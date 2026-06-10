import React from 'react';
import { View, Pressable } from 'react-native';
import Svg, { Path } from 'react-native-svg';
import { useTheme } from '@/core/theme/useTheme';

interface Props {
  total: number;
  index: number;
  onClose: () => void;
}

export function ProgressDots({ total, index, onClose }: Props) {
  const theme = useTheme();
  return (
    <View style={{ paddingTop: 8, paddingBottom: 18 }}>
      <View style={{ flexDirection: 'row', justifyContent: 'flex-end', marginBottom: 16 }}>
        <Pressable onPress={onClose} hitSlop={12}>
          <Svg width={22} height={22} viewBox="0 0 256 256" fill="none" stroke={theme.palette.ink3} strokeWidth={20}>
            <Path d="M64 64l128 128M192 64L64 192" strokeLinecap="round" />
          </Svg>
        </Pressable>
      </View>
      <View style={{ flexDirection: 'row', gap: 5 }}>
        {Array.from({ length: total }).map((_, i) => (
          <View
            key={i}
            style={{
              flex: 1,
              height: 3.5,
              borderRadius: 2,
              backgroundColor: i <= index ? theme.palette.ember : theme.palette.creamDark,
            }}
          />
        ))}
      </View>
    </View>
  );
}
