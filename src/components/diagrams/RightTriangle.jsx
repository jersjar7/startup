import React from 'react';

export function RightTriangle({ angle = 35, labels = true }) {
  // Clamp angle to sane range
  const theta = Math.max(15, Math.min(75, angle));
  const rad = (theta * Math.PI) / 180;

  // Triangle geometry — right angle at bottom-left
  const adjLen = 180; // adjacent side length (horizontal)
  const oppLen = adjLen * Math.tan(rad);
  const hypLen = adjLen / Math.cos(rad);

  // Vertices — position triangle so viewBox fits tightly
  const ax = 60;
  const ay = oppLen + 30;         // top padding of 30
  const bx = ax + adjLen;         // bottom-right
  const by = ay;
  const cx = ax;                  // top-left
  const cy = ay - oppLen;

  // Right angle marker
  const markerSize = 14;

  // Theta arc (at bottom-right vertex B)
  const arcR = 28;
  const arcStartX = bx - arcR;
  const arcStartY = by;
  const arcEndX = bx - arcR * Math.cos(rad);
  const arcEndY = by - arcR * Math.sin(rad);

  // Label positions
  const adjMidX = (ax + bx) / 2;
  const adjMidY = ay + 20;
  const oppMidX = ax - 16;
  const oppMidY = (ay + cy) / 2;

  // Hypotenuse label — midpoint, offset perpendicular outward from triangle
  const hypRawX = (bx + cx) / 2;
  const hypRawY = (by + cy) / 2;
  // Direction along hypotenuse (from C top-left to B bottom-right)
  const hypDx = bx - cx;
  const hypDy = by - cy;
  const hypLen2 = Math.sqrt(hypDx * hypDx + hypDy * hypDy);
  // Perpendicular unit vector pointing away from triangle (to the right of C→B)
  const perpX = -hypDy / hypLen2;
  const perpY = hypDx / hypLen2;
  const offsetDist = 14;
  const hypMidX = hypRawX + perpX * offsetDist;
  const hypMidY = hypRawY + perpY * offsetDist;
  // Rotation angle so text reads along the hypotenuse (uphill left-to-right)
  const hypAngle = Math.atan2(hypDy, hypDx) * (180 / Math.PI);

  // Theta label position
  const thetaLabelR = arcR + 14;
  const thetaLabelAngle = rad / 2;
  const thetaLabelX = bx - thetaLabelR * Math.cos(thetaLabelAngle);
  const thetaLabelY = by - thetaLabelR * Math.sin(thetaLabelAngle);

  return (
    <svg
      viewBox={`0 0 340 ${ay + 30}`}
      xmlns="http://www.w3.org/2000/svg"
      role="img"
      aria-label={`Right triangle with angle ${theta} degrees`}
      style={{ width: '100%', height: 'auto' }}
    >
      {/* Triangle */}
      <polygon
        points={`${ax},${ay} ${bx},${by} ${cx},${cy}`}
        fill="none"
        stroke="var(--charcoal)"
        strokeWidth="2.5"
        strokeLinejoin="round"
      />

      {/* Right angle marker at A */}
      <polyline
        points={`${ax + markerSize},${ay} ${ax + markerSize},${ay - markerSize} ${ax},${ay - markerSize}`}
        fill="none"
        stroke="var(--gray-400)"
        strokeWidth="1.5"
      />

      {/* Theta arc at B */}
      <path
        d={`M ${arcStartX},${arcStartY} A ${arcR},${arcR} 0 0 1 ${arcEndX},${arcEndY}`}
        fill="none"
        stroke="var(--ember)"
        strokeWidth="1.5"
      />

      {labels && (
        <>
          {/* Theta label */}
          <text
            x={thetaLabelX}
            y={thetaLabelY}
            fill="var(--ember)"
            fontFamily="var(--font-body)"
            fontStyle="italic"
            fontSize="13"
            textAnchor="middle"
            dominantBaseline="middle"
          >
            {'\u03B8'}
          </text>

          {/* Side labels */}
          <text
            x={oppMidX}
            y={oppMidY}
            fill="var(--gray-500)"
            fontFamily="var(--font-body)"
            fontSize="12"
            textAnchor="middle"
            dominantBaseline="middle"
            writingMode="tb"
          >
            opposite
          </text>

          <text
            x={adjMidX}
            y={adjMidY}
            fill="var(--gray-500)"
            fontFamily="var(--font-body)"
            fontSize="12"
            textAnchor="middle"
          >
            adjacent
          </text>

          <text
            x={hypMidX}
            y={hypMidY}
            fill="var(--gray-500)"
            fontFamily="var(--font-body)"
            fontSize="12"
            textAnchor="middle"
            dominantBaseline="middle"
            transform={`rotate(${hypAngle}, ${hypMidX}, ${hypMidY})`}
          >
            hypotenuse
          </text>
        </>
      )}
    </svg>
  );
}
