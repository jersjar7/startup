import React from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  Lightning,
  ArrowRight,
  MagnifyingGlass,
} from '@phosphor-icons/react';
import { CHAPTERS } from '../data/chapters';
import './diagnostic.css';

function getMasteryColor(mastery) {
  if (mastery >= 90) return 'var(--forest)';
  if (mastery >= 70) return 'var(--sunbeam)';
  if (mastery >= 40) return 'var(--ember)';
  return 'var(--error)';
}

export function DiagnosticResults({ userName }) {
  const navigate = useNavigate();
  const { attemptNumber } = useParams();
  const [result, setResult] = React.useState(null);
  const [loading, setLoading] = React.useState(true);

  React.useEffect(() => {
    if (!userName) {
      navigate('/');
      return;
    }

    // Try sessionStorage first (just submitted), then fetch from API
    const cached = sessionStorage.getItem('diagnosticResult');
    if (cached) {
      try {
        const parsed = JSON.parse(cached);
        if (String(parsed.attemptNumber) === String(attemptNumber)) {
          setResult(parsed);
          setLoading(false);
          sessionStorage.removeItem('diagnosticResult');
          return;
        }
      } catch {}
    }

    fetch(`/api/diagnostic/results/${attemptNumber}`)
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
  }, [userName, navigate, attemptNumber]);

  if (loading) {
    return (
      <main className="dr-main">
        <div className="dx-loading"><p>Loading results...</p></div>
      </main>
    );
  }

  if (!result) {
    return (
      <main className="dr-main">
        <div className="dr-container">
          <div className="dx-error">Diagnostic result not found.</div>
          <button className="btn-secondary" onClick={() => navigate('/dashboard')}>
            Back to Dashboard
          </button>
        </div>
      </main>
    );
  }

  const { chapterScores, totalCorrect, totalQuestions, xpEarned } = result;
  const xpTotal = typeof xpEarned === 'object' ? xpEarned.total : xpEarned;

  // Build chapter list sorted by mastery (lowest first)
  const chapterList = CHAPTERS.map(ch => {
    const score = chapterScores?.[ch.id] || { correct: 0, total: 0, masterySeeded: 0 };
    return { ...ch, ...score };
  }).sort((a, b) => a.masterySeeded - b.masterySeeded);

  return (
    <main className="dr-main">
      <div className="dr-container">
        <div className="dr-header">
          <h1 className="dr-title">Your Diagnostic Results</h1>
          <p className="dr-subtitle">Here's where you stand across all 15 FE topics.</p>
        </div>

        {/* Score card */}
        <div className="dr-score-card">
          <div className="dr-score-big">
            {totalCorrect}/{totalQuestions}
          </div>
          <div className="dr-score-label">questions correct</div>
          <div className="dr-xp-pill">
            <Lightning size={14} weight="fill" />
            +{xpTotal} XP earned
          </div>
        </div>

        {/* Chapter breakdown */}
        <div className="dr-chapters">
          <h3 className="dr-chapters-title">Chapter Mastery (from diagnostic)</h3>
          {chapterList.map(ch => (
            <div key={ch.id} className="dr-chapter-row">
              <span className="dr-ch-name">{ch.name}</span>
              <div className="dr-mastery-bar-wrap">
                <div className="dr-mastery-bar">
                  <div
                    className="dr-mastery-fill"
                    style={{
                      width: `${ch.masterySeeded}%`,
                      background: getMasteryColor(ch.masterySeeded),
                    }}
                  />
                </div>
                <span
                  className="dr-mastery-pct"
                  style={{ color: getMasteryColor(ch.masterySeeded) }}
                >
                  {ch.masterySeeded}%
                </span>
              </div>
              <span className="dr-ch-score">{ch.correct}/{ch.total}</span>
            </div>
          ))}
        </div>

        {/* Message */}
        <div className="dr-message">
          <p>
            Your personalized study plan is ready. We'll prioritize the chapters
            where you'll get the biggest score improvement on the real FE.
          </p>
          <p style={{ marginTop: '0.5rem', fontSize: '0.82rem', color: 'var(--gray-400)' }}>
            The diagnostic seeds your mastery bars up to 60%. Keep studying to push past that.
          </p>
        </div>

        {/* Actions */}
        <div className="dr-actions">
          <button className="btn-primary" onClick={() => navigate('/dashboard')}>
            Go to Dashboard
            <ArrowRight size={16} weight="bold" />
          </button>
          <button
            className="btn-secondary"
            onClick={() => navigate(`/diagnostic/review/${attemptNumber}`)}
          >
            <MagnifyingGlass size={16} weight="bold" />
            Review Answers
          </button>
        </div>
      </div>
    </main>
  );
}
