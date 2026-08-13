#!/usr/bin/env node
/**
 * Mint (or revoke) an auth session for the QA account, so automated UI checks
 * can reach signed-in pages WITHOUT anyone storing a password.
 *
 * Why this exists: the old flow kept a real password in secrets/qa-login.json
 * and typed it into the login form. That meant a live credential sat on disk,
 * broke whenever the password changed, and had to be handled by whoever set the
 * tooling up. A session token is strictly better here — it is revocable on its
 * own, survives password changes, and never has to be shared to be used.
 *
 * The account is read from secrets/qa-account.json ({ "email": "..." }), which
 * holds no secret but is kept out of the PUBLIC repo anyway so it does not
 * advertise which account is the test one.
 *
 * Usage (env comes from the service, same as the other DB scripts):
 *   node --env-file=service/.env scripts/qa-session.mjs            # mint, print token
 *   node --env-file=service/.env scripts/qa-session.mjs --revoke   # delete ALL its sessions
 *
 * Sessions are also reaped automatically by the Mongo TTL index after 30 idle
 * days, so a forgotten token is not permanent.
 */
import { createRequire } from 'node:module';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.join(path.dirname(fileURLToPath(import.meta.url)), '..');
// `mongodb` is installed under service/, not at the repo root.
const require = createRequire(new URL('../service/', import.meta.url));
const { MongoClient } = require('mongodb');

const ACCOUNT_FILE = path.join(root, 'secrets/qa-account.json');

export function qaEmail() {
  if (!fs.existsSync(ACCOUNT_FILE)) {
    throw new Error(`Missing ${ACCOUNT_FILE} — expected { "email": "..." }`);
  }
  const { email } = JSON.parse(fs.readFileSync(ACCOUNT_FILE, 'utf8'));
  if (!email) throw new Error(`${ACCOUNT_FILE} has no "email"`);
  return email;
}

function client() {
  const { DB_USERNAME, DB_PASSWORD, DB_HOSTNAME } = process.env;
  if (!DB_HOSTNAME || !DB_USERNAME || !DB_PASSWORD) {
    throw new Error('Missing DB_* env. Run with: node --env-file=service/.env …');
  }
  return new MongoClient(`mongodb+srv://${DB_USERNAME}:${encodeURIComponent(DB_PASSWORD)}@${DB_HOSTNAME}`);
}

/**
 * Insert a session row and return its token.
 *
 * The shape MIRRORS service/db/sessions.js createSession(). If that ever
 * changes, change it here too — this is the one place the duplication lives,
 * and it is deliberate so the script stays self-contained and exits cleanly
 * rather than importing the service's long-lived Mongo connection.
 */
export async function mintQaSession({ client: kind = 'web' } = {}) {
  const email = qaEmail();
  const c = client();
  await c.connect();
  try {
    const users = c.db('fe4raccoons').collection('users');
    if (!(await users.findOne({ email }))) {
      throw new Error(`QA account ${email} does not exist in the database`);
    }
    const token = crypto.randomUUID();
    const now = new Date();
    await c.db('fe4raccoons').collection('sessions').insertOne({
      token, email, client: kind === 'mobile' ? 'mobile' : 'web', createdAt: now, lastSeen: now,
    });
    return { token, email };
  } finally {
    await c.close();
  }
}

export async function revokeQaSessions() {
  const email = qaEmail();
  const c = client();
  await c.connect();
  try {
    const r = await c.db('fe4raccoons').collection('sessions').deleteMany({ email });
    return r.deletedCount;
  } finally {
    await c.close();
  }
}

/** Revoke exactly one token — used by verify-ui.mjs so a run cleans up after itself. */
export async function revokeToken(token) {
  const c = client();
  await c.connect();
  try {
    const r = await c.db('fe4raccoons').collection('sessions').deleteOne({ token });
    return r.deletedCount;
  } finally {
    await c.close();
  }
}

// CLI
if (import.meta.url === `file://${process.argv[1]}`) {
  if (process.argv.includes('--revoke')) {
    const n = await revokeQaSessions();
    console.log(`revoked ${n} session(s) for ${qaEmail()}`);
  } else {
    const { token, email } = await mintQaSession();
    console.log(`session for ${email}:`);
    console.log(token);
  }
}
