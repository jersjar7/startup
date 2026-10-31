const { purchasesCollection, userCollection } = require('./connection');
const { ObjectId } = require('mongodb');

async function recordPurchase(userId, purchase) {
  await purchasesCollection.insertOne({
    userId,
    ...purchase,
    createdAt: new Date(),
  });

  // Grant exam simulation access on the user document
  await userCollection.updateOne(
    { _id: new ObjectId(userId) },
    { $set: { examSimAccess: true, examSimPurchaseDate: new Date() } }
  );
}

async function hasPurchased(userId) {
  const purchase = await purchasesCollection.findOne({
    userId,
    status: 'completed',
  });
  return !!purchase;
}

async function getPurchaseHistory(userId) {
  return purchasesCollection
    .find({ userId })
    .sort({ createdAt: -1 })
    .toArray();
}

async function getPurchaseBySessionId(stripeSessionId) {
  return purchasesCollection.findOne({ stripeSessionId });
}

// Apply a refund or dispute plan from stripeReversals.js. The purchase filter
// repeats the status the plan was made from, so two deliveries of the same
// event cannot both write.
async function applyPurchaseReversal(purchase, plan) {
  const res = await purchasesCollection.updateOne(
    { _id: purchase._id, status: purchase.status },
    plan.purchase,
  );
  if (res.modifiedCount === 1 && plan.user && purchase.userId) {
    try {
      await userCollection.updateOne({ _id: new ObjectId(purchase.userId) }, plan.user);
    } catch { /* orphan row: the purchase status alone decides access */ }
  }
  return res.modifiedCount === 1;
}

module.exports = {
  applyPurchaseReversal,
  recordPurchase,
  hasPurchased,
  getPurchaseHistory,
  getPurchaseBySessionId,
};
