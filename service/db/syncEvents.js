const { ObjectId } = require('mongodb');
const { reviewEventsCollection } = require('./connection');

// The append-only review-event log — the shared source of truth for progress
// sync (docs/mobile/sync-design.md). Events are immutable; state (schedules,
// streak, mastery) is DERIVED from them, never synced directly.
//
// Event shape: { email, eventId (client uuid — idempotency key), itemId,
// chapterId, grade ('forgot'|'fuzzy'|'gotIt'), source ('web'|'ios'|'android'),
// deviceId, ts (epoch ms), localDate ('YYYY-MM-DD' in the CLIENT's timezone —
// streak credit always uses this, so an offline Tuesday synced Wednesday
// still counts Tuesday), receivedAt }

/**
 * Insert events idempotently (unique on email+eventId). Returns the events
 * that were actually NEW — ingest side-effects must only run for those.
 */
async function insertReviewEvents(email, events) {
  if (!events.length) return [];
  const docs = events.map((e) => ({
    email,
    eventId: e.eventId,
    itemId: e.itemId,
    chapterId: e.chapterId,
    grade: e.grade,
    source: e.source,
    deviceId: e.deviceId || null,
    ts: e.ts,
    localDate: e.localDate,
    receivedAt: new Date(),
  }));
  try {
    const res = await reviewEventsCollection.insertMany(docs, { ordered: false });
    return docs.filter((_, i) => res.insertedIds[i] !== undefined);
  } catch (err) {
    // Duplicate eventIds (retried push) are expected — keep only what landed.
    if (err.code === 11000 || err.writeErrors) {
      const dupIdx = new Set((err.writeErrors || []).map((w) => w.index));
      return docs.filter((_, i) => !dupIdx.has(i));
    }
    throw err;
  }
}

/** Events newer than the cursor (a stringified _id), oldest first, capped. */
async function getReviewEventsSince(email, sinceId, limit = 500) {
  const query = { email };
  if (sinceId) {
    try {
      query._id = { $gt: new ObjectId(sinceId) };
    } catch {
      // bad cursor → full replay from the start
    }
  }
  const rows = await reviewEventsCollection.find(query).sort({ _id: 1 }).limit(limit).toArray();
  return {
    events: rows.map((r) => ({
      eventId: r.eventId,
      itemId: r.itemId,
      chapterId: r.chapterId,
      grade: r.grade,
      source: r.source,
      deviceId: r.deviceId,
      ts: r.ts,
      localDate: r.localDate,
    })),
    cursor: rows.length ? String(rows[rows.length - 1]._id) : sinceId || null,
  };
}

/** Today's phone work (non-web events for a local date) — the dashboard line. */
async function getPhoneActivity(email, localDate) {
  const rows = await reviewEventsCollection
    .find({ email, localDate, source: { $ne: 'web' } })
    .project({ chapterId: 1, ts: 1, grade: 1, itemId: 1 })
    .toArray();
  const chapters = {};
  const missedParents = new Map();
  let misses = 0;
  let lastTs = 0;
  for (const r of rows) {
    chapters[r.chapterId] = (chapters[r.chapterId] || 0) + 1;
    if (r.grade === 'forgot') {
      misses++;
      const parent = String(r.itemId || '').split(':')[0];
      if (parent) missedParents.set(parent, r.chapterId);
    }
    if (r.ts > lastTs) lastTs = r.ts;
  }
  return {
    cards: rows.length,
    misses,
    chapters,
    lastTs: lastTs || null,
    // tonight's desk queue: the concepts the phone exposed as weak
    missed: [...missedParents].map(([problemId, chapterId]) => ({ problemId, chapterId })),
  };
}

/** Grade tallies for a local day's phone events (XP cap accounting). */
async function getPhoneGradeCounts(email, localDate) {
  const rows = await reviewEventsCollection
    .find({ email, localDate, source: { $ne: 'web' } })
    .project({ grade: 1 })
    .toArray();
  const counts = { gotIt: 0, fuzzy: 0, forgot: 0 };
  for (const r of rows) if (counts[r.grade] !== undefined) counts[r.grade]++;
  return counts;
}

module.exports = { insertReviewEvents, getReviewEventsSince, getPhoneActivity, getPhoneGradeCounts };
