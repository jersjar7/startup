import React from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { ArrowLeft, SignOut, ArrowRight, BookOpen, Lightning } from '@phosphor-icons/react';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import { MathText } from '../components/MathText';
import { LoadingState } from '../components/LoadingState';
import { CHAPTERS } from '../data/chapters';
import { getChapterPracticeProblems } from '../data/chapter-practice/index';
import { getProblemById } from '../data/problemPool';
import { computeFocusAreas } from '../data/readiness';
import { DIAGRAM_REGISTRY } from '../components/diagrams';
import './problems.css';

// States: LOADING -> SESSION -> SUMMARY
// Within SESSION each problem: ANSWERING -> REVIEWED

function fisherYatesShuffle(arr) {
  const copy = [...arr];
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
}

function ProblemDiagram({ diagram }) {
  if (!diagram) return null;
  const Comp = DIAGRAM_REGISTRY[diagram.component];
  if (!Comp) return null;
  return <div className="prob-diagram"><Comp {...(diagram.props || {})} /></div>;
}

export function Problems({ userName, onLogout, reviewMode = false }) {
  const navigate = useNavigate();
  const { topicId } = useParams();

  const [phase, setPhase] = React.useState('LOADING');
  const [problems, setProblems] = React.useState([]);
  const [topicName, setTopicName] = React.useState(reviewMode ? 'Daily Review' : '');
  useDocumentTitle(reviewMode ? 'Daily Review' : topicName || 'Practice');
  const [currentIndex, setCurrentIndex] = React.useState(0);
  const [selectedChoice, setSelectedChoice] = React.useState(null);
  const [reviewed, setReviewed] = React.useState(false);
  const [answers, setAnswers] = React.useState([]);
  const [summary, setSummary] = React.useState(null);
  const [quote, setQuote] = React.useState('');
  const [quoteAuthor, setQuoteAuthor] = React.useState('');
  const [recommendation, setRecommendation] = React.useState(null);

  React.useEffect(() => {
    if (!userName) {
      navigate('/');
      return;
    }

    if (reviewMode) {
      // Review mode: the API returns due problem references (ids + topic);
      // resolve them against the local question pools so review uses the same
      // content the student studied. Drop any id that no longer exists.
      fetch('/api/review?count=5')
        .then((res) => {
          if (!res.ok) throw new Error('Failed to load problems');
          return res.json();
        })
        .then((data) => {
          const refs = data.problems || [];
          const resolved = refs
            .map((ref) => {
              const source = getProblemById(ref.problemId);
              if (!source) return null;
              const problem = normalizePracticeProblem(source);
              // Preserve topic so the review submit can credit the right chapter.
              problem.topicId = ref.topicId || source.chapterId;
              return problem;
            })
            .filter(Boolean);

          if (resolved.length === 0) {
            setPhase('EMPTY');
            return;
          }
          setProblems(resolved);
          setPhase('SESSION');
        })
        .catch(() => setPhase('ERROR'));
    } else {
      // Chapter practice: load from client-side data
      const chapter = CHAPTERS.find((c) => c.id === topicId);
      setTopicName(chapter?.name || topicId);

      const pool = getChapterPracticeProblems(topicId);
      if (pool.length === 0) {
        setPhase('EMPTY_CHAPTER');
        return;
      }

      // Shuffle and pick up to 5, shuffle choices
      const selected = fisherYatesShuffle(pool).slice(0, 5).map(normalizePracticeProblem);
      setProblems(selected);
      setPhase('SESSION');
    }

    // Fetch motivational quote for summary screen
    fetch('https://quote.cs260.click')
      .then((res) => res.json())
      .then((data) => {
        setQuote(data.quote);
        setQuoteAuthor(data.author);
      })
      .catch(() => {
        setQuote('Success is the sum of small efforts repeated day in and day out.');
        setQuoteAuthor('Robert Collier');
      });

    // WebSocket notification
    const protocol = window.location.protocol === 'http:' ? 'ws' : 'wss';
    const ws = new WebSocket(`${protocol}://${window.location.host}/ws`);
    ws.onopen = () => {
      ws.send(JSON.stringify({
        type: 'study',
        from: userName,
        topic: reviewMode ? 'Daily Review' : topicId,
      }));
    };
    return () => ws.close();
  }, [userName, navigate, topicId, reviewMode]);

  // Normalize chapter-practice problem (lesson schema) to internal format
  function normalizePracticeProblem(p) {
    const shuffledChoices = fisherYatesShuffle(p.choices);
    return {
      id: p.id,
      statement: p.statement,
      choices: shuffledChoices.map((c, i) => ({
        id: c.id,
        text: c.text,
        label: String.fromCharCode(65 + i),
      })),
      correctChoiceId: p.correctAnswerId,
      solution: null,
      steps: p.steps || null,
      eli5: p.eli5 || null,
      hint: p.hint || null,
      handbookPage: p.handbookPage || null,
      traps: p.traps || null,
      diagram: p.diagram || null,
    };
  }

  const handleSubmit = () => {
    if (selectedChoice === null) return;
    setReviewed(true);
  };

  const handleNext = () => {
    const problem = problems[currentIndex];
    const isCorrect = selectedChoice === problem.correctChoiceId;
    const answer = { problemId: problem.id, isCorrect };
    if (reviewMode && problem.topicId) answer.topicId = problem.topicId;
    const updatedAnswers = [...answers, answer];
    setAnswers(updatedAnswers);

    if (currentIndex < problems.length - 1) {
      setCurrentIndex(currentIndex + 1);
      setSelectedChoice(null);
      setReviewed(false);
    } else {
      // Submit session
      setPhase('LOADING');
      const submitUrl = reviewMode ? '/api/review' : '/api/sessions';
      const submitBody = reviewMode
        ? { answers: updatedAnswers }
        : { topicId, answers: updatedAnswers };

      fetch(submitUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(submitBody),
      })
        .then((res) => res.json())
        .then((data) => {
          setSummary(data.sessionSummary);
          setPhase('SUMMARY');
        })
        .catch(() => {
          const correct = updatedAnswers.filter((a) => a.isCorrect).length;
          const bonusKey = reviewMode ? 'reviewBonus' : 'sessionBonus';
          const bonusAmount = reviewMode ? 15 : 25;
          setSummary({
            totalProblems: updatedAnswers.length,
            correct,
            incorrect: updatedAnswers.length - correct,
            xpEarned: {
              correct: correct * 10,
              incorrect: (updatedAnswers.length - correct) * 5,
              [bonusKey]: bonusAmount,
              total: correct * 10 + (updatedAnswers.length - correct) * 5 + bonusAmount,
            },
            streak: { current: 0, longest: 0 },
          });
          setPhase('SUMMARY');
        });
    }
  };

  const handleLogout = () => {
    onLogout();
    navigate('/');
  };

  // When a session ends, compute what to study next: clear due reviews first,
  // otherwise point to the highest-leverage chapter (low mastery x exam weight).
  React.useEffect(() => {
    if (phase !== 'SUMMARY') return;
    let cancelled = false;
    Promise.allSettled([
      fetch('/api/review/count').then((r) => (r.ok ? r.json() : { count: 0 })),
      fetch('/api/diagnostic/mastery').then((r) => (r.ok ? r.json() : { chapterMastery: {} })),
    ]).then(([countRes, masteryRes]) => {
      if (cancelled) return;
      const due = countRes.status === 'fulfilled' ? (countRes.value.count || 0) : 0;
      if (!reviewMode && due > 0) {
        setRecommendation({ type: 'review', due });
        return;
      }
      const cm = masteryRes.status === 'fulfilled' ? (masteryRes.value.chapterMastery || {}) : {};
      const masteryByChapterId = {};
      for (const [id, v] of Object.entries(cm)) masteryByChapterId[id] = v.totalMastery || 0;
      const exclude = reviewMode ? [] : [topicId];
      const top = computeFocusAreas(masteryByChapterId, { exclude, limit: 1 })[0];
      if (top) setRecommendation({ type: 'chapter', ch: top.ch, masteryPct: top.masteryPct });
      else if (due > 0) setRecommendation({ type: 'review', due });
      else setRecommendation(null);
    });
    return () => { cancelled = true; };
  }, [phase, reviewMode, topicId]);

  const backPath = reviewMode ? '/dashboard' : `/study/${topicId}`;
  const backLabel = reviewMode ? 'Back to Dashboard' : 'Back to Study';
  const bonusLabel = reviewMode ? 'Review bonus' : 'Session bonus';
  const bonusValue = summary?.xpEarned?.reviewBonus ?? summary?.xpEarned?.sessionBonus ?? 0;

  // --- LOADING ---
  if (phase === 'LOADING') {
    return <LoadingState />;
  }

  // --- ERROR ---
  if (phase === 'ERROR') {
    return (
      <main>
        <div className="error-banner" role="alert">Could not load problems. Please try again.</div>
        <a href="#" className="back-link" onClick={(e) => { e.preventDefault(); navigate(backPath); }}>
          <ArrowLeft weight="bold" size={16} />
          {backLabel}
        </a>
      </main>
    );
  }

  // --- EMPTY (review mode, no problems due) ---
  if (phase === 'EMPTY') {
    return (
      <main>
        <div className="page-header">
          <a href="#" className="back-link" onClick={(e) => { e.preventDefault(); navigate('/dashboard'); }}>
            <ArrowLeft weight="bold" size={16} />
            Back to Dashboard
          </a>
          <h1>Daily Review</h1>
          <button className="logout-btn" onClick={handleLogout}>
            <SignOut weight="bold" size={18} />
            Logout
          </button>
        </div>
        <section className="summary-card">
          <h2>No problems to review right now</h2>
          <p>Complete topic sessions to build your review queue, or check back later.</p>
        </section>
        <div className="summary-actions">
          <button className="btn-primary" onClick={() => navigate('/dashboard')}>
            Back to Dashboard
          </button>
        </div>
      </main>
    );
  }

  // --- EMPTY CHAPTER (no chapter practice problems yet) ---
  if (phase === 'EMPTY_CHAPTER') {
    return (
      <main>
        <div className="page-header">
          <a href="#" className="back-link" onClick={(e) => { e.preventDefault(); navigate(`/study/${topicId}`); }}>
            <ArrowLeft weight="bold" size={16} />
            Back to Study
          </a>
          <h1>{topicName}</h1>
          <button className="logout-btn" onClick={handleLogout}>
            <SignOut weight="bold" size={18} />
            Logout
          </button>
        </div>
        <section className="summary-card">
          <h2>Chapter practice problems coming soon</h2>
          <p>In the meantime, practice individual lessons from the chapter page — each lesson has 3 practice problems.</p>
        </section>
        <div className="summary-actions">
          <button className="btn-primary" onClick={() => navigate(`/study/${topicId}`)}>
            <ArrowLeft weight="bold" size={16} />
            Back to {topicName}
          </button>
        </div>
      </main>
    );
  }

  // --- SUMMARY ---
  if (phase === 'SUMMARY' && summary) {
    const pct = Math.round((summary.correct / summary.totalProblems) * 100);
    return (
      <main>
        <div className="page-header">
          <span />
          <h1>{reviewMode ? 'Review Complete' : 'Session Complete'}</h1>
          <button className="logout-btn" onClick={handleLogout}>
            <SignOut weight="bold" size={18} />
            Logout
          </button>
        </div>

        <section className="summary-card">
          <h2>Score: {summary.correct}/{summary.totalProblems} ({pct}%)</h2>

          <div className="xp-breakdown">
            <div className="xp-row">
              <span>Correct answers ({summary.correct})</span>
              <span>+{summary.xpEarned.correct} XP</span>
            </div>
            <div className="xp-row">
              <span>Attempted ({summary.incorrect} incorrect)</span>
              <span>+{summary.xpEarned.incorrect} XP</span>
            </div>
            <div className="xp-row">
              <span>{bonusLabel}</span>
              <span>+{bonusValue} XP</span>
            </div>
            <div className="xp-row xp-total">
              <span>Total</span>
              <span>+{summary.xpEarned.total} XP</span>
            </div>
          </div>

          <div className="streak-info">
            <p>Current streak: {summary.streak.current} day{summary.streak.current !== 1 ? 's' : ''}</p>
            <p>Longest streak: {summary.streak.longest} day{summary.streak.longest !== 1 ? 's' : ''}</p>
          </div>

          {summary.newBadges && summary.newBadges.length > 0 && (
            <div className="new-badges">
              <h3>New Badges Earned!</h3>
              {summary.newBadges.map((badge) => (
                <div key={badge.id} className="new-badge-item">
                  <span className="new-badge-name">{badge.name}</span>
                  <span className="new-badge-desc">{badge.description}</span>
                </div>
              ))}
            </div>
          )}
        </section>

        {recommendation && (
          <section className="recommend-card">
            <span className="recommend-overline">Recommended next</span>
            {recommendation.type === 'review' ? (
              <>
                <h3 className="recommend-title">Lock in what you've learned</h3>
                <p className="recommend-text">
                  You have {recommendation.due} review{recommendation.due !== 1 ? 's' : ''} due.
                  A quick review session is the highest-value way to strengthen recall.
                </p>
                <button className="btn-primary recommend-btn" onClick={() => navigate('/review')}>
                  Start Daily Review
                  <ArrowRight weight="bold" size={16} />
                </button>
              </>
            ) : (
              <>
                <h3 className="recommend-title">Focus on {recommendation.ch.name}</h3>
                <p className="recommend-text">
                  {recommendation.masteryPct > 0 ? `${recommendation.masteryPct}% mastery` : 'Not started yet'}
                  {' '}— one of your biggest score opportunities on the exam.
                </p>
                <button className="btn-primary recommend-btn" onClick={() => navigate(`/study/${recommendation.ch.id}`)}>
                  Study {recommendation.ch.name}
                  <ArrowRight weight="bold" size={16} />
                </button>
              </>
            )}
          </section>
        )}

        {quote && (
          <section className="quote-card">
            <blockquote>
              <p>"{quote}"</p>
              <cite>- {quoteAuthor}</cite>
            </blockquote>
          </section>
        )}

        <div className="summary-actions">
          <button className="btn-secondary" onClick={() => navigate(backPath)}>
            <ArrowLeft weight="bold" size={16} />
            {backLabel}
          </button>
          <button className="btn-primary" onClick={() => window.location.reload()}>
            {reviewMode ? 'Review Again' : 'Try Again'}
            <ArrowRight weight="bold" size={16} />
          </button>
        </div>
      </main>
    );
  }

  // --- SESSION ---
  const problem = problems[currentIndex];
  if (!problem) return null;

  const isCorrect = selectedChoice === problem.correctChoiceId;
  const correctChoice = problem.choices.find((c) => c.id === problem.correctChoiceId);
  const correctLabel = correctChoice?.label || correctChoice?.id;

  return (
    <main>
      <div className="page-header">
        <a href="#" className="back-link" onClick={(e) => { e.preventDefault(); navigate(backPath); }}>
          <ArrowLeft weight="bold" size={16} />
          {backLabel}
        </a>
        <h1>{topicName}</h1>
        <button className="logout-btn" onClick={handleLogout}>
          <SignOut weight="bold" size={18} />
          Logout
        </button>
      </div>

      <section className="progress-bar-section">
        <div className="progress-bar">
          <div
            className="progress-fill"
            style={{ width: `${((currentIndex + (reviewed ? 1 : 0)) / problems.length) * 100}%` }}
          />
        </div>
        <span className="progress-label">Problem {currentIndex + 1} of {problems.length}</span>
      </section>

      <section className="problem-card">
        <h3>Problem {currentIndex + 1}</h3>
        <p className="problem-question"><MathText text={problem.statement} /></p>

        <ProblemDiagram diagram={problem.diagram} />

        <div className="choices">
          {problem.choices.map((choice, ci) => {
            const label = choice.label || String.fromCharCode(65 + ci);
            let choiceClass = 'choice-btn';
            if (reviewed) {
              if (choice.id === problem.correctChoiceId) {
                choiceClass += ' correct';
              } else if (choice.id === selectedChoice && !isCorrect) {
                choiceClass += ' incorrect';
              } else {
                choiceClass += ' dimmed';
              }
            } else if (choice.id === selectedChoice) {
              choiceClass += ' selected';
            }

            return (
              <button
                key={choice.id}
                className={choiceClass}
                onClick={() => !reviewed && setSelectedChoice(choice.id)}
                disabled={reviewed}
              >
                <span className="choice-label">{label}</span>
                <span><MathText text={choice.text} /></span>
              </button>
            );
          })}
        </div>

        {!reviewed ? (
          <button
            className="btn-primary submit-btn"
            onClick={handleSubmit}
            disabled={selectedChoice === null}
          >
            Submit Answer
          </button>
        ) : (
          <div className="feedback-section">
            <div className={`feedback-banner ${isCorrect ? 'correct' : 'incorrect'}`}>
              {isCorrect ? 'Correct! +10 XP' : `Incorrect — the answer is ${correctLabel}. +5 XP`}
            </div>

            {/* Rich feedback for chapter-practice problems */}
            {problem.eli5 && (
              <div className="solution-box eli5-box">
                <h4><Lightning size={16} weight="bold" /> Quick Explanation</h4>
                <p><MathText text={problem.eli5} /></p>
              </div>
            )}

            {problem.steps && problem.steps.length > 0 && (
              <div className="solution-box steps-box">
                <h4><BookOpen size={16} weight="bold" /> Step-by-Step Solution</h4>
                <ol className="solution-steps">
                  {problem.steps.map((step, i) => (
                    <li key={i}>
                      <MathText text={step.text} />
                      {step.latex && (
                        <div className="step-formula"><MathText text={`$$${step.latex}$$`} /></div>
                      )}
                    </li>
                  ))}
                </ol>
              </div>
            )}

            {problem.handbookPage && (
              <div className="handbook-ref">
                FE Handbook Reference: {problem.handbookPage}
              </div>
            )}

            {/* Fallback for review-mode problems (plain solution text) */}
            {problem.solution && !problem.steps && (
              <div className="solution-box">
                <h4>Solution</h4>
                <p><MathText text={problem.solution} /></p>
              </div>
            )}

            <button className="btn-primary next-btn" onClick={handleNext}>
              {currentIndex < problems.length - 1 ? 'Next Problem' : (reviewMode ? 'Finish Review' : 'Finish Session')}
              <ArrowRight weight="bold" size={16} />
            </button>
          </div>
        )}
      </section>
    </main>
  );
}
