import React from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import {
  Lightning,
  ArrowRight,
  ArrowLeft,
  CheckCircle,
  XCircle,
  Trophy,
} from '@phosphor-icons/react';
import { CHAPTERS } from '../data/chapters';
import { formatDuration } from './formatDuration';
import './exam.css';

// Mirrors TIME_LIMIT_SECONDS in service/examAttempt.js (5h 20m of testing).
const EXAM_TIME_LIMIT_SECONDS = 19200;

function getMasteryColor(pct) {
  if (pct >= 70) return 'var(--forest)';
  if (pct >= 50) return 'var(--sunbeam)';
  if (pct >= 30) return 'var(--ember)';
  return 'var(--error)';
}

export function ExamResults({ userName }) {
  const navigate = useNavigate();
  const { attemptId } = useParams();
  useDocumentTitle('Exam Results');
  const [result, setResult] = React.useState(null);
  const [loading, setLoading] = React.useState(true);

  React.useEffect(() => {
    if (!userName) {
      navigate('/');
      return;
    }

    // Try sessionStorage first (just submitted)
    const cached = sessionStorage.getItem('examResult');
    if (cached) {
      try {
        const parsed = JSON.parse(cached);
        if (parsed.attemptId === attemptId) {
          setResult(parsed);
          setLoading(false);
          sessionStorage.removeItem('examResult');
          return;
        }
      } catch {}
    }

    // Fetch from API
    fetch(`/api/exam/attempt/${attemptId}`)
      .then(res => {
        if (!res.ok) throw new Error('Not found');
        return res.json();
      })
      .then(data => {
        setResult(data);
        setLoading(false);
      })
      .catch(() => {
        setLoading(false);
      });
  }, [userName, navigate, attemptId]);

  if (loading) {
    return (
      <main className="er-main">
        <div className="ex-loading"><p>Loading results...</p></div>
      </main>
    );
  }

  if (!result) {
    return (
      <main className="er-main">
        <div className="er-container">
          <div className="exam-error" role="alert">Exam result not found.</div>
          <button className="btn-secondary" onClick={() => navigate('/exam')}>
            Back to Exam
          </button>
        </div>
      </main>
    );
  }

  const {
    chapterScores,
    totalCorrect,
    totalAttempted = 0,
    totalQuestions,
    timeUsedSeconds,
    timeLimit,
    overallPercentage,
    xpEarned,
    attemptNumber,
  } = result;

  const xpTotal = typeof xpEarned === 'object' ? xpEarned.total : xpEarned;
  const passed = overallPercentage >= 50;

  // Attempts completed before this shipped have no stored timeLimit, so fall
  // back to the constant rather than rendering "of undefined".
  const timeLimitSeconds = timeLimit || EXAM_TIME_LIMIT_SECONDS;
  const timeUsedLabel = formatDuration(timeUsedSeconds);
  const unanswered = Math.max((totalQuestions || 110) - totalAttempted, 0);

  // Build chapter list sorted by percentage (lowest first)
  const chapterList = CHAPTERS.map(ch => {
    const score = chapterScores?.[ch.id] || { correct: 0, total: 0, percentage: 0 };
    return { ...ch, ...score };
  }).filter(ch => ch.total > 0)
    .sort((a, b) => (a.percentage || 0) - (b.percentage || 0));

  return (
    <main className="er-main">
      <div className="er-container">
        <div className="er-header">
          <h1 className="er-title">
            {passed ? 'You passed!' : 'Exam Results'}
          </h1>
          <p className="er-subtitle">
            {passed
              ? 'Great job! Keep practicing to build confidence for the real exam.'
              : 'Review the chapter breakdown below to focus your studying.'}
          </p>
        </div>

        {/* Score card */}
        <div className={`er-score-card ${passed ? 'er-score-card--pass' : ''}`}>
          <div className="er-score-big">
            {totalCorrect}/{totalQuestions || 110}
          </div>
          <div className="er-score-pct" style={{ color: getMasteryColor(overallPercentage) }}>
            {overallPercentage}%
          </div>
          <div className="er-score-label">
            {passed ? (
              <span className="er-pass-badge"><CheckCircle size={16} weight="bold" /> Passing Score</span>
            ) : (
              <span className="er-fail-badge"><XCircle size={16} weight="bold" /> Below Passing</span>
            )}
          </div>
          {xpTotal > 0 && (
            <div className="er-xp-pill">
              <Lightning size={14} weight="fill" />
              +{xpTotal} XP earned
            </div>
          )}
        </div>

        {/* Pacing. A full-length timed exam answers two different questions, and
            the score alone only answers one. Finishing with an hour to spare and
            scoring 45% is a knowledge problem; running the clock out with 20
            questions untouched is a pacing problem, and the fix is not the same.
            timeUsedSeconds is server-authoritative (the client's timer resets on
            every resume), so this cannot be inflated by leaving a tab open. */}
        <div className="er-stats">
          {timeUsedLabel && (
            <div className="er-stat">
              <span className="er-stat-label">Time used</span>
              <span className="er-stat-value">
                {timeUsedLabel}
                <span className="er-stat-of"> of {formatDuration(timeLimitSeconds)}</span>
              </span>
            </div>
          )}
          <div className="er-stat">
            <span className="er-stat-label">Questions answered</span>
            <span className="er-stat-value">
              {totalAttempted}
              <span className="er-stat-of"> of {totalQuestions || 110}</span>
            </span>
          </div>
          {unanswered > 0 && (
            <p className="er-stat-note">
              {unanswered} question{unanswered === 1 ? '' : 's'} went unanswered. On
              the real exam those score as wrong, so pacing is worth practising
              alongside the chapters below.
            </p>
          )}
        </div>

        {/* Chapter breakdown */}
        <div className="er-chapters">
          <h3 className="er-chapters-title">Score by Chapter</h3>
          {chapterList.map(ch => (
            <div key={ch.id} className="er-chapter-row">
              <span className="er-ch-name">{ch.name}</span>
              <div className="er-mastery-bar-wrap">
                <div className="er-mastery-bar">
                  <div
                    className="er-mastery-fill"
                    style={{
                      width: `${ch.percentage || 0}%`,
                      background: getMasteryColor(ch.percentage || 0),
                    }}
                  />
                </div>
                <span
                  className="er-mastery-pct"
                  style={{ color: getMasteryColor(ch.percentage || 0) }}
                >
                  {ch.percentage || 0}%
                </span>
              </div>
              <span className="er-ch-score">{ch.correct}/{ch.total}</span>
            </div>
          ))}
        </div>

        {/* Threshold note */}
        <div className="er-note">
          <p>
            The NCEES doesn't publish an exact passing score, but historical estimates
            suggest ~50-55% is needed to pass. Focus on chapters where you scored below 50%.
          </p>
        </div>

        {/* Actions */}
        <div className="er-actions">
          <button className="btn-primary" onClick={() => navigate(`/exam/review/${attemptId}`)}>
            Review answers
            <ArrowRight size={16} weight="bold" />
          </button>
          <button className="btn-secondary" onClick={() => navigate('/exam')}>
            Back to Exam Hub
          </button>
          <button className="btn-secondary" onClick={() => navigate('/dashboard')}>
            <ArrowLeft size={16} weight="bold" />
            Dashboard
          </button>
        </div>
      </div>
    </main>
  );
}
