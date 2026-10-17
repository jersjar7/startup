// "Contact us", from the website's /contact page and the app's account sheet
// (the tester's point 12a, owner 2026-10-17).
//
// Anybody can write, signed in or not: a student who cannot sign in is the
// one most likely to need it. A signed-in message carries the account's
// address; otherwise the sender gives one, so a reply has somewhere to go.
// Each message is stored and emailed to the owner with Reply-To set to the
// sender.

const MAX_MESSAGE = 2000;
const PER_HOUR = 5; // per sender address, on top of the per-IP limiter
const SOURCES = new Set(['app', 'web']);
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

/**
 * Checks a message. `accountEmail` is the signed-in account's, or null.
 * Returns { ok: true, value } or { ok: false, msg } in words the page shows.
 * A filled honeypot field (`website`) is { ok: true, spam: true }: the bot is
 * thanked and nothing is sent.
 */
function validateContact(body, accountEmail = null) {
  if (!body || typeof body !== 'object') return { ok: false, msg: 'Nothing to send.' };
  if (typeof body.website === 'string' && body.website.trim()) return { ok: true, spam: true };
  const message = typeof body.message === 'string' ? body.message.trim() : '';
  if (!message) return { ok: false, msg: 'Write a message first.' };
  if (message.length > MAX_MESSAGE) return { ok: false, msg: `Keep it under ${MAX_MESSAGE} characters.` };
  let email = accountEmail;
  if (!email) {
    email = typeof body.email === 'string' ? body.email.trim().toLowerCase() : '';
    if (!EMAIL_RE.test(email) || email.length > 200) {
      return { ok: false, msg: 'Add an email address so we can write back.' };
    }
  }
  const name = typeof body.name === 'string' && body.name.trim() ? body.name.trim().slice(0, 80) : null;
  const source = SOURCES.has(body.source) ? body.source : 'web';
  const build = typeof body.build === 'string' ? body.build.trim().slice(0, 20) : null;
  return { ok: true, value: { email, name, message, source, build, signedIn: !!accountEmail } };
}

/** True when this address has already sent PER_HOUR messages in the last hour. */
function overTheHourlyLimit(sentInLastHour) {
  return sentInLastHour >= PER_HOUR;
}

module.exports = { validateContact, overTheHourlyLimit, MAX_MESSAGE, PER_HOUR };
