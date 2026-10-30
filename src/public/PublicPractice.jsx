import React from 'react';
import { Link, useParams } from 'react-router-dom';
import { CheckCircle, XCircle } from '@phosphor-icons/react';
import { MathText } from '../components/MathText';
import { NotFound } from '../components/NotFound';
import { useSeo } from '../seo/useSeo';
import { getTopic } from './content';
import { getChapterPracticeProblems } from '../data/chapter-practice/index';
import { PROBLEM_COUNT_LABEL } from '../data/contentStats';
import { DIAGRAM_REGISTRY } from '../components/diagrams';
import { AppArrow } from '../components/brand/AppArrow';
import './public.css';
import { pageTitle, titleName } from '../seo/pageTitle';

const SITE = 'https://fe4raccoons.com';

// Plain text for structured data: drop the $ delimiters and the commonest
// LaTeX commands so a search engine reads "150 N at 53.1 degrees", not markup.
export function plainText(tex) {
  return String(tex || '')
    .replace(/\$\$?/g, '')
    .replace(/\\(?:text|mathrm|textbf)\{([^}]*)\}/g, '$1')
    .replace(/\\degree|\^\\circ|\^\{\\circ\}/g, ' degrees')
    .replace(/\\cdot/g, '·')
    .replace(/\\times/g, ' x ')
    .replace(/\\[,;!]/g, ' ')
    .replace(/\\left|\\right/g, '')
    .replace(/\\([a-zA-Z]+)/g, '$1')
    .replace(/[{}]/g, '')
    .replace(/\s+/g, ' ')
    .trim();
}

function Diagram({ diagram }) {
  if (!diagram) return null;
  const Comp = DIAGRAM_REGISTRY[diagram.component];
  if (!Comp) return null;
  return <div className="pub-practice-figure"><Comp {...(diagram.props || {})} /></div>;
}

// One problem: pick an answer to check it, and the worked solution opens.
// The solution sits in a <details> so it is in the page for readers without
// JavaScript and for search engines, and opens itself once an answer is picked.
function PracticeProblem({ p, n, onAnswer }) {
  const [picked, setPicked] = React.useState(null);
  const answered = picked !== null;
  const right = picked === p.correctAnswerId;
  const pick = (id) => {
    if (answered) return;
    setPicked(id);
    onAnswer(id === p.correctAnswerId);
  };
  return (
    <article className="pub-problem pub-practice" id={`q${n}`}>
      <p className="pub-problem-q"><span className="pub-problem-tag">Q{n}</span><MathText text={p.statement} /></p>
      <Diagram diagram={p.diagram} />
      <ol className="pub-choices" type="A">
        {p.choices.map((c, i) => {
          const state = !answered ? '' : c.id === p.correctAnswerId ? ' is-right' : c.id === picked ? ' is-wrong' : ' is-dim';
          return (
            <li key={c.id}>
              <button type="button" className={`pub-choice${state}`} onClick={() => pick(c.id)} disabled={answered} aria-pressed={c.id === picked}>
                <span className="pub-choice-letter">{String.fromCharCode(65 + i)}</span>
                <span className="pub-choice-text"><MathText text={c.text} /></span>
              </button>
            </li>
          );
        })}
      </ol>
      {answered && (
        <p className={`pub-verdict ${right ? 'is-right' : 'is-wrong'}`} role="status">
          {right ? <CheckCircle size={18} weight="bold" /> : <XCircle size={18} weight="bold" />}
          {right ? 'Correct.' : 'Not quite. The worked solution is below.'}
        </p>
      )}
      <details className="pub-eli5" open={answered}>
        <summary>Worked solution</summary>
        {p.eli5 && <p><MathText text={p.eli5} /></p>}
        {p.steps && p.steps.length > 0 && (
          <ol className="pub-steps">
            {p.steps.map((s, i) => (
              <li key={i}>
                <MathText text={s.text} />
                {s.latex && <div className="pub-step-math"><MathText text={`$${s.latex}$`} /></div>}
              </li>
            ))}
          </ol>
        )}
        {p.handbookPage && <p className="pub-practice-ref">FE Reference Handbook: {p.handbookPage}</p>}
      </details>
    </article>
  );
}

