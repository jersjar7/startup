import React, { useCallback } from 'react';
import { View, ActivityIndicator, Pressable, Linking } from 'react-native';
import { useNavigation, useFocusEffect } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import Svg, { Path } from 'react-native-svg';
import { Screen } from '@/presentation/ui/Screen';
import { Text } from '@/presentation/ui/Text';
import { Card } from '@/presentation/ui/Card';
import { Overline } from '@/presentation/ui/Overline';
import { ProgressBar } from '@/presentation/ui/ProgressBar';
import { ListRow } from '@/presentation/ui/ListRow';
import { useTheme } from '@/core/theme/useTheme';
import { masteryColor, masteryLabel } from '@/presentation/ui/semantics';
import { usePracticeViewModel } from './usePracticeViewModel';
import type { RootStackParamList } from '@/presentation/navigation/types';

const WEB_URL = 'https://fe4raccoons.com';

export function PracticeScreen() {
  const theme = useTheme();
  const nav = useNavigation<NativeStackNavigationProp<RootStackParamList>>();
  const { loading, dueCount, weak, reload } = usePracticeViewModel();

  useFocusEffect(
    useCallback(() => {
      void reload();
    }, [reload]),
  );

  if (loading) {
    return (
      <Screen>
        <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
          <ActivityIndicator color={theme.palette.ember} />
        </View>
      </Screen>
    );
  }

  const done = dueCount === 0;

  return (
    <Screen scroll>
      <Text variant="h1" style={{ marginTop: 8 }}>
        Practice
      </Text>
      <Text variant="sub" color={theme.palette.ink3}>
        Your daily review covers the essentials — everything here is optional extra.
      </Text>

      {/* daily review status */}
      <Pressable onPress={() => nav.navigate('Review')} style={({ pressed }) => ({ opacity: pressed ? 0.85 : 1, marginTop: 18 })}>
        <View
          style={{
            flexDirection: 'row',
            alignItems: 'center',
            gap: 13,
            padding: 15,
            borderRadius: 16,
            backgroundColor: done ? theme.palette.forestBg : theme.palette.white,
            ...(done ? {} : theme.shadow.card),
          }}
        >
          <View
            style={{
              width: 36,
              height: 36,
              borderRadius: 18,
              backgroundColor: done ? theme.palette.forest : theme.palette.ember,
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <Svg width={18} height={18} viewBox="0 0 256 256" fill="none" stroke="#fff" strokeWidth={done ? 24 : 0}>
              {done ? (
                <Path d="M40 144l52 52L216 72" strokeLinecap="round" strokeLinejoin="round" />
              ) : (
                <Path d="M104 80l72 48-72 48z" fill="#fff" />
              )}
            </Svg>
          </View>
          <View style={{ flex: 1 }}>
            <Text variant="bodyStrong" color={done ? theme.palette.forestInk : theme.palette.charcoal}>
              {done ? 'Daily review done' : 'Daily review'}
            </Text>
            <Text variant="sub" color={done ? '#3F7A63' : theme.palette.ink3} style={{ marginTop: 2 }}>
              {done ? "You're caught up for today" : `${dueCount} cards · ~${Math.max(1, Math.round(dueCount * 0.7))} min`}
            </Text>
          </View>
        </View>
      </Pressable>

      {/* weak areas — "weak" only once there's evidence; untouched topics are
          just new, and claiming otherwise reads as the app not paying attention */}
      {weak.length > 0 ? (
        <>
          <View style={{ marginTop: 24, marginBottom: 6 }}>
            <Overline>
              {weak.some((w) => w.mastery.percent > 0) ? 'Focus on your weak areas' : 'Start a new topic'}
            </Overline>
          </View>
          <Card>
            {weak.map((w, i) => (
              <Pressable
                key={w.chapter.id}
                onPress={() => nav.navigate('Review', { chapterId: w.chapter.id })}
                style={({ pressed }) => ({
                  paddingVertical: 11,
                  borderTopWidth: i ? 1 : 0,
                  borderTopColor: theme.palette.line,
                  opacity: pressed ? 0.6 : 1,
                })}
              >
                <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: w.mastery.percent > 0 ? 8 : 0 }}>
                  <Text variant="bodyStrong">{w.chapter.name}</Text>
                  <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                    <Overline color={masteryColor(w.mastery.state, theme)}>{masteryLabel(w.mastery.state)}</Overline>
                    <Svg width={14} height={14} viewBox="0 0 256 256" fill="none" stroke={theme.palette.ink4} strokeWidth={20}>
                      <Path d="M96 48l80 80-80 80" strokeLinecap="round" strokeLinejoin="round" />
                    </Svg>
                  </View>
                </View>
                {w.mastery.percent > 0 ? (
                  <ProgressBar percent={w.mastery.percent} color={masteryColor(w.mastery.state, theme)} />
                ) : null}
              </Pressable>
            ))}
          </Card>
        </>
      ) : null}

      {/* the 3 above are smart suggestions — full list lives one tap away */}
      <ListRow title="All 15 chapters" onPress={() => nav.navigate('Mastery' as never)} />

      {/* full mock exam → web */}
      <View style={{ marginTop: 24, marginBottom: 2 }}>
        <Overline>Go deeper</Overline>
      </View>
      <ListRow
        title="Full mock exam"
        subtitle="110 questions · timed · included in the optional Exam Pass"
        onPress={() => Linking.openURL(WEB_URL)}
        right={
          <Text
            variant="overline"
            color={theme.palette.ink2}
            style={{ backgroundColor: theme.palette.creamDark, paddingHorizontal: 8, paddingVertical: 4, borderRadius: 6 }}
          >
            Web
          </Text>
        }
      />
    </Screen>
  );
}
