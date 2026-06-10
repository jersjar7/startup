import type { UseCase } from './UseCase';
import type { Mastery } from '../entities/mastery';
import type { MasteryRepository } from '../repositories/MasteryRepository';

export class GetOverallMastery implements UseCase<void, Mastery> {
  constructor(private readonly mastery: MasteryRepository) {}
  execute(): Promise<Mastery> {
    return this.mastery.overall();
  }
}
