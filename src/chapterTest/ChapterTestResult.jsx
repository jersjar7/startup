import React from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { ArrowLeft, CheckCircle, XCircle, MinusCircle, BookOpen } from '@phosphor-icons/react';
import katex from 'katex';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import { MathText } from '../components/MathText';
import { CHAPTERS } from '../data/chapters';
import { DIAGRAM_REGISTRY } from '../components/diagrams';
import { AppArrow } from '../components/brand/AppArrow';
import { LoadingState } from '../components/LoadingState';
import { formatDuration } from './format';
import '../diagnostic/diagnostic.css';
import '../exam/exam.css';
import './chapterTest.css';

// The score, where it came from (by topic), and every question with its
// solution. Only reachable once the test is handed in; the server refuses the
// review while a test is still open.

function MathBlock({ tex }) {
  const html = React.useMemo(() => {
    try {
      return katex.renderToString(tex, { displayMode: true, throwOnError: false, strict: false });
    } catch {
      return tex;
    }
  }, [tex]);
  return <div className="lp-step-math" dangerouslySetInnerHTML={{ __html: html }} />;
}

function ProblemDiagram({ diagram }) {
  if (!diagram) return null;
  const Comp = DIAGRAM_REGISTRY[diagram.component];
  if (!Comp) return null;
  return <div className="ex-diagram"><Comp {...(diagram.props || {})} /></div>;
}

// What the score says, in a sentence. 70% is the usual rule of thumb for a
// pass on the FE; NCEES does not publish a cut score, so the copy never
// promises one.
function verdict(percent) {
  if (percent >= 80) return 'Exam-ready on this chapter. Take it again later to keep it warm.';
  if (percent >= 70) return 'Around passing pace. The topics below show where the rest of the points are.';
  if (percent >= 50) return 'Getting there. Work the topics you missed, then take it again.';
  return 'A starting point. Go back to the lessons for the topics below, then try again.';
}

