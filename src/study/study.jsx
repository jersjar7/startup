import React from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import {
  ArrowLeft,
  ArrowRight,
  CaretDown,
  CaretUp,
  BookOpenText,
  Lightning,
  Warning,
  MathOperations,
  PlayCircle,
  CheckCircle,
  LockSimple,
  Circle,
  Info,
} from '@phosphor-icons/react';
import katex from 'katex';
import { CHAPTERS } from '../data/chapters';
import { CHAPTER_DETAILS } from '../data/chapters/index';
import { LESSONS } from '../data/lessons/index';
import { getChapterPracticeCount } from '../data/chapter-practice/index';
import { LoadingState } from '../components/LoadingState';
import './study.css';

/* ── KaTeX block renderer ── */
function MathBlock({ tex }) {
  const html = React.useMemo(() => {
    try {
      return katex.renderToString(tex, {
        displayMode: true,
        throwOnError: false,
        strict: false,
      });
    } catch {
      return tex;
    }
  }, [tex]);
  return <div className="math-block" dangerouslySetInnerHTML={{ __html: html }} />;
}

/* ── Subtopic row ── */
function SubtopicRow({ sub, index, isExpanded, onToggle, accent, chapterId }) {
  const navigate = useNavigate();
  // Mastery state would come from API — placeholder for now
  const status = 'available'; // 'locked' | 'available' | 'in-progress' | 'mastered'

  const statusIcon = {
    locked: <LockSimple size={16} weight="bold" className="st-status st-status--locked" />,
    available: <Circle size={16} weight="bold" className="st-status st-status--available" />,
    'in-progress': <Lightning size={16} weight="fill" className={`st-status st-status--${accent}`} />,
    mastered: <CheckCircle size={16} weight="fill" className="st-status st-status--mastered" />,
  };

  // Find lessons for this subtopic
  const chapterLessons = LESSONS[chapterId] ?? [];
  const subtopicEntry = chapterLessons.find((entry) => entry.subtopicId === sub.id);
  const lessons = subtopicEntry?.lessons ?? [];

  return (
    <div className={`st-row ${isExpanded ? 'st-row--expanded' : ''}`}>
      <button className="st-row-btn" onClick={onToggle} aria-expanded={isExpanded}>
        <span className="st-num">{String(index + 1).padStart(2, '0')}</span>
        {statusIcon[status]}
        <span className="st-name">{sub.name}</span>
        {/* collapsed rows still tell you how big the chunk is (always rendered —
            the 5-column row grid needs the cell even when empty) */}
        <span className="st-row-meta">
          {lessons.length > 0 ? `${lessons.length} ${lessons.length === 1 ? 'lesson' : 'lessons'}` : ''}
        </span>
        <span className="st-toggle">
          {isExpanded ? <CaretUp size={16} weight="bold" /> : <CaretDown size={16} weight="bold" />}
        </span>
      </button>

      {isExpanded && (
        <div className="st-expanded">
          {lessons.length > 0 ? (
            <div className="st-lesson-list">
              {lessons.map((lesson) => (
                <div key={lesson.id} className="st-lesson-row">
                  <div className="st-lesson-info">
                    <span className="st-lesson-name">{lesson.name}</span>
                    <span className="st-lesson-app">{lesson.application}</span>
                  </div>
                  <button
                    className="st-practice-btn"
                    onClick={(e) => {
                      e.stopPropagation();
                      navigate(`/lesson/${chapterId}/${lesson.id}`);
                    }}
                  >
                    <Lightning size={16} weight="bold" />
                    Practice &amp; learn
                  </button>
                </div>
              ))}
            </div>
          ) : (
            <p className="st-application" style={{ fontStyle: 'italic', color: 'var(--gray-400)' }}>
              Lessons coming soon for this subtopic.
            </p>
          )}
        </div>
      )}
    </div>
  );
}

