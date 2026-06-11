import React from 'react';
import { View } from 'react-native';
import Svg, { Path } from 'react-native-svg';
import { Card } from '@/presentation/ui/Card';
import { Text } from '@/presentation/ui/Text';
import { useTheme } from '@/core/theme/useTheme';
import type { WeekDay } from '@/domain/usecases/GetWeekActivity';

const DAY_LETTERS = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

interface Props {
  days: readonly WeekDay[];
  /** Today's check is EARNED — it only fills once the daily queue is done. */
  todayComplete?: boolean;
}

// Seven quiet day dots — the chain made visible without confetti.
export function WeekStrip({ days, todayComplete = false }: Props) {
  const theme = useTheme();
  return (
    <Card style={{ marginTop: 12, flexDirection: 'row', justifyContent: 'space-between' }}>
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
    </Card>
  );
}
