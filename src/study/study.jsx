import React from 'react';
import { useNavigate, useParams } from 'react-router-dom';
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
function SubtopicRow({ sub, index, isExpanded, onToggle, accent }) {
  // Mastery state would come from API — placeholder for now
  const status = 'available'; // 'locked' | 'available' | 'in-progress' | 'mastered'

  const statusIcon = {
    locked: <LockSimple size={16} weight="bold" className="st-status st-status--locked" />,
    available: <Circle size={16} weight="bold" className="st-status st-status--available" />,
    'in-progress': <Lightning size={16} weight="fill" className={`st-status st-status--${accent}`} />,
    mastered: <CheckCircle size={16} weight="fill" className="st-status st-status--mastered" />,
  };

  return (
    <div className={`st-row ${isExpanded ? 'st-row--expanded' : ''}`}>
      <button className="st-row-btn" onClick={onToggle} aria-expanded={isExpanded}>
        <span className="st-num">{String(index + 1).padStart(2, '0')}</span>
        {statusIcon[status]}
        <span className="st-name">{sub.name}</span>
        <span className="st-toggle">
          {isExpanded ? <CaretUp size={16} weight="bold" /> : <CaretDown size={16} weight="bold" />}
        </span>
      </button>

      {isExpanded && (
        <div className="st-expanded">
          <p className="st-application">{sub.application}</p>
          <button className="st-practice-btn" onClick={(e) => e.stopPropagation()}>
            <Lightning size={16} weight="bold" />
            Practice and learn this subtopic
          </button>
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
export function Study({ userName, onLogout }) {
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

  React.useEffect(() => {
    if (!userName) {
      navigate('/');
      return;
    }

    // Fetch topic data from API (for problem count, key concepts, etc.)
    fetch(`/api/topics/${topicId}`)
      .then((res) => {
        if (!res.ok) throw new Error('Topic not found');
        return res.json();
      })
      .then((data) => setTopic(data))
      .catch(() => {}) // OK if API doesn't have it yet — we use static data
      .finally(() => setLoading(false));

    // WebSocket presence notification
    const protocol = window.location.protocol === 'http:' ? 'ws' : 'wss';
    const ws = new WebSocket(`${protocol}://${window.location.host}/ws`);
    ws.onopen = () => {
      ws.send(JSON.stringify({ type: 'study', from: userName, topic: topicId }));
    };
    return () => ws.close();
  }, [userName, navigate, topicId]);

  if (loading) return <LoadingState />;

  if (!chapter || !details) {
    return (
      <main>
        <div className="error-banner">Chapter not found.</div>
        <a href="#" className="back-link" onClick={(e) => { e.preventDefault(); navigate('/dashboard'); }}>
          <ArrowLeft weight="bold" size={16} /> Back to Dashboard
        </a>
      </main>
    );
  }

  const accentClass = `accent--${chapter.accent}`;
  const problemCount = topic?.problemCount ?? 0;

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

          <div className="st-list">
            {details.subtopics.map((sub, i) => (
              <SubtopicRow
                key={sub.id}
                sub={sub}
                index={i}
                accent={chapter.accent}
                isExpanded={expandedSub === sub.id}
                onToggle={() => setExpandedSub(expandedSub === sub.id ? null : sub.id)}
              />
            ))}
          </div>

          {/* ── Practice All Button ── */}
          <div className="study-practice-all">
            <button
              className="btn-primary study-practice-all-btn"
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
