import React from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Brain,
  ChartLineUp,
  PlayCircle,
  Timer,
  ArrowRight,
  CompassTool,
  Atom,
  Drop,
  Stack,
  Bridge,
  Path,
} from '@phosphor-icons/react';
import { HeroSvg, TopicLabel } from './hero-svg';
import './landing.css';
import './hero-svg.css';

const features = [
  {
    title: 'Spaced Repetition',
    desc: 'Our algorithm schedules reviews at the optimal time so you remember more with less effort.',
    icon: Brain,
    accent: 'ember',
  },
  {
    title: 'Mastery Tracking',
    desc: 'Track your progress across all FE exam topics with a 5-level mastery system.',
    icon: ChartLineUp,
    accent: 'forest',
  },
  {
    title: 'Video Tutorials',
    desc: 'Watch curated engineering video lessons before diving into practice problems.',
    icon: PlayCircle,
    accent: 'ember',
  },
  {
    title: 'Daily Review',
    desc: 'A personalized mix of problems from past topics keeps your knowledge fresh.',
    icon: Timer,
    accent: 'sunbeam',
  },
];

const topics = [
  { name: 'Analytic Geometry', icon: CompassTool },
  { name: 'Dynamics', icon: Atom },
  { name: 'Fluid Mechanics', icon: Drop },
  { name: 'Soils', icon: Stack },
  { name: 'Materials', icon: Bridge },
  { name: 'Transportation', icon: Path },
];

export function Landing({ userName }) {
  const navigate = useNavigate();

  React.useEffect(() => {
    if (userName) {
      navigate('/dashboard');
    }
  }, [userName, navigate]);

  return (
    <>
      {/* Hero — full viewport, outside main constraint */}
      <section className="hero">
        <HeroSvg />
        <TopicLabel />
        <div className="hero-content">
          <span className="hero-overline">
            <span className="hero-overline-dash" />
            FE Civil Exam Prep
          </span>
          <h1 className="hero-title">
            Create an account and find everything you need to pass the FE.
            <span className="hero-title-emphasis">Everything.</span>
          </h1>
          <p className="hero-subtitle">
            If you already took your junior core classes, you're almost there.
            You just need a little guidance.
          </p>
          <button className="hero-cta" onClick={() => navigate('/login')}>
            Get Started Free
            <ArrowRight weight="bold" size={18} />
          </button>
        </div>

        <div className="hero-lockup" aria-hidden="true">
          <div className="hero-lockup-top">
            <span className="hero-lockup-fe">FE</span>
            <span className="hero-lockup-4">4</span>
          </div>
          <div className="hero-lockup-raccoons">RACCOONS</div>
        </div>

        <div className="hero-scroll-indicator">
          <div className="hero-scroll-line" />
          <span className="hero-scroll-text">Scroll</span>
        </div>
      </section>

      {/* Content sections — constrained width */}
      <main className="landing">
        {/* Features */}
        <section className="features-section">
          <h2 className="section-title">Study smarter, not harder.</h2>
          <p className="section-subtitle">
            Being here is the right step. Our platform combines proven learning
            science with real FE exam content.
          </p>
          <div className="features-grid">
            {features.map((f) => {
              const Icon = f.icon;
              return (
                <div key={f.title} className={`feature-card feature-card--${f.accent}`}>
                  <div className={`feature-icon feature-icon--${f.accent}`}>
                    <Icon weight="bold" size={22} />
                  </div>
                  <h3>{f.title}</h3>
                  <p>{f.desc}</p>
                </div>
              );
            })}
          </div>
        </section>

        {/* Topics */}
        <section className="topics-section">
          <h2 className="section-title">FE Civil Exam Topics</h2>
          <div className="topics-preview">
            {topics.map((t) => {
              const Icon = t.icon;
              return (
                <div key={t.name} className="topic-preview-card">
                  <Icon size={20} />
                  <span>{t.name}</span>
                </div>
              );
            })}
          </div>
        </section>

        {/* Bottom CTA */}
        <section className="cta-section">
          <h2>Let's get you ready to pass the FE.</h2>
          <p>Just create an account and let's get started.</p>
          <button className="hero-cta" onClick={() => navigate('/login')}>
            Create Free Account
            <ArrowRight weight="bold" size={18} />
          </button>
        </section>
      </main>
    </>
  );
}
