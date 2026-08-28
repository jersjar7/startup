// What counts as a SALE and as INCOME.
//
// A purchase document with `status: 'completed'` means "we granted the product."
// It does NOT mean "we were paid." Those two came apart once already: while
// production was accidentally running on a Stripe TEST key (2026-07-18 to
// 2026-07-30), a real student checked out, Stripe reported the session as paid,
// and the app recorded a completed $29 purchase. No money ever moved. She keeps
// the product, and that is deliberate — the mistake was ours. But counting her
// $29 as revenue overstated income, sales, and average revenue per paying user
// on the admin dashboard for months.
//
// So `uncollected: true` on a purchase means: real grant, real customer, no
// money collected. Such rows are excluded from every revenue, sales-count and
// ARPPU surface, and are still kept in the collection because they are a true
// record of who has access and why.
//
// ENTITLEMENT MUST NOT USE THIS FILTER. `hasPurchased()` in db/purchases.js
// deliberately matches on status alone, so flagging a purchase as uncollected
// never takes the product away from someone who has it.
const COLLECTED_SALE = { status: 'completed', uncollected: { $ne: true } };

// Same predicate for rows already in hand (no round trip to Mongo).
function isCollectedSale(purchase) {
  return !!purchase && purchase.status === 'completed' && purchase.uncollected !== true;
}

module.exports = { COLLECTED_SALE, isCollectedSale };
