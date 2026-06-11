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

// Copy ratified by the fresh-eyes + brand panel (positive-first, plain,
// landing-page voice) — see onb-copy workflow, 2026-06-11.
const PAGES = [
  {
    headline: 'Everything the FE Civil tests',
    body:
      'All 15 NCEES chapters, 135 lessons, and 1,126 practice problems aligned to the FE Handbook. ' +
      'Master the concepts behind them and you can answer the question, however the exam words it.',
    Graphic: OnbHonestRing,
  },
  {
    headline: 'Practice here. Go deeper online.',
    body:
      'This app is for quick review. Full lessons and exam-style problems are free at fe4raccoons.com. ' +
      'Sign in and your phone reviews count on the website too.',
    Graphic: TwoSurfacesGraphic,
  },
  {
    headline: 'Back before you forget',
    body:
      "Each question comes back right before you'd forget it. That timing is what makes it stick. " +
      'Miss one and it just comes back sooner.',
    Graphic: SpacedReturnGraphic,
  },
  {
    headline: 'Done means done',
    body:
      'Each session is a short, fixed set of questions, not an endless feed. ' +
      'You rate how well you remembered each one, and that sets when it comes back.',
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
