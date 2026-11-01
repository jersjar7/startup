import React from 'react';
import './leagueCoin.css';

// A league's coin (ADR 0037): the chapter coin's build, struck in the league's
// metal, with an engraved ring and the league's letter. The only place the
// five metal colours are used.
const LETTER = { copper: 'C', bronze: 'B', silver: 'S', gold: 'G', platinum: 'P' };

export function LeagueCoin({ tier, size = 34, className = '' }) {
  return (
    <span className={`lcoin lcoin--${tier} ${className}`} style={{ '--lcoin-d': `${size}px` }} aria-hidden="true">
      <span className="lcoin-rim" />
      <span className="lcoin-face"><span className="lcoin-ring" /><b>{LETTER[tier] || ''}</b></span>
    </span>
  );
}
