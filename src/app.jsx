import React from 'react';
import { BrowserRouter, Route, Routes } from 'react-router-dom';
import { Login } from './login/login';
import { Dashboard } from './dashboard/dashboard';
import { Study } from './study/study';
import { Problems } from './problems/problems';
import './app.css';

export default function App() {
  const [userName, setUserName] = React.useState('');
  const [authLoading, setAuthLoading] = React.useState(true);

  React.useEffect(() => {
    fetch('/api/user/me')
      .then((res) => {
        if (res.ok) return res.json();
        throw new Error('Not authenticated');
      })
      .then((data) => {
        setUserName(data.email);
      })
      .catch(() => {
        setUserName('');
      })
      .finally(() => {
        setAuthLoading(false);
      });
  }, []);

  function onLogin(email) {
    setUserName(email);
  }

  function onLogout() {
    fetch('/api/auth/logout', { method: 'DELETE' })
      .catch(() => {})
      .finally(() => {
        setUserName('');
      });
  }

  if (authLoading) {
    return <div className="body"><p>Loading...</p></div>;
  }

  return (
    <BrowserRouter>
      <div className="body">
        <header>
          <h1 id="app-title">FE for Raccoons</h1>
          <h4 id="app-slogan">All you need to pass the Fundamentals of Engineering exam in one place!</h4>
        </header>

        <Routes>
          <Route path="/" element={<Login userName={userName} onLogin={onLogin} />} exact />
          <Route path="/dashboard" element={<Dashboard userName={userName} onLogout={onLogout} />} />
          <Route path="/study/:topicId" element={<Study userName={userName} onLogout={onLogout} />} />
          <Route path="/problems/:topicId" element={<Problems userName={userName} onLogout={onLogout} />} />
          <Route path="/review" element={<Problems userName={userName} onLogout={onLogout} reviewMode />} />
          <Route path="*" element={<NotFound />} />
        </Routes>

        <footer>
          <p>Created by Jerson J. Garcia</p>
          <p>
            <a href="https://github.com/jersjar7/startup" target="_blank">GitHub Repository</a>
          </p>
        </footer>
      </div>
    </BrowserRouter>
  );
}

function NotFound() {
  return <main>404: Page not found</main>;
}
