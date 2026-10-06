// Shared number / date formatting for the admin analytics dashboard.

export const fmtInt = (v) => (v >= 1000 ? `${(v / 1000).toFixed(1)}k` : `${Math.round(v)}`);

export const fmtMoney = (v) => `$${v >= 1000 ? `${(v / 1000).toFixed(1)}k` : Math.round(v * 100) / 100}`;

export const money = (v) => `$${Number(v).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;

export const SOURCE_LABEL = {
  reddit: 'Reddit', search: 'Google / search', youtube: 'YouTube',
  instagram: 'Instagram', tiktok: 'TikTok', friend: 'A friend', other: 'Other',
};

// Account-created date + time in Pacific Time, e.g. "6/9/26, 5:38 PM".
export const fmtJoined = (iso) => {
  if (!iso) return '—';
  try {
    return new Intl.DateTimeFormat('en-US', {
      timeZone: 'America/Los_Angeles',
      month: 'numeric', day: 'numeric', year: '2-digit',
      hour: 'numeric', minute: '2-digit',
    }).format(new Date(iso));
  } catch { return '—'; }
};
