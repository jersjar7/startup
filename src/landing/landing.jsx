import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import {
  ArrowRight,
  Lightning,
  BookOpenText,
  MapPin,
  Warning,
  Exam,
  Function,
  ChartBar,
  Scales,
  CurrencyDollar,
  Barbell,
  Atom,
  Wrench,
  CubeTransparent,
  Drop,
  Compass,
  WaveSine,
  Bridge,
  Mountains,
  Path,
  HardHat,
  CaretDown,
  Play,
  BookBookmark,
  SealWarning,
  ArrowsClockwise,
  Tag,
  LockSimple,
  Eye,
  EyeSlash,
  ArrowSquareOut,
  CheckCircle,
  Timer,
} from '@phosphor-icons/react';
import { HeroSvg, TopicLabel } from './hero-svg';
import { BeamDiagram } from './beam-diagram';
import { Math } from './math';
import './landing.css';
import './hero-svg.css';
import { STUDENT_PRICE, STANDARD_PRICE } from '../data/pricing';

/* ── Chapter data (15 FE Civil topics) ── */
const chapters = [
  { num: 1,  name: 'Mathematics',            qs: '8–12',  icon: Function,         accent: 'ember' },
  { num: 2,  name: 'Probability & Statistics', qs: '4–6',  icon: ChartBar,         accent: 'sunbeam' },
  { num: 3,  name: 'Ethics & Prof. Practice', qs: '4–6',   icon: Scales,           accent: 'forest' },
  { num: 4,  name: 'Engineering Economics',   qs: '5–8',   icon: CurrencyDollar,   accent: 'ember' },
  { num: 5,  name: 'Statics',                qs: '8–12',  icon: Barbell,          accent: 'sunbeam' },
  { num: 6,  name: 'Dynamics',               qs: '4–6',   icon: Atom,             accent: 'forest' },
  { num: 7,  name: 'Mechanics of Materials', qs: '7–11',  icon: Wrench,           accent: 'ember' },
  { num: 8,  name: 'Materials',              qs: '5–8',   icon: CubeTransparent,  accent: 'sunbeam' },
  { num: 9,  name: 'Fluid Mechanics',        qs: '6–9',   icon: Drop,             accent: 'forest' },
  { num: 10, name: 'Surveying',              qs: '6–9',   icon: Compass,          accent: 'ember' },
  { num: 11, name: 'Water Resources & Env.', qs: '10–15', icon: WaveSine,         accent: 'sunbeam' },
  { num: 12, name: 'Structural Engineering', qs: '10–15', icon: Bridge,           accent: 'forest' },
  { num: 13, name: 'Geotechnical Eng.',      qs: '10–15', icon: Mountains,        accent: 'ember' },
  { num: 14, name: 'Transportation Eng.',    qs: '9–14',  icon: Path,             accent: 'sunbeam' },
  { num: 15, name: 'Construction Eng.',      qs: '8–12',  icon: HardHat,          accent: 'forest' },
];

/* ── Sample problem data ── */
const sampleProblem = {
  chapter: 'Ch. 5 — Statics',
  lesson: 'Bending Moment in Simply Supported Beams',
  difficulty: 'Medium',
  statement:
    'A simply supported beam of length 6 m carries a uniformly distributed load of 10 kN/m over its entire span. Determine the maximum bending moment.',
  choices: [
    { label: 'A', text: '30 kN·m' },
    { label: 'B', text: '45 kN·m' },
    { label: 'C', text: '60 kN·m' },
    { label: 'D', text: '22.5 kN·m' },
  ],
  eli5: 'Imagine laying a ruler across two books and pressing down evenly with your hand. The ruler bends the most right in the middle — that\'s where the bending moment is greatest. For a uniform load on a simple beam, the max moment is always at the center.',
  video: 'https://www.youtube.com/watch?v=vm__If17_jE',
  handbookPage: 'p. 128',
  handbookFormula: 'M_{max} = \\frac{wL^2}{8}',
  traps: [
    'The formula is wL²/8 — not wL/8. The square matters.',
    'Units must be consistent: kN/m × m² = kN·m.',
  ],
};

