import React, { useCallback } from 'react';
import { View, ActivityIndicator } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { Screen } from '@/presentation/ui/Screen';
import { Text } from '@/presentation/ui/Text';
import { Card } from '@/presentation/ui/Card';
import { Overline } from '@/presentation/ui/Overline';
import { Divider } from '@/presentation/ui/Divider';
import { ProgressRing } from '@/presentation/ui/ProgressRing';
import { ListRow } from '@/presentation/ui/ListRow';
import { useTheme } from '@/core/theme/useTheme';
import { masteryColor } from '@/presentation/ui/semantics';
import { useProfileViewModel } from './useProfileViewModel';

export function ProfileScreen() {
  const theme = useTheme();
  const { loading, overall, masteredCount, topicCount, prefs, reload } = useProfileViewModel();

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
        Profile
      </Text>

      <View style={{ marginTop: 18 }}>
        <Card style={{ flexDirection: 'row', alignItems: 'center', gap: 18, borderRadius: theme.radius.hero }}>
          <ProgressRing percent={overall.percent} color={masteryColor(overall.state, theme)} />
          <View style={{ flex: 1 }}>
            <Text variant="title">Concept mastery</Text>
            <Text variant="sub" color={theme.palette.ink3} style={{ marginTop: 2 }}>
              {masteredCount} of {topicCount} topics mastered
            </Text>
            <Text variant="sub" color={theme.palette.ink4} style={{ marginTop: 7, fontSize: 11, lineHeight: 15 }}>
              Mastery of the concepts the FE tests — not a probability of passing.
            </Text>
          </View>
        </Card>
      </View>

      <View style={{ marginTop: 24, marginBottom: 2 }}>
        <Overline>Plan</Overline>
      </View>
      {prefs ? (
        <>
          <ListRow
            title="Exam date"
            right={
              <Text variant="sub" color={theme.palette.ink3}>
                {formatDate(prefs.examDate)}
              </Text>
            }
          />
          <Divider />
          <ListRow
            title="Daily pace"
            right={
              <Text variant="sub" color={theme.palette.ink3}>
                {prefs.minutesPerDay} min
              </Text>
            }
          />
        </>
      ) : null}
    </Screen>
  );
}

function formatDate(iso: string): string {
  return new Date(`${iso}T00:00:00`).toLocaleDateString(undefined, {
    month: 'long',
    day: 'numeric',
    year: 'numeric',
  });
}
