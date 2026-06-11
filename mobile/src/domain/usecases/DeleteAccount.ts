import type { UseCase } from './UseCase';
import type { AccountRepository } from '../repositories/AccountRepository';
import type { AppDataRepository } from '../repositories/AppDataRepository';

// Apple requires in-app account deletion wherever accounts are usable in-app.
// Deletes the website account server-side, then clears this device entirely.
export class DeleteAccount implements UseCase<void, void> {
  constructor(
    private readonly accounts: AccountRepository,
    private readonly appData: AppDataRepository,
  ) {}

  async execute(): Promise<void> {
    await this.accounts.deleteAccount();
    await this.appData.reset();
  }
}
