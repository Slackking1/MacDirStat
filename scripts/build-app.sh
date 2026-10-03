#!/bin/bash
# Builds a release MacDirStat.app (with Info.plist and icon) at .build/MacDirStat.app.
# Install with: cp -R .build/MacDirStat.app /Applications/
set -euo pipefail

VERSION="0.1.0"
BUNDLE_ID="io.github.phalladar.MacDirStat"

cd "$(dirname "$0")/.."
swift build -c release
BIN_DIR="$(swift build -c release --show-bin-path)"

APP=".build/MacDirStat.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp "$BIN_DIR/MacDirStat" "$APP/Contents/MacOS/"
cp Sources/MacDirStat/AppIcon.icns "$APP/Contents/Resources/"
# Bundle.module looks in Contents/Resources first, so keep SPM resources working inside the app.
cp -R "$BIN_DIR/MacDirStat_MacDirStat.bundle" "$APP/Contents/Resources/"

cat > "$APP/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>MacDirStat</string>
    <key>CFBundleDisplayName</key>
    <string>MacDirStat</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleExecutable</key>
    <string>MacDirStat</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>LSMinimumSystemVersion</key>
    <string>15.0</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.utilities</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Ad-hoc sign so the bundle's resources are sealed and the signature is valid.
codesign --force --sign - "$APP"

echo "Built $APP"
