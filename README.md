# CodeCatcher

[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-db61a2?logo=githubsponsors)](https://github.com/sponsors/sineld)

**Read this in:** English · [Türkçe](docs/README.tr.md) · [Deutsch](docs/README.de.md) · [Español](docs/README.es.md) · [Français](docs/README.fr.md) · [Italiano](docs/README.it.md) · [Português (Brasil)](docs/README.pt-BR.md) · [Nederlands](docs/README.nl.md) · [Polski](docs/README.pl.md) · [Русский](docs/README.ru.md) · [Українська](docs/README.uk.md) · [Kurdî](docs/README.ku.md) · [Azərbaycan dili](docs/README.az.md) · [العربية](docs/README.ar.md) · [فارسی](docs/README.fa.md) · [简体中文](docs/README.zh-Hans.md) · [日本語](docs/README.ja.md) · [한국어](docs/README.ko.md)

A macOS menu bar app that catches one-time verification codes in SMS messages forwarded from your iPhone and copies them to the clipboard. It has no dependencies: SwiftUI, Foundation and the system SQLite are enough.

CodeCatcher is free and open source. It was built as a personal project and is provided as is, with no guarantee of support or updates. Bug reports and contributions are welcome. If it saves you time, you can support its development through [GitHub Sponsors](https://github.com/sponsors/sineld).

## Features

- **Never skips a message:** Every new SMS since the last processed one is handled in order. Since macOS 13, the text of most messages is stored only in the `attributedBody` column; those messages are read too.
- **Picks the right number:** Card digits, dates, times, amounts, phone numbers and campaign opt-out numbers are filtered out; the number closest to a keyword is taken as the code.
- **Understands many languages:** Keywords in 18 languages are built in, and Chinese, Japanese and Korean messages, where digits are written right next to letters, work too. Letter case and accents don't matter, including Turkish: ŞİFRE, şifre and sifre are the same.
- **Rules without regex:** Paste a sample SMS and select the code; the rule is written for you and tested on the sample.
- **GİB e-Arşiv:** e-Arşiv invoice passwords from Turkey's Revenue Administration, which contain letters, are caught by a default rule.
- **18 interface languages:** Chosen on first launch and changeable in Settings.
- **Private:** Messages are read only on this Mac, read-only; nothing is sent over the network.

**Requirements:** macOS 15 or later, Xcode 16 or later to build, and Text Message Forwarding on your iPhone.

## Installation

### Download

1. Download the `.dmg` file from the [latest release](https://github.com/sineld/CodeCatcher/releases/latest). It is a universal app for both Apple silicon and Intel Macs.
2. Open the DMG and drag CodeCatcher to the Applications folder.
3. The app is not notarized by Apple, so macOS blocks it the first time. Try to open it once, then go to System Settings → Privacy & Security and click **Open Anyway**. Alternatively, run this in Terminal:

   ```bash
   xattr -dr com.apple.quarantine /Applications/CodeCatcher.app
   ```

### Build from source

```bash
scripts/build-app.sh --install   # builds, installs to ~/Applications and launches
```

**Signing (recommended):** The Full Disk Access permission is tied to the app's signature. With ad-hoc signing you have to grant it again after every rebuild. To avoid that, create a certificate named `CodeCatcher Local` once in Keychain Access → Certificate Assistant → Create a Certificate (identity type: Self-Signed Root, certificate type: Code Signing). The script uses it when it finds it. To use another certificate: `CODESIGN_IDENTITY="…" scripts/build-app.sh`.

### After installing

1. **Full Disk Access:** System Settings → Privacy & Security → Full Disk Access → CodeCatcher. Without it `~/Library/Messages/chat.db` can't be read, and the menu bar shows a ⚠︎ icon.
2. On your iPhone, turn on this Mac under Settings → Messages → Text Message Forwarding.

## Language

On first launch CodeCatcher asks which language to use and remembers the choice. You can change it later under Settings → General → Language; the app restarts to apply it.

Supported languages: English, Türkçe, Deutsch, Español, Français, Italiano, Português (Brasil), Nederlands, Polski, Русский, Українська, Kurdî (Kurmancî), Azərbaycan dili, العربية, فارسی, 简体中文, 日本語, 한국어.

The interface language doesn't limit which messages are caught: keywords for all supported languages are active by default.

## How the code is chosen

For each new message, the following are tried in order:

1. **Rules:** Tried in the order of the list in Settings → Rules; the first match decides the code. You don't need to know regex; see "Rules from a sample SMS" below.

   The default rule below is added to the list once, on first launch. Like any other rule it can be edited and deleted; a deleted rule doesn't come back on its own and can be restored with **Restore Deleted Default Rules**.

   | Rule | Sender | Regex | Why |
   |---|---|---|---|
   | GİB e-Arşiv | `GIB` | `SIFRENIZ:\s*([A-Z0-9]{4,8})\b` | e-Arşiv invoice passwords are 6 characters and contain letters; some are letters only |

2. **Keywords:** If one of the keywords appears in the message, numbers with 4–8 digits or in the form `123 456` become candidates. The default keywords cover all supported languages: `kod, şifre, parola, doğrulama, otp, code, password, passcode, código, codice, şifrə, код, пароль, رمز, کد, 验证码, 动态码, コード, 인증`.
   - **Filtered out:** parts of dates, times and amounts; phone and IBAN groups; amounts followed by a currency such as `TL`, `₺` or `USD`; card phrases such as "ile biten" and "son 4 hanesi"; order numbers after "no:"; campaign opt-out numbers ("3340'e RET yaz", "OBRET->3340").
   - Of the remaining candidates, the one closest to a keyword wins. On a tie, the one after the keyword is preferred.

The code is copied to the clipboard and a notification is shown. Messages older than 10 minutes, such as those synced after waking from sleep, are ignored.

### Rules from a sample SMS

If a sender's code isn't caught, go to Settings → Rules → **Create Rule from Sample SMS…**:

1. Type the sender name, for example `GIB`.
2. Paste the whole SMS.
3. Select the part to copy with the mouse.

CodeCatcher writes the rule itself:
- The fixed words before the code are used as an anchor; if there are none, the words after the code are used.
- The code is replaced by a pattern that matches its shape: digits only, or letters and digits, of similar length.
- Before saving, the rule is tested on the sample SMS. If it doesn't capture exactly the selected code, it can't be saved.

For example, selecting `4DAR7Q` in `… SMS SIFRENIZ: 4DAR7Q B001` produces a rule that starts with `SMS\s+SIFRENIZ\s*:\s*([A-Z0-9]{4,8})`. It also catches letter-only passwords such as `ZPQRTT`. The generated regex is shown in the window and can be edited by hand by expanding the rule in the list.

In the **Try It** tab you can paste an SMS and instantly see which code and which rule would be chosen; you can create a rule from there as well.

## Testing with real messages

```bash
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100          # digits masked
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100 --plain  # as is
```

This scans the last N incoming messages and prints the chosen code and its source for each, marking the code's position in the text with `⟦CODE⟧`. Nothing is copied. Your terminal needs Full Disk Access.

## Development

GitHub Actions runs `swift test` on every push and pull request.

```bash
swift test                          # tests
scripts/build-app.sh                # build/CodeCatcher.app (universal: arm64 + x86_64)
scripts/build-app.sh --dmg          # build/CodeCatcher-<version>.dmg for a release
xcrun swift scripts/make-icon.swift # regenerates Resources/AppIcon.icns
```

```
Sources/CodeCatcher/
  App.swift            menu bar, polling loop, clipboard, notification, About, --dry-run
  Language.swift       interface languages, first-launch picker, restart
  MessageStore.swift   read-only chat.db access, attributedBody decoding
  CodeExtractor.swift  language-aware folding, rules, candidate selection and filtering
  RuleBuilder.swift    building a rule from a sample SMS and a selection
  SettingsView.swift   General, Rules, Keywords and Try It tabs
Resources/Localizations/
  <language>.lproj/Localizable.strings   interface translations; en is the source
Tests/CodeCatcherTests/
  CodeExtractorTests.swift   examples derived from real SMS templates (codes are made up)
  RuleBuilderTests.swift     a rule built from a sample works on other SMS of the same template
  RuleStorageTests.swift     default rules are added once, deleted and restored
  MessageStoreTests.swift    reading tests on a temporary chat.db copy
  LocalizationTests.swift    every interface string exists in every language
```

**Translations:** The keys are the English strings in `Sources/`. To add or change a string, update `en.lproj` and every other language; `LocalizationTests` fails if a key or a `%@` placeholder is missing. Corrections from native speakers are very welcome.

## Privacy

Messages are read only from `chat.db` on this Mac, read-only. Nothing is sent over the network or written to disk. All SMS in the tests are made up.

The caught code is copied to the clipboard; clipboard history apps will store these codes too.

## Support

CodeCatcher is free. If you'd like to support its development, you can become a sponsor on [GitHub Sponsors](https://github.com/sponsors/sineld). Starring the repository and reporting issues help too.

## License

[MIT](LICENSE)

## Developer

Sinan Eldem · [sinan@sinaneldem.tr](mailto:sinan@sinaneldem.tr) · [sinaneldem.tr](https://sinaneldem.tr)
