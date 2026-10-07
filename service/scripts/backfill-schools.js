#!/usr/bin/env node
//
// Name the institution of everybody who signed up with a university address.
//
// Measured 2026-10-07: 55 of 511 accounts have an academic email and every one
// of them resolves against the directory, 49 of those having no school on
// record. That takes the number of accounts attached to an institution from 19
// to 68 without asking anybody anything, which matters because a cohort report
// cannot be built on 19.
//
// Run:  node service/scripts/backfill-schools.js          (dry run, writes nothing)
//       node service/scripts/backfill-schools.js --write  (applies)
//
// Safe to run twice. It only ever fills a blank: an account that already has a
// school name is left alone, whether somebody typed it or a previous run
// inferred it.

require('dotenv').config();
const { userCollection } = require('../db/connection.js');
const { academicDomain, normalizeSchoolName } = require('../school.js');
const { schoolForDomain } = require('../schoolDirectory.js');

const WRITE = process.argv.includes('--write');

async function main() {
  const users = await userCollection
    .find({}, { projection: { email: 1, school: 1 } })
    .toArray();

  const plan = [];
  let academic = 0;
  let unresolved = 0;
  let alreadyNamed = 0;

  for (const user of users) {
    const domain = academicDomain(user.email);
    if (!domain) continue;
    academic += 1;

    const name = schoolForDomain(domain);
    if (!name) {
      // A .edu we do not recognise. Left alone rather than guessed at: a wrong
      // institution is worse than a missing one, because it is counted.
      unresolved += 1;
      continue;
    }
    if (user.school && user.school.name) {
      alreadyNamed += 1;
      continue;
    }
    plan.push({ email: user.email, domain, name });
  }

  const byName = new Map();
  for (const row of plan) byName.set(row.name, (byName.get(row.name) || 0) + 1);

  console.log(`accounts:               ${users.length}`);
  console.log(`academic address:       ${academic}`);
  console.log(`  already named:        ${alreadyNamed}`);
  console.log(`  domain not in list:   ${unresolved}`);
  console.log(`  to fill:              ${plan.length}`);
  console.log(`distinct institutions:  ${byName.size}`);
  for (const [name, n] of [...byName].sort((a, b) => b[1] - a[1]).slice(0, 10)) {
    console.log(`    ${String(n).padStart(3)}  ${name}`);
  }

  if (!WRITE) {
    console.log('\nDry run. Nothing written. Pass --write to apply.');
    return;
  }

  let written = 0;
  for (const row of plan) {
    const norm = normalizeSchoolName(row.name);
    // inferredAt, never answeredAt. They did not tell us this, and the domain
    // gives an institution but never a graduation year, so they are still
    // worth asking once with the university already filled in.
    const update = {
      'school.name': norm.name,
      'school.key': norm.key,
      'school.domain': row.domain,
      'school.inferredAt': new Date(),
    };
    // The filter repeats the "no name" condition so a concurrent write cannot
    // be overwritten between the read above and this update.
    const res = await userCollection.updateOne(
      { email: row.email, 'school.name': { $exists: false } },
      { $set: update },
    );
    written += res.modifiedCount;
  }
  console.log(`\nwrote ${written} of ${plan.length}`);
}

main()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error('backfill failed:', e.message);
    process.exit(1);
  });
