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
/* Per-lesson progress marker. Five states over three brand colours, no red —
   see docs/progress-markers.md.

   `untouched` renders an INVISIBLE circle rather than nothing, so lesson names
   stay aligned whether or not a lesson has been started.

   Colour is never the only carrier: every visible state also has an aria-label
   and a tooltip, and `attempted` is hollow rather than filled, so the states
   are still distinguishable without seeing hue. */
const LESSON_MARKER = {
  untouched:     { cls: 'st-lm--untouched',   label: null },
  attempted:     { cls: 'st-lm--attempted',   label: 'Started, no exercises correct yet' },
  'one-correct': { cls: 'st-lm--one',         label: '1 of 3 exercises correct' },
  'two-correct': { cls: 'st-lm--two',         label: '2 of 3 exercises correct' },
  complete:      { cls: 'st-lm--complete',    label: 'All 3 exercises correct' },
};

function LessonMarker({ progress }) {
  // `undefined` means progress has not loaded (or failed to). That is NOT the
  // same as "untouched", and must never be drawn as though the user has done
  // nothing — showing a blank marker for unknown data is exactly the misleading
  // signal this feature exists to remove.
  const [open, setOpen] = React.useState(false);
  const state = progress?.state;
  const spec = LESSON_MARKER[state] || LESSON_MARKER.untouched;

  // Untouched keeps its space so lesson names stay aligned, but there is nothing
  // to explain and nothing to press.
  if (!spec.label) {
    return (
      <span className="st-lm-wrap">
        <span className="st-lm st-lm--untouched" aria-hidden="true" />
      </span>
    );
  }

  // A real button, not a span with a `title`: the native tooltip only appears on
  // hover, so on a touch screen it never appears at all.
  //
  // Hover and focus are handled in CSS; a tap only ever OPENS.
  // Driving both from one state made them fight each other. Hovering opened the
  // bubble, so the click that followed toggled it shut; and once the click gave
  // the button focus, :focus-within kept it visible no matter what the state
  // said. Tapping opens, moving away (blur) closes, Escape blurs. Predictable.
  //
  // The bubble is aria-hidden: it repeats the button's own aria-label, so
  // exposing both would just make a screen reader say it twice.
  return (
    <span className={`st-lm-wrap ${open ? 'st-lm-wrap--open' : ''}`}>
      <button
        type="button"
        className={`st-lm ${spec.cls}`}
        aria-label={spec.label}
        aria-expanded={open}
        onClick={(e) => { e.stopPropagation(); setOpen(true); }}
        onBlur={() => setOpen(false)}
        onKeyDown={(e) => { if (e.key === 'Escape') e.currentTarget.blur(); }}
      />
      <span className="st-lm-bubble" role="tooltip" aria-hidden="true">{spec.label}</span>
    </span>
  );
}

