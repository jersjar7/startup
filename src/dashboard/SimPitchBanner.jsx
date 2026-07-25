import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Certificate } from '@phosphor-icons/react';

// On-site exam-sim pitch. Reaches engaged studiers directly (no Promotions-tab
// tax), timed to the SAME window as the countdown-email pitch: dated non-buyers
// 12-30 days out. Copy escalates as the exam nears (why now + how it helps).
// Soft snooze ("Maybe later") keeps it near-persistent without nagging.
const MIN_DAYS = 2; // banner runs closer to the exam than the email pitch (email floor is 12)
const MAX_DAYS = 30;
const DISMISS_KEY = 'fe4r-sim-banner-snoozed';

// "Maybe later" snooze TIGHTENS as the exam nears, but never below a day: relaxed
// early (3 days), a gentle daily nudge inside the final two weeks. A 24h floor keeps
// it a reminder, not a nag — the trust behind "core is free" is worth more than a
// few extra impressions.
function snoozeMs(daysLeft) {
  if (daysLeft <= 14) return 24 * 60 * 60 * 1000;
  return 3 * 24 * 60 * 60 * 1000;
}

// Message tiers by time-to-exam. Precise personal lead + a rationale that
// changes with proximity, so the banner stays fresh and answers "why now".
function pitchFor(daysLeft) {
  if (daysLeft >= 22) {
    return {
      lead: `Your exam is ${daysLeft} days away.`,
      body: 'Plenty of runway. One full timed simulation now shows exactly which topics still cost you points, while there is time to fix them.',
      urgent: false,
    };
  }
  if (daysLeft >= 14) {
    return {
      lead: `Your exam is ${daysLeft} days away.`,
      body: 'Knowing the material and surviving six hours of it are different skills. A dress rehearsal under real NCEES timing builds the pacing and stamina the day demands.',
      urgent: false,
    };
  }
  if (daysLeft >= 7) {
    return {
      lead: `Test week is close — ${daysLeft} days out.`,
      body: 'Do one complete run under real conditions so the format, the clock, and the fatigue are familiar, not a surprise on exam day.',
      urgent: true,
    };
  }
  return {
    lead: `Just ${daysLeft} days to go.`,
    body: 'No time for the full six hours? Even a partial run under the real clock gives you the exam-day feel, so the first time you face it is not the real thing.',
    urgent: true,
  };
}

export function SimPitchBanner({ examDate, variant = 'full' }) {
  const navigate = useNavigate();
  const [show, setShow] = React.useState(false);
  const loggedShown = React.useRef(false);

  const daysLeft = React.useMemo(() => {
    if (!examDate) return null;
    const t = new Date(`${examDate}T00:00:00`).getTime();
    if (Number.isNaN(t)) return null;
    return Math.ceil((t - Date.now()) / 86400000);
  }, [examDate]);

  const inWindow = daysLeft != null && daysLeft >= MIN_DAYS && daysLeft <= MAX_DAYS;

  // Eligible + not recently snoozed + not already a buyer -> show.
  React.useEffect(() => {
    if (!inWindow) return undefined;
    try {
      const ts = Number(localStorage.getItem(DISMISS_KEY) || 0);
      if (ts && Date.now() - ts < snoozeMs(daysLeft)) return undefined;
    } catch { /* ignore */ }
    let alive = true;
    fetch('/api/checkout/status')
      .then((r) => (r.ok ? r.json() : null))
      .then((d) => { if (alive && d && !d.purchased) setShow(true); })
      .catch(() => {});
    return () => { alive = false; };
  }, [inWindow, daysLeft]);

  // Log one impression per mount when it actually renders.
  React.useEffect(() => {
    if (show && !loggedShown.current) {
      loggedShown.current = true;
      fetch('/api/checkout/sim-banner/shown', { method: 'POST' }).catch(() => {});
    }
  }, [show]);

  if (!show) return null;

  const p = pitchFor(daysLeft);
  const compact = variant === 'compact';
  const cls = `sim-pitch-banner${p.urgent ? ' sim-pitch-banner--urgent' : ''}${compact ? ' sim-pitch-banner--compact' : ''}`;

  const handleCta = () => {
    fetch('/api/checkout/sim-banner/click', { method: 'POST' }).catch(() => {});
    navigate('/exam');
  };
  const handleSnooze = () => {
    try { localStorage.setItem(DISMISS_KEY, String(Date.now())); } catch { /* ignore */ }
    setShow(false);
  };

  return (
    <div className={cls} role="region" aria-label="Exam simulation">
      <div className="sim-pitch-content">
        <Certificate weight="bold" size={compact ? 20 : 22} />
        <p className="sim-pitch-text">
          <strong>{p.lead}</strong>
          {!compact && <>{' '}{p.body}</>}
        </p>
      </div>
      <div className="sim-pitch-actions">
        <button type="button" className="sim-pitch-cta" onClick={handleCta}>
          See the simulation
        </button>
        <button type="button" className="sim-pitch-later" onClick={handleSnooze}>
          Maybe later
        </button>
      </div>
    </div>
  );
}
