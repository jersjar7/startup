import React from 'react';
import { useNavigate } from 'react-router-dom';
import './study.css';

export function Study() {
  const navigate = useNavigate();
  const [userName, setUserName] = React.useState('');
  const [selectedTopic] = React.useState('Analytic Geometry');

  React.useEffect(() => {
    const storedUser = localStorage.getItem('userName');
    if (!storedUser) {
      navigate('/');
    } else {
      setUserName(storedUser);
    }
  }, [navigate]);

  const handleLogout = () => {
    localStorage.removeItem('userName');
    navigate('/');
  };

  return (
    <main>
      <div className="study-header">
        <a href="#" className="back-link" onClick={(e) => { e.preventDefault(); navigate('/dashboard'); }}>
          ← Back to Topics
        </a>
        <h1>{selectedTopic}</h1>
        <button className="logout-btn" onClick={handleLogout}>Logout</button>
      </div>

      <section className="key-concepts">
        <h2>Key Concepts</h2>
        <p>Master these fundamental concepts for {selectedTopic}.</p>
        <ul>
          <li>Coordinate Systems (Cartesian, Polar)</li>
          <li>Distance and Midpoint Formulas</li>
          <li>Circle Equations</li>
          <li>Line Equations and Slopes</li>
          <li>Conic Sections (Parabolas, Ellipses, Hyperbolas)</li>
          <li>Vector Operations</li>
        </ul>
        <p style={{ marginTop: '1rem', fontStyle: 'italic', color: '#666' }}>
          Database placeholder: Study materials will be loaded from MongoDB
        </p>
      </section>

      <section className="video-section">
        <h3>YouTube Video Tutorial</h3>
        <p style={{ color: '#666' }}>(Embedded Video Player)</p>
        <p style={{ marginTop: '1rem', fontStyle: 'italic', color: '#666' }}>
          Placeholder for YouTube embed from Raccoon Engineering channel
        </p>
      </section>

      <section style={{ textAlign: 'center' }}>
        <button className="practice-btn" onClick={() => navigate('/problems')}>
          Practice Problems →
        </button>
      </section>
    </main>
  );
}