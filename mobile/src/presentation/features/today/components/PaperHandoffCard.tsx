import React from 'react';
import { View, Pressable } from 'react-native';
import { Text } from '@/presentation/ui/Text';
import { MathText } from '@/presentation/ui/math/MathText';
import { useTheme } from '@/core/theme/useTheme';
import type { PaperHandoff } from '@/domain/entities/session';

// The honest hand-off: one warm ember card, surfaced not hidden. The button
// sends this paper-tier problem to the shared web "Tonight" list so it is
// waiting at the desk later.
export function PaperHandoffCard({
  handoff,
  flagged,
  onFlag,
}: {
  handoff: PaperHandoff;
  flagged: boolean;
  onFlag: () => void;
}) {
  const theme = useTheme();
  return (
    <View style={{ backgroundColor: theme.palette.emberBg, borderRadius: 14, padding: 14 }}>
      <Text variant="bodyStrong" color={theme.palette.emberInk}>
        For your desk tonight
      </Text>
      <MathText variant="sub" color={theme.palette.ink2} style={{ marginTop: 3 }} numberOfLines={2}>
        {`Solve on paper: ${handoff.statement}`}
      </MathText>
      <Pressable
        accessibilityRole="button"
        onPress={flagged ? undefined : onFlag}
        disabled={flagged}
        style={{
          marginTop: 12,
          alignSelf: 'flex-start',
          backgroundColor: flagged ? 'transparent' : theme.palette.ember,
          borderRadius: 999,
          paddingVertical: 9,
          paddingHorizontal: 16,
        }}
      >
        <Text variant="bodyStrong" color={flagged ? theme.palette.emberInk : theme.palette.cream}>
          {flagged ? 'On tonight’s list ✓' : 'Send to tonight’s list'}
        </Text>
      </Pressable>
    </View>
  );
}
