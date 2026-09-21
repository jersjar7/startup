const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const { deriveAccount } = require('../derive.js');
const { allEvents, weekIdFor } = require('../rederive.js');
const { getBadgeDetails } = require('../badges.js');

const router = express.Router();

// The one read (ADR 0018, step 4): the account's state, derived from its
// log right now, the same for the website and the phone. Nothing here is
// read from a cache except what is not progress: badges earned, the phone's
// last sync, the profile.
router.get('/state', verifyAuth, async (req, res) => {
  const email = req.user.email;
  const [events, stats] = await Promise.all([allEvents(email), DB.getUserStats(email)]);
  const d = deriveAccount({ events });
  const today = typeof req.query.date === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(req.query.date)
    ? req.query.date : new Date().toISOString().slice(0, 10);
  const thisWeek = weekIdFor(today);
  let weeklyXp = 0;
  for (const [day, xp] of Object.entries(d.xpByDay)) if (weekIdFor(day) === thisWeek) weeklyXp += xp;
  const dueReviews = Object.values(d.history).filter((h) => h.reviewActive && h.nextReview && h.nextReview <= today).length;
  res.send({
    totalXp: d.totalXp,
    weeklyXp,
    daysStudied: d.daysStudied,
    studyDays: d.studyDays,
    lastSessionDate: d.lastSessionDate,
    examDate: req.user.examDate || null,
    badges: getBadgeDetails(stats?.badges || []),
    chapterMastery: d.chapterMastery,
    dueReviews,
    problemsAnswered: d.problemsAnswered,
    sessions: d.sessions,
    phone: {
      lastSync: stats && stats.lastSyncAt ? { at: stats.lastSyncAt, device: stats.lastSyncDevice || null, source: stats.lastSyncSource || null } : null,
      games: d.games,
    },
    derivedAt: Date.now(),
    events: events.length,
  });
});

module.exports = router;
