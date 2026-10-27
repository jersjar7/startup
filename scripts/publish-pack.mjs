#!/usr/bin/env node
// Publishes a built content pack to service/packs/<exam>/ (ADR 0030).
//
//   cd mobile && flutter test test/packs/build_pack_test.dart && cd ..
//   node scripts/publish-pack.mjs mobile/build/packs/fe-civil.json
//
// Gives the pack the next version, writes it under a name that carries its
// hash, and updates the exam's manifest. Refuses a pack with problems, does
// nothing when the content matches the latest version, and never overwrites
// a published file. Commit the new file and the manifest, then deploy the
// service; the server reads packs at startup.

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
const latestPack = manifest ? JSON.parse(fs.readFileSync(path.join(dir, manifest.latest.file), 'utf8')) : null;

let result;
try {
  result = preparePublish(pack, manifest, latestPack);
} catch (e) {
  console.error(e.message);
  process.exit(1);
}

if (result.unchanged) {
  console.log(`${pack.exam}: nothing changed since version ${result.version}; nothing published.`);
  process.exit(0);
}

fs.mkdirSync(dir, { recursive: true });
// 'wx' fails if the file exists: a published version is never rewritten.
fs.writeFileSync(path.join(dir, result.file), result.text, { flag: 'wx' });
fs.writeFileSync(manifestFile, `${JSON.stringify(result.manifest, null, 2)}\n`);

const { latest } = result.manifest;
console.log(`${pack.exam}: published version ${latest.version} as ${latest.file}`);
console.log(`  ${Object.keys(latest.lessons).length} lessons, ${latest.bytes} bytes, ${latest.gzipBytes} to download`);
