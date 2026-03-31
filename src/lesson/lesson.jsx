import React from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  ArrowLeft,
  ArrowRight,
  CaretDown,
  Tag,
  BookBookmark,
  BookOpenText,
  ArrowsClockwise,
  Play,
  SealWarning,
  LockSimple,
  CheckCircle,
  XCircle,
  Lightning,
  Warning,
} from '@phosphor-icons/react';
import katex from 'katex';
import { MathText } from '../components/MathText';
import { CHAPTERS } from '../data/chapters';
import { CHAPTER_DETAILS } from '../data/chapters/index';
import { getLessonById } from '../data/lessons/index';
import { useShuffledChoices } from '../utils/shuffleChoices';
import './lesson.css';

/* ── KaTeX block renderer ── */
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

function FormulaBlock({ tex }) {
  const html = React.useMemo(() => {
    try {
      return katex.renderToString(tex, { displayMode: true, throwOnError: false, strict: false });
    } catch {
      return tex;
    }
  }, [tex]);
  return <div className="lp-formula-block" dangerouslySetInnerHTML={{ __html: html }} />;
}

/* ── Resource panel definitions ── */
const PANELS = [
  { key: 'lesson',   label: 'Lesson',        icon: Tag,              color: 'sunbeam', locked: false },
  { key: 'handbook', label: 'FE Handbook',    icon: BookBookmark,     color: 'forest',  locked: false },
  { key: 'eli5',     label: 'ELI5',           icon: BookOpenText,     color: 'forest',  locked: true },
  { key: 'steps',    label: 'Step-by-Step',   icon: ArrowsClockwise,  color: 'ember',   locked: true },
  { key: 'video',    label: 'Video',          icon: Play,             color: 'sunbeam', locked: true },
  { key: 'traps',    label: 'Common Traps',   icon: SealWarning,      color: 'ember',   locked: true },
];

/* ═══════════════════════════════════════
   MAIN LESSON PAGE COMPONENT
   ═══════════════════════════════════════ */
