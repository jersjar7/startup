import React, { Suspense } from 'react';
import { BrowserRouter, Route, Routes, useLocation, useNavigate } from 'react-router-dom';
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
const QuickStart = React.lazy(() => import('./quickstart/QuickStart').then(m => ({ default: m.QuickStart })));
const DiagnosticExam = React.lazy(() => import('./diagnostic/DiagnosticExam').then(m => ({ default: m.DiagnosticExam })));
const DiagnosticResults = React.lazy(() => import('./diagnostic/DiagnosticResults').then(m => ({ default: m.DiagnosticResults })));
const DiagnosticReview = React.lazy(() => import('./diagnostic/DiagnosticReview').then(m => ({ default: m.DiagnosticReview })));
const ExamGate = React.lazy(() => import('./exam/ExamGate').then(m => ({ default: m.ExamGate })));
const ExamSession = React.lazy(() => import('./exam/ExamSession').then(m => ({ default: m.ExamSession })));
const ExamResults = React.lazy(() => import('./exam/ExamResults').then(m => ({ default: m.ExamResults })));
const ExamReview = React.lazy(() => import('./exam/ExamReview').then(m => ({ default: m.ExamReview })));
const ResetPassword = React.lazy(() => import('./login/ResetPassword').then(m => ({ default: m.ResetPassword })));
const VerifyEmail = React.lazy(() => import('./login/VerifyEmail').then(m => ({ default: m.VerifyEmail })));
const Profile = React.lazy(() => import('./profile/profile').then(m => ({ default: m.Profile })));
const Admin = React.lazy(() => import('./admin/admin').then(m => ({ default: m.Admin })));
const ExamGuide = React.lazy(() => import('./public/ExamGuide').then(m => ({ default: m.ExamGuide })));
const PublicTopic = React.lazy(() => import('./public/PublicTopic').then(m => ({ default: m.PublicTopic })));
const MitchStory = React.lazy(() => import('./stories/MitchStory').then(m => ({ default: m.MitchStory })));

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
const Hero3DDemo = import.meta.env.DEV
  ? React.lazy(() => import('./dev/Hero3DDemo').then(m => ({ default: m.Hero3DDemo })))
  : null;
const HeroTiles = import.meta.env.DEV
  ? React.lazy(() => import('./dev/HeroTiles').then(m => ({ default: m.HeroTiles })))
  : null;

export default function App() {
  const [userName, setUserName] = React.useState('');
  const [emailVerified, setEmailVerified] = React.useState(true);
  const [me, setMe] = React.useState({});
  const [authLoading, setAuthLoading] = React.useState(true);

  React.useEffect(() => {
    let cancelled = false;
    async function checkAuth(attempt = 0) {
      try {
        const res = await fetch('/api/user/me');
        if (res.ok) {
          const data = await res.json();
          if (!cancelled) {
            setUserName(data.email);
            setEmailVerified(data.emailVerified ?? true);
            setMe({ displayName: data.displayName, firstName: data.firstName, lastName: data.lastName, examDate: data.examDate });
          }
          return;
        }
        // Only a real 401 means "not logged in".
        if (res.status === 401) {
          if (!cancelled) setUserName('');
          return;
        }
        // 429 / 5xx / network blip — transient. Don't drop the session; retry.
        throw new Error('transient');
      } catch {
        if (attempt < 3 && !cancelled) {
          await new Promise((r) => setTimeout(r, 600 * (attempt + 1)));
          return checkAuth(attempt + 1);
        }
        // After retries, leave auth state as-is rather than forcing a logout.
      }
    }
    checkAuth().finally(() => {
      if (!cancelled) setAuthLoading(false);
    });
    return () => { cancelled = true; };
  }, []);

  // Capture acquisition (utm params + external referrer) once, on first load,
  // before signup — stored locally and sent with the register call so we know
  // where new users came from even when they navigate around first.
  React.useEffect(() => {
    try {
      if (localStorage.getItem('fe4r_acq')) return;
      const params = new URLSearchParams(window.location.search);
      const ref = document.referrer || '';
      const external = ref && !ref.includes(window.location.host);
      const utmSource = params.get('utm_source') || undefined;
      const utmMedium = params.get('utm_medium') || undefined;
      const utmCampaign = params.get('utm_campaign') || undefined;
      if (utmSource || external) {
        localStorage.setItem('fe4r_acq', JSON.stringify({
          utmSource, utmMedium, utmCampaign,
          referrer: external ? ref : undefined,
          landingPath: window.location.pathname,
        }));
      }
    } catch { /* ignore */ }
  }, []);

  // Login/register now return verified status + profile, so set it all
  // synchronously — no second /me round-trip, no verification-banner flash.
  function onLogin(data) {
    setUserName(data.email);
    setEmailVerified(data.emailVerified === true);
    setMe({ displayName: data.displayName, firstName: data.firstName, lastName: data.lastName, examDate: data.examDate });
  }

  // Clear in-memory auth when the server reports the session is gone.
  const onSessionExpired = React.useCallback(() => {
    setUserName('');
    setMe({});
    setEmailVerified(true);
  }, []);

  // Install a one-time fetch interceptor: if any authenticated API call returns
  // 401 mid-session (e.g. the token TTL lapses), trigger a clean logout+redirect
  // instead of a silent broken page. Excludes the auth-check and auth endpoints
  // so the normal logged-out flows don't loop.
  React.useEffect(() => {
    const orig = window.fetch;
    window.fetch = async (...args) => {
      const res = await orig(...args);
      try {
        const url = typeof args[0] === 'string' ? args[0] : (args[0] && args[0].url) || '';
        if (res.status === 401 && url.includes('/api/')
          && !url.includes('/api/user/me') && !url.includes('/api/auth/')) {
          window.dispatchEvent(new Event('fe4r:session-expired'));
        }
      } catch { /* ignore */ }
      return res;
    };
    return () => { window.fetch = orig; };
  }, []);

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
      <AppShell userName={userName} emailVerified={emailVerified} me={me} onLogin={onLogin} onLogout={onLogout} onSessionExpired={onSessionExpired} />
    </BrowserRouter>
  );
}

