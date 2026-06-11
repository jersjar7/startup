import React from 'react';
import Svg, { Circle, Line, Path, Rect } from 'react-native-svg';

// Onboarding illustrations — flat geometric, brand hexes only, hand-coded by
// the design panel (trust-first suite, judged + merged from three proposals).

/** Page 1 — the honest mastery ring (forest + charcoal on cream). */
export function OnbHonestRing({ size = 160 }: { size?: number }) {
  return (
    <Svg width={size} height={size} viewBox="0 0 160 160" fill="none">
      {/* the whole journey — unfilled track */}
      <Circle cx={80} cy={80} r={56} stroke="#F5EDE0" strokeWidth={10} />
      {/* exactly where you are — never pretends to be 100% */}
      <Path
        d="M 80 24 A 56 56 0 1 1 29.3 103.7"
        stroke="#2D7A5F"
        strokeWidth={10}
        strokeLinecap="round"
      />
      {/* end-cap marker: the honest edge of your mastery */}
      <Circle cx={29.3} cy={103.7} r={7.5} fill="#2D7A5F" />
      <Circle cx={29.3} cy={103.7} r={2.5} fill="#FFF9F0" />
      {/* abstract readout — the number we report, truthfully */}
      <Line x1={66} y1={76} x2={94} y2={76} stroke="#2C2C2C" strokeWidth={3.5} strokeLinecap="round" />
      <Line x1={66} y1={88} x2={82} y2={88} stroke="#2C2C2C" strokeWidth={3.5} strokeLinecap="round" strokeOpacity={0.35} />
    </Svg>
  );
}



/** Page 2 — phone reviews, desk solves: one system (ember + forest). */
export function TwoSurfacesGraphic({ width = 220 }: { width?: number }) {
  return (
    <Svg width={width} height={width * 0.8} viewBox="0 0 200 160" fill="none">
      {/* desktop = lessons + full problems */}
      <Rect x={18} y={30} width={86} height={60} rx={8} fill="#FFFFFF" stroke="#2C2C2C" strokeWidth={2.5} />
      <Rect x={28} y={42} width={44} height={6} rx={3} fill="#F5EDE0" />
      <Rect x={28} y={54} width={56} height={6} rx={3} fill="#F5EDE0" />
      <Rect x={28} y={68} width={30} height={12} rx={4} fill="#2D7A5F" />
      <Rect x={64} y={68} width={20} height={12} rx={4} fill="#F5EDE0" />
      <Line x1={61} y1={92} x2={61} y2={102} stroke="#2C2C2C" strokeWidth={3} strokeLinecap="round" />
      <Line x1={45} y1={104} x2={77} y2={104} stroke="#2C2C2C" strokeWidth={3} strokeLinecap="round" />
      {/* phone = spaced review of the same bank */}
      <Rect x={140} y={40} width={46} height={84} rx={12} fill="#FFFFFF" stroke="#2C2C2C" strokeWidth={2.5} />
      <Rect x={148} y={52} width={30} height={20} rx={5} fill="#FFFFFF" stroke="#E8683A" strokeWidth={2} />
      <Rect x={154} y={60} width={18} height={4} rx={2} fill="#F5EDE0" />
      <Rect x={148} y={80} width={30} height={8} rx={3} fill="#F5EDE0" />
      <Rect x={148} y={94} width={30} height={8} rx={3} fill="#F5EDE0" />
      {/* the link — dashed: sync designed, shipping soon */}
      <Path d="M104 66 C118 66 126 82 140 82" stroke="#E8683A" strokeWidth={2.5} strokeDasharray="2 6" strokeLinecap="round" />
      <Circle cx={104} cy={66} r={3.5} fill="#E8683A" />
      <Circle cx={140} cy={82} r={3.5} fill="#E8683A" />
    </Svg>
  );
}



/** Page 3 — the forgetting curve, interrupted (ember reviews, forest hold). */
export function SpacedReturnGraphic({ width = 220 }: { width?: number }) {
  return (
    <Svg width={width} height={width * 0.8} viewBox="0 0 200 160" fill="none">
      {/* baseline */}
      <Line x1={16} y1={138} x2={188} y2={138} stroke="#2C2C2C" strokeOpacity={0.15} strokeWidth={2} strokeLinecap="round" />
      {/* first decay (what would be forgotten) */}
      <Path d="M20 36 C36 72 54 102 70 116" stroke="#2C2C2C" strokeOpacity={0.3} strokeWidth={2.5} strokeDasharray="5 5" strokeLinecap="round" />
      <Circle cx={20} cy={36} r={4} fill="#2C2C2C" />
      {/* review #1 snaps it back */}
      <Line x1={70} y1={116} x2={70} y2={46} stroke="#E8683A" strokeWidth={2.5} strokeLinecap="round" />
      <Circle cx={70} cy={116} r={5} fill="#E8683A" />
      {/* shallower decay */}
      <Path d="M70 46 C90 68 108 84 126 94" stroke="#2C2C2C" strokeOpacity={0.3} strokeWidth={2.5} strokeDasharray="5 5" strokeLinecap="round" />
      {/* review #2 */}
      <Line x1={126} y1={94} x2={126} y2={54} stroke="#E8683A" strokeWidth={2.5} strokeLinecap="round" />
      <Circle cx={126} cy={94} r={5} fill="#E8683A" />
      {/* retained — holds high */}
      <Path d="M126 54 C144 62 162 66 184 68" stroke="#2D7A5F" strokeWidth={3} strokeLinecap="round" />
      <Circle cx={184} cy={68} r={5} fill="#2D7A5F" />
    </Svg>
  );
}



/** Page 4 — a bounded session with a real end (ember + forest). */
export function OnbBoundedSession({ width = 200, height = 120 }: { width?: number; height?: number }) {
  return (
    <Svg width={width} height={height} viewBox="0 0 200 120" fill="none">
      {/* a defined set — four done, one to go */}
      <Rect x={14} y={52} width={24} height={16} rx={5} fill="#E8683A" />
      <Rect x={44} y={52} width={24} height={16} rx={5} fill="#E8683A" />
      <Rect x={74} y={52} width={24} height={16} rx={5} fill="#E8683A" />
      <Rect x={104} y={52} width={24} height={16} rx={5} fill="#E8683A" />
      <Rect x={134} y={52} width={24} height={16} rx={5} stroke="#E8683A" strokeWidth={2} />
      {/* the hard stop — nothing scrolls past this */}
      <Line x1={166} y1={44} x2={166} y2={76} stroke="#2C2C2C" strokeWidth={3} strokeLinecap="round" />
      {/* done means done */}
      <Circle cx={184} cy={60} r={13} fill="#2D7A5F" />
      <Path d="M 178 60 L 182 64.5 L 190 55" stroke="#FFF9F0" strokeWidth={2.5} strokeLinecap="round" strokeLinejoin="round" />
    </Svg>
  );
}
