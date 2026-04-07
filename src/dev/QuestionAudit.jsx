import React from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { CHAPTERS } from '../data/chapters';
import { LESSONS } from '../data/lessons/index';
import { MathText } from '../components/MathText';
import { DIAGRAM_REGISTRY } from '../components/diagrams';
import { ArrowLeft, ArrowRight, Image, WarningCircle } from '@phosphor-icons/react';

function ProblemDiagram({ diagram }) {
  if (!diagram) return null;
  const Comp = DIAGRAM_REGISTRY[diagram.component];
  if (!Comp) return <div style={{ color: 'var(--error)', fontSize: '0.8rem' }}>Missing: {diagram.component}</div>;
  return (
    <div style={{ margin: '0.75rem 0', maxWidth: 400 }}>
      <Comp {...(diagram.props || {})} />
    </div>
  );
}

function QuestionCard({ q, index, pool }) {
  const hasDiagram = !!q.diagram;
  return (
    <div style={{
      background: 'white',
      borderRadius: 10,
      boxShadow: '0 1px 3px rgba(44,44,44,0.04), 0 4px 16px rgba(44,44,44,0.06)',
      padding: '1.25rem',
      borderLeft: `4px solid ${pool === 'exam' ? 'var(--ember)' : 'var(--forest)'}`,
    }}>
      {/* Header row */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.5rem' }}>
        <div style={{ display: 'flex', gap: '0.5rem', alignItems: 'center' }}>
          <span style={{
            fontFamily: 'var(--font-mono)',
            fontSize: '0.7rem',
            fontWeight: 600,
            padding: '2px 8px',
            borderRadius: 4,
            background: pool === 'exam' ? 'var(--ember-bg)' : 'var(--forest-bg)',
            color: pool === 'exam' ? 'var(--ember)' : 'var(--forest)',
          }}>
            {pool === 'exam' ? 'EXAM' : 'PRACTICE'}
          </span>
          <span style={{ fontFamily: 'var(--font-mono)', fontSize: '0.7rem', color: 'var(--gray-400)' }}>
            #{index + 1}
          </span>
          <span style={{ fontFamily: 'var(--font-mono)', fontSize: '0.7rem', color: 'var(--gray-400)' }}>
            {q.id}
          </span>
          {q.type && (
            <span style={{
              fontFamily: 'var(--font-mono)',
              fontSize: '0.65rem',
              padding: '1px 6px',
              borderRadius: 3,
              background: 'var(--cream-dark)',
              color: 'var(--charcoal)',
            }}>
              {q.type}
            </span>
          )}
        </div>

        {hasDiagram ? (
          <span style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: '0.7rem', color: 'var(--forest)', fontWeight: 600 }}>
            <Image size={14} weight="bold" />
            {q.diagram.component}
          </span>
        ) : (
          <span style={{ fontSize: '0.7rem', color: 'var(--gray-300)' }}>no diagram</span>
        )}
      </div>

      {/* Statement */}
      <div style={{ fontSize: '0.9rem', lineHeight: 1.6, marginBottom: '0.75rem', color: 'var(--charcoal)' }}>
        <MathText text={q.statement} />
      </div>

      {/* Diagram */}
      <ProblemDiagram diagram={q.diagram} />

      {/* Choices */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '0.35rem' }}>
        {q.choices.map((c, ci) => {
          const label = String.fromCharCode(65 + ci);
          const isCorrect = c.id === q.correctAnswerId;
          return (
            <div key={c.id} style={{
              display: 'flex',
              alignItems: 'center',
              gap: '0.5rem',
              padding: '0.4rem 0.6rem',
              borderRadius: 6,
              fontSize: '0.85rem',
              background: isCorrect ? 'var(--forest-bg)' : 'transparent',
              border: isCorrect ? '1px solid var(--forest)' : '1px solid var(--gray-100)',
            }}>
              <span style={{
                fontWeight: 600,
                fontSize: '0.75rem',
                fontFamily: 'var(--font-mono)',
                color: isCorrect ? 'var(--forest)' : 'var(--gray-400)',
                minWidth: 18,
              }}>
                {label}
              </span>
              <MathText text={c.text} />
            </div>
          );
        })}
      </div>
    </div>
  );
}

