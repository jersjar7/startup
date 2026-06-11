import type { Account } from '../entities/account';

// PORT for the fe4raccoons account. Progress sync will get its own port; this
// covers identity plus the one-time profile/familiarity import at sign-in.
export interface AccountRepository {
  signIn(email: string, password: string): Promise<Account>;
  getAccount(): Promise<Account | null>;
  signOut(): Promise<void>;
  /** Server chapter mastery mapped to 0–1 familiarity (empty if no diagnostic). */
  fetchRemoteFamiliarity(): Promise<Record<string, number>>;
}
