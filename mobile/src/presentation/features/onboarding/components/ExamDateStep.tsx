import React, { useState } from 'react';
import { View, Pressable, Platform } from 'react-native';
import DateTimePicker from '@react-native-community/datetimepicker';
import { Text } from '@/presentation/ui/Text';
import { useTheme } from '@/core/theme/useTheme';

const DAY = 24 * 60 * 60 * 1000;

// The FE is a scheduled appointment — the exact day is the primary input
// (deriving a precise countdown from a fuzzy preset was false precision).
// Presets remain only for people who haven't booked yet.
const PRESETS: { label: string; days: number }[] = [
  { label: 'About 1 month away', days: 30 },
  { label: 'About 2 months away', days: 60 },
  { label: 'About 3 months away', days: 90 },
  { label: 'About 6 months away', days: 180 },
];

interface Props {
  value: string | null;
  onChange: (examDate: string) => void;
}

const toIso = (d: Date): string =>
  `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;

export function ExamDateStep({ value, onChange }: Props) {
  const theme = useTheme();
  const [mode, setMode] = useState<'exact' | 'unscheduled' | null>(null);
  const [presetIdx, setPresetIdx] = useState<number | null>(null);
  const supportsPicker = Platform.OS !== 'web';

  const pickExact = (d: Date) => {
    setMode('exact');
    setPresetIdx(null);
    onChange(toIso(d));
  };

  const pickPreset = (i: number) => {
    setMode('unscheduled');
    setPresetIdx(i);
    onChange(toIso(new Date(Date.now() + PRESETS[i].days * DAY)));
  };

  return (
    <View>
      <Text variant="h1">When's your exam?</Text>
      <Text variant="sub" color={theme.palette.ink3} style={{ marginTop: 4 }}>
        We'll pace your plan to have you ready the day before.
      </Text>

      {supportsPicker ? (
        <View
          style={{
            marginTop: 22,
            borderRadius: 16,
            backgroundColor: theme.palette.white,
            borderWidth: 1.5,
            borderColor: mode === 'exact' ? theme.palette.ember : 'rgba(44,44,44,0.15)',
            paddingVertical: 8,
            alignItems: 'center',
          }}
        >
          <Text variant="bodyStrong" style={{ marginTop: 6 }}>
            Pick your exam day
          </Text>
          <DateTimePicker
            value={value && mode === 'exact' ? new Date(`${value}T00:00:00`) : new Date(Date.now() + 60 * DAY)}
            mode="date"
            display={Platform.OS === 'ios' ? 'inline' : 'default'}
            minimumDate={new Date(Date.now() + DAY)}
            onChange={(_e, d) => {
              if (d) pickExact(d);
            }}
            accentColor={theme.palette.ember}
            style={{ alignSelf: 'center' }}
          />
        </View>
      ) : null}

      <View style={{ marginTop: 18 }}>
        <Text variant="sub" color={theme.palette.ink3} style={{ marginBottom: 8 }}>
          Haven't scheduled it yet? Pick a rough window. Adjust anytime in Profile.
        </Text>
        <View style={{ gap: 11 }}>
          {PRESETS.map((p, i) => {
            const on = mode === 'unscheduled' && presetIdx === i;
            return (
              <Pressable
                key={p.label}
                onPress={() => pickPreset(i)}
                style={{
                  height: 56,
                  borderRadius: 14,
                  paddingHorizontal: 18,
                  justifyContent: 'center',
                  backgroundColor: on ? theme.palette.emberBg : theme.palette.white,
                  borderWidth: 1.5,
                  borderColor: on ? theme.palette.ember : 'rgba(44,44,44,0.15)',
                }}
              >
                <Text variant="bodyStrong" color={on ? theme.palette.emberInk : theme.palette.charcoal}>
                  {p.label}
                </Text>
              </Pressable>
            );
          })}
        </View>
      </View>
    </View>
  );
}
