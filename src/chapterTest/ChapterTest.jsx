import React from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { Timer, ArrowLeft, ArrowRight, Flag, PaperPlaneTilt } from '@phosphor-icons/react';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import { MathText } from '../components/MathText';
import { CHAPTERS } from '../data/chapters';
import { DIAGRAM_REGISTRY } from '../components/diagrams';
import { AppArrow } from '../components/brand/AppArrow';
import { LoadingState } from '../components/LoadingState';
import { formatClock } from './format';
import '../diagnostic/diagnostic.css';
import '../exam/exam.css';
import './chapterTest.css';

// One chapter test: the rules, then the questions, then hand in. Answers are
// shown only on the result page (ChapterTestResult). The server holds the key
// and the deadline; the browser keeps a copy of the answers in case the
// network drops, and autosaves them.

function ProblemDiagram({ diagram }) {
  if (!diagram) return null;
  const Comp = DIAGRAM_REGISTRY[diagram.component];
  if (!Comp) return null;
  return <div className="ex-diagram"><Comp {...(diagram.props || {})} /></div>;
}

const localKey = (id) => `fe4r-ct-${id}`;
function readLocal(id) {
  try { return JSON.parse(localStorage.getItem(localKey(id)) || '{}'); } catch { return {}; }
}
function writeLocal(id, answers) {
  try { localStorage.setItem(localKey(id), JSON.stringify(answers)); } catch { /* ignore */ }
}

