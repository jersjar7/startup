import React, { useCallback, useEffect, useState } from 'react';
import { View } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { useUseCases } from '@/di/useUseCases';
import { useTheme } from '@/core/theme/useTheme';
import { RootNavigator } from '@/presentation/navigation/RootNavigator';
import { OnboardingFlow } from '@/presentation/features/onboarding/OnboardingFlow';
import { AppRestartContext } from './AppRestart';

type Status = 'loading' | 'onboarding' | 'ready';

// First-run vs returning user: no saved pace → onboarding, otherwise the app.
// `restart()` (provided via context) re-evaluates after a reset.
export function RootGate() {
  const uc = useUseCases();
  const theme = useTheme();
  const [status, setStatus] = useState<Status>('loading');
  const [nonce, setNonce] = useState(0);

  const restart = useCallback(() => {
    setStatus('loading');
    setNonce((n) => n + 1);
  }, []);

  useEffect(() => {
    let active = true;
    void (async () => {
      const prefs = await uc.getStudyPreferences.execute();
      if (active) setStatus(prefs ? 'ready' : 'onboarding');
    })();
    return () => {
      active = false;
    };
  }, [uc, nonce]);

  let content: React.ReactNode;
  if (status === 'loading') {
    content = <View style={{ flex: 1, backgroundColor: theme.palette.cream }} />;
  } else if (status === 'onboarding') {
    content = <OnboardingFlow onDone={() => setStatus('ready')} />;
  } else {
    content = (
      <NavigationContainer>
        <RootNavigator />
      </NavigationContainer>
    );
  }

  return <AppRestartContext.Provider value={restart}>{content}</AppRestartContext.Provider>;
}
