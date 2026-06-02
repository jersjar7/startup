const express = require('express');
const bcrypt = require('bcryptjs');
const uuid = require('uuid');
const rateLimit = require('express-rate-limit');
const DB = require('../database.js');
const { verifyAuth, setAuthCookie, authCookieName } = require('../middleware/auth.js');
const { getBadgeDetails, getAllBadges } = require('../badges.js');
const { generateToken, hashToken } = require('../crypto.js');
const { sendPasswordResetEmail, sendVerificationEmail } = require('../email.js');

const router = express.Router();

// Stricter rate limit for password-reset requests
const forgotLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  standardHeaders: true,
  legacyHeaders: false,
  message: { msg: 'Too many attempts, try again later' },
});

// Validation helpers
function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function validatePassword(password) {
  return password && password.length >= 8 && /(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/.test(password);
}

function validateAuthInput(req, res, isRegistration = false) {
  const { email, password } = req.body;
  const errors = [];

  if (!email || !isValidEmail(email)) {
    errors.push({ field: 'email', message: 'Must be a valid email' });
  }
  if (!password || password.length < 8) {
    errors.push({ field: 'password', message: 'Must be at least 8 characters' });
  } else if (isRegistration && !validatePassword(password)) {
    errors.push({ field: 'password', message: 'Must include uppercase, lowercase, and a number' });
  }

  if (errors.length > 0) {
    res.status(400).send({ msg: 'Validation error', errors });
    return false;
  }
  return true;
}

// Register a new user
router.post('/create', async (req, res) => {
  if (!validateAuthInput(req, res, true)) return;

  if (await DB.getUser(req.body.email)) {
    res.status(409).send({ msg: 'Existing user' });
  } else {
    const rawVerifyToken = generateToken();
    const passwordHash = await bcrypt.hash(req.body.password, 10);
    const user = {
      email: req.body.email,
      password: passwordHash,
      token: uuid.v4(),
      tokenCreatedAt: new Date(),
      createdAt: new Date(),
      emailVerified: false,
      verificationToken: hashToken(rawVerifyToken),
    };
    await DB.addUser(user);
    setAuthCookie(res, user.token);

    // Fire-and-forget verification email
    sendVerificationEmail(req.body.email, rawVerifyToken);

    res.send({ email: user.email });
  }
});

// Login an existing user
router.post('/login', async (req, res) => {
  if (!validateAuthInput(req, res)) return;

  const user = await DB.getUser(req.body.email);
  if (user && (await bcrypt.compare(req.body.password, user.password))) {
    user.token = uuid.v4();
    user.tokenCreatedAt = new Date();
    await DB.updateUser(user);
    setAuthCookie(res, user.token);
    res.send({ email: user.email });
  } else {
    res.status(401).send({ msg: 'Incorrect email or password.' });
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

// Get the current authenticated user with stats
router.get('/me', async (req, res) => {
  const user = await DB.getUserByToken(req.cookies[authCookieName]);
  if (user) {
    const stats = await DB.getUserStats(user.email);
    const earnedBadgeIds = stats?.badges || [];
    res.send({
      email: user.email,
      createdAt: user.createdAt || null,
      emailVerified: user.emailVerified ?? true,
      totalXp: stats?.totalXp || 0,
      currentStreak: stats?.currentStreak || 0,
      longestStreak: stats?.longestStreak || 0,
      badges: getBadgeDetails(earnedBadgeIds),
      allBadges: getAllBadges(),
    });
  } else {
    res.status(401).send({ msg: 'Unauthorized' });
  }
});

// Forgot password — always returns 200 to prevent email enumeration
router.post('/forgot-password', forgotLimiter, async (req, res) => {
  const { email } = req.body;
  if (!email || !isValidEmail(email)) {
    return res.status(400).send({ msg: 'Valid email is required' });
  }

  const user = await DB.getUser(email);
  if (user) {
    const rawToken = generateToken();
    user.resetToken = hashToken(rawToken);
    user.resetTokenExpiry = new Date(Date.now() + 60 * 60 * 1000); // 1 hour
    await DB.updateUser(user);
    sendPasswordResetEmail(email, rawToken);
  }

  res.send({ msg: 'If that email exists, a reset link has been sent.' });
});

// Reset password with token
router.post('/reset-password', async (req, res) => {
  const { token, password } = req.body;
  if (!token || !password) {
    return res.status(400).send({ msg: 'Token and password are required' });
  }
  if (!validatePassword(password)) {
    return res.status(400).send({ msg: 'Password must be 8+ characters with uppercase, lowercase, and a number' });
  }

  const hashed = hashToken(token);
  const user = await DB.getUserByResetToken(hashed);
  if (!user) {
    return res.status(400).send({ msg: 'Invalid or expired reset link' });
  }

  user.password = await bcrypt.hash(password, 10);
  delete user.token; // invalidate session
  await DB.updateUser(user);
  await DB.unsetUserFields(user.email, ['resetToken', 'resetTokenExpiry']);

  res.clearCookie(authCookieName);
  res.send({ msg: 'Password has been reset. Please log in.' });
});

// Verify email
router.get('/verify-email/:token', async (req, res) => {
  const hashed = hashToken(req.params.token);
  const user = await DB.getUserByVerificationToken(hashed);
  if (!user) {
    return res.status(400).send({ msg: 'Invalid or expired verification link' });
  }

  user.emailVerified = true;
  await DB.updateUser(user);
  await DB.unsetUserFields(user.email, ['verificationToken']);

  res.send({ msg: 'Email verified successfully' });
});

// Resend verification email
router.post('/resend-verification', verifyAuth, async (req, res) => {
  const user = req.user;
  if (user.emailVerified) {
    return res.send({ msg: 'Email already verified' });
  }

  const rawToken = generateToken();
  user.verificationToken = hashToken(rawToken);
  await DB.updateUser(user);
  sendVerificationEmail(user.email, rawToken);

  res.send({ msg: 'Verification email sent' });
});

// Change password (requires auth)
router.post('/change-password', verifyAuth, async (req, res) => {
  const { currentPassword, newPassword } = req.body;
  if (!currentPassword || !newPassword) {
    return res.status(400).send({ msg: 'Current and new passwords are required' });
  }
  if (!validatePassword(newPassword)) {
    return res.status(400).send({ msg: 'New password must be 8+ characters with uppercase, lowercase, and a number' });
  }

  const user = req.user;
  const match = await bcrypt.compare(currentPassword, user.password);
  if (!match) {
    return res.status(401).send({ msg: 'Current password is incorrect' });
  }

  user.password = await bcrypt.hash(newPassword, 10);
  user.token = uuid.v4();
  user.tokenCreatedAt = new Date();
  await DB.updateUser(user);
  setAuthCookie(res, user.token);

  res.send({ msg: 'Password changed successfully' });
});

// Delete account (requires auth)
router.delete('/account', verifyAuth, async (req, res) => {
  const { password, confirmation } = req.body;
  if (!password || confirmation !== 'DELETE') {
    return res.status(400).send({ msg: 'Password and DELETE confirmation required' });
  }

  const user = req.user;
  const match = await bcrypt.compare(password, user.password);
  if (!match) {
    return res.status(401).send({ msg: 'Password is incorrect' });
  }

  await DB.deleteAllUserData(user.email);
  res.clearCookie(authCookieName);
  res.send({ msg: 'Account deleted' });
});

module.exports = router;
