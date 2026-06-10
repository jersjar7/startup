import React, { useCallback } from 'react';
import { View, ActivityIndicator } from 'react-native';
import Svg, { Path } from 'react-native-svg';
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
  const { loading, mastery, plan, session, streak, reload } = useTodayViewModel();

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
      <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start' }}>
        <View>
          <Text variant="h1" style={{ marginTop: 8 }}>
            Today
          </Text>
          <Text variant="sub" color={theme.palette.ink3}>
            {plan ? `${plan.daysUntilExam} days to your exam` : 'Set your exam date'}
          </Text>
        </View>
        {streak > 0 ? (
          <View
            style={{
              flexDirection: 'row',
              alignItems: 'center',
              gap: 5,
              marginTop: 10,
              backgroundColor: theme.palette.sunbeamBg,
              paddingHorizontal: 11,
              paddingVertical: 7,
              borderRadius: theme.radius.pill,
            }}
          >
            <Svg width={15} height={15} viewBox="0 0 256 256" fill={theme.palette.sunbeam}>
              <Path d="M173.8 32.3a8 8 0 0 0-12.6 3.2c-9 24-25 38.6-39.4 51.6-15.7 14.2-30.6 27.6-30.6 49 0 10 3 18.6 7.8 25.4-13-3.8-23-13.6-27.8-27a8 8 0 0 0-13.4-3C45.3 146.3 40 165 40 184a88 88 0 0 0 176 0c0-62.7-31.6-119.6-42.2-151.7" />
            </Svg>
            <Text variant="title" color={theme.palette.sunbeamInk} style={{ fontSize: 14 }}>
              {streak}
            </Text>
          </View>
        ) : null}
      </View>

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
