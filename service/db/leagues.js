const { leagueGroupsCollection, leagueStandingCollection, userCollection, userStatsCollection } = require('./connection');

// Weekly leagues (ADR 0037). Two collections:
//   leagueGroups    one per group per week: { weekId, tier, groupNo, members
//                   (emails, in the order they joined), createdAt, closedAt,
//                   results }
//   leagueStanding  one per student: { email, tier, hidden, weekId, groupId,
//                   placingWeek, history: [{ weekId, tier, place, size, xp,
//                   moved, newTier }], lastResult }
// The tier lives only here. The re-derive never writes it, so rebuilding an
// account from its log can never undo a week's result.

const isDuplicate = (e) => e && e.code === 11000;

async function getLeagueStanding(email) {
  return leagueStandingCollection.findOne({ email });
}

async function getLeagueStandings(emails) {
  return leagueStandingCollection.find({ email: { $in: emails } }).toArray();
}

/**
 * Claims this week's placement for a student, once. Returns their standing
 * (created in the starting tier if they have none), or null when the week is
 * already claimed, by this call's twin running at the same moment or earlier.
 */
async function claimLeaguePlacement(email, weekId, startingTier) {
  try {
    return await leagueStandingCollection.findOneAndUpdate(
      { email, placingWeek: { $ne: weekId } },
      {
        $set: { placingWeek: weekId },
        $setOnInsert: { email, tier: startingTier, hidden: false, history: [], createdAt: new Date() },
      },
      { upsert: true, returnDocument: 'after' },
    );
  } catch (e) {
    if (isDuplicate(e)) return null; // the standing exists and this week is claimed
    throw e;
  }
}

/** Gives a claim back, so a placement that failed is tried again next time. */
async function releaseLeaguePlacement(email, weekId) {
  await leagueStandingCollection.updateOne({ email, placingWeek: weekId }, { $unset: { placingWeek: '' } });
}

/**
 * Adds a student to the newest group of their tier this week that still has
 * room, opening the next group when every one is full. Safe when two
 * placements run at once: the room check and the add are one update, and two
 * students opening the same new group collide on the unique index and retry.
 */
async function addToLeagueGroup(email, weekId, tier, groupSize) {
  for (let attempt = 0; attempt < 6; attempt++) {
    const joined = await leagueGroupsCollection.findOneAndUpdate(
      { weekId, tier, closedAt: null, members: { $ne: email }, [`members.${groupSize - 1}`]: { $exists: false } },
      { $push: { members: email } },
      { sort: { groupNo: -1 }, returnDocument: 'after' },
    );
    if (joined) return joined;
    const already = await leagueGroupsCollection.findOne({ weekId, members: email });
    if (already) return already;
    const last = await leagueGroupsCollection.findOne({ weekId, tier }, { sort: { groupNo: -1 }, projection: { groupNo: 1 } });
    const group = { weekId, tier, groupNo: (last?.groupNo || 0) + 1, members: [email], createdAt: new Date(), closedAt: null };
    try {
      const r = await leagueGroupsCollection.insertOne(group);
      return { ...group, _id: r.insertedId };
    } catch (e) {
      if (!isDuplicate(e)) throw e; // someone opened that group first; join it next pass
    }
  }
  throw new Error(`could not place ${email} in ${weekId}/${tier}`);
}

async function setLeagueGroupForStanding(email, weekId, groupId) {
  await leagueStandingCollection.updateOne({ email }, { $set: { weekId, groupId } });
}

async function getLeagueGroup(groupId) {
  return groupId ? leagueGroupsCollection.findOne({ _id: groupId }) : null;
}

/** Groups from weeks before this one that are not closed yet. */
async function listOpenLeagueGroupsBefore(weekId) {
  return leagueGroupsCollection.find({ weekId: { $lt: weekId }, closedAt: null }).sort({ weekId: 1, tier: 1, groupNo: 1 }).toArray();
}

/** Names and this week's XP for a group's members. */
async function getLeagueMemberInfo(emails, weekId) {
  const [users, stats] = await Promise.all([
    userCollection.find({ email: { $in: emails } }, { projection: { _id: 0, email: 1, firstName: 1, lastName: 1 } }).toArray(),
    userStatsCollection.find({ email: { $in: emails } }, { projection: { _id: 0, email: 1, weekId: 1, weeklyXp: 1 } }).toArray(),
  ]);
  const byEmail = new Map(users.map((u) => [u.email, u]));
  const xp = new Map(stats.map((s) => [s.email, s.weekId === weekId ? (s.weeklyXp || 0) : 0]));
  return emails.map((email) => ({ ...(byEmail.get(email) || { email }), weeklyXp: xp.get(email) || 0 }));
}

/**
 * Writes one student's result for a week, once. The history guard makes a
 * second run of the week close (after a crash halfway) a no-op for anyone it
 * already moved.
 */
async function applyLeagueResult(email, entry) {
  const r = await leagueStandingCollection.updateOne(
    { email, 'history.weekId': { $ne: entry.weekId } },
    { $set: { tier: entry.newTier, lastResult: { ...entry, seen: false } }, $push: { history: entry } },
  );
  return r.modifiedCount > 0;
}

async function closeLeagueGroup(groupId, results) {
  const r = await leagueGroupsCollection.updateOne({ _id: groupId, closedAt: null }, { $set: { closedAt: new Date(), results } });
  return r.modifiedCount > 0;
}

async function markLeagueResultSeen(email) {
  await leagueStandingCollection.updateOne({ email, 'lastResult.seen': false }, { $set: { 'lastResult.seen': true } });
}

async function setLeagueHidden(email, hidden, startingTier) {
  await leagueStandingCollection.updateOne(
    { email },
    { $set: { hidden: !!hidden }, $setOnInsert: { email, tier: startingTier, history: [], createdAt: new Date() } },
    { upsert: true },
  );
}

/**
 * Sets a starting tier before a student has any league history. Never
 * touches someone who has already finished a league week.
 */
async function seedLeagueTier(email, tier) {
  try {
    const r = await leagueStandingCollection.updateOne(
      { email, 'history.0': { $exists: false } },
      { $set: { tier, seededAt: new Date() }, $setOnInsert: { email, hidden: false, history: [], createdAt: new Date() } },
      { upsert: true },
    );
    return r.modifiedCount + r.upsertedCount > 0;
  } catch (e) {
    if (isDuplicate(e)) return false; // has history already
    throw e;
  }
}

/** Every group of one week, for the admin line. */
async function listLeagueGroupsForWeek(weekId) {
  return leagueGroupsCollection.find({ weekId }, { projection: { _id: 0, tier: 1, groupNo: 1, members: 1, closedAt: 1, results: 1 } }).toArray();
}

module.exports = {
  getLeagueStanding,
  getLeagueStandings,
  claimLeaguePlacement,
  releaseLeaguePlacement,
  addToLeagueGroup,
  setLeagueGroupForStanding,
  getLeagueGroup,
  listOpenLeagueGroupsBefore,
  getLeagueMemberInfo,
  applyLeagueResult,
  closeLeagueGroup,
  markLeagueResultSeen,
  setLeagueHidden,
  seedLeagueTier,
  listLeagueGroupsForWeek,
};
