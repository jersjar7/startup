import React from 'react';
import { AppArrow } from '../components/brand/AppArrow';
import { LeagueCoin } from '../components/brand/LeagueCoin';

const LADDER = [
  { id: 'platinum', name: 'Platinum' },
  { id: 'gold', name: 'Gold' },
  { id: 'silver', name: 'Silver' },
  { id: 'bronze', name: 'Bronze' },
  { id: 'copper', name: 'Copper' },
];
const ORDINAL = (n) => `${n}${[, 'st', 'nd', 'rd'][n % 100 >> 3 ^ 1 && n % 10] || 'th'}`;

// One orchestrated moment, on one 1.2s clock (fractions of it below): the
// student's coin starts at last week's league, travels the ladder to the new
// one, the new league's name turns charcoal as it lands, then the words come
// in. Reduced motion shows the end state, which is what the markup already is.
const DURATION = 1200;
const LEAVE = 0.12;
const LAND = 0.72;
const SETTLE = 0.8;

function reducedMotion() {
  return typeof window === 'undefined' || !window.matchMedia
    || window.matchMedia('(prefers-reduced-motion: reduce)').matches;
}

/** The travelling coin's path for a move: an overshoot and settle going up, a short soft drop going down, a pulse in place. */
function travelFrames(moved, fromY, toY) {
  const at = (y, extra = '') => `translateY(${y}px)${extra}`;
  if (moved === 'up') {
    return [
      { offset: 0, transform: at(fromY) },
      { offset: LEAVE, transform: at(fromY, ' scale(1.06)'), easing: 'cubic-bezier(0.3, 0.7, 0.3, 1)' },
      { offset: LAND - 0.06, transform: at(toY - 5) },
      { offset: LAND, transform: at(toY) },
      { offset: SETTLE, transform: at(toY, ' scale(1.08)') },
      { offset: 1, transform: at(toY) },
    ];
  }
  if (moved === 'down') {
    return [
      { offset: 0, transform: at(fromY) },
      { offset: LEAVE, transform: at(fromY), easing: 'cubic-bezier(0.5, 0, 0.7, 1)' },
      { offset: LAND - 0.06, transform: at(toY + 3) },
      { offset: LAND, transform: at(toY) },
      { offset: 1, transform: at(toY) },
    ];
  }
  return [
    { offset: 0, transform: at(toY) },
    { offset: 0.3, transform: at(toY - 4, ' scale(1.12)') },
    { offset: 0.5, transform: at(toY) },
    { offset: LAND, transform: at(toY) },
    { offset: 1, transform: at(toY) },
  ];
}

// Last week's league result, shown once on the first visit after the week
// closes (ADR 0037). `result` is lastResult from /api/league.
export function LeagueResult({ result, onClose }) {
  const { moved, tier, tierName, newTier, newTierName, place, size, xp } = result;
  const ladderRef = React.useRef(null);
  const travellerRef = React.useRef(null);
  const copyRef = React.useRef(null);

  React.useLayoutEffect(() => {
    const ladder = ladderRef.current;
    const traveller = travellerRef.current;
    if (!ladder || !traveller || reducedMotion() || !ladder.animate) return undefined;
    const coinOf = (id) => ladder.querySelector(`li[data-tier="${id}"] .lcoin`);
    const toCoin = coinOf(newTier);
    const fromCoin = coinOf(tier) || toCoin;
    const toLabel = ladder.querySelector(`li[data-tier="${newTier}"] .league-ladder-name`);
    if (!toCoin || !fromCoin) return undefined;

    // Centre the travelling coin on each row's coin.
    const box = ladder.getBoundingClientRect();
    const half = traveller.getBoundingClientRect().height / 2;
    const centre = (el) => { const r = el.getBoundingClientRect(); return r.top + r.height / 2 - box.top - half; };
    const opts = { duration: DURATION, fill: 'both' };
    const grey = getComputedStyle(ladder.querySelector('li[data-tier]:not(.is-now):not(.is-was)') || ladder).color;
    const ink = toLabel ? getComputedStyle(toLabel).color : grey;

    const runs = [
      traveller.animate(travelFrames(moved, centre(fromCoin), centre(toCoin)).map((f) => ({ ...f, opacity: f.offset === 1 ? 0 : 1 })), opts),
      // The coin that stays in the row appears the moment the traveller lands.
      toCoin.animate([{ opacity: 0 }, { opacity: 0, offset: LAND }, { opacity: 1, offset: LAND + 0.001 }, { opacity: 1 }], opts),
    ];
    if (toLabel) runs.push(toLabel.animate([{ color: grey }, { color: grey, offset: LAND }, { color: ink, offset: SETTLE }, { color: ink }], opts));
    if (copyRef.current) {
      runs.push(copyRef.current.animate([
        { opacity: 0, transform: 'translateY(6px)' },
        { opacity: 0, transform: 'translateY(6px)', offset: LAND + 0.04, easing: 'ease-out' },
        { opacity: 1, transform: 'none' },
      ], opts));
    }
    return () => runs.forEach((a) => a.cancel());
  }, [moved, tier, newTier]);

  const title = moved === 'up' ? `You moved up to ${newTierName}`
    : moved === 'down' ? `You moved down to ${newTierName}`
      : `You stay in ${newTierName}`;
  const line = `${ORDINAL(place)} of ${size} in ${tierName} last week, with ${(xp || 0).toLocaleString('en-US')} XP.`;
  const next = moved === 'down' ? 'One good week brings you back.'
    : newTier === 'platinum' ? 'The top league. Stay in it.'
      : 'A new week starts now, and everyone is back at zero.';
  return (
    <div className="league-result-overlay" role="dialog" aria-modal="true" aria-label={title}>
      <div className="league-result">
        <ol className="league-ladder" ref={ladderRef} aria-hidden="true">
          {LADDER.map((t) => (
            <li key={t.id} data-tier={t.id} className={t.id === newTier ? 'is-now' : t.id === tier && moved !== 'stayed' ? 'is-was' : ''}>
              <LeagueCoin tier={t.id} size={t.id === newTier ? 32 : 20} />
              <span className="league-ladder-name">{t.name}</span>
            </li>
          ))}
          {/* Last week's coin, on its way; the new league's own coin replaces it on landing. */}
          <li className="league-ladder-track"><span ref={travellerRef}><LeagueCoin tier={tier || newTier} size={32} /></span></li>
        </ol>
        <div ref={copyRef}>
          <h2 className="league-result-title">{title}</h2>
          <p className="league-result-line">{line}</p>
          <p className="league-result-line">{next}</p>
        </div>
        <button type="button" className="league-result-cta" onClick={onClose}>
          See your league <AppArrow size={16} />
        </button>
      </div>
    </div>
  );
}
