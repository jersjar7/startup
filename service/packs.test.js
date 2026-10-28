import { describe, it, expect } from 'vitest';
const fs = require('fs');
const os = require('os');
const path = require('path');
const express = require('express');
const request = require('supertest');
const { PACKS_DIR, FILE, CHAPTER_FILE, sha256, packProblems, preparePublish, publishedFiles, loadManifests } = require('./packs.js');
const packsRouter = require('./routes/packs.js');

// Content packs (ADR 0030, phase 1; one file per chapter since ADR 0033):
// the publish rules, the routes, and the promise that a published file
// never changes.

const built = () => ({
  format: 2,
  exam: 'fe-test',
  title: 'FE Test',
  lessons: {
    'statics/trusses': { minApp: '1.2.0', games: ['zero-force'] },
    'ethics/duties': { minApp: '1.3.0', games: ['in-order', 'who-first'] },
  },
  games: {
    'zero-force': { id: 'zero-force', type: 'tap-figure', chapter: 'statics' },
    'in-order': { id: 'in-order', type: 'order', chapter: 'ethics' },
    'who-first': { id: 'who-first', type: 'pick-one', chapter: 'ethics' },
  },
});

describe('a built pack is checked before it is published', () => {
  it('accepts a sound pack', () => {
    expect(packProblems(built())).toEqual([]);
  });

  it('names every problem in plain words', () => {
    const p = built();
    p.format = 1;
    p.lessons['statics/trusses'].minApp = 'soon';
    p.lessons['ethics/duties'].games.push('zero-force', 'missing');
    p.games.lost = { id: 'lost', type: 'pick-one', chapter: 'ethics' };
    expect(packProblems(p)).toEqual([
      'format 1, expected 2',
      'statics/trusses: bad minApp "soon"',
      'game "zero-force" is in both statics/trusses and ethics/duties',
      'ethics/duties: game "missing" is not in the pack',
      'game "zero-force" says chapter "statics", its lesson is in "ethics"',
      'game "lost" is in no lesson',
    ]);
  });

  it('refuses to publish a pack with problems', () => {
    const p = built();
    delete p.games['who-first'];
    expect(() => preparePublish(p, null, null)).toThrow(/not in the pack/);
  });
});

