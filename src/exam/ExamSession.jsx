import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import {
  Timer,
  ArrowLeft,
  ArrowRight,
  Flag,
  PaperPlaneTilt,
  WarningCircle,
  Coffee,
} from '@phosphor-icons/react';
import { MathText } from '../components/MathText';
import { CHAPTERS } from '../data/chapters';
import { selectExamQuestions, selectPreviewQuestions } from '../data/exam-bank/index';
import { DIAGRAM_REGISTRY } from '../components/diagrams';
import { priceForEmail } from '../data/pricing';
import '../diagnostic/diagnostic.css';
import './exam.css';

const TIME_LIMIT = 5 * 3600 + 20 * 60; // 5h 20min in seconds
const BREAK_AFTER_QUESTION = 55; // Halfway through — like the real FE exam
const BREAK_DURATION = 25 * 60; // 25 minutes in seconds

function shuffleArray(arr) {
  const copy = [...arr];
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
}

function shuffleQuestionChoices(questions) {
  return questions.map(q => ({
    ...q,
    choices: shuffleArray(q.choices),
  }));
}

function ProblemDiagram({ diagram }) {
  if (!diagram) return null;
  const Comp = DIAGRAM_REGISTRY[diagram.component];
  if (!Comp) return null;
  return <div className="ex-diagram"><Comp {...(diagram.props || {})} /></div>;
}

const PREVIEW_COUNT = 10;

