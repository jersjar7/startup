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
  LinkedinLogo,
  Gauge,
  Target,
} from '@phosphor-icons/react';
import { CHAPTERS } from '../data/chapters';
import { getExamWeight } from '../data/exam-bank/index';
import { LoadingState } from '../components/LoadingState';
import { DiagnosticCard } from '../diagnostic/DiagnosticCard';
import { ExamSimCard } from '../exam/ExamSimCard';
import './dashboard.css';

export function Dashboard({ userName, onLogout }) {
  const navigate = useNavigate();
  useDocumentTitle('Dashboard');
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
    ]).then(([topicsResult, statsResult, lbResult, retakeResult, masteryResult, historyResult]) => {
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

      if (errors.length > 0) {
        setError('Failed to load some data. Try refreshing the page.');
      }
      setLoading(false);
    });

    const protocol = window.location.protocol === 'http:' ? 'ws' : 'wss';
    const ws = new WebSocket(`${protocol}://${window.location.host}/ws`);

    ws.onopen = () => {
      ws.send(JSON.stringify({ type: 'study', from: userName, topic: 'Dashboard' }));
    };

    ws.onmessage = (event) => {
      const msg = JSON.parse(event.data);
      setEvents((prev) => [msg, ...prev].slice(0, 10));
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
      socket.send(JSON.stringify({ type: 'study', from: userName, topic: chapter.name }));
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

  function readinessLabel(pct) {
    if (pct >= 85) return 'Exam ready';
    if (pct >= 70) return 'On track to pass';
    if (pct >= 40) return 'Building momentum';
    return 'Just getting started';
  }

  /* Per-chapter mastery + NCEES exam weight — the basis for readiness and focus. */
  const chapterStats = React.useMemo(
    () => CHAPTERS.map((ch) => ({
      ch,
      masteryPct: getProgress(ch).masteryPct,
      weight: getExamWeight(ch.id),
    })),
    // getProgress reads from topics (via topicLookup) and chapterMastery
    [topics, chapterMastery],
  );

  /* Weighted exam-readiness: chapter mastery weighted by how many questions
     each chapter gets on the 110-question exam. */
  const readiness = React.useMemo(() => {
    const totalWeight = chapterStats.reduce((s, c) => s + c.weight, 0) || 1;
    const weighted = chapterStats.reduce((s, c) => s + c.masteryPct * c.weight, 0);
    return Math.round(weighted / totalWeight);
  }, [chapterStats]);

  const hasActivity = React.useMemo(
    () => stats.totalXp > 0 || chapterStats.some((c) => c.masteryPct > 0),
    [stats.totalXp, chapterStats],
  );

  /* The 3 chapters where effort moves the score most: low mastery × high exam weight. */
  const focusAreas = React.useMemo(
    () => chapterStats
      .filter((c) => c.masteryPct < 90)
      .map((c) => ({ ...c, focusScore: (100 - c.masteryPct) * c.weight }))
      .sort((a, b) => b.focusScore - a.focusScore)
      .slice(0, 3),
    [chapterStats],
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
          <span className="dash-greeting">Welcome back, {userName}</span>
        </div>
        <button className="logout-btn" onClick={handleLogout}>
          <SignOut weight="bold" size={18} />
          Logout
        </button>
      </div>

      {error && <div className="error-banner" role="alert">{error}</div>}

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
        <button className="review-btn" onClick={() => navigate('/review')}>
          <Timer weight="bold" size={16} />
          Daily Review
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
                <li className="act-empty">No recent activity</li>
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
              I hope you're finding these resources helpful! We just want more students to benefit from quality FE prep without paying hundreds of dollars. If you think this platform is worth sharing, a quick post on{' '}
              <a href="https://www.reddit.com/r/FE_Exam/" target="_blank" rel="noopener noreferrer">r/FE_Exam</a>
              {' '}or{' '}
              <a href="https://www.reddit.com/r/engineeringstudents/" target="_blank" rel="noopener noreferrer">r/engineeringstudents</a>
              {' '}would mean a lot.
            </p>
            <div className="referral-deal">
              <span className="referral-deal-label">Get 33% off the Exam Simulation</span>
              <p className="referral-deal-text">
                Take a screenshot of your Reddit post and{' '}
                <a href="https://www.linkedin.com/in/jersonjgarcia/" target="_blank" rel="noopener noreferrer">
                  <LinkedinLogo weight="bold" size={14} />
                  DM me on LinkedIn
                </a>
                . I'll send you a one-time discount code — <strong>$9.99</strong> instead of $14.99.
              </p>
            </div>
          </div>
        </aside>
      </div>
    </main>
  );
}
