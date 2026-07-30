#!/usr/bin/env node
/**
 * baseline-report.js — one-shot business baseline pull for growth planning.
 *
 * Reads production MongoDB directly and prints the numbers a growth plan needs
 * to calibrate targets. Read-only: it never writes to the database.
 *
 * Run from the repo root:
 *   node --env-file=service/.env scripts/baseline-report.js
 *
 * Add --json to emit machine-readable output instead of the text report.
 *
 * Output is aggregate-only by design: no individual emails or names, so the
 * report can be handed to an outside analyst without shipping customer PII.
 */

import { createRequire } from 'node:module';

// The repo root is ESM and `mongodb` is installed under service/, so resolve it
// from there rather than from this file's directory.
const require = createRequire(new URL('../service/', import.meta.url));
const { MongoClient, ObjectId } = require('mongodb');

const HOST = process.env.DB_HOSTNAME;
const USER = process.env.DB_USERNAME;
const PASS = process.env.DB_PASSWORD;

if (!HOST || !USER || !PASS) {
  console.error('Missing DB_HOSTNAME / DB_USERNAME / DB_PASSWORD.');
  console.error('Try: node --env-file=service/.env scripts/baseline-report.js');
  process.exit(1);
}

const EXCLUDED = (process.env.EXCLUDED_ACCOUNTS || 'admin@oqupa.com,qa-bot@fe4raccoons.com')
  .split(',')
  .map((s) => s.trim().toLowerCase())
  .filter(Boolean);

// Plus-addressed aliases of an excluded account are excluded too, so
// admin+test1@oqupa.com and every future admin+whatever@ test signup is kept
// out of the numbers without editing this list each time.
//
// The app's own normalizeEmail() does NOT strip +tags (they are genuinely
// distinct accounts, which is why they work as throwaways). This collapsing
// happens only when matching against the exclusion list.
const stripPlusTag = (email) => {
  const [local = '', domain = ''] = String(email || '').toLowerCase().split('@');
  return `${local.split('+')[0]}@${domain}`;
};
const EXCLUDED_BASES = new Set(EXCLUDED.map(stripPlusTag));
const isInternal = (email) => {
  const e = String(email || '').toLowerCase();
  return EXCLUDED.includes(e) || EXCLUDED_BASES.has(stripPlusTag(e));
};

const JSON_OUT = process.argv.includes('--json');
const DAY = 86400000;
const now = new Date();
const ago = (d) => new Date(now.getTime() - d * DAY);
const pct = (n, d) => (d > 0 ? Math.round((n / d) * 1000) / 10 : 0);
const ym = (d) => new Date(d).toISOString().slice(0, 7);
const ymd = (d) => (d ? new Date(d).toISOString().slice(0, 10) : 'n/a');

// ISO-ish week key (Sunday-anchored) so the signup trend is visible at a
// resolution month buckets hide.
const weekKey = (d) => {
  const t = new Date(d);
  t.setUTCHours(0, 0, 0, 0);
  t.setUTCDate(t.getUTCDate() - t.getUTCDay());
  return t.toISOString().slice(0, 10);
};

const median = (arr) => {
  if (!arr.length) return null;
  const s = [...arr].sort((a, b) => a - b);
  const m = Math.floor(s.length / 2);
  return s.length % 2 ? s[m] : Math.round(((s[m - 1] + s[m]) / 2) * 10) / 10;
};

