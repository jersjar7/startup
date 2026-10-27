const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

// Content packs (ADR 0030; docs/mobile/content-packs-migration.md, phase 1).
//
// Each exam has a folder under service/packs/<exam>/ holding:
// - manifest.json: what the phone asks for first. The exam, the latest
//   version, its file, its size, and every lesson's oldest app. Small and
//   always revalidated.
// - <exam>-v<version>-<hash>.json: one published version. Never changed or
//   removed once published; a fix is a new version in a new file, so a
//   phone midway through a download never gets half of two versions. The
//   name carries the first 12 characters of the content's sha256 and
//   packs.test.js checks every one.
//
// The pack builder (mobile/test/packs/build_pack_test.dart) writes the
// pack; scripts/publish-pack.mjs gives it its version and publishes it here.

const PACKS_DIR = path.join(__dirname, 'packs');
const FORMAT = 1; // the pack layout; see mobile/lib/features/packs/game_types.dart
const EXAM = /^[a-z0-9]+(-[a-z0-9]+)*$/;
const VERSION = /^\d+\.\d+\.\d+$/;
const FILE = /^([a-z0-9-]+)-v(\d+)-([a-f0-9]{12})\.json$/;

const sha256 = (text) => crypto.createHash('sha256').update(text).digest('hex');
const fileName = (exam, version, hash) => `${exam}-v${version}-${hash.slice(0, 12)}.json`;

// Everything wrong with a built pack, in plain words. Empty when it is fine.
function packProblems(pack) {
  const out = [];
  if (!pack || typeof pack !== 'object') return ['not a pack'];
  if (pack.format !== FORMAT) out.push(`format ${pack.format}, expected ${FORMAT}`);
  if (!EXAM.test(pack.exam || '')) out.push(`bad exam name "${pack.exam}"`);
  if (!pack.title) out.push('no title');
  const lessons = pack.lessons || {};
  const games = pack.games || {};
  if (!Object.keys(lessons).length) out.push('no lessons');
  const placed = new Map();
  for (const [id, lesson] of Object.entries(lessons)) {
    if (!/^[a-z0-9-]+\/[a-z0-9-]+$/.test(id)) out.push(`bad lesson id "${id}"`);
    if (!VERSION.test(lesson.minApp || '')) out.push(`${id}: bad minApp "${lesson.minApp}"`);
    if (!Array.isArray(lesson.games) || !lesson.games.length) out.push(`${id}: no games`);
    for (const g of lesson.games || []) {
      if (!games[g]) out.push(`${id}: game "${g}" is not in the pack`);
      if (placed.has(g)) out.push(`game "${g}" is in both ${placed.get(g)} and ${id}`);
      placed.set(g, id);
    }
  }
  for (const [id, game] of Object.entries(games)) {
    if (!placed.has(id)) out.push(`game "${id}" is in no lesson`);
    if (game.id !== id) out.push(`game "${id}" calls itself "${game.id}"`);
    if (!game.type) out.push(`game "${id}" has no type`);
    const chapter = placed.get(id)?.split('/')[0];
    if (chapter && game.chapter !== chapter) out.push(`game "${id}" says chapter "${game.chapter}", its lesson is in "${chapter}"`);
  }
  return out;
}

// The pack as published: the builder's pack with its version, as text.
function packText(pack, version) {
  const { format, exam, title, lessons, games } = pack;
  return JSON.stringify({ format, exam, title, version, lessons, games });
}

// The pack's content without its version, to tell whether anything changed.
const sameContent = (a, b) => packText(a, 0) === packText(b, 0);

// Works out what publishing [pack] adds, given the exam's manifest and its
// latest published pack (both null for a first publish). Returns
// { unchanged: true } when nothing changed, otherwise { file, text, manifest }.
function preparePublish(pack, manifest, latestPack, published = new Date().toISOString()) {
  const problems = packProblems(pack);
  if (problems.length) throw new Error(`Pack not published:\n- ${problems.join('\n- ')}`);
  if (manifest && manifest.exam !== pack.exam) throw new Error(`Manifest is for ${manifest.exam}, pack is ${pack.exam}`);
  const latest = manifest?.latest;
  if (latest && latestPack && sameContent(latestPack, pack)) return { unchanged: true, version: latest.version };

  const version = (latest?.version || 0) + 1;
  const text = packText(pack, version);
  const hash = sha256(text);
  const file = fileName(pack.exam, version, hash);
  const entry = {
    version,
    file,
    sha256: hash,
    bytes: Buffer.byteLength(text),
    gzipBytes: zlib.gzipSync(text).length,
    published,
    lessons: Object.fromEntries(Object.entries(pack.lessons).map(([id, l]) => [id, l.minApp])),
  };
  const next = {
    exam: pack.exam,
    title: pack.title,
    format: FORMAT,
    latest: entry,
    versions: [...(manifest?.versions || []), { version, file, sha256: hash, published }],
  };
  return { file, text, manifest: next };
}

// Reads every exam's manifest. A missing folder means no packs yet.
function loadManifests(dir = PACKS_DIR) {
  if (!fs.existsSync(dir)) return {};
  const out = {};
  for (const exam of fs.readdirSync(dir)) {
    const file = path.join(dir, exam, 'manifest.json');
    if (fs.existsSync(file)) out[exam] = JSON.parse(fs.readFileSync(file, 'utf8'));
  }
  return out;
}

module.exports = { PACKS_DIR, FORMAT, FILE, sha256, fileName, packProblems, packText, preparePublish, loadManifests };
