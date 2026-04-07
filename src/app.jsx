import React, { Suspense } from 'react';
import { BrowserRouter, Route, Routes, useLocation } from 'react-router-dom';
import { Header } from './components/Header';
import { Footer } from './components/Footer';
import { VerificationBanner } from './components/VerificationBanner';
import { LoadingState } from './components/LoadingState';
import { NotFound } from './components/NotFound';
import { ErrorBoundary } from './components/ErrorBoundary';
import { Landing } from './landing/landing';
import { Terms } from './legal/terms';
import { Privacy } from './legal/privacy';
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
const ExamGate = React.lazy(() => import('./exam/ExamGate').then(m => ({ default: m.ExamGate })));
const ExamSession = React.lazy(() => import('./exam/ExamSession').then(m => ({ default: m.ExamSession })));
const ExamResults = React.lazy(() => import('./exam/ExamResults').then(m => ({ default: m.ExamResults })));
const ResetPassword = React.lazy(() => import('./login/ResetPassword').then(m => ({ default: m.ResetPassword })));
const VerifyEmail = React.lazy(() => import('./login/VerifyEmail').then(m => ({ default: m.VerifyEmail })));
const Profile = React.lazy(() => import('./profile/profile').then(m => ({ default: m.Profile })));

// Dev tools — only available in dev mode
const DiagramPreview = import.meta.env.DEV
  ? React.lazy(() => import('./dev/DiagramPreview').then(m => ({ default: m.DiagramPreview })))
  : null;
const QuestionAudit = import.meta.env.DEV
  ? React.lazy(() => import('./dev/QuestionAudit').then(m => ({ default: m.QuestionAudit })))
  : null;
const QuestionAuditIndex = import.meta.env.DEV
  ? React.lazy(() => import('./dev/QuestionAudit').then(m => ({ default: m.QuestionAuditIndex })))
  : null;

export default function App() {
  const [userName, setUserName] = React.useState('');
  const [emailVerified, setEmailVerified] = React.useState(true);
  const [authLoading, setAuthLoading] = React.useState(true);

  React.useEffect(() => {
    fetch('/api/user/me')
      .then((res) => {
        if (res.ok) return res.json();
        throw new Error('Not authenticated');
      })
      .then((data) => {
        setUserName(data.email);
        setEmailVerified(data.emailVerified ?? true);
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
    // Re-fetch to get emailVerified status
    fetch('/api/user/me')
      .then((res) => res.ok ? res.json() : Promise.reject())
      .then((data) => setEmailVerified(data.emailVerified ?? true))
      .catch(() => {});
  }

  function onLogout() {
    fetch('/api/auth/logout', { method: 'DELETE' })
      .catch(() => {})
      .finally(() => {
        setUserName('');
        setEmailVerified(true);
      });
  }

  if (authLoading) {
    return <div className="body"><LoadingState /></div>;
  }

  return (
    <BrowserRouter>
      <AppShell userName={userName} emailVerified={emailVerified} onLogin={onLogin} onLogout={onLogout} />
    </BrowserRouter>
  );
}

function AppShell({ userName, emailVerified, onLogin, onLogout }) {
  const { pathname } = useLocation();
  const isLanding = pathname === '/';
  const isLesson = pathname.startsWith('/lesson/');
  const isDiagnostic = pathname.startsWith('/diagnostic');
  const isExamSession = pathname === '/exam/session';

  return (
    <div className="body">
      <ErrorBoundary>
        {!isLanding && !isLesson && !isDiagnostic && !isExamSession && <Header userName={userName} />}
        {userName && !isLanding && <VerificationBanner emailVerified={emailVerified} />}

        <Suspense fallback={<LoadingState />}>
          <Routes>
            <Route path="/" element={<Landing userName={userName} />} />
            <Route path="/login" element={<Login userName={userName} onLogin={onLogin} />} />
            <Route path="/reset-password/:token" element={<ResetPassword />} />
            <Route path="/verify-email/:token" element={<VerifyEmail />} />
            <Route path="/terms" element={<Terms />} />
            <Route path="/privacy" element={<Privacy />} />
            <Route path="/profile" element={<Profile userName={userName} onLogout={onLogout} />} />
            <Route path="/dashboard" element={<Dashboard userName={userName} onLogout={onLogout} />} />
            <Route path="/study/:topicId" element={<Study userName={userName} onLogout={onLogout} />} />
            <Route path="/problems/:topicId" element={<Problems userName={userName} onLogout={onLogout} />} />
            <Route path="/review" element={<Problems userName={userName} onLogout={onLogout} reviewMode />} />
            <Route path="/lesson/:chapterId/:lessonId" element={<LessonPage userName={userName} onLogout={onLogout} />} />
            <Route path="/diagnostic" element={<DiagnosticExam userName={userName} />} />
            <Route path="/diagnostic/results/:attemptNumber" element={<DiagnosticResults userName={userName} />} />
            <Route path="/diagnostic/review/:attemptNumber" element={<DiagnosticReview userName={userName} />} />
            <Route path="/exam" element={<ExamGate userName={userName} />} />
            <Route path="/exam/session" element={<ExamSession userName={userName} />} />
            <Route path="/exam/results/:attemptId" element={<ExamResults userName={userName} />} />
            {DiagramPreview && <Route path="/dev/diagrams" element={<DiagramPreview />} />}
            {QuestionAuditIndex && <Route path="/dev/audit" element={<QuestionAuditIndex />} />}
            {QuestionAudit && <Route path="/dev/audit/:chapterId" element={<QuestionAudit />} />}
            <Route path="*" element={<NotFound />} />
          </Routes>
        </Suspense>

        {!isLanding && !isLesson && !isDiagnostic && !isExamSession && <Footer />}
      </ErrorBoundary>
    </div>
  );
}
