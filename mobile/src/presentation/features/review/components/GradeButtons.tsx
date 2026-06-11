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
      {/* Equal visual weight — a filled "Got it" nudges users to inflate
          their self-grade, which corrupts the schedule (honest-mastery rule). */}
      <View style={{ flexDirection: 'row', gap: 10 }}>
        <Button label="Forgot" variant="ghost" style={{ flex: 1 }} onPress={() => onGrade('forgot')} />
        <Button label="Fuzzy" variant="ghost" style={{ flex: 1 }} onPress={() => onGrade('fuzzy')} />
        {/* equal fills + geometry (no grade inflation); the forest LABEL is the
            one success cue — panel consensus after four rounds of arbitration */}
        <Button
          label="Got it"
          variant="ghost"
          accentColor={theme.palette.forest}
          style={{ flex: 1 }}
          onPress={() => onGrade('gotIt')}
        />
      </View>
    </View>
  );
}
