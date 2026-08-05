import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Certificate } from '@phosphor-icons/react';
import { daysUntil, shouldShowSimPitch, usesCountdownCopy } from './simPitchGate';

// On-site exam-sim pitch. Reaches engaged studiers directly, with no
// Promotions-tab tax. Soft snooze ("Maybe later") keeps it near-persistent
// without nagging.
//
// WHO SEES IT. Measured 2026-08-04, the old gate (exam date AND 2-30 days out)
// reached 15 of 270 users. It discarded 96% before the banner was even
// considered, and the binding constraint was the 28-day WINDOW, not missing
// exam dates: 35 users were excluded purely for sitting more than 30 days out.
// A 60% click-through on that microscopic audience said the offer works and
// almost nobody sees it. So the gate is now:
//
//     any future exam date (no upper bound)  OR  25+ problems answered
//
// The upper bound is gone; the lower one stays, because selling a 5h20m
// simulation to somebody sitting the exam tomorrow is not a real offer.
//
// The 25-problem floor is evidence-based but deliberately loose: 7 of the first
// 8 buyers had answered 45+ before purchasing, yet tuning to 45 would be
// overfitting 8 data points. Only 1 of 8 buyers was below 25, so 25 costs
// almost nothing in precision and nearly doubles reach.
// Gate logic lives in simPitchGate.js so it can be unit tested — it decides the
// reach of the only paid product.
const DISMISS_KEY = 'fe4r-sim-banner-snoozed';

// "Maybe later" snooze TIGHTENS as the exam nears, but never below a day: relaxed
// early (3 days), a gentle daily nudge inside the final two weeks. A 24h floor keeps
// it a reminder, not a nag — the trust behind "core is free" is worth more than a
// few extra impressions.
function snoozeMs(daysLeft) {
  // No exam date means no deadline pressure, so use the relaxed cadence.
  if (daysLeft == null) return 3 * 24 * 60 * 60 * 1000;
  if (daysLeft <= 14) return 24 * 60 * 60 * 1000;
  return 3 * 24 * 60 * 60 * 1000;
}

// For a studier with no exam date (or a stale one). There is no countdown to
// lean on, so the pitch sells the DIAGNOSTIC value instead of urgency: their own
// problem count is the hook. Never invent urgency for someone who has not told
// us when they sit.
function pitchWithoutDate(problemsAnswered) {
  return {
    lead: `You've answered ${problemsAnswered} problems.`,
    body: 'A full timed simulation is the only way to see how that holds up across 110 questions and five and a half hours. You get a chapter-by-chapter breakdown of where the points actually go.',
    urgent: false,
  };
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

export function SimPitchBanner({ examDate, problemsAnswered = 0, variant = 'full' }) {
  const navigate = useNavigate();
  const [show, setShow] = React.useState(false);
  const loggedShown = React.useRef(false);

  const daysLeft = React.useMemo(() => daysUntil(examDate), [examDate]);

  const eligible = shouldShowSimPitch({ daysLeft, problemsAnswered });
  const datedPitch = usesCountdownCopy(daysLeft);

  // Eligible + not recently snoozed + not already a buyer -> show.
  React.useEffect(() => {
    if (!eligible) return undefined;
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
  }, [eligible, daysLeft]);

  // Log one impression per mount when it actually renders.
  React.useEffect(() => {
    if (show && !loggedShown.current) {
      loggedShown.current = true;
      fetch('/api/checkout/sim-banner/shown', { method: 'POST' }).catch(() => {});
    }
  }, [show]);

  if (!show) return null;

  // Countdown copy only when there is a real countdown. Without this guard the
  // undated user would fall through to the final tier and render the literal
  // string "Just null days to go."
  const p = datedPitch ? pitchFor(daysLeft) : pitchWithoutDate(problemsAnswered);
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
