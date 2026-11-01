// A sample /api/league answer for reviewing the design without a league of
// your own. Dev only: add ?leagueMock=1 (joined), ?leagueMock=join (not
// joined yet), or ?leagueMock=up|down|stayed (last week's result) to the
// dashboard URL. Same shape as the real answer (service/routes/league.js).
const NAMES = ['Sweet D.', 'Mohammad A.', 'Kasie N.', 'Jackson H.', 'Meagan', 'Liz', 'Nicholas K.', 'Izzy T.', 'Ermi', 'A student', 'Devon R.', 'sal***', 'Priya S.', 'Tom B.'];
const XP = [1840, 1525, 1310, 1240, 1105, 980, 870, 760, 640, 515, 420, 310, 185, 90];
const MOVE = ['up', 'down', null, 'up', 'down', 'up', 'new', 'up', null, 'down', 'new', 'up', 'down', 'new', null];
const DAYS = [6, 5, 5, 4, 4, 5, 3, 4, 3, 3, 2, 2, 2, 1, 1];

const RESULTS = {
  up: { tier: 'bronze', tierName: 'Bronze', place: 3, moved: 'up' },
  down: { tier: 'gold', tierName: 'Gold', place: 14, moved: 'down' },
  stayed: { tier: 'silver', tierName: 'Silver', place: 8, moved: 'stayed' },
};

export function leagueMock() {
  if (!import.meta.env.DEV) return null;
  const mode = new URLSearchParams(window.location.search).get('leagueMock');
  if (!mode) return null;
  const rows = NAMES.map((name, i) => ({ name, xp: XP[i], isMe: false }));
  rows.splice(3, 0, { name: 'Jerson G.', xp: 1290, isMe: true });
  rows.sort((a, b) => b.xp - a.xp);
  const result = RESULTS[mode === 'result' ? 'up' : mode];
  return {
    tier: 'silver', tierName: 'Silver',
    nextTier: 'gold', nextTierName: 'Gold', prevTier: 'bronze', prevTierName: 'Bronze',
    weekId: '2026-W45', weekEndsAt: '2026-11-08T08:00:00.000Z',
    joined: mode !== 'join',
    hidden: false,
    rows: mode === 'join' ? [] : rows.map((r, i) => ({ ...r, place: i + 1, move: MOVE[i], days: DAYS[i] })),
    zones: { promote: 5, demote: 3 },
    lastResult: result ? { weekId: '2026-W44', size: 15, xp: 1180, newTier: 'silver', newTierName: 'Silver', ...result } : null,
    mock: true,
  };
}
