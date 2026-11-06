const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const { computeFunnelMetrics } = require('../metrics.js');
const { sendTestEmail, getEmailConfig } = require('../email.js');
const budget = require('../sendBudget.js');

const router = express.Router();

// Owner-only. Set ADMIN_EMAIL in service/.env to override; falls back to the
// admin account email.
const ADMIN_EMAIL = (process.env.ADMIN_EMAIL || 'admin@oqupa.com').toLowerCase();

function requireAdmin(req, res, next) {
  if ((req.user.email || '').toLowerCase() !== ADMIN_EMAIL) {
    return res.status(403).send({ msg: 'Forbidden' });
  }
  next();
}

// GET /api/admin/metrics — conversion funnel + revenue.
router.get('/metrics', verifyAuth, requireAdmin, async (req, res) => {
  const counts = await DB.getFunnelCounts();
  res.send(computeFunnelMetrics(counts));
});

// GET /api/admin/waitlist: PE waitlist totals by source and exam timing.
// Counts only, never addresses.
router.get('/waitlist', verifyAuth, requireAdmin, async (req, res) => {
  try {
    const { summarize } = require('../waitlist.js');
    res.send(summarize(await DB.listWaitlistForSummary()));
  } catch (e) {
    console.error('[admin] waitlist failed:', e.message);
    res.status(500).send({ msg: 'Failed to load the waitlist' });
  }
});

// GET /api/admin/leagues: this week's groups per tier and last week's moves
// (ADR 0037). Counts only, never addresses.
router.get('/leagues', verifyAuth, requireAdmin, async (req, res) => {
  try {
    const { summarizeWeeks } = require('../leagues/league.js');
    const { currentWeekId, previousWeekId } = require('../leagues/week.js');
    const now = new Date();
    const [thisWeek, lastWeek] = await Promise.all([
      DB.listLeagueGroupsForWeek(currentWeekId(now)),
      DB.listLeagueGroupsForWeek(previousWeekId(now)),
    ]);
    res.send({ weekId: currentWeekId(now), ...summarizeWeeks(thisWeek, lastWeek) });
  } catch (e) {
    console.error('[admin] leagues failed:', e.message);
    res.status(500).send({ msg: 'Failed to load leagues' });
  }
});

// GET /api/admin/timeseries?days=30 — daily time-series + KPI snapshot.
router.get('/timeseries', verifyAuth, requireAdmin, async (req, res) => {
  try {
    const data = await DB.getDailyAnalytics(req.query.days);
    res.send(data);
  } catch (e) {
    console.error('[admin] timeseries failed:', e.message);
    res.status(500).send({ msg: 'Failed to load analytics' });
  }
});

// GET /api/admin/recent — recent signups + purchases with MASKED emails.
router.get('/recent', verifyAuth, requireAdmin, async (req, res) => {
  try {
    const [users, purchases, total] = await Promise.all([DB.getRecentUsers(25), DB.getRecentPurchases(10), DB.countRealUsers()]);
    res.send({ users, purchases, total });
  } catch (e) {
    console.error('[admin] recent failed:', e.message);
    res.status(500).send({ msg: 'Failed to load recent users' });
  }
});

// GET /api/admin/acquisition — how users found us (self-reported + referrers).
router.get('/acquisition', verifyAuth, requireAdmin, async (req, res) => {
  try {
    res.send(await DB.getAcquisitionBreakdown());
  } catch (e) {
    console.error('[admin] acquisition failed:', e.message);
    res.status(500).send({ msg: 'Failed to load acquisition' });
  }
});

// GET /api/admin/user-lookup?email= — full record for ONE user (support).
router.get('/user-lookup', verifyAuth, requireAdmin, async (req, res) => {
  try {
    const user = await DB.lookupUser(req.query.email);
    if (!user) return res.status(404).send({ msg: 'No user with that email' });
    res.send(user);
  } catch (e) {
    console.error('[admin] user-lookup failed:', e.message);
    res.status(500).send({ msg: 'Lookup failed' });
  }
});

// GET /api/admin/email-status — sender config + today's/month's send counts vs
// the Resend free-plan caps (so the owner can watch the budget).
router.get('/email-status', verifyAuth, requireAdmin, async (req, res) => {
  const c = await budget.counts();
  res.send({
    ...getEmailConfig(),
    budget: {
      day: c.day,
      month: c.month,
      dailyCap: budget.DAILY_CAP,
      monthlyCap: budget.MONTHLY_CAP,
      dailyLifecycleMax: budget.DAILY_LIFECYCLE_MAX,
      monthlySoft: budget.MONTHLY_SOFT,
    },
  });
});

