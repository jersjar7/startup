import React, { useState } from 'react';
import { View, Pressable } from 'react-native';
import Svg, { Path } from 'react-native-svg';
import { Screen } from '@/presentation/ui/Screen';
import { Button } from '@/presentation/ui/Button';
import { Overline } from '@/presentation/ui/Overline';
import { Text } from '@/presentation/ui/Text';
import { useTheme } from '@/core/theme/useTheme';
import { useUseCases } from '@/di/useUseCases';
import { IntroPager, INTRO_PAGE_COUNT } from './components/IntroPager';
import { SignInStep } from './components/SignInStep';
import { ExamDateStep } from './components/ExamDateStep';
import { PaceStep } from './components/PaceStep';
import { DiagnosticStep } from './components/DiagnosticStep';
import type { SignInResult } from '@/domain/usecases/SignIn';
import type { DiagnosticAnswer } from '@/domain/usecases/SubmitDiagnostic';

const TOTAL = 3; // step 0 = intro pager; 1 = exam date; 2 = pace; diagnostic follows.

// First-run flow: the "why" pager (promise / two surfaces / pedagogy /
// bounded sessions) → exam date → pace → quick diagnostic. Existing users
// sign in from screen one (offered, never required) — that imports their web
// diagnostic + exam date and skips what the website already knows.
export function OnboardingFlow({ onDone }: { onDone: () => void }) {
  const theme = useTheme();
  const uc = useUseCases();
  const [step, setStep] = useState(0);
  const [introPage, setIntroPage] = useState(0);
  const [signingIn, setSigningIn] = useState(false);
  const [imported, setImported] = useState<SignInResult | null>(null);
  const [examDate, setExamDate] = useState<string | null>(null);
  const [minutesPerDay, setMinutesPerDay] = useState(20);

  const skipDiagnostic = imported?.importedFamiliarity === true;
  const blocked = step === 1 && !examDate;
  const onIntro = step === 0;
  const lastIntroPage = introPage === INTRO_PAGE_COUNT - 1;
  const label = onIntro ? (lastIntroPage ? 'Get started' : 'Next') : step === 1 ? 'Continue' : 'Start';

  const handleSignedIn = (result: SignInResult) => {
    setImported(result);
    setSigningIn(false);
    const serverDate = result.account.examDate;
    if (serverDate) {
      setExamDate(serverDate);
      setStep(2); // exam date known — straight to pace
    } else {
      setStep(1);
    }
  };

  const onPrimary = () => {
    if (blocked) return;
    if (onIntro && !lastIntroPage) {
      setIntroPage((p) => p + 1);
      return;
    }
    if (step < TOTAL - 1) {
      setStep((s) => s + 1);
      return;
    }
    // Pace step done → save preferences, then diagnostic (unless imported).
    if (examDate) {
      void uc.setStudyPreferences.execute({ minutesPerDay, examDate }).then(() => {
        if (skipDiagnostic) onDone();
        else setStep(TOTAL);
      });
    }
  };

  const onBack = () => {
    if (onIntro) setIntroPage((p) => Math.max(0, p - 1));
    else if (step === 1) setStep(0);
    else setStep((s) => s - 1);
  };

  const finishDiagnostic = (answers: DiagnosticAnswer[]) => {
    void uc.submitDiagnostic.execute(answers).then(onDone);
  };

  if (signingIn) {
    return (
      <Screen edges={['top', 'bottom']}>
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12, paddingTop: 8, paddingBottom: 18 }}>
          <Pressable onPress={() => setSigningIn(false)} hitSlop={12}>
            <Svg width={22} height={22} viewBox="0 0 256 256" fill="none" stroke={theme.palette.ink3} strokeWidth={18}>
              <Path d="M160 48l-80 80 80 80" strokeLinecap="round" strokeLinejoin="round" />
            </Svg>
          </Pressable>
          <Overline color={theme.palette.ember}>Sign in</Overline>
        </View>
        <View style={{ flex: 1 }}>
          <SignInStep onSignedIn={handleSignedIn} />
        </View>
      </Screen>
    );
  }

  if (step >= TOTAL) {
    return <DiagnosticStep onComplete={finishDiagnostic} />;
  }

  return (
    <Screen edges={['top', 'bottom']}>
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12, paddingTop: 8, paddingBottom: 18 }}>
        {step > 0 || introPage > 0 ? (
          <Pressable onPress={onBack} hitSlop={12}>
            <Svg width={22} height={22} viewBox="0 0 256 256" fill="none" stroke={theme.palette.ink3} strokeWidth={18}>
              <Path d="M160 48l-80 80 80 80" strokeLinecap="round" strokeLinejoin="round" />
            </Svg>
          </Pressable>
        ) : null}
        {/* the intro carries its own page dots — step counter starts at setup */}
        {!onIntro ? (
          <Overline color={theme.palette.ember}>
            Step {step} of {TOTAL - 1}
          </Overline>
        ) : null}
      </View>

      <View style={{ flex: 1 }}>
        {step === 0 ? <IntroPager page={introPage} /> : null}
        {step === 1 ? <ExamDateStep value={examDate} onChange={setExamDate} /> : null}
        {step === 2 && examDate ? (
          <>
            {imported ? (
              <View
                style={{
                  backgroundColor: theme.palette.forestBg,
                  borderRadius: 12,
                  paddingHorizontal: 14,
                  paddingVertical: 10,
                  marginBottom: 14,
                }}
              >
                <Text variant="sub" color={theme.palette.forestInk}>
                  Signed in as {imported.account.displayName}
                  {imported.importedFamiliarity
                    ? ' — your diagnostic results are loaded, no need to redo them.'
                    : '.'}
                </Text>
              </View>
            ) : null}
            <PaceStep examDate={examDate} minutesPerDay={minutesPerDay} onChange={setMinutesPerDay} />
          </>
        ) : null}
      </View>

      <View style={{ paddingVertical: 16, gap: 10 }}>
        {step === 2 && !skipDiagnostic ? (
          <Text variant="sub" color={theme.palette.ink3} style={{ textAlign: 'center' }}>
            Next: 8 quick questions to map where you stand — guessing is fine, skip anytime.
          </Text>
        ) : null}
        <Button label={label} onPress={onPrimary} disabled={blocked} />
        {step === 0 && !imported ? (
          <Button label="I already have an account" variant="ghost" onPress={() => setSigningIn(true)} />
        ) : null}
      </View>
    </Screen>
  );
}
