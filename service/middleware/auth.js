const DB = require('../database.js');

const authCookieName = 'token';

const verifyAuth = async (req, res, next) => {
  try {
    const user = await DB.getUserByToken(req.cookies[authCookieName]);
    if (user) {
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
  });
}

module.exports = { verifyAuth, setAuthCookie, authCookieName };