// GET /api/admin/exam-dates — how many users are testing on each date (from the
// exam date they set in their profile), for the upcoming-exams calendar.
// The latest reports from the flag on a game round, newest first.
router.get('/feedback', verifyAuth, requireAdmin, async (req, res) => {
  const limit = Math.min(500, Math.max(1, parseInt(req.query.limit, 10) || 100));
  res.send({ reports: await DB.listGameFeedback(limit) });
});

router.get('/exam-dates', verifyAuth, requireAdmin, async (req, res) => {
  try {
    res.send(await DB.getExamDateDistribution());
  } catch (e) {
    console.error('[admin] exam-dates failed:', e.message);
    res.status(500).send({ msg: 'Failed to load exam dates' });
  }
});

// GET /api/admin/pitch-stats — exam-sim pitch funnel (pitched → clicked → bought)
// so the owner can watch the countdown-email sim pitch working.
router.get('/pitch-stats', verifyAuth, requireAdmin, async (req, res) => {
  try {
    res.send(await DB.getSimPitchStats());
  } catch (e) {
    console.error('[admin] pitch-stats failed:', e.message);
    res.status(500).send({ msg: 'Failed to load pitch stats' });
  }
});

// POST /api/admin/email-test { to } — send a test email, report the raw result.
// Lets the owner confirm delivery from the running app after verifying a domain.
router.post('/email-test', verifyAuth, requireAdmin, async (req, res) => {
  const to = String(req.body?.to || req.user.email).trim();
  const result = await sendTestEmail(to);
  res.send({ to, ...getEmailConfig(), ...result });
});

// ── School site licences (ADR 0040) ────────────────────────────────────────
// A college pays yearly; its verified students get the Exam Simulation.
const { parseLicenseInput, adminLicense } = require('../schoolAccess.js');

// GET /api/admin/school-licenses — every licence with its seats.
router.get('/school-licenses', verifyAuth, requireAdmin, async (req, res) => {
  const now = new Date();
  res.send({ licenses: (await DB.listSchoolLicenses()).map((l) => adminLicense(l, now)) });
});

// POST /api/admin/school-licenses — create one.
router.post('/school-licenses', verifyAuth, requireAdmin, async (req, res) => {
  const { fields, error } = parseLicenseInput(req.body);
  if (error) return res.status(400).send({ msg: error });
  const created = await DB.createSchoolLicense(fields);
  console.log(`[admin] school licence created: ${fields.schoolName} (${fields.domains.join(', ')}), ${fields.seatCap} seats`);
  res.status(201).send(adminLicense(created));
});

// PATCH /api/admin/school-licenses/:id — edit any field. Seats already
// claimed stay claimed when the cap goes down (ADR 0040).
router.patch('/school-licenses/:id', verifyAuth, requireAdmin, async (req, res) => {
  const existing = await DB.getSchoolLicense(req.params.id);
  if (!existing) return res.status(404).send({ msg: 'No such licence' });
  const { fields, error } = parseLicenseInput(req.body, { partial: true, existing });
  if (error) return res.status(400).send({ msg: error });
  const updated = await DB.updateSchoolLicense(req.params.id, fields);
  res.send(adminLicense(updated || { ...existing, ...fields }));
});

// POST /api/admin/school-licenses/:id/end — end it now. Kept, not deleted, so
// the record of what a school bought survives. A student mid-exam still
// finishes (routes/exam.js).
router.post('/school-licenses/:id/end', verifyAuth, requireAdmin, async (req, res) => {
  const existing = await DB.getSchoolLicense(req.params.id);
  if (!existing) return res.status(404).send({ msg: 'No such licence' });
  if (existing.endedAt) return res.send(adminLicense(existing));
  const updated = await DB.updateSchoolLicense(req.params.id, { endedAt: new Date() });
  console.log(`[admin] school licence ended: ${existing.schoolName}`);
  res.send(adminLicense(updated || { ...existing, endedAt: new Date() }));
});

// POST /api/admin/school-licenses/:id/reopen — undo an early end.
router.post('/school-licenses/:id/reopen', verifyAuth, requireAdmin, async (req, res) => {
  const existing = await DB.getSchoolLicense(req.params.id);
  if (!existing) return res.status(404).send({ msg: 'No such licence' });
  const updated = await DB.updateSchoolLicense(req.params.id, { endedAt: null });
  res.send(adminLicense(updated || { ...existing, endedAt: null }));
});

module.exports = router;
