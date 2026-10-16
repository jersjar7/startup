#!/usr/bin/env bash
# Runs the simulator checks in integration_test/ (see
# docs/mobile/TEST-JOURNEYS.md). Since iOS 26 a simulator holds no scheduled
# notification for an app that is not allowed to show them, and every
# `flutter test` run reinstalls the app, which drops the permission. So it is
# granted again right before each file runs.
#
#   scripts/device-tests.sh [simulator id]   (default: the first booted iPhone)
#
# Needs applesimutils: brew trust --formula wix/brew/applesimutils &&
# brew install wix/brew/applesimutils
set -euo pipefail
cd "$(dirname "$0")/.."

sim="${1:-$(xcrun simctl list devices booted | grep -m1 -oE 'iPhone[^(]*\(([0-9A-F-]{36})\)' | grep -oE '[0-9A-F-]{36}')}"
if [[ -z "$sim" ]]; then
  echo "No booted iPhone simulator. Boot one, or pass its id." >&2
  exit 1
fi

status=0
for f in integration_test/daily_device_test.dart integration_test/notifications_test.dart; do
  applesimutils --byId "$sim" --bundle com.fe4raccoons.mobile \
    --setPermissions notifications=YES >/dev/null
  echo "==> $f"
  flutter test "$f" -d "$sim" || status=1
done
exit $status