function SubtopicRow({ sub, index, isExpanded, onToggle, accent, chapterId, lessonProgress, subtopicProgress }) {
  const navigate = useNavigate();
  // Find lessons for this subtopic
  const chapterLessons = LESSONS[chapterId] ?? [];
  const subtopicEntry = chapterLessons.find((entry) => entry.subtopicId === sub.id);
  const lessons = subtopicEntry?.lessons ?? [];

  // The collapsed row counts EXERCISES, not whole lessons. Counting lessons made
  // a subtopic with real partial work report "0 of 3" while the dots inside it
  // showed otherwise, and this row is the only progress signal visible before
  // anyone expands anything. See docs/progress-markers.md.
  const total = subtopicProgress?.exercisesTotal ?? 0;
  const done = subtopicProgress?.exercisesCorrect ?? 0;

  return (
    <div className={`st-row ${isExpanded ? 'st-row--expanded' : ''}`}>
      <button className="st-row-btn" onClick={onToggle} aria-expanded={isExpanded}>
        <span className="st-num">{String(index + 1).padStart(2, '0')}</span>
        <span className="st-name">{sub.name}</span>
        {/* Collapsed rows still tell you how big the chunk is, and once progress
            is known they say how much of it is DONE — the row is collapsed by
            default, so this is the only progress signal visible without opening
            it. Falls back to the plain count while progress is unknown, because
            "0 of 6" would be a claim we cannot yet make.
            (Always rendered — the 4-column row grid needs the cell even when
            empty.) */}
        <span className={`st-row-meta ${subtopicProgress && done === total && total > 0 ? 'st-row-meta--done' : ''}`}>
          {subtopicProgress
            ? `${done} of ${total} exercises`
            : lessons.length > 0
              ? `${lessons.length} ${lessons.length === 1 ? 'lesson' : 'lessons'}`
              : ''}
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
                  <LessonMarker progress={lessonProgress?.[lesson.id]} />
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
  // Progress markers. `progress` stays null until it loads, and progressFailed
  // records a real failure so the page can say the markers are unavailable
  // instead of silently drawing every lesson as untouched.
  const [progress, setProgress] = React.useState(null);
  const [progressFailed, setProgressFailed] = React.useState(false);

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

    // The chapter STRUCTURE still renders entirely from bundled content; the
    // legacy /api/topics/<chapter> endpoint has no row for chapter ids (it would
    // always 404), so we don't call it.
    setLoading(false);

    // Progress markers are fetched separately and never block the page. The
    // content is already in the bundle, so a slow or failed progress call must
    // not stop somebody reading a chapter.
    let cancelled = false;
    setProgress(null);
    setProgressFailed(false);
    fetch(`/api/progress/chapter/${topicId}`)
      .then((r) => (r.ok ? r.json() : Promise.reject(new Error(String(r.status)))))
      .then((d) => { if (!cancelled) setProgress(d); })
      .catch(() => { if (!cancelled) setProgressFailed(true); });

    // WebSocket presence notification
    const protocol = window.location.protocol === 'http:' ? 'ws' : 'wss';
    const ws = new WebSocket(`${protocol}://${window.location.host}/ws`);
    ws.onopen = () => {
      ws.send(JSON.stringify({ type: 'study', from: activityName, topic: topicId }));
    };
    return () => { cancelled = true; ws.close(); };
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
            <span className="study-section-count">{details.subtopics.length} subtopics</span>
          </div>

          {progressFailed && (
            <p className="st-progress-note">
              Progress markers are unavailable right now. Your work is saved — this is only the display.
            </p>
          )}

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
                lessonProgress={progress?.lessons}
                subtopicProgress={progress?.subtopics?.[sub.id]}
              />
            ))}
          </div>

          {/* ── Chapter practice (secondary — the guided lesson is primary) ──
              Its own row with a PLAIN FRACTION and no marker. The five-state dot
              is calibrated to a lesson's 3 exercises; practice sets run 11-29,
              so the same colours would mean "3 correct" on a lesson and "29
              correct" one row below. See docs/progress-markers.md. */}
          {(() => {
            const pr = progress?.practice;
            const allDone = pr && pr.total > 0 && pr.correct >= pr.total;
            return (
              <div className="study-practice-all">
                {pr && pr.total > 0 && (
                  <div className={`study-practice-row ${allDone ? 'study-practice-row--done' : ''}`}>
                    <span className="study-practice-label">Chapter practice</span>
                    <span className="study-practice-count">{`${pr.correct} of ${pr.total} problems`}</span>
                  </div>
                )}
                <button
                  className={`btn-secondary study-practice-all-btn ${allDone ? 'study-practice-all-btn--done' : ''}`}
                  onClick={() => navigate(`/problems/${topicId}`)}
                  disabled={problemCount === 0}
                >
                  <Lightning size={18} weight="bold" />
                  {problemCount === 0
                    ? 'Problems Coming Soon'
                    : allDone
                      ? `Practice ${chapter.name} again`
                      : `Practice All ${chapter.name} Problems`}
                  {problemCount > 0 && <ArrowRight size={16} weight="bold" />}
                </button>
                {problemCount > 0 && (
                  <span className="study-practice-note">
                    {allDone
                      // "Weighted by your weakest areas" is not true when there
                      // are none left, so stop claiming it.
                      ? 'You have answered every practice problem here correctly. Run it again any time.'
                      : 'Mixed session across all subtopics — weighted by your weakest areas'}
                  </span>
                )}
              </div>
            );
          })()}
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
