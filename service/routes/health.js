const express = require('express');
const router = express.Router();
const DB = require('../database.js');

router.get('/health', async (_req, res) => {
  try {
    await DB.ping();
    res.send({ status: 'ok', timestamp: new Date().toISOString() });
  } catch {
    res.status(503).send({ status: 'error', msg: 'Database unreachable' });
  }
});

module.exports = router;
