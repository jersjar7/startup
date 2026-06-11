import React from 'react';
import { View } from 'react-native';
import { Text } from '@/presentation/ui/Text';
import { MathText } from '@/presentation/ui/math/MathText';
import { useTheme } from '@/core/theme/useTheme';
import type { PaperHandoff } from '@/domain/entities/session';

// The honest hand-off — one warm ember card, surfaced not hidden.
export function PaperHandoffCard({ handoff }: { handoff: PaperHandoff }) {
  const theme = useTheme();
  return (
    <View style={{ backgroundColor: theme.palette.emberBg, borderRadius: 14, padding: 14 }}>
      <Text variant="bodyStrong" color={theme.palette.emberInk}>
        For your desk tonight
      </Text>
      <MathText variant="sub" color={theme.palette.ink2} style={{ marginTop: 3 }} numberOfLines={2}>
        {`Solve on paper: ${handoff.statement}`}
      </MathText>
    </View>
  );
}
