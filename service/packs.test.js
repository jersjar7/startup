import { describe, it, expect } from 'vitest';
const fs = require('fs');
const os = require('os');
const path = require('path');
const express = require('express');
const request = require('supertest');
const { PACKS_DIR, FILE, sha256, packProblems, preparePublish, loadManifests } = require('./packs.js');
const packsRouter = require('./routes/packs.js');

// Content packs (ADR 0030, phase 1): the publish rules, the routes, and the
// promise that a published version never changes.

const built = () => ({
  format: 1,
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
    p.format = 2;
    p.lessons['statics/trusses'].minApp = 'soon';
    p.lessons['ethics/duties'].games.push('zero-force', 'missing');
    p.games.lost = { id: 'lost', type: 'pick-one', chapter: 'ethics' };
    expect(packProblems(p)).toEqual([
      'format 2, expected 1',
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

  it('starts at version 1 and names the file by its content', () => {
    const r = preparePublish(built(), null, null, when);
    expect(r.file).toMatch(FILE);
    expect(r.file).toBe(`fe-test-v1-${sha256(r.text).slice(0, 12)}.json`);
    expect(JSON.parse(r.text).version).toBe(1);
    expect(r.manifest.latest).toMatchObject({
      version: 1,
      file: r.file,
      bytes: Buffer.byteLength(r.text),
      published: when,
      lessons: { 'statics/trusses': '1.2.0', 'ethics/duties': '1.3.0' },
    });
    expect(r.manifest.versions).toHaveLength(1);
  });

  it('does nothing when the content has not changed', () => {
    const first = preparePublish(built(), null, null, when);
    const again = preparePublish(built(), first.manifest, JSON.parse(first.text));
    expect(again).toEqual({ unchanged: true, version: 1 });
  });

  it('makes a change a new version in a new file, keeping the old one listed', () => {
    const first = preparePublish(built(), null, null, when);
    const p = built();
    p.games['who-first'].title = 'Who First';
    const second = preparePublish(p, first.manifest, JSON.parse(first.text));
    expect(second.manifest.latest.version).toBe(2);
    expect(second.file).not.toBe(first.file);
    expect(second.manifest.versions.map((v) => v.file)).toEqual([first.file, second.file]);
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
  const v2 = preparePublish(changed, v1.manifest, JSON.parse(v1.text));
  fs.mkdirSync(path.join(dir, 'fe-test'));
  for (const r of [v1, v2]) fs.writeFileSync(path.join(dir, 'fe-test', r.file), r.text);
  fs.writeFileSync(path.join(dir, 'fe-test', 'manifest.json'), JSON.stringify(v2.manifest));
  fs.writeFileSync(path.join(dir, 'fe-test', 'notes.json'), '{"secret":1}');

  const app = express();
  app.use('/api/packs', packsRouter(dir));

  it('lists each exam with its latest version and download size', async () => {
    const res = await request(app).get('/api/packs');
    expect(res.status).toBe(200);
    expect(res.headers['cache-control']).toBe('public, no-cache');
    expect(res.body).toEqual([
      { exam: 'fe-test', title: 'FE Test, revised', format: 1, version: 2, gzipBytes: v2.manifest.latest.gzipBytes },
    ]);
  });

  it('gives an exam its latest version and every lesson\'s oldest app', async () => {
    const res = await request(app).get('/api/packs/fe-test');
    expect(res.status).toBe(200);
    expect(res.headers['cache-control']).toBe('public, no-cache');
    expect(res.headers.etag).toBeTruthy();
    expect(res.body).toMatchObject({ exam: 'fe-test', version: 2, file: v2.file });
    expect(res.body.lessons['ethics/duties']).toBe('1.3.0');

    const again = await request(app).get('/api/packs/fe-test').set('If-None-Match', res.headers.etag);
    expect(again.status).toBe(304);
  });

  it('serves a published version, old or new, cached forever', async () => {
    for (const r of [v1, v2]) {
      const res = await request(app).get(`/api/packs/fe-test/${r.file}`);
      expect(res.status).toBe(200);
      expect(res.headers['cache-control']).toBe('public, max-age=31536000, immutable');
      expect(res.headers['content-type']).toMatch(/application\/json/);
      expect(sha256(res.text)).toBe(JSON.parse(r.text).version === 1 ? v1.manifest.latest.sha256 : v2.manifest.latest.sha256);
    }
  });

  it('serves nothing the manifest does not list', async () => {
    for (const url of [
      '/api/packs/pe-water',
      '/api/packs/fe-test/notes.json',
      '/api/packs/fe-test/manifest.json',
      '/api/packs/fe-test/fe-test-v9-000000000000.json',
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
    it(`${exam}: every version is still there, unchanged`, () => {
      expect(m.exam).toBe(exam);
      expect(m.versions.map((v) => v.version)).toEqual(m.versions.map((_, i) => i + 1));
      for (const v of m.versions) {
        const text = fs.readFileSync(path.join(PACKS_DIR, exam, v.file), 'utf8');
        expect(sha256(text), v.file).toBe(v.sha256);
        expect(v.file).toBe(`${exam}-v${v.version}-${v.sha256.slice(0, 12)}.json`);
        expect(JSON.parse(text).version).toBe(v.version);
      }
      expect(m.versions.at(-1)).toMatchObject({ version: m.latest.version, file: m.latest.file, sha256: m.latest.sha256 });
    });

    it(`${exam}: the latest version is sound and matches its manifest`, () => {
      const pack = JSON.parse(fs.readFileSync(path.join(PACKS_DIR, exam, m.latest.file), 'utf8'));
      expect(packProblems(pack)).toEqual([]);
      expect(m.latest.lessons).toEqual(Object.fromEntries(Object.entries(pack.lessons).map(([id, l]) => [id, l.minApp])));
    });

    it(`${exam}: no file in the folder that the manifest does not list`, () => {
      const listed = new Set(['manifest.json', ...m.versions.map((v) => v.file)]);
      expect(fs.readdirSync(path.join(PACKS_DIR, exam)).filter((f) => !listed.has(f))).toEqual([]);
    });
  }
});
