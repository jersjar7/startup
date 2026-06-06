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
import { DIAGRAM_REGISTRY } from '../components/diagrams';
import '../diagnostic/diagnostic.css';
import './exam.css';

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

function ProblemDiagram({ diagram }) {
  if (!diagram) return null;
  const Comp = DIAGRAM_REGISTRY[diagram.component];
  if (!Comp) return null;
  return <div className="ex-diagram"><Comp {...(diagram.props || {})} /></div>;
}

export function ExamReview({ userName }) {
  const navigate = useNavigate();
  const { attemptId } = useParams();
  useDocumentTitle('Exam Review');
  const [result, setResult] = React.useState(null);
  const [loading, setLoading] = React.useState(true);
  const [wrongOnly, setWrongOnly] = React.useState(false);

  React.useEffect(() => {
    if (!userName) {
      navigate('/');
      return;
    }
    fetch(`/api/exam/attempt/${attemptId}`)
      .then(res => {
        if (!res.ok) throw new Error('Not found');
        return res.json();
      })
      .then(data => {
        setResult(data);
        setLoading(false);
      })
      .catch(() => setLoading(false));
  }, [userName, navigate, attemptId]);

  if (loading) {
    return (
      <main className="drev-main">
        <div className="dx-loading"><p>Loading review...</p></div>
      </main>
    );
  }

  if (!result || !result.questions || result.questions.length === 0) {
    return (
      <main className="drev-main">
        <div className="drev-container">
          <div className="dx-error" role="alert">Review data isn't available for this attempt.</div>
          <button className="btn-secondary" onClick={() => navigate('/exam')}>Back to Exam</button>
        </div>
      </main>
    );
  }

  const all = result.questions;
  const wrongCount = all.filter(q => !q.isCorrect).length;
  const shown = wrongOnly ? all.filter(q => !q.isCorrect) : all;

  // Group the shown questions by chapter, in CHAPTERS order.
  const grouped = {};
  for (const q of shown) {
    if (!grouped[q.chapterId]) grouped[q.chapterId] = [];
    grouped[q.chapterId].push(q);
  }
  const orderedChapters = CHAPTERS.filter(ch => grouped[ch.id]);

  const filterBtn = (active) => (active ? 'btn-primary' : 'btn-secondary');

  return (
    <main className="drev-main">
      <div className="drev-container">
        <div className="drev-header">
          <button className="btn-secondary" onClick={() => navigate(`/exam/results/${attemptId}`)}>
            <ArrowLeft size={16} weight="bold" />
            Back to Results
          </button>
          <h1 className="drev-title">Review Answers</h1>
        </div>

        <div style={{ display: 'flex', gap: 8, marginBottom: 20 }}>
          <button className={filterBtn(!wrongOnly)} onClick={() => setWrongOnly(false)}>
            All ({all.length})
          </button>
          <button className={filterBtn(wrongOnly)} onClick={() => setWrongOnly(true)}>
            Wrong only ({wrongCount})
          </button>
        </div>

        {orderedChapters.length === 0 && (
          <div className="drev-card" style={{ textAlign: 'center' }}>
            <CheckCircle size={20} weight="fill" style={{ color: 'var(--forest)' }} /> Nothing to review here — nice work.
          </div>
        )}

        {orderedChapters.map(ch => (
          <div key={ch.id} className="drev-chapter-group">
            <h3 className="drev-chapter-label">{ch.name}</h3>
            {grouped[ch.id].map((q) => {
              const isCorrect = q.isCorrect;
              const isSkipped = !q.selectedAnswerId;
              // Resolve full problem content (statement/choices/eli5/steps/diagram)
              // from the client pool; fall back to what's stored on the attempt.
              const prob = getProblemById(q.id) || q;
              const choices = prob.choices || q.choices || [];
              const studentChoice = choices.find(c => c.id === q.selectedAnswerId);
              const correctChoice = choices.find(c => c.id === q.correctAnswerId);

              return (
                <div key={q.id} className="drev-card">
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

                  {(prob.statement || q.statement) && (
                    <div className="drev-statement">
                      <MathText text={prob.statement || q.statement} />
                    </div>
                  )}

                  <ProblemDiagram diagram={prob.diagram || q.diagram} />

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

                  {prob.eli5 && (
                    <div className="drev-eli5">
                      <div className="drev-eli5-title">Explain like I'm 5</div>
                      <p><MathText text={prob.eli5} /></p>
                    </div>
                  )}

                  {prob.steps && prob.steps.length > 0 && (
                    <div className="drev-steps">
                      <div className="drev-steps-title">Step-by-Step Solution</div>
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
          </div>
        ))}
      </div>
    </main>
  );
}
