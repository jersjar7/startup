import React from 'react';
import { View } from 'react-native';
import { Text } from '@/presentation/ui/Text';
import { Overline } from '@/presentation/ui/Overline';
import { useTheme } from '@/core/theme/useTheme';
import { interactionLabel, interactionColor } from '@/presentation/ui/semantics';
import type { SessionItem } from '@/domain/entities/session';

export function SessionRow({ item }: { item: SessionItem }) {
  const theme = useTheme();
  const title = item.kind === 'card' ? item.prompt : item.statement;
  return (
    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12, paddingVertical: 12 }}>
      <View style={{ flex: 1 }}>
        <Text variant="bodyStrong" numberOfLines={2}>
          {title}
        </Text>
      </View>
      <Overline color={interactionColor(item.interaction, theme)}>
        {interactionLabel(item.interaction)}
      </Overline>
    </View>
  );
}
