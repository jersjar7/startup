const express = require('express');
const { channelOf, pageOf, isBot, dayOf } = require('../visits.js');

// POST /api/visit   one visit to the website, sent once per browser session
//
// Body: { path, referrer, utmSource, returning }. Adds one to that day's
// counter for the page and channel, and to its new-visitor counter unless the
// browser has been here before. Stores no cookie, IP, user agent or account.
// Always answers 204: counting must never slow or break a page.
function visitRouter(counts = require('../db/connection.js').visitCountsCollection, now = () => new Date()) {
  const router = express.Router();

  router.post('/', async (req, res) => {
    res.status(204).end();
    if (isBot(req.get('user-agent'))) return;
    const b = req.body && typeof req.body === 'object' ? req.body : {};
    const day = dayOf(now());
    const path = pageOf(b.path);
    const channel = channelOf({ utmSource: b.utmSource, referrer: b.referrer });
    try {
      await counts.updateOne(
        { _id: `${day}|${path}|${channel}` },
        { $set: { day, path, channel }, $inc: { visits: 1, newVisitors: b.returning === true ? 0 : 1 } },
        { upsert: true },
      );
    } catch (e) {
      console.error('[visit] count failed:', e.message);
    }
  });

  return router;
}

module.exports = visitRouter;
