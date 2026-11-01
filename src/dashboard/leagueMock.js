// Sample league for reviewing the design before the API exists. Dev only:
// add ?leagueMock=1 (joined), ?leagueMock=join (not joined yet) or
// ?leagueMock=result (Sunday result) to the dashboard URL.
const NAMES = ['Sweet D.', 'Mohammad A.', 'Kasie N.', 'Jackson H.', 'Meagan', 'Liz', 'Nicholas K.', 'Izzy T.', 'Ermi', 'A student', 'Devon R.', 'sal***', 'Priya S.', 'Tom B.'];
const XP = [1840, 1525, 1310, 1240, 1105, 980, 870, 760, 640, 515, 420, 310, 185, 90];
const MOVE = ['up', 'down', null, 'up', 'down', 'up', 'new', 'up', null, 'down', 'new', 'up', 'down', 'new', null];
const DAYS = [6, 5, 5, 4, 4, 5, 3, 4, 3, 3, 2, 2, 2, 1, 1];

export function leagueMock() {
  if (!import.meta.env.DEV) return null;
  const mode = new URLSearchParams(window.location.search).get('leagueMock');
  if (!mode) return null;
  const rows = NAMES.map((name, i) => ({ name, xp: XP[i] }));
  rows.splice(3, 0, { name: 'Jerson G.', xp: 1290, isMe: true });
  rows.sort((a, b) => b.xp - a.xp);
  return {
    tier: 'silver', tierName: 'Silver', nextTierName: 'Gold', prevTierName: 'Bronze',
    joined: mode !== 'join',
    rows: mode === 'join' ? [] : rows.map((r, i) => ({ ...r, place: i + 1, move: MOVE[i], days: DAYS[i] })),
    zones: { promote: 5, demote: 3 },
    forceResult: true, lastResult: mode === 'result' ? { moved: 'up', fromName: 'Bronze', toName: 'Silver', place: 3, of: 15, xp: 1180 } : null,
  };
}
