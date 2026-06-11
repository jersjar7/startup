import React from 'react';
import { View } from 'react-native';
import { Text } from '@/presentation/ui/Text';
import { Card } from '@/presentation/ui/Card';
import { useTheme } from '@/core/theme/useTheme';

function Point({ title, body }: { title: string; body: string }) {
  const theme = useTheme();
  return (
    <View style={{ paddingVertical: 12 }}>
      <Text variant="title">{title}</Text>
      <Text variant="body" color={theme.palette.ink2} style={{ marginTop: 3 }}>
        {body}
      </Text>
    </View>
  );
}

// The honest promise — the first thing a new user reads.
export function HowItWorksStep() {
  const theme = useTheme();
  return (
    <View>
      <Text variant="h1">How this works</Text>

      <View style={{ marginTop: 18 }}>
        <Point
          title="Short daily sessions"
          body="Concepts come back right before you'd forget them — that's what makes them stick."
        />
        <Point
          title="Track real mastery"
          body="We measure how well you've mastered the concepts the FE tests — topic by topic."
        />
      </View>

      <Card style={{ marginTop: 10, borderLeftWidth: 3, borderLeftColor: theme.palette.forest }}>
        <Text variant="title" color={theme.palette.forestInk}>
          No false promises
        </Text>
        <Text variant="body" color={theme.palette.ink2} style={{ marginTop: 8 }}>
          Mastery isn't a guaranteed pass — nobody can promise that. But master the lessons and you'll
          recognize what drives the questions, however they're asked. That's how you walk in ready.
        </Text>
      </Card>
    </View>
  );
}
