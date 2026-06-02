const DB = require('../database.js');

const authCookieName = 'token';
const TOKEN_MAX_AGE_MS = 7 * 24 * 60 * 60 * 1000; // 7 days

// Shared so the cookie is cleared with the SAME attributes it was set with —
// otherwise the browser keeps it.
const COOKIE_OPTS = { secure: true, httpOnly: true, sameSite: 'strict', path: '/' };

const verifyAuth = async (req, res, next) => {
  try {
    const user = await DB.getUserByToken(req.cookies[authCookieName]);
    if (!user) {
      res.status(401).send({ msg: 'Unauthorized' });
      return;
    }
    // Fail CLOSED: a token with no tokenCreatedAt is treated as expired, not
    // never-expiring. Clear the stale cookie so the client can self-heal.
    const createdAt = user.tokenCreatedAt ? new Date(user.tokenCreatedAt).getTime() : 0;
    if (Date.now() - createdAt > TOKEN_MAX_AGE_MS) {
      res.clearCookie(authCookieName, COOKIE_OPTS);
      res.status(401).send({ msg: 'Session expired' });
      return;
    }
    req.user = user;
    next();
  } catch (err) {
    res.status(500).send({ msg: 'Internal server error' });
  }
};

function setAuthCookie(res, authToken) {
  res.cookie(authCookieName, authToken, { ...COOKIE_OPTS, maxAge: TOKEN_MAX_AGE_MS });
}

function clearAuthCookie(res) {
  res.clearCookie(authCookieName, COOKIE_OPTS);
}

module.exports = { verifyAuth, setAuthCookie, clearAuthCookie, authCookieName, TOKEN_MAX_AGE_MS };
