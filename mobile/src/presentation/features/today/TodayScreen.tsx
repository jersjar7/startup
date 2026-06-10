import React, { useCallback } from 'react';
import { View, ActivityIndicator } from 'react-native';
import { useNavigation, useFocusEffect } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '@/presentation/navigation/types';
import { Screen } from '@/presentation/ui/Screen';
import { Text } from '@/presentation/ui/Text';
import { Button } from '@/presentation/ui/Button';
import { Divider } from '@/presentation/ui/Divider';
import { useTheme } from '@/core/theme/useTheme';
import { useTodayViewModel } from './useTodayViewModel';
import { MasteryHeroCard } from './components/MasteryHeroCard';
import { SessionRow } from './components/SessionRow';
import { PaperHandoffCard } from './components/PaperHandoffCard';

export function TodayScreen() {
  const theme = useTheme();
  const nav = useNavigation<NativeStackNavigationProp<RootStackParamList>>();
  const { loading, mastery, plan, session, reload } = useTodayViewModel();

  // Recompute mastery + session when returning from a review session.
  useFocusEffect(
    useCallback(() => {
      void reload();
    }, [reload]),
  );

  if (loading || !session) {
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
        Today
      </Text>
      <Text variant="sub" color={theme.palette.ink3}>
        {plan ? `${plan.daysUntilExam} days to your exam` : 'Set your exam date'}
      </Text>

      <View style={{ marginTop: 20 }}>
        <MasteryHeroCard percent={mastery?.percent ?? 0} daysUntilExam={plan?.daysUntilExam ?? 0} />
      </View>

      <View
        style={{
          flexDirection: 'row',
          justifyContent: 'space-between',
          alignItems: 'center',
          marginTop: 26,
          marginBottom: 2,
        }}
      >
        <Text variant="h2">Your review</Text>
        <Text variant="sub" color={theme.palette.ink3}>
          {session.items.length} cards · {session.estimatedMinutes} min
        </Text>
      </View>

      <View>
        {session.items.map((item, i) => (
          <View key={item.id}>
            <SessionRow item={item} />
            {i < session.items.length - 1 ? <Divider /> : null}
          </View>
        ))}
      </View>

      {session.paperHandoff ? (
        <View style={{ marginTop: 16 }}>
          <PaperHandoffCard handoff={session.paperHandoff} />
        </View>
      ) : null}

      <View style={{ marginTop: 22 }}>
        <Button label="Start" onPress={() => nav.navigate('Review')} />
      </View>
    </Screen>
  );
}
