# CodeCatcher

[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-db61a2?logo=githubsponsors)](https://github.com/sponsors/sineld)

**خواندن به زبان:** [English](../README.md) · [Türkçe](README.tr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Kurdî](README.ku.md) · [Azərbaycan dili](README.az.md) · [العربية](README.ar.md) · فارسی · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

یک برنامهٔ نوار منو برای macOS که کدهای تأیید یک‌بارمصرف را در پیامک‌هایی که از iPhone شما بازارسال می‌شوند پیدا می‌کند و در کلیپ‌بورد کپی می‌کند. هیچ وابستگی‌ای ندارد: SwiftUI، Foundation و SQLite خودِ سیستم کافی‌اند.

CodeCatcher رایگان و متن‌باز است. به‌عنوان یک پروژهٔ شخصی ساخته شده و همان‌طور که هست ارائه می‌شود، بدون هیچ تضمینی برای پشتیبانی یا به‌روزرسانی. از گزارش اشکال و مشارکت استقبال می‌شود. اگر در وقت شما صرفه‌جویی می‌کند، می‌توانید از طریق [GitHub Sponsors](https://github.com/sponsors/sineld) از توسعهٔ آن حمایت کنید.

## ویژگی‌ها

- **هیچ پیامی را جا نمی‌اندازد:** همهٔ پیامک‌های تازه از آخرین پیام پردازش‌شده به بعد، به ترتیب پردازش می‌شوند. از macOS 13 به بعد، متن بیشتر پیام‌ها فقط در ستون `attributedBody` ذخیره می‌شود؛ این پیام‌ها هم خوانده می‌شوند.
- **عدد درست را انتخاب می‌کند:** ارقام کارت، تاریخ، ساعت، مبلغ، شماره‌تلفن و شماره‌های لغو اشتراک پیام‌های تبلیغاتی کنار گذاشته می‌شوند؛ نزدیک‌ترین عدد به یک کلیدواژه به‌عنوان کد برداشته می‌شود.
- **زبان‌های زیادی را می‌فهمد:** کلیدواژه‌های ۱۸ زبان از پیش در آن گنجانده شده‌اند، و پیام‌های چینی، ژاپنی و کره‌ای که در آن‌ها ارقام بی‌فاصله کنار حروف نوشته می‌شوند هم کار می‌کنند. بزرگی و کوچکی حروف و علامت‌های روی حروف اهمیتی ندارند، از جمله در ترکی: ŞİFRE, şifre و sifre یکی هستند.
- **قاعده بدون regex:** یک پیامک نمونه را بچسبانید و کد را انتخاب کنید؛ قاعده برای شما نوشته و روی همان نمونه آزمایش می‌شود.
- **GİB e-Arşiv:** رمزهای فاکتورهای e-Arşiv سازمان درآمد ترکیه که حرف هم دارند، با یک قاعدهٔ پیش‌فرض گرفته می‌شوند.
- **۱۸ زبان رابط کاربری:** در نخستین اجرا انتخاب می‌شود و در تنظیمات قابل تغییر است.
- **خصوصی:** پیام‌ها فقط روی همین Mac و به‌صورت فقط‌خواندنی خوانده می‌شوند؛ چیزی از طریق شبکه فرستاده نمی‌شود.

**پیش‌نیازها:** macOS 15 یا جدیدتر، Xcode 16 یا جدیدتر برای ساخت، و قابلیت بازارسال پیامک (Text Message Forwarding) روی iPhone شما.

## تصاویر صفحه

| ساخت قاعده از یک پیامک نمونه | امتحان |
|:---:|:---:|
| <img src="images/rule-builder.png" width="400" alt="ساخت قاعده از یک پیامک نمونه"> | <img src="images/try-it.png" width="400" alt="امتحان"> |
| **عمومی** | **کلیدواژه‌ها** |
| <img src="images/settings-general.png" width="400" alt="عمومی"> | <img src="images/keywords.png" width="400" alt="کلیدواژه‌ها"> |

<p align="center"><img src="images/language-picker.png" width="260" alt="زبان"><br><em>زبان</em></p>

## نصب

### دانلود

1. فایل `.dmg` را از [آخرین نسخهٔ منتشرشده](https://github.com/sineld/CodeCatcher/releases/latest) دانلود کنید. این یک برنامهٔ universal است که هم روی Macهای Apple silicon و هم روی Macهای Intel اجرا می‌شود.
2. فایل DMG را باز کنید و CodeCatcher را به پوشهٔ Applications بکشید.
3. این برنامه از سوی Apple تأیید (notarize) نشده است، بنابراین macOS بار اول جلوی اجرای آن را می‌گیرد. یک بار برای باز کردن آن تلاش کنید، سپس به تنظیمات سیستم ← حریم خصوصی و امنیت (در macOS انگلیسی: System Settings → Privacy & Security) بروید و روی **به هر حال باز شود** (Open Anyway) کلیک کنید. همچنین می‌توانید این دستور را در ترمینال اجرا کنید:

   ```bash
   xattr -dr com.apple.quarantine /Applications/CodeCatcher.app
   ```

### ساخت از کد منبع

```bash
scripts/build-app.sh --install   # builds, installs to ~/Applications and launches
```

**امضا (توصیه می‌شود):** مجوز دسترسی کامل به دیسک به امضای برنامه وابسته است. با امضای ad-hoc باید پس از هر بار ساخت دوباره آن را بدهید. برای جلوگیری از این کار، یک بار در Keychain Access → Certificate Assistant → Create a Certificate گواهی‌ای با نام `CodeCatcher Local` بسازید (identity type: Self-Signed Root, certificate type: Code Signing). اسکریپت اگر آن را پیدا کند از آن استفاده می‌کند. برای استفاده از گواهی دیگر: `CODESIGN_IDENTITY="…" scripts/build-app.sh`.

### پس از نصب

1. **دسترسی کامل به دیسک:** تنظیمات سیستم ← حریم خصوصی و امنیت ← دسترسی کامل به دیسک ← CodeCatcher (در macOS انگلیسی: System Settings → Privacy & Security → Full Disk Access). بدون آن `~/Library/Messages/chat.db` خوانده نمی‌شود و در نوار منو نماد ⚠︎ نمایش داده می‌شود.
2. روی iPhone خود، در تنظیمات ← پیام‌ها ← بازارسال پیامک (در iOS انگلیسی: Settings → Messages → Text Message Forwarding) این Mac را روشن کنید.

## زبان

CodeCatcher در نخستین اجرا می‌پرسد از کدام زبان استفاده شود و انتخاب شما را به خاطر می‌سپارد. بعداً می‌توانید آن را در تنظیمات ← عمومی ← زبان تغییر دهید؛ برنامه برای اعمال آن دوباره راه‌اندازی می‌شود.

زبان‌های پشتیبانی‌شده: English، Türkçe، Deutsch، Español، Français، Italiano، Português (Brasil)، Nederlands، Polski، Русский، Українська، Kurdî (Kurmancî)، Azərbaycan dili، العربية، فارسی، 简体中文، 日本語، 한국어.

زبان رابط کاربری تعیین نمی‌کند کدام پیام‌ها گرفته شوند: کلیدواژه‌های همهٔ زبان‌های پشتیبانی‌شده به‌طور پیش‌فرض فعال‌اند.

## کد چگونه انتخاب می‌شود

برای هر پیام تازه، موارد زیر به ترتیب امتحان می‌شوند:

1. **قاعده‌ها:** به ترتیب فهرست در تنظیمات ← قاعده‌ها امتحان می‌شوند؛ نخستین تطابق کد را تعیین می‌کند. لازم نیست regex بلد باشید؛ بخش «قاعده از روی پیامک نمونه» را در پایین ببینید.

   قاعدهٔ پیش‌فرض زیر یک بار، در نخستین اجرا، به فهرست افزوده می‌شود. مانند هر قاعدهٔ دیگری می‌توان آن را ویرایش و حذف کرد؛ قاعدهٔ حذف‌شده خودبه‌خود برنمی‌گردد و می‌توان آن را با **بازگردانی قاعده‌های پیش‌فرض حذف‌شده** بازگرداند.

   | قاعده | فرستنده | Regex | چرا |
   |---|---|---|---|
   | GİB e-Arşiv | `GIB` | `SIFRENIZ:\s*([A-Z0-9]{4,8})\b` | رمزهای فاکتور e-Arşiv شش‌نویسه‌ای‌اند و حرف دارند؛ بعضی فقط از حروف تشکیل شده‌اند |

2. **کلیدواژه‌ها:** اگر یکی از کلیدواژه‌ها در پیام بیاید، عددهای ۴ تا ۸ رقمی یا عددهایی به شکل `123 456` نامزد می‌شوند. کلیدواژه‌های پیش‌فرض همهٔ زبان‌های پشتیبانی‌شده را پوشش می‌دهند: `kod, şifre, parola, doğrulama, otp, code, password, passcode, código, codice, şifrə, код, пароль, رمز, کد, 验证码, 动态码, コード, 인증`.
   - **کنار گذاشته می‌شوند:** بخش‌هایی از تاریخ، ساعت و مبلغ؛ گروه‌های ارقام تلفن و IBAN؛ مبلغ‌هایی که پس از آن‌ها واحد پولی مانند `TL`، `₺` یا `USD` می‌آید؛ عبارت‌های مربوط به کارت مانند «ile biten» و «son 4 hanesi»؛ شمارهٔ سفارش پس از «no:»؛ شماره‌های لغو اشتراک پیام‌های تبلیغاتی («3340'e RET yaz»، «OBRET->3340»).
   - از نامزدهای باقی‌مانده، نزدیک‌ترین به کلیدواژه برنده می‌شود. در صورت برابری، عددی که پس از کلیدواژه آمده ترجیح داده می‌شود.

کد در کلیپ‌بورد کپی می‌شود و یک اعلان نمایش داده می‌شود. پیام‌های قدیمی‌تر از ۱۰ دقیقه، مانند پیام‌هایی که پس از بیدار شدن از خواب همگام‌سازی می‌شوند، نادیده گرفته می‌شوند.

### قاعده از روی پیامک نمونه

اگر کد یک فرستنده گرفته نمی‌شود، به تنظیمات ← قاعده‌ها ← **ساخت قاعده از پیامک نمونه…** بروید:

1. نام فرستنده را بنویسید، مثلاً `GIB`.
2. کل پیامک را بچسبانید.
3. بخشی را که باید کپی شود با ماوس انتخاب کنید.

CodeCatcher خودش قاعده را می‌نویسد:
- واژه‌های ثابتِ پیش از کد به‌عنوان لنگر به کار می‌روند؛ اگر چنین واژه‌هایی نباشد، از واژه‌های پس از کد استفاده می‌شود.
- کد با الگویی جایگزین می‌شود که با شکل آن جور است: فقط رقم، یا حرف و رقم، با طولی نزدیک به آن.
- پیش از ذخیره، قاعده روی پیامک نمونه آزمایش می‌شود. اگر دقیقاً همان کد انتخاب‌شده را نگیرد، ذخیره نمی‌شود.

برای مثال، انتخاب `4DAR7Q` در `… SMS SIFRENIZ: 4DAR7Q B001` قاعده‌ای می‌سازد که با `SMS\s+SIFRENIZ\s*:\s*([A-Z0-9]{4,8})` شروع می‌شود. این قاعده رمزهای فقط‌حرفی مانند `ZPQRTT` را هم می‌گیرد. regex ساخته‌شده در پنجره نمایش داده می‌شود و می‌توان با باز کردن قاعده در فهرست، آن را دستی ویرایش کرد.

در زبانهٔ **امتحان** می‌توانید یک پیامک بچسبانید و فوراً ببینید کدام کد و کدام قاعده انتخاب می‌شود؛ از همان‌جا هم می‌توانید قاعده بسازید.

## آزمایش با پیام‌های واقعی

```bash
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100          # digits masked
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100 --plain  # as is
```

این دستور N پیام دریافتی آخر را بررسی می‌کند و برای هر کدام کد انتخاب‌شده و منبع آن را چاپ می‌کند و جای کد را در متن با `⟦CODE⟧` نشان می‌دهد. چیزی کپی نمی‌شود. ترمینال شما به دسترسی کامل به دیسک نیاز دارد.

## توسعه

GitHub Actions در هر push و pull request، `swift test` را اجرا می‌کند.

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

**ترجمه‌ها:** کلیدها همان رشته‌های انگلیسی در `Sources/` هستند. برای افزودن یا تغییر یک رشته، `en.lproj` و همهٔ زبان‌های دیگر را به‌روز کنید؛ اگر کلیدی یا جانگهدار `%@` جا افتاده باشد، `LocalizationTests` شکست می‌خورد. از اصلاحاتِ گویشوران بومی بسیار استقبال می‌شود.

## حریم خصوصی

پیام‌ها فقط از `chat.db` روی همین Mac و به‌صورت فقط‌خواندنی خوانده می‌شوند. چیزی از طریق شبکه فرستاده یا روی دیسک نوشته نمی‌شود. همهٔ پیامک‌های آزمون‌ها ساختگی‌اند.

کد گرفته‌شده در کلیپ‌بورد کپی می‌شود؛ برنامه‌هایی که تاریخچهٔ کلیپ‌بورد را نگه می‌دارند هم این کدها را ذخیره خواهند کرد.

## پشتیبانی

CodeCatcher رایگان است. اگر می‌خواهید از توسعهٔ آن حمایت کنید، می‌توانید در [GitHub Sponsors](https://github.com/sponsors/sineld) حامی شوید. ستاره دادن به مخزن و گزارش مشکلات هم کمک می‌کند.

## مجوز

[MIT](../LICENSE)

## توسعه‌دهنده

Sinan Eldem · [sinan@sinaneldem.tr](mailto:sinan@sinaneldem.tr) · [sinaneldem.tr](https://sinaneldem.tr)
