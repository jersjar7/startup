import React, { useState } from 'react';
import { View, Pressable } from 'react-native';
import { Text } from '@/presentation/ui/Text';
import { useTheme } from '@/core/theme/useTheme';

const DAY = 24 * 60 * 60 * 1000;

// Presets for now; a calendar picker comes later. Each maps to an exam date.
const PRESETS = [
  { label: 'About 1 month away', days: 30 },
  { label: 'About 2 months away', days: 60 },
  { label: 'About 3 months away', days: 90 },
  { label: 'About 6 months away', days: 180 },
];

interface Props {
  value: string | null;
  onChange: (examDate: string) => void;
}

export function ExamDateStep({ onChange }: Props) {
  const theme = useTheme();
  const [selected, setSelected] = useState<number | null>(null);

  const pick = (i: number) => {
    setSelected(i);
    onChange(new Date(Date.now() + PRESETS[i].days * DAY).toISOString().slice(0, 10));
  };

  return (
    <View>
      <Text variant="h1">When's your exam?</Text>
      <Text variant="sub" color={theme.palette.ink3} style={{ marginTop: 4 }}>
        We'll pace your plan to land on it.
      </Text>

      <View style={{ marginTop: 22, gap: 11 }}>
        {PRESETS.map((p, i) => {
          const on = selected === i;
          return (
            <Pressable
              key={p.label}
              onPress={() => pick(i)}
              style={{
                height: 56,
                borderRadius: 14,
                paddingHorizontal: 18,
                justifyContent: 'center',
                backgroundColor: on ? theme.palette.emberBg : theme.palette.white,
                borderWidth: 1.5,
                borderColor: on ? theme.palette.ember : theme.palette.line,
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
  );
}
