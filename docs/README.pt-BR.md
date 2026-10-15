# CodeCatcher

[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-db61a2?logo=githubsponsors)](https://github.com/sponsors/sineld)

**Leia em:** [English](../README.md) · [Türkçe](README.tr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) · [Italiano](README.it.md) · Português (Brasil) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Kurdî](README.ku.md) · [Azərbaycan dili](README.az.md) · [العربية](README.ar.md) · [فارسی](README.fa.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

Um app de barra de menus do macOS que captura códigos de verificação de uso único em mensagens SMS encaminhadas do seu iPhone e os copia para a área de transferência. Não tem dependências: SwiftUI, Foundation e o SQLite do sistema bastam.

O CodeCatcher é gratuito e de código aberto. Ele foi criado como um projeto pessoal e é fornecido como está, sem garantia de suporte ou atualizações. Relatos de bugs e contribuições são bem-vindos. Se ele economiza o seu tempo, você pode apoiar o desenvolvimento pelo [GitHub Sponsors](https://github.com/sponsors/sineld).

## Recursos

- **Nunca pula uma mensagem:** Todo SMS novo desde o último processado é tratado em ordem. Desde o macOS 13, o texto da maioria das mensagens fica armazenado apenas na coluna `attributedBody`; essas mensagens também são lidas.
- **Escolhe o número certo:** Dígitos de cartão, datas, horários, valores, números de telefone e números para cancelar campanhas são filtrados; o número mais próximo de uma palavra-chave é usado como código.
- **Entende vários idiomas:** Palavras-chave em 18 idiomas já vêm incluídas, e mensagens em chinês, japonês e coreano, em que os dígitos são escritos colados às letras, também funcionam. Maiúsculas, minúsculas e acentos não importam, inclusive em turco: ŞİFRE, şifre e sifre são iguais.
- **Regras sem regex:** Cole um SMS de exemplo e selecione o código; a regra é escrita para você e testada no exemplo.
- **GİB e-Arşiv:** As senhas de faturas e-Arşiv da Administração da Receita da Turquia, que contêm letras, são capturadas por uma regra padrão.
- **18 idiomas de interface:** O idioma é escolhido na primeira abertura e pode ser alterado nos Ajustes.
- **Privado:** As mensagens são lidas apenas neste Mac, somente para leitura; nada é enviado pela rede.

**Requisitos:** macOS 15 ou posterior, Xcode 16 ou posterior para compilar e o Encaminhamento de Mensagens de Texto no iPhone.

## Instalação

### Download

1. Baixe o arquivo `.dmg` da [versão mais recente](https://github.com/sineld/CodeCatcher/releases/latest). É um app universal para Macs com Apple silicon e com Intel.
2. Abra o DMG e arraste o CodeCatcher para a pasta Aplicativos.
3. O app não é notarizado pela Apple, então o macOS o bloqueia na primeira vez. Tente abri-lo uma vez e depois vá em Ajustes do Sistema → Privacidade e Segurança e clique em **Abrir Mesmo Assim**. Como alternativa, execute isto no Terminal:

   ```bash
   xattr -dr com.apple.quarantine /Applications/CodeCatcher.app
   ```

### Compilar a partir do código-fonte

```bash
scripts/build-app.sh --install   # builds, installs to ~/Applications and launches
```

**Assinatura (recomendado):** A permissão de Acesso Total ao Disco fica vinculada à assinatura do app. Com assinatura ad hoc, você precisa concedê-la de novo após cada recompilação. Para evitar isso, crie uma única vez um certificado chamado `CodeCatcher Local` em Acesso às Chaves → Assistente de Certificado → Criar um Certificado (tipo de identidade: Raiz Autoassinada, tipo de certificado: Assinatura de Código). O script o usa quando o encontra. Para usar outro certificado: `CODESIGN_IDENTITY="…" scripts/build-app.sh`.

### Após a instalação

1. **Acesso Total ao Disco:** Ajustes do Sistema → Privacidade e Segurança → Acesso Total ao Disco → CodeCatcher. Sem isso, `~/Library/Messages/chat.db` não pode ser lido e a barra de menus mostra um ícone ⚠︎.
2. No iPhone, ative este Mac em Ajustes → Mensagens → Encaminhamento de Mensagens de Texto.

## Idioma

Na primeira abertura, o CodeCatcher pergunta qual idioma usar e lembra a escolha. Você pode alterá-lo depois em Ajustes → Geral → Idioma; o app é reiniciado para aplicá-lo.

Idiomas suportados: English, Türkçe, Deutsch, Español, Français, Italiano, Português (Brasil), Nederlands, Polski, Русский, Українська, Kurdî (Kurmancî), Azərbaycan dili, العربية, فارسی, 简体中文, 日本語, 한국어.

O idioma da interface não limita quais mensagens são capturadas: as palavras-chave de todos os idiomas suportados ficam ativas por padrão.

## Como o código é escolhido

Para cada mensagem nova, o seguinte é testado em ordem:

1. **Regras:** Testadas na ordem da lista em Ajustes → Regras; a primeira correspondência define o código. Você não precisa saber regex; veja “Regras a partir de um SMS de exemplo” abaixo.

   A regra padrão abaixo é adicionada à lista uma única vez, na primeira abertura. Como qualquer outra regra, ela pode ser editada e apagada; uma regra apagada não volta sozinha e pode ser restaurada com **Restaurar Regras Padrão Apagadas**.

   | Regra | Remetente | Regex | Por quê |
   |---|---|---|---|
   | GİB e-Arşiv | `GIB` | `SIFRENIZ:\s*([A-Z0-9]{4,8})\b` | As senhas do e-Arşiv têm 6 caracteres e contêm letras; algumas são só letras |

2. **Palavras-chave:** Se uma das palavras-chave aparecer na mensagem, números com 4 a 8 dígitos ou no formato `123 456` se tornam candidatos. As palavras-chave padrão cobrem todos os idiomas suportados: `kod, şifre, parola, doğrulama, otp, code, password, passcode, código, codice, şifrə, код, пароль, رمز, کد, 验证码, 动态码, コード, 인증`.
   - **Filtrados:** partes de datas, horários e valores; grupos de números de telefone e IBAN; valores seguidos de uma moeda como `TL`, `₺` ou `USD`; expressões de cartão como “ile biten” e “son 4 hanesi”; números de pedido depois de “no:”; números para cancelar campanhas (“3340'e RET yaz”, “OBRET->3340”).
   - Dos candidatos restantes, vence o mais próximo de uma palavra-chave. Em caso de empate, tem preferência o que vem depois da palavra-chave.

O código é copiado para a área de transferência e uma notificação é exibida. Mensagens com mais de 10 minutos, como as sincronizadas depois que o Mac sai do repouso, são ignoradas.

### Regras a partir de um SMS de exemplo

Se o código de um remetente não for capturado, vá em Ajustes → Regras → **Criar Regra a Partir de SMS de Exemplo…**:

1. Digite o nome do remetente, por exemplo `GIB`.
2. Cole o SMS inteiro.
3. Selecione com o mouse a parte a ser copiada.

O próprio CodeCatcher escreve a regra:
- As palavras fixas antes do código são usadas como âncora; se não houver nenhuma, são usadas as palavras depois do código.
- O código é substituído por um padrão que corresponde ao seu formato: só dígitos, ou letras e dígitos, com comprimento parecido.
- Antes de salvar, a regra é testada no SMS de exemplo. Se ela não capturar exatamente o código selecionado, não pode ser salva.

Por exemplo, selecionar `4DAR7Q` em `… SMS SIFRENIZ: 4DAR7Q B001` gera uma regra que começa com `SMS\s+SIFRENIZ\s*:\s*([A-Z0-9]{4,8})`. Ela também captura senhas só de letras, como `ZPQRTT`. A regex gerada é exibida na janela e pode ser editada à mão expandindo a regra na lista.

Na aba **Testar**, você pode colar um SMS e ver na hora qual código e qual regra seriam escolhidos; também é possível criar uma regra a partir dali.

## Testes com mensagens reais

```bash
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100          # digits masked
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100 --plain  # as is
```

Isto examina as últimas N mensagens recebidas e mostra, para cada uma, o código escolhido e a sua origem, marcando a posição do código no texto com `⟦CODE⟧`. Nada é copiado. O seu Terminal precisa de Acesso Total ao Disco.

## Desenvolvimento

O GitHub Actions executa `swift test` a cada push e pull request.

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

**Traduções:** As chaves são as strings em inglês de `Sources/`. Para adicionar ou alterar uma string, atualize `en.lproj` e todos os outros idiomas; `LocalizationTests` falha se faltar uma chave ou um marcador `%@`. Correções de falantes nativos são muito bem-vindas.

## Privacidade

As mensagens são lidas apenas do `chat.db` neste Mac, somente para leitura. Nada é enviado pela rede nem gravado no disco. Todos os SMS dos testes são inventados.

O código capturado é copiado para a área de transferência; apps de histórico da área de transferência também vão armazenar esses códigos.

## Apoio

O CodeCatcher é gratuito. Se quiser apoiar o desenvolvimento, você pode se tornar patrocinador no [GitHub Sponsors](https://github.com/sponsors/sineld). Dar uma estrela ao repositório e relatar problemas também ajuda.

## Licença

[MIT](../LICENSE)

## Desenvolvedor

Sinan Eldem · [sinan@sinaneldem.tr](mailto:sinan@sinaneldem.tr) · [sinaneldem.tr](https://sinaneldem.tr)
