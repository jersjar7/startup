// Who is allowed to see and name a pass card.
//
// Pulled out of the route so it can be tested without a database, the same way
// examResultLink.js is. The route is glue: look the token up, call these,
// answer.
//
// The card is reached from a link in an email, with no sign in. That is a
// deliberate choice and it is only safe because of what the card does not
// carry: no coverage, no score, no mastery, nothing but a name, a month and the
// exam's own chapter list. An earlier design put the person's own figures on it,
// which would have meant a forwarded email handed their study record to whoever
// opened it. See docs/EXAM-OUTCOME-AND-PASS-CARD.md section 4.

const { sanitizeName } = require('./profile.js');

/// Whether this account has a card at all.
///
/// Only a pass earns one. Somebody who failed or did not sit it must never be
/// offered one, and the check is on the recorded outcome rather than on how
/// they arrived, so a guessed or edited URL cannot manufacture a card.
function canSeeCard(user) {
  const o = user?.examOutcome;
  return Boolean(o && o.answeredAt && o.sat === true && o.passed === true);
}

/// What the card page needs. Never the email address, and never anything the
/// person has not already published by owning the account.
function cardPayload(user) {
  if (!canSeeCard(user)) return null;
  const firstName = sanitizeName(user.firstName || '');
  const lastName = sanitizeName(user.lastName || '');
  return {
    firstName: firstName || null,
    lastName: lastName || null,
    hasName: Boolean(firstName || lastName),
    answeredAt: user.examOutcome.answeredAt,
  };
}

/// Whether a name typed on the card page may be written to the account.
///
/// Only when the account has none. The token travels in an email, and a
/// forwarded one must not let somebody else rename the account; it may only
/// fill a blank that is otherwise blocking the card. Changing a name that
/// exists stays behind a sign in, in the profile, where it always was.
function mayNameAccount(user, raw) {
  if (!canSeeCard(user)) return false;
  if (user.firstName || user.lastName) return false;
  return Boolean(sanitizeName(raw || ''));
}

/// Split what they typed into the two fields the account already has.
///
/// One field on screen rather than two: they are being asked for a name on the
/// way to a reward, not filling in a form. Everything after the first space is
/// the last name, which is wrong for some names and right for most, and is only
/// ever used to print the card and never to address them.
function splitName(raw) {
  const clean = sanitizeName(raw || '');
  if (!clean) return null;
  const at = clean.indexOf(' ');
  if (at === -1) return { firstName: clean, lastName: null };
  return {
    firstName: clean.slice(0, at),
    lastName: clean.slice(at + 1).trim() || null,
  };
}

module.exports = { canSeeCard, cardPayload, mayNameAccount, splitName };
