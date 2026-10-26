import React from 'react';
import { ChapterCoin } from '../components/brand/ChapterCoin';
import { CHAPTERS } from '../data/chapters';
import { feedLine, initials, timeAgo } from './road';

// What other students are doing (docs/dashboard.md): the people working
// right now first, then the latest of the day, one row each. The server
// works it out from the log every minute; a lesson someone opens while this
// page is up arrives sooner through the page's presence socket.
const POLL_MS = 60000;
const TINTS = ['var(--ember-bg)', 'var(--forest-bg)', 'var(--sunbeam-bg)', 'var(--cream-dark)'];
const chapterOf = (id) => CHAPTERS.find((c) => c.id === id);

function tintFor(name) {
  let h = 0;
  for (const c of String(name)) h = (h * 31 + c.charCodeAt(0)) >>> 0;
  return TINTS[h % TINTS.length];
}

// A presence frame ({ from, topic } or { from, chapter, lesson }) as a feed
// row. Frames from older pages may carry an email as the name; those are
// never shown.
function presenceRow(e, now) {
  const from = String(e.from || '').trim();
  if (!from || from.includes('@')) return null;
  const chapterId = chapterOf(e.topic) ? e.topic : chapterOf(e.chapter) ? e.chapter : null;
  return { name: from, kind: 'working', device: 'desk', chapterId, lesson: null, ts: now };
}

export function LiveFeed({ today, presence = [], viewerName = '' }) {
  const [feed, setFeed] = React.useState(null);

  React.useEffect(() => {
    let live = true;
    const load = () => {
      if (document.visibilityState !== 'visible') return;
      fetch(`/api/community/now?date=${today}`)
        .then((r) => (r.ok ? r.json() : null))
        .then((d) => { if (live && d) setFeed(d); })
        .catch(() => {});
    };
    load();
    const id = setInterval(load, POLL_MS);
    return () => { live = false; clearInterval(id); };
  }, [today]);

  const now = Date.now();
  const rows = [...(feed?.rows || [])];
  for (const e of presence) {
    const r = presenceRow(e, now);
    if (r && r.name !== viewerName && !rows.some((x) => x.name === r.name)) rows.unshift(r);
  }
  const shown = rows.slice(0, 6);
  const liveCount = shown.filter((r) => r.kind === 'working').length;
  const studied = feed?.studiedToday || 0;

  return (
    <section className="feed-card" aria-label="Right now">
      <p className="feed-over">
        <span>Right now</span>
        {liveCount > 0 && <span className="feed-live"><i aria-hidden="true" />{liveCount} live</span>}
      </p>
      {shown.length > 0 ? (
        <ul className="feed-list">
          {shown.map((r, i) => {
            const ch = chapterOf(r.chapterId);
            const working = r.kind === 'working';
            return (
              <li key={`${r.name}-${i}`} className="feed-row">
                <span className={`feed-avatar${working ? ' is-live' : ''}`} style={{ background: tintFor(r.name) }} aria-hidden="true">{initials(r.name)}</span>
                <p className="feed-text"><b>{r.name}</b> {feedLine(r, ch?.name)}</p>
                <span className="feed-side">
                  {ch && <ChapterCoin chapterId={ch.id} accent="forest" size={22} />}
                  <span className={`feed-when${working ? ' is-live' : ''}`}>{working ? 'now' : timeAgo(r.ts, feed?.now || now)}</span>
                </span>
              </li>
            );
          })}
        </ul>
      ) : (
        <p className="feed-empty">
          {feed ? 'Nobody else has studied yet today. Start, and you are the first one others see here.' : 'Loading who is studying.'}
        </p>
      )}
      {feed && (studied > 0 || feed.school) && (
        <p className="feed-foot">
          {studied > 0 && <span><b>{studied}</b> studied today</span>}
          {feed.school && <span><b>{feed.school.count}</b> from {feed.school.name} this week</span>}
        </p>
      )}
    </section>
  );
}
