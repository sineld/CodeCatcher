# CodeCatcher

[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-db61a2?logo=githubsponsors)](https://github.com/sponsors/sineld)

**阅读语言：** [English](../README.md) · [Türkçe](README.tr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Kurdî](README.ku.md) · [Azərbaycan dili](README.az.md) · [العربية](README.ar.md) · [فارسی](README.fa.md) · 简体中文 · [日本語](README.ja.md) · [한국어](README.ko.md)

一款 macOS 菜单栏 App，可捕获从 iPhone 转发的短信中的一次性验证码，并将其拷贝到剪贴板。它没有任何依赖：SwiftUI、Foundation 和系统自带的 SQLite 就足够了。

CodeCatcher 免费且开源。它作为个人项目开发，按原样提供，不保证提供支持或更新。欢迎提交错误报告和贡献代码。如果它为你节省了时间，你可以通过 [GitHub Sponsors](https://github.com/sponsors/sineld) 支持它的开发。

## 功能

- **绝不遗漏短信：** 自上次处理的短信以来的每条新短信都会按顺序处理。从 macOS 13 起，大多数信息的文本只存储在 `attributedBody` 列中；这些信息同样会被读取。
- **选出正确的数字：** 卡号、日期、时间、金额、电话号码和营销短信退订号码都会被过滤掉；离关键词最近的数字会被当作验证码。
- **理解多种语言：** 内置 18 种语言的关键词，数字紧挨着文字书写的中文、日文和韩文短信也同样适用。不区分大小写和重音符号，土耳其语也是如此：ŞİFRE, şifre 和 sifre 视为相同。
- **无需 regex 的规则：** 粘贴一条短信样本并选中验证码，规则就会自动生成，并在样本上进行测试。
- **GİB e-Arşiv：** 土耳其税务局 e-Arşiv 发票的密码包含字母，可由一条默认规则捕获。
- **18 种界面语言：** 首次启动时选择，之后可在设置中更改。
- **注重隐私：** 短信仅在这台 Mac 上以只读方式读取；不会通过网络发送任何内容。

**系统要求：** macOS 15 或更高版本，构建需要 Xcode 16 或更高版本，并在 iPhone 上开启短信转发。

## 安装

```bash
scripts/build-app.sh --install   # builds, installs to ~/Applications and launches
```

1. **完全磁盘访问权限：** 系统设置 → 隐私与安全性 → 完全磁盘访问权限 → CodeCatcher。没有此权限就无法读取 `~/Library/Messages/chat.db`，菜单栏会显示 ⚠︎ 图标。
2. **签名（推荐）：** 该权限与 App 的签名绑定。使用临时（ad-hoc）签名时，每次重新构建后都必须重新授予权限。为避免这种情况，请在钥匙串访问 → 证书助理 → 创建证书中，一次性创建一个名为 `CodeCatcher Local` 的证书（身份类型：自签名根证书，证书类型：代码签名）。脚本找到该证书时就会使用它。要使用其他证书：`CODESIGN_IDENTITY="…" scripts/build-app.sh`。
3. 在 iPhone 上，前往设置 → 信息 → 短信转发，开启这台 Mac。

## 语言

首次启动时，CodeCatcher 会询问要使用的语言并记住你的选择。你之后可以在设置 → 通用 → 语言中更改；App 会重新启动以应用更改。

支持的语言：English、Türkçe、Deutsch、Español、Français、Italiano、Português (Brasil)、Nederlands、Polski、Русский、Українська、Kurdî (Kurmancî)、Azərbaycan dili、العربية、فارسی、简体中文、日本語、한국어。

界面语言不会限制可捕获的短信：所有支持语言的关键词默认都处于启用状态。

## 如何选择验证码

对于每条新短信，会按以下顺序尝试：

1. **规则：** 按设置 → 规则中列表的顺序尝试；第一个匹配的规则决定验证码。你不需要懂 regex；请参阅下文的“基于短信样本的规则”。

   下面的默认规则会在首次启动时添加到列表中，仅添加一次。与其他规则一样，它可以编辑和删除；删除的规则不会自动恢复，可以通过**恢复已删除的默认规则**来恢复。

   | 规则 | 发送者 | Regex | 原因 |
   |---|---|---|---|
   | GİB e-Arşiv | `GIB` | `SIFRENIZ:\s*([A-Z0-9]{4,8})\b` | e-Arşiv 发票密码为 6 个字符且包含字母；有些只含字母 |

2. **关键词：** 如果短信中出现任一关键词，4–8 位数字或 `123 456` 形式的数字会成为候选。默认关键词涵盖所有支持的语言：`kod, şifre, parola, doğrulama, otp, code, password, passcode, código, codice, şifrə, код, пароль, رمز, کد, 验证码, 动态码, コード, 인증`。
   - **会被过滤掉的：** 日期、时间和金额的组成部分；电话号码和 IBAN 的数字分组；后跟 `TL`、`₺` 或 `USD` 等货币的金额；“ile biten”和“son 4 hanesi”等银行卡相关短语；“no:”后面的订单号；营销短信退订号码（“3340'e RET yaz”、“OBRET->3340”）。
   - 在剩余的候选中，离关键词最近的胜出。距离相同时，优先选择位于关键词之后的那个。

验证码会被拷贝到剪贴板，并显示通知。超过 10 分钟的短信（例如从睡眠中唤醒后才同步的短信）会被忽略。

### 基于短信样本的规则

如果某个发送者的验证码未被捕获，请前往设置 → 规则 → **根据短信样本创建规则…**：

1. 输入发送者名称，例如 `GIB`。
2. 粘贴完整的短信。
3. 用鼠标选中要拷贝的部分。

CodeCatcher 会自动编写规则：
- 验证码前面的固定词语用作锚点；如果没有，则使用验证码后面的词语。
- 验证码会被替换为与其形式相匹配的模式：仅数字，或字母加数字，长度相近。
- 存储之前，规则会在短信样本上进行测试。如果它不能准确捕获所选的验证码，就无法存储。

例如，在 `… SMS SIFRENIZ: 4DAR7Q B001` 中选中 `4DAR7Q`，会生成一条以 `SMS\s+SIFRENIZ\s*:\s*([A-Z0-9]{4,8})` 开头的规则。它也能捕获像 `ZPQRTT` 这样只含字母的密码。生成的 regex 会显示在窗口中，在列表中展开该规则即可手动编辑。

在**测试**标签页中，你可以粘贴一条短信，立即查看会选择哪个验证码以及哪条规则；也可以在那里创建规则。

## 使用真实短信测试

```bash
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100          # digits masked
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100 --plain  # as is
```

此命令会扫描最近收到的 N 条信息，为每条信息打印所选的验证码及其来源，并在文本中用 `⟦CODE⟧` 标出验证码的位置。不会拷贝任何内容。你的终端需要完全磁盘访问权限。

## 开发

GitHub Actions 会在每次推送和拉取请求时运行 `swift test`。

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

**翻译：** 键是 `Sources/` 中的英文字符串。要添加或更改字符串，请更新 `en.lproj` 以及所有其他语言；如果缺少某个键或 `%@` 占位符，`LocalizationTests` 就会失败。非常欢迎母语使用者提供修正。

## 隐私

短信仅从这台 Mac 上的 `chat.db` 以只读方式读取。不会通过网络发送任何内容，也不会写入磁盘。测试中的所有短信都是虚构的。

捕获的验证码会被拷贝到剪贴板；剪贴板历史记录类 App 也会存储这些验证码。

## 支持

CodeCatcher 是免费的。如果你想支持它的开发，可以在 [GitHub Sponsors](https://github.com/sponsors/sineld) 上成为赞助者。为仓库加星标和报告问题也很有帮助。

## 许可证

[MIT](../LICENSE)

## 开发者

Sinan Eldem · [sinan@sinaneldem.tr](mailto:sinan@sinaneldem.tr) · [sinaneldem.tr](https://sinaneldem.tr)
