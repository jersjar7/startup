import React from 'react';

/**
 * Simply supported beam with UDL — SVG engineering diagram.
 * Looks like a textbook figure: clean lines, dimension arrows, hatching.
 */
export function BeamDiagram() {
  const W = 440;
  const H = 220;
  const beamY = 110;
  const beamX1 = 60;
  const beamX2 = 380;
  const beamLen = beamX2 - beamX1;

  return (
    <svg
      viewBox={`0 0 ${W} ${H}`}
      className="beam-diagram"
      aria-label="Simply supported beam with uniformly distributed load"
    >
      {/* ── Beam (thick line) ── */}
      <line
        x1={beamX1} y1={beamY}
        x2={beamX2} y2={beamY}
        stroke="var(--charcoal)" strokeWidth="3" strokeLinecap="round"
      />

      {/* ── UDL arrows ── */}
      {Array.from({ length: 13 }, (_, i) => {
        const x = beamX1 + 10 + i * (beamLen - 20) / 12;
        return (
          <g key={i}>
            <line
              x1={x} y1={beamY - 50}
              x2={x} y2={beamY - 6}
              stroke="var(--ember)" strokeWidth="1.2"
            />
            <polygon
              points={`${x - 3},${beamY - 10} ${x + 3},${beamY - 10} ${x},${beamY - 4}`}
              fill="var(--ember)"
            />
          </g>
        );
      })}

      {/* UDL top line */}
      <line
        x1={beamX1 + 10} y1={beamY - 50}
        x2={beamX2 - 10} y2={beamY - 50}
        stroke="var(--ember)" strokeWidth="1.2"
      />

      {/* UDL label */}
      <text
        x={(beamX1 + beamX2) / 2} y={beamY - 58}
        textAnchor="middle"
        className="beam-label beam-label--load"
      >
        w = 10 kN/m
      </text>

      {/* ── Pin support (left) — triangle ── */}
      <polygon
        points={`${beamX1},${beamY + 2} ${beamX1 - 12},${beamY + 22} ${beamX1 + 12},${beamY + 22}`}
        fill="none" stroke="var(--charcoal)" strokeWidth="1.5"
      />
      {/* Ground hatching under pin */}
      <line x1={beamX1 - 16} y1={beamY + 24} x2={beamX1 + 16} y2={beamY + 24} stroke="var(--charcoal)" strokeWidth="1.5" />
      {[...Array(4)].map((_, i) => (
        <line
          key={`ph${i}`}
          x1={beamX1 - 14 + i * 9} y1={beamY + 30}
          x2={beamX1 - 6 + i * 9} y2={beamY + 24}
          stroke="var(--charcoal)" strokeWidth="1"
        />
      ))}

      {/* ── Roller support (right) — triangle + circle ── */}
      <polygon
        points={`${beamX2},${beamY + 2} ${beamX2 - 12},${beamY + 22} ${beamX2 + 12},${beamY + 22}`}
        fill="none" stroke="var(--charcoal)" strokeWidth="1.5"
      />
      <circle cx={beamX2 - 6} cy={beamY + 27} r="4" fill="none" stroke="var(--charcoal)" strokeWidth="1.2" />
      <circle cx={beamX2 + 6} cy={beamY + 27} r="4" fill="none" stroke="var(--charcoal)" strokeWidth="1.2" />
      <line x1={beamX2 - 16} y1={beamY + 33} x2={beamX2 + 16} y2={beamY + 33} stroke="var(--charcoal)" strokeWidth="1.5" />
      {[...Array(4)].map((_, i) => (
        <line
          key={`rh${i}`}
          x1={beamX2 - 14 + i * 9} y1={beamY + 39}
          x2={beamX2 - 6 + i * 9} y2={beamY + 33}
          stroke="var(--charcoal)" strokeWidth="1"
        />
      ))}

      {/* ── Dimension line ── */}
      <line
        x1={beamX1} y1={beamY + 50}
        x2={beamX2} y2={beamY + 50}
        stroke="var(--gray-400)" strokeWidth="0.8"
        markerStart="url(#dimArrowL)" markerEnd="url(#dimArrowR)"
      />
      {/* Tick marks */}
      <line x1={beamX1} y1={beamY + 44} x2={beamX1} y2={beamY + 56} stroke="var(--gray-400)" strokeWidth="0.8" />
      <line x1={beamX2} y1={beamY + 44} x2={beamX2} y2={beamY + 56} stroke="var(--gray-400)" strokeWidth="0.8" />

      <text
        x={(beamX1 + beamX2) / 2} y={beamY + 66}
        textAnchor="middle"
        className="beam-label beam-label--dim"
      >
        L = 6 m
      </text>

      {/* ── Support labels ── */}
      <text x={beamX1} y={beamY + 48} textAnchor="middle" className="beam-label beam-label--support">A</text>
      <text x={beamX2} y={beamY + 48} textAnchor="middle" className="beam-label beam-label--support">B</text>

      {/* ── Arrowhead markers ── */}
      <defs>
        <marker id="dimArrowL" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto">
          <path d="M6,0 L0,3 L6,6" fill="none" stroke="var(--gray-400)" strokeWidth="0.8" />
        </marker>
        <marker id="dimArrowR" markerWidth="6" markerHeight="6" refX="0" refY="3" orient="auto">
          <path d="M0,0 L6,3 L0,6" fill="none" stroke="var(--gray-400)" strokeWidth="0.8" />
        </marker>
      </defs>
    </svg>
  );
}