function ReviewCard({ q, n }) {
  const skipped = !q.chosen;
  const status = skipped ? 'skipped' : q.correct ? 'correct' : 'incorrect';
  return (
    <article className="drev-card ct-review-card" id={`q${n}`}>
      <div className="drev-q-header">
        <div className={`drev-q-status drev-q-status--${status}`}>
          {skipped ? <MinusCircle size={16} weight="fill" /> : q.correct ? <CheckCircle size={16} weight="fill" /> : <XCircle size={16} weight="fill" />}
        </div>
        <span className="drev-q-label">Question {n} · {skipped ? 'No answer' : q.correct ? 'Correct' : 'Incorrect'}</span>
        <span className="ct-review-topic">{q.topic}</span>
      </div>

      <div className="drev-statement"><MathText text={q.statement} /></div>
      <ProblemDiagram diagram={q.diagram} />

      <ol className="ct-choices">
        {q.choices.map((c, ci) => {
          const isKey = c.id === q.correctAnswerId;
          const isMine = c.id === q.chosen;
          const cls = isKey ? 'ct-choice--key' : isMine ? 'ct-choice--mine' : '';
          return (
            <li key={c.id} className={`ct-choice ${cls}`}>
              <span className="ct-choice-letter">{String.fromCharCode(65 + ci)}</span>
              <div className="ct-choice-body">
                <div className="ct-choice-text">
                  <MathText text={c.text} />
                  {isKey && <span className="ct-choice-tag ct-choice-tag--key">Correct answer</span>}
                  {isMine && !isKey && <span className="ct-choice-tag ct-choice-tag--mine">Your answer</span>}
                  {isMine && isKey && <span className="ct-choice-tag ct-choice-tag--key">Your answer</span>}
                </div>
                {q.choiceNotes[ci] && <p className="ct-choice-note"><MathText text={q.choiceNotes[ci]} /></p>}
              </div>
            </li>
          );
        })}
      </ol>

      {q.eli5 && (
        <div className="drev-eli5">
          <div className="drev-eli5-title">The idea</div>
          <p><MathText text={q.eli5} /></p>
        </div>
      )}

      {q.steps.length > 0 && (
        <div className="drev-steps">
          <div className="drev-steps-title">Solution</div>
          <div className="lp-steps">
            {q.steps.map((step, si) => (
              <div key={si} className="lp-step-item">
                <span className="lp-step-num">{String(si + 1).padStart(2, '0')}</span>
                <div className="lp-step-content">
                  <p><MathText text={step.text} /></p>
                  {step.latex && <MathBlock tex={step.latex} />}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {q.handbookPage && (
        <p className="ct-handbook">
          <BookOpen size={16} />
          <span>FE Reference Handbook, {q.handbookPage}{q.handbookFormula ? `: ${q.handbookFormula}` : ''}</span>
        </p>
      )}
    </article>
  );
}

export function ChapterTestResult({ userName }) {
  const { attemptId } = useParams();
  const navigate = useNavigate();
  const [result, setResult] = React.useState(null);
  const [failed, setFailed] = React.useState(false);
  const [missedOnly, setMissedOnly] = React.useState(false);
  const [nextIsNew, setNextIsNew] = React.useState(false);
  const chapter = result && CHAPTERS.find((c) => c.id === result.chapterId);
  useDocumentTitle(chapter ? `${chapter.name} test result` : 'Chapter test result');

  React.useEffect(() => {
    if (!userName) { navigate('/login'); return; }
    fetch(`/api/chapter-tests/attempts/${attemptId}`)
      .then((r) => (r.ok ? r.json() : Promise.reject(r.status)))
      .then((d) => {
        setResult(d);
        // Only promise new questions if the next try really has them.
        return fetch(`/api/chapter-tests/${d.chapterId}`).then((r) => (r.ok ? r.json() : null));
      })
      .then((info) => { if (info) setNextIsNew(!!info.nextIsNew && !info.openId); })
      .catch(() => setFailed(true));
  }, [attemptId, userName, navigate]);

  if (failed) {
    return (
      <main className="ct-main">
        <div className="dx-error" role="alert">This result could not be loaded.</div>
        <button className="btn-secondary" onClick={() => navigate('/dashboard')}>Back to dashboard</button>
      </main>
    );
  }
  if (!result || !chapter) return <LoadingState />;

  const missed = result.questions.filter((q) => !q.correct).length;
  const shown = result.questions
    .map((q, i) => ({ q, n: i + 1 }))
    .filter(({ q }) => !missedOnly || !q.correct);

  return (
    <main className="ct-main ct-main--result">
      <button className="ct-back" onClick={() => navigate(`/study/${chapter.id}`)}>
        <ArrowLeft size={16} weight="bold" /> {chapter.name}
      </button>

      <section className="ct-score">
        <div className="ct-score-head">
          <p className="ct-overline">Chapter {chapter.num} test</p>
          <h1 className="ct-score-title">{chapter.name}</h1>
          <p className="ct-score-verdict">{verdict(result.percent)}</p>
        </div>
        <div className="ct-score-number">
          <span className="ct-score-percent">{result.percent}<small>%</small></span>
          <span className="ct-score-meta">
            {result.correct} of {result.total} correct · {formatDuration(result.seconds)}
          </span>
          {result.late && <span className="ct-score-meta">Handed in after the clock ran out</span>}
        </div>
      </section>

      <section className="ct-topics" aria-labelledby="ct-topics-title">
        <h2 className="ct-section-title" id="ct-topics-title">By topic</h2>
        <ul className="ct-topic-list">
          {result.topics.map((t) => (
            <li key={t.topic} className="ct-topic">
              <span className="ct-topic-name">{t.topic}</span>
              <span className="ct-topic-bar" aria-hidden="true">
                <i style={{ width: `${(t.correct / t.total) * 100}%` }} className={t.correct === t.total ? 'is-full' : ''} />
              </span>
              <span className="ct-topic-count">{t.correct}/{t.total}</span>
            </li>
          ))}
        </ul>
      </section>

      <div className="ct-actions">
        <button className="ct-start" onClick={() => navigate(`/test/${chapter.id}`)}>
          {nextIsNew ? 'Take it again with new questions' : 'Take it again'}
          <AppArrow />
        </button>
        <button className="ct-link" onClick={() => navigate(`/study/${chapter.id}`)}>
          Back to {chapter.name}
        </button>
      </div>

      <aside className="ct-sim">
        <p>
          A chapter test is one slice of the FE. The exam simulation is all 15 chapters,
          110 questions, under the real clock.
        </p>
        <button className="ct-link" onClick={() => navigate('/exam')}>See the exam simulation</button>
      </aside>

      <section className="ct-review" aria-labelledby="ct-review-title">
        <div className="ct-review-head">
          <h2 className="ct-section-title" id="ct-review-title">Every question, solved</h2>
          {missed > 0 && (
            <div className="ct-filter" role="group" aria-label="Show">
              <button className={!missedOnly ? 'is-on' : ''} onClick={() => setMissedOnly(false)}>All {result.total}</button>
              <button className={missedOnly ? 'is-on' : ''} onClick={() => setMissedOnly(true)}>Missed {missed}</button>
            </div>
          )}
        </div>
        {shown.map(({ q, n }) => <ReviewCard key={q.id} q={q} n={n} />)}
      </section>
    </main>
  );
}
