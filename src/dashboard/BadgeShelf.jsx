import React from 'react';
import {
  Footprints, Barbell, GraduationCap, Fire, CalendarCheck, CalendarStar,
  Lightning, Star, Cpu, Target, Compass, Sparkle, Trophy,
} from '@phosphor-icons/react';
import { nextBadge } from './road';

// The website's badges as a shelf of coins (docs/dashboard.md): earned ones
// raised in sunbeam, the rest dashed, and the closest one with its progress.
const ICONS = {
  'first-session': Footprints,
  'five-sessions': Barbell,
  'twenty-sessions': GraduationCap,
  'streak-3': Fire,
  'streak-7': CalendarCheck,
  'streak-30': CalendarStar,
  'xp-100': Lightning,
  'xp-500': Star,
  'xp-1000': Cpu,
  'first-mastery': Target,
  'multi-topic': Compass,
  'perfect-session': Sparkle,
};

export function BadgeShelf({ allBadges = [], earnedIds, totalXp = 0, streak = 0 }) {
  if (!allBadges.length) return null;
  const next = nextBadge(earnedIds, { totalXp, streak });
  const nextName = next ? allBadges.find((b) => b.id === next.id)?.name : null;
  return (
    <section className="shelf-card" aria-label="Badges">
      <p className="feed-over"><span>Badges</span><b>{earnedIds.size} of {allBadges.length}</b></p>
      <ul className="shelf-grid">
        {allBadges.map((b) => {
          const Icon = ICONS[b.id] || Trophy;
          const on = earnedIds.has(b.id);
          return (
            <li key={b.id} className={`shelf-badge${on ? ' is-on' : ''}`} title={`${b.name}: ${b.description}`} aria-label={`${b.name}, ${on ? 'earned' : 'not earned yet'}. ${b.description}`}>
              <Icon weight="bold" size={17} aria-hidden="true" />
            </li>
          );
        })}
      </ul>
      {next && nextName && (
        <div className="shelf-next">
          <span>Next: {nextName}</span>
          <span className="shelf-bar" aria-hidden="true"><i style={{ width: `${(next.have / next.need) * 100}%` }} /></span>
          <span className="shelf-left">{next.need - next.have} {next.unit} to go</span>
        </div>
      )}
    </section>
  );
}
