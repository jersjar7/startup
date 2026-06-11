import { Platform } from 'react-native';
import * as SecureStore from 'expo-secure-store';
import AsyncStorage from '@react-native-async-storage/async-storage';

const KEY = 'fe4r.auth.token';

// Auth token storage: hardware-backed keychain on device; AsyncStorage
// fallback on web (Expo web is our verification harness, not a product surface).
export class SecureTokenStore {
  async get(): Promise<string | null> {
    if (Platform.OS === 'web') return AsyncStorage.getItem(KEY);
    return SecureStore.getItemAsync(KEY);
  }

  async set(token: string): Promise<void> {
    if (Platform.OS === 'web') return AsyncStorage.setItem(KEY, token);
    return SecureStore.setItemAsync(KEY, token);
  }

  async clear(): Promise<void> {
    if (Platform.OS === 'web') return AsyncStorage.removeItem(KEY);
    return SecureStore.deleteItemAsync(KEY);
  }
}
