import React from 'react';
import { View } from 'react-native';
import { useTheme } from '@/core/theme/useTheme';

interface Props {
  percent: number;
  color?: string;
  height?: number;
}

export function ProgressBar({ percent, color, height = 6 }: Props) {
  const theme = useTheme();
  const clamped = Math.max(0, Math.min(100, percent));
  return (
    <View style={{ height, borderRadius: height / 2, backgroundColor: theme.palette.creamDark, overflow: 'hidden' }}>
      <View
        style={{
          width: `${clamped}%`,
          height: '100%',
          borderRadius: height / 2,
          backgroundColor: color ?? theme.palette.ember,
        }}
      />
    </View>
  );
}
