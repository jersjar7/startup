// The PE waitlist, from the public page /pe-civil-water-resources (owner
// 2026-10-31). Nothing is built for the PE yet: the list is how we learn
// whether to build it, so every signup keeps where it came from. The go
// signal written in research/pe/product-proposal.md is 150 signups by
// 2027-03-31.
//
// One row per address and exam. Joining twice keeps the first row and its
// source, and only updates when they plan to sit it.
const { channelOf } = require('./visits.js');

const EXAMS = new Set(['pe-civil-wre']);

// Answers to "When are you taking it?", in the order the page lists them.
const WHEN = {
  'not-booked': 'Not booked yet',
  'before-2027-04': 'Before April 2027',
  '2027-04-to-12': 'April to December 2027',
  '2028-plus': '2028 or later',
};

// Which of the page's two forms it came from.
const PLACES = new Set(['top', 'bottom']);

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const tag = (v) => (typeof v === 'string' && v.trim() ? v.trim().toLowerCase().replace(/[^a-z0-9._:-]/g, '').slice(0, 60) || null : null);

/**
 * Checks a signup. Returns { ok: true, value } or { ok: false, msg } in words
 * the page shows. A filled honeypot field (`website`) is { ok: true, spam: true }:
 * the bot is thanked and nothing is stored.
 */
function validateWaitlist(body) {
  if (!body || typeof body !== 'object') return { ok: false, msg: 'Add your email address.' };
  if (typeof body.website === 'string' && body.website.trim()) return { ok: true, spam: true };
  const email = typeof body.email === 'string' ? body.email.trim().toLowerCase() : '';
  if (!EMAIL_RE.test(email) || email.length > 200) {
    return { ok: false, msg: 'That email address does not look right.' };
  }
  const exam = EXAMS.has(body.exam) ? body.exam : 'pe-civil-wre';
  const when = Object.prototype.hasOwnProperty.call(WHEN, body.when) ? body.when : null;
  const referrer = typeof body.referrer === 'string' ? body.referrer.slice(0, 300) : undefined;
  const utmSource = tag(body.utmSource);
  return {
    ok: true,
    value: {
      email,
      exam,
      when,
      channel: channelOf({ utmSource, referrer }),
      utmSource,
      utmMedium: tag(body.utmMedium),
      utmCampaign: tag(body.utmCampaign),
      place: PLACES.has(body.place) ? body.place : null,
    },
  };
}

/**
 * The admin summary from stored rows: totals, by channel and by exam timing.
 * Rows that unsubscribed still count as signups; `subscribed` says how many
 * are left to write to.
 */
function summarize(rows, now = new Date()) {
  const weekAgo = new Date(now.getTime() - 7 * 864e5);
  const out = { total: rows.length, subscribed: 0, lastWeek: 0, withFeAccount: 0, byChannel: {}, byWhen: {} };
  for (const r of rows) {
    if (!r.optedOut) out.subscribed++;
    if (r.createdAt && new Date(r.createdAt) >= weekAgo) out.lastWeek++;
    if (r.hasFeAccount) out.withFeAccount++;
    const ch = r.channel || 'direct';
    out.byChannel[ch] = (out.byChannel[ch] || 0) + 1;
    const w = WHEN[r.when] || 'Not answered';
    out.byWhen[w] = (out.byWhen[w] || 0) + 1;
  }
  return out;
}

module.exports = { validateWaitlist, summarize, WHEN };
