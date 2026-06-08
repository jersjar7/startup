import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import {
  ArrowRight,
  ArrowLeft,
  CheckCircle,
  XCircle,
  Compass,
  Lightning,
  Flag,
  SkipForward,
} from '@phosphor-icons/react';
import { MathText } from '../components/MathText';
import { CHAPTERS } from '../data/chapters';
import { getExamBankForChapter } from '../data/exam-bank/index';
import { DIAGRAM_REGISTRY } from '../components/diagrams';
import { ChapterMap } from './ChapterMap';
import './quickstart.css';

const DEFAULT_SEGMENT = 5;
const DIFFICULTY_RANK = { easy: 0, medium: 1, hard: 2 };

function ProblemDiagram({ diagram }) {
  if (!diagram) return null;
  const Comp = DIAGRAM_REGISTRY[diagram.component];
  if (!Comp) return null;
  return <div className="qs-diagram"><Comp {...(diagram.props || {})} /></div>;
}

function fisherYatesShuffle(arr) {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

// Confidence-first: easiest question first, then ramp. Choices shuffled for
// variety. `count` is the chapter's tiered question budget (5/4/3), from server.
function buildSegment(chapterId, count = DEFAULT_SEGMENT) {
  const pool = getExamBankForChapter(chapterId) || [];
  const ranked = [...pool].sort(
    (a, b) => (DIFFICULTY_RANK[a.difficulty] ?? 1) - (DIFFICULTY_RANK[b.difficulty] ?? 1)
  );
  return ranked.slice(0, count).map((q) => ({
    ...q,
    choices: fisherYatesShuffle(q.choices),
  }));
}

const chapterName = (id) => (CHAPTERS.find((c) => c.id === id)?.name || id);

export function QuickStart({ userName }) {
  const navigate = useNavigate();
  useDocumentTitle('Quick Start');

  const [phase, setPhase] = React.useState('LOADING'); // LOADING | INTRO | SEGMENT | RESULT | DONE | ERROR
  const [state, setState] = React.useState(null);       // server quick-start state
  const [error, setError] = React.useState('');

  // Active segment
  const [chapterId, setChapterId] = React.useState(null);
  const [questions, setQuestions] = React.useState([]);
  const [qIndex, setQIndex] = React.useState(0);
  const [answers, setAnswers] = React.useState({});      // { index: choiceId | null }
  const [revealed, setRevealed] = React.useState({});    // { index: true }
  const [submitting, setSubmitting] = React.useState(false);
  const [segResult, setSegResult] = React.useState(null);

  React.useEffect(() => {
    if (!userName) { navigate('/'); return; }
    fetch('/api/quickstart/state')
      .then((res) => { if (!res.ok) throw new Error(); return res.json(); })
      .then((s) => {
        setState(s);
        setPhase(s.done ? 'DONE' : 'INTRO');
      })
      .catch(() => { setError('Could not load your progress. Please try again.'); setPhase('ERROR'); });
  }, [userName, navigate]);

  function startSegment(ch, count) {
    const seg = buildSegment(ch, count || DEFAULT_SEGMENT);
    if (seg.length === 0) {
      setError('No questions available for this chapter yet.');
      setPhase('ERROR');
      return;
    }
    setChapterId(ch);
    setQuestions(seg);
    setQIndex(0);
    setAnswers({});
    setRevealed({});
    setSegResult(null);
    setPhase('SEGMENT');
    window.scrollTo(0, 0);
  }

  function selectChoice(choiceId) {
    if (revealed[qIndex]) return; // immediate-feedback: locked once answered
    setAnswers((prev) => ({ ...prev, [qIndex]: choiceId }));
    setRevealed((prev) => ({ ...prev, [qIndex]: true }));
  }

  function skipQuestion() {
    if (revealed[qIndex]) return;
    setAnswers((prev) => ({ ...prev, [qIndex]: null }));
    setRevealed((prev) => ({ ...prev, [qIndex]: true }));
  }

  function advance() {
    if (qIndex < questions.length - 1) {
      setQIndex((i) => i + 1);
      window.scrollTo(0, 0);
    } else {
      submitSegment();
    }
  }

  function submitSegment() {
    setSubmitting(true);
    const payload = questions.map((q, i) => ({
      questionId: q.id,
      selectedAnswerId: answers[i] || null,
      correctAnswerId: q.correctAnswerId,
      isCorrect: answers[i] === q.correctAnswerId,
    }));
    fetch('/api/quickstart/submit-segment', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ chapterId, answers: payload }),
    })
      .then((res) => { if (!res.ok) throw new Error(); return res.json(); })
      .then((result) => {
        setSegResult(result);
        setState(result); // result spreads the full state shape
        setPhase('RESULT');
        setSubmitting(false);
        window.scrollTo(0, 0);
      })
      .catch(() => { setError('Could not save your answers. Please try again.'); setSubmitting(false); });
  }

  // ─── LOADING / ERROR ───
  if (phase === 'LOADING') {
    return <main className="qs-main"><div className="qs-loading">Loading…</div></main>;
  }
  if (phase === 'ERROR') {
    return (
      <main className="qs-main">
        <div className="qs-card qs-narrow">
          <p className="qs-error" role="alert">{error}</p>
          <button className="btn-secondary" onClick={() => navigate('/dashboard')}>
            <ArrowLeft size={16} weight="bold" /> Back to Dashboard
          </button>
        </div>
      </main>
    );
  }

  // ─── INTRO ───
  if (phase === 'INTRO') {
    const resuming = state.sampledCount > 0;
    const nextName = chapterName(state.nextChapterId);
    const qCount = state.nextChapterQuestions || DEFAULT_SEGMENT;
    return (
      <main className="qs-main">
        <div className="qs-card qs-narrow qs-intro">
          <span className="qs-overline"><Compass size={14} weight="bold" /> Quick Start</span>
          <h1 className="qs-title">
            {resuming ? 'Pick up where you left off' : 'See where you stand'}
          </h1>
          {resuming ? (
            <p className="qs-lead">
              You've mapped <strong>{state.sampledCount} of {state.totalChapters}</strong> chapters.
              Next up: <strong>{nextName}</strong> — answer {qCount} more, about 5 minutes.
            </p>
          ) : (
            <p className="qs-lead">
              Answer {qCount} questions and we'll start mapping where you stand — about
              5 minutes. You can stop anytime and study any chapter right away.
            </p>
          )}
          <ul className="qs-facts">
            <li><strong>{qCount} questions</strong> from one chapter, with instant feedback</li>
            <li><strong>~5 minutes</strong> — measured in questions, not a timer</li>
            <li><strong>Always free</strong> — this builds your study plan</li>
          </ul>
          <div className="qs-actions">
            <button className="btn-primary" onClick={() => startSegment(state.nextChapterId, qCount)}>
              {resuming ? <>Continue with {nextName}</> : <>Start — first up: {nextName}</>}
              <ArrowRight size={16} weight="bold" />
            </button>
            <button className="qs-text-btn" onClick={() => navigate('/dashboard')}>
              {resuming ? 'Stop for now' : 'Maybe later'}
            </button>
          </div>
        </div>
      </main>
    );
  }

  // ─── DONE (all 15 mapped) ───
  if (phase === 'DONE') {
    return (
      <main className="qs-main">
        <div className="qs-card qs-wide">
          <span className="qs-overline"><Flag size={14} weight="bold" /> Complete</span>
          <h1 className="qs-title">You've mapped all 15 chapters</h1>
          <p className="qs-lead">
            Here's your full readiness map. These are early reads — your mastery
            grows as you study and review over time.
          </p>
          <ChapterMapWrap state={state} />
          <div className="qs-actions">
            <button className="btn-primary" onClick={() => navigate('/dashboard')}>
              Go to your dashboard <ArrowRight size={16} weight="bold" />
            </button>
          </div>
        </div>
      </main>
    );
  }

  // ─── SEGMENT (one question at a time) ───
  if (phase === 'SEGMENT') {
    const q = questions[qIndex];
    if (!q) return null;
    const isRevealed = !!revealed[qIndex];
    const selected = answers[qIndex] || null;
    const isLast = qIndex === questions.length - 1;
    const why = q.eli5 || q.hint || '';

    return (
      <main className="qs-main">
        <div className="qs-card qs-wide qs-segment">
          <div className="qs-seg-head">
            <span className="qs-seg-chapter">{chapterName(chapterId)}</span>
            <span className="qs-seg-count">Question {qIndex + 1} of {questions.length}</span>
          </div>
          <div className="qs-seg-progress">
            <div className="qs-seg-progress-fill" style={{ width: `${((qIndex) / questions.length) * 100}%` }} />
          </div>

          <div className="qs-statement"><MathText text={q.statement} /></div>
          <ProblemDiagram diagram={q.diagram} />

          <div className="qs-choices">
            {q.choices.map((c, ci) => {
              const label = String.fromCharCode(65 + ci);
              const isSel = c.id === selected;
              const isCorrect = c.id === q.correctAnswerId;
              let cls = 'qs-choice';
              if (isRevealed) {
                if (isCorrect) cls += ' qs-choice--correct';
                else if (isSel) cls += ' qs-choice--wrong';
                else cls += ' qs-choice--muted';
              } else if (isSel) {
                cls += ' qs-choice--selected';
              }
              return (
                <button key={c.id} className={cls} onClick={() => selectChoice(c.id)} disabled={isRevealed}>
                  <span className="qs-choice-label">{label}</span>
                  <span className="qs-choice-text"><MathText text={c.text} /></span>
                  {isRevealed && isCorrect && <CheckCircle size={18} weight="fill" className="qs-choice-mark qs-choice-mark--ok" />}
                  {isRevealed && isSel && !isCorrect && <XCircle size={18} weight="fill" className="qs-choice-mark qs-choice-mark--no" />}
                </button>
              );
            })}
          </div>

          {!isRevealed && (
            <button className="qs-skip" onClick={skipQuestion}>
              <SkipForward size={15} weight="bold" /> Skip this one
            </button>
          )}

          {isRevealed && (
            <div className={`qs-feedback ${selected === q.correctAnswerId ? 'qs-feedback--ok' : 'qs-feedback--no'}`}>
              <span className="qs-feedback-tag">
                {selected === null ? 'Skipped' : selected === q.correctAnswerId ? 'Correct' : 'Not quite'}
              </span>
              {why && <div className="qs-feedback-why"><MathText text={why} /></div>}
            </div>
          )}

          {isRevealed && (
            <div className="qs-actions qs-actions--right">
              <button className="btn-primary" onClick={advance} disabled={submitting}>
                {isLast ? (submitting ? 'Saving…' : 'See your results') : 'Next question'}
                <ArrowRight size={16} weight="bold" />
              </button>
            </div>
          )}
        </div>
      </main>
    );
  }

  // ─── RESULT (segment finished) ───
  if (phase === 'RESULT' && segResult) {
    const done = segResult.done;
    const nextName = chapterName(segResult.nextChapterId);
    const fam = segResult.chapterFamiliarity ?? (segResult.familiarity[segResult.chapterId] || 0);
    return (
      <main className="qs-main">
        <div className="qs-card qs-wide">
          <span className="qs-overline"><CheckCircle size={14} weight="bold" /> Early read</span>
          <h1 className="qs-title">{chapterName(segResult.chapterId)}</h1>
          <p className="qs-result-score">
            You got <strong>{segResult.correct} of {segResult.total}</strong>. Early read: <strong>{fam}% familiar</strong>.
          </p>
          <p className="qs-honest">
            This is a starting point, not a grade — getting these right means you're
            <em> familiar</em>, not yet exam-ready. Mastery grows as you study and review.
          </p>

          <div className="qs-reward">
            <span className="qs-reward-xp"><Lightning size={15} weight="fill" /> +{segResult.xpEarned.total} XP</span>
            {segResult.streak?.current > 0 && (
              <span className="qs-reward-streak">{segResult.streak.current}-day streak</span>
            )}
          </div>

          <ChapterMapWrap state={segResult} currentChapterId={segResult.chapterId} />

          {done ? (
            <>
              <p className="qs-lead" style={{ marginTop: '1rem' }}>That's all 15 chapters mapped. Nice work.</p>
              <div className="qs-actions">
                <button className="btn-primary" onClick={() => navigate('/dashboard')}>
                  Go to your dashboard <ArrowRight size={16} weight="bold" />
                </button>
              </div>
            </>
          ) : (
            <>
              <p className="qs-checkpoint-help">
                The more chapters you answer, the more complete your plan. You can stop anytime —
                every chapter is open to study right now.
              </p>
              <div className="qs-actions">
                <button className="btn-primary" onClick={() => startSegment(segResult.nextChapterId, segResult.nextChapterQuestions)}>
                  Keep going — next: {nextName} <ArrowRight size={16} weight="bold" />
                </button>
                <button className="qs-text-btn" onClick={() => navigate('/dashboard')}>
                  Stop &amp; start studying
                </button>
              </div>
            </>
          )}
        </div>
      </main>
    );
  }

  return null;
}

function ChapterMapWrap({ state, currentChapterId = null }) {
  return (
    <ChapterMap
      order={state.order}
      familiarity={state.familiarity}
      sampled={state.sampled}
      currentChapterId={currentChapterId}
      totalChapters={state.totalChapters}
    />
  );
}
