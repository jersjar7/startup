import React, { useEffect, useState } from 'react';
import { View, Pressable } from 'react-native';
import Svg, { Path } from 'react-native-svg';
import { Screen } from '@/presentation/ui/Screen';
import { Text } from '@/presentation/ui/Text';
import { Button } from '@/presentation/ui/Button';
import { FadeIn } from '@/presentation/ui/FadeIn';
import { OptionSheet, type SheetOption } from '@/presentation/ui/OptionSheet';
import { useTheme } from '@/core/theme/useTheme';
import { haptics } from '@/core/haptics';
import { useUseCases } from '@/di/useUseCases';

const REMINDER_OPTIONS: readonly SheetOption[] = [
  { label: '8:00 AM', value: '480' },
  { label: '12:00 PM', value: '720' },
  { label: '6:00 PM', value: '1080' },
  { label: '9:00 PM', value: '1260' },
];

interface Props {
  reviewed: number;
  streak: number;
  onClose: () => void;
}

// Bounded ending — celebrate, then stop. No "keep going" push.
export function DoneView({ reviewed, streak, onClose }: Props) {
  const theme = useTheme();
  const uc = useUseCases();
  const [reminderOff, setReminderOff] = useState(false);
  const [picking, setPicking] = useState(false);

  // The one earned moment — a single success tap as the screen lands.
  useEffect(() => {
    haptics.success();
    // Quiet streak-protection nudge — only while reminders are off, at the
    // moment motivation peaks. Disappears forever once a reminder exists.
    void uc.getReminder.execute().then((h) => setReminderOff(h === null));
  }, [uc]);

  return (
    <Screen edges={['top', 'bottom']}>
      <FadeIn offset={16} style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
        <View
          style={{
            width: 88,
            height: 88,
            borderRadius: 44,
            backgroundColor: theme.palette.forestBg,
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <Svg width={42} height={42} viewBox="0 0 256 256" fill="none" stroke={theme.palette.forest} strokeWidth={20}>
            <Path d="M40 144l52 52L216 72" strokeLinecap="round" strokeLinejoin="round" />
          </Svg>
        </View>
        <Text variant="h1" style={{ marginTop: 24 }}>
          Done for today
        </Text>
        <Text variant="body" color={theme.palette.ink2} style={{ marginTop: 8, textAlign: 'center' }}>
          {reviewed === 0
            ? "Nothing due right now — you're caught up."
            : `${reviewed} cards reviewed. That's the work — see you tomorrow.`}
        </Text>

        {streak > 0 ? (
          <View
            style={{
              flexDirection: 'row',
              alignItems: 'center',
              gap: 7,
              marginTop: 22,
              backgroundColor: theme.palette.sunbeamBg,
              paddingHorizontal: 14,
              paddingVertical: 9,
              borderRadius: theme.radius.pill,
            }}
          >
            <Svg width={17} height={17} viewBox="0 0 256 256" fill={theme.palette.sunbeam}>
              <Path d="M173.8 32.3a8 8 0 0 0-12.6 3.2c-9 24-25 38.6-39.4 51.6-15.7 14.2-30.6 27.6-30.6 49 0 10 3 18.6 7.8 25.4-13-3.8-23-13.6-27.8-27a8 8 0 0 0-13.4-3C45.3 146.3 40 165 40 184a88 88 0 0 0 176 0c0-62.7-31.6-119.6-42.2-151.7" />
            </Svg>
            <Text variant="bodyStrong" color={theme.palette.sunbeamInk}>
              {streak}-day streak
            </Text>
          </View>
        ) : null}

        {reminderOff && streak > 0 ? (
          <Pressable onPress={() => setPicking(true)} hitSlop={8} style={{ marginTop: 18 }}>
            <Text variant="sub" color={theme.palette.ink2}>
              Protect the streak — <Text variant="bodyStrong" color={theme.palette.ember}>set a reminder</Text>
            </Text>
          </Pressable>
        ) : null}
      </FadeIn>
      <View style={{ paddingVertical: 16 }}>
        <Button label="Done" variant="ghost" onPress={onClose} />
      </View>
      <OptionSheet
        visible={picking}
        title="Daily reminder"
        options={REMINDER_OPTIONS}
        onSelect={(v) => {
          void uc.setReminder.execute({ minutes: Number(v) }).then(() => setReminderOff(false));
          setPicking(false);
        }}
        onClose={() => setPicking(false)}
      />
    </Screen>
  );
}
