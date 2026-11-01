import React from 'react';
import { ArrowUp, ArrowDown, CaretUp, CaretDown } from '@phosphor-icons/react';
import { initials } from './road';
import { tintFor } from './LiveFeed';

// The weekly league (ADR 0037, 0038), drawn like a chart: place with how it
// moved since yesterday, the student, their week. Where the move-up and
// move-down places start, a line names the league on the other side.
function Move({ move }) {
  if (move === 'up') return <CaretUp weight="bold" size={14} className="lg-move lg-move--up" aria-label="Up since yesterday" />;
  if (move === 'down') return <CaretDown weight="bold" size={14} className="lg-move lg-move--down" aria-label="Down since yesterday" />;
  if (move === 'new') return <span className="lg-new">New</span>;
  return <span className="lg-move" aria-hidden="true" />;
}

export function LeagueBoard({ league }) {
  const rows = league.rows || [];
  const { promote, demote } = league.zones || {};
  const downFrom = demote ? rows.length - demote : rows.length;
  const up = league.nextTierName;
  const down = league.prevTierName;

  if (!league.joined) {
    return (
      <section className="board-card league-card" aria-label={`${league.tierName} league`}>
        <p className="feed-over"><span>{league.tierName} league</span><b>Ends Saturday</b></p>
        <p className="league-join">Earn XP this week to join your {league.tierName} league.</p>
        <p className="board-foot">You are matched with up to 14 students studying this week.</p>
      </section>
    );
  }

  return (
    <section className="board-card league-card" aria-label={`${league.tierName} league`}>
      <p className="feed-over"><span>{league.tierName} league</span><b>Ends Saturday</b></p>
      <ol className="lg-list">
        {rows.map((e, i) => (
          <React.Fragment key={e.place}>
            {promote > 0 && up && i === 0 && (
              <li className="lg-line lg-line--up"><ArrowUp weight="bold" size={12} /><span>Moving up to {up}</span></li>
            )}
            {promote > 0 && up && i === promote && (
              <li className="lg-line lg-line--stay"><span>Staying in {league.tierName}</span></li>
            )}
            {demote > 0 && down && i === downFrom && (
              <li className="lg-line lg-line--down"><ArrowDown weight="bold" size={12} /><span>Moving down to {down}</span></li>
            )}
            <li className={`lg-row${e.isMe ? ' is-you' : ''}`}>
              <span className="lg-place"><b>{e.place}</b><Move move={e.move} /></span>
              <span className="feed-avatar" style={{ background: e.isMe ? 'var(--charcoal)' : tintFor(e.name) }} aria-hidden="true">{initials(e.name)}</span>
              <span className="lg-who">
                <b>{e.isMe ? 'You' : e.name}</b>
                <span>{e.xp.toLocaleString('en-US')} XP{e.days ? ` · ${e.days} ${e.days === 1 ? 'day' : 'days'} this week` : ''}</span>
              </span>
            </li>
          </React.Fragment>
        ))}
      </ol>
      <p className="board-foot">
        {[up && promote ? `Top ${promote} move up to ${up}.` : 'The top league.', down && demote ? `Bottom ${demote} move down to ${down}.` : ''].filter(Boolean).join(' ')}
      </p>
    </section>
  );
}
