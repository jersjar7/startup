import type { UseCase } from './UseCase';
import type { Account } from '../entities/account';
import type { AccountRepository } from '../repositories/AccountRepository';

export class GetAccount implements UseCase<void, Account | null> {
  constructor(private readonly accounts: AccountRepository) {}
  execute(): Promise<Account | null> {
    return this.accounts.getAccount();
  }
}