async function main() {
  const client = new MongoClient(`mongodb+srv://${USER}:${PASS}@${HOST}`, {
    serverSelectionTimeoutMS: 20000,
  });
  await client.connect();
  const db = client.db('fe4raccoons');

  const users = db.collection('users');
  const purchases = db.collection('purchases');
  const funnelEvents = db.collection('funnelEvents');
  const examAttempts = db.collection('examAttempts');
  const sessionLog = db.collection('sessionLog');
  const reviewEvents = db.collection('reviewEvents');
  const problemHistory = db.collection('problemHistory');
  const userStats = db.collection('userStats');

  // Resolve the concrete internal-email list from the real data, so the same
  // exclusion (including plus-aliases) applies to every collection below.
  const allUsersRaw = await users.find({}).toArray();
  const internalEmails = allUsersRaw.map((u) => u.email).filter(isInternal);
  const notInternal = { email: { $nin: internalEmails } };

  // ---- Users -------------------------------------------------------------
  const allUsers = allUsersRaw.filter((u) => !isInternal(u.email));
  const totalUsers = allUsers.length;
  const idToUser = new Map(allUsers.map((u) => [String(u._id), u]));

  const has = (u, f) => u[f] !== undefined && u[f] !== null && u[f] !== '';
  const verifiedUsers = allUsers.filter((u) => u.emailVerified === true).length;
  const withExamDate = allUsers.filter((u) => has(u, 'examDate')).length;
  const withName = allUsers.filter((u) => has(u, 'firstName')).length;
  const optedOut = allUsers.filter((u) => u.lifecycleOptOut === true).length;
  const studentVerified = allUsers.filter((u) => u.studentVerified === true).length;

  // The email sim pitch only fires for users who have an exam date on file and
  // have not been pitched before, so "pitched" — not signups — is the true
  // denominator for the one monetization mechanic that currently exists.
  const pitchedIds = new Set(
    allUsers.filter((u) => has(u, 'simPitchedAt')).map((u) => String(u._id)),
  );
  const withSimAccess = allUsers.filter((u) => u.examSimAccess === true).length;

  const signupsIn = (d) => allUsers.filter((u) => new Date(u.createdAt) >= ago(d)).length;
  const firstSignupAt = allUsers.reduce(
    (min, u) => (!min || new Date(u.createdAt) < new Date(min) ? u.createdAt : min),
    null,
  );

  // Signups per calendar month AND per week — monthly buckets are too coarse to
  // tell an accelerating channel from a flat one on a 2-month-old dataset.
  const signupsByMonth = {};
  const signupsByWeek = {};
  allUsers.forEach((u) => {
    const k = ym(u.createdAt);
    signupsByMonth[k] = (signupsByMonth[k] || 0) + 1;
    const w = weekKey(u.createdAt);
    signupsByWeek[w] = (signupsByWeek[w] || 0) + 1;
  });

  // ---- Revenue -----------------------------------------------------------
  // NOTE: purchases key off `userId` (string ObjectId) and store `amount` in
  // CENTS. There is no `email` or `amountCents` field on this collection.
  const paidRaw = await purchases.find({ status: 'completed' }).sort({ createdAt: 1 }).toArray();
  const paid = paidRaw.filter((p) => {
    const u = idToUser.get(String(p.userId));
    return u !== undefined; // drops internal/deleted accounts
  });
  const revenueCents = paid.reduce((s, p) => s + (p.amount || 0), 0);
  const byTier = paid.reduce((acc, p) => {
    const t = p.tier || 'unknown';
    acc[t] = (acc[t] || 0) + 1;
    return acc;
  }, {});
  const liveMode = paid.filter((p) => String(p.stripeSessionId || '').startsWith('cs_live_')).length;
  const pitchedWhoBought = paid.filter((p) => pitchedIds.has(String(p.userId))).length;
  // Sales that predate the pitch mechanic entirely — these bought unprompted,
  // which is the strongest demand signal in the dataset.
  const boughtUnpitched = paid.length - pitchedWhoBought;
  const revenueByMonth = {};
  paid.forEach((p) => {
    const k = ym(p.createdAt);
    revenueByMonth[k] = (revenueByMonth[k] || 0) + (p.amount || 0) / 100;
  });

  // Consideration window: signup -> purchase.
  const daysToPurchase = paid
    .map((p) => {
      const u = idToUser.get(String(p.userId));
      if (!u?.createdAt) return null;
      return Math.round((new Date(p.createdAt) - new Date(u.createdAt)) / DAY);
    })
    .filter((n) => n !== null && n >= 0);

  // Purchase -> exam date. Nobody in this industry publishes this; the DB can
  // answer it, and it decides where the reminder-email ladder should aim.
  const daysBeforeExam = paid
    .map((p) => {
      const u = idToUser.get(String(p.userId));
      if (!u?.examDate) return null;
      return Math.round((new Date(u.examDate) - new Date(p.createdAt)) / DAY);
    })
    .filter((n) => n !== null);

  // ---- Funnel ------------------------------------------------------------
  const evAgg = await funnelEvents
    .aggregate([{ $group: { _id: '$type', n: { $sum: 1 }, users: { $addToSet: '$email' } } }])
    .toArray();
  const ev = {};
  evAgg.forEach((e) => {
    ev[e._id] = {
      events: e.n,
      users: e.users.filter((x) => x && !isInternal(x)).length,
    };
  });
  const evUsers = (t) => ev[t]?.users || 0;
  const checkoutStartUsers = evUsers('checkout_started');

  const evRange = {
    first: (await funnelEvents.find().sort({ createdAt: 1 }).limit(1).toArray())[0]?.createdAt,
    last: (await funnelEvents.find().sort({ createdAt: -1 }).limit(1).toArray())[0]?.createdAt,
  };

  // ---- Engagement --------------------------------------------------------
  // Two independent activity streams: web study sessions and mobile/spaced
  // reviews. Union them so mobile-only users are not counted as inactive.
  const activeUsers = async (days) => {
    const a = await sessionLog.distinct('email', { completedAt: { $gte: ago(days) } });
    const b = await reviewEvents.distinct('email', { receivedAt: { $gte: ago(days) } });
    const set = new Set(
      [...a, ...b].filter((e) => e && !isInternal(e)),
    );
    return set.size;
  };

  const attempts = await examAttempts
    .aggregate([{ $group: { _id: '$status', n: { $sum: 1 } } }])
    .toArray();

  // problemHistory holds ONE doc per (user, problem) with attempt tallies, so
  // distinct problems seen != attempts made. Report both.
  const perUser = await problemHistory
    .aggregate([
      { $match: { email: { $nin: internalEmails } } },
      {
        $group: {
          _id: '$email',
          problems: { $sum: 1 },
          attempts: { $sum: { $add: ['$timesCorrect', '$timesIncorrect'] } },
        },
      },
    ])
    .toArray();
  const bucket = (lo, hi) =>
    perUser.filter((u) => u.problems >= lo && (hi === null || u.problems < hi)).length;

  const stats = await userStats.find({ email: { $nin: internalEmails } }).toArray();
  const streaks = stats.map((s) => s.currentStreak || 0);

  // ---- Exam-date distribution -------------------------------------------
  // Which NCEES windows the audience is actually sitting for. This is the
  // demand calendar the plan has to be timed against.
  const examByMonth = {};
  let examPast = 0;
  allUsers.forEach((u) => {
    if (!has(u, 'examDate')) return;
    const d = new Date(u.examDate);
    if (Number.isNaN(d.getTime())) return;
    if (d < now) examPast += 1;
    const k = ym(d);
    examByMonth[k] = (examByMonth[k] || 0) + 1;
  });

  // ---- Acquisition -------------------------------------------------------
  // Three independent signals live on `acquisition`, and reading only the
  // self-report survey badly understates coverage:
  //   utmSource   - set when the visitor arrived on a tagged link
  //   referrer    - captured automatically for any EXTERNAL referrer
  //   source      - the dashboard survey, which ~90% of users skip
  // Referrer is by far the widest of the three. Prefer utm > referrer > survey.
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

  const hostOf = (raw) => {
    if (!raw) return null;
    if (raw.startsWith('android-app://')) return raw.replace('android-app://', '').replace(/\/$/, '');
    try {
      return new URL(raw).hostname.replace(/^www\./, '');
    } catch {
      return raw;
    }
  };
  const groupReferrer = (raw) => {
    const h = hostOf(raw);
    if (!h) return null;
    for (const [re, label] of REFERRER_GROUPS) if (re.test(h)) return label;
    return `other: ${h}`;
  };

  const acqCounts = {}; // survey answers only, kept for continuity
  const channelCounts = {}; // best-available channel per user
  const referrerHosts = {};
  let acqObject = 0;
  let withUtm = 0;
  let withReferrer = 0;
  let attributedAny = 0;
  const landingPaths = {};

  allUsers.forEach((u) => {
    const a = u.acquisition;
    if (a) acqObject += 1;
    const src = a?.source;
    if (src) acqCounts[src] = (acqCounts[src] || 0) + 1;
    if (a?.utmSource) withUtm += 1;
    if (a?.referrer) {
      withReferrer += 1;
      const h = hostOf(a.referrer);
      if (h) referrerHosts[h] = (referrerHosts[h] || 0) + 1;
    }
    if (a?.landingPath) landingPaths[a.landingPath] = (landingPaths[a.landingPath] || 0) + 1;

    let channel;
    if (a?.utmSource) channel = `utm: ${a.utmSource}`;
    else if (a?.referrer) channel = groupReferrer(a.referrer);
    else if (src) channel = `self-report: ${src}`;
    else channel = '(unattributed)';
    if (channel !== '(unattributed)') attributedAny += 1;
    channelCounts[channel] = (channelCounts[channel] || 0) + 1;
  });
  const acqAnswered = Object.values(acqCounts).reduce((a, b) => a + b, 0);

  const sortDesc = (o) => Object.fromEntries(Object.entries(o).sort((a, b) => b[1] - a[1]));

  const report = {
    generatedAt: now.toISOString(),
    excludedAccounts: EXCLUDED,
    excludedEmailsMatched: internalEmails.sort(),
    users: {
      total: totalUsers,
      verified: verifiedUsers,
      pctVerified: pct(verifiedUsers, totalUsers),
      studentVerified,
      withExamDate,
      pctWithExamDate: pct(withExamDate, totalUsers),
      withFirstName: withName,
      lifecycleOptOut: optedOut,
      firstSignupAt,
      signups_last_7d: signupsIn(7),
      signups_last_30d: signupsIn(30),
      signups_last_90d: signupsIn(90),
      signupsByMonth,
      signupsByWeek: Object.fromEntries(Object.entries(signupsByWeek).sort()),
    },
    revenue: {
      totalSales: paid.length,
      liveModeSales: liveMode,
      grossRevenue: revenueCents / 100,
      avgOrderValue: paid.length ? Math.round((revenueCents / paid.length / 100) * 100) / 100 : 0,
      byTier,
      revenueByMonth,
      sales_last_30d: paid.filter((p) => new Date(p.createdAt) >= ago(30)).length,
      sales_last_90d: paid.filter((p) => new Date(p.createdAt) >= ago(90)).length,
      medianDaysSignupToPurchase: median(daysToPurchase),
      daysSignupToPurchaseAll: daysToPurchase,
      medianDaysPurchaseBeforeExam: median(daysBeforeExam),
      daysPurchaseBeforeExamAll: daysBeforeExam,
      daysBeforeExamSample: daysBeforeExam.length,
    },
    funnel: {
      eventWindow: evRange,
      signups: totalUsers,
      quickstartActivated: evUsers('quickstart_activated'),
      quickstartCompleted: evUsers('quickstart_completed'),
      simBannerShown: evUsers('sim_banner_shown'),
      simBannerClicked: evUsers('sim_banner_click'),
      checkoutStarted: checkoutStartUsers,
      purchased: paid.length,
      pitched: pitchedIds.size,
      pitchedWhoBought,
      boughtUnpitched,
      grantedSimAccess: withSimAccess,
      rates: {
        pitchToPurchase: pct(pitchedWhoBought, pitchedIds.size),
        examDateToPitched: pct(pitchedIds.size, withExamDate),
        signupToQuickstartActivated: pct(evUsers('quickstart_activated'), totalUsers),
        activatedToCompleted: pct(evUsers('quickstart_completed'), evUsers('quickstart_activated')),
        bannerShownToClick: pct(evUsers('sim_banner_click'), evUsers('sim_banner_shown')),
        signupToCheckout: pct(checkoutStartUsers, totalUsers),
        checkoutToPurchase: pct(paid.length, checkoutStartUsers),
        signupToPurchase: pct(paid.length, totalUsers),
      },
      abandonedCheckouts: Math.max(0, checkoutStartUsers - paid.length),
      eventCounts: ev,
    },
    engagement: {
      active7d: await activeUsers(7),
      active30d: await activeUsers(30),
      examAttemptsByStatus: Object.fromEntries(attempts.map((a) => [a._id, a.n])),
      usersWhoTouchedAProblem: perUser.length,
      totalProblemAttempts: perUser.reduce((s, u) => s + u.attempts, 0),
      users_with_0_problems: totalUsers - perUser.length,
      users_1_to_24: bucket(1, 25),
      users_25_to_99: bucket(25, 100),
      users_100_to_299: bucket(100, 300),
      users_300_plus: bucket(300, null),
      medianProblemsPerActiveUser: median(perUser.map((u) => u.problems)),
      usersWithStreakGte3: streaks.filter((s) => s >= 3).length,
      usersWithStreakGte7: streaks.filter((s) => s >= 7).length,
    },
    examDates: {
      usersWithDate: withExamDate,
      alreadyPast: examPast,
      byMonth: Object.fromEntries(Object.entries(examByMonth).sort()),
    },
    acquisition: {
      usersWithAcquisitionObject: acqObject,
      surveyAnswered: acqAnswered,
      pctSurveyAnswered: pct(acqAnswered, totalUsers),
      withReferrer,
      withUtm,
      attributedAny,
      pctAttributedAny: pct(attributedAny, totalUsers),
      unattributed: totalUsers - attributedAny,
      byChannel: sortDesc(channelCounts),
      surveyBySource: sortDesc(acqCounts),
      referrerHosts: sortDesc(referrerHosts),
      landingPaths: sortDesc(landingPaths),
    },
  };

  await client.close();

  if (JSON_OUT) {
    console.log(JSON.stringify(report, null, 2));
    return;
  }

  const L = (s = '') => console.log(s);
  const row = (k, v) => L(`  ${String(k).padEnd(36)} ${v}`);
  const r = report;

  L('');
  L('='.repeat(64));
  L('  FE FOR RACCOONS - BASELINE REPORT');
  L(`  ${now.toISOString().slice(0, 16).replace('T', ' ')} UTC`);
  L('='.repeat(64));

  L('\nUSERS');
  row('Total registered', r.users.total);
  row('Email verified', `${r.users.verified} (${r.users.pctVerified}%)`);
  row('Student (.edu) verified', r.users.studentVerified);
  row('Has exam date on file', `${r.users.withExamDate} (${r.users.pctWithExamDate}%)`);
  row('Gave a first name', r.users.withFirstName);
  row('Unsubscribed from lifecycle', r.users.lifecycleOptOut);
  row(
    'Signups 7d / 30d / 90d',
    `${r.users.signups_last_7d} / ${r.users.signups_last_30d} / ${r.users.signups_last_90d}`,
  );
  row('First signup', ymd(r.users.firstSignupAt));
  L('  Signups by month:');
  Object.entries(r.users.signupsByMonth)
    .sort()
    .forEach(([k, v]) => row(`    ${k}`, v));
  L('  Signups by week (week beginning):');
  Object.entries(r.users.signupsByWeek).forEach(([k, v]) =>
    row(`    ${k}`, `${String(v).padStart(3)}  ${'#'.repeat(v)}`),
  );

  L('\nREVENUE');
  row('Total sales (all time)', r.revenue.totalSales);
  row('Stripe LIVE-mode sales', `${r.revenue.liveModeSales} of ${r.revenue.totalSales}`);
  row('Gross revenue', `$${r.revenue.grossRevenue.toFixed(2)}`);
  row('Average order value', `$${r.revenue.avgOrderValue.toFixed(2)}`);
  row('By tier', JSON.stringify(r.revenue.byTier));
  row('Sales 30d / 90d', `${r.revenue.sales_last_30d} / ${r.revenue.sales_last_90d}`);
  row('Median days signup -> purchase', r.revenue.medianDaysSignupToPurchase ?? 'n/a');
  row('  all values', JSON.stringify(r.revenue.daysSignupToPurchaseAll));
  row(
    'Median days purchase -> exam',
    r.revenue.medianDaysPurchaseBeforeExam ?? `n/a (sample ${r.revenue.daysBeforeExamSample})`,
  );
  row('  all values', JSON.stringify(r.revenue.daysPurchaseBeforeExamAll));
  L('  Revenue by month:');
  Object.entries(r.revenue.revenueByMonth)
    .sort()
    .forEach(([k, v]) => row(`    ${k}`, `$${v.toFixed(2)}`));

  L('\nFUNNEL  (events logged since ' + ymd(r.funnel.eventWindow.first) + ')');
  row('Signups', r.funnel.signups);
  row(
    'Quick-start diagnostic activated',
    `${r.funnel.quickstartActivated} (${r.funnel.rates.signupToQuickstartActivated}% of signups)`,
  );
  row(
    'Quick-start completed',
    `${r.funnel.quickstartCompleted} (${r.funnel.rates.activatedToCompleted}% of activated)`,
  );
  row('Saw exam-sim banner', r.funnel.simBannerShown);
  row(
    'Clicked exam-sim banner',
    `${r.funnel.simBannerClicked} (${r.funnel.rates.bannerShownToClick}% of shown)`,
  );
  row(
    'Started checkout',
    `${r.funnel.checkoutStarted} (${r.funnel.rates.signupToCheckout}% of signups)`,
  );
  row('Purchased', `${r.funnel.purchased} (${r.funnel.rates.signupToPurchase}% of signups)`);
  row('Checkout -> purchase', `${r.funnel.rates.checkoutToPurchase}%`);
  row('ABANDONED CHECKOUTS', `${r.funnel.abandonedCheckouts}  (no recovery email exists)`);
  L('  Raw event counts:');
  Object.entries(r.funnel.eventCounts)
    .sort((a, b) => b[1].events - a[1].events)
    .forEach(([k, v]) => row(`    ${k}`, `${v.events} events / ${v.users} users`));

  L('\nENGAGEMENT');
  row('Active last 7d / 30d', `${r.engagement.active7d} / ${r.engagement.active30d}`);
  row('Exam sim attempts', JSON.stringify(r.engagement.examAttemptsByStatus));
  row('Users who answered >=1 problem', r.engagement.usersWhoTouchedAProblem);
  row('Total problem attempts logged', r.engagement.totalProblemAttempts);
  row('Median problems / active user', r.engagement.medianProblemsPerActiveUser ?? 'n/a');
  row('0 problems answered', r.engagement.users_with_0_problems);
  row('  1-24 problems', r.engagement.users_1_to_24);
  row('  25-99 problems', r.engagement.users_25_to_99);
  row('  100-299 problems', r.engagement.users_100_to_299);
  row('  300+ problems  <- QUALIFIED', r.engagement.users_300_plus);
  row('Current streak >=3 / >=7', `${r.engagement.usersWithStreakGte3} / ${r.engagement.usersWithStreakGte7}`);

  L('\nEXAM DATES ON FILE  (the demand calendar)');
  row('Users with a date', r.examDates.usersWithDate);
  row('Date already in the past', r.examDates.alreadyPast);
  Object.entries(r.examDates.byMonth).forEach(([k, v]) => row(`    ${k}`, v));

  L('\nACQUISITION ATTRIBUTION');
  row('Attributable by ANY signal', `${r.acquisition.attributedAny} (${r.acquisition.pctAttributedAny}%)`);
  row('  via captured referrer', r.acquisition.withReferrer);
  row('  via UTM tag', r.acquisition.withUtm);
  row('  via survey answer', `${r.acquisition.surveyAnswered} (${r.acquisition.pctSurveyAnswered}%)`);
  row('UNATTRIBUTED', r.acquisition.unattributed);
  L('  Best-available channel per user:');
  Object.entries(r.acquisition.byChannel).forEach(([k, v]) => row(`    ${k}`, v));
  L('  Raw referrer hosts:');
  Object.entries(r.acquisition.referrerHosts).forEach(([k, v]) => row(`    ${k}`, v));
  L('  Landing page on first touch:');
  Object.entries(r.acquisition.landingPaths).forEach(([k, v]) => row(`    ${k}`, v));
  L('');
}

main().catch((err) => {
  console.error('\nBaseline report failed:', err.message);
  if (/auth|Authentication/i.test(err.message)) {
    console.error('-> Credentials rejected. Check DB_USERNAME / DB_PASSWORD.');
  }
  if (/ENOTFOUND|timed out|ServerSelection/i.test(err.message)) {
    console.error('-> Cannot reach the cluster. Check your IP is on the Atlas allowlist.');
  }
  process.exit(1);
});
