import React from 'react';
import { useNavigate } from 'react-router-dom';
import './dashboard.css';

export function Dashboard({ userName, onLogout }) {
  const navigate = useNavigate();
  const [topics, setTopics] = React.useState([]);
  const [events, setEvents] = React.useState([]);
  const [socket, setSocket] = React.useState(null);

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

    // Connect to WebSocket
    const protocol = window.location.protocol === 'http:' ? 'ws' : 'wss';
    const ws = new WebSocket(`${protocol}://${window.location.host}/ws`);

    ws.onopen = () => {
      // Announce this user is on the dashboard
      ws.send(JSON.stringify({
        type: 'study',
        from: userName,
        topic: 'Dashboard',
      }));
    };

    ws.onmessage = (event) => {
      const msg = JSON.parse(event.data);
      setEvents((prev) => {
        const updated = [msg, ...prev].slice(0, 10);
        return updated;
      });
    };

    ws.onclose = () => {
      // Connection closed
    };

    setSocket(ws);

    return () => {
      ws.close();
    };
  }, [userName, navigate]);

  const handleTopicClick = (topic) => {
    // Send WebSocket event that this user started studying a topic
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
        <h2 style={{ fontSize: '1.5rem', fontWeight: 600 }}>Select a Topic to Study</h2>
        <div>
          <span style={{ marginRight: '1rem', color: '#666' }}>Welcome, {userName}!</span>
          <button className="logout-btn" onClick={handleLogout}>Logout</button>
        </div>
      </div>

      <section className="topics-grid">
        {topics.map((topic) => (
          <div className="topic-card" key={topic.topicId} onClick={() => handleTopicClick(topic)}>
            <h3>{topic.name}</h3>
            <p>0/{topic.problemCount} problems</p>
          </div>
        ))}
      </section>

      <section className="live-activity">
        <h3>Live Activity</h3>
        <ul>
          {events.length > 0 ? (
            events.map((event, index) => (
              <li key={index}>
                <span style={{ fontWeight: 500 }}>{event.from}</span> started studying{' '}
                <span style={{ fontWeight: 500 }}>{event.topic}</span>
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
