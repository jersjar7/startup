import React, { useCallback } from 'react';
import { View, ActivityIndicator, Pressable } from 'react-native';
import { useFocusEffect, useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '@/presentation/navigation/types';
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
  const nav = useNavigation<NativeStackNavigationProp<RootStackParamList>>();
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
        The concepts the FE tests, on this phone — not a probability of passing.
      </Text>

      <View style={{ marginTop: 20 }}>
        <Card style={{ flexDirection: 'row', alignItems: 'center', gap: 18, borderRadius: theme.radius.hero }}>
          {/* One metric, one color — the arc is always ember (data moment rule) */}
          <ProgressRing percent={overall.percent} />
          <View style={{ flex: 1 }}>
            <Text variant="title">Concept mastery</Text>
            <Text variant="sub" color={theme.palette.ink3} style={{ marginTop: 2 }}>
              {stateBreakdown(chapters.map((c) => c.mastery.state))}
            </Text>
          </View>
        </Card>
      </View>

      <View style={{ marginTop: 24, marginBottom: 4 }}>
        <Overline>By chapter</Overline>
      </View>

      {chapters.map(({ chapter, mastery }) => (
        <Pressable
          key={chapter.id}
          onPress={() => nav.navigate('Review', { chapterId: chapter.id })}
          style={({ pressed }) => ({ paddingVertical: 12, opacity: pressed ? 0.6 : 1 })}
        >
          <View style={{ flexDirection: 'row', justifyContent: 'space-between', marginBottom: 8 }}>
            <Text variant="bodyStrong">{chapter.name}</Text>
            <Overline color={masteryColor(mastery.state, theme)}>{masteryLabel(mastery.state)}</Overline>
          </View>
          <ProgressBar percent={mastery.percent} color={masteryColor(mastery.state, theme)} />
        </Pressable>
      ))}
    </Screen>
  );
}

// "2 building · 1 familiar · 12 new" — the breakdown the chapter list implies.
function stateBreakdown(states: readonly string[]): string {
  const order = ['mastered', 'familiar', 'building', 'new'] as const;
  const counts = new Map<string, number>();
  for (const s of states) counts.set(s, (counts.get(s) ?? 0) + 1);
  return order
    .filter((s) => (counts.get(s) ?? 0) > 0)
    .map((s) => `${counts.get(s)} ${s}`)
    .join(' · ');
}
