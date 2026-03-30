const express = require('express');
const bcrypt = require('bcryptjs');
const uuid = require('uuid');
const DB = require('../database.js');
const { setAuthCookie, authCookieName } = require('../middleware/auth.js');

const router = express.Router();

// Validation helpers
function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function validateAuthInput(req, res) {
  const { email, password } = req.body;
  const errors = [];

  if (!email || !isValidEmail(email)) {
    errors.push({ field: 'email', message: 'Must be a valid email' });
  }
  if (!password || password.length < 8) {
    errors.push({ field: 'password', message: 'Must be at least 8 characters' });
  }

  if (errors.length > 0) {
    res.status(400).send({ msg: 'Validation error', errors });
    return false;
  }
  return true;
}

// Register a new user
router.post('/create', async (req, res) => {
  if (!validateAuthInput(req, res)) return;

  if (await DB.getUser(req.body.email)) {
    res.status(409).send({ msg: 'Existing user' });
  } else {
    const passwordHash = await bcrypt.hash(req.body.password, 10);
    const user = {
      email: req.body.email,
      password: passwordHash,
      token: uuid.v4(),
    };
    await DB.addUser(user);
    setAuthCookie(res, user.token);
    res.send({ email: user.email });
  }
});

// Login an existing user
router.post('/login', async (req, res) => {
  if (!validateAuthInput(req, res)) return;

  const user = await DB.getUser(req.body.email);
  if (user && (await bcrypt.compare(req.body.password, user.password))) {
    user.token = uuid.v4();
    await DB.updateUser(user);
    setAuthCookie(res, user.token);
    res.send({ email: user.email });
  } else {
    res.status(401).send({ msg: 'Unauthorized' });
  }
});

// Logout a user
router.delete('/logout', async (req, res) => {
  const user = await DB.getUserByToken(req.cookies[authCookieName]);
  if (user) {
    delete user.token;
    await DB.updateUser(user);
  }
  res.clearCookie(authCookieName);
  res.status(204).end();
});

// Get the current authenticated user
router.get('/me', async (req, res) => {
  const user = await DB.getUserByToken(req.cookies[authCookieName]);
  if (user) {
    res.send({ email: user.email });
  } else {
    res.status(401).send({ msg: 'Unauthorized' });
  }
});

module.exports = router;
