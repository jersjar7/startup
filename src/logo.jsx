import React from 'react';

/**
 * FE4 RACCOONS brand logo — "FE" charcoal + "4" ember, "RACCOONS" below.
 * No padding, no extra whitespace. Fits any container.
 * @param {number} height - height in px (default 36)
 */
export function Logo({ height = 36 }) {
  return (
    <svg
      viewBox="0 0 200 95"
      height={height}
      style={{ display: 'block' }}
      aria-label="FE4 Raccoons logo"
    >
      <text
        x="0"
        y="58"
        fontFamily="'DM Sans', system-ui, sans-serif"
        fontWeight="900"
        fontSize="66"
        letterSpacing="-2"
      >
        <tspan fill="#2C2C2C">FE</tspan>
        <tspan fill="#E8683A">4</tspan>
      </text>
      <text
        x="1"
        y="88"
        fontFamily="'DM Sans', system-ui, sans-serif"
        fontWeight="700"
        fontSize="22"
        letterSpacing="7"
        fill="#2C2C2C"
      >
        RACCOONS
      </text>
    </svg>
  );
}
