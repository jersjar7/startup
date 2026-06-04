import React from 'react';
import { useNavigate } from 'react-router-dom';
import {
  ClipboardText,
  ArrowRight,
  ArrowsClockwise,
  CheckCircle,
} from '@phosphor-icons/react';
import './diagnostic.css';

/*
  4 states:
  1. not-taken: Large prominent card, full messaging
  2. skipped: Smaller card, still visible
  3. completed-locked: Compact, shows retake progress
  4. completed-retake: Retake available
*/

export function DiagnosticCard({ diagnosticStatus, onSkip }) {
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

  // State 1: Not taken (new user, not skipped)
  if (!diagnosticCompleted && !diagnosticSkipped) {
    return (
      <div className="diag-card">
        <div style={{ display: 'flex', alignItems: 'flex-start', gap: '0.75rem' }}>
          <ClipboardText size={28} weight="bold" style={{ color: 'var(--forest)', flexShrink: 0, marginTop: '2px' }} />
          <div style={{ flex: 1 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <h3 className="diag-card-title" style={{ marginBottom: 0 }}>Start With a Diagnostic</h3>
              <span className="diag-free-badge">Free</span>
            </div>
            <p className="diag-card-subtitle">This is your compass, not a test.</p>
            <div className="diag-card-body">
              <p>
                Take a quick 30-question diagnostic before you start studying.
                It tells us exactly where you stand so we can personalize your study plan.
                This is not the exam simulation — it's a free tool included with your account.
              </p>
              <p style={{ fontSize: '0.82rem', color: 'var(--gray-400)' }}>
                30 questions &middot; ~87 minutes &middot; real FE pace &middot; always free
              </p>
            </div>
            <div className="diag-card-actions">
              <button className="btn-primary" onClick={() => navigate('/diagnostic')}>
                Take the Diagnostic
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
  if (!diagnosticCompleted && diagnosticSkipped) {
    return (
      <div className="diag-card diag-card--compact">
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
          <ClipboardText size={20} weight="bold" style={{ color: 'var(--forest)', flexShrink: 0 }} />
          <div style={{ flex: 1 }}>
            <span style={{ fontFamily: 'var(--font-heading)', fontWeight: 600, fontSize: '0.88rem', color: 'var(--charcoal)' }}>
              Recommended: Take the free diagnostic to personalize your study plan
            </span>
          </div>
          <button className="btn-primary" style={{ padding: '0.45rem 1rem', fontSize: '0.82rem' }} onClick={() => navigate('/diagnostic')}>
            Take Diagnostic
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
        <button className="btn-primary" style={{ padding: '0.45rem 1rem', fontSize: '0.82rem' }} onClick={() => navigate('/diagnostic')}>
          <ArrowsClockwise size={16} weight="bold" />
          Retake
        </button>
      </div>
    </div>
  );
}
