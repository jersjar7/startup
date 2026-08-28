// Flag a purchase as granted-but-never-paid, so it stops counting as a sale or
// as income on the admin dashboard. See ../collectedSales.js for the rule and
// docs/adr/0010-uncollected-purchases-are-not-revenue.md for the why.
//
// The customer KEEPS the product. This script only touches reporting: it never
// changes `status` and never touches `examSimAccess` on the user document.
//
// Usage (from service/):
//   node --env-file=.env scripts/markUncollectedPurchase.js --session=cs_test_...
//   node --env-file=.env scripts/markUncollectedPurchase.js --session=cs_test_... --reason="..." --apply
//   node --env-file=.env scripts/markUncollectedPurchase.js --session=cs_test_... --undo --apply
//
// Without --apply it prints what it would do and changes nothing.

const { MongoClient } = require('mongodb');

const args = Object.fromEntries(
  process.argv.slice(2).map((a) => {
    const [k, ...rest] = a.replace(/^--/, '').split('=');
    return [k, rest.length ? rest.join('=') : true];
  }),
);

const sessionId = args.session;
const apply = args.apply === true;
const undo = args.undo === true;
const reason = typeof args.reason === 'string'
  ? args.reason
  : 'Stripe was on a TEST key in production (2026-07-18 to 2026-07-30). The session reported paid, access was granted, no money was ever collected.';

if (!sessionId || typeof sessionId !== 'string') {
  console.error('Missing --session=<stripeSessionId>. Nothing done.');
  process.exit(1);
}

function mask(email) {
  if (!email) return '(unknown)';
  return email.replace(/^(.).*?(.?)@/, (_, a, b) => `${a}***${b}@`);
}

(async () => {
  const url = `mongodb+srv://${process.env.DB_USERNAME}:${process.env.DB_PASSWORD}@${process.env.DB_HOSTNAME}`;
  const client = new MongoClient(url);
  await client.connect();
  const db = client.db('fe4raccoons');
  const purchases = db.collection('purchases');
  const users = db.collection('users');

  try {
    const row = await purchases.findOne({ stripeSessionId: sessionId });
    if (!row) {
      console.error(`No purchase found with stripeSessionId=${sessionId}. Nothing done.`);
      process.exitCode = 1;
      return;
    }

    const { ObjectId } = require('mongodb');
    let owner = null;
    try { owner = await users.findOne({ _id: new ObjectId(row.userId) }, { projection: { email: 1, examSimAccess: 1 } }); } catch { /* orphan row */ }

    console.log('Purchase found');
    console.log('  date       ', row.createdAt ? new Date(row.createdAt).toISOString().slice(0, 10) : '(none)');
    console.log('  amount     ', `$${((row.amount || 0) / 100).toFixed(2)} ${row.tier || ''}`.trim());
    console.log('  status     ', row.status);
    console.log('  customer   ', mask(owner && owner.email));
    console.log('  access now ', owner && owner.examSimAccess === true ? 'granted (unchanged by this script)' : 'not granted');
    console.log('  uncollected', row.uncollected === true ? 'true' : '(not set)');

    const update = undo
      ? { $unset: { uncollected: '', uncollectedReason: '', uncollectedAt: '' } }
      : { $set: { uncollected: true, uncollectedReason: reason, uncollectedAt: new Date() } };

    console.log('');
    console.log(undo ? 'Would CLEAR the uncollected flag (row counts as revenue again).'
                     : 'Would FLAG as uncollected (row stops counting as a sale and as income).');
    if (!undo) console.log('  reason:', reason);

    if (!apply) {
      console.log('\nDry run. Re-run with --apply to write it.');
      return;
    }

    const res = await purchases.updateOne({ stripeSessionId: sessionId }, update);
    console.log(`\nWrote. matched=${res.matchedCount} modified=${res.modifiedCount}`);

    const after = await purchases.aggregate([
      { $match: { status: 'completed', uncollected: { $ne: true } } },
      { $group: { _id: null, count: { $sum: 1 }, cents: { $sum: '$amount' } } },
    ]).toArray();
    const t = after[0] || { count: 0, cents: 0 };
    console.log(`Reported sales now: ${t.count} purchases, $${(t.cents / 100).toFixed(2)} collected.`);
  } finally {
    await client.close();
  }
})();
