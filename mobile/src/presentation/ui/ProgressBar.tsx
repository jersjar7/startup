import React, { useEffect, useRef } from 'react';
import { Animated, View } from 'react-native';
import { useTheme } from '@/core/theme/useTheme';

interface Props {
  percent: number;
  color?: string;
  height?: number;
}

export function ProgressBar({ percent, color, height = 6 }: Props) {
  const theme = useTheme();
  const clamped = Math.max(0, Math.min(100, percent));

  // Animate the fill toward its value (width % → not native-driver eligible).
  const t = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    const anim = Animated.timing(t, { toValue: clamped, duration: 650, useNativeDriver: false });
    anim.start();
    return () => anim.stop();
  }, [t, clamped]);

  const width = t.interpolate({ inputRange: [0, 100], outputRange: ['0%', '100%'] });

  return (
    <View style={{ height, borderRadius: height / 2, backgroundColor: theme.palette.creamDark, overflow: 'hidden' }}>
      <Animated.View
        style={{
          width,
          height: '100%',
          borderRadius: height / 2,
          backgroundColor: color ?? theme.palette.ember,
        }}
      />
    </View>
  );
}
