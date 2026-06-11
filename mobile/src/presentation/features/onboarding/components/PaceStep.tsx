import React, { useEffect, useState } from 'react';
import { View, Pressable } from 'react-native';
import { Text } from '@/presentation/ui/Text';
import { Card } from '@/presentation/ui/Card';
import { Overline } from '@/presentation/ui/Overline';
import { ProgressBar } from '@/presentation/ui/ProgressBar';
import { useTheme } from '@/core/theme/useTheme';
import { useUseCases } from '@/di/useUseCases';
import type { StudyPlan } from '@/domain/entities/plan';

const OPTIONS = [10, 20, 30, 45];

interface Props {
  examDate: string;
  minutesPerDay: number;
  onChange: (minutes: number) => void;
}

// Pick minutes/day and see the honest projection — concept mastery, never odds.
export function PaceStep({ examDate, minutesPerDay, onChange }: Props) {
  const theme = useTheme();
  const uc = useUseCases();
  const [plan, setPlan] = useState<StudyPlan | null>(null);

  useEffect(() => {
    let active = true;
    void (async () => {
      const p = await uc.previewStudyPlan.execute({ minutesPerDay, examDate, now: Date.now() });
      if (active) setPlan(p);
    })();
    return () => {
      active = false;
    };
  }, [uc, minutesPerDay, examDate]);

  return (
    <View>
      <Text variant="h1">Your daily pace</Text>
      <Text variant="sub" color={theme.palette.ink3} style={{ marginTop: 4 }}>
        How much time can you give it most days?
      </Text>

      <View style={{ flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'space-between', marginTop: 18 }}>
        {OPTIONS.map((m) => {
          const on = m === minutesPerDay;
          return (
            <Pressable
              key={m}
              onPress={() => onChange(m)}
              style={{
                width: '48%',
                marginBottom: 11,
                paddingVertical: 16,
                borderRadius: 15,
                alignItems: 'center',
                backgroundColor: on ? theme.palette.emberBg : theme.palette.white,
                borderWidth: 1.5,
                borderColor: on ? theme.palette.ember : theme.palette.line,
              }}
            >
              <Text variant="mono" color={on ? theme.palette.ember : theme.palette.charcoal} style={{ fontSize: 22 }}>
                {m}
              </Text>
              <Text variant="sub" color={theme.palette.ink3} style={{ marginTop: 2 }}>
                min / day
              </Text>
            </Pressable>
          );
        })}
      </View>

      {plan ? (
        <Card style={{ marginTop: 12, borderRadius: theme.radius.hero }}>
          <Overline>At this pace</Overline>
          <View style={{ flexDirection: 'row', alignItems: 'flex-end', gap: 8, marginTop: 10 }}>
            <Text variant="mono" color={theme.palette.forest} style={{ fontSize: 32 }}>
              ~{plan.projection.projectedPercent}%
            </Text>
            <Text variant="sub" color={theme.palette.ink3} style={{ marginBottom: 4 }}>
              mastery by {formatDate(dayBefore(examDate))}, the day before your exam
            </Text>
          </View>
          <View style={{ marginTop: 12 }}>
            <ProgressBar percent={plan.projection.projectedPercent} color={theme.palette.forest} height={7} />
          </View>
          <Text variant="sub" color={theme.palette.ink2} style={{ marginTop: 12 }}>
            {projectionCaption(plan.projection.projectedPercent)}
          </Text>
          <Text variant="sub" color={theme.palette.ink3} style={{ marginTop: 6 }}>
            Exam day ({formatDate(examDate)}) stays light: review, rest, walk in ready.
          </Text>
        </Card>
      ) : null}
    </View>
  );
}

// Caption must match the number above it — calling 37% "strong mastery"
// oversells in the same breath the app disclaims (honest-mastery rule).
function projectionCaption(pct: number): string {
  if (pct >= 75) return 'Strong mastery of the core topics. Never a guaranteed pass.';
  if (pct >= 50) return 'Working mastery of the core topics. Never a guaranteed pass.';
  return 'A solid foundation in the highest-weight topics. Never a guaranteed pass.';
}

// Mastery targets the day BEFORE the exam — the last day is rest, not cramming.
function dayBefore(iso: string): string {
  const d = new Date(`${iso}T00:00:00`);
  d.setDate(d.getDate() - 1);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}

function formatDate(iso: string): string {
  return new Date(`${iso}T00:00:00`).toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
}
