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

module.exports = {
  recordPurchase,
  hasPurchased,
  getPurchaseHistory,
  getPurchaseBySessionId,
};
