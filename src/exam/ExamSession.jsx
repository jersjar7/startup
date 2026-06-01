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
      setQuestions(shuffleQuestionChoices(selected));

      if (data.resumed && data.startedAt) {
        const elapsed = Math.floor((Date.now() - new Date(data.startedAt).getTime()) / 1000);
        const remaining = Math.max(0, TIME_LIMIT - elapsed);
        setTimeLeft(remaining);
      } else {
        setTimeLeft(TIME_LIMIT);
      }

      setStartTime(Date.now());
      setPhase('EXAM');
    } catch (err) {
      setError(err.message);
    }
  }

  // Exam timer countdown (pauses during break)
  React.useEffect(() => {
    if (phase !== 'EXAM' || timeLeft <= 0) return;

    const interval = setInterval(() => {
      setTimeLeft(prev => {
        if (prev <= 1) {
          clearInterval(interval);
          submitExam();
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    return () => clearInterval(interval);
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

  function handleSelectChoice(choiceId) {
    setUserAnswers(prev => ({ ...prev, [currentIndex]: choiceId }));
  }

  function handleToggleFlag() {
    setFlagged(prev => {
      const next = new Set(prev);
      if (next.has(currentIndex)) next.delete(currentIndex);
      else next.add(currentIndex);
      return next;
    });
  }

  function handleNext() {
    const nextIndex = currentIndex + 1;
    if (nextIndex >= questions.length) return;

    // Trigger break at the halfway point (after question 55)
    if (!breakTaken && currentIndex === BREAK_AFTER_QUESTION - 1) {
      setBreakTimeLeft(BREAK_DURATION);
      setPhase('BREAK');
      return;
    }

    setCurrentIndex(nextIndex);
  }

  function resumeFromBreak() {
    setBreakTaken(true);
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

  async function submitExam() {
    // Free preview: score on the client, no server submit.
    if (preview) {
      let correct = 0;
      const chapterScores = {};
      questions.forEach((q, i) => {
        const ch = q.chapterId;
        if (!chapterScores[ch]) chapterScores[ch] = { correct: 0, total: 0 };
        chapterScores[ch].total++;
        if (userAnswers[i] && userAnswers[i] === q.correctAnswerId) {
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

    const answers = questions.map((q, i) => ({
      questionId: q.id,
      selectedAnswerId: userAnswers[i] || null,
    }));

    try {
      const res = await fetch('/api/exam/submit', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ attemptId, answers, timeUsedSeconds }),
      });

      if (!res.ok) throw new Error('Submit failed');
      const result = await res.json();

      sessionStorage.setItem('examResult', JSON.stringify(result));
      navigate(`/exam/results/${attemptId}`);
    } catch {
      setError('Failed to submit exam. Please try again.');
      setPhase('EXAM');
    }
  }

  const answeredCount = Object.keys(userAnswers).length;

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
    const firstHalfAnswered = Object.keys(userAnswers).filter(k => parseInt(k) < BREAK_AFTER_QUESTION).length;
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
            {rows.map((row) => (
              <div key={row.name} className="ex-preview-row">
                <span className="ex-preview-chapter">{row.name}</span>
                <span className="ex-preview-mark">{row.correct}/{row.total}</span>
              </div>
            ))}
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
  const selectedChoice = userAnswers[currentIndex] || null;
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
              const isAnswered = userAnswers[i] !== undefined;
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
