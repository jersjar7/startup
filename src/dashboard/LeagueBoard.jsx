import React from 'react';
import { ArrowUp, ArrowDown } from '@phosphor-icons/react';

// The weekly league (ADR 0037, docs/leagues-spec.md): the student's group of
// up to 15, everyone in it studying this week. A line under the move-up places
// and one above the move-down places, type alone, no pills.
export function LeagueBoard({ league }) {
  const rows = league.rows || [];
  const max = Math.max(1, rows[0]?.xp || 0);
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
      <ol className="board-list">
        {rows.map((e, i) => (
          <React.Fragment key={e.place}>
            {demote > 0 && i === downFrom && <li className="league-line league-line--down" aria-hidden="true"><ArrowDown weight="bold" size={11} /><span>Move down</span></li>}
            <li className={`board-row${e.isMe ? ' is-you' : ''}`}>
              <span className="board-rank">#{e.place}</span>
              <span className="board-name">{e.isMe ? 'You' : e.name}</span>
              <span className="board-bar" aria-hidden="true"><i style={{ width: `${Math.max(2, (e.xp / max) * 100)}%` }} /></span>
              <span className="board-xp">{e.xp.toLocaleString('en-US')}</span>
            </li>
            {promote > 0 && up && i === promote - 1 && i < rows.length - 1 && (
              <li className="league-line league-line--up" aria-hidden="true"><ArrowUp weight="bold" size={11} /><span>Move up</span></li>
            )}
          </React.Fragment>
        ))}
      </ol>
      <p className="board-foot">
        {[up && promote ? `Top ${promote} move up to ${up}.` : 'The top league.', down && demote && rows.length >= 8 ? `Bottom ${demote} move down to ${down}.` : ''].filter(Boolean).join(' ')}
      </p>
    </section>
  );
}
