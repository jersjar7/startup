import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { TodayScreen } from '@/presentation/features/today/TodayScreen';
import { PracticeScreen } from '@/presentation/features/practice/PracticeScreen';
import { ProgressScreen } from '@/presentation/features/progress/ProgressScreen';
import { ProfileScreen } from '@/presentation/features/profile/ProfileScreen';
import { useTheme } from '@/core/theme/useTheme';

const Tab = createBottomTabNavigator();

export function TabNavigator() {
  const theme = useTheme();
  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: theme.palette.ember,
        tabBarInactiveTintColor: theme.palette.ink4,
        tabBarStyle: {
          backgroundColor: theme.palette.cream,
          borderTopColor: theme.palette.line,
        },
        tabBarLabelStyle: { fontFamily: theme.fontFamily.heading, fontSize: 11 },
      }}
    >
      <Tab.Screen name="Today" component={TodayScreen} />
      <Tab.Screen name="Practice" component={PracticeScreen} />
      <Tab.Screen name="Mastery" component={ProgressScreen} />
      <Tab.Screen name="Profile" component={ProfileScreen} />
    </Tab.Navigator>
  );
}
