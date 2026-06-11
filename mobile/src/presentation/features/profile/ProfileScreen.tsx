import React, { useCallback, useState } from 'react';
import { View, ActivityIndicator, Switch, Platform } from 'react-native';
import DateTimePicker from '@react-native-community/datetimepicker';
import { useFocusEffect } from '@react-navigation/native';
import { Screen } from '@/presentation/ui/Screen';
import { Text } from '@/presentation/ui/Text';
import { Card } from '@/presentation/ui/Card';
import { Overline } from '@/presentation/ui/Overline';
import { Divider } from '@/presentation/ui/Divider';
import { ProgressRing } from '@/presentation/ui/ProgressRing';
import { ListRow } from '@/presentation/ui/ListRow';
import { OptionSheet, type SheetOption } from '@/presentation/ui/OptionSheet';
import { useTheme } from '@/core/theme/useTheme';
import { masteryColor } from '@/presentation/ui/semantics';
import { useUseCases } from '@/di/useUseCases';
import { useAppRestart } from '@/presentation/bootstrap/AppRestart';
import { useProfileViewModel } from './useProfileViewModel';

const DAY = 24 * 60 * 60 * 1000;
const PACE_OPTIONS: readonly SheetOption[] = [10, 20, 30, 45].map((m) => ({
  label: `${m} min / day`,
  value: String(m),
}));
const DATE_OPTIONS: readonly SheetOption[] = (
  [
    ['About 1 month away', 30],
    ['About 2 months away', 60],
    ['About 3 months away', 90],
    ['About 6 months away', 180],
  ] as const
).map(([label, days]) => ({
  label,
  value: new Date(Date.now() + days * DAY).toISOString().slice(0, 10),
}));

type Editing = 'pace' | 'date' | 'reminder' | null;

// Values are minutes since local midnight; "custom" opens the native time
// picker (real study slots are "the 7:15 bus", not round numbers).
const REMINDER_OPTIONS: readonly SheetOption[] = [
  { label: 'Off', value: 'off' },
  { label: '8:00 AM', value: '480' },
  { label: '12:00 PM', value: '720' },
  { label: '6:00 PM', value: '1080' },
  { label: '9:00 PM', value: '1260' },
  ...(Platform.OS !== 'web' ? [{ label: 'Custom time…', value: 'custom' }] : []),
];

export function formatReminderTime(minutes: number | null): string {
  if (minutes === null) return 'Off';
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  const period = h < 12 ? 'AM' : 'PM';
  const hour12 = h % 12 === 0 ? 12 : h % 12;
  return `${hour12}:${String(m).padStart(2, '0')} ${period}`;
}

