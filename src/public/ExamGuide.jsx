import React from 'react';
import { Link } from 'react-router-dom';
import { useSeo } from '../seo/useSeo';
import { allTopics, EXAM_FACTS, EXAM_DAY, FE_PASS_RATE, CHECKED_ON } from './content';
import { PROBLEM_COUNT_LABEL } from '../data/contentStats';
import { AppArrow } from '../components/brand/AppArrow';
import { RaccoonPeek } from '../components/brand/RaccoonPeek';
import { ChapterCoin } from '../components/brand/ChapterCoin';
import './public.css';
import './examGuide.css';

const SITE = 'https://fe4raccoons.com';

// Every fact below was checked against ncees.org on CHECKED_ON. The study plan
// is ours and says so.
const SECTIONS = [
  ['cost', 'Cost'],
  ['format', 'Format and exam day'],
  ['calculator', 'Calculators'],
  ['pass-rate', 'Pass rate'],
  ['topics', 'The 15 topics'],
  ['study-plan', 'How to study'],
  ['fe-vs-pe', 'FE vs PE'],
  ['results', 'Results and retakes'],
  ['faq', 'Questions'],
];

const COSTS = [
  { item: 'NCEES exam fee', note: 'Paid to NCEES when you register. The same fee applies to every attempt.', amount: '$225' },
  { item: 'Reschedule or cancel', note: 'Paid to Pearson VUE online, at least 48 hours before your appointment.', amount: '$50' },
  { item: 'State board application', note: 'Some licensing boards charge their own fee. Check the board you pick at registration.', amount: 'Varies' },
  { item: 'Reference handbook', note: 'The FE Reference Handbook is on screen during the exam. Download a copy from your MyNCEES account.', amount: '$0' },
];

const CALCULATORS = [
  { brand: 'Casio', models: ['fx-115', 'fx-991'], rule: 'Any model with one of these in its name, fx-9910 models included.' },
  { brand: 'Hewlett Packard', models: ['HP 33s', 'HP 35s'], rule: 'These two models and no other HP.' },
  { brand: 'Texas Instruments', models: ['TI-30X', 'TI-36X'], rule: 'Any model with one of these in its name.' },
];

const PLAN = [
  { weeks: 'Week 1', from: 1, to: 1, name: 'Map', text: 'Take a diagnostic to see where you stand, and download the FE Reference Handbook so you study from the same PDF you will search on exam day.' },
  { weeks: 'Weeks 2 to 7', from: 2, to: 7, name: 'Build', text: 'Work chapter by chapter, heaviest first: Water Resources, Structural, Geotechnical and Transportation carry the most questions. Solve problems every day, not just notes.' },
  { weeks: 'Weeks 8 and 9', from: 8, to: 9, name: 'Mix', text: 'Switch to mixed sets from every chapter at exam pace, about 3 minutes a question. Find each formula in the handbook instead of from memory.' },
  { weeks: 'Week 10', from: 10, to: 10, name: 'Rehearse', text: 'Sit one full 110-question practice exam in a single 5 hour 20 minute block, then spend your last days on the chapters it exposed.' },
];

const FE_VS_PE = [
  ['When you take it', 'Senior year or right after graduating', 'After about 4 years of work experience'],
  ['Questions', '110', '80'],
  ['Exam time', '5 hours 20 minutes', '8 hours'],
  ['Appointment', 'About 6 hours', '9 hours'],
  ['NCEES fee', '$225', '$400'],
  ['Reference', 'FE Reference Handbook only', 'Handbook plus design standards'],
  ['Civil versions', 'One: FE Civil', 'Five depths: Construction, Geotechnical, Structural, Transportation, Water Resources and Environmental'],
  ['First-time pass rate', `${FE_PASS_RATE.rate}%`, '60% to 71%, by depth'],
  ['What it leads to', 'Engineer Intern (EI or EIT) certification from your state board', 'The PE license'],
];

