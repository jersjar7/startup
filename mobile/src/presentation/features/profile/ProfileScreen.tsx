import React, { useCallback, useState } from 'react';
import { View, ActivityIndicator } from 'react-native';
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

const REMINDER_OPTIONS: readonly SheetOption[] = [
  { label: 'Off', value: 'off' },
  { label: '8:00 AM', value: '8' },
  { label: '12:00 PM', value: '12' },
  { label: '6:00 PM', value: '18' },
  { label: '9:00 PM', value: '21' },
];

function formatHour(h: number | null): string {
  if (h === null) return 'Off';
  const period = h < 12 ? 'AM' : 'PM';
  const hour12 = h % 12 === 0 ? 12 : h % 12;
  return `${hour12}:00 ${period}`;
}

export function ProfileScreen() {
  const theme = useTheme();
  const uc = useUseCases();
  const restart = useAppRestart();
  const { loading, overall, masteredCount, topicCount, prefs, reminderHour, reload, update, setReminder } =
    useProfileViewModel();
  const [editing, setEditing] = useState<Editing>(null);
  const [confirmingReset, setConfirmingReset] = useState(false);

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
          <ProgressRing percent={overall.percent} color={masteryColor(overall.state, theme)} />
          <View style={{ flex: 1 }}>
            <Text variant="title">Concept mastery</Text>
            <Text variant="sub" color={theme.palette.ink3} style={{ marginTop: 2 }}>
              {masteredCount} of {topicCount} topics mastered
            </Text>
            <Text variant="sub" color={theme.palette.ink4} style={{ marginTop: 7, fontSize: 11, lineHeight: 15 }}>
              Mastery of the concepts the FE tests — not a probability of passing.
            </Text>
          </View>
        </Card>
      </View>

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
                {formatHour(reminderHour)}
              </Text>
            }
          />
        </>
      ) : null}

      <View style={{ marginTop: 24, marginBottom: 2 }}>
        <Overline>Account</Overline>
      </View>
      <ListRow
        title="Reset progress"
        subtitle="Clear everything and start over"
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
        selected={reminderHour === null ? 'off' : String(reminderHour)}
        onSelect={(v) => {
          void setReminder(v === 'off' ? null : Number(v));
          setEditing(null);
        }}
        onClose={() => setEditing(null)}
      />
      <OptionSheet
        visible={confirmingReset}
        title="Reset everything? This can't be undone"
        options={[{ label: 'Reset progress', value: 'reset' }]}
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