export function ChapterTest({ userName }) {
  const { chapterId } = useParams();
  const navigate = useNavigate();
  const chapter = CHAPTERS.find((c) => c.id === chapterId);
  useDocumentTitle(chapter ? `${chapter.name} chapter test` : 'Chapter test');

  const [phase, setPhase] = React.useState('LOADING'); // LOADING | INTRO | TEST | SUBMITTING | ERROR
  const [info, setInfo] = React.useState(null);
  const [test, setTest] = React.useState(null);
  const [answers, setAnswers] = React.useState({});
  const [flagged, setFlagged] = React.useState(() => new Set());
  const [index, setIndex] = React.useState(0);
  const [now, setNow] = React.useState(Date.now());
  const [confirming, setConfirming] = React.useState(false);
  const [error, setError] = React.useState('');
  const answersRef = React.useRef(answers);
  answersRef.current = answers;

  React.useEffect(() => {
    if (!userName) { navigate('/login'); return; }
    fetch(`/api/chapter-tests/${chapterId}`)
      .then((r) => (r.ok ? r.json() : Promise.reject(r.status)))
      .then((d) => { setInfo(d); setPhase('INTRO'); })
      .catch(() => { setError('This chapter test could not be loaded.'); setPhase('ERROR'); });
  }, [chapterId, userName, navigate]);

  const start = async () => {
    setPhase('LOADING');
    try {
      // The server picks the question set (CT.nextVersion); the student never sees it.
      const r = await fetch(`/api/chapter-tests/${chapterId}/${info.next}/start`, { method: 'POST' });
      if (!r.ok) throw new Error();
      const d = await r.json();
      setAnswers({ ...d.answers, ...readLocal(d.attemptId) });
      setTest(d);
      setIndex(0);
      setPhase('TEST');
    } catch {
      setError('The test could not be started. Check your connection and try again.');
      setPhase('ERROR');
    }
  };

  // Clock from the server's deadline, so a sleeping laptop cannot pause it.
  React.useEffect(() => {
    if (phase !== 'TEST') return undefined;
    const t = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(t);
  }, [phase]);

  // Autosave a moment after each change.
  React.useEffect(() => {
    if (!test || phase !== 'TEST') return undefined;
    writeLocal(test.attemptId, answers);
    const t = setTimeout(() => {
      fetch(`/api/chapter-tests/attempts/${test.attemptId}/answers`, {
        method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ answers }),
      }).catch(() => {});
    }, 800);
    return () => clearTimeout(t);
  }, [answers, test, phase]);

  const submit = React.useCallback(async () => {
    if (!test) return;
    setConfirming(false);
    setPhase('SUBMITTING');
    try {
      const r = await fetch(`/api/chapter-tests/attempts/${test.attemptId}/submit`, {
        method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ answers: answersRef.current }),
      });
      if (!r.ok) throw new Error();
      try { localStorage.removeItem(localKey(test.attemptId)); } catch { /* ignore */ }
      navigate(`/test/result/${test.attemptId}`, { replace: true });
    } catch {
      setError('Could not hand in the test. Your answers are saved on this device; try again.');
      setPhase('TEST');
    }
  }, [test, navigate]);

  const timeLeft = test ? Math.max(0, Math.round((test.deadline - now) / 1000)) : 0;
  React.useEffect(() => {
    if (phase === 'TEST' && test && timeLeft === 0) submit();
  }, [phase, test, timeLeft, submit]);

  if (!chapter) return <main className="ct-main"><div className="dx-error" role="alert">Chapter not found.</div></main>;
  if (phase === 'LOADING' || phase === 'SUBMITTING') return <LoadingState />;
  if (phase === 'ERROR') {
    return (
      <main className="ct-main">
        <div className="dx-error" role="alert">{error}</div>
        <button className="btn-secondary" onClick={() => navigate(`/study/${chapterId}`)}>Back to {chapter.name}</button>
      </main>
    );
  }

  if (phase === 'INTRO') {
    const minutes = Math.round(info.limitSeconds / 60);
    return (
      <main className="ct-main">
        <button className="ct-back" onClick={() => navigate(`/study/${chapterId}`)}>
          <ArrowLeft size={16} weight="bold" /> {chapter.name}
        </button>
        <section className="ct-intro">
          <p className="ct-overline">Chapter {chapter.num} test</p>
          <h1 className="ct-intro-title">{chapter.name}</h1>
          <dl className="ct-facts">
            <div><dt>Questions</dt><dd>{info.length}</dd></div>
            <div><dt>Time</dt><dd>{minutes} min</dd></div>
            <div><dt>Your best</dt><dd>{info.best ? `${info.best.percent}%` : 'Not taken'}</dd></div>
          </dl>
          <ul className="ct-rules">
            <li>As many questions as this chapter can have on the FE, at the exam's pace: 3 minutes a question.</li>
            <li>Keep the FE Reference Handbook and your calculator at hand, as on exam day.</li>
            <li>No answers until you hand it in. Then every question comes with its full solution.</li>
            <li>Your answers save as you go. When the clock runs out, the test is handed in for you.</li>
            <li>Take it again later and your next try has all new questions.</li>
          </ul>
          <button className="ct-start" onClick={start}>
            {info.openId ? 'Continue the test' : info.tries ? 'Take the test again' : 'Start the test'}
            <AppArrow />
          </button>
        </section>
      </main>
    );
  }

  const q = test.questions[index];
  const chosen = answers[q.id] || null;
  const answeredCount = test.questions.filter((x) => answers[x.id]).length;
  const unanswered = test.questions.length - answeredCount;
  const choose = (cid) => setAnswers((a) => ({ ...a, [q.id]: a[q.id] === cid ? null : cid }));
  const toggleFlag = () => setFlagged((s) => { const n = new Set(s); if (n.has(index)) n.delete(index); else n.add(index); return n; });

  return (
    <main className="ex-main ct-test">
      <div className="dx-topbar">
        <div className={`dx-timer ${timeLeft <= 300 ? 'dx-timer--low' : ''}`}>
          <Timer size={18} weight="bold" />
          <span>{formatClock(timeLeft)}</span>
        </div>
        <span className="dx-progress-text">{chapter.name} · {index + 1} of {test.questions.length}</span>
        <button className="dx-submit-btn" onClick={() => setConfirming(true)}>
          <PaperPlaneTilt size={16} weight="bold" />
          Hand in
        </button>
      </div>

      <div className="dx-body ex-body-wide">
        <div className="dx-question-area">
          <div className="dx-question-card">
            <div className="dx-question-header">
              <div>
                <span className="dx-question-num">Question {index + 1}</span>
                <span className="ex-chapter-tag">{q.topic}</span>
              </div>
              <button
                className={`dx-flag-btn ${flagged.has(index) ? 'dx-flag-btn--active' : ''}`}
                onClick={toggleFlag}
                title="Flag for review"
                aria-label="Flag for review"
              >
                <Flag size={16} weight={flagged.has(index) ? 'fill' : 'bold'} />
              </button>
            </div>
            <div className="dx-statement"><MathText text={q.statement} /></div>
            <ProblemDiagram diagram={q.diagram} />
            <div className="dx-choices">
              {q.choices.map((c, ci) => (
                <button
                  key={c.id}
                  className={`dx-choice ${c.id === chosen ? 'dx-choice--selected' : ''}`}
                  onClick={() => choose(c.id)}
                >
                  <span className="dx-choice-label">{String.fromCharCode(65 + ci)}</span>
                  <span className="dx-choice-text"><MathText text={c.text} /></span>
                </button>
              ))}
            </div>
            <div className="dx-nav-buttons">
              <button className="btn-secondary dx-nav-btn" onClick={() => setIndex(index - 1)} disabled={index === 0}>
                <ArrowLeft size={16} weight="bold" /> Previous
              </button>
              {index < test.questions.length - 1 ? (
                <button className="btn-secondary dx-nav-btn" onClick={() => setIndex(index + 1)}>
                  Next <ArrowRight size={16} weight="bold" />
                </button>
              ) : (
                <button className="btn-primary dx-nav-btn" onClick={() => setConfirming(true)}>
                  <PaperPlaneTilt size={16} weight="bold" /> Hand in
                </button>
              )}
            </div>
          </div>
          {error && <div className="dx-error" role="alert">{error}</div>}
        </div>

        <div className="dx-sidebar">
          <h3 className="dx-sidebar-title">Questions</h3>
          <div className="ex-grid">
            {test.questions.map((x, i) => {
              let cls = 'dx-grid-cell';
              if (i === index) cls += ' dx-grid-cell--current';
              else if (flagged.has(i)) cls += ' dx-grid-cell--flagged';
              else if (answers[x.id]) cls += ' dx-grid-cell--answered';
              return <button key={x.id} className={cls} onClick={() => setIndex(i)}>{i + 1}</button>;
            })}
          </div>
          <div className="dx-grid-legend">
            <span><span className="dx-legend-dot dx-legend-dot--answered" /> Answered</span>
            <span><span className="dx-legend-dot dx-legend-dot--flagged" /> Flagged</span>
            <span><span className="dx-legend-dot dx-legend-dot--unanswered" /> Unanswered</span>
          </div>
          <div className="dx-grid-stats">{answeredCount}/{test.questions.length} answered</div>
        </div>
      </div>

      {confirming && (
        <div className="ct-confirm-overlay" role="dialog" aria-modal="true" aria-labelledby="ct-confirm-title">
          <div className="ct-confirm">
            <h2 id="ct-confirm-title">Hand in the test?</h2>
            <p>
              {unanswered === 0
                ? 'Every question has an answer. You will see your score and every solution next.'
                : `${unanswered} ${unanswered === 1 ? 'question has' : 'questions have'} no answer and will count as wrong, as on the FE.`}
            </p>
            <div className="ct-confirm-actions">
              <button className="btn-secondary" onClick={() => setConfirming(false)}>Keep working</button>
              <button className="btn-primary" onClick={submit}>Hand in</button>
            </div>
          </div>
        </div>
      )}
    </main>
  );
}
