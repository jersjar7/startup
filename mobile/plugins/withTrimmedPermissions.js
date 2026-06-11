const { withAndroidManifest } = require('expo/config-plugins');

// Expo's Android template declares SYSTEM_ALERT_WINDOW ("draw over other apps")
// by default. This app never draws overlays, so strip it from the released
// manifest — keeps permissions to exactly what we use and avoids Play review
// questions. (It stays in the debug source set, so the RN dev menu still works.)
const REMOVE = ['android.permission.SYSTEM_ALERT_WINDOW'];

module.exports = function withTrimmedPermissions(config) {
  return withAndroidManifest(config, (cfg) => {
    const manifest = cfg.modResults.manifest;
    if (Array.isArray(manifest['uses-permission'])) {
      manifest['uses-permission'] = manifest['uses-permission'].filter(
        (p) => !REMOVE.includes(p.$?.['android:name']),
      );
    }
    return cfg;
  });
};
