import React from 'react';
import { useNavigate } from 'react-router-dom';
import './index.css';

export function Login() {
  const navigate = useNavigate();

  const handleLogin = (e) => {
    e.preventDefault();
    navigate('/dashboard');
  };

  return (
    <main className="login-main">
      <div className="login-form-container">
        <h2>Login / Register</h2>
        <form onSubmit={handleLogin}>
          <input type="text" id="username" name="username" placeholder="Username" required />
          <input type="password" id="password" name="password" placeholder="Password" required />
          <div className="login-buttons">
            <button type="submit">Login</button>
            <button type="button" className="btn-register" onClick={handleLogin}>Register</button>
          </div>
        </form>
      </div>
    </main>
  );
}