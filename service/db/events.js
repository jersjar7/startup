const {
  funnelEventsCollection,
  userCollection,
  diagnosticResultsCollection,
  purchasesCollection,
} = require('./connection');
const { NOT_EXCLUDED, EXCLUDED_PATTERN } = require('../internalAccounts');
const { COLLECTED_SALE } = require('../collectedSales');

// Record a funnel event. Analytics must never break a user flow, so failures
// are swallowed (logged, not thrown).
async function logEvent(type, email = null, meta = {}) {
  try {
    await funnelEventsCollection.insertOne({ type, email, meta, createdAt: new Date() });
  } catch (e) {
    console.error('[events] logEvent failed:', e.message);
  }
}

// Distinct users who triggered an event type (optionally since a date).
async function countDistinctEventUsers(type, since) {
  const match = { type, email: { $ne: null, $not: EXCLUDED_PATTERN } };
  if (since) match.createdAt = { $gte: since };
  const emails = await funnelEventsCollection.distinct('email', match);
  return emails.length;
}

// Aggregate the conversion funnel from existing collections + funnel events.
// signups, diagnostic completions, and purchases are derived from their own
// collections; checkout starts come from funnel events.
async function getFunnelCounts() {
  const [signups, diagEmails, purchaseAgg, checkoutStarts, quickstartActivated, quickstartCompleted] = await Promise.all([
    userCollection.countDocuments({ email: NOT_EXCLUDED }),
    diagnosticResultsCollection.distinct('email', { email: NOT_EXCLUDED }),
    purchasesCollection
      .aggregate([
        { $match: COLLECTED_SALE },
        { $group: { _id: null, count: { $sum: 1 }, revenue: { $sum: '$amount' } } },
      ])
      .toArray(),
    countDistinctEventUsers('checkout_started'),
    countDistinctEventUsers('quickstart_activated'),
    countDistinctEventUsers('quickstart_completed'),
  ]);
  const p = purchaseAgg[0] || { count: 0, revenue: 0 };
  return {
    signups,
    diagnosticUsers: diagEmails.length,
    quickstartActivated,
    quickstartCompleted,
    checkoutStarts,
    purchases: p.count,
    revenueCents: p.revenue || 0,
  };
}

// Running totals of completed purchases (for the owner sale-alert email).
async function getSalesSummary() {
  const agg = await purchasesCollection.aggregate([
    { $match: COLLECTED_SALE },
    { $group: { _id: null, count: { $sum: 1 }, revenue: { $sum: '$amount' } } },
  ]).toArray();
  const r = agg[0] || { count: 0, revenue: 0 };
  return { count: r.count, revenueCents: r.revenue || 0 };
}

module.exports = { logEvent, countDistinctEventUsers, getFunnelCounts, getSalesSummary };
