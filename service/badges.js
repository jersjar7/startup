// Achievement badge definitions and evaluation.
// Badges are checked after each session/review and awarded if earned.

const BADGES = [
  {
    id: 'first-session',
    name: 'First Steps',
    description: 'Complete your first study session',
    check: (stats) => getTotalSessions(stats) >= 1,
  },
  {
    id: 'five-sessions',
    name: 'Getting Serious',
    description: 'Complete 5 study sessions',
    check: (stats) => getTotalSessions(stats) >= 5,
  },
  {
    id: 'twenty-sessions',
    name: 'Dedicated Learner',
    description: 'Complete 20 study sessions',
    check: (stats) => getTotalSessions(stats) >= 20,
  },
  {
    id: 'streak-3',
    name: 'On a Roll',
    description: 'Reach a 3-day study streak',
    check: (stats) => (stats.longestStreak || 0) >= 3,
  },
  {
    id: 'streak-7',
    name: 'Week Warrior',
    description: 'Reach a 7-day study streak',
    check: (stats) => (stats.longestStreak || 0) >= 7,
  },
  {
    id: 'streak-30',
    name: 'Monthly Master',
    description: 'Reach a 30-day study streak',
    check: (stats) => (stats.longestStreak || 0) >= 30,
  },
  {
    id: 'xp-100',
    name: 'Century Club',
    description: 'Earn 100 total XP',
    check: (stats) => (stats.totalXp || 0) >= 100,
  },
  {
    id: 'xp-500',
    name: 'XP Hunter',
    description: 'Earn 500 total XP',
    check: (stats) => (stats.totalXp || 0) >= 500,
  },
  {
    id: 'xp-1000',
    name: 'Knowledge Machine',
    description: 'Earn 1000 total XP',
    check: (stats) => (stats.totalXp || 0) >= 1000,
  },
  {
    id: 'first-mastery',
    name: 'Getting the Hang of It',
    description: 'Reach mastery level 3 (Familiar) in any topic',
    check: (stats) => {
      const tp = stats.topicProgress || {};
      return Object.values(tp).some((p) => (p.masteryLevel || 0) >= 3);
    },
  },
  {
    id: 'multi-topic',
    name: 'Renaissance Engineer',
    description: 'Study at least 3 different topics',
    check: (stats) => {
      const tp = stats.topicProgress || {};
      return Object.values(tp).filter((p) => (p.sessionsCompleted || 0) >= 1).length >= 3;
    },
  },
  {
    id: 'perfect-session',
    name: 'Flawless',
    description: 'Get 100% on a session with 5+ problems',
    // This is checked at session time, not from stats alone
    check: () => false,
  },
];

function getTotalSessions(stats) {
  const tp = stats.topicProgress || {};
  return Object.values(tp).reduce((sum, p) => sum + (p.sessionsCompleted || 0), 0);
}

// Evaluate which badges the user has earned.
// Returns array of badge IDs to award.
function evaluateBadges(stats, sessionContext) {
  const existingBadges = new Set(stats.badges || []);
  const newBadges = [];

  for (const badge of BADGES) {
    if (existingBadges.has(badge.id)) continue;

    // Special case: perfect session checked from session context
    if (badge.id === 'perfect-session') {
      if (sessionContext && sessionContext.correct === sessionContext.total && sessionContext.total >= 5) {
        newBadges.push(badge.id);
      }
      continue;
    }

    if (badge.check(stats)) {
      newBadges.push(badge.id);
    }
  }

  return newBadges;
}

// Get badge details by IDs
function getBadgeDetails(badgeIds) {
  return BADGES.filter((b) => badgeIds.includes(b.id)).map((b) => ({
    id: b.id,
    name: b.name,
    description: b.description,
  }));
}

function getAllBadges() {
  return BADGES.map((b) => ({
    id: b.id,
    name: b.name,
    description: b.description,
  }));
}

module.exports = { evaluateBadges, getBadgeDetails, getAllBadges };
