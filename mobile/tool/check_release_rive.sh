#!/bin/bash
# Run after `flutter build ipa`, before uploading. Fails if the archived app
# has lost the names Dart uses to reach the Rive engine, which makes every
# Rive artwork fall back to its still drawing on a real phone.
set -e
cd "$(dirname "$0")/.."
app=build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app/Runner
dsym=build/ios/archive/Runner.xcarchive/dSYMs/Runner.app.dSYM/Contents/Resources/DWARF/Runner
lib=$(find "$HOME/.pub-cache/hosted/pub.dev" -maxdepth 1 -name 'rive_native-*' | sort | tail -1)/lib
exports=$(mktemp); used=$(mktemp)
dyld_info -exports "$app" | awk '{print $NF}' | sort -u > "$exports"
grep -rhoE "'[a-zA-Z][a-zA-Z0-9_]+'" "$lib" | tr -d "'" | sort -u |
  while read -r s; do nm "$dsym" | grep -q " T _$s$" && echo "_$s"; done > "$used" || true
missing=$(comm -23 <(sort -u "$used") "$exports" | wc -l | tr -d ' ')
count=$(wc -l < "$used" | tr -d ' ')
rm -f "$exports" "$used"
if [ "$count" -eq 0 ] || [ "$missing" -ne 0 ]; then
  echo "RIVE_RELEASE_BAD: $missing of $count Rive names are not reachable"; exit 1
fi
echo "RIVE_RELEASE_OK: all $count Rive names reachable"
