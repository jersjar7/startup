import React from 'react';
import { Link } from 'react-router-dom';
import { useSeo } from '../seo/useSeo';
import { pageTitle } from '../seo/pageTitle';
import { AppArrow } from '../components/brand/AppArrow';
import { PE_PROBLEMS, isRight } from './peProblems';
import peekUrl from '../assets/brand/raccoon-peek.png';
import './public.css';
import './examGuide.css';
import './peWaitlist.css';

const SITE = 'https://fe4raccoons.com';
export const PE_PATH = '/pe-exam-prep';

// The PE waitlist (owner 2026-10-31). Nothing is built for the PE yet; the
// list decides whether it is, and the "Which PE exam?" answers decide which
// one comes first. The page never says which exam we are building first
// (owner, 2026-10-31).
//
// Layout (mock v3, owner 2026-10-31): a real problem is the hero, because the
// problems are the taste of what we are building and most visitors never
// scroll. The form asks only for email and exam; when they plan to sit it is
// asked after they join.

// Same keys as service/waitlist.js.
export const EXAM_OPTIONS = [
  ['pe-civil-construction', 'PE Civil: Construction'],
  ['pe-civil-geotechnical', 'PE Civil: Geotechnical'],
  ['pe-civil-structural', 'PE Civil: Structural'],
  ['pe-civil-transportation', 'PE Civil: Transportation'],
  ['pe-civil-wre', 'PE Civil: Water Resources and Environmental'],
  ['pe-environmental', 'PE Environmental'],
  ['se-structural', 'SE Structural'],
  ['pe-other', 'Another PE exam'],
  ['not-sure', 'Not sure yet'],
];

export const WHEN_OPTIONS = [
  ['not-booked', 'Not booked yet'],
  ['before-2027-04', 'Before April 2027'],
  ['2027-04-to-12', 'April to December 2027'],
  ['2028-plus', '2028 or later'],
];

const BUILDING = [
  ['Worked problems for every exam topic', 'Exam-depth problems like the ones above. Every solution shows each step, points to the handbook section, and explains each wrong answer.'],
  ['Practice that fits a commute', 'Ten-minute sets on the FE for Raccoons phone app: which method, which equation, which trap. The long calculations wait for your desk.'],
  ['Full timed practice exams', 'The real number of questions, the real clock, scored by topic.'],
];

// Where the signup came from: a tagged link on this visit first, then the
// first visit's tag or referrer that src/app.jsx keeps for signups.
function attribution() {
  const out = {};
  try {
    const params = new URLSearchParams(window.location.search);
    let stored = {};
    try { stored = JSON.parse(localStorage.getItem('fe4r_acq') || '{}') || {}; } catch { /* none */ }
    const ref = document.referrer || '';
    const external = ref && !ref.includes(window.location.host) ? ref : undefined;
    out.utmSource = params.get('utm_source') || stored.utmSource;
    out.utmMedium = params.get('utm_medium') || stored.utmMedium;
    out.utmCampaign = params.get('utm_campaign') || stored.utmCampaign;
    out.referrer = external || stored.referrer;
  } catch { /* nothing to add */ }
  return out;
}

