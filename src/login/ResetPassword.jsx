import React from 'react';
import { useParams, Link } from 'react-router-dom';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import { LockKey, CheckCircle, WarningCircle } from '@phosphor-icons/react';
import './index.css';

export function ResetPassword() {
  useDocumentTitle('Reset Password');
  const { token } = useParams();
  const [password, setPassword] = React.useState('');
  const [confirm, setConfirm] = React.useState('');
  const [error, setError] = React.useState('');
  const [done, setDone] = React.useState(false);
  const [submitting, setSubmitting] = React.useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setError('');

    if (password !== confirm) {
      setError('Passwords do not match');
      return;
    }
    if (password.length < 8 || !/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/.test(password)) {
      setError('Password must be 8+ characters with uppercase, lowercase, and a number');
      return;
    }

    setSubmitting(true);
    try {
      const res = await fetch('/api/auth/reset-password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ token, password }),
      });
      if (res.ok) {
        setDone(true);
      } else {
        const body = await res.json();
        setError(body.msg || 'Reset failed');
      }
    } catch {
      setError('Network error. Please try again.');
    } finally {
      setSubmitting(false);
    }
  }

  if (done) {
    return (
      <main className="login-main">
        <div className="login-form-container" style={{ textAlign: 'center' }}>
          <CheckCircle size={48} weight="bold" color="var(--forest)" style={{ marginBottom: '1rem' }} />
          <h2>Password Reset</h2>
          <p className="login-subtitle">Your password has been updated. You can now log in.</p>
          <Link to="/login" className="btn-primary" style={{ display: 'inline-flex', textDecoration: 'none', marginTop: '0.5rem' }}>
            Go to Login
          </Link>
        </div>
      </main>
    );
  }

  return (
    <main className="login-main">
      <div className="login-form-container">
        <h2>Choose a New Password</h2>
        <p className="login-subtitle">Enter and confirm your new password below.</p>
        {error && <p className="error-banner" role="alert">{error}</p>}
        <form onSubmit={handleSubmit}>
          <label className="login-label" htmlFor="new-password">New Password</label>
          <input
            id="new-password"
            type="password"
            placeholder="8+ characters"
            autoComplete="new-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
          <label className="login-label" htmlFor="confirm-password">Confirm Password</label>
          <input
            id="confirm-password"
            type="password"
            placeholder="Repeat password"
            autoComplete="new-password"
            value={confirm}
            onChange={(e) => setConfirm(e.target.value)}
            required
          />
          <div className="login-buttons">
            <button type="submit" className="btn--primary" disabled={submitting || !(password && confirm)}>
              <LockKey weight="bold" size={18} />
              {submitting ? 'Resetting...' : 'Reset Password'}
            </button>
          </div>
        </form>
      </div>
    </main>
  );
}
