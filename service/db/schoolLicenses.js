// School site licenses (ADR 0040): storage. The rule is schoolAccess.js and
// the entitlement check that joins the two is simAccess.js.
//
// schoolLicenses        one row per license a college bought
// schoolLicenseClaims   one row per student holding a seat, unique per
//                       (licenseId, userId); the license's seatsUsed counter is
//                       the number that is compared to the cap
const { ObjectId } = require('mongodb');
const { schoolLicensesCollection, schoolLicenseClaimsCollection } = require('./connection');

/// Licenses that list any of these domains. All states; the rule filters.
async function findLicensesForDomains(domains) {
  const list = [...new Set((domains || []).filter(Boolean))];
  if (!list.length) return [];
  return schoolLicensesCollection.find({ domains: { $in: list } }).toArray();
}

async function getClaimsForUser(userId) {
  return schoolLicenseClaimsCollection.find({ userId: String(userId) }).toArray();
}

/// Take a seat on a license for a student. Idempotent: a student who already
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

/// Account deletion gives the seat back to the school (owner, 2026-11-06).
///
/// Race-safe: each claim is removed by its own id, and only the request that
/// actually removed it lowers the counter, so two deletions arriving together
/// cannot hand back one seat twice. The counter never goes below zero.
async function releaseClaimsForDeletedUser(userId) {
  if (!userId) return 0;
  const claims = await schoolLicenseClaimsCollection.find({ userId: String(userId) }).toArray();
  let released = 0;
  for (const c of claims) {
    const gone = await schoolLicenseClaimsCollection.deleteOne({ _id: c._id });
    if (gone.deletedCount !== 1) continue;
    await schoolLicensesCollection.updateOne(
      { _id: c.licenseId, seatsUsed: { $gt: 0 } },
      { $inc: { seatsUsed: -1 } },
    );
    released += 1;
  }
  return released;
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
