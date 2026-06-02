import React from 'react';

// Engineering-themed line-art for error screens — on brand (charcoal lines,
// ember accent for "the problem"), matching the hero SVG aesthetic.

const C = '#2C2C2C';   // charcoal
const E = '#E8683A';   // ember
const G = '#A09C93';   // muted ground

/* 404 — a truss bridge with a broken span: "this path doesn't connect". */
export function BrokenBridge() {
  return (
    <svg width="208" height="132" viewBox="0 0 208 132" fill="none" role="img" aria-label="A bridge with a broken span">
      {/* ground */}
      <line x1="14" y1="108" x2="74" y2="108" stroke={G} strokeWidth="2.5" strokeLinecap="round" />
      <line x1="134" y1="108" x2="194" y2="108" stroke={G} strokeWidth="2.5" strokeLinecap="round" />
      <g stroke={C} strokeWidth="2.5" strokeLinejoin="round" strokeLinecap="round">
        {/* left span */}
        <path d="M32 108 V88 M88 108 V88" />
        <path d="M32 88 H88" />
        <path d="M40 60 H80" />
        <path d="M32 88 L40 60 M60 88 L40 60 M60 88 L80 60 M80 60 L88 88" />
        {/* right span */}
        <path d="M120 108 V88 M176 108 V88" />
        <path d="M120 88 H176" />
        <path d="M128 60 H168" />
        <path d="M120 88 L128 60 M148 88 L128 60 M148 88 L168 60 M168 60 L176 88" />
      </g>
      {/* the break */}
      <g stroke={E} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" fill="none">
        <path d="M88 88 l5 -5 l-3 9 l6 -3" />
        <path d="M120 88 l-5 -5 l3 9 l-6 -3" />
        <line x1="96" y1="84" x2="112" y2="84" strokeDasharray="2.5 4.5" />
      </g>
    </svg>
  );
}

/* 404 alt — a survey instrument sighting off into nothing: "can't locate it". */
export function LostSurveyor() {
  return (
    <svg width="208" height="132" viewBox="0 0 208 132" fill="none" role="img" aria-label="A survey instrument sighting into the unknown">
      <line x1="18" y1="112" x2="92" y2="112" stroke={G} strokeWidth="2.5" strokeLinecap="round" />
      <g stroke={C} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
        {/* tripod */}
        <path d="M55 66 L36 112 M55 66 L74 112 M55 66 L57 112" />
        {/* instrument */}
        <rect x="43" y="50" width="24" height="16" rx="3.5" />
        <line x1="67" y1="58" x2="84" y2="56" />
      </g>
      {/* sight line off into nothing */}
      <line x1="84" y1="56" x2="158" y2="48" stroke={E} strokeWidth="2.5" strokeDasharray="4 5.5" strokeLinecap="round" />
      <circle cx="172" cy="46" r="16" stroke={E} strokeWidth="2.5" />
      <text x="172" y="54" textAnchor="middle" fontFamily="'DM Sans', system-ui, sans-serif" fontSize="22" fontWeight="700" fill={E}>?</text>
    </svg>
  );
}

/* Error boundary — a beam failing under overload: "something gave way". */
export function OverloadedBeam() {
  return (
    <svg width="208" height="132" viewBox="0 0 208 132" fill="none" role="img" aria-label="A beam cracking under overload">
      <line x1="34" y1="108" x2="174" y2="108" stroke={G} strokeWidth="2.5" strokeLinecap="round" />
      <g stroke={C} strokeWidth="2.5" strokeLinejoin="round" fill="none">
        {/* pin + roller supports */}
        <path d="M48 108 l11 -17 l11 17 z" />
        <path d="M138 108 l11 -17 l11 17 z" />
        {/* deflected (sagging) beam */}
        <path d="M59 90 Q104 122 149 90" strokeWidth="3.5" strokeLinecap="round" />
      </g>
      {/* overload arrow pressing down */}
      <g stroke={E} strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round" fill="none">
        <line x1="104" y1="30" x2="104" y2="100" />
        <path d="M96 93 l8 11 l8 -11" />
      </g>
      {/* crack */}
      <path d="M104 108 l-5 7 l7 4 l-5 7" stroke={E} strokeWidth="2.5" fill="none" strokeLinejoin="round" strokeLinecap="round" />
    </svg>
  );
}
