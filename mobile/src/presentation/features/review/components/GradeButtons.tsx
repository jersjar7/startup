import React from 'react';
import { View } from 'react-native';
import { Button } from '@/presentation/ui/Button';
import { Text } from '@/presentation/ui/Text';
import { useTheme } from '@/core/theme/useTheme';
import type { ReviewGrade } from '@/domain/entities/review';

// Self-grade drives the schedule: forgot resurfaces soon, got-it spaces it out.
// Three equal-height, single-word buttons (visual-language button rule).
export function GradeButtons({ onGrade }: { onGrade: (g: ReviewGrade) => void }) {
  const theme = useTheme();
  return (
    <View>
      <Text variant="sub" color={theme.palette.ink3} style={{ textAlign: 'center', marginBottom: 10 }}>
        How well did you know it?
      </Text>
      <View style={{ flexDirection: 'row', gap: 10 }}>
        <Button label="Forgot" variant="ghost" style={{ flex: 1 }} onPress={() => onGrade('forgot')} />
        <Button label="Fuzzy" variant="ghost" style={{ flex: 1 }} onPress={() => onGrade('fuzzy')} />
        <Button label="Got it" style={{ flex: 1 }} onPress={() => onGrade('gotIt')} />
      </View>
    </View>
  );
}
