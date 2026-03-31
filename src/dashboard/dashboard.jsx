import React from 'react';
import { useNavigate } from 'react-router-dom';
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
} from '@phosphor-icons/react';
import { CHAPTERS } from '../data/chapters';
import { LoadingState } from '../components/LoadingState';
import './dashboard.css';

export function Dashboard({ userName, onLogout }) {
  const navigate = useNavigate();
  const [topics, setTopics] = React.useState([]);
  const [stats, setStats] = React.useState({ totalXp: 0, currentStreak: 0, badges: [], allBadges: [] });
  const [leaderboard, setLeaderboard] = React.useState({ weekId: '', entries: [] });
  const [loading, setLoading] = React.useState(true);
  const [error, setError] = React.useState('');
  const [events, setEvents] = React.useState([]);
  const [socket, setSocket] = React.useState(null);

  React.useEffect(() => {
    if (!userName) {
      navigate('/');
      return;
    }

    Promise.allSettled([
      fetch('/api/topics').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
      fetch('/api/user/me').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
      fetch('/api/leaderboard').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
    ]).then(([topicsResult, statsResult, lbResult]) => {
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

  const getProgress = (chapterName) => {
    const t = topicLookup[chapterName];
    if (!t) return { masteryLevel: 0, masteryName: 'Not Started', correct: 0, total: 0, decaying: false };
    return {
      masteryLevel: t.progress?.masteryLevel || 0,
      masteryName: t.progress?.masteryName || 'Not Started',
      correct: t.progress?.correct || 0,
      total: t.problemCount || 0,
      decaying: t.progress?.decaying || false,
    };
  };

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

      {error && <div className="error-banner">{error}</div>}

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
              const prog = getProgress(ch.name);
              return (
                <button key={ch.id} className="ch-row-dash" onClick={() => handleChapterClick(ch)}>
                  <span className="ch-num-d">{String(ch.num).padStart(2, '0')}</span>
                  <Icon weight="bold" size={18} className={`ch-icon-d ch-icon-d--${ch.accent}`} />
                  <span className="ch-name-d">{ch.name}</span>
                  <div className="ch-mastery">
                    <div className="mastery-bar">
                      {[1, 2, 3, 4, 5].map((level) => (
                        <div
                          key={level}
                          className={`mastery-seg${
                            level <= prog.masteryLevel
                              ? prog.decaying ? ' mastery-seg--decay' : ' mastery-seg--fill'
                              : ''
                          }`}
                        />
                      ))}
                    </div>
                    <span className={`ch-status${prog.decaying ? ' ch-status--decay' : ''}`}>
                      {prog.decaying ? 'Review' : prog.masteryName}
                    </span>
                  </div>
                  <span className={`ch-badge-d ch-badge-d--${ch.accent}`}>{ch.qs} Qs</span>
                  <ArrowRight weight="bold" size={14} className="ch-arrow" />
                </button>
              );
            })}
          </div>
        </section>

        {/* ── RIGHT: Sidebar ── */}
        <aside className="dash-sidebar">
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
        </aside>
      </div>
    </main>
  );
}
