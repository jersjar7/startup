import React, { useRef } from 'react';
import { Animated, Pressable, type ViewStyle } from 'react-native';
import { Text } from './Text';
import { useTheme } from '@/core/theme/useTheme';
import { haptics } from '@/core/haptics';

type Variant = 'primary' | 'ghost';

interface Props {
  label: string; // keep short — fixed height, single line (visual-language button rule)
  onPress?: () => void;
  variant?: Variant;
  style?: ViewStyle;
}

// Fixed 54px height, single line. Long labels truncate rather than grow/wrap —
// shorten the word instead (docs/mobile/visual-language.md). Presses dip with a
// spring and fire a light haptic so taps feel acknowledged.
export function Button({ label, onPress, variant = 'primary', style }: Props) {
  const theme = useTheme();
  const isPrimary = variant === 'primary';
  const scale = useRef(new Animated.Value(1)).current;

  const spring = (toValue: number) =>
    Animated.spring(scale, { toValue, useNativeDriver: true, friction: 7, tension: 220 }).start();

  const base: ViewStyle = {
    height: 54,
    borderRadius: 14,
    paddingHorizontal: 18,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: isPrimary ? theme.palette.ember : 'transparent',
    borderWidth: isPrimary ? 0 : 1.5,
    borderColor: theme.palette.line,
    ...(isPrimary ? theme.shadow.emberButton : {}),
  };

  return (
    <Pressable
      onPressIn={() => spring(0.96)}
      onPressOut={() => spring(1)}
      onPress={() => {
        haptics.light();
        onPress?.();
      }}
    >
      <Animated.View style={[base, { transform: [{ scale }] }, style]}>
        <Text variant="title" numberOfLines={1} color={isPrimary ? theme.palette.white : theme.palette.ink2}>
          {label}
        </Text>
      </Animated.View>
    </Pressable>
  );
}
