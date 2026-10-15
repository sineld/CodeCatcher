import Foundation
import Testing
@testable import CodeCatcher

@MainActor
struct RuleStorageTests {
    private func freshDefaults() -> UserDefaults {
        let suite = "CodeCatcherTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    private let gib = CodeExtractor.defaultRules[0]

    @Test func firstLaunchSeedsDefaultRules() {
        let defaults = freshDefaults()
        #expect(AppModel.loadRules(from: defaults) == [gib])
        #expect(AppModel.loadRules(from: defaults) == [gib]) // ikinci açılışta tekrar eklenmez
    }

    @Test func existingUsersGetDefaultsOnceAfterTheirOwnRules() throws {
        let defaults = freshDefaults()
        let mine = Rule(name: "benim", pattern: "x")
        AppModel.saveRules([mine], to: defaults)
        #expect(AppModel.loadRules(from: defaults) == [mine, gib])
    }

    @Test func deletedDefaultRuleStaysDeleted() {
        let defaults = freshDefaults()
        _ = AppModel.loadRules(from: defaults)
        AppModel.saveRules([], to: defaults)
        #expect(AppModel.loadRules(from: defaults).isEmpty)
    }

    @Test func editedDefaultRuleIsKeptAndNotDuplicatedOnRestore() {
        var edited = gib
        edited.name = "e-Arşiv (benim)"
        edited.pattern = #"SIFRENIZ:\s*(\w{6})"#
        #expect(AppModel.withDefaultRules([edited]) == [edited])
    }

    @Test func restoreAddsOnlyMissingDefaults() {
        let mine = Rule(name: "benim", pattern: "x")
        #expect(AppModel.withDefaultRules([mine]) == [mine, gib])
        #expect(AppModel.withDefaultRules([mine, gib]) == [mine, gib])
    }
}
