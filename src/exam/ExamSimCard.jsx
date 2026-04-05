import React from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Exam,
  ArrowRight,
} from '@phosphor-icons/react';
import './exam.css';

export function ExamSimCard() {
  const navigate = useNavigate();
  const [purchased, setPurchased] = React.useState(null);
  const [bestScore, setBestScore] = React.useState(null);
  const [attemptCount, setAttemptCount] = React.useState(0);

  React.useEffect(() => {
    fetch('/api/checkout/status')
      .then(r => {
        if (!r.ok) throw new Error();
        return r.json();
      })
      .then(data => {
        setPurchased(data.purchased);
        if (data.purchased) {
          fetch('/api/exam/attempts')
            .then(r => r.ok ? r.json() : [])
            .then(attempts => {
              const completed = attempts.filter(a => a.status === 'completed');
              setAttemptCount(completed.length);
              if (completed.length > 0) {
                setBestScore(Math.max(...completed.map(a => a.overallPercentage || 0)));
              }
            })
            .catch(() => {});
        }
      })
      .catch(() => setPurchased(false));
  }, []);

  if (purchased === null) return null;

  // Not purchased — subtle inline CTA, no price shown
  if (!purchased) {
    return (
      <button className="exam-sim-inline" onClick={() => navigate('/exam')}>
        <Exam size={18} weight="bold" className="exam-sim-inline-icon" />
        <span className="exam-sim-inline-text">
          Ready to test yourself? Take the full 110-question exam simulation.
        </span>
        <ArrowRight size={14} weight="bold" className="exam-sim-inline-arrow" />
      </button>
    );
  }

  // Purchased — show status
  return (
    <button className="exam-sim-inline exam-sim-inline--owned" onClick={() => navigate('/exam')}>
      <Exam size={18} weight="bold" className="exam-sim-inline-icon" />
      <span className="exam-sim-inline-text">
        Exam Simulation
        {attemptCount > 0 && (
          <span className="exam-sim-inline-meta">
            {attemptCount} attempt{attemptCount !== 1 ? 's' : ''}
            {bestScore !== null ? ` · Best: ${bestScore}%` : ''}
          </span>
        )}
        {attemptCount === 0 && (
          <span className="exam-sim-inline-meta">Ready to start your first exam</span>
        )}
      </span>
      <ArrowRight size={14} weight="bold" className="exam-sim-inline-arrow" />
    </button>
  );
}
