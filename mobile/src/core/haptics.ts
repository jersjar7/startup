import { Platform } from 'react-native';
import * as Haptics from 'expo-haptics';

// Tactile feedback. No-op on web. Fire-and-forget (never awaited).
const enabled = Platform.OS !== 'web';

export const haptics = {
  light: () => {
    if (enabled) void Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
  },
  medium: () => {
    if (enabled) void Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
  },
  selection: () => {
    if (enabled) void Haptics.selectionAsync();
  },
  success: () => {
    if (enabled) void Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
  },
  error: () => {
    if (enabled) void Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
  },
};
