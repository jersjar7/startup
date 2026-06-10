import React, { useState } from 'react';
import { View, Pressable } from 'react-native';
import Svg, { Path } from 'react-native-svg';
import { Screen } from '@/presentation/ui/Screen';
import { Button } from '@/presentation/ui/Button';
import { Overline } from '@/presentation/ui/Overline';
import { useTheme } from '@/core/theme/useTheme';
import { useUseCases } from '@/di/useUseCases';
import { HowItWorksStep } from './components/HowItWorksStep';
import { ExamDateStep } from './components/ExamDateStep';
import { PaceStep } from './components/PaceStep';

const TOTAL = 3;

// First-run flow: promise → exam date → pace. On finish, saves preferences and
// hands control back to the gate. Self-contained step state (no nested navigator).
export function OnboardingFlow({ onDone }: { onDone: () => void }) {
  const theme = useTheme();
  const uc = useUseCases();
  const [step, setStep] = useState(0);
  const [examDate, setExamDate] = useState<string | null>(null);
  const [minutesPerDay, setMinutesPerDay] = useState(20);

  const blocked = step === 1 && !examDate;
  const label = step === 0 ? 'Get started' : step === 1 ? 'Continue' : 'Start';

  const onPrimary = () => {
    if (blocked) return;
    if (step < TOTAL - 1) {
      setStep((s) => s + 1);
      return;
    }
    if (examDate) {
      void uc.setStudyPreferences.execute({ minutesPerDay, examDate }).then(onDone);
    }
  };

  return (
    <Screen edges={['top', 'bottom']}>
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12, paddingTop: 8, paddingBottom: 18 }}>
        {step > 0 ? (
          <Pressable onPress={() => setStep((s) => s - 1)} hitSlop={12}>
            <Svg width={22} height={22} viewBox="0 0 256 256" fill="none" stroke={theme.palette.ink3} strokeWidth={18}>
              <Path d="M160 48l-80 80 80 80" strokeLinecap="round" strokeLinejoin="round" />
            </Svg>
          </Pressable>
        ) : null}
        <Overline color={theme.palette.ember}>
          Step {step + 1} of {TOTAL}
        </Overline>
      </View>

      <View style={{ flex: 1 }}>
        {step === 0 ? <HowItWorksStep /> : null}
        {step === 1 ? <ExamDateStep value={examDate} onChange={setExamDate} /> : null}
        {step === 2 && examDate ? (
          <PaceStep examDate={examDate} minutesPerDay={minutesPerDay} onChange={setMinutesPerDay} />
        ) : null}
      </View>

      <View style={{ paddingVertical: 16 }}>
        <Button label={label} onPress={onPrimary} variant={blocked ? 'ghost' : 'primary'} />
      </View>
    </Screen>
  );
}