export function ProfileScreen() {
  const theme = useTheme();
  const uc = useUseCases();
  const restart = useAppRestart();
  const { loading, overall, masteredCount, topicCount, prefs, reminderMinutes, soundEnabled, account, streak, totalReps, reload, update, setReminder, setSound, signOut } =
    useProfileViewModel();
  const [editing, setEditing] = useState<Editing>(null);
  const [confirmingReset, setConfirmingReset] = useState(false);
  const [pickingTime, setPickingTime] = useState(false);

  const doReset = () => {
    setConfirmingReset(false);
    void uc.resetAllProgress.execute().then(restart);
  };

  useFocusEffect(
    useCallback(() => {
      void reload();
    }, [reload]),
  );

  if (loading || !overall) {
    return (
      <Screen>
        <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
          <ActivityIndicator color={theme.palette.ember} />
        </View>
      </Screen>
    );
  }

  return (
    <Screen scroll>
      <Text variant="h1" style={{ marginTop: 8 }}>
        Profile
      </Text>

      <View style={{ marginTop: 18 }}>
        <Card style={{ flexDirection: 'row', alignItems: 'center', gap: 18, borderRadius: theme.radius.hero }}>
          <ProgressRing percent={overall.percent} />
          <View style={{ flex: 1 }}>
            <Text variant="title">Concept mastery</Text>
            <Text variant="sub" color={theme.palette.ink3} style={{ marginTop: 2 }}>
              {masteredCount} of {topicCount} chapters mastered
            </Text>
            <Text variant="sub" color={theme.palette.ink4} style={{ marginTop: 7, fontSize: 11, lineHeight: 15 }}>
              How well you know the concepts the FE tests, tracked on this phone. Never a pass probability.
            </Text>
          </View>
        </Card>
      </View>

      {/* lifetime work on this device — the habit has a home here */}
      <Card style={{ marginTop: 12, flexDirection: 'row' }}>
        <View style={{ flex: 1, alignItems: 'center' }}>
          <Text variant="mono" style={{ fontSize: 20 }}>
            {streak}
          </Text>
          <Text variant="sub" color={theme.palette.ink3} style={{ marginTop: 2 }}>
            day streak
          </Text>
        </View>
        <View style={{ width: 1, backgroundColor: theme.palette.line }} />
        <View style={{ flex: 1, alignItems: 'center' }}>
          <Text variant="mono" style={{ fontSize: 20 }}>
            {totalReps}
          </Text>
          <Text variant="sub" color={theme.palette.ink3} style={{ marginTop: 2 }}>
            {totalReps === 1 ? 'card reviewed' : 'cards reviewed'}
          </Text>
        </View>
      </Card>

      <View style={{ marginTop: 24, marginBottom: 2 }}>
        <Overline>Plan</Overline>
      </View>
      {prefs ? (
        <>
          <ListRow
            title="Exam date"
            onPress={() => setEditing('date')}
            right={
              <Text variant="sub" color={theme.palette.ink3}>
                {formatDate(prefs.examDate)}
              </Text>
            }
          />
          <Divider />
          <ListRow
            title="Daily pace"
            onPress={() => setEditing('pace')}
            right={
              <Text variant="sub" color={theme.palette.ink3}>
                {prefs.minutesPerDay} min
              </Text>
            }
          />
          <Divider />
          <ListRow
            title="Reminders"
            onPress={() => setEditing('reminder')}
            right={
              <Text variant="sub" color={theme.palette.ink3}>
                {formatReminderTime(reminderMinutes)}
              </Text>
            }
          />
          <Divider />
          <ListRow
            title="Sound effects"
            subtitle="A subtle tick when you answer"
            right={
              <Switch
                testID="sound-switch"
                value={soundEnabled}
                onValueChange={setSound}
                trackColor={{ false: theme.palette.line, true: theme.palette.forest }}
                thumbColor={theme.palette.white}
                ios_backgroundColor={theme.palette.line}
              />
            }
          />
        </>
      ) : null}

      <View style={{ marginTop: 24, marginBottom: 2 }}>
        <Overline>Account</Overline>
      </View>
      <Text variant="sub" color={theme.palette.ink4} style={{ fontSize: 11, lineHeight: 15, marginBottom: 4 }}>
        Signed in, your reviews sync to your fe4raccoons.com account.
      </Text>
      {account ? (
        <>
          <ListRow
            title={account.displayName}
            subtitle={account.email}
            right={
              <Text variant="bodyStrong" color={theme.palette.ink3} onPress={() => void signOut()}>
                Sign out
              </Text>
            }
          />
          <Divider />
        </>
      ) : null}
      <ListRow
        title="Reset this device"
        subtitle="Clears progress stored on this phone"
        chevron={false}
        onPress={() => setConfirmingReset(true)}
        right={
          <Text variant="bodyStrong" color={theme.palette.error}>
            Reset
          </Text>
        }
      />

      <OptionSheet
        visible={editing === 'pace'}
        title="Minutes per day"
        options={PACE_OPTIONS}
        selected={prefs ? String(prefs.minutesPerDay) : undefined}
        onSelect={(v) => {
          void update({ minutesPerDay: Number(v) });
          setEditing(null);
        }}
        onClose={() => setEditing(null)}
      />
      <OptionSheet
        visible={editing === 'date'}
        title="When's your exam?"
        options={DATE_OPTIONS}
        selected={prefs?.examDate}
        onSelect={(v) => {
          void update({ examDate: v });
          setEditing(null);
        }}
        onClose={() => setEditing(null)}
      />
      <OptionSheet
        visible={editing === 'reminder'}
        title="Daily reminder"
        options={REMINDER_OPTIONS}
        selected={reminderMinutes === null ? 'off' : String(reminderMinutes)}
        onSelect={(v) => {
          setEditing(null);
          if (v === 'custom') setPickingTime(true);
          else void setReminder(v === 'off' ? null : Number(v));
        }}
        onClose={() => setEditing(null)}
      />
      {pickingTime ? (
        <DateTimePicker
          value={new Date(2026, 0, 1, Math.floor((reminderMinutes ?? 480) / 60), (reminderMinutes ?? 480) % 60)}
          mode="time"
          display="spinner"
          onChange={(e, d) => {
            setPickingTime(false);
            if (e.type === 'set' && d) void setReminder(d.getHours() * 60 + d.getMinutes());
          }}
        />
      ) : null}
      <OptionSheet
        visible={confirmingReset}
        title="Reset this device? This can't be undone"
        options={[{ label: 'Reset this device', value: 'reset' }]}
        onSelect={doReset}
        onClose={() => setConfirmingReset(false)}
      />
    </Screen>
  );
}

function formatDate(iso: string): string {
  return new Date(`${iso}T00:00:00`).toLocaleDateString(undefined, {
    month: 'long',
    day: 'numeric',
    year: 'numeric',
  });
}
