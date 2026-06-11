import React from 'react';
import { View } from 'react-native';
import Svg, { Path } from 'react-native-svg';
import { Card } from '@/presentation/ui/Card';
import { Text } from '@/presentation/ui/Text';
import { useTheme } from '@/core/theme/useTheme';
import type { WeekDay } from '@/domain/usecases/GetWeekActivity';
import { displayStreakNumber } from '@/domain/entities/streak';

const DAY_LETTERS = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

interface Props {
  days: readonly WeekDay[];
  /** Today's check is EARNED — it only fills once the daily queue is done. */
  todayComplete?: boolean;
  streak?: number;
}

// Seven quiet day dots — the chain made visible without confetti.
export function WeekStrip({ days, todayComplete = false, streak = 0 }: Props) {
  const theme = useTheme();
  // The number must equal what the dots show — today only counts once its
  // queue is done. The label and the strip may never disagree.
  const todayStudied = days.length > 0 && days[days.length - 1].studied;
  const displayStreak = displayStreakNumber(streak, todayStudied, todayComplete);
  return (
    <Card style={{ marginTop: 12 }}>
      <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
        <Text variant="overline" color={theme.palette.ink3}>
          Streak
        </Text>
        {displayStreak > 0 ? (
          // number in mono, unit in body — a mono space reads as a double gap
          <View style={{ flexDirection: 'row', alignItems: 'baseline', gap: 4 }}>
            <Text variant="mono" style={{ fontSize: 14 }}>
              {displayStreak}
            </Text>
            <Text variant="sub" color={theme.palette.ink3}>
              {displayStreak === 1 ? 'day' : 'days'}
            </Text>
          </View>
        ) : null}
      </View>
      <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
      {days.map((d, i) => {
        const letter = DAY_LETTERS[new Date(`${d.date}T00:00:00`).getDay()];
        const isToday = i === days.length - 1;
        const filled = d.studied && (!isToday || todayComplete);
        return (
          <View key={d.date} style={{ alignItems: 'center', gap: 6 }}>
            <Text variant="sub" color={isToday ? theme.palette.charcoal : theme.palette.ink4} style={{ fontSize: 11 }}>
              {letter}
            </Text>
            <View
              style={{
                width: 26,
                height: 26,
                borderRadius: 13,
                alignItems: 'center',
                justifyContent: 'center',
                backgroundColor: filled ? theme.palette.sunbeam : theme.palette.creamDark,
                borderWidth: isToday && !filled ? 1.5 : 0,
                borderColor: theme.palette.sunbeam,
              }}
            >
              {filled ? (
                <Svg width={13} height={13} viewBox="0 0 256 256" fill="none" stroke={theme.palette.charcoal} strokeWidth={28}>
                  <Path d="M40 144l52 52L216 72" strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
              ) : null}
            </View>
          </View>
        );
      })}
      </View>
      {todayStudied && !todayComplete && streak > 0 ? (
        <Text variant="sub" color={theme.palette.ink4} style={{ marginTop: 10 }}>
          Finish today's review to make it {streak}.
        </Text>
      ) : null}
    </Card>
  );
}
