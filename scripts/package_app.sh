#!/usr/bin/env zsh
set -euo pipefail

APP_NAME="Chargi"
IDENTIFIER="app.chargi"
VERSION="1.0"
BUILD_DIR="build"
BUNDLE_DIR="dist/${APP_NAME}.app"
SCHEME="${SCHEME:-Chargi}"
CONFIGURATION="${CONFIGURATION:-Release}"
PROJECT="${PROJECT:-}"
WORKSPACE="${WORKSPACE:-}"

mkdir -p "$BUILD_DIR"
mkdir -p "dist"
mkdir -p "Resources"

# Prepare AppIcon.icns from assets if available
function prepare_icons() {
  local SRC_APPICONSET="Assets.xcassets/AppIcon.appiconset"
  local SRC_ICONSET_ALT="Assets/AppIcon.iconset"
  local SRC_APPICONSET_ROOT="AppIcon.appiconset"
  local DEST_ICONSET="Resources/AppIcon.iconset"
  rm -rf "$DEST_ICONSET"
  mkdir -p "$DEST_ICONSET"
  if [[ -d "$SRC_APPICONSET_ROOT" ]]; then
    [[ -f "$SRC_APPICONSET_ROOT/icon-16.png" ]] && cp -f "$SRC_APPICONSET_ROOT/icon-16.png" "$DEST_ICONSET/icon_16x16.png"
    [[ -f "$SRC_APPICONSET_ROOT/icon-32.png" ]] && {
      cp -f "$SRC_APPICONSET_ROOT/icon-32.png" "$DEST_ICONSET/icon_16x16@2x.png"
      cp -f "$SRC_APPICONSET_ROOT/icon-32.png" "$DEST_ICONSET/icon_32x32.png"
    }
    [[ -f "$SRC_APPICONSET_ROOT/icon-64.png" ]] && cp -f "$SRC_APPICONSET_ROOT/icon-64.png" "$DEST_ICONSET/icon_32x32@2x.png"
    [[ -f "$SRC_APPICONSET_ROOT/icon-128.png" ]] && cp -f "$SRC_APPICONSET_ROOT/icon-128.png" "$DEST_ICONSET/icon_128x128.png"
    [[ -f "$SRC_APPICONSET_ROOT/icon-256.png" ]] && {
      cp -f "$SRC_APPICONSET_ROOT/icon-256.png" "$DEST_ICONSET/icon_128x128@2x.png"
      cp -f "$SRC_APPICONSET_ROOT/icon-256.png" "$DEST_ICONSET/icon_256x256.png"
    }
    [[ -f "$SRC_APPICONSET_ROOT/icon-512.png" ]] && {
      cp -f "$SRC_APPICONSET_ROOT/icon-512.png" "$DEST_ICONSET/icon_256x256@2x.png"
      cp -f "$SRC_APPICONSET_ROOT/icon-512.png" "$DEST_ICONSET/icon_512x512.png"
    }
    [[ -f "$SRC_APPICONSET_ROOT/icon-1024.png" ]] && cp -f "$SRC_APPICONSET_ROOT/icon-1024.png" "$DEST_ICONSET/icon_512x512@2x.png"
    [[ -f "$SRC_APPICONSET_ROOT/16.png" ]] && cp -f "$SRC_APPICONSET_ROOT/16.png" "$DEST_ICONSET/icon_16x16.png"
    [[ -f "$SRC_APPICONSET_ROOT/32.png" ]] && {
      cp -f "$SRC_APPICONSET_ROOT/32.png" "$DEST_ICONSET/icon_16x16@2x.png"
      cp -f "$SRC_APPICONSET_ROOT/32.png" "$DEST_ICONSET/icon_32x32.png"
    }
    [[ -f "$SRC_APPICONSET_ROOT/64.png" ]] && cp -f "$SRC_APPICONSET_ROOT/64.png" "$DEST_ICONSET/icon_32x32@2x.png"
    [[ -f "$SRC_APPICONSET_ROOT/128.png" ]] && cp -f "$SRC_APPICONSET_ROOT/128.png" "$DEST_ICONSET/icon_128x128.png"
    [[ -f "$SRC_APPICONSET_ROOT/256.png" ]] && {
      cp -f "$SRC_APPICONSET_ROOT/256.png" "$DEST_ICONSET/icon_128x128@2x.png"
      cp -f "$SRC_APPICONSET_ROOT/256.png" "$DEST_ICONSET/icon_256x256.png"
    }
    [[ -f "$SRC_APPICONSET_ROOT/512.png" ]] && {
      cp -f "$SRC_APPICONSET_ROOT/512.png" "$DEST_ICONSET/icon_256x256@2x.png"
      cp -f "$SRC_APPICONSET_ROOT/512.png" "$DEST_ICONSET/icon_512x512.png"
    }
    [[ -f "$SRC_APPICONSET_ROOT/1024.png" ]] && cp -f "$SRC_APPICONSET_ROOT/1024.png" "$DEST_ICONSET/icon_512x512@2x.png"
    [[ -f "$SRC_APPICONSET_ROOT/Icon-16.png" ]] && cp -f "$SRC_APPICONSET_ROOT/Icon-16.png" "$DEST_ICONSET/icon_16x16.png"
    [[ -f "$SRC_APPICONSET_ROOT/Icon-32.png" ]] && {
      cp -f "$SRC_APPICONSET_ROOT/Icon-32.png" "$DEST_ICONSET/icon_16x16@2x.png"
      cp -f "$SRC_APPICONSET_ROOT/Icon-32.png" "$DEST_ICONSET/icon_32x32.png"
    }
    [[ -f "$SRC_APPICONSET_ROOT/Icon-64.png" ]] && cp -f "$SRC_APPICONSET_ROOT/Icon-64.png" "$DEST_ICONSET/icon_32x32@2x.png"
    [[ -f "$SRC_APPICONSET_ROOT/Icon-128.png" ]] && cp -f "$SRC_APPICONSET_ROOT/Icon-128.png" "$DEST_ICONSET/icon_128x128.png"
    [[ -f "$SRC_APPICONSET_ROOT/Icon-256.png" ]] && {
      cp -f "$SRC_APPICONSET_ROOT/Icon-256.png" "$DEST_ICONSET/icon_128x128@2x.png"
      cp -f "$SRC_APPICONSET_ROOT/Icon-256.png" "$DEST_ICONSET/icon_256x256.png"
    }
    [[ -f "$SRC_APPICONSET_ROOT/Icon-512.png" ]] && {
      cp -f "$SRC_APPICONSET_ROOT/Icon-512.png" "$DEST_ICONSET/icon_256x256@2x.png"
      cp -f "$SRC_APPICONSET_ROOT/Icon-512.png" "$DEST_ICONSET/icon_512x512.png"
    }
    [[ -f "$SRC_APPICONSET_ROOT/Icon-1024.png" ]] && cp -f "$SRC_APPICONSET_ROOT/Icon-1024.png" "$DEST_ICONSET/icon_512x512@2x.png"
  elif [[ -d "$SRC_APPICONSET" ]]; then
    find "$SRC_APPICONSET" -maxdepth 1 -name 'icon_*.png' -exec cp -f {} "$DEST_ICONSET/" \; 2>/devnull || true
  elif [[ -d "$SRC_ICONSET_ALT" ]]; then
    find "$SRC_ICONSET_ALT" -maxdepth 1 -name 'icon_*.png' -exec cp -f {} "$DEST_ICONSET/" \; 2>/dev/null || true
  fi
  if find "$DEST_ICONSET" -maxdepth 1 -name 'icon_*.png' | grep -q .; then
    iconutil -c icns "$DEST_ICONSET" -o Resources/AppIcon.icns || true
    return
  fi
  swift scripts/make_icns.swift || true
  iconutil -c icns "$DEST_ICONSET" -o Resources/AppIcon.icns || true
}

