import AppKit
import ServiceManagement
import SwiftUI
import UserNotifications

@main
struct CodeCatcherApp: App {
    @State private var model: AppModel

    init() {
        let args = CommandLine.arguments
        if let i = args.firstIndex(of: "--dry-run") {
            let count = args.dropFirst(i + 1).first.flatMap { Int($0) } ?? 50
            exit(DryRun.run(count: count, plain: args.contains("--plain")))
        }
        _model = State(initialValue: AppModel())
    }

    var body: some Scene {
        MenuBarExtra {
            MenuContent(model: model)
        } label: {
            Image(systemName: model.accessError != nil ? "exclamationmark.triangle" : model.isPaused ? "pause.circle" : "key.fill")
        }
        Window("CodeCatcher Settings", id: "settings") {
            SettingsView(model: model)
                .environment(\.layoutDirection, AppLanguage.layoutDirection)
        }
        .windowResizability(.contentSize)
        .defaultLaunchBehavior(.suppressed)
        Window("Language", id: "language") {
            LanguagePickerView()
                .environment(\.layoutDirection, AppLanguage.layoutDirection)
        }
        .windowResizability(.contentSize)
        .defaultLaunchBehavior(AppLanguage.chosen == nil ? .presented : .suppressed)
    }
}

@Observable @MainActor
final class AppModel {
    var keywords: [String] { didSet { UserDefaults.standard.set(keywords, forKey: "keywords") } }
    var rules: [Rule] { didSet { Self.saveRules(rules) } }
    var isPaused = false
    private(set) var lastCode: String?
    private(set) var lastSender: String?
    private(set) var accessError: String?
    private(set) var launchAtLogin = SMAppService.mainApp.status == .enabled

    @ObservationIgnored private var store: MessageStore?
    @ObservationIgnored private var lastRowID: Int64 = 0
    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private let notificationDelegate = NotificationDelegate()

    static var storedKeywords: [String] { UserDefaults.standard.stringArray(forKey: "keywords") ?? CodeExtractor.defaultKeywords }
    /// Kayıtlı kurallar; varsayılan kurallar ilk açılışta bir kez sona eklenir.
    static func loadRules(from defaults: UserDefaults = .standard) -> [Rule] {
        var rules = defaults.data(forKey: "rules").flatMap { try? JSONDecoder().decode([Rule].self, from: $0) } ?? []
        if !defaults.bool(forKey: "defaultRulesSeeded") {
            rules = withDefaultRules(rules)
            saveRules(rules, to: defaults)
            defaults.set(true, forKey: "defaultRulesSeeded")
        }
        return rules
    }

    static func saveRules(_ rules: [Rule], to defaults: UserDefaults = .standard) {
        defaults.set(try? JSONEncoder().encode(rules), forKey: "rules")
    }

    /// Listede olmayan (silinmiş) varsayılan kuralları sona ekler; düzenlenmiş olanlara dokunmaz.
    static func withDefaultRules(_ rules: [Rule]) -> [Rule] {
        rules + CodeExtractor.defaultRules.filter { d in !rules.contains { $0.id == d.id } }
    }

    var isMissingDefaultRules: Bool { Self.withDefaultRules(rules).count != rules.count }

    func restoreDefaultRules() { rules = Self.withDefaultRules(rules) }

    init() {
        keywords = Self.storedKeywords
        rules = Self.loadRules()
        let center = UNUserNotificationCenter.current()
        center.delegate = notificationDelegate
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.poll() }
        }
        poll()
    }

    func poll() {
        if store == nil {
            do {
                let store = try MessageStore()
                lastRowID = try store.maxRowID() // açılıştan önceki mesajlar işlenmez
                self.store = store
                accessError = nil
            } catch {
                accessError = "\(error)"
                return
            }
        }
        do {
            guard let messages = try store?.messages(after: lastRowID), let last = messages.last else { return }
            lastRowID = last.rowID
            guard !isPaused else { return }
            // Uyku sonrası eşitlenen eski mesajlardaki kodları kopyalama.
            for message in messages where message.date > Date(timeIntervalSinceNow: -600) {
                if let found = CodeExtractor.extract(from: message.body, sender: message.sender, keywords: keywords, rules: rules) {
                    deliver(found.code, from: message.sender)
                }
            }
        } catch {
            accessError = "\(error)"
            store = nil
        }
    }

    func copyLastCode() {
        if let lastCode { copy(lastCode) }
    }

    static func openFullDiskAccessSettings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!)
    }

    func setLaunchAtLogin(_ on: Bool) {
        do {
            if on { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
        } catch {
            NSLog("CodeCatcher login item: \(error)")
        }
        launchAtLogin = SMAppService.mainApp.status == .enabled
    }

    private func deliver(_ code: String, from sender: String) {
        copy(code)
        lastCode = code
        lastSender = sender
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Code copied: \(code)")
        content.body = sender
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
    }

    private func copy(_ code: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(code, forType: .string)
    }
}

