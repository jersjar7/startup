// PORT for persistence. Implemented by AsyncStorage (device) or in-memory (tests).
export interface KeyValueStore {
  get(key: string): Promise<string | null>;
  set(key: string, value: string): Promise<void>;
  remove(key: string): Promise<void>;
}
