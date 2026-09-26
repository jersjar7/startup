// Which of a chapter's games the phone has cleared.
//
// Games are a warm-up (ADR 0020, 2026-09-25): the count is shown on both
// surfaces and never enters the mastery number. A round on the phone is not
// problem evidence either.
//
// A game is cleared when the phone's events cover every one of its rounds
// with a right answer. Events name the round: itemId is
// `<problemId>:<gameId>:<round>` (mobile game_sync.dart), round 1-based.

const catalog = require('./gameCatalog.json'); // {chapterId: {gameId: rounds}}


/** The games of one chapter, {gameId: rounds}; empty for an unknown chapter. */
function gamesIn(chapterId) {
  return catalog[chapterId] || {};
}

/** Parses `<problemId>:<gameId>:<round>`; null for anything else (cards, web). */
function parseGameItem(itemId) {
  const parts = String(itemId || '').split(':');
  if (parts.length !== 3) return null;
  const round = Number(parts[2]);
  if (!Number.isInteger(round) || round < 1) return null;
  return { problemId: parts[0], gameId: parts[1], round };
}

/**
 * Which of a chapter's games are cleared, from that chapter's phone events
 * (any source but web). Returns a sorted array of game ids.
 */
function clearedGames(chapterId, events) {
  const games = gamesIn(chapterId);
  const rounds = new Map();
  for (const e of events) {
    if (e.source === 'web' || e.grade === 'forgot') continue;
    const item = parseGameItem(e.itemId);
    if (!item || !(item.gameId in games)) continue;
    if (!rounds.has(item.gameId)) rounds.set(item.gameId, new Set());
    rounds.get(item.gameId).add(item.round);
  }
  return [...rounds.entries()]
    .filter(([id, done]) => done.size >= games[id])
    .map(([id]) => id)
    .sort();
}

/** 50 times the share of the chapter's games cleared, rounded. */

module.exports = { gamesIn, parseGameItem, clearedGames };
