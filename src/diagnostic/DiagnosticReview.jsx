import React from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  ArrowLeft,
  CheckCircle,
  XCircle,
  MinusCircle,
} from '@phosphor-icons/react';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import katex from 'katex';
import { MathText } from '../components/MathText';
import { CHAPTERS } from '../data/chapters';
import { getProblemById } from '../data/problemPool';
import { getLessonById } from '../data/lessons/index';
import './diagnostic.css';

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

export function DiagnosticReview({ userName }) {
  const navigate = useNavigate();
  const { attemptNumber } = useParams();
  useDocumentTitle('Diagnostic Review');
  const [result, setResult] = React.useState(null);
  const [loading, setLoading] = React.useState(true);

  React.useEffect(() => {
    if (!userName) {
      navigate('/');
      return;
    }

    fetch(`/api/diagnostic/results/${attemptNumber}`)
      .then(res => {
        if (!res.ok) throw new Error('Not found');
        return res.json();
      })
      .then(data => {
        setResult(data);
        setLoading(false);
      })
      .catch(() => setLoading(false));
  }, [userName, navigate, attemptNumber]);

  if (loading) {
    return (
      <main className="drev-main">
        <div className="dx-loading"><p>Loading review...</p></div>
      </main>
    );
  }

  if (!result || !result.questions) {
    return (
      <main className="drev-main">
        <div className="drev-container">
          <div className="dx-error" role="alert">Review data not available for this attempt.</div>
          <button className="btn-secondary" onClick={() => navigate('/dashboard')}>
            Back to Dashboard
          </button>
        </div>
      </main>
    );
  }

  // Group questions by chapter
  const grouped = {};
  for (const q of result.questions) {
    if (!grouped[q.chapterId]) grouped[q.chapterId] = [];
    grouped[q.chapterId].push(q);
  }

  // Sort chapters by CHAPTERS order
  const orderedChapters = CHAPTERS.filter(ch => grouped[ch.id]);

  return (
    <main className="drev-main">
      <div className="drev-container">
        <div className="drev-header">
          <button
            className="btn-secondary"
            onClick={() => navigate(`/diagnostic/results/${attemptNumber}`)}
          >
            <ArrowLeft size={16} weight="bold" />
            Back to Results
          </button>
          <h1 className="drev-title">Review Answers</h1>
        </div>

        {orderedChapters.map(ch => (
          <div key={ch.id} className="drev-chapter-group">
            <h3 className="drev-chapter-label">{ch.name}</h3>
            {grouped[ch.id].map((q, qi) => {
              const isCorrect = q.isCorrect;
              const isSkipped = !q.selectedAnswerId;

              // Resolve the full problem (statement/choices/eli5/steps) by id
              // across all pools — diagnostic questions come from the exam bank.
              const examProblem = getProblemById(q.questionId);

              // Fallback: try to build choice text from stored data
              const choices = examProblem?.choices || [];
              const studentChoice = choices.find(c => c.id === q.selectedAnswerId);
              const correctChoice = choices.find(c => c.id === q.correctAnswerId);

              return (
                <div key={q.questionId} className="drev-card">
                  <div className="drev-q-header">
                    <div className={`drev-q-status ${
                      isSkipped ? 'drev-q-status--skipped' :
                      isCorrect ? 'drev-q-status--correct' :
                      'drev-q-status--incorrect'
                    }`}>
                      {isSkipped ? <MinusCircle size={16} weight="fill" /> :
                       isCorrect ? <CheckCircle size={16} weight="fill" /> :
                       <XCircle size={16} weight="fill" />}
                    </div>
                    <span className="drev-q-label">
                      {isSkipped ? 'Skipped' : isCorrect ? 'Correct' : 'Incorrect'}
                    </span>
                  </div>

                  {examProblem && (
                    <div className="drev-statement">
                      <MathText text={examProblem.statement} />
                    </div>
                  )}

                  {choices.length > 0 && (
                    <div className="drev-answers">
                      {!isSkipped && !isCorrect && studentChoice && (
                        <div className="drev-answer drev-answer--wrong">
                          <XCircle size={14} weight="fill" />
                          <span>Your answer: <MathText text={studentChoice.text} /></span>
                        </div>
                      )}
                      {correctChoice && (
                        <div className="drev-answer drev-answer--correct">
                          <CheckCircle size={14} weight="fill" />
                          <span>Correct: <MathText text={correctChoice.text} /></span>
                        </div>
                      )}
                    </div>
                  )}

                  {examProblem?.eli5 && (
                    <div className="drev-eli5">
                      <div className="drev-eli5-title">Explain like I'm 5</div>
                      <p><MathText text={examProblem.eli5} /></p>
                    </div>
                  )}

                  {examProblem?.steps && examProblem.steps.length > 0 && (
                    <div className="drev-steps">
                      <div className="drev-steps-title">Step-by-Step Solution</div>
                      <div className="lp-steps">
                        {examProblem.steps.map((step, si) => (
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
          </div>
        ))}
      </div>
    </main>
  );
}
