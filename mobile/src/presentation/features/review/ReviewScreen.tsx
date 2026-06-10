import React from 'react';
import { View } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { Screen } from '@/presentation/ui/Screen';
import { Button } from '@/presentation/ui/Button';
import { useReviewViewModel } from './useReviewViewModel';
import { ProgressDots } from './components/ProgressDots';
import { ReviewCard } from './components/ReviewCard';
import { GradeButtons } from './components/GradeButtons';
import { DoneView } from './components/DoneView';
import type { RootStackParamList } from '@/presentation/navigation/types';

export function ReviewScreen() {
  const nav = useNavigation<NativeStackNavigationProp<RootStackParamList>>();
  const vm = useReviewViewModel();

  if (vm.phase === 'done') {
    return <DoneView reviewed={vm.items.length} onClose={() => nav.goBack()} />;
  }

  return (
    <Screen edges={['top', 'bottom']}>
      <View style={{ flex: 1 }}>
        <ProgressDots total={vm.items.length} index={vm.index} onClose={() => nav.goBack()} />
        {vm.current ? <ReviewCard item={vm.current} revealed={vm.revealed} /> : null}
      </View>
      <View style={{ paddingVertical: 16 }}>
        {vm.revealed ? (
          <GradeButtons onGrade={vm.grade} />
        ) : (
          <Button label="Reveal" onPress={vm.reveal} />
        )}
      </View>
    </Screen>
  );
}
