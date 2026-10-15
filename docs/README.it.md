# CodeCatcher

[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-db61a2?logo=githubsponsors)](https://github.com/sponsors/sineld)

**Leggi in:** [English](../README.md) · [Türkçe](README.tr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) · Italiano · [Português (Brasil)](README.pt-BR.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Kurdî](README.ku.md) · [Azərbaycan dili](README.az.md) · [العربية](README.ar.md) · [فارسی](README.fa.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

Un’app per la barra dei menu di macOS che rileva i codici di verifica monouso negli SMS inoltrati dal tuo iPhone e li copia negli appunti. Non ha dipendenze: bastano SwiftUI, Foundation e l’SQLite di sistema.

CodeCatcher è gratuito e open source. È nato come progetto personale ed è fornito così com’è, senza garanzia di supporto o aggiornamenti. Segnalazioni di bug e contributi sono benvenuti. Se ti fa risparmiare tempo, puoi sostenerne lo sviluppo tramite [GitHub Sponsors](https://github.com/sponsors/sineld).

## Funzionalità

- **Non salta nessun messaggio:** ogni nuovo SMS arrivato dopo l’ultimo elaborato viene gestito in ordine. Da macOS 13 il testo della maggior parte dei messaggi è salvato solo nella colonna `attributedBody`; anche questi messaggi vengono letti.
- **Sceglie il numero giusto:** cifre della carta, date, orari, importi, numeri di telefono e numeri per disiscriversi dalle campagne vengono esclusi; il numero più vicino a una parola chiave viene preso come codice.
- **Capisce molte lingue:** sono integrate parole chiave in 18 lingue, e funzionano anche i messaggi in cinese, giapponese e coreano, dove le cifre sono scritte attaccate ai caratteri. Maiuscole, minuscole e accenti non contano, turco compreso: ŞİFRE, şifre e sifre sono uguali.
- **Regole senza regex:** incolla un SMS di esempio e seleziona il codice; la regola viene scritta per te e testata sull’esempio.
- **GİB e-Arşiv:** le password delle fatture e-Arşiv dell’amministrazione fiscale turca, che contengono lettere, vengono rilevate da una regola predefinita.
- **18 lingue dell’interfaccia:** si sceglie al primo avvio e si può cambiare nelle Impostazioni.
- **Privato:** i messaggi vengono letti solo su questo Mac, in sola lettura; nulla viene inviato in rete.

**Requisiti:** macOS 15 o versioni successive, Xcode 16 o versioni successive per la compilazione e l’inoltro dei messaggi attivo sul tuo iPhone.

## Screenshot

| Crea una regola da un SMS di esempio | Prova |
|:---:|:---:|
| <img src="images/rule-builder.png" width="400" alt="Crea una regola da un SMS di esempio"> | <img src="images/try-it.png" width="400" alt="Prova"> |
| **Generali** | **Parole chiave** |
| <img src="images/settings-general.png" width="400" alt="Generali"> | <img src="images/keywords.png" width="400" alt="Parole chiave"> |

<p align="center"><img src="images/language-picker.png" width="260" alt="Lingua"><br><em>Lingua</em></p>

## Installazione

### Download

1. Scarica il file `.dmg` dall’[ultima release](https://github.com/sineld/CodeCatcher/releases/latest). È un’app universale per Mac con Apple silicon e con processore Intel.
2. Apri il DMG e trascina CodeCatcher nella cartella Applicazioni.
3. L’app non è notarizzata da Apple, quindi macOS la blocca la prima volta. Prova ad aprirla una volta, poi vai in Impostazioni di Sistema → Privacy e sicurezza e fai clic su **Apri comunque**. In alternativa, esegui questo comando nel Terminale:

   ```bash
   xattr -dr com.apple.quarantine /Applications/CodeCatcher.app
   ```

### Compilare dal codice sorgente

```bash
scripts/build-app.sh --install   # builds, installs to ~/Applications and launches
```

**Firma (consigliata):** il permesso Accesso completo al disco è legato alla firma dell’app. Con la firma ad hoc devi concederlo di nuovo dopo ogni ricompilazione. Per evitarlo, crea una sola volta un certificato chiamato `CodeCatcher Local` in Accesso Portachiavi → Assistente Certificato → Crea un certificato (tipo di identità: Radice autofirmata, tipo di certificato: Firma codice). Lo script lo usa se lo trova. Per usare un altro certificato: `CODESIGN_IDENTITY="…" scripts/build-app.sh`.

### Dopo l’installazione

1. **Accesso completo al disco:** Impostazioni di Sistema → Privacy e sicurezza → Accesso completo al disco → CodeCatcher. Senza questo permesso `~/Library/Messages/chat.db` non può essere letto e nella barra dei menu compare un’icona ⚠︎.
2. Sul tuo iPhone, attiva questo Mac in Impostazioni → Messaggi → Inoltro messaggi.

## Lingua

Al primo avvio CodeCatcher chiede quale lingua usare e ricorda la scelta. Puoi cambiarla in seguito in Impostazioni → Generali → Lingua; l’app si riavvia per applicarla.

Lingue supportate: English, Türkçe, Deutsch, Español, Français, Italiano, Português (Brasil), Nederlands, Polski, Русский, Українська, Kurdî (Kurmancî), Azərbaycan dili, العربية, فارسی, 简体中文, 日本語, 한국어.

La lingua dell’interfaccia non limita i messaggi rilevati: le parole chiave di tutte le lingue supportate sono attive per impostazione predefinita.

## Come viene scelto il codice

Per ogni nuovo messaggio vengono provati, in ordine:

1. **Regole:** provate nell’ordine della lista in Impostazioni → Regole; la prima corrispondenza determina il codice. Non serve conoscere le regex; vedi “Regole da un SMS di esempio” più avanti.

   La regola predefinita qui sotto viene aggiunta alla lista una sola volta, al primo avvio. Come ogni altra regola può essere modificata ed eliminata; una regola eliminata non ricompare da sola e può essere ripristinata con **Ripristina regole predefinite eliminate**.

   | Regola | Mittente | Regex | Perché |
   |---|---|---|---|
   | GİB e-Arşiv | `GIB` | `SIFRENIZ:\s*([A-Z0-9]{4,8})\b` | Le password delle fatture e-Arşiv sono di 6 caratteri e contengono lettere; alcune sono composte solo da lettere |

2. **Parole chiave:** se nel messaggio compare una delle parole chiave, i numeri di 4–8 cifre o nella forma `123 456` diventano candidati. Le parole chiave predefinite coprono tutte le lingue supportate: `kod, şifre, parola, doğrulama, otp, code, password, passcode, código, codice, şifrə, код, пароль, رمز, کد, 验证码, 动态码, コード, 인증`.
   - **Esclusi:** parti di date, orari e importi; gruppi di numeri di telefono e IBAN; importi seguiti da una valuta come `TL`, `₺` o `USD`; frasi relative alla carta come “ile biten” e “son 4 hanesi”; numeri d’ordine dopo “no:”; numeri per disiscriversi dalle campagne (“3340'e RET yaz”, “OBRET->3340”).
   - Tra i candidati rimasti vince quello più vicino a una parola chiave. A parità di distanza si preferisce quello dopo la parola chiave.

Il codice viene copiato negli appunti e viene mostrata una notifica. I messaggi più vecchi di 10 minuti, come quelli sincronizzati all’uscita dallo stop, vengono ignorati.

### Regole da un SMS di esempio

Se il codice di un mittente non viene rilevato, vai in Impostazioni → Regole → **Crea regola da SMS di esempio…**:

1. Inserisci il nome del mittente, ad esempio `GIB`.
2. Incolla l’SMS completo.
3. Seleziona con il mouse la parte da copiare.

CodeCatcher scrive la regola da solo:
- Le parole fisse prima del codice vengono usate come ancora; se non ce ne sono, si usano le parole dopo il codice.
- Il codice viene sostituito da uno schema che ne riproduce la forma: solo cifre, oppure lettere e cifre, di lunghezza simile.
- Prima del salvataggio, la regola viene testata sull’SMS di esempio. Se non cattura esattamente il codice selezionato, non può essere salvata.

Ad esempio, selezionando `4DAR7Q` in `… SMS SIFRENIZ: 4DAR7Q B001` si ottiene una regola che inizia con `SMS\s+SIFRENIZ\s*:\s*([A-Z0-9]{4,8})`. Rileva anche password composte solo da lettere, come `ZPQRTT`. La regex generata viene mostrata nella finestra e può essere modificata a mano espandendo la regola nella lista.

Nel pannello **Prova** puoi incollare un SMS e vedere subito quale codice e quale regola verrebbero scelti; anche da lì puoi creare una regola.

## Test con messaggi reali

```bash
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100          # digits masked
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100 --plain  # as is
```

Il comando analizza gli ultimi N messaggi ricevuti e per ciascuno stampa il codice scelto e la sua origine, indicando la posizione del codice nel testo con `⟦CODE⟧`. Non viene copiato nulla. Il terminale deve avere l’accesso completo al disco.

## Sviluppo

GitHub Actions esegue `swift test` a ogni push e pull request.

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

**Traduzioni:** le chiavi sono le stringhe inglesi in `Sources/`. Per aggiungere o modificare una stringa, aggiorna `en.lproj` e tutte le altre lingue; `LocalizationTests` fallisce se manca una chiave o un segnaposto `%@`. Le correzioni da parte di madrelingua sono molto gradite.

## Privacy

I messaggi vengono letti solo da `chat.db` su questo Mac, in sola lettura. Nulla viene inviato in rete o scritto su disco. Tutti gli SMS nei test sono inventati.

Il codice rilevato viene copiato negli appunti; anche le app di cronologia degli appunti salveranno questi codici.

## Supporto

CodeCatcher è gratuito. Se vuoi sostenerne lo sviluppo, puoi diventare sponsor su [GitHub Sponsors](https://github.com/sponsors/sineld). Anche aggiungere una stella al repository e segnalare problemi aiuta.

## Licenza

[MIT](../LICENSE)

## Sviluppatore

Sinan Eldem · [sinan@sinaneldem.tr](mailto:sinan@sinaneldem.tr) · [sinaneldem.tr](https://sinaneldem.tr)
