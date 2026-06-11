import React, { useState } from 'react';
import { View, Pressable } from 'react-native';
import Svg, { Path } from 'react-native-svg';
import { useNavigation } from '@react-navigation/native';
import { Screen } from '@/presentation/ui/Screen';
import { Overline } from '@/presentation/ui/Overline';
import { OptionSheet } from '@/presentation/ui/OptionSheet';
import { useTheme } from '@/core/theme/useTheme';
import { useUseCases } from '@/di/useUseCases';
import { SignInStep } from '@/presentation/features/onboarding/components/SignInStep';
import type { SignInResult } from '@/domain/usecases/SignIn';

// Sign-in for users who onboarded as guests. If the account's exam date
// differs from this phone's, ask ONCE which is right — the date drives all
// pacing math, so it must never be silently clobbered (panel verdict).
export function SignInScreen() {
  const theme = useTheme();
  const uc = useUseCases();
  const nav = useNavigation();
  const [conflict, setConflict] = useState<{ server: string; local: string } | null>(null);

  const finish = () => {
    void uc.syncNow.execute();
    nav.goBack();
  };

  const handleSignedIn = async (result: SignInResult) => {
    const prefs = await uc.getStudyPreferences.execute();
    const server = result.account.examDate;
    if (prefs && server && server !== prefs.examDate) {
      setConflict({ server, local: prefs.examDate });
      return;
    }
    finish();
  };

  const resolve = async (choice: string) => {
    const prefs = await uc.getStudyPreferences.execute();
    if (conflict && prefs) {
      // keep-phone writes the phone's date up; use-account adopts the server's.
      const examDate = choice === 'account' ? conflict.server : prefs.examDate;
      await uc.setStudyPreferences.execute({ ...prefs, examDate });
    }
    setConflict(null);
    finish();
  };

  const fmt = (iso: string) =>
    new Date(`${iso}T00:00:00`).toLocaleDateString(undefined, { month: 'long', day: 'numeric', year: 'numeric' });

  return (
    <Screen edges={['top', 'bottom']}>
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12, paddingTop: 8, paddingBottom: 18 }}>
        <Pressable onPress={() => nav.goBack()} hitSlop={12}>
          <Svg width={22} height={22} viewBox="0 0 256 256" fill="none" stroke={theme.palette.ink3} strokeWidth={18}>
            <Path d="M160 48l-80 80 80 80" strokeLinecap="round" strokeLinejoin="round" />
          </Svg>
        </Pressable>
        <Overline color={theme.palette.ember}>Sign in</Overline>
      </View>
      <SignInStep onSignedIn={(r) => void handleSignedIn(r)} />
      <OptionSheet
        visible={conflict !== null}
        title="Which exam date is right?"
        options={
          conflict
            ? [
                { label: `Your account: ${fmt(conflict.server)}`, value: 'account' },
                { label: `This phone: ${fmt(conflict.local)}`, value: 'phone' },
              ]
            : []
        }
        onSelect={(v) => void resolve(v)}
        onClose={() => void resolve('phone')}
      />
    </Screen>
  );
}
