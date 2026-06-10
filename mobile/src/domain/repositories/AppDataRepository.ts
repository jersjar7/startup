// Wipes all locally stored user data (preferences, review schedules, streak).
export interface AppDataRepository {
  reset(): Promise<void>;
}
