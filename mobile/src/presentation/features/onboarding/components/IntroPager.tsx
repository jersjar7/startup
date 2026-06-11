import React from 'react';
import { View } from 'react-native';
import { Text } from '@/presentation/ui/Text';
import { FadeIn } from '@/presentation/ui/FadeIn';
import { useTheme } from '@/core/theme/useTheme';
import {
  OnbHonestRing,
  TwoSurfacesGraphic,
  SpacedReturnGraphic,
  OnbBoundedSession,
} from './OnboardingGraphics';

export const INTRO_PAGE_COUNT = 4;

const PAGES = [
  {
    headline: 'No false promises',
    body:
      'We track concept mastery — never a "chance to pass," because nobody can promise that. ' +
      "Master what drives the questions, however they're worded, and you walk in ready.",
    Graphic: OnbHonestRing,
  },
  {
    headline: 'Phone reviews. Desk solves.',
    body:
      'The phone drills the same question bank you study at fe4raccoons.com — quick recall here, ' +
      'lessons and full problems at your desk. Progress sync is shipping soon; for now the phone tracks your work on this device.',
    Graphic: TwoSurfacesGraphic,
  },
  {
    headline: 'Back before you forget',
    body:
      'Each question returns right before it would fade — that timing is what makes it stick. ' +
      'Miss one and it simply comes back sooner.',
    Graphic: SpacedReturnGraphic,
  },
  {
    headline: 'Short. Bounded. Honest.',
    body:
      'A session is a fixed set, not a feed — done means done. You grade your own recall, ' +
      "and honest grades are what make tomorrow's schedule right.",
    Graphic: OnbBoundedSession,
  },
] as const;

// The app's "why", one idea per page: the honest promise, the two-surface
// model, the pedagogy, the bounded session. Graphic-led, two sentences max.
export function IntroPager({ page }: { page: number }) {
  const theme = useTheme();
  const { headline, body, Graphic } = PAGES[Math.min(page, PAGES.length - 1)];
  return (
    <FadeIn key={page} offset={10} style={{ flex: 1 }}>
      <View style={{ flex: 1, justifyContent: 'center' }}>
        <View style={{ alignItems: 'center', marginBottom: 36 }}>
          <Graphic />
        </View>
        <Text variant="h1">{headline}</Text>
        <Text variant="body" color={theme.palette.ink2} style={{ marginTop: 10 }}>
          {body}
        </Text>
      </View>
      <View style={{ flexDirection: 'row', gap: 7, justifyContent: 'center', paddingBottom: 10 }}>
        {PAGES.map((_, i) => (
          <View
            key={i}
            style={{
              width: i === page ? 18 : 7,
              height: 7,
              borderRadius: 4,
              backgroundColor: i === page ? theme.palette.ember : theme.palette.creamDark,
            }}
          />
        ))}
      </View>
    </FadeIn>
  );
}
