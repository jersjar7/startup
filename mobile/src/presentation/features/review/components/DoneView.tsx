import React from 'react';
import { View } from 'react-native';
import Svg, { Path } from 'react-native-svg';
import { Screen } from '@/presentation/ui/Screen';
import { Text } from '@/presentation/ui/Text';
import { Button } from '@/presentation/ui/Button';
import { useTheme } from '@/core/theme/useTheme';

interface Props {
  reviewed: number;
  streak: number;
  onClose: () => void;
}

// Bounded ending — celebrate, then stop. No "keep going" push.
export function DoneView({ reviewed, streak, onClose }: Props) {
  const theme = useTheme();
  return (
    <Screen edges={['top', 'bottom']}>
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
        <View
          style={{
            width: 88,
            height: 88,
            borderRadius: 44,
            backgroundColor: theme.palette.forestBg,
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <Svg width={42} height={42} viewBox="0 0 256 256" fill="none" stroke={theme.palette.forest} strokeWidth={20}>
            <Path d="M40 144l52 52L216 72" strokeLinecap="round" strokeLinejoin="round" />
          </Svg>
        </View>
        <Text variant="h1" style={{ marginTop: 24 }}>
          Done for today
        </Text>
        <Text variant="body" color={theme.palette.ink2} style={{ marginTop: 8, textAlign: 'center' }}>
          {reviewed === 0
            ? "Nothing due right now — you're caught up."
            : `${reviewed} cards reviewed. That's the work — see you tomorrow.`}
        </Text>

        {streak > 0 ? (
          <View
            style={{
              flexDirection: 'row',
              alignItems: 'center',
              gap: 7,
              marginTop: 22,
              backgroundColor: theme.palette.sunbeamBg,
              paddingHorizontal: 14,
              paddingVertical: 9,
              borderRadius: theme.radius.pill,
            }}
          >
            <Svg width={17} height={17} viewBox="0 0 256 256" fill={theme.palette.sunbeam}>
              <Path d="M173.8 32.3a8 8 0 0 0-12.6 3.2c-9 24-25 38.6-39.4 51.6-15.7 14.2-30.6 27.6-30.6 49 0 10 3 18.6 7.8 25.4-13-3.8-23-13.6-27.8-27a8 8 0 0 0-13.4-3C45.3 146.3 40 165 40 184a88 88 0 0 0 176 0c0-62.7-31.6-119.6-42.2-151.7" />
            </Svg>
            <Text variant="bodyStrong" color={theme.palette.sunbeamInk}>
              {streak}-day streak
            </Text>
          </View>
        ) : null}
      </View>
      <View style={{ paddingVertical: 16 }}>
        <Button label="Done" variant="ghost" onPress={onClose} />
      </View>
    </Screen>
  );
}
