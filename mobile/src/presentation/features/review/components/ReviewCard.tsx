import React from 'react';
import { View } from 'react-native';
import { Text } from '@/presentation/ui/Text';
import { Overline } from '@/presentation/ui/Overline';
import { useTheme } from '@/core/theme/useTheme';
import { interactionLabel, interactionColor } from '@/presentation/ui/semantics';
import type { SessionItem } from '@/domain/entities/session';

interface Props {
  item: SessionItem;
  revealed: boolean;
}

// Reveal-gated retrieval: prompt first, answer only after the user commits.
// The answer lands in a filled forest card — color as the payoff moment.
export function ReviewCard({ item, revealed }: Props) {
  const theme = useTheme();
  return (
    <View style={{ flex: 1 }}>
      <Overline color={interactionColor(item.interaction, theme)}>
        {interactionLabel(item.interaction)}
      </Overline>

      <Text variant="h2" style={{ marginTop: 14, fontSize: 22, lineHeight: 30 }}>
        {item.prompt}
      </Text>

      {revealed ? (
        <View
          style={{
            marginTop: 26,
            backgroundColor: theme.palette.forestBg,
            borderRadius: theme.radius.card,
            padding: 16,
          }}
        >
          <Overline color={theme.palette.forest}>Answer</Overline>
          <Text variant="body" color={theme.palette.forestInk} style={{ marginTop: 8 }}>
            {item.answer}
          </Text>
        </View>
      ) : (
        <Text variant="sub" color={theme.palette.ink3} style={{ marginTop: 20 }}>
          Recall it in your head, then reveal.
        </Text>
      )}
    </View>
  );
}
