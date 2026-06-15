const { paperFlagsCollection } = require('./connection');

// Problems the phone set aside for the desk — the honest "grab paper" hand-off.
// A per-day to-do list that surfaces on the web "Tonight" card so the two
// surfaces are one product, not two to-do lists sharing a login. Idempotent per
// (email, itemId, localDate): re-flagging the same problem the same day is one
// entry. Stored by PARENT problem id so it matches the web's question pools.

const parentId = (itemId) => String(itemId).split(':')[0];

async function upsertPaperFlags(email, flags) {
  if (!flags.length) return 0;
  const ops = flags.map((f) => {
    const itemId = parentId(f.itemId);
    return {
      updateOne: {
        filter: { email, itemId, localDate: f.localDate },
        update: {
          $set: {
            email,
            itemId,
            chapterId: f.chapterId,
            statement: typeof f.statement === 'string' ? f.statement.slice(0, 400) : null,
            source: f.source,
            localDate: f.localDate,
            ts: f.ts,
            flaggedAt: new Date(),
          },
        },
        upsert: true,
      },
    };
  });
  const res = await paperFlagsCollection.bulkWrite(ops, { ordered: false });
  return (res.upsertedCount || 0) + (res.modifiedCount || 0);
}

// Today's set-aside-for-paper problems, for the web Tonight card.
async function getPaperFlagsForDay(email, localDate) {
  const rows = await paperFlagsCollection
    .find({ email, localDate })
    .project({ itemId: 1, chapterId: 1, statement: 1 })
    .toArray();
  return rows.map((r) => ({ problemId: r.itemId, chapterId: r.chapterId, statement: r.statement || null }));
}

module.exports = { upsertPaperFlags, getPaperFlagsForDay };