extension Extraction.Source: CustomStringConvertible {
    var description: String {
        switch self {
        case .rule(let name): String(localized: "Rule: \(name)")
        case .keyword(let keyword): String(localized: "Keyword: \(keyword)")
        }
    }
}

/// Menü çubuğu uygulaması öndeyken de bildirim görünsün.
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, Sendable {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}

struct MenuContent: View {
    @Bindable var model: AppModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        if model.accessError != nil {
            Text("Can't read messages: Full Disk Access required")
            Button("Open Full Disk Access Settings") { AppModel.openFullDiskAccessSettings() }
            Divider()
        }
        if let code = model.lastCode {
            let sender = model.lastSender ?? ""
            Button("Last code: \(code) (\(sender)) — copy") { model.copyLastCode() }
        } else {
            Text("No code caught yet")
        }
        Toggle("Pause", isOn: $model.isPaused)
        Divider()
        Button("Settings…") {
            openWindow(id: "settings")
            NSApp.activate()
        }
        .keyboardShortcut(",")
        Button("About CodeCatcher") {
            NSApp.activate()
            NSApp.orderFrontStandardAboutPanel(options: [.credits: Self.credits])
        }
        Button("Quit") { NSApp.terminate(nil) }
            .keyboardShortcut("q")
    }

    private static let credits: NSAttributedString = {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let base: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
            .foregroundColor: NSColor.secondaryLabelColor,
            .paragraphStyle: paragraph,
        ]
        var bold = base
        bold[.font] = NSFont.boldSystemFont(ofSize: NSFont.smallSystemFontSize)
        bold[.foregroundColor] = NSColor.labelColor
        func link(_ title: String, _ url: String) -> NSAttributedString {
            var attributes = base
            attributes[.link] = URL(string: url)!
            return NSAttributedString(string: title, attributes: attributes)
        }
        // Geliştirici bilgisi üstte: Hakkında panelinin metin alanı kısa, alt kısım kaydırmadan görünmüyor.
        let developer = "Sinan Eldem"
        let text = NSMutableAttributedString(string: String(localized: "Developer: \(developer)") + "\n", attributes: bold)
        text.append(link("sinan@sinaneldem.tr", "mailto:sinan@sinaneldem.tr"))
        text.append(NSAttributedString(string: "  ·  ", attributes: base))
        text.append(link("sinaneldem.tr", "https://sinaneldem.tr"))
        let about = [
            String(localized: "Catches verification codes in SMS messages forwarded from your iPhone and copies them to the clipboard. If a message is missed, create a rule from a sample SMS in Settings."),
            String(localized: "Messages are read only on this Mac and are never sent anywhere."),
        ]
        text.append(NSAttributedString(string: "\n\n" + about.joined(separator: "\n\n"), attributes: base))
        return text
    }()
}

/// `CodeCatcher --dry-run [N] [--plain]`: son N gelen mesajı tarar, sonucu yazar, hiçbir şey kopyalamaz.
/// Varsayılan çıktıda rakamlar maskelenir; --plain metni olduğu gibi gösterir.
enum DryRun {
    @MainActor static func run(count: Int, plain: Bool) -> Int32 {
        let keywords = AppModel.storedKeywords, rules = AppModel.loadRules()
        func mask(_ s: String) -> String { plain ? s : String(s.map { $0.isNumber ? "#" : $0 }) }
        do {
            for message in try MessageStore().latest(count) {
                let found = CodeExtractor.extract(from: message.body, sender: message.sender, keywords: keywords, rules: rules)
                var text = message.body.replacingOccurrences(of: "\n", with: " ")
                if let code = found?.code { text = text.replacingOccurrences(of: code, with: "⟦CODE⟧") }
                print("#\(message.rowID)  \(mask(message.sender))  →  \(found.map { "\($0.code)  (\($0.source.description))" } ?? "—")")
                print("    \(mask(text))")
            }
            return 0
        } catch {
            print("Error: \(error)")
            return 1
        }
    }
}
