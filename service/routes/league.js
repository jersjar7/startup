const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const { leaderName } = require('./leaderboard.js');
const { rankGroup } = require('../leagues/league.js');
const { LEAGUE, STARTING_TIER, TIER_IDS, tierName } = require('../leagues/config.js');
const { currentWeekId, weekEndsAt } = require('../leagues/week.js');

// The student's weekly league (ADR 0037): their tier, their group this week,
// and last week's result until they have seen it. The website and the phone
// app both read this.

const router = express.Router();

const HIDDEN_NAME = 'A student';

/** How many move up and down in a group of this size in this tier. */
function zonesFor(tier, size) {
  const top = tier === TIER_IDS[TIER_IDS.length - 1];
  const bottom = tier === TIER_IDS[0];
  return {
    promote: top ? 0 : Math.min(LEAGUE.promote, size),
    demote: bottom || size < LEAGUE.minGroupForDemotion ? 0 : LEAGUE.demote,
  };
}

function resultView(r) {
  if (!r || r.seen !== false) return null;
  return {
    weekId: r.weekId,
    tier: r.tier,
    tierName: tierName(r.tier),
    place: r.place,
    size: r.size,
    moved: r.moved,
    newTier: r.newTier,
    newTierName: tierName(r.newTier),
  };
}

router.get('/', verifyAuth, async (req, res) => {
  try {
    const email = req.user.email;
    const now = new Date();
    const weekId = currentWeekId(now);
    const standing = await DB.getLeagueStanding(email);
    const tier = standing?.tier || STARTING_TIER;
    const joined = !!(standing && standing.weekId === weekId && standing.groupId);

    let rows = [];
    let size = 0;
    if (joined) {
      const group = await DB.getLeagueGroup(standing.groupId);
      const members = group?.members || [];
      size = members.length;
      const [info, standings] = await Promise.all([
        DB.getLeagueMemberInfo(members, weekId),
        DB.getLeagueStandings(members),
      ]);
      const hidden = new Set(standings.filter((s) => s.hidden).map((s) => s.email));
      const ranked = rankGroup(info.map((m, i) => ({ ...m, xp: m.weeklyXp || 0, joinIndex: i })));
      rows = ranked.map((m) => {
        const isMe = m.email === email;
        return {
          place: m.place,
          name: hidden.has(m.email) && !isMe ? HIDDEN_NAME : leaderName(m),
          xp: m.xp,
          isMe,
        };
      });
    }

    res.send({
      tier,
      tierName: tierName(tier),
      weekId,
      weekEndsAt: weekEndsAt(now).toISOString(),
      joined,
      hidden: !!standing?.hidden,
      rows,
      zones: zonesFor(tier, size),
      lastResult: resultView(standing?.lastResult),
    });
  } catch (e) {
    console.error('[league] failed:', e.message);
    res.status(500).send({ msg: 'Could not load your league' });
  }
});

// The first visit after a week closes shows the result once.
router.post('/seen', verifyAuth, async (req, res) => {
  try {
    await DB.markLeagueResultSeen(req.user.email);
    res.send({ ok: true });
  } catch (e) {
    console.error('[league] seen failed:', e.message);
    res.status(500).send({ msg: 'Could not save that' });
  }
});

// "Hide me from leagues": still competes, shown to others as "A student".
router.post('/hidden', verifyAuth, async (req, res) => {
  if (typeof req.body?.hidden !== 'boolean') return res.status(400).send({ msg: 'hidden must be true or false' });
  try {
    await DB.setLeagueHidden(req.user.email, req.body.hidden, STARTING_TIER);
    res.send({ ok: true, hidden: req.body.hidden });
  } catch (e) {
    console.error('[league] hidden failed:', e.message);
    res.status(500).send({ msg: 'Could not save that' });
  }
});

module.exports = router;
module.exports.zonesFor = zonesFor;
