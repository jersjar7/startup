import { Platform } from 'react-native';
import * as Notifications from 'expo-notifications';
import type { ReminderScheduler } from '@/domain/services/ReminderScheduler';

// Local daily notification via expo-notifications. No-op on web (unsupported).
export class ExpoReminderScheduler implements ReminderScheduler {
  async requestPermission(): Promise<boolean> {
    if (Platform.OS === 'web') return false;
    const { status } = await Notifications.requestPermissionsAsync();
    return status === 'granted';
  }

  async scheduleDaily(hour: number): Promise<void> {
    if (Platform.OS === 'web') return;
    await Notifications.cancelAllScheduledNotificationsAsync();
    await Notifications.scheduleNotificationAsync({
      content: {
        title: 'Time to study',
        body: 'A few minutes keeps your streak — and your mastery — moving.',
      },
      trigger: {
        type: Notifications.SchedulableTriggerInputTypes.DAILY,
        hour,
        minute: 0,
      },
    });
  }

  async cancel(): Promise<void> {
    if (Platform.OS === 'web') return;
    await Notifications.cancelAllScheduledNotificationsAsync();
  }
}
