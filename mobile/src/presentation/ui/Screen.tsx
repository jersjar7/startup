import React from 'react';
import { View, ScrollView } from 'react-native';
import { SafeAreaView, type Edge } from 'react-native-safe-area-context';
import { useTheme } from '@/core/theme/useTheme';

interface Props {
  children: React.ReactNode;
  scroll?: boolean;
  edges?: readonly Edge[];
}

// Cream canvas + safe-area. The one place the page background is set.
export function Screen({ children, scroll = false, edges = ['top'] }: Props) {
  const theme = useTheme();
  const pad = theme.spacing.lg - 2;

  return (
    <SafeAreaView edges={edges} style={{ flex: 1, backgroundColor: theme.palette.cream }}>
      {scroll ? (
        <ScrollView
          style={{ flex: 1 }}
          contentContainerStyle={{ paddingHorizontal: pad, paddingBottom: theme.spacing.lg }}
          showsVerticalScrollIndicator={false}
        >
          {children}
        </ScrollView>
      ) : (
        <View style={{ flex: 1, paddingHorizontal: pad }}>{children}</View>
      )}
    </SafeAreaView>
  );
}
