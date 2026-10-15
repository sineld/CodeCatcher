# CodeCatcher

[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-db61a2?logo=githubsponsors)](https://github.com/sponsors/sineld)

**اقرأ هذا بلغة أخرى:** [English](../README.md) · [Türkçe](README.tr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Kurdî](README.ku.md) · [Azərbaycan dili](README.az.md) · العربية · [فارسی](README.fa.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

تطبيق لشريط القوائم في macOS يلتقط رموز التحقق لمرة واحدة من رسائل SMS المُعاد توجيهها من iPhone وينسخها إلى الحافظة. لا يعتمد على أي حزم خارجية: يكفيه SwiftUI وFoundation وSQLite المضمَّن في النظام.

CodeCatcher مجاني ومفتوح المصدر. طُوِّر كمشروع شخصي ويُقدَّم كما هو، دون أي ضمان للدعم أو التحديثات. نرحّب بتقارير الأخطاء والمساهمات. إذا كان يوفّر عليك الوقت، يمكنك دعم تطويره عبر [GitHub Sponsors](https://github.com/sponsors/sineld).

## الميزات

- **لا يفوّت أي رسالة:** تُعالَج كل رسالة SMS جديدة وصلت بعد آخر رسالة تمت معالجتها، بالترتيب. منذ macOS 13، يُخزَّن نص معظم الرسائل في العمود `attributedBody` فقط؛ وتُقرأ هذه الرسائل أيضًا.
- **يختار الرقم الصحيح:** تُستبعَد أرقام البطاقات والتواريخ والأوقات والمبالغ وأرقام الهواتف وأرقام إلغاء الاشتراك في الحملات الترويجية؛ ويؤخذ الرقم الأقرب إلى كلمة مفتاحية كرمز.
- **يفهم لغات كثيرة:** يتضمن كلمات مفتاحية بـ 18 لغة، ويعمل أيضًا مع الرسائل الصينية واليابانية والكورية التي تُكتب فيها الأرقام ملاصقةً للحروف. لا تهمّ الأحرف الكبيرة والصغيرة ولا علامات التشكيل، بما في ذلك التركية: ŞİFRE, şifre و sifre متماثلة.
- **قواعد بلا regex:** الصق نموذج رسالة SMS وحدّد الرمز؛ تُكتب القاعدة نيابةً عنك وتُختبَر على النموذج.
- **GİB e-Arşiv:** تُلتقط كلمات مرور فواتير e-Arşiv الصادرة عن إدارة الإيرادات التركية، والتي تحتوي على حروف، بواسطة قاعدة افتراضية.
- **18 لغة للواجهة:** تُختار عند التشغيل الأول ويمكن تغييرها في الإعدادات.
- **يحفظ الخصوصية:** تُقرأ الرسائل على جهاز Mac هذا فقط وللقراءة فقط؛ لا يُرسَل أي شيء عبر الشبكة.

**المتطلبات:** macOS 15 أو أحدث، وXcode 16 أو أحدث للبناء، وميزة إعادة توجيه الرسائل النصية على iPhone.

## لقطات الشاشة

| إنشاء قاعدة من نموذج رسالة SMS | تجربة |
|:---:|:---:|
| <img src="images/rule-builder.png" width="400" alt="إنشاء قاعدة من نموذج رسالة SMS"> | <img src="images/try-it.png" width="400" alt="تجربة"> |
| **عام** | **الكلمات المفتاحية** |
| <img src="images/settings-general.png" width="400" alt="عام"> | <img src="images/keywords.png" width="400" alt="الكلمات المفتاحية"> |

<p align="center"><img src="images/language-picker.png" width="260" alt="اللغة"><br><em>اللغة</em></p>

## التثبيت

### التنزيل

1. نزّل ملف `.dmg` من [أحدث إصدار](https://github.com/sineld/CodeCatcher/releases/latest). إنه تطبيق عام (Universal) يعمل على أجهزة Mac بشريحة Apple silicon وأجهزة Mac بمعالج Intel.
2. افتح ملف DMG واسحب CodeCatcher إلى مجلد التطبيقات.
3. التطبيق غير موثَّق (notarized) من Apple، لذلك يحظره macOS في المرة الأولى. حاول فتحه مرة واحدة، ثم انتقل إلى إعدادات النظام ← الخصوصية والأمن وانقر على **فتح على أي حال**. أو بدلًا من ذلك، شغّل هذا الأمر في تطبيق الطرفية:

   ```bash
   xattr -dr com.apple.quarantine /Applications/CodeCatcher.app
   ```

### البناء من المصدر

```bash
scripts/build-app.sh --install   # builds, installs to ~/Applications and launches
```

**التوقيع (موصى به):** يرتبط إذن الوصول الكامل إلى القرص بتوقيع التطبيق. مع التوقيع المخصص (ad-hoc) عليك منح الإذن من جديد بعد كل إعادة بناء. لتجنّب ذلك، أنشئ مرة واحدة شهادة باسم `CodeCatcher Local` من الوصول إلى سلسلة المفاتيح ← مساعد الشهادة ← إنشاء شهادة (نوع الهوية: جذر موقَّع ذاتيًا، نوع الشهادة: توقيع الرمز). يستخدمها السكربت عندما يجدها. لاستخدام شهادة أخرى: `CODESIGN_IDENTITY="…" scripts/build-app.sh`.

### بعد التثبيت

1. **الوصول الكامل إلى القرص:** إعدادات النظام ← الخصوصية والأمن ← الوصول الكامل إلى القرص ← CodeCatcher. بدونه لا يمكن قراءة `~/Library/Messages/chat.db`، ويعرض شريط القوائم أيقونة ⚠︎.
2. على iPhone، فعّل جهاز Mac هذا من الإعدادات ← الرسائل ← إعادة توجيه الرسائل النصية.

## اللغة

عند التشغيل الأول، يسألك CodeCatcher عن اللغة التي تريد استخدامها ويتذكّر اختيارك. يمكنك تغييرها لاحقًا من الإعدادات ← عام ← اللغة؛ ويُعاد تشغيل التطبيق لتطبيقها.

اللغات المدعومة: English، Türkçe، Deutsch، Español، Français، Italiano، Português (Brasil)، Nederlands، Polski، Русский، Українська، Kurdî (Kurmancî)، Azərbaycan dili، العربية، فارسی، 简体中文، 日本語، 한국어.

لا تحدّ لغة الواجهة من الرسائل التي تُلتقط: الكلمات المفتاحية لجميع اللغات المدعومة مفعّلة افتراضيًا.

## كيف يُختار الرمز

لكل رسالة جديدة، يُجرَّب ما يلي بالترتيب:

1. **القواعد:** تُجرَّب بترتيب القائمة في الإعدادات ← القواعد؛ وأول تطابق يحدد الرمز. لا تحتاج إلى معرفة regex؛ راجع «قواعد من نموذج رسالة SMS» أدناه.

   تُضاف القاعدة الافتراضية أدناه إلى القائمة مرة واحدة، عند التشغيل الأول. ومثل أي قاعدة أخرى، يمكن تعديلها وحذفها؛ ولا تعود القاعدة المحذوفة من تلقاء نفسها، ويمكن استعادتها عبر **استعادة القواعد الافتراضية المحذوفة**.

   | القاعدة | المرسل | Regex | السبب |
   |---|---|---|---|
   | GİB e-Arşiv | `GIB` | `SIFRENIZ:\s*([A-Z0-9]{4,8})\b` | كلمات مرور فواتير e-Arşiv مكوّنة من 6 خانات وتحتوي على حروف؛ وبعضها حروف فقط |

2. **الكلمات المفتاحية:** إذا ظهرت إحدى الكلمات المفتاحية في الرسالة، تصبح الأعداد المكوّنة من 4–8 أرقام أو التي على شكل `123 456` مرشّحة. تغطي الكلمات المفتاحية الافتراضية جميع اللغات المدعومة: `kod, şifre, parola, doğrulama, otp, code, password, passcode, código, codice, şifrə, код, пароль, رمز, کد, 验证码, 动态码, コード, 인증`.
   - **ما يُستبعَد:** أجزاء التواريخ والأوقات والمبالغ؛ ومجموعات أرقام الهواتف وIBAN؛ والمبالغ المتبوعة بعملة مثل `TL` أو `₺` أو `USD`؛ وعبارات البطاقات مثل «ile biten» و«son 4 hanesi»؛ وأرقام الطلبات بعد «no:»؛ وأرقام إلغاء الاشتراك في الحملات («3340'e RET yaz»، «OBRET->3340»).
   - من بين المرشّحين المتبقّين، يفوز الأقرب إلى كلمة مفتاحية. وعند التعادل، يُفضَّل الذي يأتي بعد الكلمة المفتاحية.

يُنسخ الرمز إلى الحافظة ويظهر إشعار. تُتجاهَل الرسائل الأقدم من 10 دقائق، مثل تلك التي تُزامَن بعد الاستيقاظ من وضع السكون.

### قواعد من نموذج رسالة SMS

إذا لم يُلتقط رمز مرسِل ما، فانتقل إلى الإعدادات ← القواعد ← **إنشاء قاعدة من نموذج SMS…**:

1. اكتب اسم المرسل، مثلًا `GIB`.
2. الصق رسالة SMS كاملةً.
3. حدّد الجزء المراد نسخه بالماوس.

يكتب CodeCatcher القاعدة بنفسه:
- تُستخدَم الكلمات الثابتة التي تسبق الرمز كمرساة؛ وإن لم توجد، تُستخدَم الكلمات التي تليه.
- يُستبدَل الرمز بنمط يطابق شكله: أرقام فقط، أو حروف وأرقام، بطول مماثل.
- قبل الحفظ، تُختبَر القاعدة على نموذج الرسالة. إذا لم تلتقط الرمز المحدد بالضبط، فلا يمكن حفظها.

على سبيل المثال، تحديد `4DAR7Q` في `… SMS SIFRENIZ: 4DAR7Q B001` ينتج قاعدة تبدأ بـ `SMS\s+SIFRENIZ\s*:\s*([A-Z0-9]{4,8})`. وهي تلتقط أيضًا كلمات المرور المكوّنة من حروف فقط مثل `ZPQRTT`. يُعرض تعبير regex المُنشأ في النافذة، ويمكن تعديله يدويًا بتوسيع القاعدة في القائمة.

في علامة التبويب **تجربة** يمكنك لصق رسالة SMS لترى فورًا أي رمز وأي قاعدة سيُختاران؛ ويمكنك إنشاء قاعدة من هناك أيضًا.

## الاختبار على رسائل حقيقية

```bash
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100          # digits masked
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100 --plain  # as is
```

يفحص هذا آخر N رسالة واردة ويطبع لكل منها الرمز المختار ومصدره، مع تمييز موضع الرمز في النص بـ `⟦CODE⟧`. لا يُنسخ أي شيء. يحتاج تطبيق الطرفية لديك إلى الوصول الكامل إلى القرص.

## التطوير

يشغّل GitHub Actions الأمر `swift test` عند كل push وكل طلب سحب (pull request).

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

**الترجمات:** المفاتيح هي النصوص الإنجليزية الموجودة في `Sources/`. لإضافة نص أو تغييره، حدّث `en.lproj` وجميع اللغات الأخرى؛ يفشل `LocalizationTests` إذا كان مفتاح أو عنصر نائب `%@` مفقودًا. نرحّب كثيرًا بالتصحيحات من الناطقين الأصليين.

## الخصوصية

تُقرأ الرسائل من `chat.db` على جهاز Mac هذا فقط، وللقراءة فقط. لا يُرسَل أي شيء عبر الشبكة ولا يُكتب على القرص. جميع رسائل SMS في الاختبارات مختلَقة.

يُنسخ الرمز الملتقَط إلى الحافظة؛ لذا ستخزّن تطبيقات سجل الحافظة هذه الرموز أيضًا.

## الدعم

CodeCatcher مجاني. إذا رغبت في دعم تطويره، يمكنك أن تصبح راعيًا عبر [GitHub Sponsors](https://github.com/sponsors/sineld). كما يساعد أيضًا وضع نجمة على المستودع والإبلاغ عن المشكلات.

## الترخيص

[MIT](../LICENSE)

## المطوّر

Sinan Eldem · [sinan@sinaneldem.tr](mailto:sinan@sinaneldem.tr) · [sinaneldem.tr](https://sinaneldem.tr)
