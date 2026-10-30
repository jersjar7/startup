import React from 'react';
import { Link } from 'react-router-dom';
import { MagnifyingGlass, X } from '@phosphor-icons/react';
import { MathText } from '../components/MathText';
import { useSeo } from '../seo/useSeo';
import { allTopics } from './content';
import { allFormulas, matches } from './formulas';
import { AppArrow } from '../components/brand/AppArrow';
import { ChapterCoin } from '../components/brand/ChapterCoin';
import './public.css';
import './formulaFinder.css';

const SITE = 'https://fe4raccoons.com';
const PATH = '/fe-civil/formulas';
const EXAMPLES = ['manning', 'moment of inertia', 'effective stress', 'present worth', 'stopping sight distance'];

function readParams() {
  if (typeof window === 'undefined') return {};
  try {
    const p = new URLSearchParams(window.location.search);
    return { q: p.get('q') || '', ch: p.get('ch') || '' };
  } catch { return {}; }
}

// One formula: the handbook form on the left, what it means on the right.
function FormulaEntry({ f }) {
  return (
    <article className="ff-entry" id={f.id}>
      <div className="ff-entry-head">
        <h3><a href={`#${f.id}`}>{f.label}</a></h3>
        {f.page && <span className="ff-page">Handbook {f.page}</span>}
        {!f.inHandbook && <span className="ff-page ff-memorize">Not in the handbook: memorize it</span>}
      </div>
      <div className="ff-entry-body">
        <div className="ff-math"><MathText text={`$${f.latex}$`} /></div>
        <div className="ff-explain">
          {f.use && <p className="ff-use">{f.use}</p>}
          {f.symbols.length > 0 && (
            <dl className="ff-symbols">
              {f.symbols.map((s) => (
                <div key={s.tex}>
                  <dt><MathText text={`$${s.tex}$`} /></dt>
                  <dd>{s.means}{s.units && <span className="ff-units">{s.units}</span>}</dd>
                </div>
              ))}
            </dl>
          )}
          {f.trap && <p className="ff-trap"><strong>Watch out:</strong> {f.trap}</p>}
        </div>
      </div>
    </article>
  );
}

