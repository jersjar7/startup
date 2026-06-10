import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { TabNavigator } from './TabNavigator';
import { ReviewScreen } from '@/presentation/features/review/ReviewScreen';
import type { RootStackParamList } from './types';

const Stack = createNativeStackNavigator<RootStackParamList>();

// Tabs are the home surface; Review opens over them as a focused, full-screen
// session (a bounded set — not another tab to wander into).
export function RootNavigator() {
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name="Tabs" component={TabNavigator} />
      <Stack.Screen name="Review" component={ReviewScreen} options={{ presentation: 'modal' }} />
    </Stack.Navigator>
  );
}
