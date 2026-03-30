import React from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import './problems.css';

// States: LOADING → SESSION → SUMMARY
// Within SESSION each problem: ANSWERING → REVIEWED

export function Problems({ userName, onLogout, reviewMode = false }) {
  const navigate = useNavigate();
  const { topicId } = useParams();

  const [phase, setPhase] = React.useState('LOADING');
  const [problems, setProblems] = React.useState([]);
  const [topicName, setTopicName] = React.useState(reviewMode ? 'Daily Review' : '');
  const [currentIndex, setCurrentIndex] = React.useState(0);
  const [selectedChoice, setSelectedChoice] = React.useState(null);
  const [reviewed, setReviewed] = React.useState(false);
  const [answers, setAnswers] = React.useState([]);
  const [summary, setSummary] = React.useState(null);
  const [quote, setQuote] = React.useState('');
  const [quoteAuthor, setQuoteAuthor] = React.useState('');

  React.useEffect(() => {
    if (!userName) {
      navigate('/');
      return;
    }

    const fetchUrl = reviewMode
      ? '/api/review?count=5'
      : `/api/topics/${topicId}/problems?count=5`;

    fetch(fetchUrl)
      .then((res) => {
        if (!res.ok) throw new Error('Failed to load problems');
        return res.json();
      })
      .then((data) => {
        const loadedProblems = reviewMode ? data.problems : data.problems;
        if (!loadedProblems || loadedProblems.length === 0) {
          if (reviewMode) {
            // No review problems available
            setPhase('EMPTY');
          } else {
            navigate(`/study/${topicId}`);
          }
          return;
        }
        if (!reviewMode) setTopicName(data.topicName);
        setProblems(loadedProblems);
        setPhase('SESSION');
      })
      .catch(() => navigate(reviewMode ? '/dashboard' : `/study/${topicId}`));

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

  const handleSubmit = () => {
    if (selectedChoice === null) return;
    setReviewed(true);
  };

  const handleNext = () => {
    const problem = problems[currentIndex];
    const isCorrect = selectedChoice === problem.correctAnswer;
    const answer = { problemId: problem.problemId, isCorrect };
    if (reviewMode) answer.topicId = problem.topicId;
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

  const backPath = reviewMode ? '/dashboard' : `/study/${topicId}`;
  const backLabel = reviewMode ? 'Back to Dashboard' : 'Back to Study';
  const bonusLabel = reviewMode ? 'Review bonus' : 'Session bonus';
  const bonusValue = summary?.xpEarned?.reviewBonus ?? summary?.xpEarned?.sessionBonus ?? 0;

  // --- LOADING ---
  if (phase === 'LOADING') {
    return <main><p>Loading...</p></main>;
  }

  // --- EMPTY (review mode, no problems due) ---
  if (phase === 'EMPTY') {
    return (
      <main>
        <div className="problems-header">
          <a href="#" className="back-link" onClick={(e) => { e.preventDefault(); navigate('/dashboard'); }}>
            &larr; Back to Dashboard
          </a>
          <h1>Daily Review</h1>
          <button className="logout-btn" onClick={handleLogout}>Logout</button>
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

  // --- SUMMARY ---
  if (phase === 'SUMMARY' && summary) {
    const pct = Math.round((summary.correct / summary.totalProblems) * 100);
    return (
      <main>
        <div className="problems-header">
          <span />
          <h1>{reviewMode ? 'Review Complete' : 'Session Complete'}</h1>
          <button className="logout-btn" onClick={handleLogout}>Logout</button>
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
        </section>

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
            &larr; {backLabel}
          </button>
          <button className="btn-primary" onClick={() => window.location.reload()}>
            {reviewMode ? 'Review Again' : 'Try Again'}
          </button>
        </div>
      </main>
    );
  }

  // --- SESSION ---
  const problem = problems[currentIndex];
  if (!problem) return null;

  const isCorrect = selectedChoice === problem.correctAnswer;

  return (
    <main>
      <div className="problems-header">
        <a href="#" className="back-link" onClick={(e) => { e.preventDefault(); navigate(backPath); }}>
          &larr; {backLabel}
        </a>
        <h1>{topicName}</h1>
        <button className="logout-btn" onClick={handleLogout}>Logout</button>
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
        <h3>Problem {problem.problemNumber}</h3>
        <p className="problem-question">{problem.question}</p>

        <div className="choices">
          {problem.choices.map((choice) => {
            let choiceClass = 'choice-btn';
            if (reviewed) {
              if (choice.label === problem.correctAnswer) {
                choiceClass += ' correct';
              } else if (choice.label === selectedChoice && !isCorrect) {
                choiceClass += ' incorrect';
              } else {
                choiceClass += ' dimmed';
              }
            } else if (choice.label === selectedChoice) {
              choiceClass += ' selected';
            }

            return (
              <button
                key={choice.label}
                className={choiceClass}
                onClick={() => !reviewed && setSelectedChoice(choice.label)}
                disabled={reviewed}
              >
                <span className="choice-label">{choice.label}</span>
                <span>{choice.text}</span>
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
              {isCorrect ? 'Correct! +10 XP' : `Incorrect — the answer is ${problem.correctAnswer}. +5 XP`}
            </div>
            <div className="solution-box">
              <h4>Solution</h4>
              <p>{problem.solution}</p>
            </div>
            <button className="btn-primary next-btn" onClick={handleNext}>
              {currentIndex < problems.length - 1 ? 'Next Problem' : (reviewMode ? 'Finish Review' : 'Finish Session')}
            </button>
          </div>
        )}
      </section>
    </main>
  );
}
