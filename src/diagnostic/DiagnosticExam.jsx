import React from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Timer,
  ArrowLeft,
  ArrowRight,
  Flag,
  PaperPlaneTilt,
  WarningCircle,
} from '@phosphor-icons/react';
import { MathText } from '../components/MathText';
import { CHAPTERS } from '../data/chapters';
import { selectDiagnosticQuestions } from '../data/lessons/index';
import { DIAGRAM_REGISTRY } from '../components/diagrams';
import './diagnostic.css';

const TIME_PER_QUESTION = 174.6; // 2.91 minutes in seconds

function ProblemDiagram({ diagram }) {
  if (!diagram) return null;
  const Comp = DIAGRAM_REGISTRY[diagram.component];
  if (!Comp) return null;
  return <div className="dx-diagram"><Comp {...(diagram.props || {})} /></div>;
}

export function DiagnosticExam({ userName }) {
  const navigate = useNavigate();

  // Exam state
  const [phase, setPhase] = React.useState('INTRO'); // INTRO | EXAM | CONFIRM | SUBMITTING
  const [questions, setQuestions] = React.useState([]);
  const [currentIndex, setCurrentIndex] = React.useState(0);
  const [userAnswers, setUserAnswers] = React.useState({}); // { questionIndex: choiceId }
  const [flagged, setFlagged] = React.useState(new Set());
  const [timeLeft, setTimeLeft] = React.useState(0);
  const [startTime, setStartTime] = React.useState(null);
  const [error, setError] = React.useState('');

  // Load questions and previous attempt history
  React.useEffect(() => {
    if (!userName) {
      navigate('/');
      return;
    }
  }, [userName, navigate]);

  function startExam() {
    // Fetch previous attempt question IDs to exclude
    fetch('/api/diagnostic/history')
      .then(res => res.ok ? res.json() : [])
      .then(history => {
        const usedIds = [];
        for (const attempt of history) {
          if (attempt.chapterScores) {
            // We don't store individual question IDs in history summary,
            // so for now just select fresh questions
          }
        }
        return usedIds;
      })
      .then(excludeIds => {
        const selected = selectDiagnosticQuestions(excludeIds);
        if (selected.length === 0) {
          setError('No exam questions available yet. Questions are being added to the platform.');
          return;
        }
        setQuestions(selected);
        const totalTime = Math.round(selected.length * TIME_PER_QUESTION);
        setTimeLeft(totalTime);
        setStartTime(Date.now());
        setPhase('EXAM');
      })
      .catch(() => {
        // If API fails, still try to load questions (no exclusions)
        const selected = selectDiagnosticQuestions([]);
        if (selected.length === 0) {
          setError('No exam questions available yet. Questions are being added to the platform.');
          return;
        }
        setQuestions(selected);
        const totalTime = Math.round(selected.length * TIME_PER_QUESTION);
        setTimeLeft(totalTime);
        setStartTime(Date.now());
        setPhase('EXAM');
      });
  }

  // Timer countdown
  React.useEffect(() => {
    if (phase !== 'EXAM' || timeLeft <= 0) return;

    const interval = setInterval(() => {
      setTimeLeft(prev => {
        if (prev <= 1) {
          clearInterval(interval);
          handleSubmit(true);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    return () => clearInterval(interval);
  }, [phase]);

  function formatTime(seconds) {
    const m = Math.floor(seconds / 60);
    const s = seconds % 60;
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
    if (currentIndex < questions.length - 1) {
      setCurrentIndex(i => i + 1);
    }
  }

  function handlePrev() {
    if (currentIndex > 0) {
      setCurrentIndex(i => i - 1);
    }
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

  function submitExam() {
    setPhase('SUBMITTING');
    const timeUsedSeconds = Math.round((Date.now() - startTime) / 1000);

    const questionData = questions.map((q, i) => ({
      questionId: q.id,
      chapterId: q.chapterId,
      lessonId: q.lessonId,
      type: q.type || 'computational',
      selectedAnswerId: userAnswers[i] || null,
      correctAnswerId: q.correctAnswerId,
      isCorrect: userAnswers[i] === q.correctAnswerId,
      timeSpentSeconds: 0, // not tracked per-question in this version
    }));

    fetch('/api/diagnostic/submit', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ questions: questionData, timeUsedSeconds }),
    })
      .then(res => {
        if (!res.ok) throw new Error('Submit failed');
        return res.json();
      })
      .then(result => {
        // Store result in sessionStorage for the results page
        sessionStorage.setItem('diagnosticResult', JSON.stringify({
          ...result,
          questions: questionData,
          questionsData: questions,
        }));
        navigate(`/diagnostic/results/${result.attemptNumber}`);
      })
      .catch(() => {
        setError('Failed to submit diagnostic. Please try again.');
        setPhase('EXAM');
      });
  }

  const answeredCount = Object.keys(userAnswers).length;

  // ═══ INTRO SCREEN ═══
  if (phase === 'INTRO') {
    return (
      <main className="dx-main">
        <div className="dx-intro">
          <div className="dx-intro-card">
            <h1 className="dx-intro-title">Diagnostic Exam</h1>
            <p className="dx-intro-subtitle">
              This is your compass, not a test.
            </p>

            <div className="dx-intro-body">
              <p>
                Before you dive into studying, take this quick diagnostic to see where you stand
                across all 15 FE exam topics.
              </p>

              <div className="dx-rules">
                <div className="dx-rule">
                  <span className="dx-rule-num">30</span>
                  <span>questions covering all 15 chapters (2 per chapter)</span>
                </div>
                <div className="dx-rule">
                  <span className="dx-rule-num">87</span>
                  <span>minutes at real FE exam pace (2.91 min/question)</span>
                </div>
                <div className="dx-rule">
                  <span className="dx-rule-num">60%</span>
                  <span>max mastery per chapter from diagnostic alone</span>
                </div>
              </div>

              <div className="dx-intro-tips">
                <p>Skip questions freely — blank answers tell us where to help you.</p>
                <p>You earn 10 XP per question attempted + 5 XP bonus per correct answer.</p>
                <p>Your results personalize your study plan and set your starting mastery bars.</p>
              </div>
            </div>

            {error && <div className="dx-error" role="alert">{error}</div>}

            <div className="dx-intro-actions">
              <button className="btn-primary dx-start-btn" onClick={startExam}>
                Start Diagnostic
              </button>
              <button className="btn-secondary" onClick={() => navigate('/dashboard')}>
                <ArrowLeft size={16} weight="bold" />
                Back to Dashboard
              </button>
            </div>
          </div>
        </div>
      </main>
    );
  }

  // ═══ CONFIRM SUBMIT MODAL ═══
  if (phase === 'CONFIRM') {
    const unanswered = questions.length - answeredCount;
    return (
      <main className="dx-main">
        <div className="dx-confirm-overlay">
          <div className="dx-confirm-card">
            <WarningCircle size={32} weight="bold" className="dx-confirm-icon" />
            <h2>Submit your diagnostic?</h2>
            <p>
              You answered <strong>{answeredCount}</strong> of <strong>{questions.length}</strong> questions.
              {unanswered > 0 && (
                <> <strong>{unanswered}</strong> {unanswered === 1 ? 'question is' : 'questions are'} unanswered and will count as incorrect.</>
              )}
            </p>
            <div className="dx-confirm-actions">
              <button className="btn-primary" onClick={submitExam}>
                Submit Diagnostic
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
      <main className="dx-main">
        <div className="dx-loading">
          <p>Calculating your results...</p>
        </div>
      </main>
    );
  }

  // ═══ EXAM SCREEN ═══
  const question = questions[currentIndex];
  if (!question) return null;

  const isTimeLow = timeLeft <= 600; // 10 minutes
  const selectedChoice = userAnswers[currentIndex] || null;

  // Find chapter name for display context
  const chapterMeta = CHAPTERS.find(c => c.id === question.chapterId);

  return (
    <main className="dx-main">
      {/* ── Top bar: timer + progress ── */}
      <div className="dx-topbar">
        <div className={`dx-timer ${isTimeLow ? 'dx-timer--low' : ''}`}>
          <Timer size={18} weight="bold" />
          <span>{formatTime(timeLeft)}</span>
        </div>

        <span className="dx-progress-text">
          {currentIndex + 1} of {questions.length}
        </span>

        <button
          className="dx-submit-btn"
          onClick={() => handleSubmit(false)}
        >
          <PaperPlaneTilt size={16} weight="bold" />
          Submit Exam
        </button>
      </div>

      <div className="dx-body">
        {/* ── LEFT: Question ── */}
        <div className="dx-question-area">
          <div className="dx-question-card">
            <div className="dx-question-header">
              <span className="dx-question-num">Question {currentIndex + 1}</span>
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
                <button
                  className="btn-secondary dx-nav-btn"
                  onClick={handleNext}
                >
                  Next
                  <ArrowRight size={16} weight="bold" />
                </button>
              ) : (
                <button
                  className="btn-primary dx-nav-btn"
                  onClick={() => handleSubmit(false)}
                >
                  <PaperPlaneTilt size={16} weight="bold" />
                  Submit Exam
                </button>
              )}
            </div>
          </div>

          {error && <div className="dx-error" role="alert">{error}</div>}
        </div>

        {/* ── RIGHT: Question Grid ── */}
        <div className="dx-sidebar">
          <h3 className="dx-sidebar-title">Questions</h3>
          <div className="dx-grid">
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
