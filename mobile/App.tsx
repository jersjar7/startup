import React from 'react';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { NavigationContainer } from '@react-navigation/native';
import { ThemeProvider } from '@/core/theme/ThemeProvider';
import { UseCasesProvider } from '@/di/AppContext';
import { TabNavigator } from '@/presentation/navigation/TabNavigator';

// Root: providers (theme + DI) wrap navigation. The composition root runs inside
// UseCasesProvider; nothing above the presentation layer is constructed here.
export default function App() {
  return (
    <SafeAreaProvider>
      <ThemeProvider>
        <UseCasesProvider>
          <NavigationContainer>
            <TabNavigator />
          </NavigationContainer>
          <StatusBar style="dark" />
        </UseCasesProvider>
      </ThemeProvider>
    </SafeAreaProvider>
  );
}
