import AppKit
import SwiftUI

/// Arayüz dili. Seçim AppleLanguages'a yazılır (macOS'un uygulama başına dil ayarıyla aynı yer)
/// ve yalnızca yeniden başlatınca uygulanır.
enum AppLanguage {
    /// Kod = Resources/Localizations altındaki .lproj adı; ad = dilin kendi dilindeki adı.
    static let all: [(code: String, name: String)] = [
        ("en", "English"),
        ("tr", "Türkçe"),
        ("de", "Deutsch"),
        ("es", "Español"),
        ("fr", "Français"),
        ("it", "Italiano"),
        ("pt-BR", "Português (Brasil)"),
        ("nl", "Nederlands"),
        ("pl", "Polski"),
        ("ru", "Русский"),
        ("uk", "Українська"),
        ("ku", "Kurdî (Kurmancî)"),
        ("az", "Azərbaycan dili"),
        ("ar", "العربية"),
        ("fa", "فارسی"),
        ("zh-Hans", "简体中文"),
        ("ja", "日本語"),
        ("ko", "한국어"),
    ]

    private static let key = "appLanguage"

    /// İlk açılışta nil; o zaman dil seçme penceresi gösterilir.
    static var chosen: String? { UserDefaults.standard.string(forKey: key) }

    /// Şu an arayüzde kullanılan dil.
    static var active: String { Bundle.main.preferredLocalizations.first ?? "en" }

    /// Uygulama başına seçilen dil Arapça ya da Farsça olsa da macOS pencereleri kendiliğinden sağdan sola çevirmiyor.
    static var layoutDirection: LayoutDirection {
        Locale.Language(identifier: active).characterDirection == .rightToLeft ? .rightToLeft : .leftToRight
    }

    /// Sistem dili destekleniyorsa o, değilse İngilizce.
    static var suggested: String {
        Bundle.preferredLocalizations(from: all.map(\.code), forPreferences: Locale.preferredLanguages).first ?? "en"
    }

    static func choose(_ code: String) {
        UserDefaults.standard.set(code, forKey: key)
        UserDefaults.standard.set([code], forKey: "AppleLanguages")
    }

    @MainActor static func relaunch() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/sh")
        // Bu süreç kapanmadan açılırsa LaunchServices yeni kopyayı başlatmaz.
        task.arguments = ["-c", "sleep 1; /usr/bin/open \"$0\"", Bundle.main.bundlePath]
        try? task.run()
        NSApp.terminate(nil)
    }
}

/// İlk açılışta gösterilen dil seçimi.
struct LanguagePickerView: View {
    @Environment(\.dismissWindow) private var dismissWindow
    @State private var selection: String? = AppLanguage.chosen ?? AppLanguage.suggested

    var body: some View {
        VStack(spacing: 14) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 64, height: 64)
            Text("Welcome to CodeCatcher")
                .font(.title2.bold())
            Text("Choose the app language. You can change it later in Settings.")
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(.secondary)
            List(AppLanguage.all, id: \.code, selection: $selection) { language in
                Text(verbatim: language.name)
            }
            .frame(height: 260)
            Button("Continue") {
                guard let selection else { return }
                AppLanguage.choose(selection)
                if selection == AppLanguage.active {
                    dismissWindow(id: "language")
                } else {
                    AppLanguage.relaunch()
                }
            }
            .keyboardShortcut(.defaultAction)
            .disabled(selection == nil)
        }
        .padding(24)
        .frame(width: 360)
        .onAppear { NSApp.activate() }
    }
}
