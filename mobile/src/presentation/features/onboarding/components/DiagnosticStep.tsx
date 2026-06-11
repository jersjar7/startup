import React, { useEffect, useRef, useState } from 'react';
import { View, ActivityIndicator, Pressable } from 'react-native';
import { Screen } from '@/presentation/ui/Screen';
import { Text } from '@/presentation/ui/Text';
import { Overline } from '@/presentation/ui/Overline';
import { useTheme } from '@/core/theme/useTheme';
import { useUseCases } from '@/di/useUseCases';
import { TapTheTrapCard } from '@/presentation/features/review/components/TapTheTrapCard';
import type { Problem } from '@/domain/entities/problem';
import type { ProblemSessionItem } from '@/domain/entities/session';
import type { ReviewGrade } from '@/domain/entities/review';
import type { DiagnosticAnswer } from '@/domain/usecases/SubmitDiagnostic';

// A short check across the top chapters; each answer seeds that chapter's
// familiarity. Reuses the tap-the-trap card. Skippable.
export function DiagnosticStep({ onComplete }: { onComplete: (answers: DiagnosticAnswer[]) => void }) {
  const theme = useTheme();
  const uc = useUseCases();
  const [questions, setQuestions] = useState<Problem[] | null>(null);
  const [index, setIndex] = useState(0);
  const answers = useRef<DiagnosticAnswer[]>([]);

  useEffect(() => {
    let active = true;
    void uc.getDiagnosticQuestions.execute({ count: 8 }).then((q) => {
      if (active) setQuestions([...q]);
    });
    return () => {
      active = false;
    };
  }, [uc]);

  if (!questions) {
    return (
      <Screen>
        <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
          <ActivityIndicator color={theme.palette.ember} />
        </View>
      </Screen>
    );
  }
  if (questions.length === 0) {
    onComplete([]);
    return null;
  }

  const q = questions[index];
  const item: ProblemSessionItem = {
    kind: 'problem',
    id: q.id,
    chapterId: q.chapterId,
    tier: q.tier,
    interaction: q.interaction,
    statement: q.statement,
    choices: q.choices,
    correctChoiceId: q.correctChoiceId,
    explanation: q.explanation,
  };

  const handleGraded = (grade: ReviewGrade) => {
    answers.current.push({ problemId: q.id, chapterId: q.chapterId, correct: grade === 'gotIt' });
    const next = index + 1;
    if (next >= questions.length) onComplete([...answers.current]);
    else setIndex(next);
  };

  return (
    <Screen edges={['top', 'bottom']}>
      <View
        style={{
          flexDirection: 'row',
          justifyContent: 'space-between',
          alignItems: 'center',
          paddingTop: 8,
          paddingBottom: 6,
        }}
      >
        {/* One overline, one header pattern — the card's label is suppressed */}
        <Overline color={theme.palette.ink3}>
          Placement · {index + 1} of {questions.length}
        </Overline>
        <Pressable onPress={() => onComplete([...answers.current])} hitSlop={10}>
          <Text variant="sub" color={theme.palette.ink3}>
            Skip
          </Text>
        </Pressable>
      </View>
      <View style={{ flex: 1 }}>
        <TapTheTrapCard key={q.id} item={item} onGraded={handleGraded} overlineOverride="" />
      </View>
    </Screen>
  );
}
