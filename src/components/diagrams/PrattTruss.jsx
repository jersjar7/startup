import React from 'react';
import {
  ArrowMarkerDefs, ForceArrow, PinSupport, RollerSupport, Label,
} from './primitives';

/**
 * Pratt truss. Load can be applied to the top chord (loadChord = 'top',
 * at top joint loadPanel) or to the bottom chord (loadChord = 'bottom',
 * at bottom joint index loadJoint). The viewBox is fitted to the content.
 */
export function PrattTruss({
  panels = 3, panelWidth = 3, height = 4, load = 24,
  loadPanel = 2, loadChord = 'top', loadJoint = 1,
}) {
  const ox = 40;
  const by = 160;
  const scaleX = 70;
  const scaleY = 20;
  const h = height * scaleY;

  const bottomJoints = [];
  const topJoints = [];
  for (let i = 0; i <= panels; i++) {
    bottomJoints.push({ x: ox + i * scaleX, y: by, label: String.fromCharCode(65 + i) });
  }
  for (let i = 1; i < panels; i++) {
    topJoints.push({ x: ox + i * scaleX, y: by - h, label: String.fromCharCode(65 + panels + i) });
  }
  const allJoints = [...bottomJoints, ...topJoints];

  // resolve the loaded joint
  const loadOnBottom = loadChord === 'bottom';
  const loadJ = loadOnBottom
    ? bottomJoints[Math.max(0, Math.min(loadJoint, panels))]
    : (topJoints[Math.min(Math.max(loadPanel, 1), topJoints.length) - 1] || null);

  // content-fitted viewBox
  const minX = ox - 24;
  const maxX = bottomJoints[panels].x + 34;
  const minY = (by - h) - (loadOnBottom ? 20 : 64);
  const maxY = by + (loadOnBottom ? 60 : 46);

  return (
    <svg viewBox={`${minX} ${minY} ${maxX - minX} ${maxY - minY}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Pratt truss, ${panels} panels, ${load} kN load`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowMain" />

      {/* Bottom chord */}
      <line x1={bottomJoints[0].x} y1={by} x2={bottomJoints[panels].x} y2={by}
        stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Top chord (sloped ends + parallel middle) */}
      {topJoints.length > 0 && (
        <>
          <line x1={bottomJoints[0].x} y1={by} x2={topJoints[0].x} y2={topJoints[0].y}
            stroke="var(--charcoal)" strokeWidth={2.5} />
          {topJoints.map((j, i) => {
            const next = topJoints[i + 1];
            return next ? <line key={`tc${i}`} x1={j.x} y1={j.y} x2={next.x} y2={next.y}
              stroke="var(--charcoal)" strokeWidth={2.5} /> : null;
          })}
          <line x1={topJoints[topJoints.length - 1].x} y1={topJoints[topJoints.length - 1].y}
            x2={bottomJoints[panels].x} y2={by} stroke="var(--charcoal)" strokeWidth={2.5} />
        </>
      )}

      {/* Verticals and diagonals */}
      {topJoints.map((tj, i) => (
        <React.Fragment key={`web${i}`}>
          <line x1={tj.x} y1={by} x2={tj.x} y2={tj.y} stroke="var(--charcoal)" strokeWidth={2} />
          <line x1={bottomJoints[i].x} y1={by} x2={tj.x} y2={tj.y} stroke="var(--charcoal)" strokeWidth={2} />
        </React.Fragment>
      ))}

      {/* Joint dots + labels */}
      {allJoints.map((j) => {
        const isBottom = j.y === by;
        const isSupport = isBottom && (j.x === bottomJoints[0].x || j.x === bottomJoints[panels].x);
        const isLoaded = loadJ && j.x === loadJ.x && j.y === loadJ.y;
        let lx = j.x, ly, anchor = 'middle';
        if (isBottom) {
          if (isLoaded) { lx = j.x - 14; ly = j.y - 12; anchor = 'end'; }   // clear of the down-load
          else { ly = isSupport ? j.y + 38 : j.y + 16; }
        } else {
          if (isLoaded) { lx = j.x - 16; ly = j.y - 30; anchor = 'end'; }   // clear of the top load
          else { ly = j.y - 14; }
        }
        return (
          <React.Fragment key={j.label}>
            <circle cx={j.x} cy={j.y} r={3} fill="var(--charcoal)" />
            <Label x={lx} y={ly} bold fontSize={11} anchor={anchor}>{j.label}</Label>
          </React.Fragment>
        );
      })}

      {/* Supports */}
      <PinSupport x={bottomJoints[0].x} y={by} size={12} />
      <RollerSupport x={bottomJoints[panels].x} y={by} size={12} />

      {/* Load */}
      {loadJ && (loadOnBottom ? (
        <>
          <ForceArrow x1={loadJ.x} y1={by + 8} x2={loadJ.x} y2={by + 46}
            color="var(--charcoal)" strokeWidth={2} markerId="arrowMain" />
          <Label x={loadJ.x + 10} y={by + 34} color="var(--charcoal)" bold fontSize={11} anchor="start">
            {load} kN
          </Label>
        </>
      ) : (
        <>
          <ForceArrow x1={loadJ.x} y1={loadJ.y - 50} x2={loadJ.x} y2={loadJ.y - 6}
            color="var(--charcoal)" strokeWidth={2} markerId="arrowMain" />
          <Label x={loadJ.x} y={loadJ.y - 58} color="var(--charcoal)" bold fontSize={11}>
            {load} kN
          </Label>
        </>
      ))}
    </svg>
  );
}
