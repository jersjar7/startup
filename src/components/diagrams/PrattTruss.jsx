import React from 'react';
import {
  ArrowMarkerDefs, ForceArrow, PinSupport, RollerSupport, Label,
} from './primitives';

export function PrattTruss({ panels = 3, panelWidth = 3, height = 4, load = 24, loadPanel = 2 }) {
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
    topJoints.push({
      x: ox + i * scaleX,
      y: by - h,
      label: String.fromCharCode(65 + panels + i),
    });
  }

  const allJoints = [...bottomJoints, ...topJoints];

  return (
    <svg viewBox="0 0 380 230" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Pratt truss, ${panels} panels, ${load} kN load`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowMain" />

      {/* Bottom chord */}
      <line x1={bottomJoints[0].x} y1={by} x2={bottomJoints[panels].x} y2={by}
        stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Top chord segments */}
      {topJoints.length > 0 && (
        <>
          <line x1={bottomJoints[0].x} y1={by} x2={topJoints[0].x} y2={topJoints[0].y}
            stroke="var(--charcoal)" strokeWidth={2.5} />
          {topJoints.map((j, i) => {
            const next = topJoints[i + 1];
            if (next) {
              return <line key={`tc${i}`} x1={j.x} y1={j.y} x2={next.x} y2={next.y}
                stroke="var(--charcoal)" strokeWidth={2.5} />;
            }
            return null;
          })}
          <line x1={topJoints[topJoints.length - 1].x} y1={topJoints[topJoints.length - 1].y}
            x2={bottomJoints[panels].x} y2={by}
            stroke="var(--charcoal)" strokeWidth={2.5} />
        </>
      )}

      {/* Verticals and diagonals */}
      {topJoints.map((tj, i) => (
        <React.Fragment key={`vert${i}`}>
          {/* Vertical */}
          <line x1={tj.x} y1={by} x2={tj.x} y2={tj.y}
            stroke="var(--charcoal)" strokeWidth={2} />
          {/* Diagonal from bottom-left to top */}
          <line x1={bottomJoints[i].x} y1={by} x2={tj.x} y2={tj.y}
            stroke="var(--charcoal)" strokeWidth={2} />
        </React.Fragment>
      ))}

      {/* Joint dots and labels */}
      {allJoints.map((j, idx) => {
        const isBottom = j.y === by;
        const isSupport = isBottom && (idx === 0 || idx === panels);
        const isLoadJoint = !isBottom && topJoints.length >= loadPanel &&
          j.x === topJoints[loadPanel - 1].x && j.y === topJoints[loadPanel - 1].y;
        const labelY = isBottom
          ? (isSupport ? j.y + 38 : j.y + 14)
          : (isLoadJoint ? j.y - 30 : j.y - 14);
        return (
          <React.Fragment key={j.label}>
            <circle cx={j.x} cy={j.y} r={3} fill="var(--charcoal)" />
            <Label x={isLoadJoint ? j.x - 16 : j.x} y={labelY} bold fontSize={11}
              anchor={isLoadJoint ? 'end' : 'middle'}>
              {j.label}
            </Label>
          </React.Fragment>
        );
      })}

      {/* Supports */}
      <PinSupport x={bottomJoints[0].x} y={by} size={12} />
      <RollerSupport x={bottomJoints[panels].x} y={by} size={12} />

      {/* Load */}
      {topJoints.length >= loadPanel && (
        <>
          <ForceArrow
            x1={topJoints[loadPanel - 1].x} y1={topJoints[loadPanel - 1].y - 50}
            x2={topJoints[loadPanel - 1].x} y2={topJoints[loadPanel - 1].y - 6}
            color="var(--charcoal)" strokeWidth={2} markerId="arrowMain" />
          <Label x={topJoints[loadPanel - 1].x} y={topJoints[loadPanel - 1].y - 58}
            color="var(--charcoal)" bold fontSize={11}>
            {load} kN
          </Label>
        </>
      )}

    </svg>
  );
}
