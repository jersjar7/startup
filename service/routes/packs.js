const express = require('express');
const path = require('path');
const { PACKS_DIR, FILE, CHAPTER_FILE, loadManifests, publishedFiles } = require('../packs.js');

// Content packs for the phone (ADR 0030). Public, like /content: packs are
// study material a guest may use (ADR 0026). Read once at startup; a newly
// published pack goes live with the next deploy.
//
// GET /api/packs                 every exam with a pack, and its latest version
// GET /api/packs/:exam           that exam's latest version, file and lessons
// GET /api/packs/:exam/:file     one published version or chapter file, cached forever

function packsRouter(dir = PACKS_DIR) {
  const router = express.Router();
  const manifests = loadManifests(dir);
  // Every file each exam's manifest makes public, worked out once.
  const served = Object.fromEntries(Object.entries(manifests).map(([exam, m]) => [exam, publishedFiles(m, dir)]));

  // The phone asks often and must see a new version promptly, so it always
  // revalidates; an unchanged manifest costs a 304.
  const FRESH = 'public, no-cache';
  // A published file never changes, so it never needs asking about again.
  const FOREVER = 'public, max-age=31536000, immutable';

  router.get('/', (req, res) => {
    res.set('Cache-Control', FRESH);
    res.json(Object.values(manifests).map((m) => ({
      exam: m.exam,
      title: m.title,
      format: m.format,
      version: m.latest.version,
      gzipBytes: m.latest.gzipBytes,
    })));
  });

  router.get('/:exam', (req, res) => {
    const m = manifests[req.params.exam];
    if (!m) {
      res.status(404).send({ msg: 'No such exam' });
      return;
    }
    const { exam, title, format, latest } = m;
    res.set('Cache-Control', FRESH);
    res.json({ exam, title, format, ...latest });
  });

  router.get('/:exam/:file', (req, res) => {
    const m = manifests[req.params.exam];
    const name = req.params.file;
    // Only files the manifest lists, or a listed version's index names, so
    // nothing else in the folder is reachable.
    if (!m || !(FILE.test(name) || CHAPTER_FILE.test(name)) || !served[m.exam].has(name)) {
      res.status(404).send({ msg: 'No such pack' });
      return;
    }
    res.set('Cache-Control', FOREVER);
    res.type('application/json').sendFile(path.join(dir, m.exam, name));
  });

  return router;
}

module.exports = packsRouter;
