import type { UseCase } from './UseCase';
import type { Account } from '../entities/account';
import type { AccountRepository } from '../repositories/AccountRepository';
import type { DiagnosticRepository } from '../repositories/DiagnosticRepository';

export interface SignInInput {
  readonly email: string;
  readonly password: string;
}

export interface SignInResult {
  readonly account: Account;
  /** True when server familiarity was imported — the mobile diagnostic is skipped. */
  readonly importedFamiliarity: boolean;
}

// Sign in with the fe4raccoons account and import the one-time seed: the
// web diagnostic's per-chapter familiarity. Keep-max merge so a stronger
// local signal is never downgraded (sync-design.md).
export class SignIn implements UseCase<SignInInput, SignInResult> {
  constructor(
    private readonly accounts: AccountRepository,
    private readonly diagnostics: DiagnosticRepository,
  ) {}

  async execute({ email, password }: SignInInput): Promise<SignInResult> {
    const account = await this.accounts.signIn(email, password);

    const remote = await this.accounts.fetchRemoteFamiliarity().catch(() => ({}) as Record<string, number>);
    const hasRemote = Object.keys(remote).length > 0;
    if (hasRemote) {
      const local = await this.diagnostics.getFamiliarity();
      const merged: Record<string, number> = { ...local };
      for (const [ch, v] of Object.entries(remote)) {
        merged[ch] = Math.max(merged[ch] ?? 0, v);
      }
      await this.diagnostics.save(merged);
    }
    return { account, importedFamiliarity: hasRemote };
  }
}
