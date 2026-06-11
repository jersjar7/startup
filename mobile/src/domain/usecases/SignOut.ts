import type { UseCase } from './UseCase';
import type { AccountRepository } from '../repositories/AccountRepository';

// Signs out of the account. Local progress stays on the device — signing out
// is about identity, never about destroying work.
export class SignOut implements UseCase<void, void> {
  constructor(private readonly accounts: AccountRepository) {}
  execute(): Promise<void> {
    return this.accounts.signOut();
  }
}
