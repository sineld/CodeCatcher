# CodeCatcher

[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-db61a2?logo=githubsponsors)](https://github.com/sponsors/sineld)

**Bi vî zimanî bixwîne:** [English](../README.md) · [Türkçe](README.tr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · Kurdî · [Azərbaycan dili](README.az.md) · [العربية](README.ar.md) · [فارسی](README.fa.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

Sepaneke darika menuyê ya macOS’ê ye ku kodên piştrastkirinê yên yekcarî di peyamên SMS de yên ku ji iPhone’a te têne veguhastin digire û wan li panoyê (clipboard) kopî dike. Tu girêdayîbûna wê tune: SwiftUI, Foundation û SQLite’a pergalê bes in.

CodeCatcher belaş û çavkaniya vekirî ye. Wekî projeyeke kesane hatiye çêkirin û wekî xwe tê pêşkêşkirin, bê garantiya piştgirî an nûkirinan. Raporên çewtiyan û beşdarî bi kêfxweşî têne pêşwazîkirin. Heke dema te xilas dike, tu dikarî bi rêya [GitHub Sponsors](https://github.com/sponsors/sineld) piştgiriya pêşdebirina wê bikî.

## Taybetmendî

- **Tu peyamê ji dest nade:** Her SMS’a nû ya piştî ya dawî ya hatî pêvajokirin bi rêzê tê pêvajokirin. Ji macOS 13 û pê ve, nivîsa piraniya peyaman tenê di stûna `attributedBody` de tê tomarkirin; ew peyam jî têne xwendin.
- **Hejmara rast hildibijêre:** Reqemên kartê, dîrok, dem, mîqdar, hejmarên telefonê û hejmarên betalkirina kampanyayan têne parzûnkirin; hejmara herî nêzîkî peyveke sereke wekî kod tê girtin.
- **Gelek zimanan fam dike:** Peyvên sereke bi 18 zimanan di nav de ne, û peyamên bi çînî, japonî û koreyî, ku tê de reqem rasterast li kêleka tîpan têne nivîsandin, jî dixebitin. Tîpên mezin û biçûk û nîşanên ser tîpan ne girîng in, tirkî jî tê de: ŞİFRE, şifre û sifre yek in.
- **Rêgez bê regex:** SMS’eke nimûne pêve bike û kodê hilbijêre; rêgez ji bo te tê nivîsandin û li ser nimûneyê tê ceribandin.
- **GİB e-Arşiv:** Şîfreyên fatûreyên e-Arşiv ên Rêveberiya Dahatê ya Tirkiyeyê, ku tîp jî tê de hene, bi rêgezeke standard têne girtin.
- **18 zimanên navrûyê:** Di destpêkirina yekem de tê hilbijartin û di Mîhengan de dikare were guhertin.
- **Taybet:** Peyam tenê li ser vê Mac’ê û tenê ji bo xwendinê têne vekirin; tiştek bi torê nayê şandin.

**Pêdivî:** macOS 15 an nûtir, ji bo avakirinê Xcode 16 an nûtir, û li ser iPhone’a te Veguhastina Peyamên Nivîsê (Text Message Forwarding).

## Sazkirin

### Daxistin

1. Pelê `.dmg` ji [weşana herî dawî](https://github.com/sineld/CodeCatcher/releases/latest) daxe. Ew sepaneke gerdûnî (universal) ye, hem ji bo Mac’ên bi Apple silicon û hem jî ji bo Mac’ên bi Intel.
2. DMG’ê veke û CodeCatcher bikişîne peldanka Applications.
3. Sepan ji aliyê Apple ve nehatiye notarîzekirin (notarized), ji ber vê yekê macOS cara yekem wê asteng dike. Carekê hewl bide ku wê vekî, paşê here Mîhengên Pergalê (System Settings) → Nepenî û Ewlehî (Privacy & Security) û li **Dîsa jî Veke** (Open Anyway) bitikîne. Wekî din, tu dikarî vê fermanê di Termînalê de bixebitînî:

   ```bash
   xattr -dr com.apple.quarantine /Applications/CodeCatcher.app
   ```

### Ji koda çavkaniyê avakirin

```bash
scripts/build-app.sh --install   # builds, installs to ~/Applications and launches
```

**Îmzekirin (tê pêşniyarkirin):** Destûra Gihîştina Tevahiya Dîskê bi îmzeya sepanê ve girêdayî ye. Bi îmzekirina ad-hoc divê tu piştî her avakirineke nû destûrê dîsa bidî. Ji bo ku ev neqewime, carekê di Keychain Access → Certificate Assistant → Create a Certificate de sertîfîkayeke bi navê `CodeCatcher Local` çêke (identity type: Self-Signed Root, certificate type: Code Signing). Skrîpt dema ku wê bibîne, wê bi kar tîne. Ji bo bikaranîna sertîfîkayeke din: `CODESIGN_IDENTITY="…" scripts/build-app.sh`.

### Piştî sazkirinê

1. **Gihîştina Tevahiya Dîskê:** Mîhengên Pergalê (System Settings) → Nepenî û Ewlehî (Privacy & Security) → Gihîştina Tevahiya Dîskê (Full Disk Access) → CodeCatcher. Bêyî wê `~/Library/Messages/chat.db` nayê xwendin, û di darika menuyê de nîşaneya ⚠︎ xuya dike.
2. Li ser iPhone’a xwe, di bin Mîheng (Settings) → Peyam (Messages) → Veguhastina Peyamên Nivîsê (Text Message Forwarding) de vê Mac’ê vêxe.

## Ziman

Di destpêkirina yekem de CodeCatcher dipirse ka kîjan ziman were bikaranîn û hilbijartinê bi bîr tîne. Tu dikarî paşê di bin Mîheng → Giştî → Ziman de biguherînî; ji bo sepandinê sepan ji nû ve dest pê dike.

Zimanên piştgirîkirî: English, Türkçe, Deutsch, Español, Français, Italiano, Português (Brasil), Nederlands, Polski, Русский, Українська, Kurdî (Kurmancî), Azərbaycan dili, العربية, فارسی, 简体中文, 日本語, 한국어.

Zimanê navrûyê sînor nake ka kîjan peyam têne girtin: peyvên sereke yên hemû zimanên piştgirîkirî bi awayê standard çalak in.

## Kod çawa tê hilbijartin

Ji bo her peyameke nû, yên jêrîn bi rêzê têne ceribandin:

1. **Rêgez:** Bi rêza lîsteyê ya di Mîheng → Rêgez de têne ceribandin; lihevhatina yekem kodê diyar dike. Ne pêwîst e tu regex zanibî; li jêr li “Rêgez ji SMS’eke nimûne” binêre.

   Rêgeza standard a jêrîn carekê, di destpêkirina yekem de, li lîsteyê tê zêdekirin. Mîna her rêgezeke din dikare were guhertin û jêbirin; rêgezeke jêbirî bi serê xwe venagere û bi **Rêgezên standard ên jêbirî vegerîne** dikare were vegerandin.

   | Rêgez | Şandyar | Regex | Çima |
   |---|---|---|---|
   | GİB e-Arşiv | `GIB` | `SIFRENIZ:\s*([A-Z0-9]{4,8})\b` | şîfreyên fatûreyên e-Arşiv 6 karakter in û tîp tê de hene; hin ji wan tenê ji tîpan pêk tên |

2. **Peyvên sereke:** Heke yek ji peyvên sereke di peyamê de derkeve, hejmarên bi 4–8 reqeman an bi şiklê `123 456` dibin berendam. Peyvên sereke yên standard hemû zimanên piştgirîkirî digirin: `kod, şifre, parola, doğrulama, otp, code, password, passcode, código, codice, şifrə, код, пароль, رمز, کد, 验证码, 动态码, コード, 인증`.
   - **Têne parzûnkirin:** beşên dîrok, dem û mîqdaran; komên reqemên telefon û IBAN’ê; mîqdarên ku pereyekî wekî `TL`, `₺` an `USD` li pey wan tê; gotinên kartê yên wekî “ile biten” û “son 4 hanesi”; hejmarên siparîşê yên piştî “no:”; hejmarên betalkirina kampanyayan (“3340'e RET yaz”, “OBRET->3340”).
   - Ji berendamên mayî, yê herî nêzîkî peyveke sereke bi ser dikeve. Di wekheviyê de, yê piştî peyva sereke tê tercîhkirin.

Kod li panoyê tê kopîkirin û agahdariyek tê nîşandan. Peyamên ji 10 deqîqeyan kevntir, wekî yên ku piştî şiyarbûna ji xewê têne hevdemkirin, têne paşguhkirin.

### Rêgez ji SMS’eke nimûne

Heke koda şandyarekî neyê girtin, here Mîheng → Rêgez → **Ji SMS’eke nimûne rêgez çêke…**:

1. Navê şandyar binivîse, bo nimûne `GIB`.
2. Tevahiya SMS’ê pêve bike.
3. Bi mişkê beşa ku dê were kopîkirin hilbijêre.

CodeCatcher rêgezê bi xwe dinivîse:
- Peyvên neguhêr ên berî kodê wekî lenger têne bikaranîn; heke tune bin, peyvên piştî kodê têne bikaranîn.
- Kod bi şablonekê tê guhertin ku li gorî şiklê wê ye: tenê reqem, an tîp û reqem, bi dirêjahiyeke nêzîk.
- Berî tomarkirinê, rêgez li ser SMS’a nimûne tê ceribandin. Heke tam koda hilbijartî negire, nayê tomarkirin.

Bo nimûne, hilbijartina `4DAR7Q` di `… SMS SIFRENIZ: 4DAR7Q B001` de rêgezekê çêdike ku bi `SMS\s+SIFRENIZ\s*:\s*([A-Z0-9]{4,8})` dest pê dike. Ew şîfreyên tenê ji tîpan ên wekî `ZPQRTT` jî digire. Regexa çêkirî di paceyê de tê nîşandan û bi vekirina rêgezê di lîsteyê de dikare bi destan were guhertin.

Di beşa **Biceribîne** de tu dikarî SMS’ekê pêve bikî û yekser bibînî ka kîjan kod û kîjan rêgez dê were hilbijartin; tu dikarî ji wir jî rêgezekê çêkî.

## Ceribandin bi peyamên rastîn

```bash
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100          # digits masked
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100 --plain  # as is
```

Ev ferman N peyamên dawî yên hatî kontrol dike û ji bo her yekê koda hilbijartî û çavkaniya wê çap dike, û cihê kodê di nivîsê de bi `⟦CODE⟧` nîşan dide. Tiştek nayê kopîkirin. Termînala te pêdivî bi Gihîştina Tevahiya Dîskê heye.

## Pêşdebirin

GitHub Actions di her push û pull request de `swift test` dixebitîne.

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

**Werger:** Mifte rêzikên îngilîzî yên di `Sources/` de ne. Ji bo zêdekirin an guhertina rêzikekê, `en.lproj` û hemû zimanên din nû bike; heke miftek an cîgirê `%@` kêm be, `LocalizationTests` têk diçe. Rastkirinên axêverên zikmakî pir bi kêfxweşî têne pêşwazîkirin.

## Nepenî

Peyam tenê ji `chat.db` a li ser vê Mac’ê û tenê ji bo xwendinê têne vekirin. Tiştek bi torê nayê şandin û li dîskê nayê nivîsandin. Hemû SMS’ên di testan de çêkirî ne.

Koda hatî girtin li panoyê tê kopîkirin; sepanên dîroka panoyê dê van kodan jî tomar bikin.

## Piştgirî

CodeCatcher belaş e. Heke tu dixwazî piştgiriya pêşdebirina wê bikî, tu dikarî li ser [GitHub Sponsors](https://github.com/sponsors/sineld) bibî sponsor. Stêrkdayîna depoyê û raporkirina pirsgirêkan jî dibin alîkar.

## Lîsans

[MIT](../LICENSE)

## Pêşdebir

Sinan Eldem · [sinan@sinaneldem.tr](mailto:sinan@sinaneldem.tr) · [sinaneldem.tr](https://sinaneldem.tr)
