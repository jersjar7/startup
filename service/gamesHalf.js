// The games half of chapter mastery.
//
// Owner's decision (2026-09-20, docs/mobile/sync-audit.md fix 2): a chapter's
// mastery is one number with two halves. The desk half is the study curve
// from website work, 0 to 100. The games half is 50 times the share of the
// chapter's games the student has cleared on the phone, 0 to 50, so the
// hand-off ("games have taken this chapter as far as they can") fires exactly
// when the last game is cleared. The number is the smaller of 100 and the
// sum. This replaces the old cap on phone-only evidence: phone rounds no
// longer count as problem evidence at all.
//
// A game is cleared when the phone's events cover every one of its rounds
// with a right answer. Events name the round: itemId is
// `<problemId>:<gameId>:<round>` (mobile game_sync.dart), round 1-based.

const catalog = require('./gameCatalog.json'); // {chapterId: {gameId: rounds}}

const GAMES_HALF_MAX = 50;

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
function gamesHalf(chapterId, cleared) {
  const total = Object.keys(gamesIn(chapterId)).length;
  if (total === 0) return 0;
  return Math.round((GAMES_HALF_MAX * cleared.length) / total);
}

module.exports = { GAMES_HALF_MAX, gamesIn, parseGameItem, clearedGames, gamesHalf };
