#!/usr/bin/env node
// Publishes a built content pack to service/packs/<exam>/ (ADR 0030).
//
//   cd mobile && flutter test --run-skipped test/packs/build_pack_test.dart && cd ..
//   node scripts/publish-pack.mjs mobile/build/packs/fe-civil.json
//
// Gives the pack the next version, splits it into one file per chapter and
// an index (ADR 0033), writes each under a name that carries its hash, and
// updates the exam's manifest. A chapter that has not changed is already
// published under the same name and is left alone. Refuses a pack with
// problems, does nothing when the content matches the latest version, and
// never overwrites a published file. Commit the new files and the manifest,
// copy the version into the app (docs/mobile/content-packs.md), then deploy
// the service; the server reads packs at startup.

import fs from 'node:fs';
import path from 'node:path';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const { PACKS_DIR, preparePublish } = require('../service/packs.js');

const source = process.argv[2];
if (!source) {
  console.error('usage: node scripts/publish-pack.mjs <built pack .json>');
  process.exit(1);
}

const pack = JSON.parse(fs.readFileSync(source, 'utf8'));
const dir = path.join(PACKS_DIR, String(pack.exam));
const manifestFile = path.join(dir, 'manifest.json');
const manifest = fs.existsSync(manifestFile) ? JSON.parse(fs.readFileSync(manifestFile, 'utf8')) : null;
const latestText = manifest ? fs.readFileSync(path.join(dir, manifest.latest.file), 'utf8') : null;

let result;
try {
  result = preparePublish(pack, manifest, latestText);
} catch (e) {
  console.error(e.message);
  process.exit(1);
}

if (result.unchanged) {
  console.log(`${pack.exam}: nothing changed since version ${result.version}; nothing published.`);
  process.exit(0);
}

fs.mkdirSync(dir, { recursive: true });
// 'wx' fails if the file exists: nothing published is ever rewritten. A
// chapter file already there is the same content, since its name is its hash.
let added = 0;
for (const c of result.chapters) {
  const file = path.join(dir, c.file);
  if (fs.existsSync(file)) continue;
  fs.writeFileSync(file, c.text, { flag: 'wx' });
  added++;
}
fs.writeFileSync(path.join(dir, result.file), result.text, { flag: 'wx' });
fs.writeFileSync(manifestFile, `${JSON.stringify(result.manifest, null, 2)}\n`);

const { latest } = result.manifest;
console.log(`${pack.exam}: published version ${latest.version} as ${latest.file}`);
console.log(`  ${Object.keys(latest.lessons).length} lessons, ${latest.bytes} bytes, ${latest.gzipBytes} to download from nothing`);
console.log(`  ${result.chapters.length} chapters, ${added} of them new in this version`);