describe('publishing', () => {
  const when = '2026-10-26T12:00:00.000Z';
  const write = (dir, r) => {
    for (const c of r.chapters) if (!fs.existsSync(path.join(dir, c.file))) fs.writeFileSync(path.join(dir, c.file), c.text);
    fs.writeFileSync(path.join(dir, r.file), r.text);
  };

  it('starts at version 1, as an index and one file per chapter, each named by its content', () => {
    const r = preparePublish(built(), null, null, when);
    expect(r.file).toMatch(FILE);
    expect(r.file).toBe(`fe-test-v1-${sha256(r.text).slice(0, 12)}.json`);
    const index = JSON.parse(r.text);
    expect(index).toMatchObject({ format: 2, exam: 'fe-test', title: 'FE Test', version: 1, lessons: built().lessons });
    expect(index.games).toBeUndefined();
    expect(Object.keys(index.chapters)).toEqual(['statics', 'ethics']);
    for (const c of r.chapters) {
      expect(c.file).toMatch(CHAPTER_FILE);
      expect(c.file).toBe(`fe-test.${c.chapter}.${sha256(c.text).slice(0, 12)}.json`);
      expect(index.chapters[c.chapter]).toEqual({ file: c.file, sha256: sha256(c.text), bytes: Buffer.byteLength(c.text) });
    }
    expect(JSON.parse(r.chapters[1].text)).toEqual({
      format: 2,
      exam: 'fe-test',
      chapter: 'ethics',
      games: { 'in-order': built().games['in-order'], 'who-first': built().games['who-first'] },
    });
    expect(r.manifest.latest).toMatchObject({
      version: 1,
      format: 2,
      file: r.file,
      bytes: Buffer.byteLength(r.text) + r.chapters.reduce((n, c) => n + Buffer.byteLength(c.text), 0),
      published: when,
      lessons: { 'statics/trusses': '1.2.0', 'ethics/duties': '1.3.0' },
    });
    expect(r.manifest.latest.chapters.ethics.file).toBe(r.chapters[1].file);
    expect(r.manifest.versions).toEqual([{ version: 1, format: 2, file: r.file, sha256: sha256(r.text), published: when }]);
  });

  it('does nothing when the content has not changed', () => {
    const first = preparePublish(built(), null, null, when);
    const again = preparePublish(built(), first.manifest, first.text);
    expect(again).toEqual({ unchanged: true, version: 1 });
  });

  it('makes a change a new version that reuses every chapter it leaves alone', () => {
    const first = preparePublish(built(), null, null, when);
    const p = built();
    p.games['who-first'].title = 'Who First';
    const second = preparePublish(p, first.manifest, first.text);
    expect(second.manifest.latest.version).toBe(2);
    expect(second.file).not.toBe(first.file);
    expect(second.manifest.versions.map((v) => v.file)).toEqual([first.file, second.file]);
    const files = (r) => Object.fromEntries(r.chapters.map((c) => [c.chapter, c.file]));
    expect(files(second).statics).toBe(files(first).statics);
    expect(files(second).ethics).not.toBe(files(first).ethics);
  });

  it('publishes a new version over a format 1 one, even with the same games', () => {
    const old = { version: 1, format: 1, file: 'fe-test-v1-000000000000.json', sha256: '0'.repeat(64) };
    const manifest = { exam: 'fe-test', title: 'FE Test', format: 1, latest: old, versions: [old] };
    const r = preparePublish(built(), manifest, JSON.stringify({ ...built(), format: 1, version: 1 }), when);
    expect(r.manifest.latest).toMatchObject({ version: 2, format: 2 });
    expect(r.manifest.versions.map((v) => v.format)).toEqual([1, 2]);
  });

  it('serves exactly the versions and the chapter files they name', () => {
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'packs-'));
    fs.mkdirSync(path.join(dir, 'fe-test'));
    const first = preparePublish(built(), null, null, when);
    const p = built();
    p.games['who-first'].title = 'Who First';
    const second = preparePublish(p, first.manifest, first.text);
    write(path.join(dir, 'fe-test'), first);
    write(path.join(dir, 'fe-test'), second);
    expect([...publishedFiles(second.manifest, dir)].sort()).toEqual(
      [...new Set([first.file, second.file, ...first.chapters.map((c) => c.file), ...second.chapters.map((c) => c.file)])].sort(),
    );
    expect(fs.readdirSync(path.join(dir, 'fe-test'))).toHaveLength(5);
  });

  it('will not mix exams', () => {
    const first = preparePublish(built(), null, null, when);
    const other = { ...built(), exam: 'pe-water' };
    expect(() => preparePublish(other, first.manifest, null)).toThrow(/Manifest is for fe-test/);
  });
});

describe('the routes', () => {
  // A packs folder of its own, holding two versions of one exam.
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'packs-'));
  const v1 = preparePublish(built(), null, null);
  const changed = built();
  changed.title = 'FE Test, revised';
  changed.games['who-first'].title = 'Who First';
  const v2 = preparePublish(changed, v1.manifest, v1.text);
  fs.mkdirSync(path.join(dir, 'fe-test'));
  for (const r of [v1, v2]) {
    fs.writeFileSync(path.join(dir, 'fe-test', r.file), r.text);
    for (const c of r.chapters) fs.writeFileSync(path.join(dir, 'fe-test', c.file), c.text);
  }
  fs.writeFileSync(path.join(dir, 'fe-test', 'manifest.json'), JSON.stringify(v2.manifest));
  fs.writeFileSync(path.join(dir, 'fe-test', 'notes.json'), '{"secret":1}');

  const app = express();
  app.use('/api/packs', packsRouter(dir));

  it('lists each exam with its latest version and download size', async () => {
    const res = await request(app).get('/api/packs');
    expect(res.status).toBe(200);
    expect(res.headers['cache-control']).toBe('public, no-cache');
    expect(res.body).toEqual([
      { exam: 'fe-test', title: 'FE Test, revised', format: 2, version: 2, gzipBytes: v2.manifest.latest.gzipBytes },
    ]);
  });

  it('gives an exam its latest version and every lesson\'s oldest app', async () => {
    const res = await request(app).get('/api/packs/fe-test');
    expect(res.status).toBe(200);
    expect(res.headers['cache-control']).toBe('public, no-cache');
    expect(res.headers.etag).toBeTruthy();
    expect(res.body).toMatchObject({ exam: 'fe-test', format: 2, version: 2, file: v2.file });
    expect(res.body.lessons['ethics/duties']).toBe('1.3.0');
    expect(res.body.chapters.ethics.file).toBe(v2.chapters[1].file);

    const again = await request(app).get('/api/packs/fe-test').set('If-None-Match', res.headers.etag);
    expect(again.status).toBe(304);
  });

  it('serves a published version or chapter file, old or new, cached forever', async () => {
    const files = [v1, v2].flatMap((r) => [{ file: r.file, text: r.text }, ...r.chapters]);
    for (const { file, text } of files) {
      const res = await request(app).get(`/api/packs/fe-test/${file}`);
      expect(res.status, file).toBe(200);
      expect(res.headers['cache-control']).toBe('public, max-age=31536000, immutable');
      expect(res.headers['content-type']).toMatch(/application\/json/);
      expect(res.text).toBe(text);
    }
  });

  it('serves nothing the manifest does not list', async () => {
    for (const url of [
      '/api/packs/pe-water',
      '/api/packs/fe-test/notes.json',
      '/api/packs/fe-test/manifest.json',
      '/api/packs/fe-test/fe-test-v9-000000000000.json',
      '/api/packs/fe-test/fe-test.statics.000000000000.json',
      '/api/packs/fe-test/..%2F..%2Fpackage.json',
    ]) {
      const r = await request(app).get(url); expect(r.status, `${url} ${r.text}`).toBe(404);
    }
  });
});

