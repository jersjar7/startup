import React from 'react';
import { StyleSheet } from 'react-native';
import Svg, { Defs, Pattern, Path, Rect } from 'react-native-svg';

// Engineering graph-paper background — the same subtle square grid the web shows
// behind its questions and formulas: faint forest-green lines on a barely-tinted
// cream, a fine 10px grid under a stronger 50px grid. Drop it as an absolutely
// positioned layer behind question content (it ignores touches).
export function GridBackground() {
  return (
    <Svg style={StyleSheet.absoluteFill} pointerEvents="none">
      <Defs>
        <Pattern id="gridMinor" width={10} height={10} patternUnits="userSpaceOnUse">
          <Path d="M10 0 H0 V10" stroke="rgba(76,153,114,0.05)" strokeWidth={1} fill="none" />
        </Pattern>
        <Pattern id="gridMajor" width={50} height={50} patternUnits="userSpaceOnUse">
          <Path d="M50 0 H0 V50" stroke="rgba(76,153,114,0.09)" strokeWidth={1} fill="none" />
        </Pattern>
      </Defs>
      <Rect x={0} y={0} width="100%" height="100%" fill="#FAFDF8" />
      <Rect x={0} y={0} width="100%" height="100%" fill="url(#gridMinor)" />
      <Rect x={0} y={0} width="100%" height="100%" fill="url(#gridMajor)" />
    </Svg>
  );
}
