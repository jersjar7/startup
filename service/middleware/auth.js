const DB = require('../database.js');

const authCookieName = 'token';
const TOKEN_MAX_AGE_MS = 7 * 24 * 60 * 60 * 1000; // 7 days

const verifyAuth = async (req, res, next) => {
  try {
    const user = await DB.getUserByToken(req.cookies[authCookieName]);
    if (user) {
      if (user.tokenCreatedAt) {
        const age = Date.now() - new Date(user.tokenCreatedAt).getTime();
        if (age > TOKEN_MAX_AGE_MS) {
          res.status(401).send({ msg: 'Session expired' });
          return;
        }
      }
      req.user = user;
      next();
    } else {
      res.status(401).send({ msg: 'Unauthorized' });
    }
  } catch (err) {
    res.status(500).send({ msg: 'Internal server error' });
  }
};

function setAuthCookie(res, authToken) {
  res.cookie(authCookieName, authToken, {
    secure: true,
    httpOnly: true,
    sameSite: 'strict',
    maxAge: TOKEN_MAX_AGE_MS,
  });
}

module.exports = { verifyAuth, setAuthCookie, authCookieName };
