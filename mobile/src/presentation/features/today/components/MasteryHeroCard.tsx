import React from 'react';
import { View } from 'react-native';
import { Card } from '@/presentation/ui/Card';
import { Text } from '@/presentation/ui/Text';
import { ProgressRing } from '@/presentation/ui/ProgressRing';
import { useTheme } from '@/core/theme/useTheme';

interface Props {
  percent: number;
  daysUntilExam: number;
}

// The hero: a mastery ring (the one colorful data moment). Never a pass figure.
export function MasteryHeroCard({ percent, daysUntilExam }: Props) {
  const theme = useTheme();
  return (
    <Card style={{ flexDirection: 'row', alignItems: 'center', gap: 18, borderRadius: theme.radius.hero }}>
      <ProgressRing percent={percent} />
      <View style={{ flex: 1 }}>
        <Text variant="title">Concept mastery</Text>
        <Text variant="sub" color={theme.palette.ink3} style={{ marginTop: 2 }}>
          {daysUntilExam} days out · the concepts the FE tests
        </Text>
      </View>
    </Card>
  );
}
