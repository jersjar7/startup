import React from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Lightning,
  Fire,
  Timer,
  Trophy,
  Users,
  Pulse,
  SignOut,
  CompassTool,
  Atom,
  Drop,
  Stack,
  Bridge,
  Path,
  BookOpenText,
  ArrowRight,
} from '@phosphor-icons/react';
import './dashboard.css';

const topicIcons = {
  'Analytic Geometry': CompassTool,
  'Dynamics': Atom,
  'Fluid Mechanics': Drop,
  'Soils': Stack,
  'Materials': Bridge,
  'Transportation': Path,
};

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

    // Fetch all dashboard data in parallel
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

    // Connect to WebSocket
    const protocol = window.location.protocol === 'http:' ? 'ws' : 'wss';
    const ws = new WebSocket(`${protocol}://${window.location.host}/ws`);

    ws.onopen = () => {
      ws.send(JSON.stringify({
        type: 'study',
        from: userName,
        topic: 'Dashboard',
      }));
    };

    ws.onmessage = (event) => {
      const msg = JSON.parse(event.data);
      setEvents((prev) => [msg, ...prev].slice(0, 10));
    };

    setSocket(ws);

    return () => {
      ws.close();
    };
  }, [userName, navigate]);

  const handleTopicClick = (topic) => {
    if (socket && socket.readyState === WebSocket.OPEN) {
      socket.send(JSON.stringify({
        type: 'study',
        from: userName,
        topic: topic.name,
      }));
    }
    navigate(`/study/${topic.topicId}`);
  };

  const handleLogout = () => {
    if (socket) {
      socket.close();
    }
    onLogout();
    navigate('/');
  };

  if (loading) {
    return <main><p>Loading...</p></main>;
  }

  return (
    <main>
      {/* Header */}
      <div className="dashboard-header">
        <div>
          <h2 className="dashboard-title">Dashboard</h2>
          <span className="user-greeting">Welcome back, {userName}</span>
        </div>
        <button className="logout-btn" onClick={handleLogout}>
          <SignOut weight="bold" size={18} />
          Logout
        </button>
      </div>

      {error && <div className="error-banner">{error}</div>}

      {/* Stat cards */}
      <section className="stats-bar">
        <div className="stat-card stat-card--sunbeam">
          <div className="stat-icon stat-icon--sunbeam">
            <Lightning weight="bold" size={22} />
          </div>
          <div className="stat-content">
            <span className="stat-value">{stats.totalXp}</span>
            <span className="stat-label">Total XP</span>
          </div>
        </div>
        <div className="stat-card stat-card--ember">
          <div className="stat-icon stat-icon--ember">
            <Fire weight="bold" size={22} />
          </div>
          <div className="stat-content">
            <span className="stat-value">{stats.currentStreak}</span>
            <span className="stat-label">Day Streak</span>
          </div>
        </div>
      </section>

      {/* Daily Review */}
      <section className="review-section">
        <button className="review-btn" onClick={() => navigate('/review')}>
          <Timer weight="bold" size={18} />
          Daily Review
          <ArrowRight weight="bold" size={16} />
        </button>
        <span className="review-hint">Mixed problems from topics you've studied</span>
      </section>

      {/* Topics */}
      <h3 className="section-heading">
        <BookOpenText weight="bold" size={20} />
        Topics
      </h3>
      <section className="topics-grid">
        {topics.map((topic) => {
          const Icon = topicIcons[topic.name] || CompassTool;
          return (
            <button className="topic-card" key={topic.topicId} onClick={() => handleTopicClick(topic)}>
              <div className="topic-card-header">
                <Icon size={20} className="topic-icon" />
                <h3>{topic.name}</h3>
              </div>
              <div className="mastery-bar-row">
                <div className="mastery-bar">
                  {[1, 2, 3, 4, 5].map((level) => (
                    <div
                      key={level}
                      className={`mastery-segment${
                        level <= topic.progress.masteryLevel
                          ? topic.progress.decaying
                            ? ' mastery-segment--decaying'
                            : ' mastery-segment--filled'
                          : ''
                      }`}
                    />
                  ))}
                </div>
                <span className={`mastery-label${topic.progress.decaying ? ' mastery-label--decaying' : ''}`}>
                  {topic.progress.decaying ? 'Needs Review' : topic.progress.masteryName || 'Not Started'}
                </span>
              </div>
              <p className="topic-progress">
                {topic.progress.correct}/{topic.problemCount} correct
              </p>
              {topic.progress.sessionsCompleted > 0 && (
                <p className="topic-sessions">
                  {topic.progress.sessionsCompleted} session{topic.progress.sessionsCompleted !== 1 ? 's' : ''} completed
                </p>
              )}
            </button>
          );
        })}
      </section>

      {/* Badges */}
      {stats.allBadges.length > 0 && (
        <section className="badges-section">
          <h3 className="section-heading">
            <Trophy weight="bold" size={20} />
            Achievements
          </h3>
          <div className="badges-grid">
            {stats.allBadges.map((badge) => {
              const earned = stats.badges.some((b) => b.id === badge.id);
              return (
                <div key={badge.id} className={`badge-item${earned ? ' badge-earned' : ''}`} title={badge.description}>
                  <span className="badge-name">{badge.name}</span>
                  <span className="badge-desc">{badge.description}</span>
                </div>
              );
            })}
          </div>
        </section>
      )}

      {/* Leaderboard */}
      <section className="leaderboard-section">
        <h3 className="section-heading">
          <Users weight="bold" size={20} />
          Weekly Leaderboard
        </h3>
        {leaderboard.weekId && (
          <span className="leaderboard-week">Week {leaderboard.weekId}</span>
        )}
        {leaderboard.entries.length > 0 ? (
          <ol className="leaderboard-list">
            {leaderboard.entries.map((entry) => (
              <li
                key={entry.rank}
                className={`leaderboard-row${entry.isCurrentUser ? ' leaderboard-row--you' : ''}`}
              >
                <span className="leaderboard-rank">#{entry.rank}</span>
                <span className="leaderboard-name">{entry.isCurrentUser ? 'You' : entry.name}</span>
                <span className="leaderboard-xp">{entry.weeklyXp} XP</span>
              </li>
            ))}
          </ol>
        ) : (
          <p className="leaderboard-empty">No activity this week yet. Complete a session to get on the board!</p>
        )}
      </section>

      {/* Live Activity */}
      <section className="live-activity">
        <h3 className="section-heading">
          <Pulse weight="bold" size={20} />
          Live Activity
        </h3>
        <ul>
          {events.length > 0 ? (
            events.map((event, index) => (
              <li key={index}>
                <span className="activity-user">{event.from}</span> started studying{' '}
                <span className="activity-topic">{event.topic}</span>
              </li>
            ))
          ) : (
            <li className="activity-empty">No recent activity — start studying to see live updates!</li>
          )}
        </ul>
      </section>
    </main>
  );
}
