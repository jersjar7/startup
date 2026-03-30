import React from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import './study.css';

export function Study({ userName, onLogout }) {
  const navigate = useNavigate();
  const { topicId } = useParams();
  const [topic, setTopic] = React.useState(null);
  const [loading, setLoading] = React.useState(true);
  const [error, setError] = React.useState('');

  React.useEffect(() => {
    if (!userName) {
      navigate('/');
      return;
    }

    fetch(`/api/topics/${topicId}`)
      .then((res) => {
        if (!res.ok) throw new Error('Topic not found');
        return res.json();
      })
      .then((data) => setTopic(data))
      .catch(() => setError('Could not load topic. Please try again.'))
      .finally(() => setLoading(false));

    // Send WebSocket event that user is studying this topic
    const protocol = window.location.protocol === 'http:' ? 'ws' : 'wss';
    const ws = new WebSocket(`${protocol}://${window.location.host}/ws`);

    ws.onopen = () => {
      ws.send(JSON.stringify({
        type: 'study',
        from: userName,
        topic: topicId,
      }));
    };

    return () => {
      ws.close();
    };
  }, [userName, navigate, topicId]);

  const handleLogout = () => {
    onLogout();
    navigate('/');
  };

  if (loading) {
    return <main><p>Loading...</p></main>;
  }

  if (error || !topic) {
    return (
      <main>
        <div className="error-banner">{error || 'Topic not found.'}</div>
        <button className="back-link" onClick={() => navigate('/dashboard')}>&larr; Back to Dashboard</button>
      </main>
    );
  }

  return (
    <main>
      <div className="study-header">
        <a href="#" className="back-link" onClick={(e) => { e.preventDefault(); navigate('/dashboard'); }}>
          &larr; Back to Topics
        </a>
        <h1>{topic.name}</h1>
        <button className="logout-btn" onClick={handleLogout}>Logout</button>
      </div>

      <section className="key-concepts">
        <h2>Key Concepts</h2>
        <p>Master these fundamental concepts for {topic.name}.</p>
        {topic.keyConcepts && topic.keyConcepts.length > 0 ? (
          <ul>
            {topic.keyConcepts.map((concept, i) => (
              <li key={i}>{concept}</li>
            ))}
          </ul>
        ) : (
          <p style={{ color: '#666', fontStyle: 'italic' }}>Key concepts coming soon.</p>
        )}
      </section>

      {topic.videoUrl && (
        <section className="video-section">
          <h3>Video Tutorial</h3>
          <iframe
            width="100%"
            height="315"
            src={topic.videoUrl}
            title={`${topic.name} tutorial`}
            allowFullScreen
          />
        </section>
      )}

      {topic.problemCount > 0 ? (
        <section style={{ textAlign: 'center' }}>
          <button className="practice-btn" onClick={() => navigate(`/problems/${topicId}`)}>
            Practice Problems &rarr;
          </button>
        </section>
      ) : (
        <section style={{ textAlign: 'center' }}>
          <p style={{ color: '#666', fontStyle: 'italic' }}>Problems coming soon for this topic.</p>
        </section>
      )}
    </main>
  );
}
