// THE entitlement check for the Exam Simulation (ADR 0040).
//
// A student has the simulation when they bought it (hasPurchased, unchanged)
// OR a school site licence covers one of their verified school addresses and
// they hold, or can take, a seat on it. Every place that gates the simulation
// asks this; hasPurchased alone misses licence students.
//
// It deliberately writes nothing to `purchases` and never sets examSimAccess on
// the user, so licence students can never reach a sales or revenue count
// (collectedSales.js, scripts/baseline-report.js).
//
// Reads through the DB facade (not the db/ modules directly) so route tests
// can stand in for the database.
const DB = require('./database.js');
const { decideSimAccess, verifiedSchoolDomains, emailDomain } = require('./schoolAccess.js');

/// user: the full user document (req.user, or the row a job is looping over).
///
/// claim: true takes a seat when the student qualifies and has none yet. Only
/// a student using the simulation should claim: the gate page and the exam
/// routes. Emails pass claim: false, which answers "would they have access"
/// without spending a seat.
async function resolveSimAccess(user, { claim = false, now = new Date() } = {}) {
  if (!user || !user._id) return decideSimAccess({});
  const uid = user._id.toString();
  if (await DB.hasPurchased(uid)) return decideSimAccess({ purchased: true });

  const domains = [...new Set([...verifiedSchoolDomains(user), emailDomain(user.email)].filter(Boolean))];
  if (!domains.length) return decideSimAccess({ user, now });
  const licenses = await DB.findLicensesForDomains(domains);
  if (!licenses.length) return decideSimAccess({ user, now });
  const claims = await DB.getClaimsForUser(uid);

  let decision = decideSimAccess({ user, licenses, claims, now });
  if (!(decision.access && decision.needsClaim) || !claim) return decision;

  // Two tries: the second covers losing the last seat to another student in
  // the instant between reading the counter and claiming it.
  for (let i = 0; i < 2; i += 1) {
    if (await DB.claimSeat(decision.license, uid, decision.domain)) {
      return { ...decision, needsClaim: false };
    }
    const fresh = await DB.findLicensesForDomains(domains);
    decision = decideSimAccess({ user, licenses: fresh, claims, now });
    if (!(decision.access && decision.needsClaim)) return decision;
  }
  return { ...decision, access: false, via: null, reason: 'seats_full', needsClaim: false };
}

/// Yes or no, without claiming a seat.
async function hasSimAccess(user, opts = {}) {
  return (await resolveSimAccess(user, { ...opts, claim: false })).access;
}

module.exports = { resolveSimAccess, hasSimAccess };
