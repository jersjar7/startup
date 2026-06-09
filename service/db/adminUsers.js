// Owner-only user visibility for the admin page. Lists are returned with
// MASKED emails (need-to-know): the recent feed never exposes full addresses,
// and a single-email lookup returns one full record the admin already typed.
const { userCollection, userStatsCollection, purchasesCollection, funnelEventsCollection } = require('./connection');
const { ObjectId } = require('mongodb');
const { EXCLUDED_EMAILS } = require('../internalAccounts');

const NOT_EXCLUDED = { $nin: EXCLUDED_EMAILS };

// jerson01@byu.edu -> j•••@byu.edu  (first char + domain). Fixed-length mask:
// uniform column widths in the table, and it doesn't leak the local-part length.
function maskEmail(e) {
  const s = String(e || '');
  const at = s.indexOf('@');
  if (at < 1) return s ? '•••' : '—';
  const local = s.slice(0, at);
  const domain = s.slice(at + 1);
  return `${local[0]}•••@${domain}`;
}

// Most recent signups (real users only), with engagement flags. No full emails.
async function getRecentUsers(limit = 25) {
  const users = await userCollection
    .find({ email: NOT_EXCLUDED }, { projection: { email: 1, createdAt: 1, emailVerified: 1 } })
    .sort({ createdAt: -1 })
    .limit(limit)
    .toArray();
  if (users.length === 0) return [];

  const emails = users.map((u) => u.email);
  const ids = users.map((u) => u._id.toString());
  const [activated, statsRows, paidIds] = await Promise.all([
    funnelEventsCollection.distinct('email', { type: 'quickstart_activated' }),
    userStatsCollection.find({ email: { $in: emails } }, { projection: { email: 1, totalXp: 1, quickstartSampled: 1 } }).toArray(),
    purchasesCollection.distinct('userId', { status: 'completed', userId: { $in: ids } }),
  ]);
  const actSet = new Set(activated);
  const paidSet = new Set(paidIds);
  const statsByEmail = Object.fromEntries(statsRows.map((s) => [s.email, s]));

  return users.map((u) => {
    const st = statsByEmail[u.email] || {};
    return {
      emailMasked: maskEmail(u.email),
      createdAt: u.createdAt || null,
      emailVerified: u.emailVerified === true,
      activated: actSet.has(u.email),
      chaptersMapped: (st.quickstartSampled || []).length,
      totalXp: st.totalXp || 0,
      purchased: paidSet.has(u._id.toString()),
    };
  });
}

// Most recent completed purchases, emails masked.
async function getRecentPurchases(limit = 10) {
  const rows = await purchasesCollection
    .find({ status: 'completed' })
    .sort({ createdAt: -1 })
    .limit(limit)
    .toArray();
  if (rows.length === 0) return [];

  const objIds = rows
    .map((r) => { try { return new ObjectId(r.userId); } catch { return null; } })
    .filter(Boolean);
  const users = await userCollection.find({ _id: { $in: objIds } }, { projection: { email: 1 } }).toArray();
  const emailById = Object.fromEntries(users.map((u) => [u._id.toString(), u.email]));

  return rows.map((r) => ({
    emailMasked: maskEmail(emailById[r.userId] || ''),
    amount: r.amount || 0,
    tier: r.tier || null,
    createdAt: r.createdAt || null,
  }));
}

// Full record for ONE user the admin looked up by exact email (support tool).
async function lookupUser(rawEmail) {
  const email = String(rawEmail || '').trim().toLowerCase();
  if (!email) return null;
  const user = await userCollection.findOne({ email });
  if (!user) return null;

  const id = user._id.toString();
  const [stats, purchases, firstActivation] = await Promise.all([
    userStatsCollection.findOne({ email }),
    purchasesCollection.find({ userId: id }).sort({ createdAt: -1 }).toArray(),
    funnelEventsCollection.findOne({ email, type: 'quickstart_activated' }, { sort: { createdAt: 1 } }),
  ]);
  const st = stats || {};

  return {
    email: user.email, // full — the admin already knows it (need-to-know)
    firstName: user.firstName || null,
    lastName: user.lastName || null,
    examDate: user.examDate || null,
    emailVerified: user.emailVerified === true,
    createdAt: user.createdAt || null,
    examSimAccess: user.examSimAccess === true,
    totalXp: st.totalXp || 0,
    currentStreak: st.currentStreak || 0,
    chaptersMapped: (st.quickstartSampled || []).length,
    activatedAt: firstActivation ? firstActivation.createdAt : null,
    diagnosticCompleted: st.diagnosticCompleted === true,
    purchases: purchases.map((p) => ({
      amount: p.amount || 0, tier: p.tier || null, status: p.status, createdAt: p.createdAt || null,
    })),
  };
}

function refHost(url) {
  try { return new URL(url).hostname.replace(/^www\./, ''); }
  catch { return null; }
}

// How users found us: self-reported source counts + passive referrer-host
// counts. Real users only.
async function getAcquisitionBreakdown() {
  const [selfRaw, refRows, total] = await Promise.all([
    userCollection.aggregate([
      { $match: { 'acquisition.source': { $type: 'string' }, email: NOT_EXCLUDED } },
      { $group: { _id: '$acquisition.source', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
    ]).toArray(),
    userCollection.find(
      { 'acquisition.referrer': { $type: 'string' }, email: NOT_EXCLUDED },
      { projection: { 'acquisition.referrer': 1 } },
    ).toArray(),
    userCollection.countDocuments({ email: NOT_EXCLUDED }),
  ]);

  const selfReported = selfRaw.map((r) => ({ source: r._id, count: r.count }));
  const answered = selfReported.reduce((a, b) => a + b.count, 0);

  const hostCounts = {};
  for (const u of refRows) {
    const host = refHost(u.acquisition.referrer);
    if (host) hostCounts[host] = (hostCounts[host] || 0) + 1;
  }
  const referrers = Object.entries(hostCounts)
    .map(([host, count]) => ({ host, count }))
    .sort((a, b) => b.count - a.count)
    .slice(0, 10);

  return { selfReported, referrers, answered, totalUsers: total };
}

module.exports = { getRecentUsers, getRecentPurchases, lookupUser, maskEmail, getAcquisitionBreakdown };
