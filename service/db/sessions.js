const uuid = require('uuid');
const { sessionsCollection } = require('./connection');

// Per-device auth sessions. Each login (web cookie OR mobile bearer) gets its
// OWN session row, so a user can be signed in on the website and the app at the
// same time. Logout deletes just that one session; password reset / change and
// account deletion delete all of a user's sessions. Validity slides on activity
// (see middleware/auth.js) and a Mongo TTL index reaps idle ones after 30 days.

// Create a session for an email and return its opaque token.
async function createSession(email, client) {
  const token = uuid.v4();
  const now = new Date();
  await sessionsCollection.insertOne({
    token,
    email,
    client: client === 'mobile' ? 'mobile' : 'web',
    createdAt: now,
    lastSeen: now,
  });
  return token;
}

function getSessionByToken(token) {
  return sessionsCollection.findOne({ token });
}

// Slide the session forward so an active user never gets logged out.
async function touchSession(token, when) {
  await sessionsCollection.updateOne(
    { token },
    { $set: { lastSeen: when || new Date() } }
  );
}

async function deleteSession(token) {
  if (!token) return;
  await sessionsCollection.deleteOne({ token });
}

// Sign out everywhere — used by password reset/change and account deletion.
async function deleteSessionsForEmail(email) {
  await sessionsCollection.deleteMany({ email });
}

module.exports = {
  createSession,
  getSessionByToken,
  touchSession,
  deleteSession,
  deleteSessionsForEmail,
};
