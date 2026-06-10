import React from 'react';
import { Text } from './Text';

export function Overline({ children, color }: { children: React.ReactNode; color?: string }) {
  return (
    <Text variant="overline" color={color}>
      {children}
    </Text>
  );
}
