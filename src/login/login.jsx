import React from 'react';
import { useNavigate } from 'react-router-dom';
import './index.css';

export function Login() {
  const navigate = useNavigate();
  const [username, setUsername] = React.useState('');
  const [password, setPassword] = React.useState('');

  // Check if user is already logged in
  React.useEffect(() => {
    const storedUser = localStorage.getItem('userName');
    if (storedUser) {
      navigate('/dashboard');
    }
  }, [navigate]);

  const handleLogin = (e) => {
    e.preventDefault();
    if (username) {
      localStorage.setItem('userName', username);
      navigate('/dashboard');
    }
  };

  return (
    <main className="login-main">
      <div className="login-form-container">
        <h2>Login / Register</h2>
        <form onSubmit={handleLogin}>
          <input 
            type="text" 
            placeholder="Username" 
            value={username}
            onChange={(e) => setUsername(e.target.value)}
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
            <button type="submit">Login</button>
            <button type="button" className="btn-register" onClick={handleLogin}>Register</button>
          </div>
        </form>
      </div>
    </main>
  );
}