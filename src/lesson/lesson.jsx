import React from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
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
  MagnifyingGlass,
  Eye,
  EyeSlash,
  ArrowSquareOut,
} from '@phosphor-icons/react';
import katex from 'katex';
import { MathText } from '../components/MathText';
import { CHAPTERS } from '../data/chapters';
import { CHAPTER_DETAILS } from '../data/chapters/index';
import { getLessonById } from '../data/lessons/index';
import { useShuffledChoices } from '../utils/shuffleChoices';
import { LessonContent } from '../components/LessonContent';
import { DIAGRAM_REGISTRY } from '../components/diagrams';
import './lesson.css';

/* ── Problem diagram renderer ── */
function ProblemDiagram({ diagram, className = 'lesson-diagram' }) {
  if (!diagram) return null;
  const Comp = DIAGRAM_REGISTRY[diagram.component];
  if (!Comp) return null;
  return <div className={className}><Comp {...(diagram.props || {})} /></div>;
}

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

/* ── Lesson illustration (lazy-loaded from assets/lessons/) ── */
const illustrationModules = import.meta.glob('../assets/lessons/**/*.svg', { eager: true, query: '?url', import: 'default' });

function LessonIllustration({ src, alt }) {
  const path = `../assets/lessons/${src}`;
  const url = illustrationModules[path];
  if (!url) return null;
  return <img className="lp-illustration" src={url} alt={alt} />;
}

/* ── Handbook panel with hide/reveal ── */
function HandbookPanel({ problem }) {
  const [showPage, setShowPage] = React.useState(false);

  return (
    <div className="lp-handbook-content">
      {problem.handbookFormula && <FormulaBlock tex={problem.handbookFormula} />}

      {problem.handbookPage && (
        <div className="lp-handbook-page-section">
          <div className="lp-handbook-page-row">
            {showPage ? (
              <span className="lp-handbook-ref">
                <BookBookmark size={14} weight="bold" />
                {problem.handbookPage}
              </span>
            ) : (
              <span className="lp-handbook-hidden">
                <BookBookmark size={14} weight="bold" />
                Page hidden
              </span>
            )}
            <button
              className="lp-handbook-toggle"
              onClick={() => setShowPage(v => !v)}
              aria-label={showPage ? 'Hide page number' : 'Show page number'}
            >
              {showPage ? <EyeSlash size={14} weight="bold" /> : <Eye size={14} weight="bold" />}
            </button>
          </div>
          {!showPage && (
            <p className="lp-handbook-hint">
              Practice finding this reference yourself — navigating the handbook quickly is a key exam skill.
            </p>
          )}
        </div>
      )}

      <a
        href="https://help.ncees.org/article/87-ncees-exam-reference-handbooks"
        target="_blank"
        rel="noopener noreferrer"
        className="lp-handbook-link"
      >
        <ArrowSquareOut size={14} weight="bold" />
        Download FE Reference Handbook
      </a>
      <p className="lp-handbook-link-note">
        Requires an NCEES account (free to create)
      </p>
    </div>
  );
}

