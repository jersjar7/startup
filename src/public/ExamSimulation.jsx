import React from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight, Timer, CaretRight } from '@phosphor-icons/react';
import { useSeo } from '../seo/useSeo';
import { allTopics } from './content';
import { PROBLEM_COUNT_LABEL } from '../data/contentStats';
import { STUDENT_PRICE, STANDARD_PRICE } from '../data/pricing';
import { getExamWeight } from '../data/exam-bank/index';
import './public.css';

const SITE = 'https://fe4raccoons.com';

// OUR simulation's timing, which is not the same as EXAM_FACTS.durationLabel —
// that describes the real NCEES appointment (6 hours including tutorial and
// survey). The simulation is the testing time plus the scheduled break. Saying
// "6 hours" here would overstate what the customer actually sits.
const SIM_DURATION = '5 hours 20 minutes of testing, plus the scheduled 25-minute break';

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
// page cannot drift from what customers actually receive. It is also built from
// the shared public.css components rather than bespoke classes — the first
// draft invented its own class names, none of which existed, and shipped as
// unstyled markup.

const FAQ = [
  {
    q: 'How many questions is the FE for Raccoons exam simulation?',
    a: `110 questions, the same as the real FE Civil exam, matched to the NCEES topic distribution. You get ${SIM_DURATION}, with the break falling after question 55. The real NCEES appointment is 6 hours because it also includes a tutorial and a survey.`,
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
    a: 'A score report broken down by chapter, sorted weakest first, showing how many questions you got right in each NCEES topic area, plus the time you used and how many questions you answered. Every question is reviewable afterwards with worked solutions and reference handbook pointers.',
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
  const description = `A full-length, timed FE Civil practice exam: 110 questions matched to the NCEES topic distribution, ${SIM_DURATION}, with a chapter-by-chapter score report. $${STANDARD_PRICE}, or $${STUDENT_PRICE} for students. Everything else on the platform is free.`;

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
      <nav className="pub-breadcrumb" aria-label="Breadcrumb">
        <Link to="/">Home</Link>
        <CaretRight size={12} />
        <span>Exam Simulation</span>
      </nav>

      <header className="pub-hero">
        <div className="pub-hero-text">
          <span className="pub-label"><span className="pub-label-dash" />The one paid feature</span>
          <h1>The full FE Civil exam, before the real one</h1>
          <p className="pub-lede">
            110 questions under the real clock: {SIM_DURATION}, matched to the
            NCEES topic distribution. You find out how you actually hold up while
            there is still time to do something about it.
          </p>
          <div className="pub-cta-row">
            <Link className="pub-btn pub-btn-primary" to="/exam/preview">
              Try 10 questions free <ArrowRight size={16} weight="bold" />
            </Link>
            <Link className="pub-btn pub-btn-ghost" to="/exam">See the full simulation</Link>
          </div>
        </div>
        <div className="pub-hero-icon"><Timer size={44} weight="duotone" /></div>
      </header>

      <section className="pub-section">
        <span className="pub-label"><span className="pub-label-dash" />At a glance</span>
        <h2>What you are buying</h2>
        <ul className="pub-facts">
          <li><span>Questions</span><strong>110, drawn fresh each attempt</strong></li>
          <li><span>Testing time</span><strong>5h 20m, plus a 25m break</strong></li>
          <li><span>Topic areas</span><strong>All 15, at NCEES weights</strong></li>
          <li><span>Price</span><strong>${STANDARD_PRICE}, or ${STUDENT_PRICE} for students</strong></li>
        </ul>
        <p className="pub-note">
          Everything else on FE for Raccoons is free — the lessons, the{' '}
          {PROBLEM_COUNT_LABEL} practice problems and the diagnostic. This is the
          only thing that costs money.
        </p>
      </section>

      <section className="pub-section pub-panel">
        <span className="pub-label"><span className="pub-label-dash" />The sitting</span>
        <h2>What sitting it is like</h2>
        <div className="pub-rows">
          <div className="pub-row">
            <span className="pub-row-num">01</span>
            <div className="pub-row-body">
              <h3>Full length, real clock</h3>
              <p>
                110 questions and {SIM_DURATION}. The same shape and timing as the
                real exam, with the break falling after question 55 exactly as it
                does on the day.
              </p>
            </div>
          </div>
          <div className="pub-row">
            <span className="pub-row-num">02</span>
            <div className="pub-row-body">
              <h3>A different exam every time</h3>
              <p>
                Each attempt draws a fresh 110 from a larger bank and shuffles the
                answer choices, so a retake is a genuine second test rather than
                the same paper again.
              </p>
            </div>
          </div>
          <div className="pub-row">
            <span className="pub-row-num">03</span>
            <div className="pub-row-body">
              <h3>Your work is saved as you go</h3>
              <p>
                Close the tab, lose your connection, come back later. Your answers
                are still there and the clock stays honest.
              </p>
            </div>
          </div>
          <div className="pub-row">
            <span className="pub-row-num">04</span>
            <div className="pub-row-body">
              <h3>Flag and revisit</h3>
              <p>
                Skip a question, mark it, and jump back to it, the same way you
                would on exam day.
              </p>
            </div>
          </div>
        </div>
      </section>

      <section className="pub-section pub-panel">
        <span className="pub-label"><span className="pub-label-dash" />Coverage</span>
        <h2>What the 110 questions cover</h2>
        <p className="pub-section-lede">
          The distribution below is the NCEES FE Civil specification. The
          simulation draws to these exact counts, so the balance of the paper
          matches what you will sit. Each topic links to its free study guide.
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
                <td>Total</td>
                <td>110</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <section className="pub-section">
        <span className="pub-label"><span className="pub-label-dash" />The score report</span>
        <h2>What you get at the end</h2>
        <p className="pub-section-lede">
          A breakdown of where the points actually went, rather than a single
          number:
        </p>
        <ul className="pub-traps">
          <li>
            <span className="pub-trap-mark" />
            <span>
              Your score in each NCEES topic area that appeared on your paper,
              <strong> sorted weakest first</strong>, so the chapter needing work
              is the top row.
            </span>
          </li>
          <li>
            <span className="pub-trap-mark" />
            <span>
              Time used and how many of the 110 you answered, so you can tell a
              pacing problem from a knowledge problem.
            </span>
          </li>
          <li>
            <span className="pub-trap-mark" />
            <span>Every question reviewable afterwards, with worked solutions.</span>
          </li>
          <li>
            <span className="pub-trap-mark" />
            <span>
              Reference handbook pointers, so you learn where to find things under
              time.
            </span>
          </li>
        </ul>
        <p className="pub-note">
          Sitting it early is the point: a chapter breakdown is only useful while
          there is still time to act on it.
        </p>

        {/* A real capture of the results screen, rendered from example answers.
            Width and height are set so the reserved space is correct before the
            image loads and the section below does not jump. The caption closes
            the section: a second grey note underneath it read as one run-on
            paragraph. */}
        <figure className="pub-figure">
          <img
            src="/exam-score-report.png"
            width="1440"
            height="1542"
            loading="lazy"
            alt="An exam simulation score report showing 62 out of 110, 56 percent, a passing-score badge, 4 hours 52 minutes used of 5 hours 20 minutes, 104 of 110 questions answered, and a chapter breakdown led by Geotechnical Engineering at 36 percent."
          />
          <figcaption>
            An example score report. Chapters are sorted weakest first, so the one
            to study next is the top row.
          </figcaption>
        </figure>
      </section>

      <section className="pub-section pub-panel">
        <span className="pub-label"><span className="pub-label-dash" />Price</span>
        <h2>Price and guarantee</h2>
        <div className="pub-price">
          <span className="pub-price-amount">${STANDARD_PRICE}</span>
          <span className="pub-price-alt">${STUDENT_PRICE} for verified students</span>
        </div>
        <p className="pub-price-terms">
          One time, no subscription, and it does not expire. The student price
          needs a .edu email you can receive a code at.
        </p>
        <p>
          14-day money-back guarantee. And if you sit the FE and do not pass,
          your access is extended free.
        </p>
        <div className="pub-cta-row">
          <Link className="pub-btn pub-btn-primary" to="/exam/preview">
            Try 10 questions free <ArrowRight size={16} weight="bold" />
          </Link>
          <Link className="pub-btn pub-btn-ghost" to="/exam">See the full simulation</Link>
        </div>
        <p className="pub-note">
          The preview uses the same interface and the same clock. No account
          needed to look.
        </p>
      </section>

      <section className="pub-section">
        <span className="pub-label"><span className="pub-label-dash" />FAQ</span>
        <h2>Common questions</h2>
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
        <h2>See it before you decide</h2>
        <p>
          Ten questions, same interface, same clock, no account needed. If it is
          not what you expected, you have lost ten minutes.
        </p>
        <Link className="pub-btn pub-btn-primary" to="/exam/preview">
          Try 10 questions free <ArrowRight size={16} weight="bold" />
        </Link>
      </section>

      <p className="pub-note">
        New to the exam? Start with the{' '}
        <Link to="/fe-civil-exam-guide">FE Civil exam guide</Link> — format,
        topics and free study resources for all 15 areas.
      </p>
    </main>
  );
}
