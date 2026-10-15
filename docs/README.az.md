# CodeCatcher

[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-db61a2?logo=githubsponsors)](https://github.com/sponsors/sineld)

**Bu dildə oxuyun:** [English](../README.md) · [Türkçe](README.tr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Kurdî](README.ku.md) · Azərbaycan dili · [العربية](README.ar.md) · [فارسی](README.fa.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

iPhone-dan yönləndirilən SMS mesajlarındakı birdəfəlik təsdiq kodlarını tutan və onları mübadilə buferinə kopyalayan macOS menyu sətri tətbiqi. Heç bir asılılığı yoxdur: SwiftUI, Foundation və sistemin SQLite-ı kifayətdir.

CodeCatcher pulsuz və açıq mənbəlidir. Şəxsi layihə kimi hazırlanıb və olduğu kimi təqdim olunur; dəstək və ya yeniləmə zəmanəti verilmir. Xəta bildirişləri və töhfələr məmnuniyyətlə qarşılanır. Vaxtınıza qənaət edirsə, [GitHub Sponsors](https://github.com/sponsors/sineld) vasitəsilə onun inkişafını dəstəkləyə bilərsiniz.

## Xüsusiyyətlər

- **Heç bir mesajı buraxmır:** Sonuncu emal olunandan sonra gələn hər yeni SMS ardıcıllıqla emal olunur. macOS 13-dən etibarən mesajların çoxunun mətni yalnız `attributedBody` sütununda saxlanılır; belə mesajlar da oxunur.
- **Düzgün ədədi seçir:** Kart rəqəmləri, tarixlər, saatlar, məbləğlər, telefon nömrələri və kampaniyadan imtina nömrələri süzülür; açar sözə ən yaxın ədəd kod kimi götürülür.
- **Bir çox dili başa düşür:** 18 dildə açar sözlər daxildir; rəqəmlərin hərflərə bitişik yazıldığı Çin, Yapon və Koreya dillərindəki mesajlar da işləyir. Böyük-kiçik hərf və diakritik işarələr fərq etmir, türk dili də daxil olmaqla: ŞİFRE, şifre və sifre eynidir.
- **Regex-siz qaydalar:** Nümunə SMS yapışdırın və kodu seçin; qayda sizin üçün yazılır və nümunə üzərində yoxlanılır.
- **GİB e-Arşiv:** Türkiyə Gəlir İdarəsinin hərflər də ehtiva edən e-Arşiv faktura şifrələri standart qayda ilə tutulur.
- **18 interfeys dili:** İlk açılışda seçilir və Ayarlarda dəyişdirilə bilər.
- **Məxfi:** Mesajlar yalnız bu Mac-də, yalnız oxuma rejimində oxunur; şəbəkə üzərindən heç nə göndərilmir.

**Tələblər:** macOS 15 və ya daha yeni versiya, qurmaq üçün Xcode 16 və ya daha yeni versiya, iPhone-da isə Mətn Mesajlarının Yönləndirilməsi (Text Message Forwarding).

## Ekran görüntüləri

| Nümunə SMS-dən qayda yaradın | Sınaq |
|:---:|:---:|
| <img src="images/rule-builder.png" width="400" alt="Nümunə SMS-dən qayda yaradın"> | <img src="images/try-it.png" width="400" alt="Sınaq"> |
| **Ümumi** | **Açar sözlər** |
| <img src="images/settings-general.png" width="400" alt="Ümumi"> | <img src="images/keywords.png" width="400" alt="Açar sözlər"> |

<p align="center"><img src="images/language-picker.png" width="260" alt="Dil"><br><em>Dil</em></p>

## Quraşdırma

### Endirmə

1. `.dmg` faylını [son buraxılışdan](https://github.com/sineld/CodeCatcher/releases/latest) endirin. Bu, həm Apple silicon, həm də Intel prosessorlu Mac-lər üçün universal tətbiqdir.
2. DMG-ni açın və CodeCatcher-i Tətbiqlər (Applications) qovluğuna sürükləyin.
3. Tətbiq Apple tərəfindən notarizasiya olunmayıb, buna görə macOS onu ilk dəfə bloklayır. Onu bir dəfə açmağa çalışın, sonra Sistem Ayarları (System Settings) → Məxfilik və Təhlükəsizlik (Privacy & Security) bölməsinə keçin və **Yenə də aç** (Open Anyway) düyməsini klikləyin. Alternativ olaraq Terminal-da bunu işə salın:

   ```bash
   xattr -dr com.apple.quarantine /Applications/CodeCatcher.app
   ```

### Mənbə kodundan qurma

```bash
scripts/build-app.sh --install   # builds, installs to ~/Applications and launches
```

**İmzalama (tövsiyə olunur):** Tam Disk Girişi (Full Disk Access) icazəsi tətbiqin imzasına bağlıdır. Ad-hoc imza ilə hər yenidən qurmadan sonra icazəni təkrar verməli olursunuz. Bunun qarşısını almaq üçün bir dəfə Keychain Access → Certificate Assistant → Create a Certificate yolu ilə `CodeCatcher Local` adlı sertifikat yaradın (identifikasiya növü: Self-Signed Root, sertifikat növü: Code Signing). Skript onu tapdıqda istifadə edir. Başqa sertifikatdan istifadə etmək üçün: `CODESIGN_IDENTITY="…" scripts/build-app.sh`.

### Quraşdırmadan sonra

1. **Tam Disk Girişi:** Sistem Ayarları (System Settings) → Məxfilik və Təhlükəsizlik (Privacy & Security) → Tam Disk Girişi (Full Disk Access) → CodeCatcher. Bu icazə olmadan `~/Library/Messages/chat.db` oxuna bilmir və menyu sətrində ⚠︎ işarəsi göstərilir.
2. iPhone-da Ayarlar (Settings) → Mesajlar (Messages) → Mətn Mesajlarının Yönləndirilməsi (Text Message Forwarding) bölməsində bu Mac-i aktiv edin.

## Dil

İlk açılışda CodeCatcher hansı dildən istifadə edəcəyini soruşur və seçimi yadda saxlayır. Onu sonra Ayarlar → Ümumi → Dil bölməsində dəyişə bilərsiniz; dəyişikliyin qüvvəyə minməsi üçün tətbiq yenidən başladılır.

Dəstəklənən dillər: English, Türkçe, Deutsch, Español, Français, Italiano, Português (Brasil), Nederlands, Polski, Русский, Українська, Kurdî (Kurmancî), Azərbaycan dili, العربية, فارسی, 简体中文, 日本語, 한국어.

İnterfeys dili hansı mesajların tutulacağını məhdudlaşdırmır: bütün dəstəklənən dillərin açar sözləri standart olaraq aktivdir.

## Kod necə seçilir

Hər yeni mesaj üçün aşağıdakılar ardıcıllıqla yoxlanılır:

1. **Qaydalar:** Ayarlar → Qaydalar bölməsindəki siyahının ardıcıllığı ilə yoxlanılır; kodu ilk uyğunluq müəyyən edir. Regex bilməyiniz lazım deyil; aşağıdakı “Nümunə SMS-dən qaydalar” bölməsinə baxın.

   Aşağıdakı standart qayda ilk açılışda siyahıya bir dəfə əlavə olunur. Hər hansı digər qayda kimi onu da redaktə etmək və silmək olar; silinmiş qayda öz-özünə geri qayıtmır və **Silinmiş standart qaydaları bərpa et** düyməsi ilə bərpa edilə bilər.

   | Qayda | Göndərən | Regex | Səbəb |
   |---|---|---|---|
   | GİB e-Arşiv | `GIB` | `SIFRENIZ:\s*([A-Z0-9]{4,8})\b` | e-Arşiv şifrələri 6 simvoldan ibarətdir və hərflər ehtiva edir; bəziləri yalnız hərflərdən ibarətdir |

2. **Açar sözlər:** Mesajda açar sözlərdən biri görünərsə, 4–8 rəqəmli və ya `123 456` formasındakı ədədlər namizəd olur. Standart açar sözlər bütün dəstəklənən dilləri əhatə edir: `kod, şifre, parola, doğrulama, otp, code, password, passcode, código, codice, şifrə, код, пароль, رمز, کد, 验证码, 动态码, コード, 인증`.
   - **Süzülənlər:** tarix, saat və məbləğ hissələri; telefon və IBAN qrupları; ardınca `TL`, `₺` və ya `USD` kimi valyuta gələn məbləğlər; “ile biten” və “son 4 hanesi” kimi kart ifadələri; “no:”-dan sonrakı sifariş nömrələri; kampaniyadan imtina nömrələri (“3340'e RET yaz”, “OBRET->3340”).
   - Qalan namizədlərdən açar sözə ən yaxın olanı qalib gəlir. Bərabərlik olduqda açar sözdən sonra gələnə üstünlük verilir.

Kod mübadilə buferinə kopyalanır və bildiriş göstərilir. Yuxu rejimindən çıxdıqdan sonra sinxronlaşdırılanlar kimi 10 dəqiqədən köhnə mesajlar nəzərə alınmır.

### Nümunə SMS-dən qaydalar

Bir göndərənin kodu tutulmursa, Ayarlar → Qaydalar → **Nümunə SMS-dən qayda yarat…** bölməsinə keçin:

1. Göndərənin adını yazın, məsələn `GIB`.
2. Bütün SMS-i yapışdırın.
3. Kopyalanacaq hissəni siçanla seçin.

CodeCatcher qaydanı özü yazır:
- Koddan əvvəlki sabit sözlər lövbər kimi istifadə olunur; belə sözlər yoxdursa, koddan sonrakı sözlər götürülür.
- Kod onun formasına uyğun gələn şablonla əvəz olunur: oxşar uzunluqda yalnız rəqəmlər və ya hərflər və rəqəmlər.
- Yadda saxlamazdan əvvəl qayda nümunə SMS üzərində yoxlanılır. Seçilmiş kodu dəqiq tutmursa, yadda saxlanıla bilməz.

Məsələn, `… SMS SIFRENIZ: 4DAR7Q B001` mətnində `4DAR7Q` seçildikdə `SMS\s+SIFRENIZ\s*:\s*([A-Z0-9]{4,8})` ilə başlayan qayda yaranır. Bu qayda `ZPQRTT` kimi yalnız hərflərdən ibarət şifrələri də tutur. Yaradılmış regex pəncərədə göstərilir və siyahıda qaydanı açaraq əl ilə redaktə edilə bilər.

**Sınaq** bölməsində SMS yapışdırıb hansı kodun və hansı qaydanın seçiləcəyini dərhal görə bilərsiniz; oradan da qayda yaratmaq mümkündür.

## Real mesajlarla sınaq

```bash
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100          # digits masked
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100 --plain  # as is
```

Bu əmr son N gələn mesajı skan edir və hər biri üçün seçilmiş kodu və onun mənbəyini çap edir, kodun mətndəki yerini `⟦CODE⟧` ilə işarələyir. Heç nə kopyalanmır. Terminalınıza Tam Disk Girişi lazımdır.

## İnkişaf

GitHub Actions hər push və pull request zamanı `swift test` işə salır.

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

**Tərcümələr:** Açarlar `Sources/` içindəki ingiliscə sətirlərdir. Sətir əlavə etmək və ya dəyişmək üçün `en.lproj` faylını və bütün digər dilləri yeniləyin; açar və ya `%@` yertutanı əskik olduqda `LocalizationTests` uğursuz olur. Ana dili daşıyıcılarının düzəlişləri böyük məmnuniyyətlə qarşılanır.

## Məxfilik

Mesajlar yalnız bu Mac-dəki `chat.db`-dən, yalnız oxuma rejimində oxunur. Şəbəkə üzərindən heç nə göndərilmir və diskə heç nə yazılmır. Testlərdəki bütün SMS-lər uydurmadır.

Tutulan kod mübadilə buferinə kopyalanır; mübadilə buferi tarixçəsini saxlayan tətbiqlər də bu kodları saxlayacaq.

## Dəstək

CodeCatcher pulsuzdur. Onun inkişafını dəstəkləmək istəyirsinizsə, [GitHub Sponsors](https://github.com/sponsors/sineld) üzərindən sponsor ola bilərsiniz. Repozitoriyaya ulduz vermək və problemləri bildirmək də kömək edir.

## Lisenziya

[MIT](../LICENSE)

## Tərtibatçı

Sinan Eldem · [sinan@sinaneldem.tr](mailto:sinan@sinaneldem.tr) · [sinaneldem.tr](https://sinaneldem.tr)
