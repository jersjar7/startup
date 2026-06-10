import React from 'react';
import { Screen } from '@/presentation/ui/Screen';
import { Text } from '@/presentation/ui/Text';
import { useTheme } from '@/core/theme/useTheme';

// Placeholder — per-chapter mastery (Mastered / Familiar / Building / New).
export function ProgressScreen() {
  const theme = useTheme();
  return (
    <Screen scroll>
      <Text variant="h1" style={{ marginTop: 8 }}>
        Mastery
      </Text>
      <Text variant="sub" color={theme.palette.ink3}>
        Mastery of the concepts the FE tests — not a probability of passing.
      </Text>
    </Screen>
  );
}
