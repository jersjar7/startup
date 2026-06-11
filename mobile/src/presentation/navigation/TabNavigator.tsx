import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { TodayScreen } from '@/presentation/features/today/TodayScreen';
import { PracticeScreen } from '@/presentation/features/practice/PracticeScreen';
import { ProgressScreen } from '@/presentation/features/progress/ProgressScreen';
import { ProfileScreen } from '@/presentation/features/profile/ProfileScreen';
import { TabBarIcon } from './TabBarIcon';
import { useTheme } from '@/core/theme/useTheme';

const Tab = createBottomTabNavigator();

export function TabNavigator() {
  const theme = useTheme();
  const insets = useSafeAreaInsets();
  // Clearance under the home indicator (with a floor where the inset is 0) —
  // clipped nav labels read as a rendering bug.
  const bottomPad = Math.max(insets.bottom, 10);
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarActiveTintColor: theme.palette.ember,
        tabBarInactiveTintColor: theme.palette.ink4,
        tabBarStyle: {
          backgroundColor: theme.palette.cream,
          borderTopColor: theme.palette.line,
          height: 56 + bottomPad,
          paddingTop: 6,
          paddingBottom: bottomPad,
        },
        tabBarLabelStyle: { fontFamily: theme.fontFamily.heading, fontSize: 11, marginTop: 2 },
        tabBarIcon: ({ color }) => <TabBarIcon name={route.name} color={color} />,
      })}
    >
      <Tab.Screen name="Today" component={TodayScreen} />
      <Tab.Screen name="Practice" component={PracticeScreen} />
      <Tab.Screen name="Mastery" component={ProgressScreen} />
      <Tab.Screen name="Profile" component={ProfileScreen} />
    </Tab.Navigator>
  );
}
