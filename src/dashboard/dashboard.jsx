import React from 'react';
import { useNavigate } from 'react-router-dom';
import { SourcePrompt } from './SourcePrompt';
import { shouldAskSource } from './acquisitionGate';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import { SimPitchBanner } from './SimPitchBanner';
import {
  Lightning,
  DeviceMobile,
  CheckCircle,
  Fire,
  Timer,
  Trophy,
  Users,
  Pulse,
  Info,
  ArrowRight,
  BookOpenText,
  Megaphone,
  Gauge,
  Target,
  CalendarBlank,
  X,
  CaretDown,
} from '@phosphor-icons/react';
import { CHAPTERS } from '../data/chapters';
import { getExamWeight } from '../data/exam-bank/index';
import { computeReadiness, computeFocusAreas, readinessLabel } from '../data/readiness';

// "2026-W24" is debug output, not product copy — show "Week of Jun 8".
function formatWeekLabel(weekId) {
  const m = /^(\d{4})-W(\d{1,2})$/.exec(weekId || '');
  if (!m) return `Week ${weekId}`;
  const [, year, week] = m;
  // ISO week → Monday of that week
  const jan4 = new Date(Number(year), 0, 4);
  const monday = new Date(jan4);
  monday.setDate(jan4.getDate() - ((jan4.getDay() + 6) % 7) + (Number(week) - 1) * 7);
  return `Week of ${monday.toLocaleDateString(undefined, { month: 'short', day: 'numeric' })}`;
}

// Exam-Qs badge color encodes weight on one scale — never the chapter accent.
function weightClass(weight) {
  if (weight >= 11) return 'ember';
  if (weight >= 7) return 'sunbeam';
  return 'muted';
}
import { PROBLEM_COUNT } from '../data/contentStats';
import { LoadingState } from '../components/LoadingState';
import { DiagnosticCard } from '../diagnostic/DiagnosticCard';
import { ExamSimCard } from '../exam/ExamSimCard';
import { ScoringModal } from './ScoringModal';
import { SetupTodo } from './SetupTodo';
import './dashboard.css';

// Live-activity presence arrives as { from, topic } (practice) or
// { from, chapter, lesson } (lessons). Resolve a readable label from whichever
// shape it is and humanize ids like "mechanics-materials" -> "Mechanics Materials".
function prettyTopic(event) {
  const raw = event.topic || event.chapter || event.lesson || '';
  if (!raw) return 'the FE';
  return /[-_]/.test(raw)
    ? raw.replace(/[-_]+/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase())
    : raw.charAt(0).toUpperCase() + raw.slice(1);
}

