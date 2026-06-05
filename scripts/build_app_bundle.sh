#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/.build"
BUNDLE_DIR="$ROOT_DIR/dist/ClipboardManager.app"
CONTENTS_DIR="$BUNDLE_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

mkdir -p "$ROOT_DIR/.home" "$BUILD_DIR/ModuleCache"

export HOME="$ROOT_DIR/.home"
export CLANG_MODULE_CACHE_PATH="$BUILD_DIR/ModuleCache"

cd "$ROOT_DIR"
swift build -c release --product ClipboardManagerApp --scratch-path "$BUILD_DIR"

rm -rf "$BUNDLE_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

cp "$ROOT_DIR/AppBundle/Info.plist" "$CONTENTS_DIR/Info.plist"
cp "$ROOT_DIR/AppBundle/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
cp "$BUILD_DIR/arm64-apple-macosx/release/ClipboardManagerApp" "$MACOS_DIR/ClipboardManagerApp"
chmod +x "$MACOS_DIR/ClipboardManagerApp"

echo "$BUNDLE_DIR"
