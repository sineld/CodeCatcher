# CodeCatcher

[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-db61a2?logo=githubsponsors)](https://github.com/sponsors/sineld)

**Lire en :** [English](../README.md) · [Türkçe](README.tr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · Français · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Kurdî](README.ku.md) · [Azərbaycan dili](README.az.md) · [العربية](README.ar.md) · [فارسی](README.fa.md) · [简体中文](README.zh-Hans.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

Une app pour la barre des menus de macOS qui détecte les codes de vérification à usage unique dans les SMS transférés depuis votre iPhone et les copie dans le presse-papiers. Elle n’a aucune dépendance : SwiftUI, Foundation et le SQLite du système suffisent.

CodeCatcher est gratuit et open source. Il a été conçu comme un projet personnel et est fourni tel quel, sans garantie d’assistance ni de mises à jour. Les signalements de bugs et les contributions sont les bienvenus. S’il vous fait gagner du temps, vous pouvez soutenir son développement via [GitHub Sponsors](https://github.com/sponsors/sineld).

## Fonctionnalités

- **Ne saute aucun message :** chaque nouveau SMS reçu depuis le dernier traité est pris en charge dans l’ordre. Depuis macOS 13, le texte de la plupart des messages n’est stocké que dans la colonne `attributedBody` ; ces messages sont lus eux aussi.
- **Choisit le bon nombre :** les chiffres de carte, dates, heures, montants, numéros de téléphone et numéros de désinscription des campagnes sont écartés ; le nombre le plus proche d’un mot-clé est retenu comme code.
- **Comprend de nombreuses langues :** des mots-clés dans 18 langues sont intégrés, et les messages en chinois, japonais et coréen, où les chiffres sont collés aux caractères, fonctionnent aussi. La casse et les accents n’ont pas d’importance, y compris en turc : ŞİFRE, şifre et sifre sont identiques.
- **Des règles sans regex :** collez un SMS d’exemple et sélectionnez le code ; la règle est écrite pour vous et testée sur l’exemple.
- **GİB e-Arşiv :** les mots de passe des factures e-Arşiv de l’administration fiscale turque, qui contiennent des lettres, sont détectés par une règle par défaut.
- **18 langues d’interface :** choisie au premier lancement et modifiable dans les Réglages.
- **Confidentiel :** les messages sont lus uniquement sur ce Mac, en lecture seule ; rien n’est envoyé sur le réseau.

**Configuration requise :** macOS 15 ou ultérieur, Xcode 16 ou ultérieur pour compiler, et le transfert de SMS activé sur votre iPhone.

## Installation

```bash
scripts/build-app.sh --install   # builds, installs to ~/Applications and launches
```

1. **Accès complet au disque :** Réglages Système → Confidentialité et sécurité → Accès complet au disque → CodeCatcher. Sans cet accès, `~/Library/Messages/chat.db` ne peut pas être lu et la barre des menus affiche une icône ⚠︎.
2. **Signature (recommandée) :** l’autorisation est liée à la signature de l’app. Avec une signature ad hoc, vous devez l’accorder à nouveau après chaque recompilation. Pour l’éviter, créez une fois pour toutes un certificat nommé `CodeCatcher Local` dans Trousseau d’accès → Assistant de certification → Créer un certificat (type d’identité : Racine auto-signée, type de certificat : Signature de code). Le script l’utilise s’il le trouve. Pour utiliser un autre certificat : `CODESIGN_IDENTITY="…" scripts/build-app.sh`.
3. Sur votre iPhone, activez ce Mac dans Réglages → Messages → Transfert de SMS.

## Langue

Au premier lancement, CodeCatcher demande quelle langue utiliser et mémorise ce choix. Vous pouvez la modifier plus tard dans Réglages → Général → Langue ; l’app redémarre pour l’appliquer.

Langues prises en charge : English, Türkçe, Deutsch, Español, Français, Italiano, Português (Brasil), Nederlands, Polski, Русский, Українська, Kurdî (Kurmancî), Azərbaycan dili, العربية, فارسی, 简体中文, 日本語, 한국어.

La langue de l’interface ne limite pas les messages détectés : les mots-clés de toutes les langues prises en charge sont actifs par défaut.

## Comment le code est choisi

Pour chaque nouveau message, les étapes suivantes sont essayées dans l’ordre :

1. **Règles :** essayées dans l’ordre de la liste dans Réglages → Règles ; la première correspondance détermine le code. Inutile de connaître les regex ; voir « Règles à partir d’un SMS d’exemple » ci-dessous.

   La règle par défaut ci-dessous est ajoutée à la liste une seule fois, au premier lancement. Comme toute autre règle, elle peut être modifiée et supprimée ; une règle supprimée ne revient pas d’elle-même et peut être restaurée avec **Restaurer les règles par défaut supprimées**.

   | Règle | Expéditeur | Regex | Pourquoi |
   |---|---|---|---|
   | GİB e-Arşiv | `GIB` | `SIFRENIZ:\s*([A-Z0-9]{4,8})\b` | Les mots de passe des factures e-Arşiv font 6 caractères et contiennent des lettres ; certains ne comportent que des lettres |

2. **Mots-clés :** si l’un des mots-clés apparaît dans le message, les nombres de 4 à 8 chiffres ou de la forme `123 456` deviennent des candidats. Les mots-clés par défaut couvrent toutes les langues prises en charge : `kod, şifre, parola, doğrulama, otp, code, password, passcode, código, codice, şifrə, код, пароль, رمز, کد, 验证码, 动态码, コード, 인증`.
   - **Écartés :** les parties de dates, d’heures et de montants ; les groupes de numéros de téléphone et d’IBAN ; les montants suivis d’une devise comme `TL`, `₺` ou `USD` ; les formules liées aux cartes comme « ile biten » et « son 4 hanesi » ; les numéros de commande après « no: » ; les numéros de désinscription des campagnes (« 3340'e RET yaz », « OBRET->3340 »).
   - Parmi les candidats restants, celui le plus proche d’un mot-clé l’emporte. En cas d’égalité, celui situé après le mot-clé est privilégié.

Le code est copié dans le presse-papiers et une notification s’affiche. Les messages de plus de 10 minutes, comme ceux synchronisés à la sortie de veille, sont ignorés.

### Règles à partir d’un SMS d’exemple

Si le code d’un expéditeur n’est pas détecté, allez dans Réglages → Règles → **Créer une règle à partir d’un SMS d’exemple…** :

1. Saisissez le nom de l’expéditeur, par exemple `GIB`.
2. Collez le SMS complet.
3. Sélectionnez à la souris la partie à copier.

CodeCatcher écrit la règle lui-même :
- Les mots fixes situés avant le code servent d’ancre ; s’il n’y en a pas, ce sont les mots situés après le code qui sont utilisés.
- Le code est remplacé par un motif qui correspond à sa forme : uniquement des chiffres, ou des lettres et des chiffres, de longueur similaire.
- Avant l’enregistrement, la règle est testée sur le SMS d’exemple. Si elle ne capture pas exactement le code sélectionné, elle ne peut pas être enregistrée.

Par exemple, sélectionner `4DAR7Q` dans `… SMS SIFRENIZ: 4DAR7Q B001` produit une règle qui commence par `SMS\s+SIFRENIZ\s*:\s*([A-Z0-9]{4,8})`. Elle détecte aussi les mots de passe composés uniquement de lettres, comme `ZPQRTT`. La regex générée est affichée dans la fenêtre et peut être modifiée à la main en développant la règle dans la liste.

Dans l’onglet **Essayer**, vous pouvez coller un SMS et voir instantanément quel code et quelle règle seraient choisis ; vous pouvez aussi y créer une règle.

## Tester avec de vrais messages

```bash
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100          # digits masked
~/Applications/CodeCatcher.app/Contents/MacOS/CodeCatcher --dry-run 100 --plain  # as is
```

Cette commande analyse les N derniers messages reçus et affiche pour chacun le code choisi et sa source, en marquant la position du code dans le texte avec `⟦CODE⟧`. Rien n’est copié. Votre terminal a besoin de l’accès complet au disque.

## Développement

GitHub Actions exécute `swift test` à chaque push et pull request.

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

**Traductions :** les clés sont les chaînes anglaises de `Sources/`. Pour ajouter ou modifier une chaîne, mettez à jour `en.lproj` et toutes les autres langues ; `LocalizationTests` échoue si une clé ou un espace réservé `%@` manque. Les corrections de locuteurs natifs sont vivement appréciées.

## Confidentialité

Les messages sont lus uniquement depuis `chat.db` sur ce Mac, en lecture seule. Rien n’est envoyé sur le réseau ni écrit sur le disque. Tous les SMS des tests sont inventés.

Le code détecté est copié dans le presse-papiers ; les apps d’historique du presse-papiers enregistreront donc aussi ces codes.

## Soutien

CodeCatcher est gratuit. Si vous souhaitez soutenir son développement, vous pouvez devenir sponsor sur [GitHub Sponsors](https://github.com/sponsors/sineld). Ajouter une étoile au dépôt et signaler des problèmes aide aussi.

## Licence

[MIT](../LICENSE)

## Développeur

Sinan Eldem · [sinan@sinaneldem.tr](mailto:sinan@sinaneldem.tr) · [sinaneldem.tr](https://sinaneldem.tr)
