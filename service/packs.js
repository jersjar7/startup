const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

// Content packs (ADR 0030; docs/mobile/content-packs-migration.md, phase 1).
//
// Each exam has a folder under service/packs/<exam>/ holding:
// - manifest.json: what the phone asks for first. The exam, the latest
//   version, its file, its size, every lesson's oldest app and every
//   chapter's file. Small and always revalidated.
// - <exam>-v<version>-<hash>.json: one published version. Since format 2
//   (ADR 0033) it is an index: every lesson with its games and oldest app,
//   and every chapter's file with its sha256. Versions 1 to 18 of FE Civil
//   are format 1, the whole pack in one file, and stay as they are.
// - <exam>.<chapter>.<hash>.json: one chapter's games (format 2), named by
//   its content and shared by every version that leaves the chapter alone,
//   so a version adds only the chapters that changed.
//
// Nothing published is ever changed or removed; a fix is a new version, so
// a phone midway through a download never gets half of two versions. Every
// name carries the first 12 characters of its content's sha256 and
// packs.test.js checks every one.
//
// The pack builder (mobile/test/packs/build_pack_test.dart) writes the
// whole pack; scripts/publish-pack.mjs gives it its version, splits it by
// chapter and publishes it here.

const PACKS_DIR = path.join(__dirname, 'packs');
const FORMAT = 2; // the pack layout; see mobile/lib/features/packs/game_types.dart
const EXAM = /^[a-z0-9]+(-[a-z0-9]+)*$/;
const VERSION = /^\d+\.\d+\.\d+$/;
const FILE = /^([a-z0-9-]+)-v(\d+)-([a-f0-9]{12})\.json$/;
const CHAPTER_FILE = /^([a-z0-9-]+)\.([a-z0-9-]+)\.([a-f0-9]{12})\.json$/;

const sha256 = (text) => crypto.createHash('sha256').update(text).digest('hex');
const fileName = (exam, version, hash) => `${exam}-v${version}-${hash.slice(0, 12)}.json`;
const chapterFileName = (exam, chapter, hash) => `${exam}.${chapter}.${hash.slice(0, 12)}.json`;
const gzipBytes = (text) => zlib.gzipSync(text).length;

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

// One chapter's file: its games, in the order the pack lists them, and
// nothing about the version, so an unchanged chapter is the same file.
function chapterText(pack, chapter) {
  const games = Object.fromEntries(Object.entries(pack.games).filter(([, g]) => g.chapter === chapter));
  return JSON.stringify({ format: pack.format, exam: pack.exam, chapter, games });
}

// The chapters a pack's lessons are in, in the order they first appear.
const chaptersOf = (pack) => [...new Set(Object.keys(pack.lessons).map((id) => id.split('/')[0]))];

// The pack split for publishing: each chapter's file, and the index that
// makes them a version.
function splitPack(pack, version) {
  const chapters = chaptersOf(pack).map((chapter) => {
    const text = chapterText(pack, chapter);
    const hash = sha256(text);
    return { chapter, file: chapterFileName(pack.exam, chapter, hash), sha256: hash, text, bytes: Buffer.byteLength(text), gzipBytes: gzipBytes(text) };
  });
  const { format, exam, title, lessons } = pack;
  const index = JSON.stringify({
    format,
    exam,
    title,
    version,
    lessons,
    chapters: Object.fromEntries(chapters.map((c) => [c.chapter, { file: c.file, sha256: c.sha256, bytes: c.bytes }])),
  });
  return { index, chapters };
}

// A version's content without its number, to tell whether anything changed.
const sameContent = (index, otherIndex) => {
  const strip = (text) => ({ ...JSON.parse(text), version: 0 });
  return JSON.stringify(strip(index)) === JSON.stringify(strip(otherIndex));
};

// Works out what publishing [pack] adds, given the exam's manifest and the
// text of its latest published version (both null for a first publish).
// Returns { unchanged: true } when nothing changed, otherwise
// { file, text, chapters, manifest }: the index to write, every chapter's
// file (the publisher writes those not already there) and the new manifest.
function preparePublish(pack, manifest, latestText, published = new Date().toISOString()) {
  const problems = packProblems(pack);
  if (problems.length) throw new Error(`Pack not published:\n- ${problems.join('\n- ')}`);
  if (manifest && manifest.exam !== pack.exam) throw new Error(`Manifest is for ${manifest.exam}, pack is ${pack.exam}`);
  const latest = manifest?.latest;
  if (latest && latestText && (latest.format || 1) === FORMAT && sameContent(splitPack(pack, 0).index, latestText)) {
    return { unchanged: true, version: latest.version };
  }

  const version = (latest?.version || 0) + 1;
  const { index, chapters } = splitPack(pack, version);
  const hash = sha256(index);
  const file = fileName(pack.exam, version, hash);
  const entry = {
    version,
    format: FORMAT,
    file,
    sha256: hash,
    // What a phone with nothing would fetch: the index and every chapter.
    bytes: Buffer.byteLength(index) + chapters.reduce((n, c) => n + c.bytes, 0),
    gzipBytes: gzipBytes(index) + chapters.reduce((n, c) => n + c.gzipBytes, 0),
    published,
    lessons: Object.fromEntries(Object.entries(pack.lessons).map(([id, l]) => [id, l.minApp])),
    chapters: Object.fromEntries(chapters.map((c) => [c.chapter, { file: c.file, sha256: c.sha256, gzipBytes: c.gzipBytes }])),
  };
  const next = {
    exam: pack.exam,
    title: pack.title,
    format: FORMAT,
    latest: entry,
    versions: [...(manifest?.versions || []), { version, format: FORMAT, file, sha256: hash, published }],
  };
  return { file, text: index, chapters, manifest: next };
}

// Every file a manifest makes public: each version, and since format 2 the
// chapter files its index names. Read from [dir]/<exam>/.
function publishedFiles(manifest, dir = PACKS_DIR) {
  const files = new Set();
  for (const v of manifest.versions) {
    files.add(v.file);
    if ((v.format || 1) >= 2) {
      const index = JSON.parse(fs.readFileSync(path.join(dir, manifest.exam, v.file), 'utf8'));
      for (const c of Object.values(index.chapters)) files.add(c.file);
    }
  }
  return files;
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

module.exports = { PACKS_DIR, FORMAT, FILE, CHAPTER_FILE, sha256, fileName, chapterFileName, packProblems, splitPack, preparePublish, publishedFiles, loadManifests };
