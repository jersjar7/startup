import React from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight, CheckCircle, Clock, ListChecks, ChartBar } from '@phosphor-icons/react';
import { useSeo } from '../seo/useSeo';
import { allTopics, EXAM_FACTS } from './content';
import { PROBLEM_COUNT_LABEL } from '../data/contentStats';
import { STUDENT_PRICE, STANDARD_PRICE } from '../data/pricing';
import { getExamWeight } from '../data/exam-bank/index';
import './public.css';

const SITE = 'https://fe4raccoons.com';

// The public page for the only paid product. It exists because there was no way
// to read about the Exam Simulation without signing up first — a professor, or
// anyone arriving from social, had to create an account to find out what it is.
//
// Its job is CONVERSION, not ranking. The commercial query it would target
// ("FE civil exam prep") is owned by School of PE, PPI and Civil Engineering
// Academy, and a new page will not displace them. The pages that can rank are
// the free topic guides, which is a separate piece of work.
//
// Every number here is derived from the same source the product uses, so the
// page cannot drift from what customers actually receive.

const FAQ = [
  {
    q: 'How many questions is the FE for Raccoons exam simulation?',
    a: `110 questions, the same as the real FE Civil exam, matched to the NCEES topic distribution. You get ${EXAM_FACTS.durationLabel.toLowerCase()}, with a scheduled break after question 55.`,
  },
  {
    q: 'Are the questions the same every time?',
    a: 'No. Each simulation draws a fresh set of 110 questions from a larger bank, matched to the NCEES distribution, and the answer choices are shuffled. Two people sitting it on the same day get different exams, and a retake differs from the first attempt.',
  },
  {
    q: 'How much does the exam simulation cost?',
    a: `$${STANDARD_PRICE} standard, or $${STUDENT_PRICE} for verified students with a .edu email. One time, no subscription. Everything else on FE for Raccoons — the lessons, the ${PROBLEM_COUNT_LABEL} practice problems and the diagnostic — is free.`,
  },
  {
    q: 'Can I try it before paying?',
    a: 'Yes. There is a free 10-question preview that uses the same interface and timing, so you can see exactly what the full simulation is like before deciding.',
  },
  {
    q: 'What do I get at the end?',
    a: 'A score report broken down by chapter, showing how many questions you got right in each of the 15 NCEES topic areas, plus a full review of every question with worked solutions and reference handbook pointers.',
  },
  {
    q: 'What if I do not pass the real exam?',
    a: 'There is a 14-day money-back guarantee, and if you sit the FE and do not pass, your access is extended free.',
  },
];

