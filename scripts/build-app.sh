#!/bin/bash
# Kullanım: scripts/build-app.sh [--install]
# build/CodeCatcher.app üretir; --install ile ~/Applications'a kopyalayıp başlatır.
set -euo pipefail
cd "$(dirname "$0")/.."

swift build -c release
APP=build/CodeCatcher.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp .build/release/CodeCatcher "$APP/Contents/MacOS/"
cp Resources/Info.plist "$APP/Contents/"
cp Resources/AppIcon.icns "$APP/Contents/Resources/" # scripts/make-icon.swift üretir
cp -R Resources/Localizations/*.lproj "$APP/Contents/Resources/"

# Tam Disk Erişimi izni imzaya bağlıdır: ad-hoc imzada her derlemeden sonra izin yeniden verilmeli.
IDENTITY="${CODESIGN_IDENTITY:-CodeCatcher Local}"
if security find-identity -p codesigning | grep -q "\"$IDENTITY\""; then
    codesign --force --sign "$IDENTITY" "$APP"
else
    echo "uyarı: '$IDENTITY' sertifikası yok, ad-hoc imzalanıyor" >&2
    codesign --force --sign - "$APP"
fi
echo "hazır: $APP"

if [[ "${1:-}" == "--install" ]]; then
    pkill -x CodeCatcher || true
    while pgrep -x CodeCatcher >/dev/null; do sleep 0.2; done
    rm -rf ~/Applications/CodeCatcher.app
    cp -R "$APP" ~/Applications/
    for _ in 1 2 3; do open ~/Applications/CodeCatcher.app && break; sleep 1; done # LaunchServices bazen -600 verir
    echo "kuruldu: ~/Applications/CodeCatcher.app"
fi
