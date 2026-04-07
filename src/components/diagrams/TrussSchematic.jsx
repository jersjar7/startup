import React from 'react';
import { PinSupport, RollerSupport } from './primitives';

/**
 * Configurable truss schematic for determinacy/stability problems.
 *
 * Shows: members (lines), joints (dots), support symbols.
 * Student counts m, j, r to classify the structure.
 *
 * variant = 'warren7'  — 7 joints, 11 members (Warren zigzag)
 * variant = 'pratt6'   — 6 joints, 9 members (rectangular Pratt)
 */

const LAYOUTS = {
  warren7: {
    // 4 bottom + 3 top (offset) = 7 joints
    joints: [
      [50, 145], [150, 145], [250, 145], [350, 145],  // j0-j3 bottom
      [100, 45], [200, 45], [300, 45],                  // j4-j6 top
    ],
    members: [
      [0, 1], [1, 2], [2, 3],       // bottom chord
      [4, 5], [5, 6],               // top chord
      [0, 4], [4, 1], [1, 5], [5, 2], [2, 6], [6, 3], // zigzag web
    ],
    supports: { left: 0, right: 3 },
  },
  pratt6: {
    // 3 bottom + 3 top (aligned) = 6 joints
    joints: [
      [70, 145], [200, 145], [330, 145],   // j0-j2 bottom
      [70, 45], [200, 45], [330, 45],       // j3-j5 top
    ],
    members: [
      [0, 1], [1, 2],               // bottom chord
      [3, 4], [4, 5],               // top chord
      [0, 3], [3, 1], [1, 4], [4, 2], [2, 5], // web
    ],
    supports: { left: 0, mid: 1, right: 2 },
  },
};

export function TrussSchematic({
  variant = 'warren7',
  leftSupport = 'pin',
  rightSupport = 'roller',
  midSupport = null,
}) {
  const layout = LAYOUTS[variant];
  const { joints, members, supports } = layout;

  const W = 420;
  const HH = 200;
  const supportSize = 14;

  return (
    <svg viewBox={`0 0 ${W} ${HH}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`${variant === 'warren7' ? '7-joint' : '6-joint'} truss schematic`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Members */}
      {members.map(([a, b], i) => (
        <line key={`m${i}`}
          x1={joints[a][0]} y1={joints[a][1]}
          x2={joints[b][0]} y2={joints[b][1]}
          stroke="var(--charcoal)" strokeWidth={2} strokeLinecap="round" />
      ))}

      {/* Joints */}
      {joints.map(([x, y], i) => (
        <circle key={`j${i}`} cx={x} cy={y} r={3.5}
          fill="var(--charcoal)" />
      ))}

      {/* Supports */}
      {renderSupport(leftSupport, joints[supports.left], supportSize)}
      {renderSupport(rightSupport, joints[supports.right], supportSize)}
      {supports.mid != null && midSupport && (
        renderSupport(midSupport, joints[supports.mid], supportSize)
      )}
    </svg>
  );
}

function renderSupport(type, joint, size) {
  if (!type || !joint) return null;
  const [x, y] = joint;
  if (type === 'pin') return <PinSupport x={x} y={y} size={size} />;
  if (type === 'roller') return <RollerSupport x={x} y={y} size={size} />;
  return null;
}
