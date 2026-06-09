import React from 'react';
import { X } from '@phosphor-icons/react';

// One-time, dismissible "how did you find us?" question. Self-reported source
// is the most reliable attribution signal (it captures word-of-mouth and
// referrer-stripped traffic that UTM/referrer miss). Shown once, then never again.
const OPTIONS = [
  { id: 'reddit', label: 'Reddit' },
  { id: 'search', label: 'Google / search' },
  { id: 'youtube', label: 'YouTube' },
  { id: 'instagram', label: 'Instagram' },
  { id: 'tiktok', label: 'TikTok' },
  { id: 'friend', label: 'A friend' },
  { id: 'other', label: 'Other' },
];

export function SourcePrompt({ onClose }) {
  const [busy, setBusy] = React.useState(false);

  async function pick(source) {
    if (busy) return;
    setBusy(true);
    try {
      await fetch('/api/user/acquisition', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ source }),
      });
    } catch { /* non-blocking */ }
    onClose(true);
  }

  return (
    <div className="source-prompt">
      <button className="source-prompt-x" onClick={() => onClose(false)} aria-label="Dismiss">
        <X size={14} weight="bold" />
      </button>
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
