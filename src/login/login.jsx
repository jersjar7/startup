import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import { SignIn, UserPlus } from '@phosphor-icons/react';
import './index.css';

export function Login({ userName, onLogin }) {
  const navigate = useNavigate();
  useDocumentTitle('Sign In');
  const [email, setEmail] = React.useState('');
  const [password, setPassword] = React.useState('');
  const [error, setError] = React.useState('');
  const [submitting, setSubmitting] = React.useState(false);

  React.useEffect(() => {
    if (userName) {
      navigate('/dashboard');
    }
  }, [userName, navigate]);

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
        onLogin(data.email);
        navigate('/dashboard');
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
    if (password.length < 8 || !/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/.test(password)) {
      setError('Password must be 8+ characters with uppercase, lowercase, and a number');
      return;
    }
    setSubmitting(true);
    try {
      const res = await fetch('/api/auth/create', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      });
      if (res.ok) {
        const data = await res.json();
        onLogin(data.email);
        navigate('/dashboard');
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

  return (
    <main className="login-main">
      <div className="login-form-container">
        <h2>Welcome Back</h2>
        <p className="login-subtitle">Sign in to continue your FE exam prep, or create a new account.</p>
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
          <input
            id="login-password"
            type="password"
            placeholder="8+ characters"
            autoComplete="current-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
          <div className="login-buttons">
            <button type="submit" className="btn--primary" disabled={submitting || !(email && password)}>
              <SignIn weight="bold" size={18} />
              {submitting ? 'Logging in...' : 'Login'}
            </button>
            <button type="button" className="btn--secondary" disabled={submitting || !(email && password)} onClick={handleRegister}>
              <UserPlus weight="bold" size={18} />
              {submitting ? 'Please wait...' : 'Register'}
            </button>
          </div>
        </form>
      </div>
    </main>
  );
}
