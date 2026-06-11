// PORT: whether answer tick sounds are on. Defaults to on when never set.
export interface SoundRepository {
  getEnabled(): Promise<boolean>;
  setEnabled(value: boolean): Promise<void>;
}
