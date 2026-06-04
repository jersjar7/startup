import React from 'react';
import { Link, useParams } from 'react-router-dom';
import { ArrowRight } from '@phosphor-icons/react';
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

  const Icon = topic.icon;
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

  const num2 = (n) => String(n).padStart(2, '0');

  return (
    <main className={`pub pub-accent-${topic.accent}`}>
      <nav className="pub-breadcrumb" aria-label="Breadcrumb">
        <Link to="/fe-civil-exam-guide">FE Civil Exam Guide</Link>
        <span aria-hidden="true">/</span>
        <span>{topic.name}</span>
      </nav>

      {/* Hero */}
      <header className="pub-hero">
        <div className="pub-hero-text">
          <span className="pub-label"><span className="pub-label-dash" />FE Civil · Chapter {topic.num} · {topic.questionRange} questions</span>
          <h1>FE Civil {topic.name}</h1>
          {topic.context && <p className="pub-lede">{topic.context}</p>}
          <div className="pub-cta-row">
            <Link className="pub-btn pub-btn-primary" to={`/study/${topic.id}`}>Practice {topic.name} free <ArrowRight size={16} weight="bold" /></Link>
            <Link className="pub-btn pub-btn-ghost" to="/fe-civil-exam-guide">Full exam guide</Link>
          </div>
        </div>
        {Icon && <div className="pub-hero-icon" aria-hidden="true"><Icon size={48} weight="duotone" /></div>}
      </header>

      {/* What the FE tests — numbered rows */}
      {topic.subtopics.length > 0 && (
        <section className="pub-section">
          <span className="pub-label"><span className="pub-label-dash" />What the FE tests</span>
          <h2>The {topic.name} skills NCEES checks</h2>
          <div className="pub-rows">
            {topic.subtopics.map((s, i) => (
              <div key={s.id || s.name} className="pub-row">
                <span className="pub-row-num">{num2(i + 1)}</span>
                <div className="pub-row-body">
                  <h3>{s.name}</h3>
                  <p>{s.application}</p>
                </div>
              </div>
            ))}
          </div>
        </section>
      )}

      {/* Formulas */}
      {topic.formulas.length > 0 && (
        <section className="pub-section pub-panel">
          <span className="pub-label"><span className="pub-label-dash" />Reference</span>
          <h2>Key {topic.name} formulas</h2>
          <ul className="pub-formulas">
            {topic.formulas.map((f, i) => (
              <li key={i}>
                <span className="pub-formula-math"><MathText text={`$${f.latex}$`} /></span>
                <span className="pub-formula-meta">
                  <span className="pub-formula-label">{f.label}</span>
                  {f.page && <span className="pub-formula-page">FE Handbook {f.page}</span>}
                </span>
              </li>
            ))}
          </ul>
        </section>
      )}

      {/* Sample problems */}
      {topic.samples.length > 0 && (
        <section className="pub-section">
          <span className="pub-label"><span className="pub-label-dash" />Try it</span>
          <h2>Sample {topic.name} problems</h2>
          <div className="pub-problems">
            {topic.samples.map((p, i) => (
              <article key={i} className="pub-problem">
                <p className="pub-problem-q"><span className="pub-problem-tag">Q{i + 1}</span><MathText text={p.statement} /></p>
                {p.answer && <p className="pub-problem-a"><MathText text={p.answer} /></p>}
                <details className="pub-eli5">
                  <summary>Explain it simply</summary>
                  <p><MathText text={p.eli5} /></p>
                </details>
              </article>
            ))}
          </div>
          <p className="pub-note">
            2 of <strong>1,126</strong> problems across all 15 chapters — the full bank, lessons, mastery
            tracking, and timed exam simulation live inside the app.
          </p>
        </section>
      )}

      {/* Common mistakes — accent rows */}
      {topic.traps.length > 0 && (
        <section className="pub-section pub-panel">
          <span className="pub-label"><span className="pub-label-dash" />Avoid these</span>
          <h2>Common {topic.name} mistakes</h2>
          <ul className="pub-traps">
            {topic.traps.map((t, i) => (
              <li key={i}><span className="pub-trap-mark" aria-hidden="true" /><MathText text={t} /></li>
            ))}
          </ul>
        </section>
      )}

      {/* Final CTA */}
      <section className="pub-final-cta">
        <h2>Study {topic.name} the smart way</h2>
        <p>Bite-sized lessons, one-problem-at-a-time practice with instant feedback, and a streak to keep you going — built for the FE Civil exam.</p>
        <Link className="pub-btn pub-btn-primary" to={`/study/${topic.id}`}>Start practicing {topic.name} <ArrowRight size={16} weight="bold" /></Link>
      </section>
    </main>
  );
}
