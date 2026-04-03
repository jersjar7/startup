import React, { Suspense } from 'react';
import { BrowserRouter, Route, Routes, useLocation } from 'react-router-dom';
import { Header } from './components/Header';
import { Footer } from './components/Footer';
import { LoadingState } from './components/LoadingState';
import { Landing } from './landing/landing';
import 'katex/dist/katex.min.css';
import './app.css';

// Lazy-loaded routes (named-export adapter)
const Login = React.lazy(() => import('./login/login').then(m => ({ default: m.Login })));
const Dashboard = React.lazy(() => import('./dashboard/dashboard').then(m => ({ default: m.Dashboard })));
const Study = React.lazy(() => import('./study/study').then(m => ({ default: m.Study })));
const Problems = React.lazy(() => import('./problems/problems').then(m => ({ default: m.Problems })));
const LessonPage = React.lazy(() => import('./lesson/lesson').then(m => ({ default: m.LessonPage })));
const DiagnosticExam = React.lazy(() => import('./diagnostic/DiagnosticExam').then(m => ({ default: m.DiagnosticExam })));
const DiagnosticResults = React.lazy(() => import('./diagnostic/DiagnosticResults').then(m => ({ default: m.DiagnosticResults })));
const DiagnosticReview = React.lazy(() => import('./diagnostic/DiagnosticReview').then(m => ({ default: m.DiagnosticReview })));

// DiagramPreview only available in dev mode
const DiagramPreview = import.meta.env.DEV
  ? React.lazy(() => import('./dev/DiagramPreview').then(m => ({ default: m.DiagramPreview })))
  : null;

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
  const isDiagnostic = pathname.startsWith('/diagnostic');

  return (
    <div className="body">
      {!isLanding && !isLesson && !isDiagnostic && <Header />}

      <Suspense fallback={<LoadingState />}>
        <Routes>
          <Route path="/" element={<Landing userName={userName} />} />
          <Route path="/login" element={<Login userName={userName} onLogin={onLogin} />} />
          <Route path="/dashboard" element={<Dashboard userName={userName} onLogout={onLogout} />} />
          <Route path="/study/:topicId" element={<Study userName={userName} onLogout={onLogout} />} />
          <Route path="/problems/:topicId" element={<Problems userName={userName} onLogout={onLogout} />} />
          <Route path="/review" element={<Problems userName={userName} onLogout={onLogout} reviewMode />} />
          <Route path="/lesson/:chapterId/:lessonId" element={<LessonPage userName={userName} onLogout={onLogout} />} />
          <Route path="/diagnostic" element={<DiagnosticExam userName={userName} />} />
          <Route path="/diagnostic/results/:attemptNumber" element={<DiagnosticResults userName={userName} />} />
          <Route path="/diagnostic/review/:attemptNumber" element={<DiagnosticReview userName={userName} />} />
          {DiagramPreview && <Route path="/dev/diagrams" element={<DiagramPreview />} />}
          <Route path="*" element={<NotFound />} />
        </Routes>
      </Suspense>

      {!isLanding && !isLesson && !isDiagnostic && <Footer />}
    </div>
  );
}

function NotFound() {
  return <main>404: Page not found</main>;
}
