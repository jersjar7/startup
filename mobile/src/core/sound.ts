// A tiny sound controller, mirrored on `haptics`. UI calls correct()/incorrect()
// synchronously; the concrete engine and the on/off flag are injected at startup
// from the composition root, so this module stays free of infrastructure.

export interface SoundEngine {
  correct(): void;
  incorrect(): void;
}

let engine: SoundEngine | null = null;
let enabled = false;

export const sound = {
  // Called once from the DI root with the platform engine + persisted flag.
  configure(soundEngine: SoundEngine, isEnabled: boolean) {
    engine = soundEngine;
    enabled = isEnabled;
  },
  setEnabled(value: boolean) {
    enabled = value;
  },
  correct() {
    if (enabled && engine) engine.correct();
  },
  incorrect() {
    if (enabled && engine) engine.incorrect();
  },
};
