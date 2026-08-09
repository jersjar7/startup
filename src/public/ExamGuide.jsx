import React from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight, CaretRight } from '@phosphor-icons/react';
import { useSeo } from '../seo/useSeo';
import { allTopics, EXAM_FACTS } from './content';
import { PROBLEM_COUNT_LABEL } from '../data/contentStats';
import { STUDENT_PRICE, STANDARD_PRICE } from '../data/pricing';
import './public.css';

const SITE = 'https://fe4raccoons.com';

const FAQ = [
  {
    q: 'How many questions are on the FE Civil exam?',
    a: 'The FE Civil exam has 110 multiple-choice questions and is computer-based (CBT). You get 6 hours total, including a tutorial and an optional break — about 5 hours and 20 minutes of actual testing time.',
  },
  {
    q: 'What topics are on the FE Civil exam?',
    a: 'NCEES covers 15 areas: Mathematics, Probability & Statistics, Ethics, Engineering Economics, Statics, Dynamics, Mechanics of Materials, Materials, Fluid Mechanics, Surveying, Water Resources & Environmental, Structural, Geotechnical, Transportation, and Construction.',
  },
  {
    q: 'Can you use a calculator and reference materials on the FE exam?',
    a: 'You may use an NCEES-approved calculator, and the searchable NCEES FE Reference Handbook is provided on-screen. There is no penalty for guessing, so answer every question.',
  },
  {
    q: 'How should I study for the FE Civil exam?',
    a: 'Work problems, not just notes. Practice one problem at a time with immediate feedback, learn the location of each formula in the FE Reference Handbook, and review the common traps for each topic. FE for Raccoons offers free practice across all 15 chapters.',
  },
  {
    q: 'Is there a free way to study for the FE Civil exam?',
    a: `Yes. FE for Raccoons is a free FE Civil study platform: bite-sized lessons, ${PROBLEM_COUNT_LABEL} practice problems across all 15 NCEES topics, and a personalized 5-minute diagnostic — all free. The only paid feature is an optional, one-time timed exam simulation.`,
  },
  {
    q: 'How much does FE for Raccoons cost?',
    a: `The core study experience is free — the lessons, ${PROBLEM_COUNT_LABEL} practice problems, and the diagnostic. The only paid item is an optional one-time timed exam simulation: $${STUDENT_PRICE} for verified students (.edu) or $${STANDARD_PRICE} standard. There is no subscription.`,
  },
];

export function ExamGuide() {
  const topics = allTopics();
  const url = `${SITE}/fe-civil-exam-guide`;
  const title = 'FE Civil Exam Guide — Format, Topics & Free Study Resources | FE for Raccoons';
  const description = 'Complete FE Civil exam guide: 110-question CBT format, all 15 NCEES topic areas with free study guides, key formulas, sample problems, and how to prepare. Free FE Civil practice.';

  const jsonLd = [
    {
      '@context': 'https://schema.org',
      '@type': 'Article',
      headline: 'FE Civil Exam Guide: Format, Topics, and How to Prepare',
      description,
      url,
      author: { '@type': 'Organization', name: 'FE for Raccoons' },
      publisher: { '@type': 'Organization', name: 'FE for Raccoons', url: SITE },
      about: { '@type': 'Thing', name: 'Fundamentals of Engineering (FE) Civil Exam' },
    },
    {
      '@context': 'https://schema.org',
      '@type': 'FAQPage',
      mainEntity: FAQ.map((f) => ({ '@type': 'Question', name: f.q, acceptedAnswer: { '@type': 'Answer', text: f.a } })),
    },
    {
      '@context': 'https://schema.org',
      '@type': 'ItemList',
      name: 'FE Civil exam topics',
      itemListElement: topics.map((t, i) => ({ '@type': 'ListItem', position: i + 1, name: t.name, url: `${SITE}/fe-civil/${t.id}` })),
    },
  ];

  useSeo({ title, description, canonical: url, jsonLd });

  return (
    <main className="pub pub-accent-ember">
      {/* Hero */}
      <header className="pub-hero">
        <div className="pub-hero-text">
          <span className="pub-label"><span className="pub-label-dash" />Free FE Civil Exam Resource</span>
          <h1>The FE Civil Exam: format, topics &amp; how to prepare</h1>
          <p className="pub-lede">
            The NCEES FE Civil exam is a {EXAM_FACTS.questions}-question, computer-based test and the first
            step toward your PE license. This guide breaks down the format and every topic area — with free
            study guides, key formulas, and sample problems for all 15 chapters.
          </p>
          <div className="pub-cta-row">
            <Link className="pub-btn pub-btn-primary" to="/login">Start practicing free <ArrowRight size={16} weight="bold" /></Link>
          </div>
        </div>
      </header>

      {/* Exam at a glance */}
      <section className="pub-section">
        <span className="pub-label"><span className="pub-label-dash" />At a glance</span>
        <h2>FE Civil exam at a glance</h2>
        <ul className="pub-facts">
          <li><span>Questions</span><strong>{EXAM_FACTS.questions} multiple-choice</strong></li>
          <li><span>Time</span><strong>{EXAM_FACTS.durationLabel}</strong></li>
          <li><span>Delivery</span><strong>{EXAM_FACTS.delivery}</strong></li>
          <li><span>Reference</span><strong>{EXAM_FACTS.reference}</strong></li>
          <li><span>Governing body</span><strong>{EXAM_FACTS.body}</strong></li>
        </ul>
      </section>

      {/* All 15 topics — chapter rows */}
      <section className="pub-section pub-panel">
        <span className="pub-label"><span className="pub-label-dash" />All 15 chapters</span>
        <h2>Every FE Civil topic area</h2>
        <p className="pub-section-lede">Each guide covers what NCEES tests, key handbook formulas, sample problems, and the mistakes that cost points.</p>
        <div className="pub-ch-list">
          {topics.map((t) => {
            const Icon = t.icon;
            return (
              <Link key={t.id} to={`/fe-civil/${t.id}`} className={`pub-ch-row pub-accent-${t.accent}`}>
                <span className="pub-ch-num">{String(t.num).padStart(2, '0')}</span>
                <span className="pub-ch-icon">{Icon && <Icon size={22} weight="duotone" />}</span>
                <span className="pub-ch-name">{t.name}</span>
                <span className="pub-ch-badge">{t.questionRange} Qs</span>
                <CaretRight size={16} className="pub-ch-caret" />
              </Link>
            );
          })}
        </div>
      </section>

      {/* FAQ */}
      <section className="pub-section">
        <span className="pub-label"><span className="pub-label-dash" />FAQ</span>
        <h2>Frequently asked questions</h2>
        <div className="pub-faq">
          {FAQ.map((f, i) => (
            <details key={i} className="pub-eli5">
              <summary>{f.q}</summary>
              <p>{f.a}</p>
            </details>
          ))}
        </div>
      </section>

      <section className="pub-final-cta">
        <h2>Ready to start?</h2>
        <p>Free FE Civil practice across all 15 chapters — bite-sized lessons, instant feedback, and progress tracking.</p>
        <Link className="pub-btn pub-btn-primary" to="/login">Create a free account <ArrowRight size={16} weight="bold" /></Link>
      </section>
    </main>
  );
}
