import React from 'react';
import { View } from 'react-native';
import { Card } from '@/presentation/ui/Card';
import { Text } from '@/presentation/ui/Text';
import { ProgressRing } from '@/presentation/ui/ProgressRing';
import { useTheme } from '@/core/theme/useTheme';

interface Props {
  percent: number;
}

// The hero: a mastery ring (the one colorful data moment). Never a pass
// figure. Before any reviews exist, never show a bare "0" — that reads as
// "your work doesn't count here." Show an honest not-yet state instead.
// (The exam countdown lives in the screen header — not duplicated here.)
export function MasteryHeroCard({ percent }: Props) {
  const theme = useTheme();
  const hasReading = percent > 0;
  return (
    <Card style={{ flexDirection: 'row', alignItems: 'center', gap: 18, borderRadius: theme.radius.hero }}>
      <ProgressRing percent={percent} display={hasReading ? undefined : '—'} />
      <View style={{ flex: 1 }}>
        <Text variant="title">Concept mastery</Text>
        <Text variant="sub" color={theme.palette.ink3} style={{ marginTop: 2 }}>
          {hasReading
            ? 'the concepts the FE tests — not a pass rate'
            : "Complete today's cards for your first reading"}
        </Text>
      </View>
    </Card>
  );
}
