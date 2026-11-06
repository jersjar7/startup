// School site licences (ADR 0040): storage. The rule is schoolAccess.js and
// the entitlement check that joins the two is simAccess.js.
//
// schoolLicenses        one row per licence a college bought
// schoolLicenseClaims   one row per student holding a seat, unique per
//                       (licenseId, userId); the licence's seatsUsed counter is
//                       the number that is compared to the cap
const { ObjectId } = require('mongodb');
const { schoolLicensesCollection, schoolLicenseClaimsCollection } = require('./connection');

/// Licences that list any of these domains. All states; the rule filters.
async function findLicensesForDomains(domains) {
  const list = [...new Set((domains || []).filter(Boolean))];
  if (!list.length) return [];
  return schoolLicensesCollection.find({ domains: { $in: list } }).toArray();
}

async function getClaimsForUser(userId) {
  return schoolLicenseClaimsCollection.find({ userId: String(userId) }).toArray();
}

/// Take a seat on a licence for a student. Idempotent: a student who already
/// holds one gets true without a second seat being counted.
///
/// The claim row goes in first (its unique index stops a double claim), then
/// the counter goes up only while it is under the cap. If the cap was reached
/// in between, the claim row is taken back out and the answer is false.
async function claimSeat(license, userId, domain) {
  const licenseId = license._id;
  const uid = String(userId);
  try {
    await schoolLicenseClaimsCollection.insertOne({
      licenseId, userId: uid, domain, claimedAt: new Date(),
    });
  } catch (e) {
    if (e && e.code === 11000) return true; // already theirs
    throw e;
  }
  const res = await schoolLicensesCollection.updateOne(
    { _id: licenseId, $expr: { $lt: [{ $ifNull: ['$seatsUsed', 0] }, '$seatCap'] } },
    { $inc: { seatsUsed: 1 } },
  );
  if (res.modifiedCount === 1) return true;
  await schoolLicenseClaimsCollection.deleteOne({ licenseId, userId: uid });
  return false;
}

// ── Admin ──────────────────────────────────────────────────────────────────

async function listSchoolLicenses() {
  return schoolLicensesCollection.find({}).sort({ endsAt: -1, createdAt: -1 }).toArray();
}

async function getSchoolLicense(id) {
  try { return await schoolLicensesCollection.findOne({ _id: new ObjectId(String(id)) }); } catch { return null; }
}

async function createSchoolLicense(fields) {
  const doc = { ...fields, seatsUsed: 0, createdAt: new Date(), updatedAt: new Date() };
  const res = await schoolLicensesCollection.insertOne(doc);
  return { ...doc, _id: res.insertedId };
}

async function updateSchoolLicense(id, fields) {
  let _id;
  try { _id = new ObjectId(String(id)); } catch { return null; }
  const res = await schoolLicensesCollection.findOneAndUpdate(
    { _id },
    { $set: { ...fields, updatedAt: new Date() } },
    { returnDocument: 'after' },
  );
  return res && res.value !== undefined ? res.value : res;
}

/// Account deletion: the student's claim goes, the seat stays counted. The
/// school paid for that seat and a counter that went down would let the
/// licence quietly hand out more seats than it was sold.
async function releaseClaimsForDeletedUser(userId) {
  if (!userId) return 0;
  const res = await schoolLicenseClaimsCollection.deleteMany({ userId: String(userId) });
  return res.deletedCount || 0;
}

module.exports = {
  findLicensesForDomains,
  getClaimsForUser,
  claimSeat,
  listSchoolLicenses,
  getSchoolLicense,
  createSchoolLicense,
  updateSchoolLicense,
  releaseClaimsForDeletedUser,
};
