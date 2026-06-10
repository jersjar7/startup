import React from 'react';
import { View } from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { useFonts, DMSans_600SemiBold, DMSans_700Bold } from '@expo-google-fonts/dm-sans';
import { Inter_400Regular, Inter_600SemiBold } from '@expo-google-fonts/inter';
import { JetBrainsMono_700Bold } from '@expo-google-fonts/jetbrains-mono';
import { ThemeProvider } from '@/core/theme/ThemeProvider';
import { palette } from '@/core/theme/tokens';
import { UseCasesProvider } from '@/di/AppContext';
import { RootGate } from '@/presentation/bootstrap/RootGate';

// Root: load brand fonts, then mount providers (theme + DI) around navigation.
// The composition root runs inside UseCasesProvider.
export default function App() {
  const [fontsLoaded] = useFonts({
    DMSans_600SemiBold,
    DMSans_700Bold,
    Inter_400Regular,
    Inter_600SemiBold,
    JetBrainsMono_700Bold,
  });

  if (!fontsLoaded) {
    return <View style={{ flex: 1, backgroundColor: palette.cream }} />;
  }

  return (
    <SafeAreaProvider>
      <ThemeProvider>
        <UseCasesProvider>
          <RootGate />
          <StatusBar style="dark" />
        </UseCasesProvider>
      </ThemeProvider>
    </SafeAreaProvider>
  );
}
