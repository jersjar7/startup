import React from 'react';
import { PinSupport, RollerSupport } from './primitives';

/**
 * Configurable frame schematic for determinacy/stability problems.
 *
 * Shows: members (thick lines), joints (dots), support symbols,
 *        internal hinge markers (small open circles).
 * Student counts m, j, r, c to classify the structure.
 *
 * variant = 'portal'  — 4 joints, 3 members (simple portal frame)
 * variant = 'twobay'  — 6 joints, 5 members (two-bay frame with center column)
 */

const LAYOUTS = {
  portal: {
    joints: [
      [130, 180], [290, 180],   // j0, j1 — bottom (column bases)
      [130, 50], [290, 50],     // j2, j3 — top (beam-column joints)
    ],
    members: [
      [0, 2], [2, 3], [3, 1],  // left col, beam, right col
    ],
    supports: { left: 0, right: 1 },
    hingeJoints: {},
  },
  twobay: {
    joints: [
      [70, 180], [200, 180], [330, 180],   // j0, j1, j2 — bottom
      [70, 50], [200, 50], [330, 50],       // j3, j4, j5 — top
    ],
    members: [
      [0, 3], [3, 4], [4, 5], [5, 2], [1, 4], // left col, left beam, right beam, right col, center col
    ],
    supports: { left: 0, mid: 1, right: 2 },
    hingeJoints: { left: 3, right: 5 },
  },
};

export function FrameSchematic({
  variant = 'portal',
  leftSupport = 'pin',
  rightSupport = 'fixed',
  midSupport = null,
  hinges = [],
}) {
  const layout = LAYOUTS[variant];
  const { joints, members, supports, hingeJoints } = layout;

  const W = 420;
  const HH = 230;
  const supportSize = 14;

  // Which joints have hinges
  const hingeSet = new Set(hinges.map(h => hingeJoints[h]).filter(v => v != null));

  return (
    <svg viewBox={`0 0 ${W} ${HH}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`${variant} frame schematic`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Members */}
      {members.map(([a, b], i) => (
        <line key={`m${i}`}
          x1={joints[a][0]} y1={joints[a][1]}
          x2={joints[b][0]} y2={joints[b][1]}
          stroke="var(--charcoal)" strokeWidth={3} strokeLinecap="round" />
      ))}

      {/* Joints */}
      {joints.map(([x, y], i) => (
        <circle key={`j${i}`} cx={x} cy={y} r={3.5}
          fill="var(--charcoal)" />
      ))}

      {/* Internal hinge markers */}
      {Array.from(hingeSet).map(ji => (
        <circle key={`h${ji}`}
          cx={joints[ji][0]} cy={joints[ji][1]} r={5}
          fill="white" stroke="var(--charcoal)" strokeWidth={1.5} />
      ))}

      {/* Supports */}
      {renderFrameSupport(leftSupport, joints[supports.left], supportSize)}
      {renderFrameSupport(rightSupport, joints[supports.right], supportSize)}
      {supports.mid != null && midSupport && (
        renderFrameSupport(midSupport, joints[supports.mid], supportSize)
      )}
    </svg>
  );
}

/** Render pin, roller, or ground-mounted fixed support */
function renderFrameSupport(type, joint, size) {
  if (!type || !joint) return null;
  const [x, y] = joint;
  if (type === 'pin') return <PinSupport x={x} y={y} size={size} />;
  if (type === 'roller') return <RollerSupport x={x} y={y} size={size} />;
  if (type === 'fixed') return <GroundFixedSupport x={x} y={y} />;
  return null;
}

/** Ground-mounted fixed support: horizontal line + diagonal hatch marks */
function GroundFixedSupport({ x, y }) {
  const hw = 14; // half-width
  const gy = y + 3; // offset down to align with pin support height
  return (
    <g>
      <line x1={x - hw} y1={gy} x2={x + hw} y2={gy}
        stroke="var(--charcoal)" strokeWidth={2.5} />
      {[-10, -5, 0, 5, 10].map(dx => (
        <line key={dx}
          x1={x + dx} y1={gy}
          x2={x + dx - 4} y2={gy + 7}
          stroke="var(--charcoal)" strokeWidth={1.2} />
      ))}
    </g>
  );
}
