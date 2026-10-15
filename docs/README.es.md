# CodeCatcher

[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-db61a2?logo=githubsponsors)](https://github.com/sponsors/sineld)

**Léelo en:** [English](../README.md) · [Türkçe](README.tr.md) · [Deutsch](README.de.md) · Español · [Français](README.fr.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Kurdî](README.ku.md) · [Azərbaycan dili](README.az.md) · [العربية](README.ar.md) · [فارسی](README.fa.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

Una app para la barra de menús de macOS que captura los códigos de verificación de un solo uso de los SMS reenviados desde tu iPhone y los copia al portapapeles. No tiene dependencias: bastan SwiftUI, Foundation y el SQLite del sistema.

CodeCatcher es gratuito y de código abierto. Se creó como proyecto personal y se ofrece tal cual, sin garantía de soporte ni de actualizaciones. Los informes de errores y las contribuciones son bienvenidos. Si te ahorra tiempo, puedes apoyar su desarrollo a través de [GitHub Sponsors](https://github.com/sponsors/sineld).

## Funciones

- **No se salta ningún mensaje:** Todos los SMS nuevos desde el último procesado se gestionan en orden. Desde macOS 13, el texto de la mayoría de los mensajes solo se guarda en la columna `attributedBody`; esos mensajes también se leen.
- **Elige el número correcto:** Se descartan los dígitos de tarjetas, las fechas, las horas, los importes, los números de teléfono y los números para darse de baja de campañas; se toma como código el número más cercano a una palabra clave.
- **Entiende muchos idiomas:** Incluye palabras clave en 18 idiomas, y también funcionan los mensajes en chino, japonés y coreano, en los que los dígitos se escriben pegados a las letras. No importan las mayúsculas ni los acentos, tampoco en turco: ŞİFRE, şifre y sifre son lo mismo.
- **Reglas sin regex:** Pega un SMS de ejemplo y selecciona el código; la regla se escribe sola y se prueba con el ejemplo.
- **GİB e-Arşiv:** Las contraseñas de las facturas e-Arşiv de la Administración Tributaria de Turquía, que contienen letras, se capturan con una regla predeterminada.
- **18 idiomas de interfaz:** Se elige al abrir la app por primera vez y se puede cambiar en Ajustes.
- **Privado:** Los mensajes solo se leen en este Mac, en modo de solo lectura; no se envía nada por la red.

**Requisitos:** macOS 15 o posterior, Xcode 16 o posterior para compilar y el Reenvío de mensajes de texto en tu iPhone.

## Instalación

### Descarga

1. Descarga el archivo `.dmg` desde la [última versión](https://github.com/sineld/CodeCatcher/releases/latest). Es una app universal para Mac con Apple silicon y con Intel.
2. Abre el DMG y arrastra CodeCatcher a la carpeta Aplicaciones.
3. La app no está notarizada por Apple, así que macOS la bloquea la primera vez. Intenta abrirla una vez y luego ve a Ajustes del Sistema → Privacidad y seguridad y haz clic en **Abrir igualmente**. Como alternativa, ejecuta esto en Terminal:

   ```bash
   xattr -dr com.apple.quarantine /Applications/CodeCatcher.app
   ```

### Compilar desde el código fuente

```bash
scripts/build-app.sh --install   # builds, installs to ~/Applications and launches
```

**Firma (recomendado):** El permiso de Acceso total al disco está ligado a la firma de la app. Con una firma ad hoc tienes que volver a concederlo después de cada recompilación. Para evitarlo, crea una sola vez un certificado llamado `CodeCatcher Local` en Acceso a Llaveros → Asistente para certificados → Crear un certificado (tipo de identidad: Raíz autofirmada, tipo de certificado: Firma de código). El script lo usa cuando lo encuentra. Para usar otro certificado: `CODESIGN_IDENTITY="…" scripts/build-app.sh`.

### Después de instalar

1. **Acceso total al disco:** Ajustes del Sistema → Privacidad y seguridad → Acceso total al disco → CodeCatcher. Sin él no se puede leer `~/Library/Messages/chat.db` y la barra de menús muestra un icono ⚠︎.
2. En tu iPhone, activa este Mac en Ajustes → Mensajes → Reenvío de mensajes de texto.

## Idioma

La primera vez que se abre, CodeCatcher pregunta qué idioma usar y recuerda la elección. Puedes cambiarlo más adelante en Ajustes → General → Idioma; la app se reinicia para aplicarlo.

Idiomas disponibles: English, Türkçe, Deutsch, Español, Français, Italiano, Português (Brasil), Nederlands, Polski, Русский, Українська, Kurdî (Kurmancî), Azərbaycan dili, العربية, فارسی, 简体中文, 日本語, 한국어.

El idioma de la interfaz no limita qué mensajes se capturan: las palabras clave de todos los idiomas disponibles están activas por omisión.

## Cómo se elige el código

Para cada mensaje nuevo se prueba lo siguiente, en orden:

1. **Reglas:** Se prueban en el orden de la lista de Ajustes → Reglas; la primera coincidencia determina el código. No necesitas saber regex; consulta «Reglas a partir de un SMS de ejemplo» más abajo.

   La regla predeterminada de abajo se añade a la lista una sola vez, al abrir la app por primera vez. Como cualquier otra regla, se puede editar y eliminar; una regla eliminada no vuelve por sí sola y se puede recuperar con **Restaurar reglas predeterminadas eliminadas**.

   | Regla | Remitente | Regex | Motivo |
   |---|---|---|---|
   | GİB e-Arşiv | `GIB` | `SIFRENIZ:\s*([A-Z0-9]{4,8})\b` | Las contraseñas de e-Arşiv tienen 6 caracteres y contienen letras; algunas son solo letras |

2. **Palabras clave:** Si en el mensaje aparece una de las palabras clave, los números de 4 a 8 dígitos o con la forma `123 456` pasan a ser candidatos. Las palabras clave predeterminadas cubren todos los idiomas disponibles: `kod, şifre, parola, doğrulama, otp, code, password, passcode, código, codice, şifrə, код, пароль, رمز, کد, 验证码, 动态码, コード, 인증`.
   - **Se descartan:** partes de fechas, horas e importes; grupos de números de teléfono e IBAN; importes seguidos de una moneda como `TL`, `₺` o `USD`; expresiones de tarjeta como «ile biten» y «son 4 hanesi»; números de pedido después de «no:»; números para darse de baja de campañas («3340'e RET yaz», «OBRET->3340»).
   - De los candidatos que quedan, gana el más cercano a una palabra clave. En caso de empate, se prefiere el que va después de la palabra clave.

El código se copia al portapapeles y se muestra una notificación. Los mensajes con más de 10 minutos de antigüedad, como los que se sincronizan al salir del reposo, se ignoran.

### Reglas a partir de un SMS de ejemplo

Si no se captura el código de un remitente, ve a Ajustes → Reglas → **Crear regla desde un SMS de ejemplo…**:

1. Escribe el nombre del remitente, por ejemplo `GIB`.
2. Pega el SMS completo.
3. Selecciona con el ratón la parte que quieres copiar.

CodeCatcher escribe la regla por sí mismo:
- Las palabras fijas que preceden al código se usan como ancla; si no hay ninguna, se usan las palabras que lo siguen.
- El código se sustituye por un patrón que coincide con su forma: solo dígitos, o letras y dígitos, de longitud similar.
- Antes de guardarla, la regla se prueba con el SMS de ejemplo. Si no captura exactamente el código seleccionado, no se puede guardar.

Por ejemplo, al seleccionar `4DAR7Q` en `… SMS SIFRENIZ: 4DAR7Q B001` se obtiene una regla que empieza por `SMS\s+SIFRENIZ\s*:\s*([A-Z0-9]{4,8})`. También captura contraseñas formadas solo por letras, como `ZPQRTT`. La regex generada se muestra en la ventana y se puede editar a mano desplegando la regla en la lista.

En la pestaña **Probar** puedes pegar un SMS y ver al instante qué código y qué regla se elegirían; desde ahí también puedes crear una regla.

## Pruebas con mensajes reales

```bash
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100          # digits masked
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100 --plain  # as is
```

Esto analiza los últimos N mensajes recibidos y muestra, para cada uno, el código elegido y su origen, y marca la posición del código en el texto con `⟦CODE⟧`. No se copia nada. Tu terminal necesita Acceso total al disco.

## Desarrollo

GitHub Actions ejecuta `swift test` en cada push y pull request.

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

**Traducciones:** Las claves son las cadenas en inglés de `Sources/`. Para añadir o cambiar una cadena, actualiza `en.lproj` y todos los demás idiomas; `LocalizationTests` falla si falta una clave o un marcador `%@`. Las correcciones de hablantes nativos son muy bienvenidas.

## Privacidad

Los mensajes solo se leen desde `chat.db` en este Mac, en modo de solo lectura. No se envía nada por la red ni se escribe nada en el disco. Todos los SMS de las pruebas son inventados.

El código capturado se copia al portapapeles; las apps de historial del portapapeles también guardarán estos códigos.

## Apoyo

CodeCatcher es gratuito. Si quieres apoyar su desarrollo, puedes hacerte patrocinador en [GitHub Sponsors](https://github.com/sponsors/sineld). Dar una estrella al repositorio e informar de problemas también ayuda.

## Licencia

[MIT](../LICENSE)

## Desarrollador

Sinan Eldem · [sinan@sinaneldem.tr](mailto:sinan@sinaneldem.tr) · [sinaneldem.tr](https://sinaneldem.tr)