export function LessonPage({ userName }) {
  const navigate = useNavigate();
  const { chapterId, lessonId } = useParams();

  // State machine
  const [currentIndex, setCurrentIndex] = React.useState(0);
  const [selectedChoice, setSelectedChoice] = React.useState(null);
  const [submitted, setSubmitted] = React.useState(false);
  const [openPanel, setOpenPanel] = React.useState(null);
  const [answers, setAnswers] = React.useState([]);

  // Lookup data
  const chapter = CHAPTERS.find((c) => c.id === chapterId);
  const details = CHAPTER_DETAILS[chapterId];
  const lesson = getLessonById(chapterId, lessonId);

  // Current problem
  const problem = lesson?.problems?.[currentIndex] ?? null;
  const { choices, correctLabel } = useShuffledChoices(problem);

  // Auth guard
  React.useEffect(() => {
    if (!userName) {
      navigate('/');
      return;
    }

    // WebSocket presence notification
    const protocol = window.location.protocol === 'http:' ? 'ws' : 'wss';
    const ws = new WebSocket(`${protocol}://${window.location.host}/ws`);
    ws.onopen = () => {
      ws.send(JSON.stringify({ type: 'lesson', from: userName, chapter: chapterId, lesson: lessonId }));
    };
    return () => ws.close();
  }, [userName, navigate, chapterId, lessonId]);

  if (!chapter || !lesson) {
    return (
      <main className="lesson-main">
        <div style={{ padding: '2rem' }}>
          <div className="error-banner">Lesson not found.</div>
          <button className="lesson-back-btn" onClick={() => navigate(`/study/${chapterId}`)}>
            <ArrowLeft size={16} weight="bold" /> Back to Chapter
          </button>
        </div>
      </main>
    );
  }

  const totalProblems = lesson.problems.length;
  const isComplete = currentIndex >= totalProblems;

  // Find the correct choice for feedback
  const correctChoice = submitted ? choices.find((c) => c.id === problem?.correctAnswerId) : null;
  const selectedIsCorrect = submitted && selectedChoice === problem?.correctAnswerId;

  function handleSelect(choiceId) {
    if (submitted) return;
    setSelectedChoice(choiceId);
  }

  function handleSubmit() {
    if (!selectedChoice || submitted) return;
    setSubmitted(true);
    setAnswers((prev) => [...prev, { problemId: problem.id, choiceId: selectedChoice, correct: selectedChoice === problem.correctAnswerId }]);

    // Auto-open ELI5 on incorrect
    if (selectedChoice !== problem.correctAnswerId) {
      setOpenPanel('eli5');
    }
  }

  function handleNext() {
    setCurrentIndex((i) => i + 1);
    setSelectedChoice(null);
    setSubmitted(false);
    setOpenPanel(null);
  }

  function handleRetry() {
    setCurrentIndex(0);
    setSelectedChoice(null);
    setSubmitted(false);
    setOpenPanel(null);
    setAnswers([]);
  }

  function togglePanel(key) {
    setOpenPanel(openPanel === key ? null : key);
  }

  // Summary calculations
  const correctCount = answers.filter((a) => a.correct).length;
  const scorePercent = totalProblems > 0 ? Math.round((correctCount / totalProblems) * 100) : 0;
  const xpEarned = correctCount * 10 + (correctCount === totalProblems ? 15 : 0);

  function getScoreClass() {
    if (scorePercent === 100) return 'lesson-summary-score--perfect';
    if (scorePercent >= 67) return 'lesson-summary-score--good';
    return 'lesson-summary-score--needs-work';
  }

  function getMessage() {
    if (scorePercent === 100) return 'Perfect score!';
    if (scorePercent >= 67) return 'Good work!';
    return 'Keep practicing!';
  }

  function getSubMessage() {
    if (scorePercent === 100) return 'You nailed every problem. That FE Handbook knowledge is solid.';
    if (scorePercent >= 67) return 'Strong performance. Review the ones you missed and try again.';
    return 'No worries — review the step-by-step solutions and give it another shot.';
  }

  // Find subtopic name for breadcrumb
  const subtopic = details?.subtopics?.find((s) => s.id === lesson.subtopicId);

  // ═══ SUMMARY SCREEN ═══
  if (isComplete) {
    return (
      <main className="lesson-main">
        <div className="lesson-header">
          <div className="lesson-header-left">
            <button className="lesson-back-btn" onClick={() => navigate(`/study/${chapterId}`)}>
              <ArrowLeft size={16} weight="bold" />
              Back
            </button>
          </div>
          <div className="lesson-header-center">
            {lesson.problems.map((_, i) => (
              <span key={i} className="lesson-dot lesson-dot--done" />
            ))}
          </div>
          <div className="lesson-header-right" />
        </div>

        <div className="lesson-summary">
          <div className="lesson-summary-card">
            <div className={`lesson-summary-score ${getScoreClass()}`}>
              {correctCount}/{totalProblems}
            </div>
            <div className="lesson-summary-label">Problems correct</div>
            <div className="lesson-summary-message">{getMessage()}</div>
            <p className="lesson-summary-sub">{getSubMessage()}</p>
            <div className="lesson-summary-xp">
              <Lightning size={16} weight="fill" />
              +{xpEarned} XP earned
            </div>
            <div className="lesson-summary-actions">
              <button className="btn-secondary" onClick={() => navigate(`/study/${chapterId}`)}>
                <ArrowLeft size={16} weight="bold" />
                Back to Chapter
              </button>
              <button className="btn-primary" onClick={handleRetry}>
                <ArrowsClockwise size={16} weight="bold" />
                Try Again
              </button>
            </div>
          </div>
        </div>
      </main>
    );
  }

  // ═══ PROBLEM SCREEN ═══
  return (
    <main className="lesson-main">
      {/* ── Slim header ── */}
      <div className="lesson-header">
        <div className="lesson-header-left">
          <button className="lesson-back-btn" onClick={() => navigate(`/study/${chapterId}`)}>
            <ArrowLeft size={16} weight="bold" />
            Back
          </button>
          <span className="lesson-breadcrumb">
            {chapter.name} / <strong>{lesson.name}</strong>
          </span>
        </div>
        <div className="lesson-header-center">
          {lesson.problems.map((_, i) => (
            <span
              key={i}
              className={`lesson-dot ${
                i < currentIndex ? 'lesson-dot--done' : i === currentIndex ? 'lesson-dot--active' : ''
              }`}
            />
          ))}
        </div>
        <div className="lesson-header-right" />
      </div>

      {/* ── Two-column body ── */}
      <div className="lesson-body">
        {/* ── LEFT: Problem ── */}
        <div className="lesson-left">
          <div className="lesson-problem">
            <span className={`lesson-difficulty lesson-difficulty--${problem.difficulty}`}>
              {problem.difficulty}
            </span>

            <div className="lesson-statement">
              <MathText text={problem.statement} />
            </div>

            {problem.diagram && (
              <div className="lesson-diagram-placeholder">
                Diagram will be added here
              </div>
            )}

            {/* Answer choices */}
            <div className="lesson-choices">
              {choices.map((c) => {
                let stateClass = '';
                if (submitted) {
                  if (c.id === problem.correctAnswerId) {
                    stateClass = 'lesson-choice--correct';
                  } else if (c.id === selectedChoice) {
                    stateClass = 'lesson-choice--incorrect';
                  } else {
                    stateClass = 'lesson-choice--dimmed';
                  }
                  stateClass += ' lesson-choice--disabled';
                } else if (c.id === selectedChoice) {
                  stateClass = 'lesson-choice--selected';
                }

                return (
                  <button
                    key={c.id}
                    className={`lesson-choice ${stateClass}`}
                    onClick={() => handleSelect(c.id)}
                    disabled={submitted}
                  >
                    <span className="lesson-choice-label">{c.label}</span>
                    <span className="lesson-choice-text">
                      <MathText text={c.text} />
                    </span>
                  </button>
                );
              })}
            </div>

            {/* Action area */}
            <div className="lesson-actions">
              {!submitted && (
                <button
                  className="lesson-submit-btn"
                  disabled={!selectedChoice}
                  onClick={handleSubmit}
                >
                  Submit Answer
                </button>
              )}

              {submitted && (
                <>
                  <div className={`lesson-feedback ${selectedIsCorrect ? 'lesson-feedback--correct' : 'lesson-feedback--incorrect'}`}>
                    {selectedIsCorrect ? (
                      <><CheckCircle size={20} weight="fill" /> Correct! The answer is {correctLabel}.</>
                    ) : (
                      <><XCircle size={20} weight="fill" /> Incorrect. The correct answer is {correctLabel}: {correctChoice?.text}</>
                    )}
                  </div>
                  <button className="lesson-next-btn" onClick={handleNext}>
                    {currentIndex < totalProblems - 1 ? (
                      <>Next Problem <ArrowRight size={16} weight="bold" /></>
                    ) : (
                      <>Finish Lesson <ArrowRight size={16} weight="bold" /></>
                    )}
                  </button>
                </>
              )}
            </div>
          </div>
        </div>

        {/* ── RIGHT: Resource Panels ── */}
        <div className="lesson-right">
          {PANELS.map((panel) => {
            const Icon = panel.icon;
            const isLocked = panel.locked && !submitted;
            const isOpen = openPanel === panel.key && !isLocked;

            return (
              <React.Fragment key={panel.key}>
                <button
                  className={`lp-trigger ${isOpen ? 'is-open' : ''}`}
                  onClick={() => !isLocked && togglePanel(panel.key)}
                  style={isLocked ? { cursor: 'default' } : undefined}
                >
                  <Icon size={18} weight="bold" className={`lp-icon lp-icon--${panel.color}`} />
                  <span>{panel.label}</span>
                  {isLocked ? (
                    <span className="lp-lock">
                      <LockSimple size={14} weight="bold" />
                      Submit to unlock
                    </span>
                  ) : (
                    <CaretDown size={14} weight="bold" className="lp-caret" />
                  )}
                </button>

                {isOpen && (
                  <div className="lp-body">
                    <PanelContent
                      panelKey={panel.key}
                      problem={problem}
                      lesson={lesson}
                      subtopic={subtopic}
                    />
                  </div>
                )}
              </React.Fragment>
            );
          })}
        </div>
      </div>
    </main>
  );
}

