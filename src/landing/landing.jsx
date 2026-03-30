import React from 'react';
import { useNavigate } from 'react-router-dom';
import './landing.css';

const features = [
  {
    title: 'Spaced Repetition',
    desc: 'Our algorithm schedules reviews at the optimal time so you remember more with less effort.',
  },
  {
    title: 'Mastery Tracking',
    desc: 'Track your progress across all FE exam topics with a 5-level mastery system.',
  },
  {
    title: 'Video Tutorials',
    desc: 'Watch curated engineering video lessons before diving into practice problems.',
  },
  {
    title: 'Daily Review',
    desc: 'A personalized mix of problems from past topics keeps your knowledge fresh.',
  },
];

const topicNames = [
  'Analytic Geometry',
  'Dynamics',
  'Fluid Mechanics',
  'Soils',
  'Materials',
  'Transportation',
];

export function Landing({ userName }) {
  const navigate = useNavigate();

  React.useEffect(() => {
    if (userName) {
      navigate('/dashboard');
    }
  }, [userName, navigate]);

  return (
    <main className="landing">
      <section className="hero">
        <h2 className="hero-title">Pass the FE Exam on Your First Try</h2>
        <p className="hero-subtitle">
          A free, gamified study platform built by engineers, for engineers.
          Master every topic with spaced repetition, video tutorials, and real exam-level problems.
        </p>
        <button className="hero-cta" onClick={() => navigate('/login')}>
          Get Started Free
        </button>
      </section>

      <section className="features-section">
        <h3 className="section-title">Study Smarter, Not Harder</h3>
        <div className="features-grid">
          {features.map((f) => (
            <div key={f.title} className="feature-card">
              <h4>{f.title}</h4>
              <p>{f.desc}</p>
            </div>
          ))}
        </div>
      </section>

      <section className="topics-section">
        <h3 className="section-title">FE Civil Exam Topics</h3>
        <div className="topics-preview">
          {topicNames.map((name) => (
            <div key={name} className="topic-preview-card">
              <span>{name}</span>
            </div>
          ))}
        </div>
      </section>

      <section className="cta-section">
        <h3>Ready to start studying?</h3>
        <p>Join now and build your path to passing the FE exam.</p>
        <button className="hero-cta" onClick={() => navigate('/login')}>
          Create Free Account
        </button>
      </section>
    </main>
  );
}
