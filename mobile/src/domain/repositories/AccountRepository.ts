import type { Account } from '../entities/account';

// PORT for the fe4raccoons account. Progress sync will get its own port; this
// covers identity plus the one-time profile/familiarity import at sign-in.
export interface AccountRepository {
  signIn(email: string, password: string): Promise<Account>;
  getAccount(): Promise<Account | null>;
  signOut(): Promise<void>;
  /** Server chapter mastery mapped to 0–1 familiarity (empty if no diagnostic). */
  fetchRemoteFamiliarity(): Promise<Record<string, number>>;
  /** Server chapter mastery as PERCENT per chapter — the shared number. */
  fetchRemoteMastery(): Promise<Record<string, number>>;
  /** Write profile fields back to the website account. */
  updateProfile(fields: { examDate?: string }): Promise<void>;
  /** Permanently delete the website account (server-side, all collections). */
  deleteAccount(): Promise<void>;
}
