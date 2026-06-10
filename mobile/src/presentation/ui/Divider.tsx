import React from 'react';
import { View } from 'react-native';
import { useTheme } from '@/core/theme/useTheme';

export function Divider() {
  const theme = useTheme();
  return <View style={{ height: 1, backgroundColor: theme.palette.line }} />;
}
