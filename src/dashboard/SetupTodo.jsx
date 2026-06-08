import React from 'react';
import { useNavigate } from 'react-router-dom';
import {
  CheckSquare,
  EnvelopeSimple,
  User,
  CalendarBlank,
} from '@phosphor-icons/react';

// A small, contained "logistics" card for the right column. Keeps account setup
// (verify email, add name, set exam date) out of the left panel so it never
// competes with the quick-start / studying. Renders nothing once all done.
export function SetupTodo({ emailVerified, hasName, hasExam }) {
  const navigate = useNavigate();
  const [resending, setResending] = React.useState(false);
  const [sent, setSent] = React.useState(false);
  const [err, setErr] = React.useState('');

  const needEmail = emailVerified === false;
  const count = (needEmail ? 1 : 0) + (hasName ? 0 : 1) + (hasExam ? 0 : 1);
  if (count === 0) return null;

  async function resend() {
    setResending(true);
    setErr('');
    try {
      const res = await fetch('/api/auth/resend-verification', { method: 'POST' });
      if (res.ok) setSent(true);
      else if (res.status === 429) setErr('Wait a minute, then try again.');
      else setErr("Couldn't send — try again shortly.");
    } catch {
      setErr('Network error — try again.');
    } finally {
      setResending(false);
    }
  }

  return (
    <div className="sidebar-block setup-todo">
      <h3 className="dash-section-label">
        <CheckSquare weight="bold" size={18} />
        Set up your account
        <span className="setup-todo-count">{count}</span>
      </h3>
      <p className="setup-todo-sub">Quick logistics — they keep your account and reminders working.</p>

      <ul className="setup-todo-list">
        {needEmail && (
          <li className="setup-todo-item">
            <EnvelopeSimple size={16} weight="bold" className="setup-todo-icon" />
            <div className="setup-todo-body">
              <span className="setup-todo-label">Verify your email</span>
              {sent ? (
                <span className="setup-todo-note setup-todo-note--ok">Sent — check your inbox.</span>
              ) : err ? (
                <span className="setup-todo-note setup-todo-note--err">{err}</span>
              ) : (
                <span className="setup-todo-note">Unlocks the student discount &amp; reminders.</span>
              )}
            </div>
            {!sent && (
              <button className="setup-todo-action" onClick={resend} disabled={resending}>
                {resending ? '…' : 'Resend'}
              </button>
            )}
          </li>
        )}

        {!hasName && (
          <li className="setup-todo-item">
            <User size={16} weight="bold" className="setup-todo-icon" />
            <div className="setup-todo-body">
              <span className="setup-todo-label">Add your name</span>
              <span className="setup-todo-note">Shown instead of your email on the leaderboard.</span>
            </div>
            <button className="setup-todo-action" onClick={() => navigate('/profile')}>Add</button>
          </li>
        )}

        {!hasExam && (
          <li className="setup-todo-item">
            <CalendarBlank size={16} weight="bold" className="setup-todo-icon" />
            <div className="setup-todo-body">
              <span className="setup-todo-label">Set your exam date</span>
              <span className="setup-todo-note">Adds a countdown to keep you on pace.</span>
            </div>
            <button className="setup-todo-action" onClick={() => navigate('/profile')}>Set</button>
          </li>
        )}
      </ul>
    </div>
  );
}
