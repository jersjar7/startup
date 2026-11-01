// Sample league for reviewing the design before the API exists. Dev only:
// add ?leagueMock=1 (joined), ?leagueMock=join (not joined yet) or
// ?leagueMock=result (Sunday result) to the dashboard URL.
const NAMES = ['Sweet D.', 'Mohammad A.', 'Kasie N.', 'Jackson H.', 'Meagan', 'Liz', 'Nicholas K.', 'Izzy T.', 'Ermi', 'A student', 'Devon R.', 'sal***', 'Priya S.', 'Tom B.'];
const XP = [1840, 1525, 1310, 1240, 1105, 980, 870, 760, 640, 515, 420, 310, 185, 90];

export function leagueMock() {
  if (!import.meta.env.DEV) return null;
  const mode = new URLSearchParams(window.location.search).get('leagueMock');
  if (!mode) return null;
  const rows = NAMES.map((name, i) => ({ name, xp: XP[i] }));
  rows.splice(3, 0, { name: 'You', xp: 1290, isMe: true });
  rows.sort((a, b) => b.xp - a.xp);
  return {
    tier: 'concrete', tierName: 'Concrete', nextTierName: 'Steel', prevTierName: 'Masonry',
    joined: mode !== 'join',
    rows: mode === 'join' ? [] : rows.map((r, i) => ({ ...r, place: i + 1 })),
    zones: { promote: 5, demote: 3 },
    forceResult: true, lastResult: mode === 'result' ? { moved: 'up', fromName: 'Masonry', toName: 'Concrete', place: 3, of: 15, xp: 1180 } : null,
  };
}
