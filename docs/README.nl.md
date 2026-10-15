# CodeCatcher

[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-db61a2?logo=githubsponsors)](https://github.com/sponsors/sineld)

**Lees dit in:** [English](../README.md) · [Türkçe](README.tr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · Nederlands · [Polski](README.pl.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Kurdî](README.ku.md) · [Azərbaycan dili](README.az.md) · [العربية](README.ar.md) · [فارسی](README.fa.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

Een app voor de menubalk van macOS die eenmalige verificatiecodes herkent in sms-berichten die vanaf je iPhone worden doorgestuurd, en ze naar het klembord kopieert. De app heeft geen afhankelijkheden: SwiftUI, Foundation en de SQLite van het systeem zijn genoeg.

CodeCatcher is gratis en open source. Het is gemaakt als persoonlijk project en wordt geleverd zoals het is, zonder garantie op ondersteuning of updates. Bugmeldingen en bijdragen zijn welkom. Als het je tijd bespaart, kun je de ontwikkeling steunen via [GitHub Sponsors](https://github.com/sponsors/sineld).

## Functies

- **Slaat geen bericht over:** elke nieuwe sms sinds de laatst verwerkte wordt op volgorde afgehandeld. Sinds macOS 13 wordt de tekst van de meeste berichten alleen in de kolom `attributedBody` opgeslagen; ook die berichten worden gelezen.
- **Kiest het juiste getal:** kaartcijfers, datums, tijden, bedragen, telefoonnummers en afmeldnummers van campagnes worden eruit gefilterd; het getal dat het dichtst bij een trefwoord staat, wordt als code genomen.
- **Begrijpt veel talen:** trefwoorden in 18 talen zijn ingebouwd, en ook Chinese, Japanse en Koreaanse berichten, waarin cijfers direct naast tekens staan, werken. Hoofdletters en accenten maken niet uit, ook in het Turks: ŞİFRE, şifre en sifre zijn hetzelfde.
- **Regels zonder regex:** plak een voorbeeld-sms en selecteer de code; de regel wordt voor je geschreven en op het voorbeeld getest.
- **GİB e-Arşiv:** wachtwoorden voor e-Arşiv-facturen van de Turkse belastingdienst, die letters bevatten, worden door een standaardregel herkend.
- **18 interfacetalen:** te kiezen bij de eerste start en te wijzigen in Instellingen.
- **Privé:** berichten worden alleen op deze Mac gelezen, zonder iets te wijzigen; er wordt niets via het netwerk verstuurd.

**Vereisten:** macOS 15 of nieuwer, Xcode 16 of nieuwer om te bouwen, en het doorsturen van tekstberichten op je iPhone.

## Installatie

### Downloaden

1. Download het `.dmg`-bestand van de [nieuwste release](https://github.com/sineld/CodeCatcher/releases/latest). Het is een universele app voor Macs met Apple silicon en met Intel.
2. Open de DMG en sleep CodeCatcher naar de map Programma's.
3. De app is niet door Apple genotariseerd, dus macOS blokkeert hem de eerste keer. Probeer de app één keer te openen, ga daarna naar Systeeminstellingen → Privacy en beveiliging en klik op **Open toch**. Je kunt ook dit in Terminal uitvoeren:

   ```bash
   xattr -dr com.apple.quarantine /Applications/CodeCatcher.app
   ```

### Bouwen vanuit de broncode

```bash
scripts/build-app.sh --install   # builds, installs to ~/Applications and launches
```

**Ondertekening (aanbevolen):** de toestemming voor Volledige schijftoegang is gekoppeld aan de handtekening van de app. Bij ad-hocondertekening moet je deze na elke nieuwe build opnieuw verlenen. Om dat te voorkomen, maak je eenmalig een certificaat met de naam `CodeCatcher Local` aan via Sleutelhangertoegang → Certificaatassistent → Maak een certificaat aan (identiteitstype: Zelfondertekende root, certificaattype: Codeondertekening). Het script gebruikt dat certificaat als het dit vindt. Om een ander certificaat te gebruiken: `CODESIGN_IDENTITY="…" scripts/build-app.sh`.

### Na de installatie

1. **Volledige schijftoegang:** Systeeminstellingen → Privacy en beveiliging → Volledige schijftoegang → CodeCatcher. Zonder deze toegang kan `~/Library/Messages/chat.db` niet worden gelezen en toont de menubalk een ⚠︎-symbool.
2. Schakel op je iPhone deze Mac in onder Instellingen → Berichten → Stuur tekstberichten door.

## Taal

Bij de eerste start vraagt CodeCatcher welke taal je wilt gebruiken en onthoudt die keuze. Je kunt deze later wijzigen via Instellingen → Algemeen → Taal; de app start opnieuw op om de taal toe te passen.

Ondersteunde talen: English, Türkçe, Deutsch, Español, Français, Italiano, Português (Brasil), Nederlands, Polski, Русский, Українська, Kurdî (Kurmancî), Azərbaycan dili, العربية, فارسی, 简体中文, 日本語, 한국어.

De interfacetaal beperkt niet welke berichten worden herkend: trefwoorden voor alle ondersteunde talen zijn standaard actief.

## Hoe de code wordt gekozen

Voor elk nieuw bericht wordt het volgende op volgorde geprobeerd:

1. **Regels:** geprobeerd in de volgorde van de lijst in Instellingen → Regels; de eerste overeenkomst bepaalt de code. Je hoeft geen regex te kennen; zie “Regels op basis van een voorbeeld-sms” hieronder.

   De onderstaande standaardregel wordt bij de eerste start eenmalig aan de lijst toegevoegd. Net als elke andere regel kan hij worden bewerkt en verwijderd; een verwijderde regel komt niet vanzelf terug en kan worden hersteld met **Herstel verwijderde standaardregels**.

   | Regel | Afzender | Regex | Waarom |
   |---|---|---|---|
   | GİB e-Arşiv | `GIB` | `SIFRENIZ:\s*([A-Z0-9]{4,8})\b` | Wachtwoorden voor e-Arşiv-facturen bestaan uit 6 tekens en bevatten letters; sommige bestaan alleen uit letters |

2. **Trefwoorden:** als een van de trefwoorden in het bericht voorkomt, worden getallen van 4–8 cijfers of in de vorm `123 456` kandidaten. De standaardtrefwoorden dekken alle ondersteunde talen: `kod, şifre, parola, doğrulama, otp, code, password, passcode, código, codice, şifrə, код, пароль, رمز, کد, 验证码, 动态码, コード, 인증`.
   - **Eruit gefilterd:** delen van datums, tijden en bedragen; telefoon- en IBAN-groepen; bedragen gevolgd door een valuta zoals `TL`, `₺` of `USD`; kaartformuleringen zoals “ile biten” en “son 4 hanesi”; ordernummers na “no:”; afmeldnummers van campagnes (“3340'e RET yaz”, “OBRET->3340”).
   - Van de overgebleven kandidaten wint degene die het dichtst bij een trefwoord staat. Bij gelijke afstand krijgt degene na het trefwoord de voorkeur.

De code wordt naar het klembord gekopieerd en er verschijnt een melding. Berichten die ouder zijn dan 10 minuten, zoals berichten die na het ontwaken uit de sluimerstand worden gesynchroniseerd, worden genegeerd.

### Regels op basis van een voorbeeld-sms

Wordt de code van een afzender niet herkend, ga dan naar Instellingen → Regels → **Maak regel op basis van voorbeeld-sms…**:

1. Typ de naam van de afzender, bijvoorbeeld `GIB`.
2. Plak de volledige sms.
3. Selecteer met de muis het deel dat gekopieerd moet worden.

CodeCatcher schrijft de regel zelf:
- De vaste woorden vóór de code dienen als anker; als die er niet zijn, worden de woorden na de code gebruikt.
- De code wordt vervangen door een patroon dat bij de vorm past: alleen cijfers, of letters en cijfers, van vergelijkbare lengte.
- Voordat de regel wordt bewaard, wordt hij op de voorbeeld-sms getest. Als hij niet precies de geselecteerde code vastlegt, kan hij niet worden bewaard.

Als je bijvoorbeeld `4DAR7Q` selecteert in `… SMS SIFRENIZ: 4DAR7Q B001`, ontstaat een regel die begint met `SMS\s+SIFRENIZ\s*:\s*([A-Z0-9]{4,8})`. Die herkent ook wachtwoorden met alleen letters, zoals `ZPQRTT`. De gegenereerde regex wordt in het venster getoond en kan handmatig worden bewerkt door de regel in de lijst uit te klappen.

In het tabblad **Probeer** kun je een sms plakken en meteen zien welke code en welke regel gekozen zouden worden; ook daar kun je een regel aanmaken.

## Testen met echte berichten

```bash
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100          # digits masked
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100 --plain  # as is
```

Dit doorzoekt de laatste N ontvangen berichten en toont voor elk bericht de gekozen code en de bron ervan, waarbij de positie van de code in de tekst wordt gemarkeerd met `⟦CODE⟧`. Er wordt niets gekopieerd. Je terminal heeft volledige schijftoegang nodig.

## Ontwikkeling

GitHub Actions voert `swift test` uit bij elke push en pull request.

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

**Vertalingen:** de sleutels zijn de Engelse strings in `Sources/`. Om een string toe te voegen of te wijzigen, werk je `en.lproj` en alle andere talen bij; `LocalizationTests` mislukt als een sleutel of een `%@`-placeholder ontbreekt. Correcties van moedertaalsprekers zijn van harte welkom.

## Privacy

Berichten worden alleen gelezen uit `chat.db` op deze Mac, zonder iets te wijzigen. Er wordt niets via het netwerk verstuurd of naar schijf geschreven. Alle sms-berichten in de tests zijn verzonnen.

De herkende code wordt naar het klembord gekopieerd; apps voor klembordgeschiedenis bewaren deze codes dus ook.

## Ondersteuning

CodeCatcher is gratis. Als je de ontwikkeling wilt steunen, kun je sponsor worden via [GitHub Sponsors](https://github.com/sponsors/sineld). Een ster geven aan de repository en problemen melden helpt ook.

## Licentie

[MIT](../LICENSE)

## Ontwikkelaar

Sinan Eldem · [sinan@sinaneldem.tr](mailto:sinan@sinaneldem.tr) · [sinaneldem.tr](https://sinaneldem.tr)
