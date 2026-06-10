import type { UseCase } from './UseCase';
import type { AppDataRepository } from '../repositories/AppDataRepository';

export class ResetAllProgress implements UseCase<void, void> {
  constructor(private readonly appData: AppDataRepository) {}
  execute(): Promise<void> {
    return this.appData.reset();
  }
}
