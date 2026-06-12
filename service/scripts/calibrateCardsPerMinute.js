// Q4 calibration: derive the cards/minute constant empirically instead of
// guessing 0.6. Reads sessionLog rows that carry durationSeconds (added in
// Stage 1; null on older rows), computes median seconds-per-card, and prints
// the implied cards/minute so AdaptivePacingPolicy's 0.6 can be replaced with a
// measured value once enough sessions have accrued.
//
// Run ON THE BOX with the service env sourced (same pattern as the deploy
// preflight):
//   cd services/startup && set -a && . ./.env && set +a && node scripts/calibrateCardsPerMinute.js
//
// Does NOT write anything — read-only analysis.

const { MongoClient } = require('mongodb');

const MIN_SESSIONS = 30; // don't trust a constant derived from a handful of sessions

function median(nums) {
  const s = [...nums].sort((a, b) => a - b);
  const mid = Math.floor(s.length / 2);
  return s.length % 2 ? s[mid] : (s[mid - 1] + s[mid]) / 2;
}

async function main() {
  const url = `mongodb+srv://${process.env.DB_USERNAME}:${process.env.DB_PASSWORD}@${process.env.DB_HOSTNAME}`;
  const client = new MongoClient(url, { serverSelectionTimeoutMS: 8000 });
  try {
    await client.connect();
    const rows = await client
      .db('fe4raccoons')
      .collection('sessionLog')
      .find({ durationSeconds: { $gt: 0 }, totalProblems: { $gt: 0 } })
      .project({ durationSeconds: 1, totalProblems: 1, type: 1 })
      .toArray();

    if (rows.length < MIN_SESSIONS) {
      console.log(
        `Not enough timed sessions yet: ${rows.length} (need >= ${MIN_SESSIONS}). ` +
          `Keep the 0.6 default until more accrue.`,
      );
      return;
    }

    const secPerCard = rows.map((r) => r.durationSeconds / r.totalProblems);
    const medSec = median(secPerCard);
    const cardsPerMinute = 60 / medSec;
    // AdaptivePacingPolicy uses dailyCardTarget = minutesPerDay * K. Today K=0.6
    // (i.e. ~10 min for 6 cards -> 100s/card). The measured K is cards/minute.
    console.log(`Sessions analyzed : ${rows.length}`);
    console.log(`Median sec/card   : ${medSec.toFixed(1)}`);
    console.log(`=> cards/minute K : ${cardsPerMinute.toFixed(2)}  (current default 0.6)`);
  } catch (e) {
    console.error(`Calibration failed: ${e.message}`);
    process.exitCode = 1;
  } finally {
    await client.close().catch(() => {});
  }
}

main();