export function Dashboard({ userName, onLogout, displayName, firstName, examDate, emailVerified }) {
  const navigate = useNavigate();
  useDocumentTitle('Dashboard');
  // Shown to other users in Live Activity — never the raw email.
  const examDays = examDate
    ? Math.ceil((new Date(`${examDate}T00:00:00`).getTime() - Date.now()) / 86400000)
    : null;
  // Only prompt for what's actually still missing (name, exam date, or both).
  const needName = !firstName;
  const needExam = examDays === null;
  const personalizeMsg = needName && needExam
    ? 'Add your name and exam date so we can count down to exam day and show your name (not your email) in Live Activity.'
    : needName
      ? 'Add your name so we can show it (not your email) in the leaderboard and Live Activity.'
      : 'Add your exam date so we can count down to exam day on your dashboard.';
  const [profilePromptDismissed, setProfilePromptDismissed] = React.useState(
    () => { try { return localStorage.getItem('fe4r-profile-prompt') === 'dismissed'; } catch { return false; } },
  );
  const dismissProfilePrompt = () => {
    try { localStorage.setItem('fe4r-profile-prompt', 'dismissed'); } catch { /* ignore */ }
    setProfilePromptDismissed(true);
  };
  const [stats, setStats] = React.useState({ totalXp: 0, currentStreak: 0, badges: [], allBadges: [] });
  const [showAllBadges, setShowAllBadges] = React.useState(false);
  // Earned achievements first, then the rest; collapsed to 3 so the column's
  // other sections (leaderboard, live activity, share) stay above the fold.
  const earnedBadgeIds = React.useMemo(() => new Set(stats.badges.map((b) => b.id)), [stats.badges]);
  const sortedBadges = React.useMemo(
    () => [...stats.allBadges].sort((a, b) => (earnedBadgeIds.has(b.id) ? 1 : 0) - (earnedBadgeIds.has(a.id) ? 1 : 0)),
    [stats.allBadges, earnedBadgeIds],
  );
  const visibleBadges = showAllBadges ? sortedBadges : sortedBadges.slice(0, 3);
  const [leaderboard, setLeaderboard] = React.useState({ weekId: '', entries: [], allTime: [] });
  const [lbTab, setLbTab] = React.useState('week');
  const [loading, setLoading] = React.useState(true);
  // Attribution safety net. New users are asked at sign-up
  // (src/login/login.jsx); this catches anyone who slipped past that. Seeded
  // `true` so a slow or failed /me never triggers a duplicate ask.
  const [acqResolved, setAcqResolved] = React.useState(true);
  const [problemsAnswered, setProblemsAnswered] = React.useState(0);
  const [error, setError] = React.useState('');
  const [events, setEvents] = React.useState([]);
  const [socket, setSocket] = React.useState(null);
  const [diagnosticStatus, setDiagnosticStatus] = React.useState({
    diagnosticCompleted: false,
    diagnosticSkipped: false,
    canRetake: false,
    chaptersAt60: 0,
    chaptersNeeded: 11,
    lastScore: undefined,
    lastDate: undefined,
  });
  const [chapterMastery, setChapterMastery] = React.useState({});
  const [quickstart, setQuickstart] = React.useState({ sampledCount: 0, totalChapters: 15, nextChapterId: null });
  const [phoneToday, setPhoneToday] = React.useState(null);
  const [syncState, setSyncState] = React.useState(null); // { at, device, source } — last sync from any device

  // A left-open dashboard should notice phone work without a reload — light
  // poll of the activity endpoint while the tab is visible (sync v1; the /ws
  // push upgrade can replace this later).
  React.useEffect(() => {
    const tick = () => {
      if (document.visibilityState !== 'visible') return;
      fetch(`/api/sync/today?date=${new Date().toLocaleDateString('en-CA')}`)
        .then((r) => (r.ok ? r.json() : null))
        .then((d) => {
          if (!d) return;
          if (d.cards > 0 || (d.paperFlags && d.paperFlags.length > 0)) setPhoneToday(d);
          if (d.lastSync) setSyncState(d.lastSync);
        })
        .catch(() => {});
    };
    const id = setInterval(tick, 60000);
    return () => clearInterval(id);
  }, []);
  const [scoringOpen, setScoringOpen] = React.useState(false);
  const [reviewDue, setReviewDue] = React.useState(0);

  React.useEffect(() => {
    if (!userName) {
      navigate('/');
      return;
    }

    Promise.allSettled([
      fetch('/api/user/me').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
      fetch('/api/leaderboard').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
      fetch('/api/diagnostic/can-retake').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
      fetch('/api/diagnostic/mastery').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
      fetch('/api/diagnostic/history').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
      fetch('/api/review/count').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
      fetch('/api/leaderboard/alltime').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
      fetch('/api/quickstart/state').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
      fetch(`/api/sync/today?date=${new Date().toLocaleDateString('en-CA')}`).then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
    ]).then(([statsResult, lbResult, retakeResult, masteryResult, historyResult, reviewCountResult, allTimeResult, quickstartResult, phoneTodayResult]) => {
      const errors = [];
      if (statsResult.status === 'fulfilled') {
        const data = statsResult.value;
        setStats({
          totalXp: data.totalXp || 0,
          currentStreak: data.currentStreak || 0,
          badges: data.badges || [],
          allBadges: data.allBadges || [],
        });
        // Server-side truth: answered OR dismissed, on any device.
        setAcqResolved(Boolean(data.acquisitionResolved));
        setProblemsAnswered(data.problemsAnswered || 0);
      } else {
        errors.push('stats');
      }
      if (lbResult.status === 'fulfilled') {
        setLeaderboard((prev) => ({ ...prev, weekId: lbResult.value.weekId, entries: lbResult.value.leaderboard || [] }));
      }
      if (allTimeResult.status === 'fulfilled') {
        setLeaderboard((prev) => ({ ...prev, allTime: allTimeResult.value.leaderboard || [] }));
      }
      if (quickstartResult.status === 'fulfilled') {
        setQuickstart(quickstartResult.value);
      }
      if (phoneTodayResult.status === 'fulfilled') {
        const pt = phoneTodayResult.value;
        // Show if there was any phone work OR anything set aside for paper.
        if (pt.cards > 0 || (pt.paperFlags && pt.paperFlags.length > 0)) setPhoneToday(pt);
        if (pt.lastSync) setSyncState(pt.lastSync);
      }

      // Diagnostic status
      const diagStatus = {
        diagnosticCompleted: false,
        diagnosticSkipped: localStorage.getItem('diagnosticSkipped') === 'true',
        diagnosticAttempts: 0,
        canRetake: false,
        chaptersAt60: 0,
        chaptersNeeded: 11,
        lastScore: undefined,
        lastDate: undefined,
      };
      if (retakeResult.status === 'fulfilled') {
        const r = retakeResult.value;
        diagStatus.diagnosticCompleted = r.diagnosticCompleted;
        diagStatus.diagnosticAttempts = r.diagnosticAttempts || 0;
        diagStatus.canRetake = r.canRetake;
        diagStatus.chaptersAt60 = r.chaptersAt60 || 0;
        diagStatus.chaptersNeeded = r.chaptersNeeded || 11;
      }
      if (historyResult.status === 'fulfilled' && historyResult.value.length > 0) {
        const latest = historyResult.value[0];
        diagStatus.lastScore = { correct: latest.totalCorrect, total: latest.totalQuestions };
        diagStatus.lastDate = latest.completedAt;
      }
      setDiagnosticStatus(diagStatus);

      // Chapter mastery from diagnostic
      if (masteryResult.status === 'fulfilled') {
        setChapterMastery(masteryResult.value.chapterMastery || {});
      }

      // Reviews due (for the Review badge)
      if (reviewCountResult.status === 'fulfilled') {
        setReviewDue(reviewCountResult.value.count || 0);
      }

      if (errors.length > 0) {
        setError('Failed to load some data. Try refreshing the page.');
      }
      setLoading(false);
    });

    const protocol = window.location.protocol === 'http:' ? 'ws' : 'wss';
    const ws = new WebSocket(`${protocol}://${window.location.host}/ws`);

    // Listen only — presence is broadcast from real lessons/practice sessions,
    // not from just having the dashboard open.
    ws.onmessage = (event) => {
      // Frames may arrive as a string or a Blob; parse defensively either way.
      const handle = (text) => {
        try {
          const msg = JSON.parse(text);
          // One row per user (their latest activity) — clients re-broadcast on
          // every WebSocket reconnect, so dedupe by `from` to avoid repeats.
          setEvents((prev) => [msg, ...prev.filter((e) => e.from !== msg.from)].slice(0, 10));
        } catch {
          /* ignore malformed frames */
        }
      };
      if (typeof event.data === 'string') {
        handle(event.data);
      } else if (event.data && typeof event.data.text === 'function') {
        event.data.text().then(handle).catch(() => {});
      }
    };

    setSocket(ws);
    return () => ws.close();
  }, [userName, navigate]);

  const handleChapterClick = (chapter) => {
    // Presence is broadcast once the study page actually loads — not on click.
    navigate(`/study/${chapter.id}`);
  };


  // Mastery is a single source of truth: chapterMastery[ch.id].totalMastery,
  // written by the diagnostic AND by practice/review (studyScore).
  // Stage words match the phone exactly (same thresholds) — one vocabulary.
  const stageName = (pct) => {
    if (pct >= 80) return 'Mastered';
    if (pct >= 50) return 'Familiar';
    if (pct >= 10) return 'Building';
    return 'New';
  };
  const getProgress = (chapter) => {
    const cm = chapterMastery[chapter.id];
    const pct = cm && cm.totalMastery > 0 ? cm.totalMastery : 0;
    return {
      masteryPct: pct,
      masteryName: stageName(pct),
      decaying: false,
    };
  };

  function getMasteryColor(pct) {
    if (pct >= 90) return 'var(--forest)';
    if (pct >= 70) return 'var(--sunbeam)';
    if (pct > 0) return 'var(--ember)'; // low = warm start, never error-red
    return 'var(--gray-200)';
  }

  /* Mastery % per chapter — fed into the shared readiness/focus model so the
     dashboard and the post-session summary agree. Single source: chapterMastery. */
  const masteryByChapterId = React.useMemo(
    () => Object.fromEntries(CHAPTERS.map((ch) => [ch.id, getProgress(ch).masteryPct])),
    [chapterMastery],
  );

  const readiness = React.useMemo(() => computeReadiness(masteryByChapterId), [masteryByChapterId]);
  const focusAreas = React.useMemo(() => computeFocusAreas(masteryByChapterId), [masteryByChapterId]);
  const hasActivity = React.useMemo(
    () => stats.totalXp > 0 || Object.values(masteryByChapterId).some((p) => p > 0),
    [stats.totalXp, masteryByChapterId],
  );


  // Ask until resolved, never after. The never-ask-twice rule lives in
  // shouldAskSource(), which is unit tested.
  const showSource = shouldAskSource({ acquisitionResolved: acqResolved });

  // Freeze the page behind the modal so the dashboard does not scroll under it.
  React.useEffect(() => {
    if (!showSource) return undefined;
    const prev = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => { document.body.style.overflow = prev; };
  }, [showSource]);

  // SourcePrompt has already POSTed the answer by the time it calls back; this
  // just closes the modal for the rest of the session. The server is the source
  // of truth on the next load, so a failed POST means they are asked again
  // rather than silently lost.
  function resolveAcquisition() {
    setAcqResolved(true);
  }

  function handleDiagnosticSkip() {
    localStorage.setItem('diagnosticSkipped', 'true');
    setDiagnosticStatus(prev => ({ ...prev, diagnosticSkipped: true }));
  }

  if (loading) {
    return <LoadingState />;
  }

  return (
    <main>
      <SimPitchBanner examDate={examDate} problemsAnswered={problemsAnswered} />
      {/* ── Header ── */}
      <div className="dash-header">
        <div>
          <h2 className="dash-title">Dashboard</h2>
          <span className="dash-greeting">{firstName ? `Welcome back, ${firstName}` : 'Welcome back'}</span>
        </div>
        {/* account actions live on Profile — keep the dashboard about study */}
      </div>

      {error && <div className="error-banner" role="alert">{error}</div>}

      {/* Account-setup logistics live in the right column (SetupTodo), so the
          main panel stays focused on preparation. */}

      {/* ── Top bar: Stats + Review ── */}
      <div className="dash-topbar">
        <div className="stat-pill stat-pill--sunbeam">
          <Lightning weight="bold" size={18} />
          <span className="stat-pill-value">{stats.totalXp}</span>
          <span className="stat-pill-label">XP</span>
        </div>
        {/* days-studied pill is sunbeam everywhere (brand token + matches mobile) */}
        <div className="stat-pill stat-pill--sunbeam">
          <Fire weight="bold" size={18} />
          {stats.currentStreak > 0 ? (
            <>
              <span className="stat-pill-value">{stats.currentStreak}</span>
              <span className="stat-pill-label">{stats.currentStreak === 1 ? 'Day studied' : 'Days studied'}</span>
            </>
          ) : (
            <span className="stat-pill-label">Start studying</span>
          )}
        </div>
        {examDays !== null && examDays >= 0 && (
          <div className="stat-pill stat-pill--forest">
            <CalendarBlank weight="bold" size={18} />
            <span className="stat-pill-value">{examDays === 0 ? 'Today' : examDays}</span>
            <span className="stat-pill-label">{examDays === 0 ? 'FE exam day!' : examDays === 1 ? 'day to FE' : 'days to FE'}</span>
          </div>
        )}
        {reviewDue > 0 ? (
          <button className="review-btn review-btn--due" onClick={() => navigate('/review')}>
            <Timer weight="bold" size={16} />
            Review
            <span className="review-due-badge">{reviewDue > 10 ? '10+' : reviewDue}</span>
            <ArrowRight weight="bold" size={14} />
          </button>
        ) : hasActivity ? (
          <span className="review-btn review-btn--done" title="No reviews due right now">
            <Timer weight="bold" size={16} />
            No reviews due
          </span>
        ) : null}
      </div>

      {/* Phone work shows up the same evening — the Tuesday test */}
      {phoneToday && (
        <div className="phone-today-line">
          <DeviceMobile weight="bold" size={16} />
          <span>
            Today on your phone: {phoneToday.cards} {phoneToday.cards === 1 ? 'card' : 'cards'}
            {phoneToday.misses > 0 ? ` · ${phoneToday.misses} ${phoneToday.misses === 1 ? 'miss' : 'misses'}` : ''}
          </span>
        </div>
      )}

      {/* Visible sync state: when + which device last synced (never assume iPhone) */}
      {syncState && syncState.at && (() => {
        const d = new Date(syncState.at);
        const sameDay = d.toDateString() === new Date().toDateString();
        const when = sameDay
          ? d.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' })
          : d.toLocaleDateString([], { month: 'short', day: 'numeric' });
        const device = syncState.device ? `your ${syncState.device}` : 'your phone';
        return (
          <div className="sync-state-line">
            <DeviceMobile weight="regular" size={14} />
            <span>Last synced {when} from {device}</span>
          </div>
        );
      })()}

      {/* The hand-off: problems the phone set aside for paper become tonight's
          desk work (falls back to missed concepts when nothing was flagged). */}
      {phoneToday && (() => {
        const flags = phoneToday.paperFlags || [];
        const missed = phoneToday.missed || [];
        const fromPaper = flags.length > 0;
        const items = fromPaper ? flags : missed;
        if (!items.length) return null;
        const byCh = {};
        for (const m of items) byCh[m.chapterId] = (byCh[m.chapterId] || 0) + 1;
        const topCh = Object.keys(byCh).sort((a, b) => byCh[b] - byCh[a])[0];
        const chMeta = CHAPTERS.find((c) => c.id === topCh);
        if (!chMeta) return null;
        const n = items.length;
        const body = fromPaper
          ? `${n} ${n === 1 ? 'problem' : 'problems'} you set aside for paper on your phone. Grab a pencil and start with ${chMeta.name}.`
          : `${n} ${n === 1 ? 'concept' : 'concepts'} from your phone need full problems. Start with ${chMeta.name}.`;
        return (
          <div className="tonight-card">
            <div>
              <span className="tonight-title">Tonight</span>
              <span className="tonight-body">{body}</span>
            </div>
            <button className="tonight-btn" onClick={() => navigate(`/problems/${topCh}`)}>
              Practice <ArrowRight weight="bold" size={13} />
            </button>
          </div>
        );
      })()}

      {/* ── Exam Readiness ── */}
      {hasActivity && (
        <div className="readiness-card">
          <div className="readiness-head">
            <Gauge weight="bold" size={18} />
            <span className="readiness-title">Concept mastery</span>
            <span className="readiness-info" data-tooltip="How much of the concepts the FE Civil tests you've mastered, weighted by how many questions each chapter gets on the exam. It rises as your chapter mastery grows — it is not a probability of passing.">
              <Info weight="regular" size={13} />
            </span>
            <span className="readiness-pct" style={{ color: getMasteryColor(readiness) }}>{readiness}%</span>
          </div>
          <div className="readiness-bar">
            <div
              className="readiness-bar-fill"
              style={{ width: `${readiness}%`, background: getMasteryColor(readiness) }}
            />
          </div>
          <span className="readiness-label">{readinessLabel(readiness)}</span>
          <button className="scoring-trigger" onClick={() => setScoringOpen(true)}>How is this scored?</button>
        </div>
      )}

      {/* ── Diagnostic Card ── */}
      <DiagnosticCard diagnosticStatus={diagnosticStatus} quickstart={quickstart} onSkip={handleDiagnosticSkip} />

      {/* Attribution survey lives at the bottom of the right rail — see below. */}

      {/* ── Two-column layout: Chapters (left) + Sidebar (right) ── */}
      <div className="dash-grid">

        {/* ── LEFT: 15 Chapters ── */}
        <section className="dash-chapters">
          <h3 className="dash-section-label">
            <BookOpenText weight="bold" size={18} />
            Chapters
          </h3>
          <div className="ch-list">
            <div className="ch-list-header">
              <span></span>
              <span></span>
              <span className="ch-header-label">
                Chapter
                <span className="ch-header-info" data-tooltip="The 15 chapters follow the official NCEES FE Civil exam specification. Each chapter maps to one knowledge area tested on exam day.">
                  <Info weight="regular" size={13} />
                </span>
              </span>
              <button className="ch-header-label ch-header-label--right ch-header-btn" onClick={() => setScoringOpen(true)} data-tooltip="How is mastery scored? Tap to see our learning-science method.">
                Mastery
                <span className="ch-header-info ch-header-info--right">
                  <Info weight="regular" size={13} />
                </span>
              </button>
              <span className="ch-header-label ch-header-label--right">
                Exam Qs
                <span className="ch-header-info ch-header-info--right" data-tooltip="The number of questions each topic gets on the actual FE Civil exam, based on the NCEES exam specification. The FE Civil has 110 questions total.">
                  <Info weight="regular" size={13} />
                </span>
              </span>
              <span></span>
            </div>
            {CHAPTERS.map((ch) => {
              const Icon = ch.icon;
              const prog = getProgress(ch);
              const pct = prog.masteryPct;
              const barColor = getMasteryColor(pct);
              const pctLabel = pct > 0 ? `${pct}%` : '';

              return (
                <button key={ch.id} className="ch-row-dash" onClick={() => handleChapterClick(ch)}>
                  <span className="ch-num-d">{String(ch.num).padStart(2, '0')}</span>
                  <Icon weight="bold" size={18} className={`ch-icon-d ch-icon-d--${ch.accent}`} />
                  <span className="ch-name-d">{ch.name}</span>
                  <div className="ch-mastery">
                    <div className="mastery-bar-pct">
                      <div
                        className="mastery-bar-fill"
                        style={{ width: `${pct}%`, background: barColor }}
                      />
                    </div>
                    <span className="ch-status" style={pct > 0 ? { color: barColor, fontWeight: 600 } : undefined}>
                      {pctLabel ? `${prog.masteryName} · ${pctLabel}` : prog.masteryName}
                    </span>
                  </div>
                  {/* badge color encodes exam weight (one scale), not the chapter's accent */}
                  <span className={`ch-badge-d ch-badge-d--${weightClass(getExamWeight(ch.id))}`}>{ch.qs} Qs</span>
                  <ArrowRight weight="bold" size={14} className="ch-arrow" />
                </button>
              );
            })}
          </div>

          {/* Exam Simulation CTA — below chapters */}
          <ExamSimCard />
        </section>

        {/* ── RIGHT: Sidebar ── */}
        <aside className="dash-sidebar">
          {/* Account setup — logistics, kept out of the left prep panel */}
          <SetupTodo
            emailVerified={emailVerified}
            hasName={!!firstName}
            hasExam={!!examDate}
          />

          {/* Focus Areas */}
          {hasActivity && focusAreas.length > 0 && (
            <div className="sidebar-block focus-block">
              <h3 className="dash-section-label">
                <Target weight="bold" size={18} />
                Focus Areas
              </h3>
              <p className="focus-sub">Where your effort moves the needle most</p>
              {focusAreas.every((f) => f.masteryPct === 0) ? (
                // No data yet — focus claims would be guesses, not guidance.
                <p className="focus-sub" style={{ marginTop: '0.5rem' }}>
                  Finish the Quick Start to see your focus areas.
                </p>
              ) : (
              <div className="focus-list">
                {focusAreas.map(({ ch, masteryPct, weight }) => (
                  <div key={ch.id} className="focus-row">
                    <div className="focus-row-top">
                      <span className="focus-name">{ch.name}</span>
                      {/* same range chips as the chapter table — one source, no contradiction */}
                      <span className="focus-weight">{ch.qs ? `${ch.qs} exam Qs` : `${weight} exam Qs`}</span>
                    </div>
                    <div className="mastery-bar-pct focus-bar">
                      <div
                        className="mastery-bar-fill"
                        style={{ width: `${masteryPct}%`, background: getMasteryColor(masteryPct) }}
                      />
                    </div>
                    <div className="focus-row-bottom">
                      <span className="focus-mastery">{masteryPct > 0 ? `${masteryPct}% mastery` : 'Not started'}</span>
                      <button className="focus-practice" onClick={() => handleChapterClick(ch)}>
                        Practice <ArrowRight weight="bold" size={12} />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
              )}
            </div>
          )}

          {/* Achievements */}
          {stats.allBadges.length > 0 && (
            <div className="sidebar-block">
              <h3 className="dash-section-label">
                <Trophy weight="bold" size={18} />
                Achievements
              </h3>
              <div className="badges-compact">
                {visibleBadges.map((badge) => {
                  const earned = earnedBadgeIds.has(badge.id);
                  return (
                    <div key={badge.id} className={`badge-row${earned ? ' badge-row--earned' : ''}`} title={badge.description}>
                      <span className="badge-name">{badge.name}</span>
                      <span className="badge-desc">{badge.description}</span>
                      {/* earned must be verifiable at a glance, not color-only */}
                      {earned && <CheckCircle weight="bold" size={16} className="badge-check" />}
                    </div>
                  );
                })}
              </div>
              {stats.allBadges.length > 3 && (
                <button className="badges-toggle" onClick={() => setShowAllBadges((v) => !v)} aria-expanded={showAllBadges}>
                  {showAllBadges
                    ? 'Show less'
                    : `Show all ${stats.allBadges.length}${earnedBadgeIds.size > 0 ? ` · ${earnedBadgeIds.size} earned` : ''}`}
                  <CaretDown weight="bold" size={12} className={`badges-caret${showAllBadges ? ' badges-caret--up' : ''}`} />
                </button>
              )}
            </div>
          )}

          {/* Leaderboard */}
          <div className="sidebar-block">
            <h3 className="dash-section-label">
              <Users weight="bold" size={18} />
              Leaderboard
            </h3>
            <div style={{ display: 'flex', gap: 8, margin: '0 0 10px' }}>
              {['week', 'alltime'].map((t) => (
                <button
                  key={t}
                  onClick={() => setLbTab(t)}
                  style={{
                    flex: 1, padding: '6px 0', fontSize: 13, fontWeight: 700, cursor: 'pointer',
                    borderRadius: 8, border: '1px solid',
                    borderColor: lbTab === t ? 'var(--ember)' : 'rgba(44,44,44,0.15)',
                    background: lbTab === t ? 'var(--ember)' : 'transparent',
                    color: lbTab === t ? '#fff' : 'var(--charcoal)',
                  }}
                >
                  {t === 'week' ? 'Weekly' : 'All-time'}
                </button>
              ))}
            </div>
            {lbTab === 'week' && leaderboard.weekId && (
              <span className="lb-week">{formatWeekLabel(leaderboard.weekId)}</span>
            )}
            {(() => {
              const isWeek = lbTab === 'week';
              const rows = isWeek ? leaderboard.entries : leaderboard.allTime;
              if (!rows || rows.length === 0) {
                return <p className="lb-empty">{isWeek ? 'Complete a session to get on the board!' : 'Earn XP to climb the all-time board!'}</p>;
              }
              return (
                <ol className="lb-list">
                  {rows.map((entry) => (
                    <li key={entry.rank} className={`lb-row${entry.isCurrentUser ? ' lb-row--you' : ''}`}>
                      <span className="lb-rank">#{entry.rank}</span>
                      <span className="lb-name">{entry.isCurrentUser ? 'You' : entry.name}</span>
                      <span className="lb-xp">{isWeek ? entry.weeklyXp : entry.totalXp} XP</span>
                    </li>
                  ))}
                </ol>
              );
            })()}
          </div>

          {/* Live Activity — only render when there's real presence. An empty
              "live" feed is mild negative social proof ("nobody's here"); the
              block reappears on its own as concurrency grows. */}
          {events.length > 0 && (
            <div className="sidebar-block">
              <h3 className="dash-section-label">
                <Pulse weight="bold" size={18} />
                Live Activity
              </h3>
              <ul className="activity-list">
                {events.map((event, index) => (
                  <li key={index}>
                    <span className="act-user">{event.from}</span> studying{' '}
                    <span className="act-topic">{prettyTopic(event)}</span>
                  </li>
                ))}
              </ul>
            </div>
          )}

          {/* Referral / Spread the word */}
          <div className="sidebar-block referral-card">
            <h3 className="dash-section-label">
              <Megaphone weight="bold" size={18} />
              Spread the word
            </h3>
            <p className="referral-text">
              I hope you're finding these resources helpful! We just want more students to benefit
              from quality FE prep without paying hundreds of dollars. If it's helped you, the best
              thanks is a quick shout-out so other engineers can find us — a post on{' '}
              <a href="https://www.reddit.com/r/FE_Exam/" target="_blank" rel="noopener noreferrer">r/FE_Exam</a>
              {' '}or{' '}
              <a href="https://www.reddit.com/r/engineeringstudents/" target="_blank" rel="noopener noreferrer">r/engineeringstudents</a>,
              a quick{' '}
              <a href={`https://x.com/intent/tweet?text=Studying%20for%20the%20FE%20Civil%20exam%3F%20FE%20for%20Raccoons%20is%20free%3A%20lessons%2C%20${PROBLEM_COUNT}%20problems%2C%20a%20diagnostic.%20fe4raccoons.com`} target="_blank" rel="noopener noreferrer">post on X</a>,
              or a mention anywhere fellow engineers hang out would mean the world.
            </p>
          </div>
        </aside>
      </div>
      {/* Attribution safety net. A modal, not a rail card: in the rail it sat
          below the fold and was effectively invisible.
          Mandatory, matching the registration ask — one tap, once, ever. There
          is no dismiss because dismissing was permanent and simply lost the
          answer; "Other" is the honest out for anyone who does not remember. */}
      {showSource && (
        <div className="source-prompt-overlay" role="dialog" aria-modal="true" aria-label="How did you find us?">
          <SourcePrompt className="is-modal" dismissible={false} onClose={resolveAcquisition} />
        </div>
      )}
      <ScoringModal open={scoringOpen} onClose={() => setScoringOpen(false)} />
    </main>
  );
}
