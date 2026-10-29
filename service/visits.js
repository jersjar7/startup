// The first-party visit counter: how many people reach each public page, and
// from where, so the report can put a signup rate next to every page and
// channel. Search Console says what Google showed; this says what happened
// after the click.
//
// Counted as daily totals only. Nothing about the visitor is stored: no
// cookie, no IP, no user agent, no account. The browser sends one call per
// visit (see src/app.jsx) and the server adds one to a counter keyed by
// day, page and channel.
//
// Pure helpers here so the classification is unit-testable without a
// database. The report (scripts/baseline-report.js) classifies signups with
// the same functions, so a visitor and the signup they become always land in
// the same row.
const { PRERENDERED_ROUTE_PATTERN } = require('./prerenderedRoutes.js');

// Ordered: first match wins.
const REFERRER_GROUPS = [
  [/(^|\.)google\.[a-z.]+$|googlequicksearchbox/, 'organic search: Google'],
  [/(^|\.)bing\.com$/, 'organic search: Bing'],
  [/search\.yahoo\.com$/, 'organic search: Yahoo'],
  [/duckduckgo\.com$/, 'organic search: DuckDuckGo'],
  [/chatgpt\.com$|openai\.com$/, 'AI assistant: ChatGPT'],
  [/copilot\.(microsoft\.)?com$/, 'AI assistant: Copilot'],
  [/perplexity\.ai$/, 'AI assistant: Perplexity'],
  [/claude\.ai$/, 'AI assistant: Claude'],
  [/linkedin/, 'LinkedIn'],
  [/reddit/, 'Reddit'],
  [/tiktok/, 'TikTok'],
  [/instagram/, 'Instagram'],
  [/youtube|youtu\.be/, 'YouTube'],
];

function hostOf(raw) {
  if (!raw) return null;
  if (raw.startsWith('android-app://')) return raw.replace('android-app://', '').replace(/\/$/, '');
  try {
    return new URL(raw).hostname.replace(/^www\./, '');
  } catch {
    return raw;
  }
}

function groupReferrer(raw) {
  const h = hostOf(raw);
  if (!h) return null;
  for (const [re, label] of REFERRER_GROUPS) if (re.test(h)) return label;
  return `other: ${h}`;
}

// A tag or host as typed into a link can be anything; keep the counter's keys
// short and plain so a junk link cannot fill the collection with junk rows.
const clean = (v, max) => String(v).toLowerCase().replace(/[^a-z0-9._:-]/g, '').slice(0, max);

// Same order as the signup attribution: a tagged link beats the referrer.
// Visits with neither are "direct" (typed, bookmarked, or an app that hides
// where it came from).
function channelOf({ utmSource, referrer } = {}) {
  const tag = utmSource ? clean(utmSource, 40) : '';
  if (tag) return `utm: ${tag}`;
  const group = referrer ? groupReferrer(String(referrer).slice(0, 300)) : null;
  if (group && group.startsWith('other: ')) {
    const h = clean(group.slice(7), 60);
    return h ? `other: ${h}` : 'direct';
  }
  return group || 'direct';
}

// Public pages are counted by name. Everything behind sign-in is one row:
// someone who lands there first is a returning student, not a new visitor
// reading a page.
const NAMED = /^\/(login|stories\/mitch)$/;
function pageOf(path) {
  if (typeof path !== 'string') return '(other)';
  const p = path.split(/[?#]/)[0].toLowerCase().replace(/\/+$/, '') || '/';
  if (p === '/' || NAMED.test(p) || PRERENDERED_ROUTE_PATTERN.test(p)) return p;
  return '(signed-in app)';
}

// Crawlers that run JavaScript would otherwise count as visitors.
const BOT = /bot|crawl|spider|slurp|headless|lighthouse|preview|facebookexternalhit|embedly|python|curl|wget/i;
const isBot = (userAgent) => !userAgent || BOT.test(userAgent);

// Day in UTC, matching how the report buckets signups by createdAt.
const dayOf = (date) => date.toISOString().slice(0, 10);

// Visitor-to-signup rates per channel and per page, over the days from
// `since` (YYYY-MM-DD) on. `rows` are visitCounts documents; `users` are
// accounts with createdAt and acquisition.
//
// A signup's channel comes from the same tag and referrer the browser sent
// with the visit. Its page is the landing page the browser kept, which it
// keeps only for a tagged or referred visit, so the page table leaves direct
// visits out on both sides rather than compare against signups it cannot see.
function visitRates(rows, users, since) {
  const byChannel = {};
  const byPage = {};
  const add = (table, key, field, n) => {
    table[key] = table[key] || { visits: 0, newVisitors: 0, signups: 0 };
    table[key][field] += n;
  };
  for (const r of rows) {
    if (r.day < since) continue;
    add(byChannel, r.channel, 'visits', r.visits || 0);
    add(byChannel, r.channel, 'newVisitors', r.newVisitors || 0);
    if (r.channel === 'direct') continue;
    add(byPage, r.path, 'visits', r.visits || 0);
    add(byPage, r.path, 'newVisitors', r.newVisitors || 0);
  }
  for (const u of users) {
    if (!u.createdAt || dayOf(new Date(u.createdAt)) < since) continue;
    const a = u.acquisition || {};
    const channel = channelOf(a);
    add(byChannel, channel, 'signups', 1);
    if (channel !== 'direct' && a.landingPath) add(byPage, pageOf(a.landingPath), 'signups', 1);
  }
  const finish = (table) => Object.entries(table)
    .map(([key, t]) => ({ key, ...t, rate: t.newVisitors ? Math.round((t.signups / t.newVisitors) * 1000) / 10 : null }))
    .sort((a, b) => b.newVisitors - a.newVisitors || b.signups - a.signups);
  return { byChannel: finish(byChannel), byPage: finish(byPage) };
}

module.exports = { REFERRER_GROUPS, hostOf, groupReferrer, channelOf, pageOf, isBot, dayOf, visitRates };