function post(body) {
  return fetch('/api/waitlist', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
}

// After joining: one optional question, when they plan to sit it. Joining
// again with the same address only updates the row, so this is the same call.
function WhenQuestion({ email, exam, place }) {
  const [when, setWhen] = React.useState('');
  const [saved, setSaved] = React.useState(false);
  async function save(e) {
    e.preventDefault();
    if (!when) return;
    try { await post({ email, exam, when, place }); } catch { /* it is optional */ }
    setSaved(true);
  }
  if (saved) return <p className="pe-when-done">Saved. Thank you.</p>;
  return (
    <form className="pe-when" onSubmit={save}>
      <label htmlFor={`pe-when-${place}`}>One more, if you like: when are you taking it?</label>
      <div>
        <select id={`pe-when-${place}`} value={when} onChange={(e) => setWhen(e.target.value)}>
          <option value="" disabled>Choose one</option>
          {WHEN_OPTIONS.map(([v, l]) => <option key={v} value={v}>{l}</option>)}
        </select>
        <button type="submit" disabled={!when}>Save</button>
      </div>
    </form>
  );
}

function WaitlistForm({ place, dark = false }) {
  const [email, setEmail] = React.useState('');
  const [exam, setExam] = React.useState('');
  const [website, setWebsite] = React.useState('');
  const [state, setState] = React.useState({ status: 'idle', msg: '' });

  async function submit(e) {
    e.preventDefault();
    setState({ status: 'sending', msg: '' });
    try {
      const r = await post({ email, exam, place, website, ...attribution() });
      const body = await r.json().catch(() => ({}));
      if (!r.ok) return setState({ status: 'error', msg: body.msg || 'That did not go through. Try again in a minute.' });
      setState({ status: 'done', msg: '' });
    } catch {
      setState({ status: 'error', msg: 'That did not go through. Check your connection and try again.' });
    }
  }

  if (state.status === 'done') {
    return (
      <div className="pe-done" role="status">
        <p><strong>You are on the list.</strong> We sent a confirmation to {email.trim()}.</p>
        <WhenQuestion email={email.trim()} exam={exam} place={place} />
      </div>
    );
  }

  return (
    <form className={`pe-form${dark ? ' pe-form-dark' : ''}`} onSubmit={submit}>
      <input type="email" required autoComplete="email" placeholder="Your email" aria-label="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
      <select required aria-label="Which PE exam?" value={exam} onChange={(e) => setExam(e.target.value)}>
        <option value="" disabled>Which PE exam?</option>
        {EXAM_OPTIONS.map(([v, l]) => <option key={v} value={v}>{l}</option>)}
      </select>
      {/* Hidden from people; a bot that fills it is thanked and dropped. */}
      <input className="pe-hp" type="text" name="website" tabIndex={-1} autoComplete="off" aria-hidden="true" value={website} onChange={(e) => setWebsite(e.target.value)} />
      <button className="pub-btn pub-btn-primary" type="submit" disabled={state.status === 'sending'}>
        {state.status === 'sending' ? 'Joining' : 'Join the list'} <AppArrow />
      </button>
      {state.status === 'error' && <p className="pe-error" role="alert">{state.msg}</p>}
    </form>
  );
}

const ARROW = { stroke: 'var(--info)', fill: 'var(--info)' };

function Figure({ name }) {
  if (name === 'watershed') {
    return (
      <svg viewBox="0 0 420 230" className="pv-fig" role="img" aria-label="Watershed with two subareas draining to one outlet">
        <path d="M10 120 C20 50 120 20 200 30 C260 36 300 30 340 60 C380 90 395 140 360 180 C330 210 260 215 215 205 L205 212 C150 215 60 205 30 180 C10 160 5 140 10 120Z" fill="#F5EDE0" stroke="#2C2C2C" strokeWidth="2" />
        <path d="M200 30 C190 80 215 130 205 205" fill="none" stroke="#2C2C2C" strokeWidth="1.5" strokeDasharray="6 5" />
        <g fontFamily="Inter, sans-serif" fontSize="12" fill="#2C2C2C">
          <text x="36" y="100" fontWeight="600">Subarea 1</text>
          <text x="36" y="118">Residential, 1/4-acre lots</text>
          <text x="36" y="134">90 ac, soil group C</text>
          <text x="232" y="100" fontWeight="600">Subarea 2</text>
          <text x="232" y="118">Woods, good condition</text>
          <text x="232" y="134">60 ac, soil group C</text>
        </g>
        <path d="M205 205 L205 226" stroke={ARROW.stroke} strokeWidth="3" />
        <path d="M199 219 L205 228 L211 219" fill={ARROW.fill} />
        <text x="216" y="224" fontFamily="'JetBrains Mono', monospace" fontSize="11" fill="#3B82B8">OUTLET</text>
      </svg>
    );
  }
  if (name === 'trapezoid') {
    // To scale: 12 px per ft. Bottom 8 ft, banks at 2H:1V, water 3.85 ft deep.
    return (
      <svg viewBox="0 0 420 200" className="pv-fig" role="img" aria-label="Trapezoidal channel drawn to scale, 8 ft bottom, 2H to 1V side slopes, flow depth y">
        <path d="M70 114 L162 160 L258 160 L350 114Z" fill="#DCEBF5" />
        <path d="M18 88 L162 160 L258 160 L402 88" fill="none" stroke="#2C2C2C" strokeWidth="2.5" strokeLinejoin="round" />
        <path d="M70 114 L350 114" stroke="#3B82B8" strokeWidth="2" />
        <path d="M294 106 L300 114 L306 106Z" fill="#3B82B8" />
        <path d="M26 92 L58 92 L58 108" stroke="#2C2C2C" strokeWidth="1" fill="none" />
        <g fontFamily="Inter, sans-serif" fontSize="11" fill="#2C2C2C">
          <text x="38" y="86">2</text>
          <text x="62" y="104">1</text>
        </g>
        <g stroke="#2C2C2C" strokeWidth="1">
          <path d="M162 178 L258 178" /><path d="M162 172 L162 184" /><path d="M258 172 L258 184" />
          <path d="M210 114 L210 160" /><path d="M204 114 L216 114" /><path d="M204 160 L216 160" />
        </g>
        <g fontFamily="Inter, sans-serif" fontSize="13" fill="#2C2C2C">
          <text x="184" y="196">b = 8 ft</text>
          <text x="218" y="143" fontWeight="700" fill="#E8683A">y = ?</text>
        </g>
      </svg>
    );
  }
  return (
    <svg viewBox="0 0 420 200" className="pv-fig" role="img" aria-label="Two circular clarifiers, 60 ft diameter, with peripheral weirs">
      <g fill="#F5EDE0" stroke="#2C2C2C" strokeWidth="2"><circle cx="110" cy="95" r="70" /><circle cx="290" cy="95" r="70" /></g>
      <g fill="none" stroke="#3B82B8" strokeWidth="2" strokeDasharray="4 3"><circle cx="110" cy="95" r="62" /><circle cx="290" cy="95" r="62" /></g>
      <g stroke="#2C2C2C" strokeWidth="1"><path d="M40 95 L180 95" /><path d="M220 95 L360 95" /></g>
      <g fontFamily="Inter, sans-serif" fontSize="12" fill="#2C2C2C">
        <text x="80" y="88">D = 60 ft</text><text x="260" y="88">D = 60 ft</text>
        <text x="70" y="190">Side water depth 12 ft (both)</text>
      </g>
      <text x="254" y="122" fontFamily="'JetBrains Mono', monospace" fontSize="10" fill="#3B82B8">PERIMETER WEIR</text>
    </svg>
  );
}

function ProblemPanel({ p, hidden = false, compact = false }) {
  const [picked, setPicked] = React.useState([]);
  const [typed, setTyped] = React.useState('');
  const [checked, setChecked] = React.useState(false);
  const given = p.kind === 'number' ? typed : picked;
  const right = checked && isRight(p, given);
  const ready = p.kind === 'number' ? typed.trim() !== '' : picked.length > 0;

  function toggle(k) {
    if (checked) return;
    if (p.kind === 'one') setPicked([k]);
    else setPicked((s) => (s.includes(k) ? s.filter((x) => x !== k) : [...s, k]));
  }
  function reset() {
    setPicked([]); setTyped(''); setChecked(false);
  }
  function choiceClass(k) {
    if (!checked) return picked.includes(k) ? ' picked' : '';
    if (p.answer.includes(k)) return ' right';
    return picked.includes(k) ? ' wrong' : '';
  }

  return (
    <div id={`pv-${p.id}`} hidden={hidden} className={compact ? 'pv-compact' : undefined}
      {...(compact ? {} : { role: 'tabpanel', 'aria-labelledby': `pv-tab-${p.id}` })}>
      <div className="pv-panel">
        <div>
          <p className="pv-stem">{p.stem}</p>
          <Figure name={p.figure} />
        </div>
        <div>
          <p className="pv-ask">{p.kind === 'one' ? 'Choose one' : p.kind === 'many' ? 'Select all that apply' : 'Fill in the blank'}</p>
          {p.kind === 'number' ? (
            <label className="pv-fill">
              <input type="text" inputMode="decimal" placeholder="0.00" aria-label={`Normal depth in ${p.unit}`} value={typed} disabled={checked} onChange={(e) => setTyped(e.target.value)} />
              <span>{p.unit}</span>
            </label>
          ) : (
            <div className="pv-choices">
              {p.choices.map(([k, text]) => (
                <label key={k} className={`pv-choice${choiceClass(k)}`}>
                  <input type={p.kind === 'one' ? 'radio' : 'checkbox'} name={`pv-${p.id}`} checked={picked.includes(k)} disabled={checked} onChange={() => toggle(k)} />
                  <span className="pv-key">{k}</span>
                  <span>{text}</span>
                </label>
              ))}
            </div>
          )}
          {!checked ? (
            <button className="pub-btn pub-btn-primary pv-check" type="button" disabled={!ready} onClick={() => setChecked(true)}>
              Check answer <AppArrow />
            </button>
          ) : (
            <button className="pv-again" type="button" onClick={reset}>Clear and try again</button>
          )}
        </div>
      </div>
      {checked && (
        <div className="pv-sol">
          <p className={`pv-result${right ? '' : ' is-miss'}`} role="status">
            <strong>{right ? 'Correct' : 'Not this time'}:</strong> the answer is {p.answerLabel}.
          </p>
          <div className="pv-sol-grid">
            <div>
              <h3>Worked solution</h3>
              <ol className="pv-steps">
                {p.steps.map(([say, math]) => (
                  <li key={say}><span>{say}</span><code>{math}</code></li>
                ))}
              </ol>
              <p className="pv-hb">Handbook: {p.handbook}</p>
            </div>
            <div>
              <h3>Why the wrong answers are tempting</h3>
              <ul className="pv-traps">
                {p.traps.map(([what, why]) => <li key={what}><b>{what}</b> {why}</li>)}
              </ul>
              <p className="pv-pace">Real exam pace: about 6 minutes a question.</p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// The first problem, as the hero: try it before anything else.
function TryOne() {
  return (
    <div className="pe-try">
      <div className="pe-try-head"><span>Try one now</span><span>About 6 min</span></div>
      <ProblemPanel p={PE_PROBLEMS[0]} compact />
    </div>
  );
}

// The other two, in the exam's other two question formats.
function ProblemViewer() {
  const rest = PE_PROBLEMS.slice(1);
  const [on, setOn] = React.useState(0);
  return (
    <div className="pv">
      <div className="pv-tabs pv-tabs-2" role="tablist" aria-label="Sample problems">
        {rest.map((p, i) => (
          <button key={p.id} id={`pv-tab-${p.id}`} type="button" role="tab" aria-selected={on === i} aria-controls={`pv-${p.id}`}
            className={`pv-tab${on === i ? ' on' : ''}`} onClick={() => setOn(i)}>
            <span className="pv-tab-topic">{p.topic}</span>
            <span className="pv-tab-name">{p.name}</span>
            <span className="pv-tab-fmt">{p.format}</span>
          </button>
        ))}
      </div>
      <div className="pv-head"><span>Question {on + 2} of {PE_PROBLEMS.length}</span><span>About 6 min</span></div>
      {rest.map((p, i) => <ProblemPanel key={p.id} p={p} hidden={on !== i} />)}
    </div>
  );
}

// The PE exams as a stack of books, the raccoon on top of "Yours?", the same
// picture as the pass card. Hand-placed, top book first. Water Resources sits
// in the middle on purpose: nothing here hints at which exam comes first.
const SHELF = [
  ['ch', 'PE Civil: Structural', 88, 14, -0.3],
  ['sa', 'PE Civil: Construction', 95, 2, 0.4],
  ['ch', 'PE Environmental', 86, 18, -0.6],
  ['cr', 'PE Civil: Water Resources', 92, 6, 0.7],
  ['sa', 'SE Structural', 84, 24, -0.4],
  ['ch', 'PE Civil: Geotechnical', 94, 0, 0.6],
  ['cr', 'PE Civil: Transportation', 90, 10, -0.8],
].reverse();

function BookStack({ className = '' }) {
  return (
    <div className={`pe-stack ${className}`} aria-hidden="true">
      <div className="pe-book em" style={{ '--w': 80, '--x': 30, '--r': -1.1 }}>
        <img className="pe-peek" src={peekUrl} alt="" />Yours?
      </div>
      {SHELF.map(([c, t, w, x, r]) => (
        <div key={t} className={`pe-book ${c}`} style={{ '--w': w, '--x': x, '--r': r }}>{t}</div>
      ))}
    </div>
  );
}

const ASK = 'Tell us which PE is yours when you join. The answers decide what we build first.';

export function PeWaitlist() {
  const url = `${SITE}${PE_PATH}`;
  const title = pageTitle('PE Exam Prep and Sample PE Civil Problems');
  const description = 'PE exam prep for engineers with a full-time job, in the works. Try three PE Civil problems in the real exam formats with worked solutions, and join the list for when it opens.';
  useSeo({
    title,
    description,
    canonical: url,
    jsonLd: {
      '@context': 'https://schema.org',
      '@type': 'WebPage',
      name: 'PE exam prep',
      description,
      url,
      publisher: { '@type': 'Organization', name: 'FE for Raccoons', url: SITE },
      about: { '@type': 'Thing', name: 'Principles and Practice of Engineering (PE) exam' },
    },
  });

  return (
    <main className="pub eg pe">
      <header className="pe-hero">
        <div className="pe-hero-text">
          <h1>PE exam prep for engineers with a full&#8209;time job</h1>
          <p className="pub-lede">
            We are working on high quality, affordable prep material for the PE exam. Try a real-format problem,
            then join the list.
          </p>
          <WaitlistForm place="top" />
          <p className="eg-checked">One email when it opens, and a short study note each month. Unsubscribe in one tap.</p>
        </div>
        <TryOne />
      </header>

      {/* On a phone the stack comes right after the first problem. */}
      <section className="pe-yours">
        <BookStack />
        <p className="pe-ask">{ASK}</p>
      </section>

      <section className="eg-section">
        <h2>Two more, in the other exam formats</h2>
        <p className="eg-intro">
          The computer-based PE also asks you to type a number or pick every answer that applies. Each one comes with
          a worked solution and the reasons the wrong answers are tempting.
        </p>
        <ProblemViewer />
      </section>

      <section className="eg-section pe-build">
        <BookStack className="pe-stack-wide" />
        <div>
          <h2>What we are building</h2>
          <ul className="pe-build-list">
            {BUILDING.map(([h, p]) => <li key={h}><h3>{h}</h3><p>{p}</p></li>)}
          </ul>
          <p className="pe-ask pe-ask-wide">{ASK}</p>
        </div>
      </section>

      <section className="eg-section pe-founder">
        <h2>Why we are building it</h2>
        <p>
          I passed the FE Civil in 2025 and I am sitting the PE in March 2027, while working full time as a drainage
          engineer. Finding the hours is the hard part, so that is what we are building for. Everything here gets
          tested on my own study first.
        </p>
        <p className="pe-sign">Jerson Garcia, founder of FE for Raccoons</p>
      </section>

      <section className="pub-final-cta">
        <h2>Hear first when it is ready</h2>
        <p>
          Join the list and tell us which PE you are taking. Our <Link to="/">FE Civil practice</Link> stays completely free.
        </p>
        <WaitlistForm place="bottom" dark />
      </section>
    </main>
  );
}
