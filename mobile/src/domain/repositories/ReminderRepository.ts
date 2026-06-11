// PORT: the user's daily reminder time, stored as minutes since local
// midnight (null = off). Minutes — not hours — because real study slots are
// "the 7:15 bus", not round numbers.
export interface ReminderRepository {
  getMinutes(): Promise<number | null>;
  setMinutes(minutes: number | null): Promise<void>;
}
