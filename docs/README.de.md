# CodeCatcher

[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-db61a2?logo=githubsponsors)](https://github.com/sponsors/sineld)

**Lies dies auf:** [English](../README.md) · [Türkçe](README.tr.md) · Deutsch · [Español](README.es.md) · [Français](README.fr.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Kurdî](README.ku.md) · [Azərbaycan dili](README.az.md) · [العربية](README.ar.md) · [فارسی](README.fa.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

Eine App für die macOS-Menüleiste, die Einmal-Bestätigungscodes in SMS erkennt, die von deinem iPhone weitergeleitet werden, und sie in die Zwischenablage kopiert. Sie hat keine Abhängigkeiten: SwiftUI, Foundation und das SQLite des Systems genügen.

CodeCatcher ist kostenlos und Open Source. Es entstand als persönliches Projekt und wird so bereitgestellt, wie es ist, ohne Garantie auf Support oder Updates. Fehlerberichte und Beiträge sind willkommen. Wenn es dir Zeit spart, kannst du die Entwicklung über [GitHub Sponsors](https://github.com/sponsors/sineld) unterstützen.

## Funktionen

- **Überspringt keine Nachricht:** Jede neue SMS seit der zuletzt verarbeiteten wird der Reihe nach bearbeitet. Seit macOS 13 wird der Text der meisten Nachrichten nur in der Spalte `attributedBody` gespeichert; auch diese Nachrichten werden gelesen.
- **Wählt die richtige Zahl:** Kartenziffern, Datumsangaben, Uhrzeiten, Beträge, Telefonnummern und Abmeldenummern von Werbekampagnen werden herausgefiltert; die Zahl, die einem Schlüsselwort am nächsten steht, wird als Code verwendet.
- **Versteht viele Sprachen:** Schlüsselwörter in 18 Sprachen sind integriert, und auch chinesische, japanische und koreanische Nachrichten, in denen Ziffern direkt neben Schriftzeichen stehen, funktionieren. Groß-/Kleinschreibung und Akzente spielen keine Rolle, auch im Türkischen: ŞİFRE, şifre und sifre sind gleich.
- **Regeln ohne Regex:** Füge eine Beispiel-SMS ein und wähle den Code aus; die Regel wird für dich geschrieben und an der Beispiel-SMS getestet.
- **GİB e-Arşiv:** Die Passwörter für e-Arşiv-Rechnungen der türkischen Steuerverwaltung, die Buchstaben enthalten, werden von einer Standardregel erkannt.
- **18 Sprachen für die Oberfläche:** Wird beim ersten Start gewählt und kann in den Einstellungen geändert werden.
- **Privat:** Nachrichten werden nur auf diesem Mac und ausschließlich lesend abgerufen; nichts wird über das Netzwerk gesendet.

**Voraussetzungen:** macOS 15 oder neuer, Xcode 16 oder neuer zum Bauen und die SMS-Weiterleitung auf deinem iPhone.

## Installation

```bash
scripts/build-app.sh --install   # builds, installs to ~/Applications and launches
```

1. **Festplattenvollzugriff:** Systemeinstellungen → Datenschutz & Sicherheit → Festplattenvollzugriff → CodeCatcher. Ohne ihn kann `~/Library/Messages/chat.db` nicht gelesen werden, und die Menüleiste zeigt ein ⚠︎-Symbol.
2. **Signieren (empfohlen):** Die Berechtigung ist an die Signatur der App gebunden. Bei Ad-hoc-Signierung musst du sie nach jedem Neubau erneut erteilen. Um das zu vermeiden, erstelle einmalig unter Schlüsselbundverwaltung → Zertifikatsassistent → Zertifikat erstellen ein Zertifikat namens `CodeCatcher Local` (Identitätstyp: Selbstsigniertes Root-Zertifikat, Zertifikattyp: Codesignatur). Das Skript verwendet es, sobald es dieses findet. Um ein anderes Zertifikat zu verwenden: `CODESIGN_IDENTITY="…" scripts/build-app.sh`.
3. Aktiviere auf deinem iPhone unter Einstellungen → Nachrichten → SMS-Weiterleitung diesen Mac.

## Sprache

Beim ersten Start fragt CodeCatcher, welche Sprache verwendet werden soll, und merkt sich die Auswahl. Du kannst sie später unter Einstellungen → Allgemein → Sprache ändern; die App startet neu, um sie zu übernehmen.

Unterstützte Sprachen: English, Türkçe, Deutsch, Español, Français, Italiano, Português (Brasil), Nederlands, Polski, Русский, Українська, Kurdî (Kurmancî), Azərbaycan dili, العربية, فارسی, 简体中文, 日本語, 한국어.

Die Sprache der Oberfläche schränkt nicht ein, welche Nachrichten erkannt werden: Schlüsselwörter für alle unterstützten Sprachen sind standardmäßig aktiv.

## Wie der Code ausgewählt wird

Für jede neue Nachricht wird Folgendes der Reihe nach versucht:

1. **Regeln:** Werden in der Reihenfolge der Liste unter Einstellungen → Regeln geprüft; der erste Treffer bestimmt den Code. Du musst kein Regex beherrschen; siehe „Regeln aus einer Beispiel-SMS“ weiter unten.

   Die folgende Standardregel wird beim ersten Start einmalig zur Liste hinzugefügt. Wie jede andere Regel kann sie bearbeitet und gelöscht werden; eine gelöschte Regel kommt nicht von selbst zurück und kann mit **Gelöschte Standardregeln wiederherstellen** wiederhergestellt werden.

   | Regel | Absender | Regex | Warum |
   |---|---|---|---|
   | GİB e-Arşiv | `GIB` | `SIFRENIZ:\s*([A-Z0-9]{4,8})\b` | Passwörter für e-Arşiv-Rechnungen haben 6 Zeichen und enthalten Buchstaben; manche bestehen nur aus Buchstaben |

2. **Schlüsselwörter:** Kommt eines der Schlüsselwörter in der Nachricht vor, werden Zahlen mit 4–8 Ziffern oder in der Form `123 456` zu Kandidaten. Die Standard-Schlüsselwörter decken alle unterstützten Sprachen ab: `kod, şifre, parola, doğrulama, otp, code, password, passcode, código, codice, şifrə, код, пароль, رمز, کد, 验证码, 动态码, コード, 인증`.
   - **Herausgefiltert:** Teile von Datumsangaben, Uhrzeiten und Beträgen; Telefon- und IBAN-Gruppen; Beträge, auf die eine Währung wie `TL`, `₺` oder `USD` folgt; Kartenformulierungen wie „ile biten“ und „son 4 hanesi“; Bestellnummern nach „no:“; Abmeldenummern von Kampagnen („3340'e RET yaz“, „OBRET->3340“).
   - Von den verbleibenden Kandidaten gewinnt der, der einem Schlüsselwort am nächsten steht. Bei Gleichstand wird der Kandidat nach dem Schlüsselwort bevorzugt.

Der Code wird in die Zwischenablage kopiert und eine Mitteilung angezeigt. Nachrichten, die älter als 10 Minuten sind, etwa solche, die nach dem Aufwachen aus dem Ruhezustand synchronisiert werden, werden ignoriert.

### Regeln aus einer Beispiel-SMS

Wird der Code eines Absenders nicht erkannt, gehe zu Einstellungen → Regeln → **Regel aus Beispiel-SMS erstellen …**:

1. Gib den Absendernamen ein, zum Beispiel `GIB`.
2. Füge die vollständige SMS ein.
3. Wähle den zu kopierenden Teil mit der Maus aus.

CodeCatcher schreibt die Regel selbst:
- Die festen Wörter vor dem Code dienen als Anker; gibt es keine, werden die Wörter nach dem Code verwendet.
- Der Code wird durch ein Muster ersetzt, das seiner Form entspricht: nur Ziffern oder Buchstaben und Ziffern, mit ähnlicher Länge.
- Vor dem Sichern wird die Regel an der Beispiel-SMS getestet. Erfasst sie nicht genau den ausgewählten Code, kann sie nicht gesichert werden.

Wählst du zum Beispiel `4DAR7Q` in `… SMS SIFRENIZ: 4DAR7Q B001` aus, entsteht eine Regel, die mit `SMS\s+SIFRENIZ\s*:\s*([A-Z0-9]{4,8})` beginnt. Sie erkennt auch Passwörter, die nur aus Buchstaben bestehen, etwa `ZPQRTT`. Die erzeugte Regex wird im Fenster angezeigt und kann von Hand bearbeitet werden, indem du die Regel in der Liste aufklappst.

Im Tab **Testen** kannst du eine SMS einfügen und sofort sehen, welcher Code und welche Regel gewählt würden; auch von dort aus kannst du eine Regel erstellen.

## Mit echten Nachrichten testen

```bash
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100          # digits masked
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100 --plain  # as is
```

Damit werden die letzten N eingegangenen Nachrichten durchsucht und für jede der gewählte Code und seine Quelle ausgegeben, wobei die Position des Codes im Text mit `⟦CODE⟧` markiert wird. Es wird nichts kopiert. Dein Terminal benötigt Festplattenvollzugriff.

## Entwicklung

GitHub Actions führt `swift test` bei jedem Push und Pull Request aus.

```bash
swift test                          # tests
scripts/build-app.sh                # build/CodeCatcher.app
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

**Übersetzungen:** Die Schlüssel sind die englischen Strings in `Sources/`. Um einen String hinzuzufügen oder zu ändern, aktualisiere `en.lproj` und alle anderen Sprachen; `LocalizationTests` schlägt fehl, wenn ein Schlüssel oder ein `%@`-Platzhalter fehlt. Korrekturen von Muttersprachlern sind sehr willkommen.

## Datenschutz

Nachrichten werden nur aus `chat.db` auf diesem Mac gelesen, ausschließlich lesend. Nichts wird über das Netzwerk gesendet oder auf die Festplatte geschrieben. Alle SMS in den Tests sind erfunden.

Der erkannte Code wird in die Zwischenablage kopiert; Apps mit Verlauf für die Zwischenablage speichern diese Codes ebenfalls.

## Unterstützung

CodeCatcher ist kostenlos. Wenn du die Entwicklung unterstützen möchtest, kannst du auf [GitHub Sponsors](https://github.com/sponsors/sineld) Sponsor werden. Ein Stern für das Repository und das Melden von Problemen helfen ebenfalls.

## Lizenz

[MIT](../LICENSE)

## Entwickler

Sinan Eldem · [sinan@sinaneldem.tr](mailto:sinan@sinaneldem.tr) · [sinaneldem.tr](https://sinaneldem.tr)
