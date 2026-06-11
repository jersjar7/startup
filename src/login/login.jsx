import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import { SignIn, UserPlus, PaperPlaneTilt, ArrowLeft, Eye, EyeSlash } from '@phosphor-icons/react';
import './index.css';

export function Login({ userName, onLogin }) {
  const navigate = useNavigate();
  const location = useLocation();
  // Where to go after auth — honor returnTo (e.g. a paid user sent here from /exam).
  const dest = location.state?.returnTo || '/dashboard';
  const sessionExpired = location.state?.expired === true;
  useDocumentTitle('Sign In');
  const [email, setEmail] = React.useState('');
  const [password, setPassword] = React.useState('');
  const [error, setError] = React.useState('');
  const [success, setSuccess] = React.useState('');
  const [submitting, setSubmitting] = React.useState(false);
  const [showForgot, setShowForgot] = React.useState(false);
  const [acceptedTerms, setAcceptedTerms] = React.useState(false);
  const [showPassword, setShowPassword] = React.useState(false);
  // One form, one mode at a time — returning users never parse signup chrome.
  const [mode, setMode] = React.useState('login'); // 'login' | 'create'

  React.useEffect(() => {
    if (userName) {
      navigate(dest);
    }
  }, [userName, navigate, dest]);

  async function handleLogin(e) {
    e.preventDefault();
    setError('');
    setSubmitting(true);
    try {
      const res = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      });
      if (res.ok) {
        const data = await res.json();
        onLogin(data);
        navigate(dest);
      } else {
        const body = await res.json();
        setError(body.msg || 'Login failed');
      }
    } catch {
      setError('Network error. Please check your connection.');
    } finally {
      setSubmitting(false);
    }
  }

  async function handleRegister() {
    setError('');
    // The button stays tappable — an unexplained dead button reads as broken.
    if (!acceptedTerms) {
      setError('Check the Terms box above to create an account.');
      return;
    }
    if (password.length < 8 || !/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/.test(password)) {
      setError('Password must be 8+ characters with uppercase, lowercase, and a number');
      return;
    }
    setSubmitting(true);
    let acq;
    try { acq = JSON.parse(localStorage.getItem('fe4r_acq') || 'null') || undefined; } catch { acq = undefined; }
    try {
      const res = await fetch('/api/auth/create', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password, acq }),
      });
      if (res.ok) {
        const data = await res.json();
        onLogin(data);
        navigate(dest);
      } else {
        const body = await res.json();
        setError(body.msg || 'Registration failed');
      }
    } catch {
      setError('Network error. Please check your connection.');
    } finally {
      setSubmitting(false);
    }
  }

  async function handleForgotPassword(e) {
    e.preventDefault();
    setError('');
    setSuccess('');
    if (!email) {
      setError('Please enter your email address');
      return;
    }
    setSubmitting(true);
    try {
      const res = await fetch('/api/auth/forgot-password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email }),
      });
      if (res.ok) {
        setSuccess('If that email exists, a reset link has been sent. Check your inbox.');
      } else {
        const body = await res.json();
        setError(body.msg || 'Something went wrong');
      }
    } catch {
      setError('Network error. Please check your connection.');
    } finally {
      setSubmitting(false);
    }
  }

  if (showForgot) {
    return (
      <main className="login-main">
        <div className="login-form-container">
          <h2>Reset Password</h2>
          <p className="login-subtitle">Enter your email and we'll send you a link to reset your password.</p>
          {error && <p className="error-banner" role="alert">{error}</p>}
          {success && <p className="success-banner" role="status">{success}</p>}
          <form onSubmit={handleForgotPassword}>
            <label className="login-label" htmlFor="forgot-email">Email</label>
            <input
              id="forgot-email"
              type="email"
              placeholder="you@example.com"
              autoComplete="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
            <div className="login-buttons">
              <button type="submit" className="btn--primary" disabled={submitting || !email}>
                <PaperPlaneTilt weight="bold" size={18} />
                {submitting ? 'Sending...' : 'Send Reset Link'}
              </button>
            </div>
          </form>
          <button
            type="button"
            className="forgot-link"
            onClick={() => { setShowForgot(false); setError(''); setSuccess(''); }}
          >
            <ArrowLeft size={16} />
            Back to login
          </button>
        </div>
      </main>
    );
  }

  return (
    <main className="login-main">
      <div className="login-form-container">
        <h2>Welcome to FE for Raccoons</h2>
        <p className="login-subtitle">Create your free account, or log in to pick up where you left off.</p>
        {sessionExpired && (
          <p role="status" style={{ background: 'var(--sunbeam-bg)', color: 'var(--charcoal)', padding: '0.6rem 0.8rem', borderRadius: '8px', fontSize: '0.85rem', marginBottom: '0.75rem' }}>
            Your session expired — please sign in again.
          </p>
        )}
        {error && <p className="error-banner" role="alert">{error}</p>}
        <form onSubmit={handleLogin}>
          <label className="login-label" htmlFor="login-email">Email</label>
          <input
            id="login-email"
            type="email"
            placeholder="you@example.com"
            autoComplete="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
          <label className="login-label" htmlFor="login-password">Password</label>
          <div className="password-field">
            <input
              id="login-password"
              type={showPassword ? 'text' : 'password'}
              placeholder="8+ characters"
              autoComplete="current-password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
            <button
              type="button"
              className="password-toggle"
              onClick={() => setShowPassword(!showPassword)}
              aria-label={showPassword ? 'Hide password' : 'Show password'}
            >
              {showPassword ? <EyeSlash size={18} /> : <Eye size={18} />}
            </button>
          </div>
          {mode === 'create' && (
            <p className="login-pw-hint">
              Use at least 8 characters with an uppercase letter, a lowercase letter, and a number.
            </p>
          )}
          {mode === 'login' && (
            <button
              type="button"
              className="forgot-link"
              onClick={() => { setShowForgot(true); setError(''); }}
            >
              Forgot password?
            </button>
          )}
          {mode === 'create' && (
            <label className="terms-checkbox">
              <input
                type="checkbox"
                checked={acceptedTerms}
                onChange={(e) => setAcceptedTerms(e.target.checked)}
              />
              <span>
                I agree to the{' '}
                <a href="/terms" target="_blank" rel="noopener noreferrer">Terms of Service</a>
                {' '}and{' '}
                <a href="/privacy" target="_blank" rel="noopener noreferrer">Privacy Policy</a>
              </span>
            </label>
          )}
          <div className="login-buttons">
            {mode === 'login' ? (
              <button type="submit" className="btn--primary" disabled={submitting || !(email && password)}>
                <SignIn weight="bold" size={18} />
                {submitting ? 'Logging in...' : 'Log in'}
              </button>
            ) : (
              <button type="button" className="btn--primary" disabled={submitting || !(email && password)} onClick={handleRegister}>
                <UserPlus weight="bold" size={18} />
                {submitting ? 'Please wait...' : 'Create account'}
              </button>
            )}
          </div>
          <p className="login-mode-toggle">
            {mode === 'login' ? (
              <>New here?{' '}
                <button type="button" className="forgot-link" onClick={() => { setMode('create'); setError(''); }}>
                  Create a free account
                </button>
              </>
            ) : (
              <>Have an account?{' '}
                <button type="button" className="forgot-link" onClick={() => { setMode('login'); setError(''); }}>
                  Log in
                </button>
              </>
            )}
          </p>
        </form>
      </div>
    </main>
  );
}
