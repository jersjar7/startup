import React from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import {
  Timer,
  Exam,
  CheckCircle,
  ArrowRight,
  ArrowLeft,
  Lightning,
  ClockCountdown,
  ListChecks,
  ChartBar,
  Heart,
} from '@phosphor-icons/react';
import './exam.css';

export function ExamGate({ userName }) {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  useDocumentTitle('Exam Simulation');

  const [purchased, setPurchased] = React.useState(null);
  const [purchaseDate, setPurchaseDate] = React.useState(null);
  const [attempts, setAttempts] = React.useState([]);
  const [loading, setLoading] = React.useState(true);
  const [checkoutLoading, setCheckoutLoading] = React.useState(false);
  const [error, setError] = React.useState('');

  React.useEffect(() => {
    if (!userName) {
      navigate('/login', { state: { returnTo: '/exam' } });
      return;
    }

    const sessionId = searchParams.get('session_id');
    const statusUrl = sessionId
      ? `/api/checkout/status?session_id=${sessionId}`
      : '/api/checkout/status';

    Promise.allSettled([
      fetch(statusUrl).then(r => {
        if (!r.ok) throw new Error();
        return r.json();
      }),
      fetch('/api/exam/attempts').then(r => {
        if (r.status === 403) return [];
        if (!r.ok) throw new Error();
        return r.json();
      }),
    ]).then(([statusResult, attemptsResult]) => {
      if (statusResult.status === 'fulfilled') {
        setPurchased(statusResult.value.purchased);
        setPurchaseDate(statusResult.value.purchaseDate);
      } else {
        setPurchased(false);
      }

      if (attemptsResult.status === 'fulfilled') {
        setAttempts(attemptsResult.value);
      }

      setLoading(false);
    });
  }, [userName, navigate]);

  // Re-check purchase status after Stripe redirect
  React.useEffect(() => {
    const sessionId = searchParams.get('session_id');
    if (sessionId && purchased === false) {
      const timer = setTimeout(() => {
        fetch(`/api/checkout/status?session_id=${sessionId}`)
          .then(r => r.ok ? r.json() : Promise.reject())
          .then(data => {
            if (data.purchased) {
              setPurchased(true);
              setPurchaseDate(data.purchaseDate);
            }
          })
          .catch(() => {});
      }, 1500);
      return () => clearTimeout(timer);
    }
  }, [searchParams, purchased]);

  async function handleBuyNow() {
    setCheckoutLoading(true);
    setError('');
    try {
      const res = await fetch('/api/checkout/create-session', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      });
      if (!res.ok) {
        const body = await res.json();
        throw new Error(body.msg || 'Failed to start checkout');
      }
      const { url } = await res.json();
      window.location.href = url;
    } catch (err) {
      setError(err.message);
      setCheckoutLoading(false);
    }
  }

  if (loading) {
    return (
      <main className="exam-main">
        <div className="exam-loading">Loading...</div>
      </main>
    );
  }

  // ═══ NOT PURCHASED ═══
  if (!purchased) {
    return (
      <main className="exam-main">
        <div className="exam-gate">
          <div className="exam-gate-card">
            <button className="exam-gate-back" onClick={() => navigate('/dashboard')}>
              <ArrowLeft size={16} weight="bold" />
              Dashboard
            </button>

            <h1 className="exam-gate-title">110-Question Exam Simulation</h1>
            <p className="exam-gate-subtitle">
              The closest thing to sitting for the real FE Civil exam.
            </p>

            {/* What you get */}
            <div className="exam-gate-features">
              <div className="exam-gate-feature">
                <Exam weight="bold" size={20} className="egf-icon egf-icon--ember" />
                <div>
                  <span className="egf-label">110 questions</span>
                  <span className="egf-desc">Weighted by the official NCEES topic distribution</span>
                </div>
              </div>
              <div className="exam-gate-feature">
                <ClockCountdown weight="bold" size={20} className="egf-icon egf-icon--sunbeam" />
                <div>
                  <span className="egf-label">5 hours 20 minutes</span>
                  <span className="egf-desc">Same time limit as the real exam</span>
                </div>
              </div>
              <div className="exam-gate-feature">
                <ChartBar weight="bold" size={20} className="egf-icon egf-icon--forest" />
                <div>
                  <span className="egf-label">Per-chapter score breakdown</span>
                  <span className="egf-desc">See exactly where you're strong and where to focus</span>
                </div>
              </div>
              <div className="exam-gate-feature">
                <ListChecks weight="bold" size={20} className="egf-icon egf-icon--ember" />
                <div>
                  <span className="egf-label">Unlimited retakes</span>
                  <span className="egf-desc">Fresh question selection every time</span>
                </div>
              </div>
            </div>

            {/* Why we charge — the genuine message */}
            <div className="exam-gate-why">
              <Heart weight="bold" size={18} className="exam-gate-why-icon" />
              <div>
                <p className="exam-gate-why-title">Why this is the only thing that costs money</p>
                <p className="exam-gate-why-text">
                  Unlike other FE prep platforms that charge $200+ for access, we give you
                  all 15 chapters, 320+ practice problems, step-by-step solutions, and the
                  diagnostic exam completely free. We built this to help students get their
                  EIT certification without breaking the bank.
                </p>
                <p className="exam-gate-why-text">
                  This one-time purchase helps us cover server costs and keep
                  everything else free for the next student who finds us.
                </p>
              </div>
            </div>

            {/* Price + CTA */}
            <div className="exam-gate-price">
              <span className="exam-gate-amount">$14.99</span>
              <span className="exam-gate-period">one-time &middot; no subscription</span>
            </div>

            {error && <div className="exam-error" role="alert">{error}</div>}

            <button
              className="btn-primary exam-buy-btn"
              onClick={handleBuyNow}
              disabled={checkoutLoading}
            >
              {checkoutLoading ? 'Redirecting to checkout...' : 'Get Exam Simulation'}
            </button>
          </div>
        </div>
      </main>
    );
  }

  // ═══ PURCHASED ═══
  const completedAttempts = attempts.filter(a => a.status === 'completed');
  const bestScore = completedAttempts.length > 0
    ? Math.max(...completedAttempts.map(a => a.overallPercentage || 0))
    : null;

  return (
    <main className="exam-main">
      <div className="exam-hub">
        <div className="exam-hub-header">
          <button className="btn-secondary exam-back-link" onClick={() => navigate('/dashboard')}>
            <ArrowLeft size={16} weight="bold" />
            Dashboard
          </button>
          <h1 className="exam-hub-title">Exam Simulation</h1>
          <p className="exam-hub-subtitle">
            110 questions, 5h 20min, weighted by NCEES distribution.
          </p>
        </div>

        <div className="exam-hub-body">
          {/* Start exam card */}
          <div className="exam-start-card">
            <div className="exam-start-card-inner">
              <div className="exam-start-info">
                <div className="exam-start-rule">
                  <Timer weight="bold" size={18} />
                  <span>5 hours 20 minutes</span>
                </div>
                <div className="exam-start-rule">
                  <Exam weight="bold" size={18} />
                  <span>110 questions across 15 chapters</span>
                </div>
                {bestScore !== null && (
                  <div className="exam-start-rule">
                    <Lightning weight="bold" size={18} />
                    <span>Best score: {bestScore}%</span>
                  </div>
                )}
              </div>
              <button className="btn-primary exam-start-btn" onClick={() => navigate('/exam/session')}>
                Start New Exam
                <ArrowRight size={16} weight="bold" />
              </button>
            </div>
          </div>

          {/* Past attempts */}
          {completedAttempts.length > 0 && (
            <div className="exam-attempts-section">
              <h3 className="exam-attempts-title">Past Attempts</h3>
              <div className="exam-attempts-list">
                {completedAttempts.map(a => (
                  <button
                    key={a.attemptId}
                    className="exam-attempt-row"
                    onClick={() => navigate(`/exam/results/${a.attemptId}`)}
                  >
                    <span className="ea-num">#{a.attemptNumber}</span>
                    <span className="ea-score">{a.totalCorrect}/{a.totalQuestions}</span>
                    <span className="ea-pct" style={{ color: a.overallPercentage >= 50 ? 'var(--forest)' : 'var(--error)' }}>
                      {a.overallPercentage}%
                    </span>
                    <span className="ea-date">
                      {a.completedAt ? new Date(a.completedAt).toLocaleDateString() : ''}
                    </span>
                    <ArrowRight size={14} weight="bold" className="ea-arrow" />
                  </button>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </main>
  );
}
