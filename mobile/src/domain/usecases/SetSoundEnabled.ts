import type { UseCase } from './UseCase';
import type { SoundRepository } from '../repositories/SoundRepository';

export class SetSoundEnabled implements UseCase<boolean, void> {
  constructor(private readonly sounds: SoundRepository) {}
  execute(value: boolean): Promise<void> {
    return this.sounds.setEnabled(value);
  }
}
