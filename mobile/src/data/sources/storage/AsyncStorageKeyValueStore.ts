import AsyncStorage from '@react-native-async-storage/async-storage';
import type { KeyValueStore } from './KeyValueStore';

// Device-backed persistence. All app keys are namespaced under `fe4r:`.
export class AsyncStorageKeyValueStore implements KeyValueStore {
  private key(k: string): string {
    return `fe4r:${k}`;
  }
  get(key: string): Promise<string | null> {
    return AsyncStorage.getItem(this.key(key));
  }
  set(key: string, value: string): Promise<void> {
    return AsyncStorage.setItem(this.key(key), value);
  }
  remove(key: string): Promise<void> {
    return AsyncStorage.removeItem(this.key(key));
  }
}
