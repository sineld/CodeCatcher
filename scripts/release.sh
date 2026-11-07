#!/bin/bash
# Usage: CODESIGN_IDENTITY="Developer ID Application: …" NOTARY_KEY_ID=… NOTARY_ISSUER=… scripts/release.sh
# Builds build/CodeCatcher-<version>.dmg: Developer ID signed, notarized by Apple and stapled.
# Notarization uses an App Store Connect API key (NOTARY_KEY_PATH defaults to the usual .p8 location).
set -euo pipefail
cd "$(dirname "$0")/.."

: "${CODESIGN_IDENTITY:?set CODESIGN_IDENTITY to a Developer ID Application identity}"
: "${NOTARY_KEY_ID:?set NOTARY_KEY_ID}"
: "${NOTARY_ISSUER:?set NOTARY_ISSUER}"
NOTARY_KEY_PATH="${NOTARY_KEY_PATH:-$HOME/.appstoreconnect/private_keys/AuthKey_${NOTARY_KEY_ID}.p8}"
[[ "$CODESIGN_IDENTITY" == "Developer ID Application:"* ]] || { echo "error: notarization needs a Developer ID Application identity" >&2; exit 1; }

notarize() {
    xcrun notarytool submit "$1" --wait --key "$NOTARY_KEY_PATH" --key-id "$NOTARY_KEY_ID" --issuer "$NOTARY_ISSUER"
}

export CODESIGN_IDENTITY
scripts/build-app.sh

APP=build/CodeCatcher.app
VERSION=$(plutil -extract CFBundleShortVersionString raw Resources/Info.plist)
DMG="build/CodeCatcher-$VERSION.dmg"
STAGE=$(mktemp -d)
RW_DMG="$STAGE.dmg"
trap 'rm -rf "$STAGE" "$RW_DMG"' EXIT

# Notarize and staple the app itself, so it also opens offline once copied out of the DMG.
ditto -c -k --keepParent "$APP" "$STAGE/notarize.zip"
notarize "$STAGE/notarize.zip"
rm "$STAGE/notarize.zip"
xcrun stapler staple "$APP"

# DMG with a drag-to-Applications window (layout matches scripts/make-dmg-background.swift).
ditto "$APP" "$STAGE/CodeCatcher.app"
ln -s /Applications "$STAGE/Applications"
mkdir "$STAGE/.background"
cp Resources/dmg-background.png "$STAGE/.background/background.png"
chflags hidden "$STAGE/.background"

if [[ -d /Volumes/CodeCatcher ]]; then hdiutil detach /Volumes/CodeCatcher -force; fi
hdiutil create -quiet -volname CodeCatcher -srcfolder "$STAGE" -fs HFS+ -format UDRW -ov "$RW_DMG"
DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "$RW_DMG" | awk '/^\/dev\// {print $1; exit}')

osascript <<'EOF'
tell application "Finder"
    tell disk "CodeCatcher"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        -- 660×440 background plus ~70 pt for the toolbar newer Finders keep showing; extra space below is white.
        set the bounds of container window to {200, 120, 860, 630}
        set opts to the icon view options of container window
        set arrangement of opts to not arranged
        set icon size of opts to 128
        set text size of opts to 13
        set background picture of opts to file ".background:background.png"
        set position of item "CodeCatcher.app" of container window to {180, 220}
        set position of item "Applications" of container window to {480, 220}
        set extension hidden of item "CodeCatcher.app" to true
        -- park dot-items outside the window for people who show hidden files
        try
            set position of item ".background" of container window to {900, 900}
        end try
        try
            set position of item ".fseventsd" of container window to {1000, 900}
        end try
        close
        open
        update without registering applications
        delay 2
        close
    end tell
end tell
EOF

sync
hdiutil detach "$DEVICE" -quiet
rm -f "$DMG"
hdiutil convert "$RW_DMG" -quiet -format UDZO -imagekey zlib-level=9 -o "$DMG"

codesign --force --timestamp --sign "$CODESIGN_IDENTITY" "$DMG"
notarize "$DMG"
xcrun stapler staple "$DMG"
spctl --assess --type open --context context:primary-signature "$DMG"
echo "ready: $DMG (sha256 $(shasum -a 256 "$DMG" | cut -d' ' -f1))"
