#!/usr/bin/env bash
set -euo pipefail
export ANDROID_HOME="${ANDROID_HOME:-$HOME/development/android-sdk}"
export PATH="$HOME/development/flutter/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

cmd="${1:-help}"
case "$cmd" in
  emulator)
    exec emulator -avd Pixel_6_API_34 -gpu swiftshader_indirect -memory 1536 -no-snapshot-load
    ;;
  devices)
    flutter devices; adb devices -l
    ;;
  run)
    flutter pub get
    flutter run -d android
    ;;
  apk)
    flutter build apk --release
    cp -f build/app/outputs/flutter-apk/app-release.apk "$HOME/Desktop/RecipeApp-release.apk"
    echo "APK: $HOME/Desktop/RecipeApp-release.apk"
    echo "Also: $ROOT/build/app/outputs/flutter-apk/app-release.apk"
    ;;
  install)
    APK="$ROOT/build/app/outputs/flutter-apk/app-release.apk"
    [ -f "$APK" ] || { echo "Build first: $0 apk"; exit 1; }
    adb wait-for-device
    adb install -r "$APK"
    ;;
  *)
    echo "Usage: $0 {emulator|devices|run|apk|install}"
    ;;
esac
