import React from 'react';
import { View } from 'react-native';
import { Card } from '@/presentation/ui/Card';
import { Text } from '@/presentation/ui/Text';
import { Overline } from '@/presentation/ui/Overline';
import { Divider } from '@/presentation/ui/Divider';
import { useTheme } from '@/core/theme/useTheme';
import { interactionLabel } from '@/presentation/ui/semantics';
import type { SessionItem } from '@/domain/entities/session';
import type { InteractionMode } from '@/domain/entities/tiers';

// Pre-session view shows WHAT KIND of work is due, never the prompts —
// reading a prompt before the session is a free recognition pass, which
// breaks the generation-not-recognition rule (North Star #1). Type chips are
// fine in aggregate; per-item they prime trick-hunting (rule #2).
interface Props {
  items: readonly SessionItem[];
  chapterNames?: Record<string, string>;
  /** Today's queue is well under the chosen pace — say so, or it reads as falling behind. */
  lightDay?: boolean;
}

export function SessionSummary({ items, chapterNames = {}, lightDay = false }: Props) {
  const theme = useTheme();

  const counts = new Map<InteractionMode, number>();
  const chapters = new Set<string>();
  for (const item of items) {
    counts.set(item.interaction, (counts.get(item.interaction) ?? 0) + 1);
    chapters.add(item.chapterId);
  }
  const single = chapters.size === 1 ? (chapterNames[[...chapters][0]] ?? null) : null;
  // Tease the first item by KIND and topic only — showing its prompt here
  // would be a free recognition pass (North Star rule 1).
  const first = items[0] ?? null;

  return (
    <Card style={{ marginTop: 12 }}>
      <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 10, alignItems: 'center' }}>
        {[...counts.entries()].map(([kind, n]) => (
          <View
            key={kind}
            style={{
              flexDirection: 'row',
              alignItems: 'center',
              gap: 6,
              backgroundColor: theme.palette.white,
              borderWidth: 1,
              borderColor: theme.palette.line,
              borderRadius: theme.radius.pill,
              paddingHorizontal: 12,
              paddingVertical: 7,
            }}
          >
            {/* neutral chips — the screen's one colorful moment is the ring;
                session screens teach the type colors via their overlines */}
            <Text variant="mono" style={{ fontSize: 14 }}>
              {n}
            </Text>
            <Overline color={theme.palette.ink2}>{interactionLabel(kind)}</Overline>
          </View>
        ))}
      </View>
      <Text variant="sub" color={theme.palette.ink3} style={{ marginTop: 10 }}>
        {single
          ? `All ${items.length} from ${single} — your current focus.`
          : `Drawn from ${chapters.size} chapters, weighted to what's about to fade.`}
      </Text>
      {lightDay ? (
        <Text variant="sub" color={theme.palette.ink4} style={{ marginTop: 4 }}>
          Light day — your queue grows as you learn more.
        </Text>
      ) : null}
      {first ? (
        <>
          <Divider />
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8, paddingTop: 11 }}>
            <Overline color={theme.palette.ink3}>Up first</Overline>
            <Text variant="bodyStrong" style={{ fontSize: 14 }}>
              {interactionLabel(first.interaction)} card · {chapterNames[first.chapterId] ?? 'your focus topic'}
            </Text>
          </View>
        </>
      ) : null}
    </Card>
  );
}