export function QuestionAudit() {
  const { chapterId } = useParams();
  const navigate = useNavigate();

  const chapter = CHAPTERS.find(c => c.id === chapterId);
  const subtopics = LESSONS[chapterId];

  if (!chapter || !subtopics) {
    return (
      <main style={{ padding: '2rem', maxWidth: 1100, margin: '0 auto' }}>
        <h1 style={{ fontFamily: 'var(--font-heading)', color: 'var(--charcoal)' }}>Chapter not found</h1>
        <p>Valid chapters:</p>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '0.25rem', marginTop: '0.5rem' }}>
          {CHAPTERS.map(c => (
            <button key={c.id} onClick={() => navigate(`/dev/audit/${c.id}`)} style={{
              background: 'none', border: 'none', cursor: 'pointer', textAlign: 'left',
              fontFamily: 'var(--font-body)', fontSize: '0.9rem', color: 'var(--ember)', padding: '0.25rem 0',
            }}>
              Ch{c.num}: {c.name} ({c.id})
            </button>
          ))}
        </div>
      </main>
    );
  }

  // Build a flat list of all problems grouped by lesson
  const lessonData = [];
  let totalPractice = 0;
  let totalExam = 0;
  let practiceWithDiagram = 0;
  let examWithDiagram = 0;

  for (const subtopic of subtopics) {
    for (const lesson of subtopic.lessons) {
      const practice = lesson.problems || [];
      const exam = lesson.examProblems || [];
      totalPractice += practice.length;
      totalExam += exam.length;
      practiceWithDiagram += practice.filter(p => !!p.diagram).length;
      examWithDiagram += exam.filter(p => !!p.diagram).length;
      lessonData.push({ subtopicId: subtopic.subtopicId, lesson, practice, exam });
    }
  }

  // Chapter navigation
  const chapterIdx = CHAPTERS.findIndex(c => c.id === chapterId);
  const prevChapter = chapterIdx > 0 ? CHAPTERS[chapterIdx - 1] : null;
  const nextChapter = chapterIdx < CHAPTERS.length - 1 ? CHAPTERS[chapterIdx + 1] : null;

  return (
    <main style={{ padding: '2rem', maxWidth: 1100, margin: '0 auto', fontFamily: 'var(--font-body)' }}>
      {/* Header */}
      <div style={{ marginBottom: '1.5rem' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.5rem' }}>
          <button onClick={() => navigate('/dev/audit')} style={{
            background: 'none', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 4,
            fontFamily: 'var(--font-body)', fontSize: '0.85rem', color: 'var(--ember)',
          }}>
            <ArrowLeft size={14} weight="bold" /> All Chapters
          </button>

          <div style={{ display: 'flex', gap: '0.75rem' }}>
            {prevChapter && (
              <button onClick={() => navigate(`/dev/audit/${prevChapter.id}`)} style={{
                background: 'none', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 4,
                fontFamily: 'var(--font-body)', fontSize: '0.8rem', color: 'var(--gray-400)',
              }}>
                <ArrowLeft size={12} weight="bold" /> Ch{prevChapter.num}
              </button>
            )}
            {nextChapter && (
              <button onClick={() => navigate(`/dev/audit/${nextChapter.id}`)} style={{
                background: 'none', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 4,
                fontFamily: 'var(--font-body)', fontSize: '0.8rem', color: 'var(--gray-400)',
              }}>
                Ch{nextChapter.num} <ArrowRight size={12} weight="bold" />
              </button>
            )}
          </div>
        </div>

        <h1 style={{ fontFamily: 'var(--font-heading)', fontSize: '1.5rem', fontWeight: 700, color: 'var(--charcoal)', margin: 0 }}>
          Ch{chapter.num}: {chapter.name}
        </h1>
        <p style={{ fontSize: '0.85rem', color: 'var(--gray-500)', margin: '0.25rem 0 0' }}>
          Question Audit — {lessonData.length} lessons
        </p>
      </div>

      {/* Stats bar */}
      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(4, 1fr)',
        gap: '1rem',
        marginBottom: '2rem',
      }}>
        <div style={{ background: 'white', borderRadius: 10, padding: '1rem', textAlign: 'center', boxShadow: '0 1px 3px rgba(44,44,44,0.04)' }}>
          <div style={{ fontFamily: 'var(--font-mono)', fontSize: '1.5rem', fontWeight: 700, color: 'var(--forest)' }}>{totalPractice}</div>
          <div style={{ fontSize: '0.75rem', color: 'var(--gray-400)' }}>Practice Qs</div>
          <div style={{ fontSize: '0.7rem', color: practiceWithDiagram > 0 ? 'var(--forest)' : 'var(--gray-300)', marginTop: 2 }}>
            {practiceWithDiagram} with diagrams
          </div>
        </div>
        <div style={{ background: 'white', borderRadius: 10, padding: '1rem', textAlign: 'center', boxShadow: '0 1px 3px rgba(44,44,44,0.04)' }}>
          <div style={{ fontFamily: 'var(--font-mono)', fontSize: '1.5rem', fontWeight: 700, color: 'var(--ember)' }}>{totalExam}</div>
          <div style={{ fontSize: '0.75rem', color: 'var(--gray-400)' }}>Exam Qs</div>
          <div style={{ fontSize: '0.7rem', color: examWithDiagram > 0 ? 'var(--forest)' : 'var(--error)', marginTop: 2 }}>
            {examWithDiagram} with diagrams
          </div>
        </div>
        <div style={{ background: 'white', borderRadius: 10, padding: '1rem', textAlign: 'center', boxShadow: '0 1px 3px rgba(44,44,44,0.04)' }}>
          <div style={{ fontFamily: 'var(--font-mono)', fontSize: '1.5rem', fontWeight: 700, color: 'var(--charcoal)' }}>{totalPractice + totalExam}</div>
          <div style={{ fontSize: '0.75rem', color: 'var(--gray-400)' }}>Total</div>
        </div>
        <div style={{ background: 'white', borderRadius: 10, padding: '1rem', textAlign: 'center', boxShadow: '0 1px 3px rgba(44,44,44,0.04)' }}>
          <div style={{ fontFamily: 'var(--font-mono)', fontSize: '1.5rem', fontWeight: 700, color: (practiceWithDiagram + examWithDiagram) > 0 ? 'var(--forest)' : 'var(--error)' }}>
            {practiceWithDiagram + examWithDiagram}
          </div>
          <div style={{ fontSize: '0.75rem', color: 'var(--gray-400)' }}>Diagrams</div>
        </div>
      </div>

      {/* Lessons */}
      {lessonData.map(({ subtopicId, lesson, practice, exam }) => (
        <div key={lesson.id} style={{ marginBottom: '2.5rem' }}>
          <div style={{
            borderBottom: '2px solid var(--gray-100)',
            paddingBottom: '0.5rem',
            marginBottom: '1rem',
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <h2 style={{ fontFamily: 'var(--font-heading)', fontSize: '1.1rem', fontWeight: 600, color: 'var(--charcoal)', margin: 0 }}>
                {lesson.name}
              </h2>
              <span style={{ fontFamily: 'var(--font-mono)', fontSize: '0.65rem', color: 'var(--gray-300)' }}>
                {subtopicId} / {lesson.id}
              </span>
            </div>
            <div style={{ display: 'flex', gap: '1rem', marginTop: '0.25rem', fontSize: '0.75rem', color: 'var(--gray-400)' }}>
              <span>{practice.length} practice</span>
              <span>{exam.length} exam</span>
              <span>{practice.filter(p => !!p.diagram).length + exam.filter(p => !!p.diagram).length} diagrams</span>
            </div>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            {practice.map((q, i) => (
              <QuestionCard key={q.id} q={q} index={i} pool="practice" />
            ))}
            {exam.map((q, i) => (
              <QuestionCard key={q.id} q={q} index={i} pool="exam" />
            ))}
          </div>
        </div>
      ))}
    </main>
  );
}

/** Index page listing all chapters */
export function QuestionAuditIndex() {
  const navigate = useNavigate();

  // Calculate stats for each chapter
  const chapterStats = CHAPTERS.map(ch => {
    const subtopics = LESSONS[ch.id];
    if (!subtopics) return { ...ch, practice: 0, exam: 0, diagrams: 0 };
    let practice = 0, exam = 0, diagrams = 0;
    for (const st of subtopics) {
      for (const l of st.lessons) {
        const p = l.problems || [];
        const e = l.examProblems || [];
        practice += p.length;
        exam += e.length;
        diagrams += p.filter(q => !!q.diagram).length + e.filter(q => !!q.diagram).length;
      }
    }
    return { ...ch, practice, exam, diagrams };
  });

  const totals = chapterStats.reduce((acc, c) => ({
    practice: acc.practice + c.practice,
    exam: acc.exam + c.exam,
    diagrams: acc.diagrams + c.diagrams,
  }), { practice: 0, exam: 0, diagrams: 0 });

  return (
    <main style={{ padding: '2rem', maxWidth: 900, margin: '0 auto', fontFamily: 'var(--font-body)' }}>
      <h1 style={{ fontFamily: 'var(--font-heading)', fontSize: '1.5rem', fontWeight: 700, color: 'var(--charcoal)', marginBottom: '0.25rem' }}>
        Question Audit
      </h1>
      <p style={{ fontSize: '0.85rem', color: 'var(--gray-500)', marginBottom: '1.5rem' }}>
        {totals.practice} practice + {totals.exam} exam = {totals.practice + totals.exam} total questions | {totals.diagrams} with diagrams
      </p>

      <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
        {chapterStats.map(ch => (
          <button
            key={ch.id}
            onClick={() => navigate(`/dev/audit/${ch.id}`)}
            style={{
              display: 'grid',
              gridTemplateColumns: '40px 1fr 80px 80px 80px',
              alignItems: 'center',
              gap: '0.5rem',
              padding: '0.75rem 1rem',
              background: 'white',
              border: 'none',
              borderRadius: 8,
              cursor: 'pointer',
              boxShadow: '0 1px 3px rgba(44,44,44,0.04)',
              textAlign: 'left',
              fontFamily: 'var(--font-body)',
            }}
          >
            <span style={{ fontFamily: 'var(--font-mono)', fontSize: '0.8rem', fontWeight: 600, color: 'var(--gray-400)' }}>
              Ch{ch.num}
            </span>
            <span style={{ fontSize: '0.9rem', fontWeight: 500, color: 'var(--charcoal)' }}>
              {ch.name}
            </span>
            <span style={{ fontFamily: 'var(--font-mono)', fontSize: '0.8rem', color: 'var(--forest)', textAlign: 'center' }}>
              {ch.practice}p
            </span>
            <span style={{ fontFamily: 'var(--font-mono)', fontSize: '0.8rem', color: 'var(--ember)', textAlign: 'center' }}>
              {ch.exam}e
            </span>
            <span style={{
              fontFamily: 'var(--font-mono)', fontSize: '0.8rem', textAlign: 'center',
              color: ch.diagrams > 0 ? 'var(--forest)' : 'var(--gray-300)',
              display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 4,
            }}>
              {ch.diagrams > 0 ? <Image size={12} weight="bold" /> : <WarningCircle size={12} />}
              {ch.diagrams}
            </span>
          </button>
        ))}
      </div>
    </main>
  );
}
