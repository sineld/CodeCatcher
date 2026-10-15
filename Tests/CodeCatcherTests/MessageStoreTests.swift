import Foundation
import SQLite3
import Testing
@testable import CodeCatcher

struct MessageStoreTests {
    private struct Row {
        var text: String?
        var attributed: String?
        var fromMe = false
        var sender = "AKBANK"
        var date: Int64 = 0
    }

    /// chat.db'nin okuduğumuz sütunlarıyla geçici bir kopyası; her satıra bir handle.
    private func makeDatabase(_ rows: [Row]) throws -> String {
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".db").path
        var db: OpaquePointer?
        try #require(sqlite3_open(path, &db) == SQLITE_OK)
        defer { sqlite3_close(db) }
        try #require(sqlite3_exec(db, """
            CREATE TABLE handle (ROWID INTEGER PRIMARY KEY, id TEXT);
            CREATE TABLE message (ROWID INTEGER PRIMARY KEY, date INTEGER, text TEXT, attributedBody BLOB, is_from_me INTEGER, handle_id INTEGER);
            """, nil, nil, nil) == SQLITE_OK)

        let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        for (i, row) in rows.enumerated() {
            var stmt: OpaquePointer?
            sqlite3_prepare_v2(db, "INSERT INTO handle (ROWID, id) VALUES (?1, ?2)", -1, &stmt, nil)
            sqlite3_bind_int64(stmt, 1, Int64(i + 1))
            sqlite3_bind_text(stmt, 2, row.sender, -1, transient)
            try #require(sqlite3_step(stmt) == SQLITE_DONE)
            sqlite3_finalize(stmt)

            sqlite3_prepare_v2(db, "INSERT INTO message (ROWID, date, text, attributedBody, is_from_me, handle_id) VALUES (?1, ?2, ?3, ?4, ?5, ?1)", -1, &stmt, nil)
            sqlite3_bind_int64(stmt, 1, Int64(i + 1))
            sqlite3_bind_int64(stmt, 2, row.date)
            if let text = row.text { sqlite3_bind_text(stmt, 3, text, -1, transient) }
            if let attributed = row.attributed {
                // Messages'ın yazdığı biçim: NSArchiver typedstream
                let data = NSArchiver.archivedData(withRootObject: NSAttributedString(string: attributed))
                _ = data.withUnsafeBytes { sqlite3_bind_blob(stmt, 4, $0.baseAddress, Int32(data.count), transient) }
            }
            sqlite3_bind_int(stmt, 5, row.fromMe ? 1 : 0)
            try #require(sqlite3_step(stmt) == SQLITE_DONE)
            sqlite3_finalize(stmt)
        }
        return path
    }

    @Test func readsTextAndAttributedBodySkipsOwnMessages() throws {
        let store = try MessageStore(path: makeDatabase([
            Row(text: "Kodunuz: 111111"),
            Row(attributed: "Şifreniz: 222222", sender: "+900000000000"),
            Row(text: "benim mesajım 333333", fromMe: true),
            Row(),
        ]))
        let messages = try store.latest(10)
        #expect(messages.map(\.rowID) == [1, 2, 4])
        #expect(messages.map(\.body) == ["Kodunuz: 111111", "Şifreniz: 222222", ""])
        #expect(messages.map(\.sender) == ["AKBANK", "+900000000000", "AKBANK"])
        #expect(try store.maxRowID() == 4)
    }

    @Test func returnsOnlyMessagesAfterRowIDInOrder() throws {
        let store = try MessageStore(path: makeDatabase([Row(text: "a"), Row(text: "b"), Row(text: "c")]))
        #expect(try store.messages(after: 1).map(\.body) == ["b", "c"])
        #expect(try store.messages(after: 3).isEmpty)
        #expect(try store.latest(2).map(\.body) == ["b", "c"])
    }

    @Test func convertsAppleNanosecondDates() throws {
        let store = try MessageStore(path: makeDatabase([Row(text: "a", date: 86_400 * 1_000_000_000)]))
        #expect(try store.latest(1).first?.date == Date(timeIntervalSinceReferenceDate: 86_400))
    }

    @Test func textWinsOverAttributedBody() {
        let data = NSArchiver.archivedData(withRootObject: NSAttributedString(string: "eski"))
        #expect(MessageStore.decodeBody(text: "yeni", attributedBody: data) == "yeni")
        #expect(MessageStore.decodeBody(text: "", attributedBody: data) == "eski")
        #expect(MessageStore.decodeBody(text: nil, attributedBody: nil) == nil)
    }

    @Test func missingDatabaseThrows() {
        #expect(throws: MessageStoreError.self) { try MessageStore(path: "/nonexistent/chat.db") }
    }
}
