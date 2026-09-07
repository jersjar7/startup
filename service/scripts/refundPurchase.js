// Record a REFUND against a purchase: revoke the product and stop counting the
// money as income. See ../collectedSales.js for what counts as a sale and
// docs/adr/0011-a-refund-revokes-the-product.md for the why.
//
// This is the opposite case to markUncollectedPurchase.js. There, money never
// arrived and the customer KEEPS the product. Here, money arrived and was given
// back, so the customer must LOSE the product. That is why this script is the
// one place allowed to move `status` off 'completed'.
//
// Refund the card in Stripe FIRST. This script only records what Stripe already
// did; it never talks to Stripe and cannot move money.
//
// Usage (from service/):
//   node --env-file=.env scripts/refundPurchase.js --session=cs_live_...
//   node --env-file=.env scripts/refundPurchase.js --session=cs_live_... --reason="..." --apply
//   node --env-file=.env scripts/refundPurchase.js --session=cs_live_... --undo --apply
//
// Without --apply it prints what it would do and changes nothing.

const { MongoClient, ObjectId } = require('mongodb');

const args = Object.fromEntries(
  process.argv.slice(2).map((a) => {
    const [k, ...rest] = a.replace(/^--/, '').split('=');
    return [k, rest.length ? rest.join('=') : true];
  }),
);

const sessionId = args.session;
const apply = args.apply === true;
const undo = args.undo === true;
const reason = typeof args.reason === 'string' ? args.reason : null;

if (!sessionId || typeof sessionId !== 'string') {
  console.error('Missing --session=<stripeSessionId>. Nothing done.');
  process.exit(1);
}
if (!undo && !reason) {
  console.error('Missing --reason="...". A refund without a recorded reason is not auditable. Nothing done.');
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

    let owner = null;
    try {
      owner = await users.findOne({ _id: new ObjectId(row.userId) }, { projection: { email: 1, examSimAccess: 1 } });
    } catch { /* orphan row */ }

    // A refund only makes sense against a purchase that still stands, and an
    // undo only against one already refunded. Guarding both directions keeps a
    // double-run from inventing a state that never happened.
    if (!undo && row.status !== 'completed') {
      console.error(`Purchase status is '${row.status}', not 'completed'. Nothing done.`);
      process.exitCode = 1;
      return;
    }
    if (undo && row.status !== 'refunded') {
      console.error(`Purchase status is '${row.status}', not 'refunded'. Nothing to undo.`);
      process.exitCode = 1;
      return;
    }

    console.log('Purchase found');
    console.log('  date      ', row.createdAt ? new Date(row.createdAt).toISOString().slice(0, 10) : '(none)');
    console.log('  amount    ', `$${((row.amount || 0) / 100).toFixed(2)} ${row.tier || ''}`.trim());
    console.log('  status    ', row.status);
    console.log('  customer  ', mask(owner && owner.email));
    console.log('  access now', owner && owner.examSimAccess === true ? 'granted' : 'not granted');

    const purchaseUpdate = undo
      ? { $set: { status: 'completed' }, $unset: { refundedAt: '', refundReason: '' } }
      : { $set: { status: 'refunded', refundedAt: new Date(), refundReason: reason } };

    // `examSimAccess` is display-only (the admin user lookup reads it), but it
    // must not contradict the purchase row, or support sees "granted" for
    // someone who was refunded.
    const userUpdate = undo
      ? { $set: { examSimAccess: true } }
      : { $set: { examSimAccess: false }, $unset: { examSimPurchaseDate: '' } };

    console.log('');
    if (undo) {
      console.log('Would RESTORE the purchase (access returns, row counts as revenue again).');
    } else {
      console.log('Would mark REFUNDED: access is revoked and the row stops counting as a sale and as income.');
      console.log('  reason:', reason);
    }

    if (!apply) {
      console.log('\nDry run. Re-run with --apply to write it.');
      return;
    }

    const res = await purchases.updateOne({ stripeSessionId: sessionId }, purchaseUpdate);
    let userRes = { matchedCount: 0, modifiedCount: 0 };
    if (row.userId) {
      try {
        userRes = await users.updateOne({ _id: new ObjectId(row.userId) }, userUpdate);
      } catch { /* orphan row */ }
    }
    console.log(`\nWrote purchase. matched=${res.matchedCount} modified=${res.modifiedCount}`);
    console.log(`Wrote user.    matched=${userRes.matchedCount} modified=${userRes.modifiedCount}`);

    const after = await purchases.aggregate([
      { $match: { status: 'completed', uncollected: { $ne: true }, comp: { $ne: true } } },
      { $group: { _id: null, count: { $sum: 1 }, cents: { $sum: '$amount' } } },
    ]).toArray();
    const t = after[0] || { count: 0, cents: 0 };
    console.log(`Reported sales now: ${t.count} purchases, $${(t.cents / 100).toFixed(2)} collected.`);
  } finally {
    await client.close();
  }
})();
