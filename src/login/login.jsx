import React from 'react';
import './index.css';

export function Login() {
  return (
    <main className="login-main">
      <div className="login-form-container">
        <h2>Login / Register</h2>
        <form method="get" action="dashboard.html">
          <input type="text" id="username" name="username" placeholder="Username" required />
          <input type="password" id="password" name="password" placeholder="Password" required />
          <div className="login-buttons">
            <button type="submit">Login</button>
            <button type="button" className="btn-register">Register</button>
          </div>
        </form>
      </div>
    </main>
  );
}