const FAQ = [
  {
    q: 'How much does the FE Civil exam cost?',
    a: 'The NCEES fee is $225 per attempt. Rescheduling or canceling online costs $50 through Pearson VUE, and some state boards add their own application fee.',
  },
  {
    q: 'How many questions are on the FE Civil exam?',
    a: 'The FE Civil exam has 110 questions over 5 hours and 20 minutes of exam time. The full appointment is about 6 hours, including a short tutorial and a 25-minute scheduled break.',
  },
  {
    q: 'What calculator can I use on the FE exam?',
    a: 'Only NCEES-approved models: Casio models with fx-115 or fx-991 in the name, the HP 33s and HP 35s, and Texas Instruments models with TI-30X or TI-36X in the name. A TI-30XS is also available on screen.',
  },
  {
    q: 'What is the FE Civil pass rate?',
    a: `${FE_PASS_RATE.rate}% of first-time FE Civil takers passed in ${FE_PASS_RATE.period} (${FE_PASS_RATE.takers} people), counting graduates of ABET-accredited programs who tested within 12 months of graduating.`,
  },
  {
    q: 'How long should I study for the FE Civil exam?',
    a: 'We suggest 8 to 12 weeks of steady practice. Our 10-week plan spends the first 7 weeks building each chapter, heaviest first, and the last 3 on mixed, timed sets and a full practice exam.',
  },
  {
    q: 'Can I bring the FE Reference Handbook?',
    a: 'No. A searchable PDF of the FE Reference Handbook is provided on screen, and you cannot bring your own copy, notes or books. Study with the PDF from your MyNCEES account so you know where everything is.',
  },
  {
    q: 'How soon do I get my FE results?',
    a: 'NCEES says results are typically available within 7 to 10 business days. A few licensing boards take 8 to 10 weeks.',
  },
  {
    q: 'How many times can I retake the FE exam?',
    a: 'Once per testing window and no more than three times in any 12-month period. Some boards are stricter, and each attempt costs the full fee.',
  },
  {
    q: 'Is there a free way to study for the FE Civil exam?',
    a: `Yes. FE for Raccoons is completely free to study with: bite-sized lessons, ${PROBLEM_COUNT_LABEL} practice problems across all 15 NCEES topics, and a diagnostic that shows where to start. No credit card.`,
  },
];

// The exam day, drawn to scale. Widths are minutes out of the whole appointment.
function ExamDayStrip() {
  const total = EXAM_DAY.reduce((s, p) => s + p.minutes, 0);
  const hours = Array.from({ length: Math.floor(total / 60) + 1 }, (_, h) => h);
  return (
    <figure className="eg-day" aria-label={`Exam day, ${total} minutes in all`}>
      <div className="eg-day-bar">
        {EXAM_DAY.map((p) => (
          <div key={p.id} className={`eg-day-seg eg-day-${p.kind}`} style={{ flexGrow: p.minutes }} title={`${p.name}: ${p.label}`}>
            {p.kind === 'exam' && <span>{p.name}, {p.label}</span>}
          </div>
        ))}
      </div>
      <div className="eg-day-ticks" aria-hidden="true">
        {hours.map((h) => <span key={h} style={{ left: `${(h * 60 / total) * 100}%` }}>{h}h</span>)}
      </div>
      <ul className="eg-day-legend">
        <li className="eg-day-key eg-day-admin"><strong>10 min</strong><span>Agreement and tutorial</span></li>
        <li className="eg-day-key eg-day-exam"><strong>5 h 20 min</strong><span>Exam clock, shared by both halves</span></li>
        <li className="eg-day-key eg-day-break"><strong>25 min</strong><span>Scheduled break</span></li>
      </ul>
    </figure>
  );
}

// 100 squares, one per examinee in a hundred.
function PassGrid({ rate }) {
  return (
    <div className="eg-waffle" role="img" aria-label={`${rate} of every 100 first-time takers passed`}>
      {Array.from({ length: 100 }, (_, i) => <span key={i} className={i < rate ? 'is-pass' : ''} />)}
    </div>
  );
}

function bounds(range) {
  const [lo, hi] = String(range).split(/[–-]/).map(Number);
  return { lo, hi: hi || lo };
}

