import React from 'react';
import { useNavigate } from 'react-router-dom';
import './index.css';

export function Login({ userName, onLogin }) {
  const navigate = useNavigate();
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
        <h2>Login / Register</h2>
        {error && <p className="error-banner">{error}</p>}
        <form onSubmit={handleLogin}>
          <input
            type="text"
            placeholder="Email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
          <input
            type="password"
            placeholder="Password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
          <div className="login-buttons">
            <button type="submit" disabled={submitting || !(email && password)}>
              {submitting ? 'Logging in...' : 'Login'}
            </button>
            <button type="button" className="btn-register" disabled={submitting || !(email && password)} onClick={handleRegister}>
              {submitting ? 'Please wait...' : 'Register'}
            </button>
          </div>
        </form>
      </div>
    </main>
  );
}
