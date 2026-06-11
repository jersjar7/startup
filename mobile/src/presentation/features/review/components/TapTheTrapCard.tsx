import React, { useState } from 'react';
import { View, ScrollView, Pressable } from 'react-native';
import { Text } from '@/presentation/ui/Text';
import { MathText } from '@/presentation/ui/math/MathText';
import { Overline } from '@/presentation/ui/Overline';
import { Button } from '@/presentation/ui/Button';
import { FadeIn } from '@/presentation/ui/FadeIn';
import { useTheme } from '@/core/theme/useTheme';
import { haptics } from '@/core/haptics';
import { sound } from '@/core/sound';
import type { ProblemSessionItem } from '@/domain/entities/session';
import type { ReviewGrade } from '@/domain/entities/review';

interface Props {
  item: ProblemSessionItem;
  onGraded: (grade: ReviewGrade) => void;
}

// Pick a choice, then see why — the correct answer turns forest, the tempting
// wrong pick turns red, and the explanation calls out the trap. The pick IS the
// grade (correct → gotIt, wrong → forgot), so there's no self-grade step.
export function TapTheTrapCard({ item, onGraded }: Props) {
  const theme = useTheme();
  const [picked, setPicked] = useState<string | null>(null);
  const answered = picked !== null;
  const isCorrect = answered && picked === item.correctChoiceId;

  return (
    <View style={{ flex: 1 }}>
      <ScrollView style={{ flex: 1 }} showsVerticalScrollIndicator={false}>
        <Overline color={theme.palette.ember}>Spot the trap</Overline>
        <MathText variant="h2" style={{ marginTop: 14, fontSize: 19, lineHeight: 27 }}>
          {item.statement}
        </MathText>

        <View style={{ marginTop: 20, gap: 10 }}>
          {item.choices.map((ch) => {
            const isAnswer = ch.id === item.correctChoiceId;
            const isChosen = picked === ch.id;
            let borderColor: string = theme.palette.line;
            let backgroundColor: string = theme.palette.white;
            let textColor: string = theme.palette.charcoal;
            if (answered && isAnswer) {
              borderColor = theme.palette.forest;
              backgroundColor = theme.palette.forestBg;
              textColor = theme.palette.forestInk;
            } else if (answered && isChosen) {
              borderColor = theme.palette.error;
              backgroundColor = theme.palette.errorBg;
              textColor = theme.palette.error;
            }
            return (
              <Pressable
                key={ch.id}
                disabled={answered}
                onPress={() => {
                  setPicked(ch.id);
                  if (ch.id === item.correctChoiceId) {
                    haptics.success();
                    sound.correct();
                  } else {
                    haptics.error();
                    sound.incorrect();
                  }
                }}
                style={{
                  borderRadius: 13,
                  borderWidth: 1.5,
                  borderColor,
                  backgroundColor,
                  paddingVertical: 14,
                  paddingHorizontal: 16,
                }}
              >
                <MathText variant="bodyStrong" color={textColor}>
                  {ch.text}
                </MathText>
              </Pressable>
            );
          })}
        </View>

        {answered ? (
          <FadeIn
            style={{
              marginTop: 18,
              borderLeftWidth: 3,
              borderLeftColor: isCorrect ? theme.palette.forest : theme.palette.ember,
              paddingLeft: 14,
            }}
          >
            <Overline color={isCorrect ? theme.palette.forest : theme.palette.ember}>
              {isCorrect ? 'Correct' : 'The trap'}
            </Overline>
            <MathText variant="body" color={theme.palette.ink2} style={{ marginTop: 6 }}>
              {item.explanation}
            </MathText>
          </FadeIn>
        ) : null}
      </ScrollView>

      <View style={{ paddingVertical: 16 }}>
        {answered ? (
          <Button label="Continue" onPress={() => onGraded(isCorrect ? 'gotIt' : 'forgot')} />
        ) : (
          <Text variant="sub" color={theme.palette.ink3} style={{ textAlign: 'center' }}>
            Pick the answer — then see why.
          </Text>
        )}
      </View>
    </View>
  );
}
