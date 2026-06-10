import React from 'react';
import { Pressable, type ViewStyle } from 'react-native';
import { Text } from './Text';
import { useTheme } from '@/core/theme/useTheme';

type Variant = 'primary' | 'ghost';

interface Props {
  label: string; // keep short — fixed height, single line (visual-language button rule)
  onPress?: () => void;
  variant?: Variant;
  style?: ViewStyle;
}

// Fixed 54px height, single line. Long labels truncate rather than grow/wrap —
// shorten the word instead (docs/mobile/visual-language.md).
export function Button({ label, onPress, variant = 'primary', style }: Props) {
  const theme = useTheme();
  const isPrimary = variant === 'primary';

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
    <Pressable onPress={onPress} style={({ pressed }) => [base, { opacity: pressed ? 0.9 : 1 }, style]}>
      <Text variant="title" numberOfLines={1} color={isPrimary ? theme.palette.white : theme.palette.ink2}>
        {label}
      </Text>
    </Pressable>
  );
}
