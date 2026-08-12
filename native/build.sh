#!/bin/bash
# Build ChessTrainer.app — a native macOS wrapper for the chess trainer.
# Requires only Xcode Command Line Tools (swiftc) — no downloads, no money.
# Usage:  cd native && ./build.sh   →   produces ChessTrainer.app
set -e
cd "$(dirname "$0")"

APP="ChessTrainer.app"
BIN="Contents/MacOS/ChessTrainer"
PAGE="../index.html"

if [ ! -f "$PAGE" ]; then
  echo "✗ ../index.html not found — nothing to bundle." >&2
  exit 1
fi

echo "› Cleaning old build…"
rm -rf "$APP"

echo "› Compiling native binary (Swift + WebKit)…"
swiftc -O ChessTrainer.swift -o chess-bin -framework Cocoa -framework WebKit

echo "› Assembling app bundle…"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
mv chess-bin "$APP/$BIN"

# The page is bundled, not fetched — the engine is embedded in it and the app
# is meant to work with no network at all.
echo "› Bundling index.html ($(du -h "$PAGE" | cut -f1))…"
cp "$PAGE" "$APP/Contents/Resources/index.html"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>ChessTrainer</string>
  <key>CFBundleDisplayName</key><string>Chess Trainer</string>
  <key>CFBundleExecutable</key><string>ChessTrainer</string>
  <key>CFBundleIdentifier</key><string>com.mintaymisgano.chesstrainer</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>11.0</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSHumanReadableCopyright</key><string>© 2026 Mintay Misgano · PolyForm Noncommercial</string>
</dict>
</plist>
PLIST

# Ad-hoc sign so macOS runs a locally built, unsigned app cleanly.
codesign --force --deep --sign - "$APP" 2>/dev/null || true

echo ""
echo "✓ Built $APP"
echo "  Move it to Applications:   mv \"$APP\" /Applications/"
echo "  Rebuild after any new index.html to pick up the changes."
