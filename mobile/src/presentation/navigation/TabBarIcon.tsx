import React from 'react';
import Svg, { Path, Circle } from 'react-native-svg';

interface Props {
  name: string;
  color: string;
}

// Outline icons keyed by route name (color carries the active/inactive state).
export function TabBarIcon({ name, color }: Props) {
  const common = { width: 24, height: 24, viewBox: '0 0 256 256', fill: 'none', stroke: color, strokeWidth: 16 } as const;
  switch (name) {
    case 'Today':
      return (
        <Svg {...common}>
          <Path d="M40 104l88-64 88 64v104a8 8 0 0 1-8 8h-48v-64h-64v64H48a8 8 0 0 1-8-8z" strokeLinejoin="round" />
        </Svg>
      );
    case 'Practice':
      return (
        <Svg {...common}>
          <Circle cx={128} cy={128} r={88} />
          <Path d="M112 96l40 32-40 32z" strokeLinejoin="round" />
        </Svg>
      );
    case 'Mastery':
      return (
        <Svg {...common}>
          <Path d="M48 208V48M104 208V120M160 208V80M216 208V152" strokeLinecap="round" />
        </Svg>
      );
    case 'Profile':
      return (
        <Svg {...common}>
          <Circle cx={128} cy={96} r={48} />
          <Path d="M40 208a96 96 0 0 1 176 0" strokeLinecap="round" />
        </Svg>
      );
    default:
      return null;
  }
}