/* ── Panel content renderer ── */
function PanelContent({ panelKey, problem, lesson, subtopic }) {
  switch (panelKey) {
    case 'lesson':
      return (
        <>
          <p className="lp-lesson-name">{lesson.name}</p>
          <p>{subtopic?.name ?? ''}</p>
          {lesson.application && (
            <p style={{ marginTop: '0.5rem', fontStyle: 'italic' }}>{lesson.application}</p>
          )}
        </>
      );

    case 'handbook':
      return (
        <>
          {problem.handbookFormula && <FormulaBlock tex={problem.handbookFormula} />}
          {problem.handbookPage && (
            <span className="lp-handbook-ref">
              <BookBookmark size={14} weight="bold" />
              {problem.handbookPage}
            </span>
          )}
        </>
      );

    case 'eli5':
      return <p>{problem.eli5}</p>;

    case 'steps':
      return (
        <div className="lp-steps">
          {problem.steps.map((step, i) => (
            <div key={i} className="lp-step-item">
              <span className="lp-step-num">{String(i + 1).padStart(2, '0')}</span>
              <div className="lp-step-content">
                <p><MathText text={step.text} /></p>
                {step.latex && <MathBlock tex={step.latex} />}
              </div>
            </div>
          ))}
        </div>
      );

    case 'video':
      return problem.videoUrl ? (
        <a href={problem.videoUrl} target="_blank" rel="noopener noreferrer">
          Watch video explanation
        </a>
      ) : (
        <p style={{ color: 'var(--gray-400)', fontStyle: 'italic' }}>
          Video coming soon for this problem.
        </p>
      );

    case 'traps':
      return (
        <div className="lp-traps">
          {problem.traps.map((trap, i) => (
            <div key={i} className="lp-trap">
              <Warning size={14} weight="fill" className="lp-trap-icon" />
              <p>{trap}</p>
            </div>
          ))}
        </div>
      );

    default:
      return null;
  }
}
