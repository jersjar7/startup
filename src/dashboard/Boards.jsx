import React from 'react';
import { boardRows } from './road';

// This week's and the all-time boards side by side under the chapters
// (docs/dashboard.md). A bar per student shows the gaps between them, not
// just the order; the viewer is the one ember row.
function Board({ title, note, entries, xpKey, empty }) {
  const rows = boardRows(entries, 10);
  const max = Math.max(1, ...(entries || []).slice(0, 1).map((e) => e[xpKey] || 0));
  const onIt = (entries || []).some((e) => e.isCurrentUser);
  return (
    <section className="board-card" aria-label={title}>
      <p className="feed-over"><span>{title}</span><b>{note}</b></p>
      {rows.length === 0 ? (
        <p className="feed-empty">{empty}</p>
      ) : (
        <ol className="board-list">
          {rows.map((e, i) => (e.gap ? (
            <li key={`gap-${i}`} className="board-gap" aria-hidden="true">···</li>
          ) : (
            <li key={e.rank} className={`board-row${e.isCurrentUser ? ' is-you' : ''}`}>
              <span className="board-rank">#{e.rank}</span>
              <span className="board-name">{e.isCurrentUser ? 'You' : e.name}</span>
              <span className="board-bar" aria-hidden="true"><i style={{ width: `${Math.max(2, ((e[xpKey] || 0) / max) * 100)}%` }} /></span>
              <span className="board-xp">{(e[xpKey] || 0).toLocaleString('en-US')}</span>
            </li>
          )))}
        </ol>
      )}
      {rows.length > 0 && !onIt && <p className="board-foot">You are not on this board yet.</p>}
    </section>
  );
}

export function Boards({ weekly, allTime }) {
  return (
    <div className="dash-boards">
      <Board title="This week" note="Ends Saturday" entries={weekly} xpKey="weeklyXp" empty="Finish a session to start this week's board." />
      <Board title="All time" note={`Top ${Math.min(30, (allTime || []).length) || 30}`} entries={allTime} xpKey="totalXp" empty="Earn XP to climb the all-time board." />
    </div>
  );
}
