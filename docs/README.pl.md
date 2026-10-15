# CodeCatcher

[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-db61a2?logo=githubsponsors)](https://github.com/sponsors/sineld)

**Przeczytaj w języku:** [English](../README.md) · [Türkçe](README.tr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Nederlands](README.nl.md) · Polski · [Русский](README.ru.md) · [Українська](README.uk.md) · [Kurdî](README.ku.md) · [Azərbaycan dili](README.az.md) · [العربية](README.ar.md) · [فارسی](README.fa.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

Aplikacja na pasek menu macOS, która przechwytuje jednorazowe kody weryfikacyjne z wiadomości SMS przekazywanych z iPhone’a i kopiuje je do schowka. Nie ma żadnych zależności: wystarczą SwiftUI, Foundation i systemowy SQLite.

CodeCatcher jest darmowy i ma otwarty kod źródłowy. Powstał jako projekt osobisty i jest udostępniany w obecnej postaci, bez gwarancji wsparcia ani aktualizacji. Zgłoszenia błędów i wkład w rozwój są mile widziane. Jeśli oszczędza ci czas, możesz wesprzeć jego rozwój przez [GitHub Sponsors](https://github.com/sponsors/sineld).

## Funkcje

- **Nie pomija żadnej wiadomości:** Każdy nowy SMS od ostatnio przetworzonego jest obsługiwany po kolei. Od macOS 13 tekst większości wiadomości jest przechowywany tylko w kolumnie `attributedBody`; takie wiadomości również są odczytywane.
- **Wybiera właściwą liczbę:** Cyfry karty, daty, godziny, kwoty, numery telefonów i numery do rezygnacji z kampanii są odfiltrowywane; za kod uznawana jest liczba najbliższa słowu kluczowemu.
- **Rozumie wiele języków:** Wbudowane są słowa kluczowe w 18 językach, a wiadomości po chińsku, japońsku i koreańsku, w których cyfry są pisane tuż obok liter, również działają. Wielkość liter i znaki diakrytyczne nie mają znaczenia, także w tureckim: ŞİFRE, şifre i sifre to to samo.
- **Reguły bez regex:** Wklej przykładowy SMS i zaznacz kod; reguła zostanie napisana za ciebie i przetestowana na przykładzie.
- **GİB e-Arşiv:** Hasła do faktur e-Arşiv tureckiej administracji skarbowej, zawierające litery, są przechwytywane przez regułę domyślną.
- **18 języków interfejsu:** Język wybiera się przy pierwszym uruchomieniu i można go zmienić w Ustawieniach.
- **Prywatność:** Wiadomości są odczytywane tylko na tym Macu, w trybie tylko do odczytu; nic nie jest wysyłane przez sieć.

**Wymagania:** macOS 15 lub nowszy, Xcode 16 lub nowszy do kompilacji oraz przekazywanie wiadomości tekstowych na iPhonie.

## Instalacja

### Pobieranie

1. Pobierz plik `.dmg` z [najnowszego wydania](https://github.com/sineld/CodeCatcher/releases/latest). To uniwersalna aplikacja dla Maców z Apple silicon i z procesorami Intel.
2. Otwórz plik DMG i przeciągnij CodeCatcher do folderu Aplikacje.
3. Aplikacja nie jest notaryzowana przez Apple, więc macOS blokuje ją przy pierwszym uruchomieniu. Spróbuj ją raz otworzyć, a następnie przejdź do Ustawienia systemowe → Prywatność i ochrona i kliknij **Otwórz mimo to**. Możesz też uruchomić w Terminalu to polecenie:

   ```bash
   xattr -dr com.apple.quarantine /Applications/CodeCatcher.app
   ```

### Budowanie ze źródeł

```bash
scripts/build-app.sh --install   # builds, installs to ~/Applications and launches
```

**Podpisywanie (zalecane):** Uprawnienie Pełny dostęp do dysku jest powiązane z podpisem aplikacji. Przy podpisie ad hoc trzeba je nadawać ponownie po każdej przebudowie. Aby tego uniknąć, utwórz jednorazowo certyfikat o nazwie `CodeCatcher Local` w aplikacji Pęk kluczy → Asystent certyfikatów → Utwórz certyfikat (typ tożsamości: Samopodpisany główny, typ certyfikatu: Podpisywanie kodu). Skrypt używa go, jeśli go znajdzie. Aby użyć innego certyfikatu: `CODESIGN_IDENTITY="…" scripts/build-app.sh`.

### Po instalacji

1. **Pełny dostęp do dysku:** Ustawienia systemowe → Prywatność i ochrona → Pełny dostęp do dysku → CodeCatcher. Bez tego nie można odczytać `~/Library/Messages/chat.db`, a na pasku menu widoczna jest ikona ⚠︎.
2. Na iPhonie włącz tego Maca w Ustawienia → Wiadomości → Przekazywanie wiadomości tekstowych.

## Język

Przy pierwszym uruchomieniu CodeCatcher pyta, jakiego języka używać, i zapamiętuje wybór. Możesz go później zmienić w Ustawienia → Ogólne → Język; aplikacja uruchamia się ponownie, aby go zastosować.

Obsługiwane języki: English, Türkçe, Deutsch, Español, Français, Italiano, Português (Brasil), Nederlands, Polski, Русский, Українська, Kurdî (Kurmancî), Azərbaycan dili, العربية, فارسی, 简体中文, 日本語, 한국어.

Język interfejsu nie ogranicza tego, które wiadomości są przechwytywane: słowa kluczowe wszystkich obsługiwanych języków są domyślnie aktywne.

## Jak wybierany jest kod

Dla każdej nowej wiadomości po kolei sprawdzane są:

1. **Reguły:** Sprawdzane w kolejności listy w Ustawienia → Reguły; o kodzie decyduje pierwsze dopasowanie. Nie musisz znać regex; zobacz „Reguły z przykładowego SMS-a” poniżej.

   Poniższa reguła domyślna jest dodawana do listy jednorazowo, przy pierwszym uruchomieniu. Jak każdą inną regułę można ją edytować i usunąć; usunięta reguła nie wraca sama i można ją przywrócić przyciskiem **Przywróć usunięte reguły domyślne**.

   | Reguła | Nadawca | Regex | Dlaczego |
   |---|---|---|---|
   | GİB e-Arşiv | `GIB` | `SIFRENIZ:\s*([A-Z0-9]{4,8})\b` | Hasła e-Arşiv mają 6 znaków i zawierają litery; niektóre składają się wyłącznie z liter |

2. **Słowa kluczowe:** Jeśli w wiadomości pojawi się jedno ze słów kluczowych, kandydatami stają się liczby 4–8-cyfrowe lub w postaci `123 456`. Domyślne słowa kluczowe obejmują wszystkie obsługiwane języki: `kod, şifre, parola, doğrulama, otp, code, password, passcode, código, codice, şifrə, код, пароль, رمز, کد, 验证码, 动态码, コード, 인증`.
   - **Odfiltrowywane:** części dat, godzin i kwot; grupy cyfr numerów telefonów i IBAN; kwoty, po których następuje waluta, np. `TL`, `₺` lub `USD`; wyrażenia dotyczące kart, takie jak „ile biten” i „son 4 hanesi”; numery zamówień po „no:”; numery do rezygnacji z kampanii („3340'e RET yaz”, „OBRET->3340”).
   - Spośród pozostałych kandydatów wygrywa ten najbliższy słowu kluczowemu. Przy remisie preferowany jest ten, który występuje po słowie kluczowym.

Kod jest kopiowany do schowka i wyświetlane jest powiadomienie. Wiadomości starsze niż 10 minut, np. zsynchronizowane po wybudzeniu z uśpienia, są ignorowane.

### Reguły z przykładowego SMS-a

Jeśli kod od danego nadawcy nie jest przechwytywany, przejdź do Ustawienia → Reguły → **Utwórz regułę z przykładowego SMS-a…**:

1. Wpisz nazwę nadawcy, na przykład `GIB`.
2. Wklej cały SMS.
3. Zaznacz myszą fragment do skopiowania.

CodeCatcher sam pisze regułę:
- Stałe słowa przed kodem służą jako punkt zaczepienia; jeśli ich nie ma, używane są słowa po kodzie.
- Kod jest zastępowany wzorcem pasującym do jego postaci: same cyfry albo litery i cyfry, o podobnej długości.
- Przed zapisaniem reguła jest testowana na przykładowym SMS-ie. Jeśli nie przechwytuje dokładnie zaznaczonego kodu, nie można jej zapisać.

Na przykład zaznaczenie `4DAR7Q` w `… SMS SIFRENIZ: 4DAR7Q B001` daje regułę zaczynającą się od `SMS\s+SIFRENIZ\s*:\s*([A-Z0-9]{4,8})`. Przechwytuje ona też hasła złożone z samych liter, takie jak `ZPQRTT`. Wygenerowany regex jest pokazywany w oknie i można go ręcznie edytować po rozwinięciu reguły na liście.

Na karcie **Wypróbuj** możesz wkleić SMS i od razu zobaczyć, który kod i która reguła zostałyby wybrane; stamtąd także można utworzyć regułę.

## Testowanie na prawdziwych wiadomościach

```bash
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100          # digits masked
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100 --plain  # as is
```

To polecenie skanuje ostatnie N wiadomości przychodzących i dla każdej wypisuje wybrany kod oraz jego źródło, oznaczając położenie kodu w tekście za pomocą `⟦CODE⟧`. Nic nie jest kopiowane. Terminal potrzebuje pełnego dostępu do dysku.

## Rozwój

GitHub Actions uruchamia `swift test` przy każdym pushu i pull requeście.

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

**Tłumaczenia:** Kluczami są angielskie ciągi znaków z `Sources/`. Aby dodać lub zmienić ciąg, zaktualizuj `en.lproj` i wszystkie pozostałe języki; `LocalizationTests` kończy się niepowodzeniem, jeśli brakuje klucza lub symbolu zastępczego `%@`. Poprawki od rodzimych użytkowników języka są bardzo mile widziane.

## Prywatność

Wiadomości są odczytywane wyłącznie z `chat.db` na tym Macu, w trybie tylko do odczytu. Nic nie jest wysyłane przez sieć ani zapisywane na dysku. Wszystkie SMS-y w testach są zmyślone.

Przechwycony kod jest kopiowany do schowka; aplikacje przechowujące historię schowka również zapiszą te kody.

## Wsparcie

CodeCatcher jest darmowy. Jeśli chcesz wesprzeć jego rozwój, możesz zostać sponsorem w [GitHub Sponsors](https://github.com/sponsors/sineld). Pomaga też dodanie gwiazdki repozytorium i zgłaszanie problemów.

## Licencja

[MIT](../LICENSE)

## Twórca

Sinan Eldem · [sinan@sinaneldem.tr](mailto:sinan@sinaneldem.tr) · [sinaneldem.tr](https://sinaneldem.tr)