prepare_icons

if ls *.xcodeproj >/dev/null 2>&1 || ls *.xcworkspace >/dev/null 2>&1 || [[ -n "$PROJECT$WORKSPACE" ]]; then
  if [[ -z "$WORKSPACE" ]] && ls *.xcworkspace >/dev/null 2>&1; then
    WORKSPACE=$(ls *.xcworkspace | head -n 1)
  fi
  if [[ -z "$PROJECT" ]] && [[ -z "$WORKSPACE" ]]; then
    PROJECT=$(ls *.xcodeproj | head -n 1)
  fi
  if [[ -n "$WORKSPACE" ]]; then
    xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -configuration "$CONFIGURATION" -derivedDataPath "$BUILD_DIR/XcodeDerived" clean build >/dev/null
  else
    xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration "$CONFIGURATION" -derivedDataPath "$BUILD_DIR/XcodeDerived" clean build >/dev/null
  fi
  PRODUCTS="$BUILD_DIR/XcodeDerived/Build/Products/$CONFIGURATION"
  APP_PATH="$PRODUCTS/${APP_NAME}.app"
  mkdir -p "dist"
  DMG_DIR="dist/dmg_root"
  DMG_NAME="${APP_NAME}.dmg"
  rm -rf "$DMG_DIR"
  mkdir -p "$DMG_DIR/${APP_NAME}.app/Contents/PlugIns"
  cp -R "$APP_PATH" "$DMG_DIR/${APP_NAME}.app"
  for APPEX in $(find "$PRODUCTS" -name "*.appex" -maxdepth 2); do
    cp -R "$APPEX" "$DMG_DIR/${APP_NAME}.app/Contents/PlugIns/"
  done
  ln -sf /Applications "$DMG_DIR/Applications"
  hdiutil create -volname "$APP_NAME" -srcfolder "$DMG_DIR" -ov -format UDZO "dist/$DMG_NAME" >/dev/null
  echo "Packaged app at: $APP_PATH"
  echo "DMG created at: dist/$DMG_NAME"
  exit 0
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
