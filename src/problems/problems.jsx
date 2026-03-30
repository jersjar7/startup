import React from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import './problems.css';

// States: LOADING → SESSION → SUMMARY
// Within SESSION each problem: ANSWERING → REVIEWED

export function Problems({ userName, onLogout }) {
  const navigate = useNavigate();
  const { topicId } = useParams();

  const [phase, setPhase] = React.useState('LOADING');
  const [problems, setProblems] = React.useState([]);
  const [topicName, setTopicName] = React.useState('');
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

    fetch(`/api/topics/${topicId}/problems?count=5`)
      .then((res) => {
        if (!res.ok) throw new Error('Failed to load problems');
        return res.json();
      })
      .then((data) => {
        setTopicName(data.topicName);
        setProblems(data.problems);
        setPhase('SESSION');
      })
      .catch(() => navigate(`/study/${topicId}`));

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
      ws.send(JSON.stringify({ type: 'study', from: userName, topic: topicId }));
    };
    return () => ws.close();
  }, [userName, navigate, topicId]);

  const handleSubmit = () => {
    if (selectedChoice === null) return;
    setReviewed(true);
  };

  const handleNext = () => {
    const problem = problems[currentIndex];
    const isCorrect = selectedChoice === problem.correctAnswer;
    const updatedAnswers = [...answers, { problemId: problem.problemId, isCorrect }];
    setAnswers(updatedAnswers);

    if (currentIndex < problems.length - 1) {
      setCurrentIndex(currentIndex + 1);
      setSelectedChoice(null);
      setReviewed(false);
    } else {
      // Submit session
      setPhase('LOADING');
      fetch('/api/sessions', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ topicId, answers: updatedAnswers }),
      })
        .then((res) => res.json())
        .then((data) => {
          setSummary(data.sessionSummary);
          setPhase('SUMMARY');
        })
        .catch(() => {
          // Show summary even if save fails
          const correct = updatedAnswers.filter((a) => a.isCorrect).length;
          setSummary({
            totalProblems: updatedAnswers.length,
            correct,
            incorrect: updatedAnswers.length - correct,
            xpEarned: { correct: correct * 10, incorrect: (updatedAnswers.length - correct) * 5, sessionBonus: 25, total: correct * 10 + (updatedAnswers.length - correct) * 5 + 25 },
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

  // --- LOADING ---
  if (phase === 'LOADING') {
    return <main><p>Loading...</p></main>;
  }

  // --- SUMMARY ---
  if (phase === 'SUMMARY' && summary) {
    const pct = Math.round((summary.correct / summary.totalProblems) * 100);
    return (
      <main>
        <div className="problems-header">
          <span />
          <h1>Session Complete</h1>
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
              <span>Session bonus</span>
              <span>+{summary.xpEarned.sessionBonus} XP</span>
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
          <button className="btn-secondary" onClick={() => navigate(`/study/${topicId}`)}>
            &larr; Back to Study
          </button>
          <button className="btn-primary" onClick={() => window.location.reload()}>
            Try Again
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
        <a href="#" className="back-link" onClick={(e) => { e.preventDefault(); navigate(`/study/${topicId}`); }}>
          &larr; Back to Study
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
              {currentIndex < problems.length - 1 ? 'Next Problem' : 'Finish Session'}
            </button>
          </div>
        )}
      </section>
    </main>
  );
}
