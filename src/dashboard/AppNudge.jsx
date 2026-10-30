import React from 'react';
import { Link } from 'react-router-dom';
import { X } from '@phosphor-icons/react';
import { APP_PAGE } from '../data/appLinks';

// "Have you seen our new app?": a small right-column card for people who have
// never synced from the phone. Anyone who has used the app already knows it,
// so a phone sync hides it for good; the close button hides it on this
// browser.
export const APP_NUDGE_KEY = 'fe4r-app-nudge-hidden';

export function shouldShowAppNudge({ syncState, hidden }) {
  return !hidden && !(syncState && syncState.at);
}

function readHidden() {
  try { return localStorage.getItem(APP_NUDGE_KEY) === '1'; } catch { return false; }
}

// Local preview only: ?show-app-card shows the card on an account that has
// already synced, so the design can be checked on a real dashboard.
function forced() {
  if (!import.meta.env.DEV || typeof window === 'undefined') return false;
  return new URLSearchParams(window.location.search).has('show-app-card');
}

export function AppNudge({ syncState }) {
  const [hidden, setHidden] = React.useState(readHidden);
  if (!forced() && !shouldShowAppNudge({ syncState, hidden })) return null;

  function hide() {
    try { localStorage.setItem(APP_NUDGE_KEY, '1'); } catch { /* ignore */ }
    setHidden(true);
  }

  return (
    <div className="sidebar-block app-nudge">
      <div className="app-nudge-text">
        <h3 className="app-nudge-title">Have you seen our new app?</h3>
        <p className="app-nudge-body">
          Short rounds on the same drawings, for the minutes between classes. On Android now,
          iPhone coming soon.
        </p>
        <Link className="app-nudge-link" to={APP_PAGE}>See how it works</Link>
      </div>
      <img className="app-nudge-shot" src="/app/round-seepage-360.webp" width="72" height="156" alt="" />
      <button type="button" className="app-nudge-close" onClick={hide} aria-label="Hide the app card">
        <X size={14} weight="bold" />
      </button>
    </div>
  );
}
