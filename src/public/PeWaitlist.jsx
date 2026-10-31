import React from 'react';
import { Link } from 'react-router-dom';
import { useSeo } from '../seo/useSeo';
import { pageTitle } from '../seo/pageTitle';
import { AppArrow } from '../components/brand/AppArrow';
import { PE_PROBLEMS, isRight } from './peProblems';
import './public.css';
import './examGuide.css';
import './peWaitlist.css';

const SITE = 'https://fe4raccoons.com';
export const PE_PATH = '/pe-civil-water-resources';

// The waitlist for PE Civil Water Resources prep (owner 2026-10-31). Nothing
// is built for the PE yet; the list decides whether it is. Facts below were
// checked against ncees.org on 2026-10-31 (research/pe on branch pe-research).
const EXAM_SHORT = [
  ['Questions', '80'],
  ['Exam time', '8 hours'],
  ['Fee', '$400 per attempt'],
  ['Where', 'Pearson VUE, year-round'],
  ['Pass rate', '71% first time'],
  ['Changes', 'April 2027: 7 supplied codes'],
];

export const WHEN_OPTIONS = [
  ['not-booked', 'Not booked yet'],
  ['before-2027-04', 'Before April 2027'],
  ['2027-04-to-12', 'April to December 2027'],
  ['2028-plus', '2028 or later'],
];

const BUILDING = [
  ['Worked problems for all 12 exam topics', 'Exam-depth problems like the three above. Every solution shows each step, points to the handbook section, and explains each wrong answer.'],
  ['Practice that fits a commute', 'Ten-minute sets on the FE for Raccoons phone app: which method, which equation, which trap. The long calculations wait for your desk.'],
  ['A full timed practice exam', '80 questions, the real clock, scored by topic.'],
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

function WaitlistForm({ place, askWhen = false, dark = false }) {
  const [email, setEmail] = React.useState('');
  const [when, setWhen] = React.useState('not-booked');
  const [website, setWebsite] = React.useState('');
  const [state, setState] = React.useState({ status: 'idle', msg: '' });

  async function submit(e) {
    e.preventDefault();
    setState({ status: 'sending', msg: '' });
    try {
      const r = await fetch('/api/waitlist', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, exam: 'pe-civil-wre', when: askWhen ? when : undefined, place, website, ...attribution() }),
      });
      const body = await r.json().catch(() => ({}));
      if (!r.ok) return setState({ status: 'error', msg: body.msg || 'That did not go through. Try again in a minute.' });
      setState({ status: 'done', msg: '' });
    } catch {
      setState({ status: 'error', msg: 'That did not go through. Check your connection and try again.' });
    }
  }

  if (state.status === 'done') {
    return (
      <p className="pe-done" role="status">
        <strong>You are on the list.</strong> We sent a confirmation to {email.trim()}.
      </p>
    );
  }

  return (
    <form className={`pe-form${dark ? ' pe-form-dark' : ''}`} onSubmit={submit}>
      <label className="pe-field">
        <span>Email</span>
        <input type="email" required autoComplete="email" placeholder="you@company.com" value={email} onChange={(e) => setEmail(e.target.value)} />
      </label>
      {askWhen && (
        <label className="pe-field">
          <span>When are you taking it?</span>
          <select value={when} onChange={(e) => setWhen(e.target.value)}>
            {WHEN_OPTIONS.map(([v, l]) => <option key={v} value={v}>{l}</option>)}
          </select>
        </label>
      )}
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

function ProblemPanel({ p, hidden }) {
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
    <div role="tabpanel" id={`pv-${p.id}`} aria-labelledby={`pv-tab-${p.id}`} hidden={hidden}>
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

function ProblemViewer() {
  const [on, setOn] = React.useState(0);
  return (
    <div className="pv">
      <div className="pv-tabs" role="tablist" aria-label="Sample problems">
        {PE_PROBLEMS.map((p, i) => (
          <button key={p.id} id={`pv-tab-${p.id}`} type="button" role="tab" aria-selected={on === i} aria-controls={`pv-${p.id}`}
            className={`pv-tab${on === i ? ' on' : ''}`} onClick={() => setOn(i)}>
            <span className="pv-tab-topic">{p.topic}</span>
            <span className="pv-tab-name">{p.name}</span>
            <span className="pv-tab-fmt">{p.format}</span>
          </button>
        ))}
      </div>
      <div className="pv-head"><span>Question {on + 1} of {PE_PROBLEMS.length}</span><span>About 6 min</span></div>
      {PE_PROBLEMS.map((p, i) => <ProblemPanel key={p.id} p={p} hidden={on !== i} />)}
    </div>
  );
}

export function PeWaitlist() {
  const url = `${SITE}${PE_PATH}`;
  const title = pageTitle('PE Civil Water Resources Prep and Practice Problems');
  const description = 'PE Civil Water Resources and Environmental prep for engineers with a full-time job. Try three exam-format problems with worked solutions, and join the list for when it opens.';
  useSeo({
    title,
    description,
    canonical: url,
    jsonLd: {
      '@context': 'https://schema.org',
      '@type': 'WebPage',
      name: 'PE Civil Water Resources prep',
      description,
      url,
      publisher: { '@type': 'Organization', name: 'FE for Raccoons', url: SITE },
      about: { '@type': 'Thing', name: 'PE Civil: Water Resources and Environmental exam' },
    },
  });

  return (
    <main className="pub eg pe">
      <header className="eg-hero">
        <div className="eg-hero-text">
          <span className="pub-label">PE Civil: Water Resources and Environmental</span>
          <h1>PE Water Resources prep for engineers with a full-time job</h1>
          <p className="pub-lede">
            Ten-minute practice on your phone, worked problems that point to the PE Civil Reference Handbook, and a
            full timed practice exam. We are building it now. Join the list and we will write when the first part opens.
          </p>
          <WaitlistForm place="top" askWhen />
          <p className="eg-checked">One email when it opens, and a short study note each month. Unsubscribe in one tap.</p>
        </div>
        <aside className="eg-short" aria-label="The exam in short">
          <h2>The exam in short</h2>
          <dl>
            {EXAM_SHORT.map(([k, v]) => <div key={k}><dt>{k}</dt><dd>{v}</dd></div>)}
          </dl>
        </aside>
      </header>

      <section className="eg-section">
        <h2>Three real-format PE problems</h2>
        <p className="eg-intro">The same depth and the same question types as the computer-based exam: multi-step, handbook lookups, and a figure to read. No account needed.</p>
        <ProblemViewer />
      </section>

      <section className="eg-section">
        <h2>What we are building</h2>
        <ul className="pe-build">
          {BUILDING.map(([h, p]) => <li key={h}><h3>{h}</h3><p>{p}</p></li>)}
        </ul>
      </section>

      <section className="eg-section pe-founder">
        <h2>Why we are building it</h2>
        <p>
          I passed the FE Civil in 2025 and I am sitting the Water Resources PE in March 2027, while working full time
          as a drainage engineer. Finding the hours is the hard part, so that is what we are building for. Everything
          here gets tested on my own study first.
        </p>
        <p className="pe-sign">Jerson Garcia, founder of FE for Raccoons</p>
      </section>

      <section className="pub-final-cta">
        <h2>Hear first when it opens</h2>
        <p>
          Join the list for PE Civil Water Resources. Our <Link to="/">FE Civil practice</Link> stays completely free.
        </p>
        <WaitlistForm place="bottom" dark />
      </section>
    </main>
  );
}
