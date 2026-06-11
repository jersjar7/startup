import React, { useState } from 'react';
import { View } from 'react-native';
import { Text } from '@/presentation/ui/Text';
import { MathText } from '@/presentation/ui/math/MathText';
import { Overline } from '@/presentation/ui/Overline';
import { Button } from '@/presentation/ui/Button';
import { FadeIn } from '@/presentation/ui/FadeIn';
import { useTheme } from '@/core/theme/useTheme';
import { interactionLabel, interactionColor } from '@/presentation/ui/semantics';
import { GradeButtons } from './GradeButtons';
import type { CardSessionItem } from '@/domain/entities/session';
import type { ReviewGrade } from '@/domain/entities/review';

interface Props {
  item: CardSessionItem;
  onGraded: (grade: ReviewGrade) => void;
}

// Reveal-gated retrieval: prompt first, answer only after the user commits, then
// a self-grade. Owns its own reveal state + footer.
export function RecallReviewCard({ item, onGraded }: Props) {
  const theme = useTheme();
  const [revealed, setRevealed] = useState(false);

  return (
    <View style={{ flex: 1 }}>
      <View style={{ flex: 1 }}>
        <Overline color={interactionColor(item.interaction, theme)}>
          {interactionLabel(item.interaction)}
        </Overline>
        <MathText variant="h2" style={{ marginTop: 14, fontSize: 22, lineHeight: 30 }}>
          {item.prompt}
        </MathText>

        {revealed ? (
          <FadeIn
            offset={14}
            style={{
              marginTop: 26,
              backgroundColor: theme.palette.forestBg,
              borderRadius: theme.radius.card,
              padding: 16,
            }}
          >
            <Overline color={theme.palette.forest}>Answer</Overline>
            <MathText variant="body" color={theme.palette.forestInk} style={{ marginTop: 8 }}>
              {item.answer}
            </MathText>
          </FadeIn>
        ) : (
          <Text variant="sub" color={theme.palette.ink3} style={{ marginTop: 20 }}>
            Recall it in your head, then reveal.
          </Text>
        )}
      </View>

      <View style={{ paddingVertical: 16 }}>
        {revealed ? <GradeButtons onGrade={onGraded} /> : <Button label="Reveal" onPress={() => setRevealed(true)} />}
      </View>
    </View>
  );
}
