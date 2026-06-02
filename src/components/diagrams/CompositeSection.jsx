import React from 'react';
import { Label } from './primitives';

/**
 * Composite beam cross-section of two materials (E1 > E2).
 * Shows: a beam section made of a stiffer material over a softer one, with the
 * neutral axis and the two elastic moduli labeled — the basis for the
 * transformed-section method.
 * Does NOT show: the modular ratio value or stresses (those are the answers).
 */
export function CompositeSection() {
  const x = 110, w = 90;
  const top = 36, mid = 96, bot = 200;       // material1: top..mid, material2: mid..bot
  const naY = 120;

  return (
    <svg viewBox="0 0 300 240" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Composite beam section of two materials with a neutral axis"
      style={{ width: '100%', height: 'auto' }}>

      {/* Material 1 (stiffer) */}
      <rect x={x} y={top} width={w} height={mid - top} fill="rgba(44,44,44,0.55)" stroke="var(--charcoal)" strokeWidth={2} />
      <Label x={x - 10} y={(top + mid) / 2} color="var(--charcoal)" fontSize={10} anchor="end">Material 1</Label>
      <Label x={x + w + 10} y={(top + mid) / 2} color="var(--charcoal)" bold fontSize={11} anchor="start">E₁</Label>

      {/* Material 2 (softer) */}
      <rect x={x} y={mid} width={w} height={bot - mid} fill="rgba(180,160,130,0.40)" stroke="var(--charcoal)" strokeWidth={2} />
      <Label x={x - 10} y={(mid + bot) / 2} color="var(--gray-600)" fontSize={10} anchor="end">Material 2</Label>
      <Label x={x + w + 10} y={(mid + bot) / 2} color="var(--gray-600)" bold fontSize={11} anchor="start">E₂</Label>

      {/* Neutral axis */}
      <line x1={x - 24} y1={naY} x2={x + w + 24} y2={naY} stroke="var(--ember)" strokeWidth={1.5} strokeDasharray="6,3" />
      <Label x={x + w + 28} y={naY} color="var(--ember)" italic fontSize={10} anchor="start">N.A.</Label>

      {/* E1 > E2 note */}
      <Label x={x + w / 2} y={bot + 20} color="var(--gray-500)" italic fontSize={10}>E₁ {'>'} E₂</Label>
    </svg>
  );
}
