import React from 'react';
import { Screen } from '@/presentation/ui/Screen';
import { Text } from '@/presentation/ui/Text';
import { useTheme } from '@/core/theme/useTheme';

// Placeholder — the "extra practice" surface (weak areas, by chapter, mock→web).
// Built out in a later batch; here to prove navigation + the architecture.
export function PracticeScreen() {
  const theme = useTheme();
  return (
    <Screen scroll>
      <Text variant="h1" style={{ marginTop: 8 }}>
        Practice
      </Text>
      <Text variant="sub" color={theme.palette.ink3}>
        Your daily plan is the spine — extra practice lands here.
      </Text>
    </Screen>
  );
}
