import Foundation
import SQLite3

struct IncomingMessage {
    let rowID: Int64
    let date: Date
    let sender: String
    let body: String
}

struct MessageStoreError: Error, CustomStringConvertible {
    let description: String
}

/// ~/Library/Messages/chat.db için salt okunur erişim. Tam Disk Erişimi gerekir.
final class MessageStore {
    static let path = NSHomeDirectory() + "/Library/Messages/chat.db"
    private var db: OpaquePointer?

    init(path: String = MessageStore.path) throws {
        guard sqlite3_open_v2(path, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else { throw lastError() }
        sqlite3_busy_timeout(db, 1000)
        _ = try maxRowID() // izin yoksa açılış değil ilk sorgu düşer
    }

    deinit { sqlite3_close(db) }

    func maxRowID() throws -> Int64 {
        try query("SELECT IFNULL(MAX(ROWID), 0) FROM message") { sqlite3_column_int64($0, 0) }.first ?? 0
    }

    /// Verilen ROWID'den sonra gelen tüm mesajlar, eskiden yeniye.
    func messages(after rowID: Int64) throws -> [IncomingMessage] {
        try query(Self.select + " WHERE m.ROWID > ?1 AND m.is_from_me = 0 ORDER BY m.ROWID LIMIT 200", rowID, Self.row)
    }

    /// Son `count` gelen mesaj, eskiden yeniye.
    func latest(_ count: Int) throws -> [IncomingMessage] {
        try query(Self.select + " WHERE m.is_from_me = 0 ORDER BY m.ROWID DESC LIMIT ?1", Int64(count), Self.row).reversed()
    }

    static func decodeBody(text: String?, attributedBody: Data?) -> String? {
        if let text, !text.isEmpty { return text }
        // macOS 13+ mesajların çoğunda text NULL; içerik NSArchiver typedstream olarak attributedBody'de.
        // shortcut: bozuk bir blob ObjC exception ile uygulamayı düşürebilir; görülürse typedstream'i elle ayrıştır.
        guard let attributedBody else { return nil }
        return (NSUnarchiver.unarchiveObject(with: attributedBody) as? NSAttributedString)?.string
    }

    private static let select = """
        SELECT m.ROWID, m.date, m.text, m.attributedBody, IFNULL(h.id, '')
        FROM message m LEFT JOIN handle h ON h.ROWID = m.handle_id
        """

    private static func row(_ s: OpaquePointer) -> IncomingMessage {
        let text = sqlite3_column_text(s, 2).map { String(cString: $0) }
        let blob = sqlite3_column_blob(s, 3).map { Data(bytes: $0, count: Int(sqlite3_column_bytes(s, 3))) }
        return IncomingMessage(
            rowID: sqlite3_column_int64(s, 0),
            // chat.db tarihi: 2001-01-01'den beri nanosaniye
            date: Date(timeIntervalSinceReferenceDate: Double(sqlite3_column_int64(s, 1)) / 1_000_000_000),
            sender: sqlite3_column_text(s, 4).map { String(cString: $0) } ?? "",
            body: decodeBody(text: text, attributedBody: blob) ?? ""
        )
    }

    private func query<T>(_ sql: String, _ arg: Int64? = nil, _ row: (OpaquePointer) -> T) throws -> [T] {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK, let stmt else { throw lastError() }
        defer { sqlite3_finalize(stmt) }
        if let arg { sqlite3_bind_int64(stmt, 1, arg) }
        var rows: [T] = []
        while true {
            switch sqlite3_step(stmt) {
            case SQLITE_ROW: rows.append(row(stmt))
            case SQLITE_DONE: return rows
            default: throw lastError()
            }
        }
    }

    private func lastError() -> MessageStoreError {
        MessageStoreError(description: "chat.db: " + String(cString: sqlite3_errmsg(db)))
    }
}
