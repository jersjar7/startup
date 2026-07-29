import React from 'react';
import { X } from '@phosphor-icons/react';
import './SourcePrompt.css';

// "How did you find us?" — asked once per user.
//
// Its job is NARROW and worth stating: automatic referrer capture (app.jsx ->
// login.jsx -> auth.js) already attributes search traffic and accounts for
// roughly half of all signups on its own. This survey exists only to catch the
// channels that strip referrers and cannot be measured any other way: TikTok,
// Instagram, Reddit, and word of mouth. Keep the fixed options — free text is
// unusable in aggregate.
const OPTIONS = [
  { id: 'reddit', label: 'Reddit' },
  { id: 'search', label: 'Google / search' },
  { id: 'youtube', label: 'YouTube' },
  { id: 'instagram', label: 'Instagram' },
  { id: 'tiktok', label: 'TikTok' },
  { id: 'linkedin', label: 'LinkedIn' },
  { id: 'friend', label: 'A friend' },
  { id: 'other', label: 'Other' },
];

const PENDING_KEY = 'fe4r_acq_pending';

async function postSource(source) {
  const res = await fetch('/api/user/acquisition', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ source }),
  });
  return res.ok;
}

// Send an answer collected while the user had no session.
//
// The verification screen is the best moment to ask — it is the one point every
// verified user passes through — but GET /api/auth/verify-email deliberately
// does NOT log anyone in, and that link often opens in a different browser from
// the one they signed up in. So an answer given there is parked in localStorage
// and flushed here on the next authenticated render. Safe to call
// unconditionally: it no-ops when there is nothing parked, and keeps the value
// for a later retry if the POST fails.
export async function flushPendingSource() {
  let pending;
  try {
    pending = localStorage.getItem(PENDING_KEY);
  } catch {
    return false; // storage blocked (private mode) — nothing to do
  }
  if (!pending) return false;
  try {
    if (await postSource(pending)) {
      localStorage.removeItem(PENDING_KEY);
      return true;
    }
  } catch { /* offline — keep it parked and retry on the next load */ }
  return false;
}

// `deferred`     collect the answer without a session and park it for
//                flushPendingSource() (the verification screen).
// `dismissible`  show the X. False where the ask is the point of the screen.
export function SourcePrompt({ onClose, deferred = false, dismissible = true, className = '' }) {
  const [busy, setBusy] = React.useState(false);

  async function pick(source) {
    if (busy) return;
    setBusy(true);
    try {
      if (deferred) {
        localStorage.setItem(PENDING_KEY, source);
      } else {
        await postSource(source);
      }
    } catch { /* non-blocking: never trap a user behind an analytics question */ }
    onClose(true);
  }

  return (
    <div className={`source-prompt ${className}`.trim()}>
      {dismissible && (
        <button className="source-prompt-x" onClick={() => onClose(false)} aria-label="Dismiss">
          <X size={14} weight="bold" />
        </button>
      )}
      <span className="source-prompt-q">Quick question — how did you find us?</span>
      <div className="source-prompt-chips">
        {OPTIONS.map((o) => (
          <button key={o.id} className="source-chip" disabled={busy} onClick={() => pick(o.id)}>
            {o.label}
          </button>
        ))}
      </div>
    </div>
  );
}