export function ExamSimulation() {
  const topics = allTopics();
  const url = `${SITE}/exam-simulation`;
  const title = 'FE Civil Exam Simulation — Full 110-Question Timed Practice Exam | FE for Raccoons';
  const description = `A full-length, timed FE Civil practice exam: 110 questions matched to the NCEES topic distribution, ${EXAM_FACTS.durationLabel.toLowerCase()}, with a chapter-by-chapter score report. $${STANDARD_PRICE}, or $${STUDENT_PRICE} for students. Everything else on the platform is free.`;

  const jsonLd = [
    {
      '@context': 'https://schema.org',
      '@type': 'Product',
      name: 'FE Civil Exam Simulation',
      description,
      brand: { '@type': 'Brand', name: 'FE for Raccoons' },
      url,
      offers: [
        {
          '@type': 'Offer',
          name: 'Standard',
          price: String(STANDARD_PRICE),
          priceCurrency: 'USD',
          url,
          availability: 'https://schema.org/InStock',
        },
        {
          '@type': 'Offer',
          name: 'Verified student (.edu)',
          price: String(STUDENT_PRICE),
          priceCurrency: 'USD',
          url,
          availability: 'https://schema.org/InStock',
        },
      ],
    },
    {
      '@context': 'https://schema.org',
      '@type': 'FAQPage',
      mainEntity: FAQ.map((f) => ({
        '@type': 'Question',
        name: f.q,
        acceptedAnswer: { '@type': 'Answer', text: f.a },
      })),
    },
  ];

  useSeo({ title, description, canonical: url, jsonLd });

  return (
    <main className="pub">
      <article className="pub-wrap">
        <p className="pub-eyebrow">Exam Simulation</p>
        <h1>The full FE Civil exam, before the real one</h1>
        <p className="pub-lede">
          110 questions. {EXAM_FACTS.durationLabel}. Matched to the NCEES topic
          distribution, sat under the real clock. You find out how you actually
          hold up while there is still time to do something about it.
        </p>

        <p className="pub-note">
          Everything else on FE for Raccoons is free — the lessons, the{' '}
          {PROBLEM_COUNT_LABEL} practice problems and the diagnostic. This is the
          only thing that costs money.
        </p>

        <section className="pub-section">
          <h2><Clock size={20} weight="bold" /> What sitting it is like</h2>
          <ul className="pub-list">
            <li>
              <strong>110 questions, {EXAM_FACTS.durationLabel.toLowerCase()}.</strong>{' '}
              The same shape as the real appointment, including the scheduled
              25-minute break after question 55.
            </li>
            <li>
              <strong>A different exam every time.</strong> Each attempt draws a
              fresh 110 from a larger bank and shuffles the answer choices, so a
              retake is a genuine second test rather than the same paper again.
            </li>
            <li>
              <strong>Your work is saved as you go.</strong> Close the tab, lose
              your connection, come back later — your answers are still there.
            </li>
            <li>
              <strong>Flag and revisit.</strong> Skip a question, mark it, and
              jump back to it, the same way you would on exam day.
            </li>
          </ul>
        </section>

        <section className="pub-section">
          <h2><ListChecks size={20} weight="bold" /> What the 110 questions cover</h2>
          <p>
            The distribution below is the NCEES FE Civil specification. The
            simulation draws to these exact counts, so the balance of the paper
            matches what you will sit.
          </p>
          <div className="pub-table-wrap">
            <table className="pub-table">
              <thead>
                <tr><th>Topic area</th><th>Questions</th></tr>
              </thead>
              <tbody>
                {topics.map((t) => (
                  <tr key={t.id}>
                    <td><Link to={`/fe-civil/${t.id}`}>{t.name}</Link></td>
                    <td>{getExamWeight(t.id)}</td>
                  </tr>
                ))}
                <tr className="pub-table-total">
                  <td><strong>Total</strong></td>
                  <td><strong>110</strong></td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>

        <section className="pub-section">
          <h2><ChartBar size={20} weight="bold" /> What you get at the end</h2>
          <p>
            A score report broken down by chapter, so you can see where the
            points actually went rather than just a single number:
          </p>
          <ul className="pub-list">
            <li>Your score in each of the 15 NCEES topic areas, not just overall</li>
            <li>Every question reviewable afterwards, with worked solutions</li>
            <li>Reference handbook pointers, so you learn where to find things under time</li>
            <li>Time used, so you can see whether pacing or knowledge is the problem</li>
          </ul>
          <p className="pub-note">
            Most people discover their weakest chapter is not the one they
            expected. That is the point of sitting it early.
          </p>
        </section>

        <section className="pub-section">
          <h2><CheckCircle size={20} weight="bold" /> Price and guarantee</h2>
          <p>
            <strong>${STANDARD_PRICE} standard, ${STUDENT_PRICE} for verified
            students</strong> with a .edu email. One time, no subscription, and
            it does not expire.
          </p>
          <p>
            14-day money-back guarantee. And if you sit the FE and do not pass,
            your access is extended free.
          </p>
          <div className="pub-cta">
            <Link className="pub-cta-btn" to="/exam/preview">
              Try 10 questions free <ArrowRight size={16} weight="bold" />
            </Link>
            <Link className="pub-cta-link" to="/exam">See the full simulation</Link>
          </div>
          <p className="pub-note">
            The preview uses the same interface and the same clock. No account
            needed to look.
          </p>
        </section>

        <section className="pub-section">
          <h2>Common questions</h2>
          <dl className="pub-faq">
            {FAQ.map((f) => (
              <React.Fragment key={f.q}>
                <dt>{f.q}</dt>
                <dd>{f.a}</dd>
              </React.Fragment>
            ))}
          </dl>
        </section>

        <p className="pub-note">
          New to the exam? Start with the{' '}
          <Link to="/fe-civil-exam-guide">FE Civil exam guide</Link> — format,
          topics and free study resources for all 15 areas.
        </p>
      </article>
    </main>
  );
}
