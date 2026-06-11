import React from 'react';
import { useNavigation, useRoute, type RouteProp } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { Screen } from '@/presentation/ui/Screen';
import { FadeIn } from '@/presentation/ui/FadeIn';
import { useReviewViewModel } from './useReviewViewModel';
import { ProgressDots } from './components/ProgressDots';
import { RecallReviewCard } from './components/RecallReviewCard';
import { TapTheTrapCard } from './components/TapTheTrapCard';
import { DoneView } from './components/DoneView';
import type { RootStackParamList } from '@/presentation/navigation/types';

export function ReviewScreen() {
  const nav = useNavigation<NativeStackNavigationProp<RootStackParamList>>();
  const route = useRoute<RouteProp<RootStackParamList, 'Review'>>();
  const vm = useReviewViewModel(route.params?.chapterId);

  if (vm.phase === 'done') {
    return <DoneView reviewed={vm.items.length} misses={vm.misses} streak={vm.streak} onClose={() => nav.goBack()} />;
  }

  const cur = vm.current;
  return (
    <Screen edges={['top', 'bottom']}>
      <ProgressDots total={vm.items.length} index={vm.index} onClose={() => nav.goBack()} />
      {cur ? (
        // Keyed so each item remounts and fades in as it arrives.
        <FadeIn key={cur.id} style={{ flex: 1 }}>
          {cur.kind === 'problem' ? (
            <TapTheTrapCard item={cur} onGraded={vm.advance} />
          ) : (
            <RecallReviewCard item={cur} onGraded={vm.advance} />
          )}
        </FadeIn>
      ) : null}
    </Screen>
  );
}