export function Landing({ userName }) {
  const navigate = useNavigate();
  useDocumentTitle('Free FE Civil Exam Prep');
  const [openPanel, setOpenPanel] = React.useState(null);

  React.useEffect(() => {
    if (userName) {
      navigate('/dashboard');
    }
  }, [userName, navigate]);

  const togglePanel = (panel) => {
    setOpenPanel((prev) => (prev === panel ? null : panel));
  };

  return (
    <>
      {/* ══════ HERO ══════ */}
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
            Get Started
            <ArrowRight weight="bold" size={18} />
          </button>
          <p className="hero-price">
            <strong>The whole platform is free</strong> — every lesson, 990 practice problems,
            the diagnostic, and spaced repetition. No trial, no credit card. The one optional
            extra is a full timed exam simulation: ${STUDENT_PRICE} for students, ${STANDARD_PRICE} standard.
          </p>
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

      {/* ══════ SECTION — WATCH HOW IT WORKS ══════ */}
      <section className="s-video">
        <div className="s-video__inner">
          <span className="section-label">
            <span className="section-label-dash" />
            See it in action
          </span>
          <h2 className="s-video__heading">Watch how it works</h2>
          <p className="s-video__sub">
            From the free diagnostic to exam-day confidence — the whole platform in under 30 seconds.
          </p>
          <div className="s-video__frame">
            <video
              className="s-video__player"
              controls
              preload="metadata"
              poster="/explainer-poster.jpg"
            >
              <source src="/explainer.mp4" type="video/mp4" />
              Your browser does not support the video tag.
            </video>
          </div>
        </div>
      </section>

      {/* ══════ SECTION 1 — HOW YOU'LL STUDY ══════ */}
      <section className="s-method">
        <div className="s-method__inner">
          <span className="section-label">
            <span className="section-label-dash" />
            How it works
          </span>
          <h2 className="s-method__heading">
            Every problem is a <em>complete lesson.</em>
          </h2>

          <div className="method-stack">
            <div className="method-row">
              <div className="method-num-col">
                <span className="method-num">01</span>
              </div>
              <div className="method-content">
                <h3 className="method-title">
                  <Lightning weight="bold" size={20} className="method-icon method-icon--ember" />
                  Problem-first learning
                </h3>
                <p className="method-desc">
                  You see the problem before anything else. Try it, struggle with it, then we break it down — that's how real understanding sticks.
                </p>
              </div>
            </div>

            <div className="method-row">
              <div className="method-num-col">
                <span className="method-num">02</span>
              </div>
              <div className="method-content">
                <h3 className="method-title">
                  <BookOpenText weight="bold" size={20} className="method-icon method-icon--forest" />
                  ELI5 explanations
                </h3>
                <p className="method-desc">
                  Every concept explained like you're five. No jargon walls. Civil engineering is intuitive — your professors just didn't have time to show you why.
                </p>
              </div>
            </div>

            <div className="method-row">
              <div className="method-num-col">
                <span className="method-num">03</span>
              </div>
              <div className="method-content">
                <h3 className="method-title">
                  <MapPin weight="bold" size={20} className="method-icon method-icon--sunbeam" />
                  FE Handbook mapped
                </h3>
                <p className="method-desc">
                  We tell you exactly which page of the Reference Handbook has the formula you need. On exam day, you'll know where to look in seconds.
                </p>
              </div>
            </div>

            <div className="method-row">
              <div className="method-num-col">
                <span className="method-num">04</span>
              </div>
              <div className="method-content">
                <h3 className="method-title">
                  <Warning weight="bold" size={20} className="method-icon method-icon--ember" />
                  Traps & common mistakes
                </h3>
                <p className="method-desc">
                  Every problem flags the mistakes that trip people up — unit errors, sign flips, wrong formulas. You'll see them before they see you.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ══════ SECTION 2 — 15 CHAPTERS ══════ */}
      <section className="s-chapters">
        <div className="s-chapters__inner">
          <span className="section-label">
            <span className="section-label-dash" />
            Full exam coverage
          </span>
          <h2 className="s-chapters__heading">
            15 chapters. 110 questions. <em>All of it.</em>
          </h2>
          <p className="s-chapters__sub">
            Every topic the NCEES tests, broken down problem by problem.
          </p>

          <div className="chapters-list">
            {chapters.map((ch) => {
              const Icon = ch.icon;
              return (
                <div key={ch.num} className="ch-row">
                  <span className="ch-num">{String(ch.num).padStart(2, '0')}</span>
                  <Icon weight="bold" size={18} className={`ch-icon ch-icon--${ch.accent}`} />
                  <span className="ch-name">{ch.name}</span>
                  <span className={`ch-badge ch-badge--${ch.accent}`}>{ch.qs} Qs</span>
                </div>
              );
            })}
          </div>

          <div className="chapters-total">
            <Exam weight="bold" size={20} />
            <span>110 questions total — we cover every single one.</span>
          </div>
        </div>
      </section>

      {/* ══════ SECTION 3 — SAMPLE PROBLEM (split layout) ══════ */}
      <section className="s-sample">
        <div className="s-sample__inner">
          <span className="section-label">
            <span className="section-label-dash" />
            See it in action
          </span>
          <h2 className="s-sample__heading">
            This is what every problem looks like.
          </h2>

          <div className="sample-split">
            {/* ── LEFT: problem + choices on engineering paper ── */}
            <div className="sample-left">
              <div className="sample-paper">
                <div className="sample-paper-header">
                  <span className="sample-chapter">{sampleProblem.chapter}</span>
                  <span className="sample-difficulty sample-difficulty--medium">{sampleProblem.difficulty}</span>
                </div>
                <div className="sample-problem-area">
                  <p className="sample-statement">{sampleProblem.statement}</p>
                  <BeamDiagram />
                  <div className="sample-choices">
                    {sampleProblem.choices.map((c) => (
                      <div key={c.label} className="sample-choice">
                        <span className="sample-choice-label">{c.label}</span>
                        <span className="sample-choice-text">{c.text}</span>
                      </div>
                    ))}
                  </div>
                  <div className="sample-submit-btn">
                    Submit Answer
                  </div>
                </div>
              </div>
            </div>

            {/* ── RIGHT: resource panels (matching real app order) ── */}
            <div className="sample-right">
              {/* Lesson (unlocked) */}
              <button
                className={`sample-panel-trigger ${openPanel === 'lesson' ? 'is-open' : ''}`}
                onClick={() => togglePanel('lesson')}
              >
                <Tag weight="bold" size={18} className="spt-icon spt-icon--sunbeam" />
                <span>Lesson</span>
                <CaretDown weight="bold" size={14} className="spt-caret" />
              </button>
              {openPanel === 'lesson' && (
                <div className="sample-panel-body">
                  <p className="sample-lesson-name">{sampleProblem.lesson}</p>
                  <p>This problem belongs to the beam analysis lesson inside the Statics chapter. The lesson covers support types, reaction forces, and bending moment diagrams for common loading conditions.</p>
                </div>
              )}

              {/* FE Handbook (unlocked — new UX) */}
              <button
                className={`sample-panel-trigger ${openPanel === 'handbook' ? 'is-open' : ''}`}
                onClick={() => togglePanel('handbook')}
              >
                <BookBookmark weight="bold" size={18} className="spt-icon spt-icon--forest" />
                <span>FE Handbook</span>
                <CaretDown weight="bold" size={14} className="spt-caret" />
              </button>
              {openPanel === 'handbook' && (
                <div className="sample-panel-body">
                  <div className="sample-handbook-content">
                    <Math tex={sampleProblem.handbookFormula} block />
                    <div className="sample-handbook-page-row">
                      <span className="sample-handbook-hidden">
                        <BookBookmark size={14} weight="bold" />
                        Page hidden
                      </span>
                      <span className="sample-handbook-toggle">
                        <Eye size={14} weight="bold" />
                      </span>
                    </div>
                    <p className="sample-handbook-hint">
                      Practice finding this reference yourself — navigating the handbook quickly is a key exam skill.
                    </p>
                    <a
                      href="https://help.ncees.org/article/87-ncees-exam-reference-handbooks"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="sample-handbook-link"
                    >
                      <ArrowSquareOut size={14} weight="bold" />
                      Download FE Reference Handbook
                    </a>
                    <p className="sample-handbook-link-note">Requires an NCEES account (free to create)</p>
                  </div>
                </div>
              )}

              {/* ELI5 (locked) */}
              <button
                className={`sample-panel-trigger ${openPanel === 'eli5' ? 'is-open' : ''}`}
                onClick={() => togglePanel('eli5')}
              >
                <BookOpenText weight="bold" size={18} className="spt-icon spt-icon--forest" />
                <span>Explain like I'm 5</span>
                {openPanel === 'eli5' ? (
                  <CaretDown weight="bold" size={14} className="spt-caret" />
                ) : (
                  <span className="spt-lock">
                    <LockSimple size={12} weight="bold" />
                    Submit answer to unlock
                  </span>
                )}
              </button>
              {openPanel === 'eli5' && (
                <div className="sample-panel-body">
                  <p>{sampleProblem.eli5}</p>
                </div>
              )}

              {/* Step-by-Step (locked) */}
              <button
                className={`sample-panel-trigger ${openPanel === 'steps' ? 'is-open' : ''}`}
                onClick={() => togglePanel('steps')}
              >
                <ArrowsClockwise weight="bold" size={18} className="spt-icon spt-icon--ember" />
                <span>Step-by-Step</span>
                {openPanel === 'steps' ? (
                  <CaretDown weight="bold" size={14} className="spt-caret" />
                ) : (
                  <span className="spt-lock">
                    <LockSimple size={12} weight="bold" />
                    Submit answer to unlock
                  </span>
                )}
              </button>
              {openPanel === 'steps' && (
                <div className="sample-panel-body">
                  <div className="sample-steps-math">
                    <div className="step-item">
                      <span className="step-num">1</span>
                      <div className="step-content">
                        <p>Identify the given values:</p>
                        <Math tex="w = 10 \text{ kN/m}, \quad L = 6 \text{ m}" block />
                      </div>
                    </div>
                    <div className="step-item">
                      <span className="step-num">2</span>
                      <div className="step-content">
                        <p>For a UDL on a simply supported beam, the maximum bending moment occurs at midspan:</p>
                        <Math tex="M_{max} = \frac{wL^2}{8}" block />
                      </div>
                    </div>
                    <div className="step-item">
                      <span className="step-num">3</span>
                      <div className="step-content">
                        <p>Substitute and solve:</p>
                        <Math tex="M_{max} = \frac{(10)(6)^2}{8} = \frac{360}{8} = 45 \text{ kN·m}" block />
                      </div>
                    </div>
                    <div className="step-item step-item--answer">
                      <span className="step-num">✓</span>
                      <div className="step-content">
                        <p>The maximum bending moment is <Math tex="45 \text{ kN·m}" /> at midspan.</p>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* Video (locked) */}
              <button
                className={`sample-panel-trigger ${openPanel === 'video' ? 'is-open' : ''}`}
                onClick={() => togglePanel('video')}
              >
                <Play weight="bold" size={18} className="spt-icon spt-icon--sunbeam" />
                <span>Video</span>
                {openPanel === 'video' ? (
                  <CaretDown weight="bold" size={14} className="spt-caret" />
                ) : (
                  <span className="spt-lock">
                    <LockSimple size={12} weight="bold" />
                    Submit answer to unlock
                  </span>
                )}
              </button>
              {openPanel === 'video' && (
                <div className="sample-panel-body">
                  <a href={sampleProblem.video} target="_blank" rel="noopener noreferrer" className="sample-link">
                    Watch on YouTube →
                  </a>
                </div>
              )}

              {/* Common Traps (locked) */}
              <button
                className={`sample-panel-trigger ${openPanel === 'traps' ? 'is-open' : ''}`}
                onClick={() => togglePanel('traps')}
              >
                <SealWarning weight="bold" size={18} className="spt-icon spt-icon--ember" />
                <span>Common Traps</span>
                {openPanel === 'traps' ? (
                  <CaretDown weight="bold" size={14} className="spt-caret" />
                ) : (
                  <span className="spt-lock">
                    <LockSimple size={12} weight="bold" />
                    Submit answer to unlock
                  </span>
                )}
              </button>
              {openPanel === 'traps' && (
                <div className="sample-panel-body">
                  <ul className="sample-traps">
                    {sampleProblem.traps.map((t, i) => (
                      <li key={i}>{t}</li>
                    ))}
                  </ul>
                </div>
              )}
            </div>
          </div>
        </div>
      </section>

      {/* ══════ EXAM REALITY CHECK ══════ */}
      <section className="s-reality">
        <div className="s-reality__inner">
          <span className="section-label">
            <span className="section-label-dash" />
            From someone who passed on the first try
          </span>
          <h2 className="s-reality__heading">
            The FE is not as hard as you think.
          </h2>
          <p className="s-reality__text">
            Most exam questions test <strong>one formula or one method</strong> — not multi-step monsters. If you're familiar with the topic and know where to find the formula in the FE Reference Handbook, you can solve it. Quite a few questions are purely conceptual, and some are even drag-and-drop. The exam rewards familiarity, not genius.
          </p>
          <p className="s-reality__text">
            That's exactly how this platform prepares you: learn the concepts, practice applying one method at a time, and memorize where things live in the Handbook. Do that consistently, and you'll walk into the exam confident.
          </p>
        </div>
      </section>

      {/* ══════ PRICING ══════ */}
      <section className="s-pricing">
        <div className="s-pricing__inner">
          <span className="section-label">
            <span className="section-label-dash" />
            Transparent pricing
          </span>
          <h2 className="s-pricing__heading">
            Built for students, not for profit.
          </h2>
          <p className="s-pricing__message">
            We know most people taking the FE are college students or recent grads. You're already paying for tuition, textbooks, and the exam itself. The last thing you need is another platform charging hundreds of dollars for study materials. So we made everything you need to learn and practice completely free — no trial period, no feature gates, no surprises. We only ask you to pay once, when you're ready to put it all to the test.
          </p>

          <div className="pricing-cards">
            {/* Free tier */}
            <div className="pricing-card">
              <div className="pricing-card-header">
                <span className="pricing-card-label">Everything, Free</span>
                <span className="pricing-card-price">$0</span>
                <span className="pricing-card-period">forever · no card required</span>
              </div>
              <ul className="pricing-features">
                <li><CheckCircle weight="bold" size={16} className="pricing-check" /> All 15 chapters of lessons</li>
                <li><CheckCircle weight="bold" size={16} className="pricing-check" /> 990 practice problems</li>
                <li><CheckCircle weight="bold" size={16} className="pricing-check" /> ELI5 explanations</li>
                <li><CheckCircle weight="bold" size={16} className="pricing-check" /> Step-by-step solutions</li>
                <li><CheckCircle weight="bold" size={16} className="pricing-check" /> FE Handbook references</li>
                <li><CheckCircle weight="bold" size={16} className="pricing-check" /> Common traps & mistakes</li>
                <li><CheckCircle weight="bold" size={16} className="pricing-check" /> Review queue & streaks</li>
                <li><CheckCircle weight="bold" size={16} className="pricing-check" /> No time limits or expiry</li>
              </ul>
              <button className="pricing-btn pricing-btn--free" onClick={() => navigate('/login')}>
                Get Started Free
                <ArrowRight weight="bold" size={16} />
              </button>
            </div>

            {/* Paid tier */}
            <div className="pricing-card pricing-card--paid">
              <div className="pricing-card-header">
                <span className="pricing-card-label">Exam Simulation <span className="pricing-card-optional">optional</span></span>
                <span className="pricing-card-price">${STUDENT_PRICE}</span>
                <span className="pricing-card-period">students &middot; ${STANDARD_PRICE} standard &middot; one-time</span>
              </div>
              <p className="pricing-card-desc">
                A bonus for when you're ready to test yourself — everything in Free, plus:
              </p>
              <ul className="pricing-features">
                <li><Timer weight="bold" size={16} className="pricing-check pricing-check--ember" /> Timed 110-question practice exam</li>
                <li><Exam weight="bold" size={16} className="pricing-check pricing-check--ember" /> Weighted by NCEES topic distribution</li>
                <li><CheckCircle weight="bold" size={16} className="pricing-check pricing-check--ember" /> Score breakdown by chapter</li>
                <li><CheckCircle weight="bold" size={16} className="pricing-check pricing-check--ember" /> Unlimited retakes</li>
                <li><CheckCircle weight="bold" size={16} className="pricing-check pricing-check--ember" /> ${STUDENT_PRICE} with a .edu student email</li>
              </ul>
              <button className="pricing-btn pricing-btn--paid" onClick={() => navigate('/login', { state: { returnTo: '/exam' } })}>
                Get Exam Simulation
                <ArrowRight weight="bold" size={16} />
              </button>
            </div>
          </div>

          <p className="s-pricing__footnote">
            We need to keep the servers running and the content growing. Your one-time purchase helps us do that — and helps the next student who finds this platform. No subscriptions, no recurring charges.
          </p>
        </div>
      </section>

      {/* ══════ FINAL CTA ══════ */}
      <section className="s-cta">
        <div className="s-cta__inner">
          <h2 className="s-cta__heading">Ready to pass the FE?</h2>
          <p className="s-cta__sub">Free to start. No credit card. Just problems and explanations.</p>
          <button className="hero-cta" onClick={() => navigate('/login')}>
            Create Free Account
            <ArrowRight weight="bold" size={18} />
          </button>
        </div>
      </section>
    </>
  );
}