// Topic weights. Mathematics and Statistics share one NCEES range, so they
// share one bar.
function TopicBars({ topics }) {
  const rows = [];
  for (const t of topics) {
    if (t.id === 'statistics') continue;
    const pair = t.id === 'mathematics' ? [t, topics.find((x) => x.id === 'statistics')].filter(Boolean) : [t];
    rows.push({ key: t.id, pair, range: t.questionRange });
  }
  return (
    <ol className="eg-bars">
      {rows.map(({ key, pair, range }) => (
        <li key={key} className="eg-bar-row">
          <div className="eg-bar-name">
            {pair.map((t) => (
              <span key={t.id} className="eg-bar-topic">
                <ChapterCoin chapterId={t.id} accent={t.accent} />
                <Link to={`/fe-civil/${t.id}`}>{t.name}</Link>
              </span>
            ))}
          </div>
          <div className="eg-bar-track" aria-hidden="true">
            <span style={{ width: `${(bounds(range).hi / 15) * 100}%`, '--lo': `${(bounds(range).lo / bounds(range).hi) * 100}%` }} />
          </div>
          <span className="eg-bar-qs">{range}{pair.length > 1 && <small>combined</small>}</span>
          <span className="eg-bar-links">
            {pair.map((t) => (
              <Link key={t.id} to={`/fe-civil/${t.id}/practice-problems`} aria-label={`${t.name} practice problems`}>
                {pair.length > 1 ? `${t.id === 'mathematics' ? 'Math' : 'Stats'} practice` : 'Practice'}
              </Link>
            ))}
          </span>
        </li>
      ))}
    </ol>
  );
}

// Contents rail: marks the section in view.
function useActiveSection(ids) {
  const [active, setActive] = React.useState(ids[0]);
  React.useEffect(() => {
    if (typeof window === 'undefined' || !('IntersectionObserver' in window)) return undefined;
    const io = new IntersectionObserver((entries) => {
      const seen = entries.filter((e) => e.isIntersecting).sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top);
      if (seen[0]) setActive(seen[0].target.id);
    }, { rootMargin: '-8% 0px -80% 0px' });
    ids.forEach((id) => { const el = document.getElementById(id); if (el) io.observe(el); });
    return () => io.disconnect();
  }, [ids]);
  return active;
}

const SECTION_IDS = SECTIONS.map(([id]) => id);

