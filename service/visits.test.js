import { describe, it, expect } from 'vitest';
import express from 'express';
import request from 'supertest';
import { channelOf, pageOf, isBot, visitRates } from './visits.js';
import visitRouter from './routes/visit.js';

const CHROME = 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 Version/18.0 Mobile/15E148 Safari/604.1';

describe('channelOf', () => {
  it('prefers a tagged link over the referrer, like signup attribution', () => {
    expect(channelOf({ utmSource: 'LinkedIn', referrer: 'https://www.google.com/' })).toBe('utm: linkedin');
  });

  it('groups referrers the same way the report groups signups', () => {
    expect(channelOf({ referrer: 'https://www.google.com/' })).toBe('organic search: Google');
    expect(channelOf({ referrer: 'https://www.google.co.uk/' })).toBe('organic search: Google');
    expect(channelOf({ referrer: 'android-app://com.google.android.googlequicksearchbox/' })).toBe('organic search: Google');
    expect(channelOf({ referrer: 'https://chatgpt.com/' })).toBe('AI assistant: ChatGPT');
    expect(channelOf({ referrer: 'https://www.linkedin.com/feed/' })).toBe('LinkedIn');
    expect(channelOf({ referrer: 'https://canvas.uwf.edu/courses/1' })).toBe('other: canvas.uwf.edu');
  });

  it('calls a visit with no tag and no referrer direct', () => {
    expect(channelOf({})).toBe('direct');
    expect(channelOf()).toBe('direct');
    expect(channelOf({ utmSource: '', referrer: '' })).toBe('direct');
  });

  it('keeps junk out of the counter keys', () => {
    expect(channelOf({ utmSource: '<script>x</script>' })).toBe('utm: scriptxscript');
    expect(channelOf({ utmSource: 'a'.repeat(500) })).toBe(`utm: ${'a'.repeat(40)}`);
    expect(channelOf({ utmSource: '$$$' })).toBe('direct');
  });
});

describe('pageOf', () => {
  it('names every public page', () => {
    expect(pageOf('/')).toBe('/');
    expect(pageOf('/fe-civil/structural')).toBe('/fe-civil/structural');
    expect(pageOf('/fe-civil/structural/')).toBe('/fe-civil/structural');
    expect(pageOf('/fe-civil-exam-guide')).toBe('/fe-civil-exam-guide');
    expect(pageOf('/exam-simulation?x=1')).toBe('/exam-simulation');
    expect(pageOf('/login')).toBe('/login');
    expect(pageOf('/stories/mitch')).toBe('/stories/mitch');
  });

  it('folds everything behind sign-in into one row', () => {
    expect(pageOf('/dashboard')).toBe('(signed-in app)');
    expect(pageOf('/lesson/statics/forces')).toBe('(signed-in app)');
    expect(pageOf('/anything/made/up')).toBe('(signed-in app)');
    expect(pageOf(42)).toBe('(other)');
  });
});

describe('isBot', () => {
  it('skips crawlers and requests with no browser', () => {
    expect(isBot('Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)')).toBe(true);
    expect(isBot('Mozilla/5.0 HeadlessChrome/120.0')).toBe(true);
    expect(isBot(undefined)).toBe(true);
    expect(isBot(CHROME)).toBe(false);
  });
});

describe('POST /api/visit', () => {
  function app() {
    const calls = [];
    const counts = { updateOne: async (...args) => { calls.push(args); } };
    const a = express();
    a.use(express.json());
    a.use('/api/visit', visitRouter(counts, () => new Date('2026-10-29T15:00:00Z')));
    return { a, calls };
  }
  const settle = () => new Promise((r) => setImmediate(r));

  it('adds one visit and one new visitor to the day, page and channel', async () => {
    const { a, calls } = app();
    await request(a).post('/api/visit').set('User-Agent', CHROME)
      .send({ path: '/fe-civil/statics', referrer: 'https://www.google.com/' }).expect(204);
    await settle();
    expect(calls).toEqual([[
      { _id: '2026-10-29|/fe-civil/statics|organic search: Google' },
      { $set: { day: '2026-10-29', path: '/fe-civil/statics', channel: 'organic search: Google' }, $inc: { visits: 1, newVisitors: 1 } },
      { upsert: true },
    ]]);
  });

  it('counts a returning browser as a visit but not a new visitor', async () => {
    const { a, calls } = app();
    await request(a).post('/api/visit').set('User-Agent', CHROME).send({ path: '/', returning: true }).expect(204);
    await settle();
    expect(calls[0][1].$inc).toEqual({ visits: 1, newVisitors: 0 });
    expect(calls[0][0]._id).toBe('2026-10-29|/|direct');
  });

  it('ignores crawlers', async () => {
    const { a, calls } = app();
    await request(a).post('/api/visit').set('User-Agent', 'Googlebot/2.1').send({ path: '/' }).expect(204);
    await settle();
    expect(calls).toEqual([]);
  });

  it('still answers 204 when the database fails', async () => {
    const a = express();
    a.use(express.json());
    a.use('/api/visit', visitRouter({ updateOne: async () => { throw new Error('down'); } }));
    await request(a).post('/api/visit').set('User-Agent', CHROME).send({}).expect(204);
  });
});

describe('visitRates', () => {
  const rows = [
    { day: '2026-10-28', path: '/', channel: 'organic search: Google', visits: 50, newVisitors: 40 },
    { day: '2026-10-28', path: '/fe-civil/statics', channel: 'organic search: Google', visits: 12, newVisitors: 10 },
    { day: '2026-10-28', path: '/', channel: 'direct', visits: 30, newVisitors: 5 },
    { day: '2026-10-20', path: '/', channel: 'LinkedIn', visits: 99, newVisitors: 99 },
  ];
  const users = [
    { createdAt: new Date('2026-10-28T10:00:00Z'), acquisition: { referrer: 'https://www.google.com/', landingPath: '/' } },
    { createdAt: new Date('2026-10-28T11:00:00Z'), acquisition: { referrer: 'https://www.google.com/', landingPath: '/fe-civil/statics' } },
    { createdAt: new Date('2026-10-28T12:00:00Z'), acquisition: { source: 'friend' } },
    { createdAt: new Date('2026-10-28T13:00:00Z') },
    { createdAt: new Date('2026-10-01T13:00:00Z'), acquisition: { referrer: 'https://www.google.com/', landingPath: '/' } },
  ];

  it('puts signups next to new visitors per channel, from the start day on', () => {
    const { byChannel } = visitRates(rows, users, '2026-10-25');
    expect(byChannel).toEqual([
      { key: 'organic search: Google', visits: 62, newVisitors: 50, signups: 2, rate: 4 },
      { key: 'direct', visits: 30, newVisitors: 5, signups: 2, rate: 40 },
    ]);
  });

  it('leaves direct visits out of the page table on both sides', () => {
    const { byPage } = visitRates(rows, users, '2026-10-25');
    expect(byPage).toEqual([
      { key: '/', visits: 50, newVisitors: 40, signups: 1, rate: 2.5 },
      { key: '/fe-civil/statics', visits: 12, newVisitors: 10, signups: 1, rate: 10 },
    ]);
  });

  it('has no rate for a channel with signups but no counted visitors', () => {
    const { byChannel } = visitRates([], users.slice(0, 1), '2026-10-25');
    expect(byChannel[0].rate).toBeNull();
  });
});
