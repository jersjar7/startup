import React from 'react';
import { useNavigate } from 'react-router-dom';
import './dashboard.css';

export function Dashboard({ userName, onLogout }) {
  const navigate = useNavigate();
  const [topics, setTopics] = React.useState([]);
  const [liveUsers, setLiveUsers] = React.useState([]);

  React.useEffect(() => {
    if (!userName) {
      navigate('/');
      return;
    }

    // Fetch topics from backend
    fetch('/api/topics')
      .then((res) => res.json())
      .then((data) => setTopics(data))
      .catch(() => {});

    // Mock WebSocket messages - simulates other users studying
    const interval = setInterval(() => {
      const topicNames = ['Analytic Geometry', 'Dynamics', 'Fluid Mechanics', 'Soils', 'Materials', 'Transportation'];
      const randomTopic = topicNames[Math.floor(Math.random() * topicNames.length)];
      const randomCount = Math.floor(Math.random() * 10) + 1;

      setLiveUsers(prev => {
        const updated = prev.filter(item => item.topic !== randomTopic);
        return [...updated, { topic: randomTopic, count: randomCount }].slice(-6);
      });
    }, 3000);

    return () => clearInterval(interval);
  }, [userName, navigate]);

  const handleLogout = () => {
    onLogout();
    navigate('/');
  };

  return (
    <main>
      <div className="dashboard-header">
        <h2 style={{ fontSize: '1.5rem', fontWeight: 600 }}>Select a Topic to Study</h2>
        <div>
          <span style={{ marginRight: '1rem', color: '#666' }}>Welcome, {userName}!</span>
          <button className="logout-btn" onClick={handleLogout}>Logout</button>
        </div>
      </div>

      <section className="topics-grid">
        {topics.map((topic) => (
          <div className="topic-card" key={topic.id} onClick={() => navigate('/study')}>
            <h3>{topic.name}</h3>
            <p>0/{topic.problemCount} problems</p>
          </div>
        ))}
      </section>

      <section className="live-activity">
        <h3>Live Activity</h3>
        <ul>
          {liveUsers.length > 0 ? (
            liveUsers.map((item, index) => (
              <li key={index}>{item.count} users studying {item.topic}</li>
            ))
          ) : (
            <li>Connecting to live activity...</li>
          )}
        </ul>
        <p style={{ marginTop: '1rem', fontStyle: 'italic', color: '#666' }}>
          WebSocket data will be displayed here in real-time
        </p>
      </section>
    </main>
  );
}