export function ExamGuide() {
  const topics = allTopics();
  const active = useActiveSection(SECTION_IDS);
  const url = `${SITE}/fe-civil-exam-guide`;
  const title = 'FE Civil Exam Guide 2026: Cost, Format, Calculators, Pass Rate & Topics | FE for Raccoons';
  const description = `Everything about the FE Civil exam in one place: the $225 fee, 110 questions in 5 hours 20 minutes, approved calculators, the ${FE_PASS_RATE.rate}% pass rate, all 15 topics, a 10-week study plan, and FE vs PE.`;

  const jsonLd = [
    {
      '@context': 'https://schema.org',
      '@type': 'Article',
      headline: 'FE Civil Exam Guide 2026: cost, format, calculators, pass rate and topics',
      description,
      url,
      dateModified: CHECKED_ON.iso,
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
    <main className="pub eg">
      <header className="eg-hero">
        <div className="eg-hero-text">
          <span className="pub-label">FE Civil exam guide, 2026</span>
          <h1>The FE Civil exam, explained in one page</h1>
          <p className="pub-lede">
            What it costs, how the day runs, which calculators are allowed, how many people pass, and what is on it.
            Then a 10-week plan to get ready. Every fact is checked against NCEES.
          </p>
          <div className="pub-cta-row">
            <Link className="pub-btn pub-btn-primary" to="/login">Start practicing free <AppArrow /></Link>
          </div>
          <p className="eg-checked">Checked against ncees.org on {CHECKED_ON.label}.</p>
        </div>
        <aside className="eg-short" aria-label="The short version">
          <h2>The short version</h2>
          <dl>
            <div><dt>Fee</dt><dd>$225 per attempt</dd></div>
            <div><dt>Questions</dt><dd>{EXAM_FACTS.questions}</dd></div>
            <div><dt>Exam time</dt><dd>5 h 20 min</dd></div>
            <div><dt>Where</dt><dd>Pearson VUE, year-round</dd></div>
            <div><dt>Pass rate</dt><dd>{FE_PASS_RATE.rate}% first time</dd></div>
            <div><dt>Results</dt><dd>7 to 10 business days</dd></div>
          </dl>
        </aside>
      </header>

      <div className="eg-body">
        <nav className="eg-rail" aria-label="On this page">
          <p className="eg-rail-title">On this page</p>
          <ol>
            {SECTIONS.map(([id, name]) => (
              <li key={id}><a href={`#${id}`} className={active === id ? 'is-active' : undefined} aria-current={active === id ? 'location' : undefined}>{name}</a></li>
            ))}
          </ol>
        </nav>

        <div className="eg-main">
          <section id="cost" className="eg-section">
            <h2>What the FE Civil exam costs</h2>
            <div className="eg-split">
              <ul className="eg-ledger">
                {COSTS.map((c) => (
                  <li key={c.item}>
                    <div>
                      <strong>{c.item}</strong>
                      <p>{c.note}</p>
                    </div>
                    <span className="eg-ledger-amount">{c.amount}</span>
                  </li>
                ))}
              </ul>
              <div className="eg-callout">
                <p className="eg-callout-big">$225</p>
                <p>is what most people pay in total. The fee does not carry over, so a retake costs another $225, which makes passing the first time the cheapest plan.</p>
              </div>
            </div>
          </section>

          <section id="format" className="eg-section">
            <h2>Format and exam day</h2>
            <p className="eg-intro">
              You sit at a Pearson VUE test center on a date you pick, any time of year. The exam is {EXAM_FACTS.questions} questions,
              mostly multiple choice, with a few other types such as fill in the number or select all that apply.
              Here is the whole appointment, drawn to scale.
            </p>
            <ExamDayStrip />
            <div className="eg-cols eg-cols-2">
              <div>
                <h3>One clock for both halves</h3>
                <p>The 5 hours 20 minutes is shared. After about half the questions you review and submit the first half, then you are offered the break. Once submitted, the first half is closed. That is about 2.9 minutes a question.</p>
              </div>
              <div>
                <h3>What is on your desk</h3>
                <p>A searchable FE Reference Handbook PDF on screen, an on-screen TI-30XS, 2 reusable booklets and 3 markers, and your own approved calculator. Phones, watches, notes and books stay in a locker.</p>
              </div>
            </div>
          </section>

          <section id="calculator" className="eg-section">
            <h2>Approved calculators</h2>
            <p className="eg-intro">NCEES allows only these three families. Check the model name printed on yours before exam day, and leave the cover in your locker.</p>
            <ul className="eg-calcs">
              {CALCULATORS.map((c) => (
                <li key={c.brand}>
                  <h3>{c.brand}</h3>
                  <p className="eg-models">{c.models.map((m) => <span key={m}>{m}</span>)}</p>
                  <p>{c.rule}</p>
                </li>
              ))}
            </ul>
            <p className="eg-note">Practice with the calculator you will bring. Knowing its keys by heart saves minutes, and the exam has no minutes to spare.</p>
          </section>

          <section id="pass-rate" className="eg-section">
            <h2>FE Civil pass rate</h2>
            <div className="eg-pass">
              <PassGrid rate={FE_PASS_RATE.rate} />
              <div className="eg-pass-text">
                <p className="eg-pass-num">{FE_PASS_RATE.rate}%</p>
                <p>
                  of first-time FE Civil takers passed in {FE_PASS_RATE.period}. That was {FE_PASS_RATE.takers} people, counting graduates
                  of ABET-accredited programs who tested within 12 months of graduating.
                </p>
                <p>So even in this group, about 1 in 3 does not pass the first time. Civil also has more takers than any other FE discipline.</p>
              </div>
            </div>
          </section>

          <RaccoonPeek at={0.9}>
            <section id="topics" className="eg-section eg-panel">
              <h2>The 15 topics and how many questions each gets</h2>
              <p className="eg-intro">
                NCEES gives each topic a range of questions. The solid bar is the fewest you will see and the pale part runs to the most,
                so longer bars deserve more of your time. Each name opens a free study guide, and each practice link opens worked problems.
              </p>
              <TopicBars topics={topics} />
            </section>
          </RaccoonPeek>

          <section id="study-plan" className="eg-section">
            <h2>How to study: a 10-week plan</h2>
            <p className="eg-intro">This is our plan, not an NCEES rule. Stretch each phase if you have more time, but keep the order.</p>
            <div className="eg-weeks" aria-hidden="true">
              {PLAN.flatMap((p, i) => Array.from({ length: p.to - p.from + 1 }, (_, k) => (
                <span key={p.from + k} className={`eg-phase-${i + 1}`}>{p.from + k}</span>
              )))}
            </div>
            <ol className="eg-plan">
              {PLAN.map((p, i) => (
                <li key={p.name} className={`eg-phase-${i + 1}`}>
                  <span className="eg-plan-weeks">{p.weeks}</span>
                  <h3>{p.name}</h3>
                  <p>{p.text}</p>
                </li>
              ))}
            </ol>
            <p className="eg-note">
              Want to hear it from someone who just took it? <Link to="/stories/mitch">Read how Mitch passed the FE Civil on the first try</Link>.
            </p>
          </section>

          <section id="fe-vs-pe" className="eg-section">
            <h2>FE vs PE</h2>
            <p className="eg-intro">Two exams, years apart. You take the FE around graduation, build about 4 years of experience, then sit the PE in your specialty.</p>
            <div className="pub-table-wrap">
              <table className="eg-table">
                <thead>
                  <tr><th scope="col"><span className="eg-sr">Compare</span></th><th scope="col">FE Civil</th><th scope="col">PE Civil</th></tr>
                </thead>
                <tbody>
                  {FE_VS_PE.map(([k, fe, pe]) => (
                    <tr key={k}><th scope="row">{k}</th><td>{fe}</td><td>{pe}</td></tr>
                  ))}
                </tbody>
              </table>
            </div>
          </section>

          <section id="results" className="eg-section">
            <h2>Results and retakes</h2>
            <div className="eg-cols eg-cols-2">
              <div>
                <h3>Results</h3>
                <p>NCEES says results typically arrive within 7 to 10 business days. A few licensing boards take 8 to 10 weeks. You see pass or fail, and a fail comes with a report of how you did in each topic.</p>
              </div>
              <div>
                <h3>Retakes</h3>
                <p>You can take the exam once per testing window and no more than three times in 12 months. Some boards are stricter. Each attempt costs the full $225.</p>
              </div>
            </div>
          </section>

          <section id="faq" className="eg-section">
            <h2>Questions people ask</h2>
            <div className="eg-faq">
              {FAQ.map((f) => (
                <details key={f.q} className="pub-eli5">
                  <summary>{f.q}</summary>
                  <p>{f.a}</p>
                </details>
              ))}
            </div>
            <p className="eg-sources">
              Sources: the NCEES <a href="https://ncees.org/exams/fe-exam/" rel="noopener">FE exam page</a> (fee, format, pass rates, results),
              the NCEES <a href="https://ncees.org/exams/" rel="noopener">exams page</a> (calculator policy), the
              NCEES Examinee Guide (exam day, retakes) and the <a href="https://ncees.org/exams/pe-exam/" rel="noopener">PE exam page</a>.
            </p>
          </section>
        </div>
      </div>

      <section className="pub-final-cta">
        <h2>Start with one chapter today</h2>
        <p>Free FE Civil practice across all 15 topics: bite-sized lessons, {PROBLEM_COUNT_LABEL} problems with worked solutions, and progress that remembers what you missed. Completely free.</p>
        <Link className="pub-btn pub-btn-primary" to="/login">Create a free account <AppArrow /></Link>
      </section>
    </main>
  );
}
