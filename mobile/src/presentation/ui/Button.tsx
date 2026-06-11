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
  disabled?: boolean; // dimmed + inert — never a normal-looking button that ignores taps
  /** Ghost-variant accent: tints border + label (e.g. forest for success
      semantics) while keeping equal geometry with its siblings. */
  accentColor?: string;
}

// Fixed 54px height, single line. Long labels truncate rather than grow/wrap —
// shorten the word instead (docs/mobile/visual-language.md). Presses dip with a
// spring and fire a light haptic so taps feel acknowledged.
export function Button({ label, onPress, variant = 'primary', style, disabled = false, accentColor }: Props) {
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
    // Disabled is desaturated cream — never tinted ember, which reads as
    // "almost on" / broken rendering at ~1.7:1 contrast. Ghost buttons sit on
    // the cream canvas, so they get a white fill — transparent ghosts had
    // near-invisible borders in daylight.
    backgroundColor: disabled
      ? theme.palette.creamDark
      : isPrimary
        ? theme.palette.ember
        : theme.palette.white,
    borderWidth: isPrimary || disabled ? 0 : 1.5,
    borderColor: accentColor ?? 'rgba(44,44,44,0.15)',
    ...(isPrimary && !disabled ? theme.shadow.emberButton : {}),
  };

  return (
    // Layout styles (flex, margins) go on the Pressable — putting flex:1 on
    // the inner view lets flexBasis:0 override the fixed 54px height and
    // collapse the pill (the round-3 "short grade buttons" bug).
    <Pressable
      style={style}
      disabled={disabled}
      onPressIn={() => spring(0.96)}
      onPressOut={() => spring(1)}
      onPress={() => {
        haptics.light();
        onPress?.();
      }}
    >
      <Animated.View style={[base, { transform: [{ scale }] }]}>
        <Text
          variant="title"
          numberOfLines={1}
          color={
            disabled
              ? 'rgba(44,44,44,0.45)'
              : isPrimary
                ? theme.palette.white
                : (accentColor ?? theme.palette.ink2)
          }
        >
          {label}
        </Text>
      </Animated.View>
    </Pressable>
  );
}
