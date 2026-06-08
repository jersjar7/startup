const {
  userCollection,
  sessionLogCollection,
  diagnosticResultsCollection,
  examAttemptsCollection,
  purchasesCollection,
  funnelEventsCollection,
} = require('./connection');
const { dateAxis, seriesFor, cumulative } = require('../analytics');
const { EXCLUDED_EMAILS } = require('../internalAccounts');
const NOT_EXCLUDED = { $nin: EXCLUDED_EMAILS };

// Daily buckets are computed in the owner's local timezone so "today" lines up
// with their calendar day. Override with ANALYTICS_TZ if the owner relocates.
const TZ = process.env.ANALYTICS_TZ || 'America/Los_Angeles';

// Current date as YYYY-MM-DD in TZ (en-CA formats as ISO date).
function todayYmd() {
  return new Intl.DateTimeFormat('en-CA', {
    timeZone: TZ, year: 'numeric', month: '2-digit', day: '2-digit',
  }).format(new Date());
}

// $dateToString expression that buckets a date field by local day.
const dayOf = (field) => ({ $dateToString: { format: '%Y-%m-%d', date: field, timezone: TZ } });

// Signups per day from users.createdAt.
function signupsByDay(since) {
  return userCollection.aggregate([
    { $match: { createdAt: { $gte: since }, email: NOT_EXCLUDED } },
    { $group: { _id: dayOf('$createdAt'), count: { $sum: 1 } } },
    { $project: { _id: 0, day: '$_id', count: 1 } },
  ]).toArray();
}

// Active users, sessions, problems and correct answers per day from sessionLog.
function sessionsByDay(since) {
  return sessionLogCollection.aggregate([
    { $match: { completedAt: { $gte: since }, email: NOT_EXCLUDED } },
    { $group: {
      _id: { day: dayOf('$completedAt'), email: '$email' },
      sessions: { $sum: 1 },
      problems: { $sum: { $ifNull: ['$totalProblems', 0] } },
      correct: { $sum: { $ifNull: ['$correct', 0] } },
    } },
    { $group: {
      _id: '$_id.day',
      activeUsers: { $sum: 1 },
      sessions: { $sum: '$sessions' },
      problems: { $sum: '$problems' },
      correct: { $sum: '$correct' },
    } },
    { $project: { _id: 0, day: '$_id', activeUsers: 1, sessions: 1, problems: 1, correct: 1 } },
  ]).toArray();
}

// Diagnostic completions per day.
function diagnosticsByDay(since) {
  return diagnosticResultsCollection.aggregate([
    { $match: { completedAt: { $gte: since }, email: NOT_EXCLUDED } },
    { $group: { _id: dayOf('$completedAt'), count: { $sum: 1 } } },
    { $project: { _id: 0, day: '$_id', count: 1 } },
  ]).toArray();
}

// Completed exam simulations per day.
function examSimsByDay(since) {
  return examAttemptsCollection.aggregate([
    { $match: { status: 'completed', completedAt: { $gte: since } } },
    { $group: { _id: dayOf('$completedAt'), count: { $sum: 1 } } },
    { $project: { _id: 0, day: '$_id', count: 1 } },
  ]).toArray();
}

// Checkout starts per day from funnel events.
function checkoutStartsByDay(since) {
  return funnelEventsCollection.aggregate([
    { $match: { type: 'checkout_started', createdAt: { $gte: since }, email: NOT_EXCLUDED } },
    { $group: { _id: dayOf('$createdAt'), count: { $sum: 1 } } },
    { $project: { _id: 0, day: '$_id', count: 1 } },
  ]).toArray();
}

// Completed purchases per day with revenue (cents).
function purchasesByDay(since) {
  return purchasesCollection.aggregate([
    { $match: { status: 'completed', createdAt: { $gte: since } } },
    { $group: { _id: dayOf('$createdAt'), count: { $sum: 1 }, cents: { $sum: '$amount' } } },
    { $project: { _id: 0, day: '$_id', count: 1, cents: 1 } },
  ]).toArray();
}

// Distinct active users since a date (for the 7d / 30d KPI cards).
async function activeUsersSince(since) {
  const emails = await sessionLogCollection.distinct('email', { completedAt: { $gte: since }, email: NOT_EXCLUDED });
  return emails.filter(Boolean).length;
}

// Build the full daily time-series payload for the last `days` days, plus a
// snapshot of point-in-time KPIs. Everything is reconstructed from raw
// timestamped collections, so history is complete back to launch and each new
// event lands in its day's bucket automatically — no nightly job required.
async function getDailyAnalytics(days = 30) {
  const window = Math.min(Math.max(Number(days) || 30, 7), 365);
  const axis = dateAxis(todayYmd(), window);
  // Generous lower bound; zero-fill clips to the exact axis afterward.
  const since = new Date(Date.now() - (window + 2) * 86400000);
  const d7 = new Date(Date.now() - 7 * 86400000);
  const d30 = new Date(Date.now() - 30 * 86400000);

  const [
    signups, sessions, diagnostics, examSims, checkoutStarts, purchases,
    totalUsers, totalRevenueAgg, active7, active30,
  ] = await Promise.all([
    signupsByDay(since),
    sessionsByDay(since),
    diagnosticsByDay(since),
    examSimsByDay(since),
    checkoutStartsByDay(since),
    purchasesByDay(since),
    userCollection.countDocuments({ email: NOT_EXCLUDED }),
    purchasesCollection.aggregate([
      { $match: { status: 'completed' } },
      { $group: { _id: null, count: { $sum: 1 }, cents: { $sum: '$amount' } } },
    ]).toArray(),
    activeUsersSince(d7),
    activeUsersSince(d30),
  ]);

  const signupSeries = seriesFor(signups, axis, 'count');
  const purchaseCountSeries = seriesFor(purchases, axis, 'count');
  const revenueSeries = seriesFor(purchases, axis, 'cents').map((c) => Math.round(c) / 100);

  const totalRev = totalRevenueAgg[0] || { count: 0, cents: 0 };
  const windowSignups = signupSeries.reduce((a, b) => a + b, 0);
  const windowRevenue = revenueSeries.reduce((a, b) => a + b, 0);

  return {
    tz: TZ,
    days: window,
    axis,
    series: {
      signups: signupSeries,
      cumulativeUsers: cumulative(signupSeries, totalUsers - windowSignups),
      activeUsers: seriesFor(sessions, axis, 'activeUsers'),
      sessions: seriesFor(sessions, axis, 'sessions'),
      problems: seriesFor(sessions, axis, 'problems'),
      correct: seriesFor(sessions, axis, 'correct'),
      diagnostics: seriesFor(diagnostics, axis, 'count'),
      examSims: seriesFor(examSims, axis, 'count'),
      checkoutStarts: seriesFor(checkoutStarts, axis, 'count'),
      purchases: purchaseCountSeries,
      revenue: revenueSeries,
      cumulativeRevenue: cumulative(revenueSeries, (totalRev.cents / 100) - windowRevenue),
    },
    snapshot: {
      totalUsers,
      activeUsers7d: active7,
      activeUsers30d: active30,
      totalPurchases: totalRev.count,
      totalRevenue: Math.round(totalRev.cents) / 100,
      arppu: totalRev.count > 0 ? Math.round((totalRev.cents / totalRev.count)) / 100 : 0,
    },
  };
}

module.exports = { getDailyAnalytics };
