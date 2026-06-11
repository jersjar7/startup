import type { UseCase } from './UseCase';
import type { SoundRepository } from '../repositories/SoundRepository';

export class GetSoundEnabled implements UseCase<void, boolean> {
  constructor(private readonly sounds: SoundRepository) {}
  execute(): Promise<boolean> {
    return this.sounds.getEnabled();
  }
}
