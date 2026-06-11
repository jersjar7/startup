import React from 'react';
import { useNavigate } from 'react-router-dom';
import {
  ClipboardText,
  ArrowRight,
  ArrowsClockwise,
  CheckCircle,
  Compass,
} from '@phosphor-icons/react';
import './diagnostic.css';

/*
  4 states:
  1. not-taken: Large prominent card, full messaging
  2. skipped: Smaller card, still visible
  3. completed-locked: Compact, shows retake progress
  4. completed-retake: Retake available
*/

export function DiagnosticCard({ diagnosticStatus, quickstart = {}, onSkip }) {
  const navigate = useNavigate();

  const {
    diagnosticCompleted,
    diagnosticAttempts,
    diagnosticSkipped,
    canRetake,
    chaptersAt60,
    chaptersNeeded,
    lastScore,
    lastDate,
  } = diagnosticStatus;

  const qsCount = quickstart?.sampledCount || 0;
  const qsTotal = quickstart?.totalChapters || 15;

  // Quick-start in progress: show readiness-map progress + a continue CTA.
  // Takes priority — it reflects the live onboarding path.
  if (qsCount > 0 && qsCount < qsTotal) {
    const pct = Math.round((qsCount / qsTotal) * 100);
    return (
      <div className="diag-card diag-card--compact">
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.5rem' }}>
          <Compass size={20} weight="bold" style={{ color: 'var(--forest)', flexShrink: 0 }} />
          <div style={{ flex: 1 }}>
            <span className="diag-card-title" style={{ fontSize: '0.92rem', marginBottom: 0 }}>
              Continue your readiness map
            </span>
          </div>
          <button className="btn-primary" style={{ padding: '0.45rem 1rem', fontSize: '0.82rem' }} onClick={() => navigate('/quickstart')}>
            Continue
            <ArrowRight size={16} weight="bold" />
          </button>
        </div>
        <div className="diag-progress-bar">
          <div className="diag-progress-track">
            <div className="diag-progress-fill" style={{ width: `${pct}%` }} />
          </div>
          <span className="diag-progress-label">{qsCount}/{qsTotal} chapters mapped</span>
        </div>
        <p style={{ fontSize: '0.78rem', color: 'var(--gray-500)', margin: 0 }}>
          Answer 5 more questions to map your next chapter. Stop anytime.
        </p>
      </div>
    );
  }

  // Quick-start fully mapped (all 15) without a legacy diagnostic: a clean
  // "complete" confirmation rather than falling through to the retake card.
  if (qsCount >= qsTotal && qsTotal > 0 && !diagnosticCompleted) {
    return (
      <div className="diag-card diag-card--compact">
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
          <CheckCircle size={20} weight="bold" style={{ color: 'var(--forest)', flexShrink: 0 }} />
          <div style={{ flex: 1 }}>
            <span className="diag-card-title" style={{ fontSize: '0.92rem', marginBottom: 0 }}>
              Readiness map complete
            </span>
          </div>
          <span style={{ fontSize: '0.78rem', color: 'var(--gray-500)' }}>
            All {qsTotal} chapters mapped
          </span>
        </div>
      </div>
    );
  }

  // State 1: Not taken (new user, not skipped, no quick-start progress yet)
  if (!diagnosticCompleted && !diagnosticSkipped && qsCount === 0) {
    return (
      <div className="diag-card">
        <div style={{ display: 'flex', alignItems: 'flex-start', gap: '0.75rem' }}>
          <Compass size={28} weight="bold" style={{ color: 'var(--forest)', flexShrink: 0, marginTop: '2px' }} />
          <div style={{ flex: 1 }}>
            <h3 className="diag-card-title" style={{ marginBottom: 0 }}>See where you stand</h3>
            <div className="diag-card-body">
              {/* the numbers live in exactly one place: the meta row */}
              <p>
                A quick start that maps where you stand, one chapter at a time —
                stop anytime, your mastery map keeps what you've built.
              </p>
              <p style={{ fontSize: '0.82rem', color: 'var(--gray-400)' }}>
                5 questions to start &middot; ~5 minutes &middot; always free
              </p>
            </div>
            <div className="diag-card-actions">
              <button className="btn-primary" onClick={() => navigate('/quickstart')}>
                Start now
                <ArrowRight size={16} weight="bold" />
              </button>
              <button className="diag-card-skip" onClick={onSkip}>
                Skip for now
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // State 2: Skipped
  if (!diagnosticCompleted && diagnosticSkipped && qsCount === 0) {
    return (
      <div className="diag-card diag-card--compact">
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
          <Compass size={20} weight="bold" style={{ color: 'var(--forest)', flexShrink: 0 }} />
          <div style={{ flex: 1 }}>
            <span style={{ fontFamily: 'var(--font-heading)', fontWeight: 600, fontSize: '0.88rem', color: 'var(--charcoal)' }}>
              Recommended: a 5-minute quick start to personalize your study plan
            </span>
          </div>
          <button className="btn-primary" style={{ padding: '0.45rem 1rem', fontSize: '0.82rem' }} onClick={() => navigate('/quickstart')}>
            Start
          </button>
        </div>
      </div>
    );
  }

  // State 3: Completed, retake locked
  if (diagnosticCompleted && !canRetake) {
    const progressPct = chaptersNeeded > 0
      ? Math.round((chaptersAt60 / chaptersNeeded) * 100)
      : 0;

    return (
      <div className="diag-card diag-card--compact">
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.5rem' }}>
          <ClipboardText size={20} weight="bold" style={{ color: 'var(--forest)', flexShrink: 0 }} />
          <div style={{ flex: 1 }}>
            <span className="diag-card-title" style={{ fontSize: '0.92rem', marginBottom: 0 }}>
              Diagnostic Exam
            </span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.3rem', color: 'var(--forest)', fontSize: '0.75rem', fontWeight: 600 }}>
            <CheckCircle size={14} weight="bold" />
            Diagnostic complete
          </div>
        </div>
        {lastScore !== undefined && (
          <div className="diag-last-score">
            Last diagnostic: {lastScore.correct}/{lastScore.total} correct
            {lastDate && <> &middot; {new Date(lastDate).toLocaleDateString()}</>}
          </div>
        )}
        <div className="diag-progress-bar">
          <div className="diag-progress-track">
            <div className="diag-progress-fill" style={{ width: `${progressPct}%` }} />
          </div>
          <span className="diag-progress-label">
            {chaptersAt60}/{chaptersNeeded} chapters at 60%+
          </span>
        </div>
        <p style={{ fontSize: '0.78rem', color: 'var(--gray-500)', margin: 0 }}>
          {chaptersAt60 > 0
            ? `Nice — you're ${chaptersAt60} of ${chaptersNeeded} chapters there. Keep practicing and a retake unlocks.`
            : `Keep practicing — reach 60% mastery in ${chaptersNeeded} chapters and a retake unlocks.`}
        </p>
      </div>
    );
  }

  // State 4: Completed, retake available
  return (
    <div className="diag-card diag-card--compact">
      <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
        <ClipboardText size={20} weight="bold" style={{ color: 'var(--forest)', flexShrink: 0 }} />
        <div style={{ flex: 1 }}>
          <span className="diag-card-title" style={{ fontSize: '0.92rem', marginBottom: 0 }}>
            Retake Diagnostic
          </span>
          {lastScore !== undefined && (
            <div className="diag-last-score" style={{ marginBottom: 0 }}>
              Last score: {lastScore.correct}/{lastScore.total}
              {lastDate && <> &middot; {new Date(lastDate).toLocaleDateString()}</>}
            </div>
          )}
        </div>
        <button className="btn-primary" style={{ padding: '0.45rem 1rem', fontSize: '0.82rem' }} onClick={() => navigate('/quickstart')}>
          <ArrowsClockwise size={16} weight="bold" />
          Retake
        </button>
      </div>
    </div>
  );
}
