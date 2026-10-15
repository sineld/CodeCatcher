# CodeCatcher

[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-db61a2?logo=githubsponsors)](https://github.com/sponsors/sineld)

**다른 언어로 읽기:** [English](../README.md) · [Türkçe](README.tr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Kurdî](README.ku.md) · [Azərbaycan dili](README.az.md) · [العربية](README.ar.md) · [فارسی](README.fa.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md) · 한국어

iPhone에서 전달된 SMS 메시지의 일회용 인증 코드를 감지하여 클립보드에 복사하는 macOS 메뉴 막대 앱입니다. 의존성이 없으며, SwiftUI, Foundation, 시스템 SQLite만으로 충분합니다.

CodeCatcher는 무료 오픈 소스입니다. 개인 프로젝트로 만들어졌으며 있는 그대로 제공되고, 지원이나 업데이트는 보장되지 않습니다. 버그 리포트와 기여를 환영합니다. 시간을 절약하는 데 도움이 되었다면 [GitHub Sponsors](https://github.com/sponsors/sineld)를 통해 개발을 후원할 수 있습니다.

## 기능

- **메시지를 놓치지 않음:** 마지막으로 처리한 메시지 이후의 모든 새 SMS를 순서대로 처리합니다. macOS 13부터 대부분의 메시지 텍스트는 `attributedBody` 열에만 저장되는데, 이러한 메시지도 읽습니다.
- **올바른 숫자 선택:** 카드 번호, 날짜, 시간, 금액, 전화번호, 광고 수신 거부 번호는 걸러내고, 키워드에 가장 가까운 숫자를 코드로 가져옵니다.
- **다양한 언어 이해:** 18개 언어의 키워드가 내장되어 있으며, 숫자가 글자 바로 옆에 붙어 쓰이는 중국어, 일본어, 한국어 메시지에서도 작동합니다. 튀르키예어를 포함해 대소문자와 악센트는 구분하지 않습니다: ŞİFRE, şifre 및 sifre는 동일하게 취급됩니다.
- **regex 없는 규칙:** 샘플 SMS를 붙여넣고 코드를 선택하면 규칙이 자동으로 작성되고 샘플로 테스트됩니다.
- **GİB e-Arşiv:** 튀르키예 국세청의 e-Arşiv 송장 비밀번호는 문자를 포함하는데, 기본 규칙으로 감지됩니다.
- **18개 인터페이스 언어:** 처음 실행할 때 선택하며 설정에서 변경할 수 있습니다.
- **개인정보 보호:** 메시지는 이 Mac에서만 읽기 전용으로 읽히며, 네트워크로 전송되는 것은 없습니다.

**요구 사항:** macOS 15 이상, 빌드하려면 Xcode 16 이상, iPhone의 문자 메시지 전달.

## 설치

### 다운로드

1. [최신 릴리스](https://github.com/sineld/CodeCatcher/releases/latest)에서 `.dmg` 파일을 다운로드합니다. Apple 실리콘 Mac과 Intel Mac 모두에서 작동하는 유니버설 앱입니다.
2. DMG를 열고 CodeCatcher를 응용 프로그램 폴더로 드래그합니다.
3. 이 앱은 Apple의 공증을 받지 않았기 때문에 처음 실행할 때 macOS가 차단합니다. 한 번 열어 본 다음 시스템 설정 → 개인정보 보호 및 보안으로 이동하여 **그래도 열기**를 클릭합니다. 또는 터미널에서 다음 명령을 실행합니다:

   ```bash
   xattr -dr com.apple.quarantine /Applications/CodeCatcher.app
   ```

### 소스에서 빌드

```bash
scripts/build-app.sh --install   # builds, installs to ~/Applications and launches
```

**서명(권장):** 전체 디스크 접근 권한은 앱의 서명에 연결됩니다. 애드혹 서명을 사용하면 다시 빌드할 때마다 권한을 다시 부여해야 합니다. 이를 피하려면 키체인 접근 → 인증서 지원 → 인증서 생성에서 `CodeCatcher Local`이라는 이름의 인증서를 한 번 만드십시오(신원 유형: 자체 서명 루트, 인증서 유형: 코드 서명). 스크립트는 이 인증서를 찾으면 사용합니다. 다른 인증서를 사용하려면: `CODESIGN_IDENTITY="…" scripts/build-app.sh`.

### 설치 후

1. **전체 디스크 접근 권한:** 시스템 설정 → 개인정보 보호 및 보안 → 전체 디스크 접근 권한 → CodeCatcher. 이 권한이 없으면 `~/Library/Messages/chat.db`를 읽을 수 없으며 메뉴 막대에 ⚠︎ 아이콘이 표시됩니다.
2. iPhone의 설정 → 메시지 → 문자 메시지 전달에서 이 Mac을 켭니다.

## 언어

CodeCatcher는 처음 실행할 때 사용할 언어를 묻고 선택을 기억합니다. 나중에 설정 → 일반 → 언어에서 변경할 수 있으며, 변경 사항을 적용하기 위해 앱이 다시 시작됩니다.

지원 언어: English, Türkçe, Deutsch, Español, Français, Italiano, Português (Brasil), Nederlands, Polski, Русский, Українська, Kurdî (Kurmancî), Azərbaycan dili, العربية, فارسی, 简体中文, 日本語, 한국어.

인터페이스 언어는 감지되는 메시지를 제한하지 않습니다. 지원되는 모든 언어의 키워드가 기본적으로 활성화되어 있습니다.

## 코드 선택 방식

각 새 메시지에 대해 다음을 순서대로 시도합니다:

1. **규칙:** 설정 → 규칙에 있는 목록의 순서대로 시도하며, 처음 일치하는 규칙이 코드를 결정합니다. regex를 알 필요는 없습니다. 아래의 "샘플 SMS로 만드는 규칙"을 참고하십시오.

   아래 기본 규칙은 처음 실행할 때 한 번 목록에 추가됩니다. 다른 규칙처럼 편집하고 삭제할 수 있으며, 삭제한 규칙은 저절로 돌아오지 않고 **삭제된 기본 규칙 복원**으로 복원할 수 있습니다.

   | 규칙 | 발신자 | Regex | 이유 |
   |---|---|---|---|
   | GİB e-Arşiv | `GIB` | `SIFRENIZ:\s*([A-Z0-9]{4,8})\b` | e-Arşiv 송장 비밀번호는 6자이며 문자를 포함하고, 일부는 문자로만 이루어져 있음 |

2. **키워드:** 메시지에 키워드 중 하나가 있으면 4–8자리 숫자 또는 `123 456` 형식의 숫자가 후보가 됩니다. 기본 키워드는 지원되는 모든 언어를 포함합니다: `kod, şifre, parola, doğrulama, otp, code, password, passcode, código, codice, şifrə, код, пароль, رمز, کد, 验证码, 动态码, コード, 인증`.
   - **제외되는 항목:** 날짜, 시간, 금액의 일부, 전화번호와 IBAN 숫자 그룹, `TL`, `₺`, `USD` 같은 통화가 뒤따르는 금액, "ile biten", "son 4 hanesi" 같은 카드 관련 표현, "no:" 뒤의 주문 번호, 광고 수신 거부 번호("3340'e RET yaz", "OBRET->3340").
   - 남은 후보 중 키워드에 가장 가까운 것이 선택됩니다. 거리가 같으면 키워드 뒤에 오는 것이 우선합니다.

코드가 클립보드에 복사되고 알림이 표시됩니다. 잠자기에서 깨어난 후 동기화된 메시지처럼 10분보다 오래된 메시지는 무시됩니다.

### 샘플 SMS로 만드는 규칙

발신자의 코드가 감지되지 않으면 설정 → 규칙 → **샘플 SMS로 규칙 생성…**으로 이동하십시오:

1. 발신자 이름을 입력합니다(예: `GIB`).
2. SMS 전체를 붙여넣습니다.
3. 복사할 부분을 마우스로 선택합니다.

CodeCatcher가 규칙을 직접 작성합니다:
- 코드 앞의 고정된 단어가 기준점(anchor)으로 사용되며, 없으면 코드 뒤의 단어가 사용됩니다.
- 코드는 그 형태에 맞는 패턴으로 바뀝니다: 숫자만, 또는 문자와 숫자로 이루어진 비슷한 길이의 패턴입니다.
- 저장하기 전에 규칙을 샘플 SMS로 테스트합니다. 선택한 코드를 정확히 가져오지 못하면 저장할 수 없습니다.

예를 들어 `… SMS SIFRENIZ: 4DAR7Q B001`에서 `4DAR7Q`를 선택하면 `SMS\s+SIFRENIZ\s*:\s*([A-Z0-9]{4,8})`로 시작하는 규칙이 만들어집니다. 이 규칙은 `ZPQRTT` 같은 문자로만 된 비밀번호도 감지합니다. 생성된 regex는 윈도우에 표시되며, 목록에서 규칙을 펼쳐 직접 편집할 수 있습니다.

**테스트** 탭에서 SMS를 붙여넣으면 어떤 코드와 어떤 규칙이 선택될지 바로 확인할 수 있으며, 그곳에서 규칙을 만들 수도 있습니다.

## 실제 메시지로 테스트하기

```bash
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100          # digits masked
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100 --plain  # as is
```

최근 수신 메시지 N개를 검사하여 각 메시지에서 선택된 코드와 그 출처를 출력하고, 텍스트에서 코드의 위치를 `⟦CODE⟧`로 표시합니다. 아무것도 복사되지 않습니다. 터미널에 전체 디스크 접근 권한이 필요합니다.

## 개발

GitHub Actions는 모든 푸시와 풀 리퀘스트에서 `swift test`를 실행합니다.

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

**번역:** 키는 `Sources/`에 있는 영어 문자열입니다. 문자열을 추가하거나 변경하려면 `en.lproj`와 다른 모든 언어를 업데이트하십시오. 키나 `%@` 플레이스홀더가 빠지면 `LocalizationTests`가 실패합니다. 원어민의 수정 제안을 언제나 환영합니다.

## 개인정보 보호

메시지는 이 Mac의 `chat.db`에서 읽기 전용으로만 읽힙니다. 네트워크로 전송되거나 디스크에 기록되는 것은 없습니다. 테스트에 사용된 SMS는 모두 지어낸 것입니다.

감지된 코드는 클립보드에 복사되므로 클립보드 기록 앱도 이 코드를 저장하게 됩니다.

## 후원

CodeCatcher는 무료입니다. 개발을 후원하고 싶다면 [GitHub Sponsors](https://github.com/sponsors/sineld)에서 후원자가 될 수 있습니다. 저장소에 별표를 주거나 문제를 보고하는 것도 도움이 됩니다.

## 라이선스

[MIT](../LICENSE)

## 개발자

Sinan Eldem · [sinan@sinaneldem.tr](mailto:sinan@sinaneldem.tr) · [sinaneldem.tr](https://sinaneldem.tr)
