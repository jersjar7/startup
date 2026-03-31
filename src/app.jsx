import React from 'react';
import { BrowserRouter, Route, Routes, useLocation } from 'react-router-dom';
import { Header } from './components/Header';
import { Footer } from './components/Footer';
import { LoadingState } from './components/LoadingState';
import { Landing } from './landing/landing';
import { Login } from './login/login';
import { Dashboard } from './dashboard/dashboard';
import { Study } from './study/study';
import { Problems } from './problems/problems';
import { LessonPage } from './lesson/lesson';
import 'katex/dist/katex.min.css';
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
    return <div className="body"><LoadingState /></div>;
  }

  return (
    <BrowserRouter>
      <AppShell userName={userName} onLogin={onLogin} onLogout={onLogout} />
    </BrowserRouter>
  );
}

function AppShell({ userName, onLogin, onLogout }) {
  const { pathname } = useLocation();
  const isLanding = pathname === '/';
  const isLesson = pathname.startsWith('/lesson/');

  return (
    <div className="body">
      {!isLanding && !isLesson && <Header />}

      <Routes>
        <Route path="/" element={<Landing userName={userName} />} />
        <Route path="/login" element={<Login userName={userName} onLogin={onLogin} />} />
        <Route path="/dashboard" element={<Dashboard userName={userName} onLogout={onLogout} />} />
        <Route path="/study/:topicId" element={<Study userName={userName} onLogout={onLogout} />} />
        <Route path="/problems/:topicId" element={<Problems userName={userName} onLogout={onLogout} />} />
        <Route path="/review" element={<Problems userName={userName} onLogout={onLogout} reviewMode />} />
        <Route path="/lesson/:chapterId/:lessonId" element={<LessonPage userName={userName} onLogout={onLogout} />} />
        <Route path="*" element={<NotFound />} />
      </Routes>

      {!isLanding && !isLesson && <Footer />}
    </div>
  );
}

function NotFound() {
  return <main>404: Page not found</main>;
}
