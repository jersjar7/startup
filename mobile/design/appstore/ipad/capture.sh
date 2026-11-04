#!/bin/sh
# Photographs the real app on a 13-inch iPad simulator, in landscape, for the
# tablet store screenshots. Writes raw 2752x2064 PNGs into shots/ beside this
# file; build.py composes the store images from them.
#
#   design/appstore/ipad/capture.sh [simulator udid] [shot,names]
#
# What it does, and why each step is here:
# - Xcode 27 has no Simulator window on this Mac, so the iPad is turned with
#   `devicectl device orientation set` (the same event as turning it).
# - The status bar is set to 9:41, full Wi-Fi and a full battery.
# - integration_test/store_shots_tablet_test.dart walks the real app (the
#   shipped code, talking to production, signed in as the QA account) and
#   prints STORE-SHOT <name> on each screen; this script photographs it with
#   `simctl io screenshot` while the test holds still.
# - The QA login is read by flutter from the gitignored secrets file and
#   never printed.
set -eu
HERE=$(cd "$(dirname "$0")" && pwd)
MOBILE=$(cd "$HERE/../../.." && pwd)
UDID=${1:-71C1CB62-04B8-4CA6-98F6-F36E208F6337}   # iPad Pro 13-inch (M5)
SHOTS=${2:-}
SECRETS=${QA_LOGIN:-$MOBILE/../../startup/secrets/qa-login.json}
[ -f "$SECRETS" ] || SECRETS=$MOBILE/../secrets/qa-login.json
OUT=$HERE/shots
LOG=$HERE/work/capture.log
mkdir -p "$OUT" "$HERE/work"

xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl bootstatus "$UDID" -b >/dev/null
xcrun simctl ui "$UDID" appearance light
xcrun devicectl device orientation set --device "$UDID" landscapeLeft >/dev/null
xcrun simctl status_bar "$UDID" override --time 9:41 --dataNetwork wifi \
  --wifiMode active --wifiBars 3 --batteryState discharging --batteryLevel 100

cd "$MOBILE"
: > "$LOG"
flutter test integration_test/store_shots_tablet_test.dart -d "$UDID" \
  --dart-define=PACKS=true --dart-define-from-file="$SECRETS" \
  --dart-define=SHOTS="$SHOTS" > "$LOG" 2>&1 &
PID=$!

seen=""
while kill -0 $PID 2>/dev/null; do
  for name in $(grep -o 'STORE-SHOT [a-z0-9-]*' "$LOG" | awk '{print $2}' | sort -u); do
    case " $seen " in *" $name "*) continue ;; esac
    seen="$seen $name"
    xcrun simctl io "$UDID" screenshot "$OUT/$name.png" >/dev/null 2>&1
    echo "photographed $name"
  done
  sleep 0.5
done
wait $PID || { tail -30 "$LOG"; exit 1; }
echo "done: $OUT"
