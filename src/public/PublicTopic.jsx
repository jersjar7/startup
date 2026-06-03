import React from 'react';
import { Link, useParams } from 'react-router-dom';
import { MathText } from '../components/MathText';
import { NotFound } from '../components/NotFound';
import { useSeo } from '../seo/useSeo';
import { getTopic } from './content';
import './public.css';

const SITE = 'https://fe4raccoons.com';

export function PublicTopic() {
  const { topicId } = useParams();
  const topic = getTopic(topicId);

  if (!topic) return <NotFound />;

  const url = `${SITE}/fe-civil/${topic.id}`;
  const title = `FE Civil ${topic.name} — Study Guide, Formulas & Practice | FE for Raccoons`;
  const description = `Free FE Civil ${topic.name} study guide: what NCEES tests (${topic.questionRange} questions), key formulas with FE Reference Handbook pages, sample problems with plain-English explanations, and common mistakes to avoid.`;

  const jsonLd = [
    {
      '@context': 'https://schema.org',
      '@type': 'LearningResource',
      name: `FE Civil ${topic.name} Study Guide`,
      description,
      url,
      educationalLevel: 'Professional certification (FE / EIT)',
      teaches: topic.subtopics.map((s) => s.name),
      learningResourceType: 'Study guide',
      isAccessibleForFree: true,
      provider: { '@type': 'Organization', name: 'FE for Raccoons', url: SITE },
      about: { '@type': 'Thing', name: `Fundamentals of Engineering (FE) Civil — ${topic.name}` },
    },
    {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      itemListElement: [
        { '@type': 'ListItem', position: 1, name: 'FE Civil Exam Guide', item: `${SITE}/fe-civil-exam-guide` },
        { '@type': 'ListItem', position: 2, name: topic.name, item: url },
      ],
    },
  ];

  useSeo({ title, description, canonical: url, jsonLd });

  return (
    <main className="pub">
      <nav className="pub-breadcrumb" aria-label="Breadcrumb">
        <Link to="/fe-civil-exam-guide">FE Civil Exam Guide</Link>
        <span aria-hidden="true">›</span>
        <span>{topic.name}</span>
      </nav>

      <div className={`pub-hero pub-accent-${topic.accent}`}>
        <p className="pub-overline">FE Civil · Chapter {topic.num} · {topic.questionRange} exam questions</p>
        <h1>FE Civil {topic.name}</h1>
        {topic.context && <p className="pub-lede">{topic.context}</p>}
        <div className="pub-cta-row">
          <Link className="pub-btn pub-btn-primary" to={`/study/${topic.id}`}>Practice {topic.name} free →</Link>
          <Link className="pub-btn pub-btn-ghost" to="/fe-civil-exam-guide">Full exam guide</Link>
        </div>
      </div>

      {topic.subtopics.length > 0 && (
        <section className="pub-section">
          <h2>What the FE tests in {topic.name}</h2>
          <div className="pub-cards">
            {topic.subtopics.map((s) => (
              <article key={s.id || s.name} className="pub-card">
                <h3>{s.name}</h3>
                <p>{s.application}</p>
              </article>
            ))}
          </div>
        </section>
      )}

      {topic.formulas.length > 0 && (
        <section className="pub-section">
          <h2>Key {topic.name} formulas</h2>
          <ul className="pub-formulas">
            {topic.formulas.map((f, i) => (
              <li key={i}>
                <div className="pub-formula-math"><MathText text={`$${f.latex}$`} /></div>
                <div className="pub-formula-meta">
                  <span className="pub-formula-label">{f.label}</span>
                  {f.page && <span className="pub-formula-page">FE Handbook {f.page}</span>}
                </div>
              </li>
            ))}
          </ul>
        </section>
      )}

      {topic.samples.length > 0 && (
        <section className="pub-section">
          <h2>Sample {topic.name} problems</h2>
          {topic.samples.map((p, i) => (
            <article key={i} className="pub-problem">
              <p className="pub-problem-q"><strong>Q{i + 1}.</strong> <MathText text={p.statement} /></p>
              {p.answer && <p className="pub-problem-a"><strong>Answer:</strong> <MathText text={p.answer} /></p>}
              <details className="pub-problem-eli5">
                <summary>Explain it simply</summary>
                <p><MathText text={p.eli5} /></p>
              </details>
            </article>
          ))}
          <p className="pub-note">
            These are 2 of <strong>1,126</strong> problems across all 15 chapters. The full bank, lessons,
            mastery tracking, and timed exam simulation live inside the app.
          </p>
        </section>
      )}

      {topic.traps.length > 0 && (
        <section className="pub-section">
          <h2>Common {topic.name} mistakes on the FE</h2>
          <ul className="pub-traps">
            {topic.traps.map((t, i) => <li key={i}><MathText text={t} /></li>)}
          </ul>
        </section>
      )}

      <section className="pub-final-cta">
        <h2>Study {topic.name} the smart way</h2>
        <p>Bite-sized lessons, one-problem-at-a-time practice with instant feedback, and a streak to keep you going — built for the FE Civil exam.</p>
        <Link className="pub-btn pub-btn-primary" to={`/study/${topic.id}`}>Start practicing {topic.name} →</Link>
      </section>
    </main>
  );
}
