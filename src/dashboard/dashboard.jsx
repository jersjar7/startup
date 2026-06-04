import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import {
  Lightning,
  Fire,
  Timer,
  Trophy,
  Users,
  Pulse,
  Info,
  SignOut,
  ArrowRight,
  BookOpenText,
  Megaphone,
  Gauge,
  Target,
  CalendarBlank,
  X,
} from '@phosphor-icons/react';
import { CHAPTERS } from '../data/chapters';
import { computeReadiness, computeFocusAreas, readinessLabel } from '../data/readiness';
import { LoadingState } from '../components/LoadingState';
import { DiagnosticCard } from '../diagnostic/DiagnosticCard';
import { ExamSimCard } from '../exam/ExamSimCard';
import './dashboard.css';

export function Dashboard({ userName, onLogout, displayName, firstName, examDate }) {
  const navigate = useNavigate();
  useDocumentTitle('Dashboard');
  // Shown to other users in Live Activity — never the raw email.
  const activityName = displayName || (userName || '').split('@')[0] || 'A student';
  const examDays = examDate
    ? Math.ceil((new Date(`${examDate}T00:00:00`).getTime() - Date.now()) / 86400000)
    : null;
  const [profilePromptDismissed, setProfilePromptDismissed] = React.useState(
    () => { try { return localStorage.getItem('fe4r-profile-prompt') === 'dismissed'; } catch { return false; } },
  );
  const dismissProfilePrompt = () => {
    try { localStorage.setItem('fe4r-profile-prompt', 'dismissed'); } catch { /* ignore */ }
    setProfilePromptDismissed(true);
  };
  const [topics, setTopics] = React.useState([]);
  const [stats, setStats] = React.useState({ totalXp: 0, currentStreak: 0, badges: [], allBadges: [] });
  const [leaderboard, setLeaderboard] = React.useState({ weekId: '', entries: [] });
  const [loading, setLoading] = React.useState(true);
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
  const [reviewDue, setReviewDue] = React.useState(0);

  React.useEffect(() => {
    if (!userName) {
      navigate('/');
      return;
    }

    Promise.allSettled([
      fetch('/api/topics').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
      fetch('/api/user/me').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
      fetch('/api/leaderboard').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
      fetch('/api/diagnostic/can-retake').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
      fetch('/api/diagnostic/mastery').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
      fetch('/api/diagnostic/history').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
      fetch('/api/review/count').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
    ]).then(([topicsResult, statsResult, lbResult, retakeResult, masteryResult, historyResult, reviewCountResult]) => {
      const errors = [];
      if (topicsResult.status === 'fulfilled') {
        setTopics(topicsResult.value);
      } else {
        errors.push('topics');
      }
      if (statsResult.status === 'fulfilled') {
        const data = statsResult.value;
        setStats({
          totalXp: data.totalXp || 0,
          currentStreak: data.currentStreak || 0,
          badges: data.badges || [],
          allBadges: data.allBadges || [],
        });
      } else {
        errors.push('stats');
      }
      if (lbResult.status === 'fulfilled') {
        setLeaderboard({ weekId: lbResult.value.weekId, entries: lbResult.value.leaderboard || [] });
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

      // Reviews due (for the Daily Review badge)
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

    ws.onopen = () => {
      ws.send(JSON.stringify({ type: 'study', from: activityName, topic: 'Dashboard' }));
    };

    ws.onmessage = (event) => {
      // Frames may arrive as a string or a Blob; parse defensively either way.
      const handle = (text) => {
        try {
          const msg = JSON.parse(text);
          setEvents((prev) => [msg, ...prev].slice(0, 10));
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

  /* Build a lookup from API topics by name */
  const topicLookup = React.useMemo(() => {
    const map = {};
    topics.forEach((t) => { map[t.name] = t; });
    return map;
  }, [topics]);

  const handleChapterClick = (chapter) => {
    const apiTopic = topicLookup[chapter.name];
    if (socket && socket.readyState === WebSocket.OPEN) {
      socket.send(JSON.stringify({ type: 'study', from: activityName, topic: chapter.name }));
    }
    if (apiTopic) {
      navigate(`/study/${apiTopic.topicId}`);
    } else {
      navigate(`/study/${chapter.id}`);
    }
  };

  const handleLogout = () => {
    if (socket) socket.close();
    onLogout();
    navigate('/');
  };

  const getProgress = (chapter) => {
    const t = topicLookup[chapter.name];
    const cm = chapterMastery[chapter.id];

    // If diagnostic mastery data exists, use percentage-based system
    if (cm && cm.totalMastery > 0) {
      return {
        masteryPct: cm.totalMastery,
        masteryLevel: t?.progress?.masteryLevel || 0,
        masteryName: t?.progress?.masteryName || 'Not Started',
        correct: t?.progress?.correct || 0,
        total: t?.problemCount || 0,
        decaying: t?.progress?.decaying || false,
      };
    }

    // Fallback to old level-based system
    if (!t) return { masteryPct: 0, masteryLevel: 0, masteryName: 'Not Started', correct: 0, total: 0, decaying: false };
    return {
      masteryPct: (t.progress?.masteryLevel || 0) * 20,
      masteryLevel: t.progress?.masteryLevel || 0,
      masteryName: t.progress?.masteryName || 'Not Started',
      correct: t.progress?.correct || 0,
      total: t.problemCount || 0,
      decaying: t.progress?.decaying || false,
    };
  };

  function getMasteryColor(pct) {
    if (pct >= 90) return 'var(--forest)';
    if (pct >= 70) return 'var(--sunbeam)';
    if (pct >= 40) return 'var(--ember)';
    if (pct > 0) return 'var(--error)';
    return 'var(--gray-200)';
  }

  /* Mastery % per chapter — fed into the shared readiness/focus model so the
     dashboard and the post-session summary agree. getProgress reads from
     topics (via topicLookup) and chapterMastery. */
  const masteryByChapterId = React.useMemo(
    () => Object.fromEntries(CHAPTERS.map((ch) => [ch.id, getProgress(ch).masteryPct])),
    [topics, chapterMastery],
  );

  const readiness = React.useMemo(() => computeReadiness(masteryByChapterId), [masteryByChapterId]);
  const focusAreas = React.useMemo(() => computeFocusAreas(masteryByChapterId), [masteryByChapterId]);
  const hasActivity = React.useMemo(
    () => stats.totalXp > 0 || Object.values(masteryByChapterId).some((p) => p > 0),
    [stats.totalXp, masteryByChapterId],
  );

  function handleDiagnosticSkip() {
    localStorage.setItem('diagnosticSkipped', 'true');
    setDiagnosticStatus(prev => ({ ...prev, diagnosticSkipped: true }));
  }

  if (loading) {
    return <LoadingState />;
  }

  return (
    <main>
      {/* ── Header ── */}
      <div className="dash-header">
        <div>
          <h2 className="dash-title">Dashboard</h2>
          <span className="dash-greeting">Welcome back, {firstName || displayName || (userName || '').split('@')[0] || 'there'}</span>
        </div>
        <button className="logout-btn" onClick={handleLogout}>
          <SignOut weight="bold" size={18} />
          Logout
        </button>
      </div>

      {error && <div className="error-banner" role="alert">{error}</div>}

      {(!firstName || examDays === null) && !profilePromptDismissed && (
        <div className="profile-prompt">
          <Target weight="bold" size={18} className="profile-prompt-icon" />
          <p className="profile-prompt-text">
            <strong>Personalize your account.</strong> Add your name{examDays === null ? ' and exam date' : ''} so we can {examDays === null ? 'count down to exam day and ' : ''}show your name (not your email) in Live Activity.
          </p>
          <button className="profile-prompt-cta" onClick={() => navigate('/profile')}>Add details</button>
          <button className="profile-prompt-x" onClick={dismissProfilePrompt} aria-label="Dismiss">
            <X weight="bold" size={14} />
          </button>
        </div>
      )}

      {/* ── Top bar: Stats + Daily Review ── */}
      <div className="dash-topbar">
        <div className="stat-pill stat-pill--sunbeam">
          <Lightning weight="bold" size={18} />
          <span className="stat-pill-value">{stats.totalXp}</span>
          <span className="stat-pill-label">XP</span>
        </div>
        <div className="stat-pill stat-pill--ember">
          <Fire weight="bold" size={18} />
          <span className="stat-pill-value">{stats.currentStreak}</span>
          <span className="stat-pill-label">Day Streak</span>
        </div>
        {examDays !== null && examDays >= 0 && (
          <div className="stat-pill stat-pill--forest">
            <CalendarBlank weight="bold" size={18} />
            <span className="stat-pill-value">{examDays === 0 ? 'Today' : examDays}</span>
            <span className="stat-pill-label">{examDays === 0 ? 'FE exam day!' : examDays === 1 ? 'day to FE' : 'days to FE'}</span>
          </div>
        )}
        <button
          className={`review-btn${reviewDue > 0 ? ' review-btn--due' : ''}`}
          onClick={() => navigate('/review')}
        >
          <Timer weight="bold" size={16} />
          Daily Review
          {reviewDue > 0 && <span className="review-due-badge">{reviewDue}</span>}
          <ArrowRight weight="bold" size={14} />
        </button>
      </div>

      {/* ── Exam Readiness ── */}
      {hasActivity && (
        <div className="readiness-card">
          <div className="readiness-head">
            <Gauge weight="bold" size={18} />
            <span className="readiness-title">Exam Readiness</span>
            <span className="readiness-info" data-tooltip="A weighted estimate of how prepared you are across all 15 chapters, weighted by how many questions each gets on the FE Civil exam. It rises as your chapter mastery grows.">
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
        </div>
      )}

      {/* ── Diagnostic Card ── */}
      <DiagnosticCard diagnosticStatus={diagnosticStatus} onSkip={handleDiagnosticSkip} />

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
              <span className="ch-header-label ch-header-label--right">
                Mastery
                <span className="ch-header-info ch-header-info--right" data-tooltip="Your mastery level (1–5) for each chapter. Mastery grows as you answer problems correctly and decays if you don't review.">
                  <Info weight="regular" size={13} />
                </span>
              </span>
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
                      {pctLabel || (prog.decaying ? 'Review' : prog.masteryName)}
                    </span>
                  </div>
                  <span className={`ch-badge-d ch-badge-d--${ch.accent}`}>{ch.qs} Qs</span>
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
          {/* Focus Areas */}
          {hasActivity && focusAreas.length > 0 && (
            <div className="sidebar-block focus-block">
              <h3 className="dash-section-label">
                <Target weight="bold" size={18} />
                Focus Areas
              </h3>
              <p className="focus-sub">Where your effort moves the needle most</p>
              <div className="focus-list">
                {focusAreas.map(({ ch, masteryPct, weight }) => (
                  <div key={ch.id} className="focus-row">
                    <div className="focus-row-top">
                      <span className="focus-name">{ch.name}</span>
                      <span className="focus-weight">{weight} exam Qs</span>
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
                {stats.allBadges.map((badge) => {
                  const earned = stats.badges.some((b) => b.id === badge.id);
                  return (
                    <div key={badge.id} className={`badge-row${earned ? ' badge-row--earned' : ''}`} title={badge.description}>
                      <span className="badge-name">{badge.name}</span>
                      <span className="badge-desc">{badge.description}</span>
                    </div>
                  );
                })}
              </div>
            </div>
          )}

          {/* Leaderboard */}
          <div className="sidebar-block">
            <h3 className="dash-section-label">
              <Users weight="bold" size={18} />
              Weekly Leaderboard
            </h3>
            {leaderboard.weekId && (
              <span className="lb-week">Week {leaderboard.weekId}</span>
            )}
            {leaderboard.entries.length > 0 ? (
              <ol className="lb-list">
                {leaderboard.entries.map((entry) => (
                  <li key={entry.rank} className={`lb-row${entry.isCurrentUser ? ' lb-row--you' : ''}`}>
                    <span className="lb-rank">#{entry.rank}</span>
                    <span className="lb-name">{entry.isCurrentUser ? 'You' : entry.name}</span>
                    <span className="lb-xp">{entry.weeklyXp} XP</span>
                  </li>
                ))}
              </ol>
            ) : (
              <p className="lb-empty">Complete a session to get on the board!</p>
            )}
          </div>

          {/* Live Activity */}
          <div className="sidebar-block">
            <h3 className="dash-section-label">
              <Pulse weight="bold" size={18} />
              Live Activity
            </h3>
            <ul className="activity-list">
              {events.length > 0 ? (
                events.map((event, index) => (
                  <li key={index}>
                    <span className="act-user">{event.from}</span> studying{' '}
                    <span className="act-topic">{event.topic}</span>
                  </li>
                ))
              ) : (
                <li className="act-empty">
                  <span className="act-empty-title">You're here, and that's what counts.</span>
                  <span className="act-empty-sub">
                    Start a session and you'll light up this feed — as more engineers join, you'll see them studying alongside you.
                  </span>
                </li>
              )}
            </ul>
          </div>

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
              <a href="https://x.com/intent/tweet?text=Studying%20for%20the%20FE%20Civil%20exam%3F%20FE%20for%20Raccoons%20is%20free%3A%20lessons%2C%201126%20problems%2C%20a%20diagnostic.%20fe4raccoons.com" target="_blank" rel="noopener noreferrer">post on X</a>,
              or a mention anywhere fellow engineers hang out would mean the world.
            </p>
          </div>
        </aside>
      </div>
    </main>
  );
}
