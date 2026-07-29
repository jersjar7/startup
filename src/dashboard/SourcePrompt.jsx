import React from 'react';
import { X } from '@phosphor-icons/react';
import './SourcePrompt.css';

// "How did you find us?" — asked once, at registration, and nowhere else.
//
// Its job is NARROW and worth stating: automatic referrer capture (app.jsx ->
// login.jsx -> auth.js) already attributes search traffic and accounts for
// roughly half of all signups on its own. This survey exists only to catch the
// channels that strip referrers and cannot be measured any other way: TikTok,
// Instagram, Reddit, and word of mouth. Keep the fixed options — free text is
// unusable in aggregate.
//
// Asked at registration because that is the one point EVERY new user passes
// through while already authenticated (/api/auth/create sets the cookie).
// Earlier placements were worse: the dashboard required the user to reach and
// engage with it, and the verification screen reaches only the ~75% who verify
// and has no session, so the answer could not be written server-side.
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

async function postSource(source) {
  const res = await fetch('/api/user/acquisition', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ source }),
  });
  return res.ok;
}

// `dismissible`  show the X. False where the ask is the point of the screen.
export function SourcePrompt({ onClose, dismissible = true, className = '' }) {
  const [busy, setBusy] = React.useState(false);

  async function pick(source) {
    if (busy) return;
    setBusy(true);
    try {
      await postSource(source);
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
