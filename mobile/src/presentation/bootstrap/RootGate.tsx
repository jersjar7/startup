import React, { useEffect, useState } from 'react';
import { View } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { useUseCases } from '@/di/useUseCases';
import { useTheme } from '@/core/theme/useTheme';
import { RootNavigator } from '@/presentation/navigation/RootNavigator';
import { OnboardingFlow } from '@/presentation/features/onboarding/OnboardingFlow';

type Status = 'loading' | 'onboarding' | 'ready';

// First-run vs returning user: no saved pace → onboarding, otherwise the app.
export function RootGate() {
  const uc = useUseCases();
  const theme = useTheme();
  const [status, setStatus] = useState<Status>('loading');

  useEffect(() => {
    let active = true;
    void (async () => {
      const prefs = await uc.getStudyPreferences.execute();
      if (active) setStatus(prefs ? 'ready' : 'onboarding');
    })();
    return () => {
      active = false;
    };
  }, [uc]);

  if (status === 'loading') {
    return <View style={{ flex: 1, backgroundColor: theme.palette.cream }} />;
  }
  if (status === 'onboarding') {
    return <OnboardingFlow onDone={() => setStatus('ready')} />;
  }
  return (
    <NavigationContainer>
      <RootNavigator />
    </NavigationContainer>
  );
}
