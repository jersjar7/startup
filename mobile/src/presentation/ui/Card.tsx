import React from 'react';
import { View, type ViewProps, type ViewStyle } from 'react-native';
import { useTheme } from '@/core/theme/useTheme';

interface Props extends ViewProps {
  children: React.ReactNode;
  padded?: boolean;
}

// White card floating on the cream canvas with a soft warm shadow.
export function Card({ children, padded = true, style, ...rest }: Props) {
  const theme = useTheme();
  const base: ViewStyle = {
    backgroundColor: theme.palette.white,
    borderRadius: theme.radius.card,
    padding: padded ? theme.spacing.md : 0,
    ...theme.shadow.card,
  };
  return (
    <View {...rest} style={[base, style]}>
      {children}
    </View>
  );
}
