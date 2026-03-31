import React from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { ArrowLeft, SignOut, PlayCircle, ArrowRight } from '@phosphor-icons/react';
import { LoadingState } from '../components/LoadingState';
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
    return <LoadingState />;
  }

  if (error || !topic) {
    return (
      <main>
        <div className="error-banner">{error || 'Topic not found.'}</div>
        <a href="#" className="back-link" onClick={(e) => { e.preventDefault(); navigate('/dashboard'); }}>
          <ArrowLeft weight="bold" size={16} />
          Back to Dashboard
        </a>
      </main>
    );
  }

  return (
    <main>
      <div className="page-header">
        <a href="#" className="back-link" onClick={(e) => { e.preventDefault(); navigate('/dashboard'); }}>
          <ArrowLeft weight="bold" size={16} />
          Back to Topics
        </a>
        <h1>{topic.name}</h1>
        <button className="logout-btn" onClick={handleLogout}>
          <SignOut weight="bold" size={18} />
          Logout
        </button>
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
          <p className="key-concepts-empty">Key concepts coming soon.</p>
        )}
      </section>

      {topic.videoUrl && (
        <section className="video-section">
          <h3>Video Tutorial</h3>
          <p>Watch a curated lesson to review the key concepts before practicing.</p>
          <a
            href={topic.videoUrl.replace('/embed/', '/watch?v=')}
            target="_blank"
            rel="noopener noreferrer"
            className="video-link"
          >
            <PlayCircle weight="bold" size={18} />
            Watch on YouTube
          </a>
        </section>
      )}

      {topic.problemCount > 0 ? (
        <section className="practice-section">
          <button className="practice-btn" onClick={() => navigate(`/problems/${topicId}`)}>
            Practice Problems
            <ArrowRight weight="bold" size={18} />
          </button>
        </section>
      ) : (
        <section className="practice-section">
          <p className="practice-empty">Problems coming soon for this topic.</p>
        </section>
      )}
    </main>
  );
}
