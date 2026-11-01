import React from 'react';
import { AppArrow } from '../components/brand/AppArrow';

const LADDER = ['Platinum', 'Gold', 'Silver', 'Bronze', 'Copper'];
const ORDINAL = (n) => `${n}${[, 'st', 'nd', 'rd'][n % 100 >> 3 ^ 1 && n % 10] || 'th'}`;

// Last week's league result, shown once on the first visit after the week
// closes (ADR 0037). The ladder shows where the student is now; the line
// under it says how they got there, in our voice and without scolding.
export function LeagueResult({ result, onClose }) {
  const { moved, fromName, toName, place, of, xp } = result;
  const title = moved === 'up' ? `You moved up to ${toName}`
    : moved === 'down' ? `You moved down to ${toName}`
      : `You stay in ${toName}`;
  const line = `${ORDINAL(place)} of ${of} in ${fromName} last week, with ${xp.toLocaleString('en-US')} XP.`;
  const next = moved === 'down' ? 'One good week brings you back.'
    : toName === 'Platinum' ? 'The top league. Stay in it.'
      : 'A new week starts now, and everyone is back at zero.';
  return (
    <div className="league-result-overlay" role="dialog" aria-modal="true" aria-label={title}>
      <div className="league-result">
        <ol className="league-ladder" aria-hidden="true">
          {LADDER.map((t) => (
            <li key={t} className={t === toName ? 'is-now' : t === fromName && moved !== 'stay' ? 'is-was' : ''}>{t}</li>
          ))}
        </ol>
        <h2 className="league-result-title">{title}</h2>
        <p className="league-result-line">{line}</p>
        <p className="league-result-line">{next}</p>
        <button type="button" className="league-result-cta" onClick={onClose}>
          See your league <AppArrow size={16} />
        </button>
      </div>
    </div>
  );
}
