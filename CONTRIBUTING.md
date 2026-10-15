# Contributing to CodeCatcher

Thanks for helping! CodeCatcher is a small, free, dependency-free macOS app. Bug reports, new rules for senders that aren't caught, translation fixes and code changes are all welcome.

## Reporting a missed or wrong code

Open an issue with:

- the sender name as it appears in Messages,
- the SMS text **with the code and any personal data replaced** (keep the structure: replace `482913` with another 6-digit number, names with "Name Surname", and so on),
- what CodeCatcher copied, if anything, and what it should have copied. The **Try It** tab in Settings shows this.

Never paste a real code, phone number, card number or personal data into an issue.

## Development setup

Requirements: macOS 15 or later and Xcode 16 or later.

```bash
git clone https://github.com/sineld/CodeCatcher.git
cd CodeCatcher
swift test                      # run before every pull request
scripts/build-app.sh --install  # build the .app and run it
```

The app needs Full Disk Access to read `~/Library/Messages/chat.db`. See the README for signing tips so the permission survives rebuilds.

## Pull requests

1. Keep each pull request focused on one change.
2. For changes to code detection, add a test case that fails before your change. Use made-up messages that follow the real template.
3. Don't add third-party dependencies.
4. Run `swift test`; GitHub Actions runs it too.
5. Update `CHANGELOG.md` under **Unreleased**.
6. Use a short, imperative English commit message, for example `Add PLN to amount filter`.

## Translations

The English UI strings in the code are the keys. Translations live in `Resources/Localizations/<code>.lproj/Localizable.strings`, and translated READMEs live in `docs/`.

- **Fixing a translation:** edit the value on the right side only. Keep every `%@` placeholder; you may write `%1$@` and `%2$@` to change their order.
- **Adding or changing a UI string:** change the code, then update `en.lproj` and every other language. `LocalizationTests` fails if a key is missing or unused, or if its placeholders don't match.
- **Adding a language:** add it to `AppLanguage.all` in `Sources/CodeCatcher/Language.swift` and to `CFBundleLocalizations` in `Resources/Info.plist`. Then create `<code>.lproj/Localizable.strings` and `docs/README.<code>.md`, and add the language to the "Read this in" line of every README.
- Use the names macOS itself uses for system settings in your language, such as Full Disk Access and System Settings.

Native speakers reviewing the current translations is one of the most useful contributions; most of them have not been reviewed yet.

## Code of conduct

Be kind and assume good intent. Harassment or discrimination isn't tolerated.

## Support

If CodeCatcher is useful to you, you can support it through [GitHub Sponsors](https://github.com/sponsors/sineld).
