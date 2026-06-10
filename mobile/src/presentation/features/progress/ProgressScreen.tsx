import React, { useCallback } from 'react';
import { View, ActivityIndicator } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { Screen } from '@/presentation/ui/Screen';
import { Text } from '@/presentation/ui/Text';
import { Card } from '@/presentation/ui/Card';
import { Overline } from '@/presentation/ui/Overline';
import { ProgressRing } from '@/presentation/ui/ProgressRing';
import { ProgressBar } from '@/presentation/ui/ProgressBar';
import { useTheme } from '@/core/theme/useTheme';
import { masteryColor, masteryLabel } from '@/presentation/ui/semantics';
import { useMasteryViewModel } from './useMasteryViewModel';

// Live per-chapter mastery. Reloads on focus so reviews visibly move the bars.
export function ProgressScreen() {
  const theme = useTheme();
  const { loading, overall, chapters, reload } = useMasteryViewModel();

  useFocusEffect(
    useCallback(() => {
      void reload();
    }, [reload]),
  );

  if (loading || !overall) {
    return (
      <Screen>
        <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
          <ActivityIndicator color={theme.palette.ember} />
        </View>
      </Screen>
    );
  }

  return (
    <Screen scroll>
      <Text variant="h1" style={{ marginTop: 8 }}>
        Mastery
      </Text>
      <Text variant="sub" color={theme.palette.ink3}>
        Mastery of the concepts the FE tests — not a probability of passing.
      </Text>

      <View style={{ marginTop: 20 }}>
        <Card style={{ flexDirection: 'row', alignItems: 'center', gap: 18, borderRadius: theme.radius.hero }}>
          <ProgressRing percent={overall.percent} color={masteryColor(overall.state, theme)} />
          <View style={{ flex: 1 }}>
            <Text variant="title">{masteryLabel(overall.state)}</Text>
            <Text variant="sub" color={theme.palette.ink3} style={{ marginTop: 2 }}>
              across {chapters.length} topics
            </Text>
          </View>
        </Card>
      </View>

      <View style={{ marginTop: 24, marginBottom: 4 }}>
        <Overline>By chapter</Overline>
      </View>

      {chapters.map(({ chapter, mastery }) => (
        <View key={chapter.id} style={{ paddingVertical: 12 }}>
          <View style={{ flexDirection: 'row', justifyContent: 'space-between', marginBottom: 8 }}>
            <Text variant="bodyStrong">{chapter.name}</Text>
            <Overline color={masteryColor(mastery.state, theme)}>{masteryLabel(mastery.state)}</Overline>
          </View>
          <ProgressBar percent={mastery.percent} color={masteryColor(mastery.state, theme)} />
        </View>
      ))}
    </Screen>
  );
}
