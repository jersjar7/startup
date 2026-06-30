const authCookieName = 'token';

// New per-device sessions live 30 days, sliding on activity. Legacy single-token
// users (created before sessions) are honored under the old 7-day rule until
// their token ages out — so deploying this does NOT log everyone out.
const SESSION_MAX_AGE_MS = 30 * 24 * 60 * 60 * 1000;
const LEGACY_MAX_AGE_MS = 7 * 24 * 60 * 60 * 1000;
// Don't write to the DB on every request; slide a session at most once a day.
const TOUCH_AFTER_MS = 24 * 60 * 60 * 1000;

// Shared so the cookie is cleared with the SAME attributes it was set with —
// otherwise the browser keeps it.
const COOKIE_OPTS = { secure: true, httpOnly: true, sameSite: 'strict', path: '/' };

// Token comes from the httpOnly cookie (web) or an Authorization: Bearer
// header (mobile app — no reliable cross-platform cookie jar).
function extractToken(req) {
  const header = req.headers.authorization || '';
  if (header.startsWith('Bearer ')) return header.slice(7);
  return req.cookies[authCookieName];
}

// Pure decision: given a token and a db facade, decide whether to allow the
// request and what side effects the caller should perform. Kept side-effect
// free so it's unit-testable without a real database. Returns:
//   { allow:true, user, touch?:token }
//   { allow:false, msg, clearCookie?:bool, deleteSession?:token }
async function resolveAuth(token, db, now = Date.now()) {
  if (!token) return { allow: false, msg: 'Unauthorized' };

  // 1) Session-based auth (current model).
  const session = await db.getSessionByToken(token);
  if (session) {
    const lastSeen = session.lastSeen ? new Date(session.lastSeen).getTime() : 0;
    if (now - lastSeen > SESSION_MAX_AGE_MS) {
      return { allow: false, msg: 'Session expired', clearCookie: true, deleteSession: token };
    }
    const user = await db.getUser(session.email);
    if (!user) return { allow: false, msg: 'Unauthorized', deleteSession: token };
    return { allow: true, user, touch: now - lastSeen > TOUCH_AFTER_MS ? token : null };
  }

  // 2) Legacy fallback: a pre-sessions user whose token is on the user doc.
  // Fail CLOSED on a missing tokenCreatedAt, same as before.
  const legacyUser = await db.getUserByToken(token);
  if (legacyUser) {
    const createdAt = legacyUser.tokenCreatedAt ? new Date(legacyUser.tokenCreatedAt).getTime() : 0;
    if (now - createdAt > LEGACY_MAX_AGE_MS) {
      return { allow: false, msg: 'Session expired', clearCookie: true };
    }
    return { allow: true, user: legacyUser };
  }

  return { allow: false, msg: 'Unauthorized' };
}

const verifyAuth = async (req, res, next) => {
  // Lazy-require so the module can be imported in tests without booting the DB.
  const DB = require('../database.js');
  try {
    const token = extractToken(req);
    req.authToken = token; // so /logout can delete exactly this session
    const r = await resolveAuth(token, DB);
    if (r.deleteSession) await DB.deleteSession(r.deleteSession);
    if (!r.allow) {
      if (r.clearCookie) res.clearCookie(authCookieName, COOKIE_OPTS);
      res.status(401).send({ msg: r.msg });
      return;
    }
    if (r.touch) DB.touchSession(r.touch).catch(() => {});
    req.user = r.user;
    next();
  } catch (err) {
    res.status(500).send({ msg: 'Internal server error' });
  }
};

function setAuthCookie(res, authToken) {
  res.cookie(authCookieName, authToken, { ...COOKIE_OPTS, maxAge: SESSION_MAX_AGE_MS });
}

function clearAuthCookie(res) {
  res.clearCookie(authCookieName, COOKIE_OPTS);
}

module.exports = {
  verifyAuth,
  resolveAuth,
  setAuthCookie,
  clearAuthCookie,
  authCookieName,
  SESSION_MAX_AGE_MS,
  LEGACY_MAX_AGE_MS,
  TOUCH_AFTER_MS,
};
