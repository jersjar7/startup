import React from 'react';
import { useNavigate } from 'react-router-dom';
import './dashboard.css';

export function Dashboard() {
  const navigate = useNavigate();
  const [userName, setUserName] = React.useState('');
  const [liveUsers, setLiveUsers] = React.useState([]);

  React.useEffect(() => {
    const storedUser = localStorage.getItem('userName');
    if (!storedUser) {
      navigate('/');
    } else {
      setUserName(storedUser);
    }

    // Mock WebSocket messages - simulates other users studying
    const interval = setInterval(() => {
      const topics = ['Analytic Geometry', 'Dynamics', 'Fluid Mechanics', 'Soils', 'Materials', 'Transportation'];
      const randomTopic = topics[Math.floor(Math.random() * topics.length)];
      const randomCount = Math.floor(Math.random() * 10) + 1;
      
      setLiveUsers(prev => {
        const updated = prev.filter(item => item.topic !== randomTopic);
        return [...updated, { topic: randomTopic, count: randomCount }].slice(-6);
      });
    }, 3000);

    return () => clearInterval(interval);
  }, [navigate]);

  const handleLogout = () => {
    localStorage.removeItem('userName');
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
        <div className="topic-card" onClick={() => navigate('/study')}>
          <h3>Analytic Geometry</h3>
          <p>3/10 problems</p>
        </div>
        
        <div className="topic-card" onClick={() => navigate('/study')}>
          <h3>Dynamics</h3>
          <p>0/8 problems</p>
        </div>
        
        <div className="topic-card" onClick={() => navigate('/study')}>
          <h3>Fluid Mechanics</h3>
          <p>5/12 problems</p>
        </div>
        
        <div className="topic-card" onClick={() => navigate('/study')}>
          <h3>Soils</h3>
          <p>2/9 problems</p>
        </div>
        
        <div className="topic-card" onClick={() => navigate('/study')}>
          <h3>Materials</h3>
          <p>1/7 problems</p>
        </div>
        
        <div className="topic-card" onClick={() => navigate('/study')}>
          <h3>Transportation</h3>
          <p>0/10 problems</p>
        </div>
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