export function PublicPractice() {
  const { topicId } = useParams();
  const topic = getTopic(topicId);
  const problems = topic ? getChapterPracticeProblems(topic.id) : [];
  const [tally, setTally] = React.useState({ done: 0, right: 0 });

  const url = topic ? `${SITE}/fe-civil/${topic.id}/practice-problems` : SITE;
  const title = topic ? pageTitle(`FE Civil ${titleName(topic)} Practice Problems with Solutions`) : '';
  const description = topic
    ? `${problems.length} free FE Civil ${topic.name} practice problems, exam style, with step-by-step solutions and FE Reference Handbook pages. Check your answers right on the page, no account needed.`
    : '';
  const jsonLd = topic ? [
    // Google's practice-problem format: a Quiz of multiple-choice questions.
    {
      '@context': 'https://schema.org',
      '@type': 'Quiz',
      name: `FE Civil ${topic.name} practice problems`,
      about: { '@type': 'Thing', name: `Fundamentals of Engineering (FE) Civil: ${topic.name}` },
      educationalAlignment: [{
        '@type': 'AlignmentObject',
        alignmentType: 'educationalSubject',
        targetName: `FE Civil ${topic.name}`,
      }],
      isAccessibleForFree: true,
      provider: { '@type': 'Organization', name: 'FE for Raccoons', url: SITE },
      hasPart: problems.map((p) => {
        const right = p.choices.find((c) => c.id === p.correctAnswerId);
        return {
          '@type': 'Question',
          eduQuestionType: 'Multiple choice',
          learningResourceType: 'Practice problem',
          text: plainText(p.statement),
          suggestedAnswer: p.choices.filter((c) => c.id !== p.correctAnswerId).map((c) => ({ '@type': 'Answer', text: plainText(c.text) })),
          acceptedAnswer: { '@type': 'Answer', text: plainText(right?.text), answerExplanation: { '@type': 'Comment', text: plainText(p.eli5) } },
        };
      }),
    },
    {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      itemListElement: [
        { '@type': 'ListItem', position: 1, name: 'FE Civil Exam Guide', item: `${SITE}/fe-civil-exam-guide` },
        { '@type': 'ListItem', position: 2, name: topic.name, item: `${SITE}/fe-civil/${topic.id}` },
        { '@type': 'ListItem', position: 3, name: 'Practice problems', item: url },
      ],
    },
  ] : [];

  useSeo({ title, description, canonical: url, jsonLd });

  if (!topic || problems.length === 0) return <NotFound />;

  const onAnswer = (right) => setTally((t) => ({ done: t.done + 1, right: t.right + (right ? 1 : 0) }));

  return (
    <main className={`pub pub-accent-${topic.accent}`}>
      <nav className="pub-breadcrumb" aria-label="Breadcrumb">
        <Link to="/fe-civil-exam-guide">FE Civil Exam Guide</Link>
        <span aria-hidden="true">/</span>
        <Link to={`/fe-civil/${topic.id}`}>{topic.name}</Link>
        <span aria-hidden="true">/</span>
        <span>Practice problems</span>
      </nav>

      <header className="pub-hero">
        <div className="pub-hero-text">
          <span className="pub-label">FE Civil · Chapter {topic.num} · {topic.questionRange} questions on the exam</span>
          <h1>FE Civil {topic.name} practice problems</h1>
          <p className="pub-lede">
            {problems.length} exam-style problems with worked solutions and the FE Reference Handbook page for each.
            Pick an answer to check it. No account needed.
          </p>
        </div>
      </header>

      <section className="pub-section">
        <div className="pub-problems">
          {problems.map((p, i) => <PracticeProblem key={p.id} p={p} n={i + 1} onAnswer={onAnswer} />)}
        </div>
        <p className="pub-tally" aria-live="polite">
          {tally.done === 0
            ? `${problems.length} problems. Your score shows here as you go.`
            : `${tally.right} of ${tally.done} right so far, ${problems.length - tally.done} to go.`}
        </p>
      </section>

      <section className="pub-section">
        <p className="pub-section-lede">
          New to {topic.name}? Start with the <Link to={`/fe-civil/${topic.id}`}>FE Civil {topic.name} study guide</Link>:
          what NCEES tests, the key formulas, and the mistakes that cost points.
        </p>
      </section>

      <section className="pub-final-cta">
        <h2>Keep going</h2>
        <p>These are {problems.length} of {PROBLEM_COUNT_LABEL} problems across all 15 FE Civil chapters, with lessons and progress that remembers what you missed. Completely free.</p>
        <Link className="pub-btn pub-btn-primary" to="/login">Create a free account <AppArrow /></Link>
      </section>
    </main>
  );
}