function AppShell({ userName, emailVerified, me = {}, onLogin, onLogout, onSessionExpired }) {
  const { pathname } = useLocation();
  const navigate = useNavigate();

  // A mid-session 401 (from the fetch interceptor) → clean logout + redirect.
  React.useEffect(() => {
    const handler = () => {
      if (!userName) return;
      onSessionExpired();
      navigate('/login', { state: { expired: true } });
    };
    window.addEventListener('fe4r:session-expired', handler);
    return () => window.removeEventListener('fe4r:session-expired', handler);
  }, [userName, onSessionExpired, navigate]);

  const isLanding = pathname === '/';
  const isLesson = pathname.startsWith('/lesson/');
  const isDiagnostic = pathname.startsWith('/diagnostic');
  const isQuickstart = pathname.startsWith('/quickstart');
  const isDashboard = pathname === '/dashboard';
  const isExamSession = pathname === '/exam/session' || pathname === '/exam/preview';

  return (
    <div className="body">
      <ErrorBoundary>
        {!isLanding && !isLesson && !isDiagnostic && !isQuickstart && !isExamSession && <Header userName={userName} />}
        {userName && !isLanding && !isDiagnostic && !isQuickstart && !isDashboard && !isExamSession && <VerificationBanner emailVerified={emailVerified} />}

        <Suspense fallback={<LoadingState />}>
          <Routes>
            <Route path="/" element={<Landing userName={userName} />} />
            <Route path="/login" element={<Login userName={userName} onLogin={onLogin} />} />
            <Route path="/reset-password/:token" element={<ResetPassword />} />
            <Route path="/verify-email/:token" element={<VerifyEmail />} />
            <Route path="/terms" element={<Terms />} />
            <Route path="/privacy" element={<Privacy />} />
            <Route path="/fe-civil-exam-guide" element={<ExamGuide />} />
            <Route path="/fe-civil/:topicId" element={<PublicTopic />} />
            <Route path="/stories/mitch" element={<MitchStory />} />
            <Route path="/profile" element={<Profile userName={userName} onLogout={onLogout} />} />
            <Route path="/dashboard" element={<Dashboard userName={userName} onLogout={onLogout} displayName={me.displayName} firstName={me.firstName} examDate={me.examDate} emailVerified={emailVerified} />} />
            <Route path="/admin" element={<Admin userName={userName} onLogout={onLogout} />} />
            <Route path="/study/:topicId" element={<Study userName={userName} onLogout={onLogout} displayName={me.displayName} />} />
            <Route path="/problems/:topicId" element={<Problems userName={userName} onLogout={onLogout} />} />
            <Route path="/review" element={<Problems userName={userName} onLogout={onLogout} reviewMode />} />
            <Route path="/lesson/:chapterId/:lessonId" element={<LessonPage userName={userName} onLogout={onLogout} />} />
            <Route path="/quickstart" element={<QuickStart userName={userName} />} />
            <Route path="/diagnostic" element={<DiagnosticExam userName={userName} />} />
            <Route path="/diagnostic/results/:attemptNumber" element={<DiagnosticResults userName={userName} />} />
            <Route path="/diagnostic/review/:attemptNumber" element={<DiagnosticReview userName={userName} />} />
            <Route path="/exam" element={<ExamGate userName={userName} />} />
            <Route path="/exam/session" element={<ExamSession userName={userName} />} />
          <Route path="/exam/preview" element={<ExamSession userName={userName} preview />} />
            <Route path="/exam/results/:attemptId" element={<ExamResults userName={userName} />} />
            <Route path="/exam/review/:attemptId" element={<ExamReview userName={userName} />} />
            {Hero3DDemo && <Route path="/dev/hero" element={<Hero3DDemo />} />}
            {HeroTiles && <Route path="/dev/hero-tile" element={<HeroTiles />} />}
            {DiagramPreview && <Route path="/dev/diagrams" element={<DiagramPreview />} />}
            {QuestionAuditIndex && <Route path="/dev/audit" element={<QuestionAuditIndex />} />}
            {QuestionAudit && <Route path="/dev/audit/:chapterId" element={<QuestionAudit />} />}
            <Route path="*" element={<NotFound />} />
          </Routes>
        </Suspense>

        {!isLanding && !isLesson && !isDiagnostic && !isQuickstart && !isExamSession && <Footer />}
      </ErrorBoundary>
    </div>
  );
}
