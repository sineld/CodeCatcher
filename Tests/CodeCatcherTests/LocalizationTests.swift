import Foundation
import Testing
@testable import CodeCatcher

struct LocalizationTests {
    private static let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    private static let localizations = root.appending(path: "Resources/Localizations")

    private static func strings(_ code: String) -> [String: String] {
        NSDictionary(contentsOf: localizations.appending(path: "\(code).lproj/Localizable.strings")) as? [String: String] ?? [:]
    }

    /// Kaynak koddaki arayüz metinleri. Anahtar İngilizce metnin kendisi; \(…) yerine %@ geçer.
    private static func sourceKeys() throws -> Set<String> {
        let literal = try NSRegularExpression(pattern: #"(?:\b(?:Text|Button|Label|Toggle|LabeledContent|TextField|Section|Tab|Window|DisclosureGroup|Picker)|\.help)\(\s*"((?:[^"\\]|\\.)*)"|String\(localized:\s*"((?:[^"\\]|\\.)*)""#)
        let interpolation = try NSRegularExpression(pattern: #"\\\([^()]*\)"#)
        var keys = Set<String>()
        let sources = try FileManager.default.contentsOfDirectory(at: root.appending(path: "Sources/CodeCatcher"), includingPropertiesForKeys: nil)
        for file in sources where file.pathExtension == "swift" {
            let text = try String(contentsOf: file, encoding: .utf8)
            for match in literal.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
                let group = match.range(at: 1).location != NSNotFound ? match.range(at: 1) : match.range(at: 2)
                let raw = String(text[Range(group, in: text)!])
                keys.insert(interpolation.stringByReplacingMatches(in: raw, range: NSRange(raw.startIndex..., in: raw), withTemplate: "%@"))
            }
        }
        return keys
    }

    private static func placeholders(_ s: String) -> Int {
        s.ranges(of: /%(\d+\$)?@/).count
    }

    @Test func englishFileMatchesSourceStrings() throws {
        let english = Set(Self.strings("en").keys)
        let source = try Self.sourceKeys()
        #expect(source.subtracting(english).sorted() == [], "en.lproj'da eksik")
        #expect(english.subtracting(source).sorted() == [], "kaynakta kullanılmıyor")
    }

    @Test(arguments: AppLanguage.all.map(\.code))
    func translationIsComplete(code: String) {
        let english = Self.strings("en"), translated = Self.strings(code)
        #expect(!translated.isEmpty)
        #expect(Set(translated.keys) == Set(english.keys))
        for (key, value) in translated {
            #expect(!value.trimmingCharacters(in: .whitespaces).isEmpty, "\(code): \(key)")
            #expect(Self.placeholders(value) == Self.placeholders(key), "\(code): \(key)")
        }
    }

    @Test func languageListMatchesFoldersAndInfoPlist() throws {
        let folders = try FileManager.default.contentsOfDirectory(atPath: Self.localizations.path)
            .filter { $0.hasSuffix(".lproj") }
            .map { String($0.dropLast(".lproj".count)) }
        let declared = NSDictionary(contentsOf: Self.root.appending(path: "Resources/Info.plist"))?["CFBundleLocalizations"] as? [String]
        #expect(Set(folders) == Set(AppLanguage.all.map(\.code)))
        #expect(declared == AppLanguage.all.map(\.code))
    }
}
