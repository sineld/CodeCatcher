# Changelog

All notable changes to this project are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- `scripts/build-app.sh` builds a universal app (Apple silicon + Intel), and `--dmg` packages it as `build/CodeCatcher-<version>.dmg`. Releases now include the DMG.

### Changed
- README: installation split into Download, Build from source and After installing, with steps for opening an app that isn't notarized.

## [1.3.0] - 2026-10-15

First public release.

### Added
- Interface in 18 languages: English, Türkçe, Deutsch, Español, Français, Italiano, Português (Brasil), Nederlands, Polski, Русский, Українська, Kurdî (Kurmancî), Azərbaycan dili, العربية, فارسی, 简体中文, 日本語, 한국어.
- Language picker on first launch; the choice is stored and can be changed under Settings → General.
- Default keywords for all supported languages.
- Code detection in Chinese, Japanese and Korean messages, where digits are written right next to letters.
- READMEs in every supported language under `docs/`, plus `CONTRIBUTING.md`, `AGENTS.md` and a GitHub Sponsors link.
- `LocalizationTests`, which checks that every UI string is translated in every language.

### Changed
- The source of a code (rule or keyword) is now shown in the interface language.
- `--dry-run` marks the code position with `⟦CODE⟧`.

## [1.2.0] - 2026-10-15

### Added
- Create a rule from a sample SMS by selecting the code; no regex needed. The rule is verified on the sample before it can be saved.
- Settings split into General, Rules, Keywords and Try It tabs.
- Developer name, email and website in the About window.

### Changed
- The GİB e-Arşiv rule is now a default rule: added once, editable and deletable, with a button to restore deleted default rules.

## [1.1.0] - 2026-10-15

### Added
- Built-in rule for GİB e-Arşiv invoice passwords, which contain letters.
- About window and app icon.

## [1.0.0] - 2026-10-15

### Added
- Menu bar app that reads new messages from `chat.db`, including messages whose text is stored only in `attributedBody`.
- Processes every new message in order instead of only the latest.
- Picks the number closest to a keyword and filters out card digits, dates, times, amounts, phone numbers, order numbers and campaign opt-out numbers.
- Turkish-aware matching: ŞİFRE, şifre and sifre are the same.
- Custom regex rules with an optional sender filter, editable keywords, clipboard copy and notifications.
- `--dry-run` to test detection on recent messages without copying anything.
