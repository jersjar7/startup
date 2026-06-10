import React from 'react';
import { View } from 'react-native';
import Svg, { Circle } from 'react-native-svg';
import { Text } from './Text';
import { useTheme } from '@/core/theme/useTheme';

interface Props {
  percent: number;
  size?: number;
  stroke?: number;
  color?: string;
}

// The mastery ring — the one colorful data focal point per screen.
export function ProgressRing({ percent, size = 74, stroke = 8, color }: Props) {
  const theme = useTheme();
  const r = (size - stroke) / 2;
  const circumference = 2 * Math.PI * r;
  const clamped = Math.max(0, Math.min(100, percent));
  const offset = circumference * (1 - clamped / 100);
  const center = size / 2;

  return (
    <View style={{ width: size, height: size, alignItems: 'center', justifyContent: 'center' }}>
      <Svg width={size} height={size} style={{ position: 'absolute' }}>
        <Circle cx={center} cy={center} r={r} stroke={theme.palette.creamDark} strokeWidth={stroke} fill="none" />
        <Circle
          cx={center}
          cy={center}
          r={r}
          stroke={color ?? theme.palette.ember}
          strokeWidth={stroke}
          fill="none"
          strokeDasharray={circumference}
          strokeDashoffset={offset}
          strokeLinecap="round"
          transform={`rotate(-90 ${center} ${center})`}
        />
      </Svg>
      <Text variant="mono" style={{ fontSize: 18 }}>
        {Math.round(clamped)}
      </Text>
    </View>
  );
}
