import React from 'react';
import { useNavigate } from 'react-router-dom';
import './dashboard.css';

export function Dashboard({ userName, onLogout }) {
  const navigate = useNavigate();
  const [topics, setTopics] = React.useState([]);
  const [stats, setStats] = React.useState({ totalXp: 0, currentStreak: 0 });
  const [events, setEvents] = React.useState([]);
  const [socket, setSocket] = React.useState(null);

  React.useEffect(() => {
    if (!userName) {
      navigate('/');
      return;
    }

    // Fetch topics with progress
    fetch('/api/topics')
      .then((res) => res.json())
      .then((data) => setTopics(data))
      .catch(() => {});

    // Fetch user stats (XP, streak)
    fetch('/api/user/me')
      .then((res) => res.json())
      .then((data) => setStats({ totalXp: data.totalXp || 0, currentStreak: data.currentStreak || 0 }))
      .catch(() => {});

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

  return (
    <main>
      <div className="dashboard-header">
        <h2 className="dashboard-title">Select a Topic to Study</h2>
        <div className="dashboard-user">
          <span className="user-greeting">Welcome, {userName}!</span>
          <button className="logout-btn" onClick={handleLogout}>Logout</button>
        </div>
      </div>

      <section className="stats-bar">
        <div className="stat-item">
          <span className="stat-value">{stats.totalXp}</span>
          <span className="stat-label">Total XP</span>
        </div>
        <div className="stat-item">
          <span className="stat-value">{stats.currentStreak}</span>
          <span className="stat-label">Day Streak</span>
        </div>
      </section>

      <section className="topics-grid">
        {topics.map((topic) => (
          <div className="topic-card" key={topic.topicId} onClick={() => handleTopicClick(topic)}>
            <h3>{topic.name}</h3>
            <p className="topic-progress">
              {topic.progress.correct}/{topic.problemCount} correct
            </p>
            {topic.progress.sessionsCompleted > 0 && (
              <p className="topic-sessions">
                {topic.progress.sessionsCompleted} session{topic.progress.sessionsCompleted !== 1 ? 's' : ''} completed
              </p>
            )}
          </div>
        ))}
      </section>

      <section className="live-activity">
        <h3>Live Activity</h3>
        <ul>
          {events.length > 0 ? (
            events.map((event, index) => (
              <li key={index}>
                <span className="activity-user">{event.from}</span> started studying{' '}
                <span className="activity-topic">{event.topic}</span>
              </li>
            ))
          ) : (
            <li>No recent activity — start studying to see live updates!</li>
          )}
        </ul>
      </section>
    </main>
  );
}
