import React from 'react';
import { PinSupport, RollerSupport, DimensionLine, Label } from '../../primitives';
import { polar } from '../../geo';

// Simply supported beam with a clockwise couple M0 at aFrac*L, plus four
// candidate moment diagrams (I to IV). Diagram IV is the true shape.
// Short hatched ground strip under a support base at (x, y).
function Ground({ x, y, half = 13 }) {
  const ticks = [];
  for (let t = x - half + 4; t <= x + half; t += 5) {
    ticks.push(<line key={t} x1={t} y1={y} x2={t - 5} y2={y + 6} stroke="var(--charcoal)" strokeWidth={1} />);
  }
  return (
    <g>
      <line x1={x - half} y1={y} x2={x + half} y2={y} stroke="var(--charcoal)" strokeWidth={1.5} />
      {ticks}
    </g>
  );
}

export function CtMechanicsMaterialsACoupleDiagrams({ aFrac = 1 / 3 }) {
  const xA = 70;
  const xB = 370;
  const L = xB - xA;
  const xc = xA + aFrac * L;
  const by = 52;
  const r = 17;

  // clockwise arc on screen: from 200 deg to -110 deg (math angles), arrow at the end
  const s = polar(xc, by, r, 210);
  const e = polar(xc, by, r, -60);
  const arc = `M ${s.x},${s.y} A ${r},${r} 0 1 1 ${e.x},${e.y}`;

  const a = aFrac;
  // shapes in (x fraction, moment in units of M0), positive up
  const shapes = {
    I: [[0, 0], [a, 1 - a], [1, 0]],
    II: [[0, 0], [a, a], [a, -(1 - a)], [1, 0]],
    III: [[0, 0], [a, 0], [a, 1 - a], [1, 1 - a], [1, 0]],
    IV: [[0, 0], [a, -a], [a, 1 - a], [1, 0]],
  };
  const panelW = 196;
  const panelH = 86;
  const origins = { I: [8, 128], II: [216, 128], III: [8, 226], IV: [216, 226] };

  const panel = (key) => {
    const [px, py] = origins[key];
    const x1 = px + 30;
    const w = 150;
    const y0 = py + 50;
    const k = 48;
    const pts = shapes[key].map(([fx, m]) => [x1 + fx * w, y0 - m * k]);
    const poly = pts.map((p) => p.join(',')).join(' ');
    return (
      <g key={key}>
        <rect x={px} y={py} width={panelW} height={panelH} rx={8} fill="none" stroke="var(--gray-400)" strokeWidth={0.75} />
        <Label x={px + 14} y={py + 15} bold color="var(--charcoal)" fontSize={12}>{key}</Label>
        <line x1={x1 - 6} y1={y0} x2={x1 + w + 6} y2={y0} stroke="var(--gray-500)" strokeWidth={1} />
        <polygon points={poly} fill="var(--ember)" fillOpacity={0.12} stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="miter" />
      </g>
    );
  };

  return (
    <svg viewBox="0 0 420 306" xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label="Simply supported beam with a clockwise couple at one third of the span, and four candidate moment diagrams"
      style={{ width: '100%', height: 'auto' }}>
      <g transform="translate(0,-14)">
      <defs>
        <marker id="ctMmACoupleHead" markerWidth={8} markerHeight={8} refX={7} refY={4} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 8,4 L 0,8 Z" fill="var(--ember)" />
        </marker>
      </defs>
      <line x1={xA} y1={by} x2={xB} y2={by} stroke="var(--charcoal)" strokeWidth={3} strokeLinecap="round" />
      <PinSupport x={xA} y={by} />
      <Ground x={xA} y={by + 16} half={12} />
      <RollerSupport x={xB} y={by} />
      <Ground x={xB} y={by + 26} />
      <Label x={xA - 16} y={by + 4} bold color="var(--charcoal)">A</Label>
      <Label x={xB + 16} y={by + 4} bold color="var(--charcoal)">B</Label>
      <circle cx={xc} cy={by} r={3} fill="var(--charcoal)" />
      <path d={arc} fill="none" stroke="var(--ember)" strokeWidth={1.75} markerEnd="url(#ctMmACoupleHead)" />
      <text x={xc + r + 12} y={by - r + 2} fill="var(--ember)" fontFamily="var(--font-body)" fontStyle="italic" fontWeight={600} fontSize={13} textAnchor="middle" dominantBaseline="middle">
        M<tspan fontSize={11} dy={4}>0</tspan>
      </text>
      <DimensionLine x1={xA} y1={by + 42} x2={xc} y2={by + 42} label="L/3" offset={12} fontSize={12} />
      <DimensionLine x1={xc} y1={by + 42} x2={xB} y2={by + 42} label="2L/3" offset={12} fontSize={12} />
      {['I', 'II', 'III', 'IV'].map(panel)}
    </g>
    </svg>
  );
}
