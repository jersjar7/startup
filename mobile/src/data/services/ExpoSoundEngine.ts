import { Platform } from 'react-native';
import { createAudioPlayer, type AudioPlayer } from 'expo-audio';
import type { SoundEngine } from '@/core/sound';

// Plays the short tick samples. No-op on web (autoplay policies + the verify
// loop). Each player is created once and rewound on play so taps feel instant.
export class ExpoSoundEngine implements SoundEngine {
  private correctPlayer: AudioPlayer | null = null;
  private incorrectPlayer: AudioPlayer | null = null;

  constructor() {
    if (Platform.OS === 'web') return;
    try {
      this.correctPlayer = createAudioPlayer(require('../../../assets/sounds/correct.wav'));
      this.incorrectPlayer = createAudioPlayer(require('../../../assets/sounds/incorrect.wav'));
      this.correctPlayer.volume = 0.5;
      this.incorrectPlayer.volume = 0.5;
    } catch {
      // Audio unavailable on this device — stay silent rather than crash.
    }
  }

  correct() {
    this.replay(this.correctPlayer);
  }

  incorrect() {
    this.replay(this.incorrectPlayer);
  }

  private replay(player: AudioPlayer | null) {
    if (!player) return;
    try {
      player.seekTo(0);
      player.play();
    } catch {
      // Ignore transient playback hiccups.
    }
  }
}
