import { Platform } from 'react-native';

// A friendly, accurate label for the "last synced from ___" line on the web.
// Never assume iPhone: iOS distinguishes iPhone vs iPad via the interface idiom,
// and Android reports its own model (falling back to a neutral label).
export function deviceLabel(): string {
  if (Platform.OS === 'ios') {
    const idiom = (Platform.constants as { interfaceIdiom?: string } | undefined)?.interfaceIdiom;
    return idiom === 'pad' ? 'iPad' : 'iPhone';
  }
  if (Platform.OS === 'android') {
    const model = (Platform.constants as { Model?: string } | undefined)?.Model;
    return model ? String(model) : 'Android phone';
  }
  return 'device';
}
