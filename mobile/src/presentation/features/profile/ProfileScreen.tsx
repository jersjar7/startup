import React from 'react';
import { Screen } from '@/presentation/ui/Screen';
import { Text } from '@/presentation/ui/Text';
import { useTheme } from '@/core/theme/useTheme';

// Placeholder — account, exam date, daily pace, reminders.
export function ProfileScreen() {
  const theme = useTheme();
  return (
    <Screen scroll>
      <Text variant="h1" style={{ marginTop: 8 }}>
        Profile
      </Text>
      <Text variant="sub" color={theme.palette.ink3}>
        Exam date, daily pace, reminders.
      </Text>
    </Screen>
  );
}
