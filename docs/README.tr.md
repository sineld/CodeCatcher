# CodeCatcher

[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-db61a2?logo=githubsponsors)](https://github.com/sponsors/sineld)

**Bu belgeyi oku:** [English](../README.md) · Türkçe · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Kurdî](README.ku.md) · [Azərbaycan dili](README.az.md) · [العربية](README.ar.md) · [فارسی](README.fa.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

iPhone'dan Mac'e yönlendirilen SMS'lerdeki tek kullanımlık doğrulama kodlarını yakalayıp panoya kopyalayan bir macOS menü çubuğu uygulaması. Dış bağımlılığı yoktur: SwiftUI, Foundation ve sistemdeki SQLite yeterlidir.

CodeCatcher ücretsiz ve açık kaynaktır. Kişisel bir proje olarak geliştirildi ve olduğu gibi sunulur; destek ya da güncelleme garantisi yoktur. Hata bildirimleri ve katkılar memnuniyetle karşılanır. İşine yarıyorsa geliştirilmesini [GitHub Sponsors](https://github.com/sponsors/sineld) üzerinden destekleyebilirsin.

## Özellikler

- **Mesaj atlamaz:** Son işlenen mesajdan itibaren yeni gelen tüm SMS'ler sırayla işlenir. macOS 13'ten beri çoğu mesajın metni yalnızca `attributedBody` sütununda tutulur; bu mesajlar da okunur.
- **Doğru sayıyı seçer:** Kart son haneleri, tarih, saat, tutar, telefon ve kampanya iptal numaraları elenir; anahtar kelimeye en yakın sayı kod sayılır.
- **Birçok dili anlar:** 18 dilin anahtar kelimeleri hazır gelir; rakamların harflere bitişik yazıldığı Çince, Japonca ve Korece mesajlar da çalışır. Büyük/küçük harf ve aksanlar fark etmez; Türkçe de dahil: ŞİFRE, şifre ve sifre aynıdır.
- **Regex bilmeden kural:** Örnek SMS'i yapıştırıp kodu seçmen yeterli; kural kendiliğinden yazılır ve örnek üzerinde denenir.
- **GİB e-Arşiv:** Harf içeren e-Arşiv fatura şifreleri varsayılan bir kuralla yakalanır.
- **18 arayüz dili:** İlk açılışta seçilir, Ayarlar'dan değiştirilebilir.
- **Gizlilik:** Mesajlar yalnızca bu Mac'te, salt okunur olarak okunur; ağa hiçbir şey gönderilmez.

**Gereksinimler:** macOS 15 veya üstü, derlemek için Xcode 16 veya üstü ve iPhone'da Metin Mesajı Yönlendirme.

## Kurulum

### İndirme

1. `.dmg` dosyasını [son sürümden](https://github.com/sineld/CodeCatcher/releases/latest) indir. Hem Apple Silicon hem de Intel işlemcili Mac'lerde çalışan evrensel bir uygulamadır.
2. DMG'yi aç ve CodeCatcher'ı Uygulamalar klasörüne sürükle.
3. Uygulama Apple tarafından onaylanmadığı (notarize edilmediği) için macOS ilk açılışta onu engeller. Uygulamayı bir kez açmayı dene, ardından Sistem Ayarları → Gizlilik ve Güvenlik bölümüne gidip **Yine de Aç** düğmesine tıkla. Alternatif olarak Terminal'de şunu çalıştır:

   ```bash
   xattr -dr com.apple.quarantine /Applications/CodeCatcher.app
   ```

### Kaynaktan derleme

```bash
scripts/build-app.sh --install   # builds, installs to ~/Applications and launches
```

**İmza (önerilir):** Tam Disk Erişimi izni, uygulamanın imzasına bağlıdır. Ad-hoc imzada her yeniden derlemeden sonra izni tekrar vermen gerekir. Bunu önlemek için Anahtar Zinciri Erişimi → Sertifika Asistanı → Sertifika Oluştur yolundan bir kez `CodeCatcher Local` adlı bir sertifika oluştur (kimlik türü: Kendinden İmzalı Kök, sertifika türü: Kod İmzalama). Betik bu sertifikayı bulursa onu kullanır. Başka bir sertifika kullanmak için: `CODESIGN_IDENTITY="…" scripts/build-app.sh`.

### Kurulumdan sonra

1. **Tam Disk Erişimi:** Sistem Ayarları → Gizlilik ve Güvenlik → Tam Disk Erişimi → CodeCatcher. Bu izin olmadan `~/Library/Messages/chat.db` okunamaz ve menü çubuğunda ⚠︎ ikonu görünür.
2. iPhone'da Ayarlar → Mesajlar → Metin Mesajı Yönlendirme bölümünden bu Mac'i aç.

## Dil

CodeCatcher ilk açılışta hangi dili kullanacağını sorar ve seçimi hatırlar. Daha sonra Ayarlar → Genel → Dil bölümünden değiştirebilirsin; değişiklik uygulama yeniden başlayınca geçerli olur.

Desteklenen diller: English, Türkçe, Deutsch, Español, Français, Italiano, Português (Brasil), Nederlands, Polski, Русский, Українська, Kurdî (Kurmancî), Azərbaycan dili, العربية, فارسی, 简体中文, 日本語, 한국어.

Arayüz dili hangi mesajların yakalanacağını sınırlamaz: tüm desteklenen dillerin anahtar kelimeleri varsayılan olarak açıktır.

## Kod nasıl seçilir

Her yeni gelen mesaj için sırasıyla şunlar denenir:

1. **Kurallar:** Ayarlar → Kurallar listesindeki sırayla denenir; ilk tutan kural kodu belirler. Regex bilmen gerekmez; aşağıdaki "Örnek SMS'ten kural" bölümüne bak.

   Aşağıdaki varsayılan kural ilk açılışta listeye bir kez eklenir. Diğer kurallar gibi düzenlenip silinebilir; silinen kural kendiliğinden geri gelmez, **Silinen Varsayılan Kuralları Geri Yükle** düğmesiyle geri getirilir.

   | Kural | Gönderen | Regex | Neden |
   |---|---|---|---|
   | GİB e-Arşiv | `GIB` | `SIFRENIZ:\s*([A-Z0-9]{4,8})\b` | e-Arşiv fatura şifreleri 6 karakterdir ve harf içerir; bazıları yalnızca harften oluşur |

2. **Anahtar kelimeler:** Mesajda kelimelerden biri geçiyorsa 4–8 haneli ya da `123 456` biçimindeki sayılar aday olur. Varsayılan kelimeler tüm desteklenen dilleri kapsar: `kod, şifre, parola, doğrulama, otp, code, password, passcode, código, codice, şifrə, код, пароль, رمز, کد, 验证码, 动态码, コード, 인증`.
   - **Elenen adaylar:** tarih, saat ve tutar parçaları; telefon ve IBAN grupları; `TL`, `₺` ya da `USD` gibi bir para birimiyle biten tutarlar; "ile biten" ve "son 4 hanesi" gibi kart ifadeleri; "no:" ile başlayan sipariş numaraları; kampanya iptal numaraları ("3340'e RET yaz", "OBRET->3340").
   - Kalan adaylardan anahtar kelimeye en yakın olan seçilir. Eşitlikte kelimeden sonra gelen tercih edilir.

Bulunan kod panoya kopyalanır ve bildirim gösterilir. Son 10 dakikadan eski mesajlar (örneğin uyku sonrası eşitlenenler) işlenmez.

### Örnek SMS'ten kural

Bir göndericinin kodu yakalanmıyorsa Ayarlar → Kurallar → **Örnek SMS'ten Kural Oluştur…** yolunu izle:

1. Gönderen adını yaz (ör. `GIB`).
2. SMS'in tamamını yapıştır.
3. Kopyalanması gereken kısmı fareyle seç.

CodeCatcher kuralı kendisi yazar:
- Kodun önündeki sabit kelimeler çapa olarak kullanılır; önde kelime yoksa arkadaki kelimeler kullanılır.
- Kodun yerine karakter yapısına uyan bir desen konur: yalnızca rakam ya da harf ve rakam, benzer uzunlukta.
- Kaydetmeden önce kural örnek SMS üzerinde denenir. Tam olarak seçilen kodu yakalamıyorsa kaydedilemez.

Örneğin `… SMS SIFRENIZ: 4DAR7Q B001` içinde `4DAR7Q` seçilirse `SMS\s+SIFRENIZ\s*:\s*([A-Z0-9]{4,8})` ile başlayan bir kural üretilir. Bu kural yalnızca harften oluşan `ZPQRTT` gibi şifreleri de yakalar. Üretilen regex pencerede görünür ve listede kural açılarak elle düzenlenebilir.

**Dene** sekmesine bir SMS yapıştırarak hangi kodun ve hangi kuralın seçileceğini anında görebilirsin; buradan da kural oluşturulabilir.

## Gerçek mesajlarla deneme

```bash
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100          # digits masked
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100 --plain  # as is
```

Bu komut son N gelen mesajı tarar; her biri için seçilen kodu ve kaynağını yazar, kodun metindeki yerini `⟦CODE⟧` ile işaretler. Hiçbir şeyi kopyalamaz. Terminalin Tam Disk Erişimi olmalıdır.

## Geliştirme

Her push ve pull request'te GitHub Actions `swift test` çalıştırır.

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

**Çeviriler:** Anahtarlar `Sources/` içindeki İngilizce metinlerdir. Bir metin eklemek ya da değiştirmek için `en.lproj` ve diğer tüm dilleri güncelle; bir anahtar ya da `%@` yer tutucusu eksikse `LocalizationTests` başarısız olur. Ana dili konuşanların düzeltmeleri çok değerlidir.

## Gizlilik

Mesajlar yalnızca bu Mac'teki `chat.db` dosyasından salt okunur olarak okunur. Ağa hiçbir şey gönderilmez ve diske yazılmaz. Testlerdeki SMS'lerin hepsi uydurmadır.

Yakalanan kod panoya kopyalanır; pano geçmişi tutan uygulamalar bu kodları da kaydeder.

## Destek

CodeCatcher ücretsizdir. Geliştirilmesini desteklemek istersen [GitHub Sponsors](https://github.com/sponsors/sineld) üzerinden sponsor olabilirsin. Repoya yıldız vermek ve hata bildirmek de yardımcı olur.

## Lisans

[MIT](../LICENSE)

## Geliştirici

Sinan Eldem · [sinan@sinaneldem.tr](mailto:sinan@sinaneldem.tr) · [sinaneldem.tr](https://sinaneldem.tr)