export function FormulaFinder() {
  const formulas = React.useMemo(() => allFormulas(), []);
  const topics = React.useMemo(() => allTopics(), []);
  const [query, setQuery] = React.useState('');
  const [chapter, setChapter] = React.useState('all');
  const inputRef = React.useRef(null);

  // ?q= makes a search shareable. Read after mount so the prerendered page
  // and the first render agree.
  // ?ch= opens on one chapter (the topic pages link that way).
  React.useEffect(() => {
    const { q, ch } = readParams();
    if (q) setQuery(q);
    if (ch && topics.some((t) => t.id === ch)) setChapter(ch);
  }, [topics]);
  React.useEffect(() => {
    if (typeof window === 'undefined') return;
    const p = new URLSearchParams();
    if (query) p.set('q', query);
    if (chapter !== 'all') p.set('ch', chapter);
    const qs = p.toString();
    window.history.replaceState(null, '', (qs ? `${PATH}?${qs}` : PATH) + window.location.hash);
  }, [query, chapter]);

  // "/" jumps to the search box, as on most reference sites.
  React.useEffect(() => {
    const onKey = (e) => {
      if (e.key !== '/' || e.target.closest?.('input, textarea')) return;
      e.preventDefault();
      inputRef.current?.focus();
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, []);

  const shown = formulas.filter((f) => (chapter === 'all' || f.chapterId === chapter) && matches(f, query));
  const groups = topics
    .map((t) => ({ topic: t, items: shown.filter((f) => f.chapterId === t.id) }))
    .filter((g) => g.items.length > 0);
  const countIn = (id) => formulas.filter((f) => f.chapterId === id && matches(f, query)).length;

  const title = 'FE Reference Handbook Formula Finder for FE Civil | FE for Raccoons';
  const description = `Search ${formulas.length} FE Civil formulas by name, topic or symbol. Each shows its FE Reference Handbook page or says it is not printed, what every symbol means with units, and when to use it. Free.`;
  const jsonLd = [
    {
      '@context': 'https://schema.org',
      '@type': 'DefinedTermSet',
      name: 'FE Civil formulas from the FE Reference Handbook',
      url: `${SITE}${PATH}`,
      hasDefinedTerm: formulas.map((f) => ({
        '@type': 'DefinedTerm',
        name: f.label,
        description: [f.use, f.page && `FE Reference Handbook ${f.page}.`].filter(Boolean).join(' '),
        url: `${SITE}${PATH}#${f.id}`,
        inDefinedTermSet: `${SITE}${PATH}`,
      })),
    },
    {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      itemListElement: [
        { '@type': 'ListItem', position: 1, name: 'FE Civil Exam Guide', item: `${SITE}/fe-civil-exam-guide` },
        { '@type': 'ListItem', position: 2, name: 'Formula finder', item: `${SITE}${PATH}` },
      ],
    },
  ];
  useSeo({ title, description, canonical: `${SITE}${PATH}`, jsonLd });

  return (
    <main className="pub ff">
      <nav className="pub-breadcrumb" aria-label="Breadcrumb">
        <Link to="/fe-civil-exam-guide">FE Civil Exam Guide</Link>
        <span aria-hidden="true">/</span>
        <span>Formula finder</span>
      </nav>

      <header className="ff-hero">
        <h1>FE Civil formula finder</h1>
        <p className="pub-lede">
          {formulas.length} FE Civil formulas, with the FE Reference Handbook page to find each one on exam day,
          what every symbol means, and when to reach for it.
        </p>
        <div className="ff-search" role="search">
          <MagnifyingGlass size={22} weight="bold" aria-hidden="true" />
          <label htmlFor="ff-q" className="ff-sr">Search formulas</label>
          <input
            id="ff-q"
            ref={inputRef}
            type="search"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search a formula, topic or symbol"
            autoComplete="off"
            spellCheck="false"
          />
          {query && (
            <button type="button" className="ff-clear" onClick={() => { setQuery(''); inputRef.current?.focus(); }} aria-label="Clear search">
              <X size={18} weight="bold" />
            </button>
          )}
        </div>
        <p className="ff-try">
          Try{' '}
          {EXAMPLES.map((e, i) => (
            <React.Fragment key={e}>
              {i > 0 && ', '}
              <button type="button" onClick={() => setQuery(e)}>{e}</button>
            </React.Fragment>
          ))}
        </p>
      </header>

      <div className="ff-body">
        <nav className="ff-rail" aria-label="Chapters">
          <button type="button" className={chapter === 'all' ? 'is-on' : undefined} aria-pressed={chapter === 'all'} onClick={() => setChapter('all')}>
            <span>All chapters</span><span className="ff-n">{formulas.filter((f) => matches(f, query)).length}</span>
          </button>
          {topics.map((t) => {
            const n = countIn(t.id);
            if (formulas.every((f) => f.chapterId !== t.id)) return null;
            return (
              <button key={t.id} type="button" className={chapter === t.id ? 'is-on' : undefined} aria-pressed={chapter === t.id} onClick={() => setChapter(t.id)} disabled={n === 0}>
                <span>{t.name}</span><span className="ff-n">{n}</span>
              </button>
            );
          })}
        </nav>

        <div className="ff-results" aria-live="polite">
          <p className="ff-count">
            {shown.length === formulas.length ? `All ${formulas.length} formulas` : `${shown.length} of ${formulas.length} formulas`}
            {query && <> matching <strong>{query}</strong></>}
          </p>
          {!query && chapter === 'all' && (
            <p className="ff-note">
              A few formulas are marked <strong>not in the handbook</strong>. NCEES leaves out basic formulas and definitions it expects
              you to know, so learn those by heart.
            </p>
          )}
          {groups.length === 0 && (
            <div className="ff-empty">
              <p>No formula matches "{query}". Try what a symbol means, like "hydraulic radius", or a topic, like "beams".</p>
              <button type="button" className="pub-btn pub-btn-ghost" onClick={() => { setQuery(''); setChapter('all'); }}>Show all formulas</button>
            </div>
          )}
          {groups.map(({ topic, items }) => (
            <section key={topic.id} className="ff-group" aria-labelledby={`ff-h-${topic.id}`}>
              <div className="ff-group-head">
                <ChapterCoin chapterId={topic.id} accent={topic.accent} />
                <h2 id={`ff-h-${topic.id}`}>{topic.name}</h2>
                <span className="ff-group-links">
                  <Link to={`/fe-civil/${topic.id}`}>Study guide</Link>
                  <Link to={`/fe-civil/${topic.id}/practice-problems`}>Practice problems</Link>
                </span>
              </div>
              {items.map((f) => <FormulaEntry key={f.id} f={f} />)}
            </section>
          ))}
        </div>
      </div>

      <section className="pub-final-cta">
        <h2>Knowing the formula is half of it</h2>
        <p>The other half is spotting which one a problem wants. Practice that on worked FE Civil problems across all 15 topics. Completely free.</p>
        <Link className="pub-btn pub-btn-primary" to="/login">Start practicing free <AppArrow /></Link>
      </section>
    </main>
  );
}
