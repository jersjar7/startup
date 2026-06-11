import React, { useState } from 'react';
import { View, Pressable } from 'react-native';
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

  // "(p. 36)" jammed into the formula is cryptic — pull the handbook
  // reference onto its own labeled line.
  const refMatch = item.answer.match(/\s*\(p\.\s*(\d+)\)\s*$/);
  const answerBody = refMatch ? item.answer.slice(0, refMatch.index) : item.answer;
  const handbookPage = refMatch ? refMatch[1] : null;

  return (
    <View style={{ flex: 1 }}>
      {/* the whole question area flips the card — a precise button press is
          unforgiving on a moving bus; the Reveal button stays as the affordance */}
      <Pressable style={{ flex: 1 }} disabled={revealed} onPress={() => setRevealed(true)}>
        <Overline color={interactionColor(item.interaction, theme)}>
          {interactionLabel(item.interaction)}
        </Overline>
        <MathText
          variant="question"
          style={
            item.prompt.length > 140
              ? { marginTop: 14, fontSize: 17, lineHeight: 25 }
              : { marginTop: 14, fontSize: 21, lineHeight: 30 }
          }
        >
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
              {answerBody}
            </MathText>
            {handbookPage ? (
              <View style={{ marginTop: 10 }}>
                <Overline color={theme.palette.ink3}>FE Handbook p. {handbookPage}</Overline>
              </View>
            ) : null}
          </FadeIn>
        ) : (
          <Text variant="sub" color={theme.palette.ink3} style={{ marginTop: 20 }}>
            Recall it in your head, then tap to reveal.
          </Text>
        )}
      </Pressable>

      <View style={{ paddingVertical: 16 }}>
        {revealed ? <GradeButtons onGrade={onGraded} /> : <Button label="Reveal" onPress={() => setRevealed(true)} />}
      </View>
    </View>
  );
}
