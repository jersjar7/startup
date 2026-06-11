// Domain PORT for scheduling a daily study reminder. Implemented in data/ via
// expo-notifications (a no-op on web).
export interface ReminderScheduler {
  requestPermission(): Promise<boolean>;
  scheduleDaily(hour: number): Promise<void>;
  cancel(): Promise<void>;
}
