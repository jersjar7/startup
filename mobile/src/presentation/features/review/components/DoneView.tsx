import React from 'react';
import { View } from 'react-native';
import Svg, { Path } from 'react-native-svg';
import { Screen } from '@/presentation/ui/Screen';
import { Text } from '@/presentation/ui/Text';
import { Button } from '@/presentation/ui/Button';
import { useTheme } from '@/core/theme/useTheme';

interface Props {
  reviewed: number;
  onClose: () => void;
}

// Bounded ending — celebrate, then stop. No "keep going" push.
export function DoneView({ reviewed, onClose }: Props) {
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
      </View>
      <View style={{ paddingVertical: 16 }}>
        <Button label="Done" variant="ghost" onPress={onClose} />
      </View>
    </Screen>
  );
}