/* ── Resource panel definitions ── */
const PANELS = [
  { key: 'lesson',   label: 'Lesson',        icon: Tag,              color: 'sunbeam', locked: false },
  { key: 'handbook', label: 'FE Handbook',    icon: BookBookmark,     color: 'forest',  locked: false },
  { key: 'eli5',     label: 'Explain like I\'m 5', icon: BookOpenText, color: 'forest',  locked: true },
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
  const [reviewing, setReviewing] = React.useState(false);
  const [sessionResult, setSessionResult] = React.useState(null);
  const [sessionPosted, setSessionPosted] = React.useState(false);

  // Lookup data
  const chapter = CHAPTERS.find((c) => c.id === chapterId);
  const details = CHAPTER_DETAILS[chapterId];
  const lesson = getLessonById(chapterId, lessonId);
  useDocumentTitle(lesson ? `${lesson.name} — ${chapter?.name}` : 'Lesson');

  // Current problem
  const totalProblems = lesson?.problems?.length ?? 0;
  const isComplete = currentIndex >= totalProblems;
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

  // Post session results to backend when lesson is complete
  React.useEffect(() => {
    if (!isComplete || sessionPosted || answers.length === 0) return;
    setSessionPosted(true);

    const sessionAnswers = answers.map((a) => ({
      problemId: a.problemId,
      isCorrect: a.correct,
    }));

    fetch('/api/sessions', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ topicId: chapterId, answers: sessionAnswers }),
    })
      .then((res) => {
        if (!res.ok) throw new Error('Session save failed');
        return res.json();
      })
      .then((data) => setSessionResult(data.sessionSummary))
      .catch(() => {
        // Fallback to local calculation if API fails
        setSessionResult(null);
      });
  }, [isComplete, sessionPosted, answers, chapterId]);

  if (!chapter || !lesson) {
    return (
      <main className="lesson-main">
        <div style={{ padding: '2rem' }}>
          <div className="error-banner" role="alert">Lesson not found.</div>
          <button className="lesson-back-btn" onClick={() => navigate(`/study/${chapterId}`)}>
            <ArrowLeft size={16} weight="bold" /> Back to Chapter
          </button>
        </div>
      </main>
    );
  }

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
    setReviewing(false);
    setSessionResult(null);
    setSessionPosted(false);
  }

  function togglePanel(key) {
    setOpenPanel(openPanel === key ? null : key);
  }

  // Summary calculations
  const correctCount = answers.filter((a) => a.correct).length;
  const scorePercent = totalProblems > 0 ? Math.round((correctCount / totalProblems) * 100) : 0;
  const xpEarned = sessionResult?.xpEarned?.total ?? (correctCount * 10 + (correctCount === totalProblems ? 15 : 0));

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

  // Missed questions for review
  const missedAnswers = answers.filter((a) => !a.correct);
  const hasMistakes = missedAnswers.length > 0;

  // ═══ REVIEW SCREEN ═══
  if (isComplete && reviewing) {
    return (
      <main className="lesson-main">
        <div className="lesson-header">
          <div className="lesson-header-left">
            <button className="lesson-back-btn" onClick={() => setReviewing(false)}>
              <ArrowLeft size={16} weight="bold" />
              Back to Summary
            </button>
          </div>
          <div className="lesson-header-center">
            <span className="lesson-breadcrumb">
              <strong>Review Mistakes</strong> — {missedAnswers.length} {missedAnswers.length === 1 ? 'problem' : 'problems'}
            </span>
          </div>
          <div className="lesson-header-right" />
        </div>

        <div className="review-scroll">
          {missedAnswers.map((ans) => {
            const prob = lesson.problems.find((p) => p.id === ans.problemId);
            if (!prob) return null;
            const studentChoice = prob.choices.find((c) => c.id === ans.choiceId);
            const correctChoice = prob.choices.find((c) => c.id === prob.correctAnswerId);
            const correctLabel = String.fromCharCode(65 + prob.choices.findIndex((c) => c.id === prob.correctAnswerId));

            return (
              <div key={prob.id} className="review-card">
                <span className={`lesson-difficulty lesson-difficulty--${prob.difficulty}`}>
                  {prob.difficulty}
                </span>
                <div className="review-statement">
                  <MathText text={prob.statement} />
                </div>

                <ProblemDiagram diagram={prob.diagram} className="review-diagram" />

                <div className="review-answers">
                  <div className="review-answer review-answer--wrong">
                    <XCircle size={16} weight="fill" />
                    <span>Your answer: <MathText text={studentChoice?.text ?? ''} /></span>
                  </div>
                  <div className="review-answer review-answer--correct">
                    <CheckCircle size={16} weight="fill" />
                    <span>Correct ({correctLabel}): <MathText text={correctChoice?.text ?? ''} /></span>
                  </div>
                </div>

                {prob.eli5 && (
                  <div className="review-section">
                    <h4 className="review-section-title">Explain like I'm 5</h4>
                    <p><MathText text={prob.eli5} /></p>
                  </div>
                )}

                {prob.steps && prob.steps.length > 0 && (
                  <div className="review-section">
                    <h4 className="review-section-title">Step-by-Step</h4>
                    <div className="lp-steps">
                      {prob.steps.map((step, si) => (
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
              </div>
            );
          })}

          <div className="review-bottom-actions">
            <button className="btn-primary" onClick={handleRetry}>
              <ArrowsClockwise size={16} weight="bold" />
              Try Again
            </button>
            <button className="btn-secondary" onClick={() => navigate(`/study/${chapterId}`)}>
              <ArrowLeft size={16} weight="bold" />
              Back to Chapter
            </button>
          </div>
        </div>
      </main>
    );
  }

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
            {sessionResult?.streak && (
              <div className="lesson-summary-streak">
                {sessionResult.streak.current} day streak
              </div>
            )}
            {sessionResult?.newBadges?.length > 0 && (
              <div className="lesson-summary-badges">
                {sessionResult.newBadges.map((badge) => (
                  <div key={badge.id} className="lesson-summary-badge">
                    <CheckCircle size={14} weight="fill" />
                    <span>{badge.name}</span>
                  </div>
                ))}
              </div>
            )}
            <div className="lesson-summary-actions">
              {hasMistakes && (
                <button className="btn-primary" onClick={() => setReviewing(true)}>
                  <MagnifyingGlass size={16} weight="bold" />
                  Review Mistakes
                </button>
              )}
              <button className={hasMistakes ? 'btn-secondary' : 'btn-primary'} onClick={handleRetry}>
                <ArrowsClockwise size={16} weight="bold" />
                Try Again
              </button>
              <button className="btn-secondary" onClick={() => navigate(`/study/${chapterId}`)}>
                <ArrowLeft size={16} weight="bold" />
                Back to Chapter
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

            <ProblemDiagram diagram={problem.diagram} />

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
          {lesson.application && (
            <p className="lp-application">{lesson.application}</p>
          )}
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
                      Submit answer to unlock
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
          {Array.isArray(lesson.content) ? (
            <LessonContent blocks={lesson.content} />
          ) : (
            lesson.content && <p className="lp-lesson-content"><MathText text={lesson.content} /></p>
          )}
          {lesson.illustration && <LessonIllustration src={lesson.illustration} alt={lesson.name} />}
        </>
      );

    case 'handbook':
      return <HandbookPanel key={problem.statement?.substring(0, 50)} problem={problem} />;

    case 'eli5':
      return <p><MathText text={problem.eli5} /></p>;

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
              <p><MathText text={trap} /></p>
            </div>
          ))}
        </div>
      );

    default:
      return null;
  }
}
