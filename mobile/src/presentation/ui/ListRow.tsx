import React from 'react';
import { View, Pressable } from 'react-native';
import { Text } from './Text';
import { useTheme } from '@/core/theme/useTheme';

interface Props {
  title: string;
  subtitle?: string;
  icon?: React.ReactNode;
  right?: React.ReactNode;
  onPress?: () => void;
}

// Generic settings/menu row: optional left icon tile, title + subtitle, right
// accessory (value, chevron, badge). Pressable only when onPress is given.
export function ListRow({ title, subtitle, icon, right, onPress }: Props) {
  const theme = useTheme();
  const body = (
    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 14, paddingVertical: 15 }}>
      {icon ? (
        <View
          style={{
            width: 40,
            height: 40,
            borderRadius: 12,
            backgroundColor: theme.palette.creamDark,
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          {icon}
        </View>
      ) : null}
      <View style={{ flex: 1 }}>
        <Text variant="bodyStrong" style={{ fontSize: 15 }}>
          {title}
        </Text>
        {subtitle ? (
          <Text variant="sub" color={theme.palette.ink3} style={{ marginTop: 2 }}>
            {subtitle}
          </Text>
        ) : null}
      </View>
      {right}
    </View>
  );

  if (!onPress) return body;
  return (
    <Pressable onPress={onPress} style={({ pressed }) => ({ opacity: pressed ? 0.6 : 1 })}>
      {body}
    </Pressable>
  );
}
