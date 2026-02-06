import React from 'react';
import { useNavigate } from 'react-router-dom';
import './dashboard.css';

export function Dashboard() {
  const navigate = useNavigate();

  return (
    <main>
      <h2 style={{ fontSize: '1.5rem', fontWeight: 600, marginBottom: '2rem' }}>Select a Topic to Study</h2>
      
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
          <li>5 users studying Analytic Geometry</li>
          <li>3 users studying Dynamics</li>
          <li>2 users studying Fluids</li>
        </ul>
        <p style={{ marginTop: '1rem', fontStyle: 'italic', color: '#666' }}>WebSocket data will be displayed here in real-time</p>
      </section>
    </main>
  );
}