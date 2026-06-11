import React, { useEffect, useRef } from 'react';
import { Animated, View } from 'react-native';
import Svg, { Circle } from 'react-native-svg';
import { Text } from './Text';
import { useTheme } from '@/core/theme/useTheme';

const AnimatedCircle = Animated.createAnimatedComponent(Circle);

interface Props {
  percent: number;
  size?: number;
  stroke?: number;
  color?: string;
  display?: string; // override the center text (e.g. "—" before any reading exists)
}

// The mastery ring — the one colorful data focal point per screen. The arc
// sweeps up to its value on mount so the number feels earned, not stamped.
export function ProgressRing({ percent, size = 74, stroke = 8, color, display }: Props) {
  const theme = useTheme();
  const r = (size - stroke) / 2;
  const circumference = 2 * Math.PI * r;
  const clamped = Math.max(0, Math.min(100, percent));
  const offset = circumference * (1 - clamped / 100);
  const center = size / 2;

  // Animate strokeDashoffset (SVG prop → can't use the native driver).
  const dash = useRef(new Animated.Value(circumference)).current;
  useEffect(() => {
    const anim = Animated.timing(dash, {
      toValue: offset,
      duration: 750,
      useNativeDriver: false,
    });
    anim.start();
    return () => anim.stop();
  }, [dash, offset]);

  return (
    <View style={{ width: size, height: size, alignItems: 'center', justifyContent: 'center' }}>
      <Svg width={size} height={size} style={{ position: 'absolute' }}>
        <Circle cx={center} cy={center} r={r} stroke={theme.palette.creamDark} strokeWidth={stroke} fill="none" />
        <AnimatedCircle
          cx={center}
          cy={center}
          r={r}
          stroke={color ?? theme.palette.ember}
          strokeWidth={stroke}
          fill="none"
          strokeDasharray={circumference}
          strokeDashoffset={dash}
          strokeLinecap="round"
          transform={`rotate(-90 ${center} ${center})`}
        />
      </Svg>
      {display !== undefined ? (
        <Text variant="mono" style={{ fontSize: 18 }}>
          {display}
        </Text>
      ) : (
        // Always anchor the number with its unit — a bare "9" answers nothing.
        <Text variant="mono" style={{ fontSize: 18 }}>
          {Math.round(clamped)}
          <Text variant="mono" style={{ fontSize: 12 }}>
            %
          </Text>
        </Text>
      )}
    </View>
  );
}
