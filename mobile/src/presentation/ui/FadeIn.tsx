import React, { useEffect, useRef } from 'react';
import { Animated, type ViewStyle } from 'react-native';

interface Props {
  children: React.ReactNode;
  style?: ViewStyle;
  delay?: number; // ms — stagger siblings by passing index * step
  offset?: number; // starting translateY in px
}

// Mounts its children with a soft fade + rise. Used for card entrances and
// reveal panels so content arrives instead of snapping in. Native-driven.
export function FadeIn({ children, style, delay = 0, offset = 10 }: Props) {
  const t = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    const anim = Animated.timing(t, {
      toValue: 1,
      duration: 320,
      delay,
      useNativeDriver: true,
    });
    anim.start();
    return () => anim.stop();
  }, [t, delay]);

  const translateY = t.interpolate({ inputRange: [0, 1], outputRange: [offset, 0] });

  return (
    <Animated.View style={[style, { opacity: t, transform: [{ translateY }] }]}>{children}</Animated.View>
  );
}
