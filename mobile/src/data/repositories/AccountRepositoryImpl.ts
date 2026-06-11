import type { Account } from '@/domain/entities/account';
import type { AccountRepository } from '@/domain/repositories/AccountRepository';
import type { KeyValueStore } from '../sources/storage/KeyValueStore';
import type { SecureTokenStore } from '../sources/storage/SecureTokenStore';
import type { ApiClient } from '../sources/api/ApiClient';

const ACCOUNT_KEY = 'account:profile';

interface LoginResponse {
  email: string;
  displayName: string;
  examDate: string | null;
  token?: string;
}

interface MasteryResponse {
  chapterMastery: Record<string, { totalMastery?: number }>;
}

export class AccountRepositoryImpl implements AccountRepository {
  constructor(
    private readonly api: ApiClient,
    private readonly tokens: SecureTokenStore,
    private readonly store: KeyValueStore,
  ) {}

  async signIn(email: string, password: string): Promise<Account> {
    const res = await this.api.request<LoginResponse>('POST', '/api/auth/login', { email, password });
    if (res.token) await this.tokens.set(res.token);
    const account: Account = {
      email: res.email,
      displayName: res.displayName,
      examDate: res.examDate ?? null,
    };
    await this.store.set(ACCOUNT_KEY, JSON.stringify(account));
    return account;
  }

  async getAccount(): Promise<Account | null> {
    const raw = await this.store.get(ACCOUNT_KEY);
    if (!raw) return null;
    try {
      return JSON.parse(raw) as Account;
    } catch {
      return null;
    }
  }

  async signOut(): Promise<void> {
    // Best-effort server-side token invalidation; local sign-out always wins.
    await this.api.request('DELETE', '/api/auth/logout').catch(() => undefined);
    await this.tokens.clear();
    await this.store.remove(ACCOUNT_KEY);
  }

  async fetchRemoteFamiliarity(): Promise<Record<string, number>> {
    const res = await this.api.request<MasteryResponse>('GET', '/api/diagnostic/mastery');
    const familiarity: Record<string, number> = {};
    for (const [chapterId, m] of Object.entries(res.chapterMastery ?? {})) {
      const pct = m?.totalMastery ?? 0;
      if (pct > 0) familiarity[chapterId] = Math.min(1, pct / 100);
    }
    return familiarity;
  }
}
