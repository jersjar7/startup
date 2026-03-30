import React from 'react';
import { useNavigate } from 'react-router-dom';
import './index.css';

export function Login({ userName, onLogin }) {
  const navigate = useNavigate();
  const [email, setEmail] = React.useState('');
  const [password, setPassword] = React.useState('');
  const [error, setError] = React.useState('');

  React.useEffect(() => {
    if (userName) {
      navigate('/dashboard');
    }
  }, [userName, navigate]);

  async function handleLogin(e) {
    e.preventDefault();
    setError('');
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
  }

  async function handleRegister() {
    setError('');
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
  }

  return (
    <main className="login-main">
      <div className="login-form-container">
        <h2>Login / Register</h2>
        {error && <p style={{ color: '#c0392b', marginBottom: '1rem' }}>{error}</p>}
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
            <button type="submit" disabled={!(email && password)}>Login</button>
            <button type="button" className="btn-register" disabled={!(email && password)} onClick={handleRegister}>Register</button>
          </div>
        </form>
      </div>
    </main>
  );
}