/* ── Formula card ── */
function FormulaCard({ formula }) {
  return (
    <div className="formula-card">
      <MathBlock tex={formula.latex} />
      <div className="formula-meta">
        <span className="formula-label">{formula.label}</span>
        <span className="formula-page">{formula.page}</span>
      </div>
    </div>
  );
}

/* ══════════════════════════════════════════
   MAIN STUDY PAGE COMPONENT
   ══════════════════════════════════════════ */
export function Study({ userName, onLogout, displayName }) {
  // Live Activity shows this to other users — never the raw email.
  const activityName = displayName || (userName || '').split('@')[0] || 'A student';
  const navigate = useNavigate();
  const { topicId } = useParams();
  const [loading, setLoading] = React.useState(true);
  const [expandedSub, setExpandedSub] = React.useState(null);
  const [formulasOpen, setFormulasOpen] = React.useState(false);
  const [trapsOpen, setTrapsOpen] = React.useState(false);
  const [topic, setTopic] = React.useState(null);

  // Look up chapter from our static data
  const chapter = CHAPTERS.find((c) => c.id === topicId);
  const details = CHAPTER_DETAILS[topicId];
  const Icon = chapter?.icon;
  useDocumentTitle(chapter?.name);

  React.useEffect(() => {
    if (!userName) {
      navigate('/');
      return;
    }

    // The study page renders entirely from bundled content; the legacy
    // /api/topics/<chapter> endpoint has no row for chapter ids (it would
    // always 404), so we don't call it.
    setLoading(false);

    // WebSocket presence notification
    const protocol = window.location.protocol === 'http:' ? 'ws' : 'wss';
    const ws = new WebSocket(`${protocol}://${window.location.host}/ws`);
    ws.onopen = () => {
      ws.send(JSON.stringify({ type: 'study', from: activityName, topic: topicId }));
    };
    return () => ws.close();
  }, [userName, navigate, topicId]);

  if (loading) return <LoadingState />;

  if (!chapter || !details) {
    return (
      <main>
        <div className="error-banner" role="alert">Chapter not found.</div>
        <a href="#" className="back-link" onClick={(e) => { e.preventDefault(); navigate('/dashboard'); }}>
          <ArrowLeft weight="bold" size={16} /> Back to Dashboard
        </a>
      </main>
    );
  }

  const accentClass = `accent--${chapter.accent}`;
  const problemCount = getChapterPracticeCount(topicId);

  return (
    <main className="study-main">
      {/* ── Back link ── */}
      <a href="#" className="back-link study-back" onClick={(e) => { e.preventDefault(); navigate('/dashboard'); }}>
        <ArrowLeft weight="bold" size={16} /> Back to Dashboard
      </a>

      {/* ═══ CHAPTER HEADER ═══ */}
      <header className={`study-header ${accentClass}`}>
        <div className="study-header-left">
          <div className={`study-header-icon icon-bg--${chapter.accent}`}>
            {Icon && <Icon size={28} weight="bold" />}
          </div>
          <div>
            <span className="study-chapter-num">Chapter {chapter.num}</span>
            <h1 className="study-chapter-name">{chapter.name}</h1>
          </div>
        </div>
        <div className="study-header-right">
          <span className={`study-qs-badge badge--${chapter.accent}`}>
            {chapter.qs} exam questions
          </span>
        </div>
      </header>

      <p className="study-context">{details.context}</p>

      {/* ═══ TWO-COLUMN LAYOUT ═══ */}
      <div className="study-grid">

        {/* ── LEFT: Subtopic Progression ── */}
        <div className="study-left">
          <div className="study-section-label">
            <BookOpenText size={16} weight="bold" />
            Subtopics
            <span className="study-section-count">{details.subtopics.length} topics</span>
          </div>

          {/* Guided entry — a rusty returner needs one obvious place to start,
              not a mixed problem session as the only filled CTA. */}
          {(() => {
            const firstEntry = (LESSONS[topicId] ?? []).find((e) => (e.lessons ?? []).length > 0);
            const firstLesson = firstEntry?.lessons?.[0];
            if (!firstLesson) return null;
            return (
              <button
                className="btn-primary study-practice-all-btn"
                style={{ marginBottom: '1rem' }}
                onClick={() => navigate(`/lesson/${topicId}/${firstLesson.id}`)}
              >
                <BookOpenText size={18} weight="bold" />
                {`Start: ${firstLesson.name}`}
                <ArrowRight size={16} weight="bold" />
              </button>
            );
          })()}

          <div className="st-list">
            {details.subtopics.map((sub, i) => (
              <SubtopicRow
                key={sub.id}
                sub={sub}
                index={i}
                accent={chapter.accent}
                chapterId={topicId}
                isExpanded={expandedSub === sub.id}
                onToggle={() => setExpandedSub(expandedSub === sub.id ? null : sub.id)}
              />
            ))}
          </div>

          {/* ── Practice All Button (secondary — the guided lesson is primary) ── */}
          <div className="study-practice-all">
            <button
              className="btn-secondary study-practice-all-btn"
              onClick={() => navigate(`/problems/${topicId}`)}
              disabled={problemCount === 0}
            >
              <Lightning size={18} weight="bold" />
              {problemCount > 0
                ? `Practice All ${chapter.name} Problems`
                : 'Problems Coming Soon'
              }
              {problemCount > 0 && <ArrowRight size={16} weight="bold" />}
            </button>
            {problemCount > 0 && (
              <span className="study-practice-note">
                Mixed session across all subtopics — weighted by your weakest areas
              </span>
            )}
          </div>
        </div>

        {/* ── RIGHT: Sidebar ── */}
        <div className="study-sidebar">

          {/* ── Exam tips ── */}
          <div className="exam-tips">
            <Info size={16} weight="fill" className="exam-tips-icon" />
            <p>
              <strong>Exam day:</strong> Most questions here test one formula or method. Some are purely conceptual. Know the topic and where to find it in the Handbook, and you can solve it.
            </p>
          </div>

          {/* ── Formula Quick-Reference ── */}
          {details.formulas.length > 0 && (
            <div className="sidebar-section formulas-section">
              <button className="sidebar-section-toggle" onClick={() => setFormulasOpen(!formulasOpen)}>
                <MathOperations size={18} weight="bold" />
                <span>Key Formulas</span>
                <span className="sidebar-toggle-icon">
                  {formulasOpen ? <CaretUp size={14} weight="bold" /> : <CaretDown size={14} weight="bold" />}
                </span>
              </button>
              {formulasOpen && (
                <div className="formulas-grid">
                  <p className="formulas-hint">You'll have the FE Handbook during the exam — practice finding these quickly.</p>
                  {details.formulas.map((f, i) => (
                    <FormulaCard key={i} formula={f} />
                  ))}
                </div>
              )}
            </div>
          )}

          {/* ── Common Traps ── */}
          {details.traps.length > 0 && (
            <div className="sidebar-section traps-section">
              <button className="sidebar-section-toggle" onClick={() => setTrapsOpen(!trapsOpen)}>
                <Warning size={18} weight="bold" />
                <span>Common Traps</span>
                <span className="sidebar-section-count">{details.traps.length}</span>
                <span className="sidebar-toggle-icon">
                  {trapsOpen ? <CaretUp size={14} weight="bold" /> : <CaretDown size={14} weight="bold" />}
                </span>
              </button>
              {trapsOpen && (
                <div className="traps-list">
                  {details.traps.map((trap, i) => (
                    <div key={i} className="trap-item">
                      <Warning size={14} weight="fill" className="trap-icon" />
                      <p>{trap}</p>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

          {/* ── Video Resource ── */}
          {topic?.videoUrl && (
            <div className="sidebar-section video-sidebar">
              <a
                href={topic.videoUrl.replace('/embed/', '/watch?v=')}
                target="_blank"
                rel="noopener noreferrer"
                className="video-sidebar-link"
              >
                <PlayCircle size={20} weight="fill" />
                Watch Video Tutorial
              </a>
            </div>
          )}
        </div>
      </div>
    </main>
  );
}