describe('the packs we publish', () => {
  const manifests = loadManifests();

  it('exist, starting with FE Civil', () => {
    expect(Object.keys(manifests)).toContain('fe-civil');
  });

  for (const [exam, m] of Object.entries(manifests)) {
    const read = (file) => fs.readFileSync(path.join(PACKS_DIR, exam, file), 'utf8');

    it(`${exam}: every version is still there, unchanged`, () => {
      expect(m.exam).toBe(exam);
      expect(m.versions.map((v) => v.version)).toEqual(m.versions.map((_, i) => i + 1));
      for (const v of m.versions) {
        const text = read(v.file);
        expect(sha256(text), v.file).toBe(v.sha256);
        expect(v.file).toBe(`${exam}-v${v.version}-${v.sha256.slice(0, 12)}.json`);
        const index = JSON.parse(text);
        expect(index.version).toBe(v.version);
        expect(index.format).toBe(v.format || 1);
        // A chapter file is checked against the hash its index gives it.
        for (const [chapter, c] of Object.entries(index.chapters || {})) {
          expect(c.file).toBe(`${exam}.${chapter}.${c.sha256.slice(0, 12)}.json`);
          expect(sha256(read(c.file)), c.file).toBe(c.sha256);
        }
      }
      expect(m.versions.at(-1)).toMatchObject({ version: m.latest.version, file: m.latest.file, sha256: m.latest.sha256 });
      // Every version is read and hashed, and the format 1 ones are big
      // (FE Civil's are past 400 MB), so this gets more than the default 5 seconds.
    }, 120_000);

    it(`${exam}: the latest version is sound and matches its manifest`, () => {
      const index = JSON.parse(read(m.latest.file));
      expect(index.format).toBe(2);
      // Put back together, the chapters are the pack the builder wrote.
      const games = {};
      for (const [chapter, c] of Object.entries(index.chapters)) {
        const part = JSON.parse(read(c.file));
        expect(part).toMatchObject({ format: 2, exam, chapter });
        Object.assign(games, part.games);
      }
      const { format, title, lessons } = index;
      expect(packProblems({ format, exam, title, lessons, games })).toEqual([]);
      expect(m.latest.lessons).toEqual(Object.fromEntries(Object.entries(lessons).map(([id, l]) => [id, l.minApp])));
      expect(Object.fromEntries(Object.entries(m.latest.chapters).map(([ch, c]) => [ch, c.file])))
        .toEqual(Object.fromEntries(Object.entries(index.chapters).map(([ch, c]) => [ch, c.file])));
    }, 30_000);

    it(`${exam}: no file in the folder that the manifest does not list`, () => {
      const listed = new Set(['manifest.json', ...publishedFiles(m)]);
      expect(fs.readdirSync(path.join(PACKS_DIR, exam)).filter((f) => !listed.has(f))).toEqual([]);
    });
  }
});
