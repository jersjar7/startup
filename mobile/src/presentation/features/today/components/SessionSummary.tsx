import React from 'react';
import { View } from 'react-native';
import { Text } from '@/presentation/ui/Text';
import { Overline } from '@/presentation/ui/Overline';
import { useTheme } from '@/core/theme/useTheme';
import { interactionLabel, interactionColor } from '@/presentation/ui/semantics';
import type { SessionItem } from '@/domain/entities/session';
import type { InteractionMode } from '@/domain/entities/tiers';

// Pre-session view shows WHAT KIND of work is due, never the prompts —
// reading a prompt before the session is a free recognition pass, which
// breaks the generation-not-recognition rule (North Star #1). Type chips are
// fine in aggregate; per-item they prime trick-hunting (rule #2).
interface Props {
  items: readonly SessionItem[];
  chapterNames?: Record<string, string>;
}

export function SessionSummary({ items, chapterNames = {} }: Props) {
  const theme = useTheme();

  const counts = new Map<InteractionMode, number>();
  const chapters = new Set<string>();
  for (const item of items) {
    counts.set(item.interaction, (counts.get(item.interaction) ?? 0) + 1);
    chapters.add(item.chapterId);
  }
  const single = chapters.size === 1 ? (chapterNames[[...chapters][0]] ?? null) : null;

  return (
    <View style={{ paddingVertical: 14 }}>
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
            <Text variant="mono" style={{ fontSize: 14 }}>
              {n}
            </Text>
            <Overline color={interactionColor(kind, theme)}>{interactionLabel(kind)}</Overline>
          </View>
        ))}
      </View>
      <Text variant="sub" color={theme.palette.ink3} style={{ marginTop: 10 }}>
        {single
          ? `All ${items.length} from ${single} — your current focus.`
          : `Drawn from ${chapters.size} topics, weighted to what's about to fade.`}
      </Text>
    </View>
  );
}
