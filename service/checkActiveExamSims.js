// Deploy preflight: is anyone mid-exam-simulation right now?
//
// The paid Exam Simulation is a single timed 6-hour (5h20m) in-app session. A
// deploy that restarts the backend or swaps the bundle under a user 4 hours
// into a paid exam is exactly what we must never do. This script is run ON THE
// BOX by deployService.sh before it touches anything; it prints a sentinel the
// deploy script greps:
//   PREFLIGHT_BLOCK  -> an exam sim is in progress, abort the deploy
//   PREFLIGHT_OK     -> safe to deploy
//   PREFLIGHT_WARN   -> the check itself could not run; deploy proceeds (fail-open)
//
// Env (DB_USERNAME/DB_PASSWORD/DB_HOSTNAME) is sourced from the service's .env
// by the caller, so this matches service/db/connection.js exactly.

const { MongoClient } = require('mongodb');

// Time limit (5h20m) + a 30-minute grace so an abandoned, never-submitted
// attempt from hours ago does not block deploys forever.
const ACTIVE_WINDOW_MS = (5 * 3600 + 20 * 60 + 30 * 60) * 1000;

async function main() {
  const url = `mongodb+srv://${process.env.DB_USERNAME}:${process.env.DB_PASSWORD}@${process.env.DB_HOSTNAME}`;
  const client = new MongoClient(url, { serverSelectionTimeoutMS: 8000 });
  try {
    await client.connect();
    const attempts = client.db('fe4raccoons').collection('examAttempts');
    const cutoff = new Date(Date.now() - ACTIVE_WINDOW_MS);
    const active = await attempts.countDocuments({
      status: 'in_progress',
      startedAt: { $gt: cutoff },
    });
    if (active > 0) {
      console.log(
        `PREFLIGHT_BLOCK ${active} exam simulation(s) in progress (started within the last ~5h50m).`,
      );
    } else {
      console.log('PREFLIGHT_OK no active exam simulations.');
    }
  } catch (e) {
    // Never let a check failure block all deploys; warn loudly and proceed.
    console.log(`PREFLIGHT_WARN active-sim check could not run: ${e.message}`);
  } finally {
    await client.close().catch(() => {});
  }
}

main();
