import React from 'react';
import { ArrowMarkerDefs, ForceArrow, Label } from './primitives';

/**
 * Trip distribution by the gravity model.
 * Shows: a production zone i and two destination zones, with arrows carrying
 * the produced trips toward each (labeled by attractions A and friction F).
 * Does NOT show: the resulting trip split (that is the answer).
 */
export function GravityModelZones() {
  const origin = { x: 70, y: 130 };
  const z1 = { x: 300, y: 60 };
  const z2 = { x: 300, y: 200 };
  const R = 30;

  return (
    <svg viewBox="0 0 380 250" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Gravity model: trips from a production zone distributed to two destination zones"
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowMain" />

      {/* Trip-distribution arrows */}
      <ForceArrow x1={origin.x + R} y1={origin.y - 6} x2={z1.x - R - 4} y2={z1.y + 16}
        color="var(--charcoal)" strokeWidth={2} markerId="arrowMain" />
      <ForceArrow x1={origin.x + R} y1={origin.y + 6} x2={z2.x - R - 4} y2={z2.y - 16}
        color="var(--charcoal)" strokeWidth={2} markerId="arrowMain" />

      {/* Arrow annotations (attraction + friction) */}
      <Label x={185} y={78} color="var(--gray-500)" italic fontSize={10}>A₁, F₁</Label>
      <Label x={185} y={182} color="var(--gray-500)" italic fontSize={10}>A₂, F₂</Label>

      {/* Origin zone i */}
      <circle cx={origin.x} cy={origin.y} r={R} fill="var(--ember-bg)" stroke="var(--ember)" strokeWidth={2} />
      <Label x={origin.x} y={origin.y - 4} color="var(--ember)" bold fontSize={12}>Zone i</Label>
      <Label x={origin.x} y={origin.y + 11} color="var(--ember)" fontSize={9}>{'P'}ᵢ trips</Label>

      {/* Destination zones */}
      <circle cx={z1.x} cy={z1.y} r={R} fill="var(--forest-bg)" stroke="var(--forest)" strokeWidth={2} />
      <Label x={z1.x} y={z1.y} color="var(--forest)" bold fontSize={12}>Zone 1</Label>
      <circle cx={z2.x} cy={z2.y} r={R} fill="var(--forest-bg)" stroke="var(--forest)" strokeWidth={2} />
      <Label x={z2.x} y={z2.y} color="var(--forest)" bold fontSize={12}>Zone 2</Label>
    </svg>
  );
}