export function ExamSession({ userName, preview = false }) {
  const navigate = useNavigate();
  useDocumentTitle(preview ? 'Free Exam Preview' : 'Exam Simulation');

  const [phase, setPhase] = React.useState('LOADING'); // LOADING | EXAM | BREAK | CONFIRM | SUBMITTING | PREVIEW_RESULT
  const [previewResult, setPreviewResult] = React.useState(null);
  const [questions, setQuestions] = React.useState([]);
  const [attemptId, setAttemptId] = React.useState(null);
  const [currentIndex, setCurrentIndex] = React.useState(0);
  const [userAnswers, setUserAnswers] = React.useState({});
  const [flagged, setFlagged] = React.useState(new Set());
  const [timeLeft, setTimeLeft] = React.useState(TIME_LIMIT);
  const [startTime, setStartTime] = React.useState(null);
  const [error, setError] = React.useState('');
  const [breakTimeLeft, setBreakTimeLeft] = React.useState(BREAK_DURATION);
  const [breakTaken, setBreakTaken] = React.useState(false);

  // ── Progress durability ────────────────────────────────────────────────
  // The exam runs up to 5h20m and answers used to live only in this component's
  // state, so a refresh, crash, or accidental navigation wiped everything while
  // the server clock kept running. Three of the first six paying customers
  // submitted single-digit answer counts because of it.
  //
  // Two layers:
  //   1. localStorage, written synchronously on every change — instant, and
  //      covers the gap before the next network flush plus offline moments.
  //   2. a debounced PATCH to the server — authoritative, survives clearing
  //      site data or switching device.
  // The server MERGES, so neither layer can blank out the other.
  const dirtyRef = React.useRef(false);
  const stateRef = React.useRef({ userAnswers: {}, currentIndex: 0, flagged: [], breakTaken: false });
  const attemptIdRef = React.useRef(null);
  // The countdown effect below depends only on [phase], so anything it closes
  // over is frozen at the moment the exam started. Auto-submit MUST go through
  // this ref: calling a captured submitExam is what made a timed-out exam submit
  // a blank answer set and score 0%.
  const submitRef = React.useRef(() => {});
  // Server-issued wall-clock deadline (epoch ms). The clock is derived from this
  // on every tick and on every wake, never decremented blindly: the old
  // setInterval countdown simply stopped when the tab was hidden or the laptop
  // slept, handing out unlimited extra time on a timed exam.
  const deadlineRef = React.useRef(null);
  const breakStartedAtRef = React.useRef(null);
  const breakEndedAtRef = React.useRef(null);
  const SAVE_DEBOUNCE_MS = 8000;

  const localKey = (id) => `fe4r_exam_progress_${id}`;

  function markDirty() {
    dirtyRef.current = true;
  }

  // Keep a ref copy so the flush handlers (interval, pagehide) always send the
  // latest state without being re-registered on every keystroke.
  React.useEffect(() => {
    stateRef.current = {
      userAnswers,
      currentIndex,
      flagged: Array.from(flagged),
      breakTaken,
    };
    if (preview || !attemptId) return;
    try {
      localStorage.setItem(localKey(attemptId), JSON.stringify({
        ...stateRef.current,
        savedAt: Date.now(),
      }));
    } catch { /* storage full or blocked — the server flush still covers us */ }
  }, [userAnswers, currentIndex, flagged, breakTaken, attemptId, preview]);

  React.useEffect(() => { attemptIdRef.current = attemptId; }, [attemptId]);

  const flushProgress = React.useCallback(async (opts = {}) => {
    const id = attemptIdRef.current;
    if (preview || !id) return;
    if (!dirtyRef.current && !opts.force) return;
    dirtyRef.current = false;
    const { userAnswers: ua, currentIndex: ci, flagged: fl, breakTaken: bt } = stateRef.current;
    const body = JSON.stringify({
      attemptId: id,
      answers: ua,
      currentIndex: ci,
      flagged: fl,
      breakTaken: bt,
      breakStartedAt: breakStartedAtRef.current ? new Date(breakStartedAtRef.current).toISOString() : undefined,
      breakEndedAt: breakEndedAtRef.current ? new Date(breakEndedAtRef.current).toISOString() : undefined,
    });
    try {
      if (opts.beacon && navigator.sendBeacon) {
        // On pagehide a normal fetch is often killed mid-flight. sendBeacon is
        // the only transport the browser guarantees to deliver, but it cannot
        // send PATCH, so the server also accepts this on POST.
        navigator.sendBeacon('/api/exam/answers-beacon', new Blob([body], { type: 'application/json' }));
        return;
      }
      await fetch('/api/exam/answers', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body,
      });
    } catch {
      dirtyRef.current = true; // retry on the next tick rather than losing it
    }
  }, [preview]);

  // Periodic flush while the exam is open.
  React.useEffect(() => {
    if (preview || phase !== 'EXAM') return undefined;
    const t = setInterval(() => { flushProgress(); }, SAVE_DEBOUNCE_MS);
    return () => clearInterval(t);
  }, [phase, preview, flushProgress]);

  // Flush when the tab is hidden or unloaded — the moment answers used to die.
  React.useEffect(() => {
    if (preview) return undefined;
    const onHide = () => { flushProgress({ beacon: true, force: true }); };
    const onVisibility = () => { if (document.visibilityState === 'hidden') onHide(); };
    window.addEventListener('pagehide', onHide);
    document.addEventListener('visibilitychange', onVisibility);
    return () => {
      window.removeEventListener('pagehide', onHide);
      document.removeEventListener('visibilitychange', onVisibility);
    };
  }, [preview, flushProgress]);

  React.useEffect(() => {
    if (!userName) {
      navigate('/');
      return;
    }
    initExam();
  }, [userName, navigate]);

  async function initExam() {
    try {
      // Free preview: client-side only, no purchase, no server attempt.
      if (preview) {
        const sample = selectPreviewQuestions(PREVIEW_COUNT);
        if (sample.length === 0) {
          setError('No preview questions available.');
          return;
        }
        setQuestions(shuffleQuestionChoices(sample));
        // Preview has no server attempt, so it sets its own deadline. Without
        // this the shared timer would fall back to the full 5h20m.
        deadlineRef.current = Date.now() + PREVIEW_COUNT * 175 * 1000;
        setTimeLeft(PREVIEW_COUNT * 175); // ~exam pace (2.91 min/q)
        setStartTime(Date.now());
        setPhase('EXAM');
        return;
      }

      const selected = selectExamQuestions();
      if (selected.length === 0) {
        setError('No exam questions available.');
        setPhase('LOADING');
        return;
      }

      const serverQuestions = selected.map(q => ({
        id: q.id,
        chapterId: q.chapterId,
        lessonId: q.lessonId,
        statement: q.statement,
        choices: q.choices,
        correctAnswerId: q.correctAnswerId,
        type: q.type,
        diagram: q.diagram || null,
      }));

      const res = await fetch('/api/exam/start', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ questions: serverQuestions }),
      });

      if (res.status === 403) {
        navigate('/exam');
        return;
      }

      if (!res.ok) {
        const body = await res.json();
        throw new Error(body.msg || 'Failed to start exam');
      }

      const data = await res.json();
      setAttemptId(data.attemptId);

      if (data.resumed) {
        // Use the questions the SERVER stored, not the freshly generated local
        // set. Regenerating meant the user answered a different exam than the
        // one being scored, so their questionIds did not match and every answer
        // was counted blank.
        setQuestions(shuffleQuestionChoices(data.questions || []));

        // Server answers are authoritative, but the localStorage mirror can be
        // newer than the last successful flush (that is the whole point of it),
        // so overlay it.
        let restored = data.savedAnswers || {};
        try {
          const raw = localStorage.getItem(localKey(data.attemptId));
          if (raw) {
            const local = JSON.parse(raw);
            if (local && typeof local.userAnswers === 'object') {
              restored = { ...restored, ...local.userAnswers };
            }
          }
        } catch { /* ignore a corrupt mirror; the server copy stands */ }

        setUserAnswers(restored);
        setFlagged(new Set(Array.isArray(data.flagged) ? data.flagged : []));
        setBreakTaken(data.breakTaken === true);
        setCurrentIndex(
          Number.isInteger(data.currentIndex)
            ? Math.min(data.currentIndex, Math.max(0, (data.questions || []).length - 1))
            : 0,
        );

        // Anchor the client timer to the server's start so a resumed session
        // reports true elapsed time, not just the time since this page load.
        setStartTime(new Date(data.startedAt).getTime());
        deadlineRef.current = data.deadline || (new Date(data.startedAt).getTime() + TIME_LIMIT * 1000);
        setTimeLeft(remainingFromDeadline());
      } else {
        setQuestions(shuffleQuestionChoices(selected));
        deadlineRef.current = data.deadline || (Date.now() + TIME_LIMIT * 1000);
        setStartTime(new Date(data.startedAt || Date.now()).getTime());
        setTimeLeft(remainingFromDeadline());
      }

      setPhase('EXAM');
    } catch (err) {
      setError(err.message);
    }
  }

  // Seconds left, always re-derived from the server deadline. Never a stored
  // countdown, so hiding the tab or sleeping the machine cannot buy time.
  function remainingFromDeadline() {
    if (!deadlineRef.current) return TIME_LIMIT;
    return Math.max(0, Math.round((deadlineRef.current - Date.now()) / 1000));
  }

  // Exam timer. Recomputes from the deadline each tick and auto-submits the
  // moment it reaches zero, including when the tab wakes up already past it.
  React.useEffect(() => {
    if (phase !== 'EXAM') return undefined;

    const tick = () => {
      const left = remainingFromDeadline();
      setTimeLeft(left);
      if (left <= 0) {
        clearInterval(interval);
        submitRef.current();
      }
    };
    const interval = setInterval(tick, 1000);
    tick();

    // A backgrounded tab throttles timers, so the deadline may already have
    // passed by the time focus returns. Re-check on wake rather than waiting for
    // the next throttled tick.
    const onWake = () => { if (document.visibilityState === 'visible') tick(); };
    document.addEventListener('visibilitychange', onWake);
    window.addEventListener('focus', onWake);

    return () => {
      clearInterval(interval);
      document.removeEventListener('visibilitychange', onWake);
      window.removeEventListener('focus', onWake);
    };
  }, [phase]);

  // Break timer countdown
  React.useEffect(() => {
    if (phase !== 'BREAK') return;

    const interval = setInterval(() => {
      setBreakTimeLeft(prev => {
        if (prev <= 1) {
          clearInterval(interval);
          resumeFromBreak();
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    return () => clearInterval(interval);
  }, [phase]);

  function formatTime(seconds) {
    const h = Math.floor(seconds / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    const s = seconds % 60;
    if (h > 0) {
      return `${h}:${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
    }
    return `${m}:${String(s).padStart(2, '0')}`;
  }

  // Answers are keyed by QUESTION ID, never by array position. Position keys
  // broke on resume: the session used to regenerate its own question list, so
  // index 7 meant a different question than the server had stored and the answer
  // was scored as blank.
  function handleSelectChoice(choiceId) {
    const qid = questions[currentIndex]?.id;
    if (!qid) return;
    setUserAnswers(prev => ({ ...prev, [qid]: choiceId }));
    markDirty();
  }

  function handleToggleFlag() {
    setFlagged(prev => {
      const next = new Set(prev);
      if (next.has(currentIndex)) next.delete(currentIndex);
      else next.add(currentIndex);
      return next;
    });
    markDirty();
  }

  function handleNext() {
    const nextIndex = currentIndex + 1;
    if (nextIndex >= questions.length) return;

    // Trigger break at the halfway point (after question 55)
    if (!breakTaken && currentIndex === BREAK_AFTER_QUESTION - 1) {
      // Stamp the break start and push it immediately. The break sits outside
      // exam time, so the server needs it to extend the deadline even if the tab
      // dies during the break.
      breakStartedAtRef.current = Date.now();
      setBreakTimeLeft(BREAK_DURATION);
      setPhase('BREAK');
      markDirty();
      flushProgress({ force: true });
      return;
    }

    setCurrentIndex(nextIndex);
  }

  function resumeFromBreak() {
    // Credit the break back onto the deadline, capped at one full break so a
    // long absence cannot become unlimited exam time.
    if (breakStartedAtRef.current && deadlineRef.current) {
      const taken = Math.min(Date.now() - breakStartedAtRef.current, BREAK_DURATION * 1000);
      deadlineRef.current += Math.max(0, taken);
    }
    breakEndedAtRef.current = Date.now();
    setBreakTaken(true);
    markDirty();
    flushProgress({ force: true });
    setCurrentIndex(BREAK_AFTER_QUESTION);
    setPhase('EXAM');
  }

  function handlePrev() {
    if (currentIndex > 0) setCurrentIndex(i => i - 1);
  }

  function handleJumpTo(index) {
    setCurrentIndex(index);
  }

  function handleSubmit(autoSubmit = false) {
    if (!autoSubmit) {
      setPhase('CONFIRM');
      return;
    }
    submitExam();
  }

  // Refresh the ref every render so the countdown always fires the CURRENT
  // submitExam. Without this the auto-submit at 00:00 runs a function frozen at
  // exam start.
  React.useEffect(() => { submitRef.current = submitExam; });

  async function submitExam() {
    // Free preview: score on the client, no server submit.
    if (preview) {
      let correct = 0;
      const chapterScores = {};
      // Live state, for the same stale-closure reason as the paid path below.
      const userAnswers = stateRef.current.userAnswers || {};
      questions.forEach((q, i) => {
        const ch = q.chapterId;
        if (!chapterScores[ch]) chapterScores[ch] = { correct: 0, total: 0 };
        chapterScores[ch].total++;
        if (userAnswers[q.id] && userAnswers[q.id] === q.correctAnswerId) {
          correct++;
          chapterScores[ch].correct++;
        }
      });
      setPreviewResult({
        totalCorrect: correct,
        totalQuestions: questions.length,
        overallPercentage: Math.round((correct / questions.length) * 100),
        chapterScores,
      });
      setPhase('PREVIEW_RESULT');
      return;
    }

    setPhase('SUBMITTING');
    const timeUsedSeconds = startTime ? Math.round((Date.now() - startTime) / 1000) : 0;

    // Read answers from the ref, NOT from the closed-over `userAnswers`.
    //
    // The countdown effect depends only on [phase], so the submitExam it calls
    // is captured from the render where the exam began. Reading closure state
    // there meant a timed-out exam submitted the answer set from hours earlier —
    // on a fresh attempt, nothing at all, scoring 0/110. stateRef is kept in
    // sync on every change precisely so this path can be trusted.
    const liveAnswers = stateRef.current.userAnswers || {};

    // Send only real selections. Sending an explicit null for every unanswered
    // question is what let a partial client wipe the server's autosaved answers.
    // The server scores unanswered questions from its own stored question list,
    // so omitting them loses nothing and can no longer destroy anything.
    const answers = Object.entries(liveAnswers)
      .filter(([, selectedAnswerId]) => Boolean(selectedAnswerId))
      .map(([questionId, selectedAnswerId]) => ({ questionId, selectedAnswerId }));

    // Push the latest state before scoring, so the server has everything even if
    // the submit request itself fails and the user has to retry.
    await flushProgress({ force: true });

    try {
      const res = await fetch('/api/exam/submit', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ attemptId, answers, timeUsedSeconds }),
      });

      if (!res.ok) throw new Error('Submit failed');
      const result = await res.json();

      // The attempt is finished and scored server-side; drop the local mirror so
      // it can never be replayed onto a future attempt.
      try { localStorage.removeItem(localKey(attemptId)); } catch { /* ignore */ }

      sessionStorage.setItem('examResult', JSON.stringify(result));
      navigate(`/exam/results/${attemptId}`);
    } catch {
      setError('Failed to submit exam. Please try again.');
      setPhase('EXAM');
    }
  }

  const answeredCount = Object.values(userAnswers).filter(Boolean).length;

  // ═══ LOADING ═══
  if (phase === 'LOADING') {
    return (
      <main className="ex-main">
        <div className="ex-loading">
          {error ? (
            <div>
              <div className="exam-error" role="alert">{error}</div>
              <button className="btn-secondary" onClick={() => navigate('/exam')}>
                Back to Exam
              </button>
            </div>
          ) : (
            <p>Preparing your exam...</p>
          )}
        </div>
      </main>
    );
  }

  // ═══ BREAK ═══
  if (phase === 'BREAK') {
    const firstHalfAnswered = questions.slice(0, BREAK_AFTER_QUESTION).filter(q => userAnswers[q.id]).length;
    return (
      <main className="ex-main">
        <div className="ex-break-overlay">
          <div className="ex-break-card">
            <Coffee size={40} weight="bold" className="ex-break-icon" />
            <h2>Scheduled Break</h2>
            <p>
              Just like the real FE exam, you have an optional 25-minute break at the halfway point.
              Your exam timer is paused.
            </p>
            <div className="ex-break-timer">{formatTime(breakTimeLeft)}</div>
            <div className="ex-break-label">remaining</div>
            <div className="ex-break-progress">
              First half: {firstHalfAnswered}/{BREAK_AFTER_QUESTION} answered
            </div>
            <div className="ex-break-stats">
              {questions.length - BREAK_AFTER_QUESTION} questions remaining after break
            </div>
            <div className="ex-break-actions">
              <button className="btn-primary" onClick={resumeFromBreak}>
                Continue Exam
                <ArrowRight size={16} weight="bold" />
              </button>
            </div>
          </div>
        </div>
      </main>
    );
  }

  // ═══ CONFIRM ═══
  if (phase === 'CONFIRM') {
    const unanswered = questions.length - answeredCount;
    return (
      <main className="ex-main">
        <div className="dx-confirm-overlay">
          <div className="dx-confirm-card">
            <WarningCircle size={32} weight="bold" className="dx-confirm-icon" />
            <h2>Submit your exam?</h2>
            <p>
              You answered <strong>{answeredCount}</strong> of <strong>{questions.length}</strong> questions.
              {unanswered > 0 && (
                <> <strong>{unanswered}</strong> {unanswered === 1 ? 'question is' : 'questions are'} unanswered and will count as incorrect.</>
              )}
            </p>
            <div className="dx-confirm-actions">
              <button className="btn-primary" onClick={submitExam}>
                Submit Exam
              </button>
              <button className="btn-secondary" onClick={() => setPhase('EXAM')}>
                Go Back
              </button>
            </div>
          </div>
        </div>
      </main>
    );
  }

  // ═══ SUBMITTING ═══
  if (phase === 'SUBMITTING') {
    return (
      <main className="ex-main">
        <div className="ex-loading">
          <p>Scoring your exam...</p>
        </div>
      </main>
    );
  }

  // ═══ PREVIEW RESULT ═══
  if (phase === 'PREVIEW_RESULT' && previewResult) {
    const r = previewResult;
    const rows = Object.entries(r.chapterScores).map(([id, s]) => ({
      name: CHAPTERS.find((c) => c.id === id)?.name || id,
      correct: s.correct,
      total: s.total,
    }));
    return (
      <main className="ex-main">
        <div className="ex-preview-result">
          <span className="ex-preview-tag">Free preview · {r.totalQuestions} questions</span>
          <h2 className="ex-preview-score">{r.totalCorrect}/{r.totalQuestions} correct &middot; {r.overallPercentage}%</h2>
          <p className="ex-preview-lead">
            This is exactly how the full exam works — timed, NCEES-weighted, and scored by chapter.
          </p>
          <div className="ex-preview-breakdown">
            {rows.map((row) => {
              const ratio = row.total ? row.correct / row.total : 0;
              const color = ratio === 1 ? 'var(--forest)' : ratio > 0 ? 'var(--sunbeam)' : 'var(--error)';
              return (
                <div key={row.name} className="ex-preview-row">
                  <span className="ex-preview-chapter">{row.name}</span>
                  <span className="ex-preview-mark" style={{ color }}>{row.correct}/{row.total}</span>
                </div>
              );
            })}
          </div>
          <div className="ex-preview-cta">
            <p className="ex-preview-cta-text">
              That was a 10-question taste. The full simulation is <strong>110 questions</strong>, timed like
              exam day, with <strong>unlimited retakes</strong> — and a money-back guarantee.
            </p>
            <button className="btn-primary" onClick={() => navigate('/exam')}>
              Unlock the full exam — ${priceForEmail(userName)}
              <ArrowRight size={16} weight="bold" />
            </button>
            <button className="btn-secondary" onClick={() => window.location.reload()}>
              Retake preview
            </button>
          </div>
        </div>
      </main>
    );
  }

  // ═══ EXAM ═══
  const question = questions[currentIndex];
  if (!question) return null;

  const isTimeLow = timeLeft <= 600;
  const selectedChoice = userAnswers[questions[currentIndex]?.id] || null;
  const chapterMeta = CHAPTERS.find(c => c.id === question.chapterId);

  return (
    <main className="ex-main">
      {/* Top bar */}
      <div className="dx-topbar">
        <div className={`dx-timer ${isTimeLow ? 'dx-timer--low' : ''}`}>
          <Timer size={18} weight="bold" />
          <span>{formatTime(timeLeft)}</span>
        </div>

        <span className="dx-progress-text">
          {currentIndex + 1} of {questions.length}
        </span>

        <button className="dx-submit-btn" onClick={() => handleSubmit(false)}>
          <PaperPlaneTilt size={16} weight="bold" />
          Submit Exam
        </button>
      </div>

      <div className="dx-body ex-body-wide">
        {/* Question area */}
        <div className="dx-question-area">
          <div className="dx-question-card">
            <div className="dx-question-header">
              <div>
                <span className="dx-question-num">Question {currentIndex + 1}</span>
                {chapterMeta && (
                  <span className="ex-chapter-tag">{chapterMeta.name}</span>
                )}
              </div>
              <button
                className={`dx-flag-btn ${flagged.has(currentIndex) ? 'dx-flag-btn--active' : ''}`}
                onClick={handleToggleFlag}
                title="Flag for review"
              >
                <Flag size={16} weight={flagged.has(currentIndex) ? 'fill' : 'bold'} />
              </button>
            </div>

            <div className="dx-statement">
              <MathText text={question.statement} />
            </div>

            <ProblemDiagram diagram={question.diagram} />

            <div className="dx-choices">
              {question.choices.map((c, ci) => {
                const label = String.fromCharCode(65 + ci);
                const isSelected = c.id === selectedChoice;
                return (
                  <button
                    key={c.id}
                    className={`dx-choice ${isSelected ? 'dx-choice--selected' : ''}`}
                    onClick={() => handleSelectChoice(c.id)}
                  >
                    <span className="dx-choice-label">{label}</span>
                    <span className="dx-choice-text">
                      <MathText text={c.text} />
                    </span>
                  </button>
                );
              })}
            </div>

            <div className="dx-nav-buttons">
              <button
                className="btn-secondary dx-nav-btn"
                onClick={handlePrev}
                disabled={currentIndex === 0}
              >
                <ArrowLeft size={16} weight="bold" />
                Previous
              </button>

              {currentIndex < questions.length - 1 ? (
                <button className="btn-secondary dx-nav-btn" onClick={handleNext}>
                  Next
                  <ArrowRight size={16} weight="bold" />
                </button>
              ) : (
                <button className="btn-primary dx-nav-btn" onClick={() => handleSubmit(false)}>
                  <PaperPlaneTilt size={16} weight="bold" />
                  Submit Exam
                </button>
              )}
            </div>
          </div>

          {error && <div className="dx-error" role="alert">{error}</div>}
        </div>

        {/* Question grid sidebar */}
        <div className="dx-sidebar">
          <h3 className="dx-sidebar-title">Questions</h3>
          <div className="ex-grid">
            {questions.map((_, i) => {
              const isAnswered = Boolean(userAnswers[questions[i]?.id]);
              const isFlagged = flagged.has(i);
              const isCurrent = i === currentIndex;

              let cls = 'dx-grid-cell';
              if (isCurrent) cls += ' dx-grid-cell--current';
              else if (isFlagged) cls += ' dx-grid-cell--flagged';
              else if (isAnswered) cls += ' dx-grid-cell--answered';

              return (
                <button key={i} className={cls} onClick={() => handleJumpTo(i)}>
                  {i + 1}
                </button>
              );
            })}
          </div>
          <div className="dx-grid-legend">
            <span><span className="dx-legend-dot dx-legend-dot--answered" /> Answered</span>
            <span><span className="dx-legend-dot dx-legend-dot--flagged" /> Flagged</span>
            <span><span className="dx-legend-dot dx-legend-dot--unanswered" /> Unanswered</span>
          </div>
          <div className="dx-grid-stats">
            {answeredCount}/{questions.length} answered
          </div>
        </div>
      </div>
    </main>
  );
}
