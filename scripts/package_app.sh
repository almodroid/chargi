#!/usr/bin/env zsh
set -euo pipefail

APP_NAME="Chargi"
IDENTIFIER="app.chargi"
VERSION="1.0"
BUILD_DIR="build"
BUNDLE_DIR="dist/${APP_NAME}.app"

mkdir -p "$BUILD_DIR"
mkdir -p "dist"
mkdir -p "Resources"
if [[ ! -f Resources/AppIcon.icns ]]; then
  swiftc scripts/make_icns.swift ChargiApp/IconFactory.swift -framework AppKit -o "$BUILD_DIR/make_icns"
  "$BUILD_DIR/make_icns"
  iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns || true
fi

swiftc Standalone/main.swift Standalone/StandaloneMain.swift \
  ChargiApp/Preferences.swift ChargiApp/BatteryService.swift \
  ChargiApp/StatusBarController.swift ChargiApp/FloatingBubble.swift \
  ChargiApp/IconFactory.swift \
  -framework AppKit -framework IOKit -framework SwiftUI \
  -o "$BUILD_DIR/${APP_NAME}"

rm -rf "$BUNDLE_DIR"
mkdir -p "$BUNDLE_DIR/Contents/MacOS"
mkdir -p "$BUNDLE_DIR/Contents/Resources"

cat > "$BUNDLE_DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>Chargi</string>
  <key>CFBundleIdentifier</key><string>app.chargi</string>
  <key>CFBundleExecutable</key><string>Chargi</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>LSMinimumSystemVersion</key><string>11.0</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST

cp "$BUILD_DIR/${APP_NAME}" "$BUNDLE_DIR/Contents/MacOS/${APP_NAME}"

if [[ -f Resources/AppIcon.icns ]]; then
  cp Resources/AppIcon.icns "$BUNDLE_DIR/Contents/Resources/AppIcon.icns"
fi

chmod +x "$BUNDLE_DIR/Contents/MacOS/${APP_NAME}"

codesign --force --deep --sign - "$BUNDLE_DIR" || true

# Create DMG
DMG_DIR="dist/dmg_root"
DMG_NAME="Chargi.dmg"
rm -rf "$DMG_DIR"
mkdir -p "$DMG_DIR"
cp -R "$BUNDLE_DIR" "$DMG_DIR/Chargi.app"
ln -sf /Applications "$DMG_DIR/Applications"
hdiutil create -volname "Chargi" -srcfolder "$DMG_DIR" -ov -format UDZO "dist/$DMG_NAME" >/dev/null

echo "Packaged app at: $BUNDLE_DIR"
echo "DMG created at: dist/$DMG_NAME"
echo "Run: open '$BUNDLE_DIR'"
