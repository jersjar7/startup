import { describe, it, expect } from 'vitest';
const { buildFeed, finishedAt } = require('./community.js');
const { challengeOn, lessonsOf } = require('./challenges.js');

// The dashboard's live feed (docs/dashboard.md), from answers alone.

const NOW = Date.parse('2026-12-19T20:00:00Z');
const MIN = 60 * 1000;
const web = (email, itemId, minsAgo, extra = {}) => ({ email, itemId, chapterId: 'statics', source: 'web', kind: 'answer', grade: 'gotIt', ts: NOW - minsAgo * MIN, ...extra });
const phone = (email, gameId, round, minsAgo) => ({ email, itemId: `stat-fri-q1:${gameId}:${round}`, chapterId: 'statics', source: 'ios', kind: 'answer', grade: 'gotIt', ts: NOW - minsAgo * MIN });

describe('buildFeed', () => {
  it('shows someone who answered in the last ten minutes as working, on their lesson', () => {
    const rows = buildFeed({ answers: [web('a@x.com', 'stat-tjs-q1', 3), web('a@x.com', 'stat-tjs-q2', 1)], now: NOW });
    expect(rows).toEqual([expect.objectContaining({ kind: 'working', device: 'desk', chapterId: 'statics', lesson: 'Trusses: Method of Joints & Sections', count: 2 })]);
  });

  it('shows an earlier session as practiced, with only that session counted', () => {
    const answers = [
      web('a@x.com', 'stat-fsr-q1', 300), web('a@x.com', 'stat-fsr-q2', 299),
      web('a@x.com', 'stat-fri-q1', 62), web('a@x.com', 'stat-fri-q2', 61), web('a@x.com', 'stat-fri-q3', 60),
    ];
    const [row] = buildFeed({ answers, now: NOW });
    expect(row).toMatchObject({ kind: 'practiced', lesson: 'Friction', count: 3, ts: NOW - 60 * MIN });
  });

  it('finds the lesson of a phone round through its game', () => {
    const [row] = buildFeed({ answers: [phone('p@x.com', 'is-it-about-to-move', 1, 2), phone('p@x.com', 'is-it-about-to-move', 2, 1)], now: NOW });
    expect(row).toMatchObject({ kind: 'working', device: 'phone', lesson: 'Friction' });
  });

  it('never shows simulation answers', () => {
    const rows = buildFeed({ answers: [web('s@x.com', 'exam-q-1', 2, { eventId: 'exam-abc-q1' })], now: NOW });
    expect(rows).toEqual([]);
  });

  it('leaves out anything older than a day', () => {
    expect(buildFeed({ answers: [web('a@x.com', 'stat-fri-q1', 25 * 60)], now: NOW })).toEqual([]);
  });

  it('a challenge finish outranks an older session, and working outranks both', () => {
    const entry = challengeOn('2026-12-19');
    const all = (email, minsAgo) => lessonsOf('statics').flatMap((l) => l.practice.map((id) => ({ ...web(email, id, minsAgo), localDate: '2026-12-19' })));
    const finisher = all('f@x.com', 30);
    const rows = buildFeed({
      answers: [...finisher, web('w@x.com', 'stat-fri-q1', 120), web('w@x.com', 'stat-fri-q2', 2)],
      challenge: { entry, eventsByEmail: new Map([['f@x.com', finisher]]) },
      now: NOW,
    });
    expect(rows.map((r) => [r.email, r.kind])).toEqual([['w@x.com', 'working'], ['f@x.com', 'challenge']]);
  });

  it('puts the working first, then the latest, one row each, up to the limit', () => {
    const answers = [
      web('old@x.com', 'stat-fri-q1', 200),
      web('new@x.com', 'stat-fri-q1', 40),
      web('live@x.com', 'stat-fri-q1', 5),
    ];
    const dailies = [{ email: 'd@x.com', createdAt: new Date(NOW - 20 * MIN) }];
    const rows = buildFeed({ answers, dailies, now: NOW, limit: 3 });
    expect(rows.map((r) => [r.email, r.kind])).toEqual([['live@x.com', 'working'], ['d@x.com', 'daily'], ['new@x.com', 'practiced']]);
  });

  it('names each row with the name it is given', () => {
    const [row] = buildFeed({ answers: [web('a@x.com', 'stat-fri-q1', 1)], now: NOW, nameOf: () => 'Maria G.' });
    expect(row.name).toBe('Maria G.');
  });
});

describe('finishedAt', () => {
  it('is the time of the answer that cleared the last lesson', () => {
    const entry = challengeOn('2026-12-19');
    const ids = lessonsOf('statics').flatMap((l) => l.practice);
    const events = ids.map((id, i) => ({ itemId: id, source: 'web', kind: 'answer', grade: 'gotIt', localDate: '2026-12-19', ts: 1000 + i }));
    events.push({ itemId: ids[0], source: 'web', kind: 'answer', grade: 'gotIt', localDate: '2026-12-19', ts: 99999 });
    expect(finishedAt(entry, events)).toBe(1000 + ids.length - 1);
  });

  it('is null for someone who has not finished', () => {
    const entry = challengeOn('2026-12-19');
    expect(finishedAt(entry, [{ itemId: 'stat-fri-q1', source: 'web', kind: 'answer', grade: 'gotIt', localDate: '2026-12-19', ts: 1 }])).toBeNull();
  });
});
