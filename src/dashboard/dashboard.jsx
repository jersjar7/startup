import React from 'react';
import { useNavigate } from 'react-router-dom';
import { SourcePrompt } from './SourcePrompt';
import { shouldAskSource } from './acquisitionGate';
import { SchoolPrompt } from './SchoolPrompt';
import { shouldAskSchool } from './schoolGate';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import {
  DeviceMobile,
  Timer,
  Info,
  ArrowRight,
  BookOpenText,
} from '@phosphor-icons/react';
import { CHAPTERS } from '../data/chapters';
import { getExamWeight } from '../data/exam-bank/index';
import { computeReadiness, computeFocusAreas } from '../data/readiness';

// Exam-Qs badge color encodes weight on one scale, never the chapter accent.
function weightClass(weight) {
  if (weight >= 11) return 'ember';
  if (weight >= 7) return 'sunbeam';
  return 'muted';
}
import { PROBLEM_COUNT } from '../data/contentStats';
import { LoadingState } from '../components/LoadingState';
import { DiagnosticCard } from '../diagnostic/DiagnosticCard';
import { ScoringModal } from './ScoringModal';
import { SetupTodo } from './SetupTodo';
import './dashboard.css';
import { givenName } from '../data/names.js';
import { RoadToFe } from './RoadToFe';
import { LiveFeed } from './LiveFeed';
import { Boards } from './Boards';
import { BadgeShelf } from './BadgeShelf';
import { AppNudge } from './AppNudge';

export function Dashboard({ userName, onLogout, displayName, firstName, examDate, emailVerified }) {
  const navigate = useNavigate();
  useDocumentTitle('Dashboard');
  // Shown to other users in Live Activity, never the raw email.
  const examDays = examDate
    ? Math.ceil((new Date(`${examDate}T00:00:00`).getTime() - Date.now()) / 86400000)
    : null;
  // Only prompt for what's actually still missing (name, exam date, or both).
  const needName = !firstName;
  const needExam = examDays === null;
  const personalizeMsg = needName && needExam
    ? 'Add your name and exam date so we can count down to exam day and show your name (not your email) in Live Activity.'
    : needName
      ? 'Add your name so we can show it (not your email) in the leaderboard and Live Activity.'
      : 'Add your exam date so we can count down to exam day on your dashboard.';
  const [profilePromptDismissed, setProfilePromptDismissed] = React.useState(
    () => { try { return localStorage.getItem('fe4r-profile-prompt') === 'dismissed'; } catch { return false; } },
  );
  const dismissProfilePrompt = () => {
    try { localStorage.setItem('fe4r-profile-prompt', 'dismissed'); } catch { /* ignore */ }
    setProfilePromptDismissed(true);
  };
  const [stats, setStats] = React.useState({ totalXp: 0, currentStreak: 0, badges: [], allBadges: [] });
  const earnedBadgeIds = React.useMemo(() => new Set(stats.badges.map((b) => b.id)), [stats.badges]);
  const [leaderboard, setLeaderboard] = React.useState({ weekId: '', entries: [], allTime: [] });
  const [loading, setLoading] = React.useState(true);
  // Attribution safety net. New users are asked at sign-up
  // (src/login/login.jsx); this catches anyone who slipped past that. Seeded
  // `true` so a slow or failed /me never triggers a duplicate ask.
  const [acqResolved, setAcqResolved] = React.useState(true);
  // School safety net, on the same terms and seeded `true` for the same reason.
  // Separate flag, not folded into acqResolved: the two questions resolve
  // independently, and a user who answered one before the other existed must
  // still be asked the one they have not seen.
  const [schoolResolved, setSchoolResolved] = React.useState(true);
  // The school we already worked out from their .edu address, if any, so the
  // prompt opens with it filled in rather than asking them to retype it.
  const [knownSchool, setKnownSchool] = React.useState('');
  const [problemsAnswered, setProblemsAnswered] = React.useState(0);
  const [error, setError] = React.useState('');
  const [events, setEvents] = React.useState([]);
  const [diagnosticStatus, setDiagnosticStatus] = React.useState({
    diagnosticCompleted: false,
    diagnosticSkipped: false,
    canRetake: false,
    chaptersAt60: 0,
    chaptersNeeded: 11,
    lastScore: undefined,
    lastDate: undefined,
  });
  const [chapterMastery, setChapterMastery] = React.useState({});
  const [quickstart, setQuickstart] = React.useState({ sampledCount: 0, totalChapters: 15, nextChapterId: null });
  const [phoneToday, setPhoneToday] = React.useState(null);
  const [syncState, setSyncState] = React.useState(null); // { at, device, source }, last sync from any device

  // A left-open dashboard should notice phone work without a reload, light
  // poll of the activity endpoint while the tab is visible (sync v1; the /ws
  // push upgrade can replace this later).
  React.useEffect(() => {
    const tick = () => {
      if (document.visibilityState !== 'visible') return;
      fetch(`/api/sync/today?date=${new Date().toLocaleDateString('en-CA')}`)
        .then((r) => (r.ok ? r.json() : null))
        .then((d) => {
          if (!d) return;
          if (d.cards > 0 || (d.paperFlags && d.paperFlags.length > 0)) setPhoneToday(d);
          if (d.lastSync) setSyncState(d.lastSync);
        })
        .catch(() => {});
    };
    const id = setInterval(tick, 60000);
    return () => clearInterval(id);
  }, []);
  const [scoringOpen, setScoringOpen] = React.useState(false);
  const [reviewDue, setReviewDue] = React.useState(0);
  const [challenge, setChallenge] = React.useState(null);

  React.useEffect(() => {
    if (!userName) {
      navigate('/');
      return;
    }

    Promise.allSettled([
      fetch('/api/user/me').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
      fetch('/api/leaderboard').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
      fetch('/api/diagnostic/can-retake').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
      // One read for both surfaces (ADR 0018): mastery and the due count come
      // from the account's state, derived from its log, the same the phone reads.
      fetch(`/api/account/state?date=${new Date().toLocaleDateString('en-CA')}`).then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
      fetch('/api/diagnostic/history').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
      Promise.resolve(null), // the due count now rides on the account read above
      fetch('/api/leaderboard/alltime').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
      fetch('/api/quickstart/state').then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
      fetch(`/api/sync/today?date=${new Date().toLocaleDateString('en-CA')}`).then((res) => { if (!res.ok) throw new Error(); return res.json(); }),
    ]).then(([statsResult, lbResult, retakeResult, masteryResult, historyResult, reviewCountResult, allTimeResult, quickstartResult, phoneTodayResult]) => {
      const errors = [];
      if (statsResult.status === 'fulfilled') {
        const data = statsResult.value;
        setStats({
          totalXp: data.totalXp || 0,
          currentStreak: data.currentStreak || 0,
          badges: data.badges || [],
          allBadges: data.allBadges || [],
        });
        // Server-side truth: answered OR dismissed, on any device.
        setAcqResolved(Boolean(data.acquisitionResolved));
        setSchoolResolved(Boolean(data.schoolResolved));
        setKnownSchool(data.school?.name || '');
        setProblemsAnswered(data.problemsAnswered || 0);
      } else {
        errors.push('stats');
      }
      if (lbResult.status === 'fulfilled') {
        setLeaderboard((prev) => ({ ...prev, weekId: lbResult.value.weekId, entries: lbResult.value.leaderboard || [] }));
      }
      if (allTimeResult.status === 'fulfilled') {
        setLeaderboard((prev) => ({ ...prev, allTime: allTimeResult.value.leaderboard || [] }));
      }
      if (quickstartResult.status === 'fulfilled') {
        setQuickstart(quickstartResult.value);
      }
      if (phoneTodayResult.status === 'fulfilled') {
        const pt = phoneTodayResult.value;
        // Show if there was any phone work OR anything set aside for paper.
        if (pt.cards > 0 || (pt.paperFlags && pt.paperFlags.length > 0)) setPhoneToday(pt);
        if (pt.lastSync) setSyncState(pt.lastSync);
      }

      // Diagnostic status
      const diagStatus = {
        diagnosticCompleted: false,
        diagnosticSkipped: localStorage.getItem('diagnosticSkipped') === 'true',
        diagnosticAttempts: 0,
        canRetake: false,
        chaptersAt60: 0,
        chaptersNeeded: 11,
        lastScore: undefined,
        lastDate: undefined,
      };
      if (retakeResult.status === 'fulfilled') {
        const r = retakeResult.value;
        diagStatus.diagnosticCompleted = r.diagnosticCompleted;
        diagStatus.diagnosticAttempts = r.diagnosticAttempts || 0;
        diagStatus.canRetake = r.canRetake;
        diagStatus.chaptersAt60 = r.chaptersAt60 || 0;
        diagStatus.chaptersNeeded = r.chaptersNeeded || 11;
      }
      if (historyResult.status === 'fulfilled' && historyResult.value.length > 0) {
        const latest = historyResult.value[0];
        diagStatus.lastScore = { correct: latest.totalCorrect, total: latest.totalQuestions };
        diagStatus.lastDate = latest.completedAt;
      }
      setDiagnosticStatus(diagStatus);

      // Chapter mastery from diagnostic
      if (masteryResult.status === 'fulfilled') {
        setChapterMastery(masteryResult.value.chapterMastery || {});
        setReviewDue(masteryResult.value.dueReviews || 0);
        setChallenge(masteryResult.value.challenge || null);
      }

      // Reviews due (for the Review badge)
      if (reviewCountResult.status === 'fulfilled' && reviewCountResult.value) {
        setReviewDue(reviewCountResult.value.count || 0);
      }

      if (errors.length > 0) {
        setError('Failed to load some data. Try refreshing the page.');
      }
      setLoading(false);
    });

    const protocol = window.location.protocol === 'http:' ? 'ws' : 'wss';
    const ws = new WebSocket(`${protocol}://${window.location.host}/ws`);

    // Listen only: presence is broadcast from real lessons/practice sessions,
    // not from just having the dashboard open.
    ws.onmessage = (event) => {
      // Frames may arrive as a string or a Blob; parse defensively either way.
      const handle = (text) => {
        try {
          const msg = JSON.parse(text);
          // One row per user (their latest activity): clients re-broadcast on
          // every WebSocket reconnect, so dedupe by `from` to avoid repeats.
          setEvents((prev) => [msg, ...prev.filter((e) => e.from !== msg.from)].slice(0, 10));
        } catch {
          /* ignore malformed frames */
        }
      };
      if (typeof event.data === 'string') {
        handle(event.data);
      } else if (event.data && typeof event.data.text === 'function') {
        event.data.text().then(handle).catch(() => {});
      }
    };

    return () => ws.close();
  }, [userName, navigate]);

  const handleChapterClick = (chapter) => {
    // Presence is broadcast once the study page actually loads, not on click.
    navigate(`/study/${chapter.id}`);
  };


  // Mastery is a single source of truth: chapterMastery[ch.id].totalMastery,
  // written by the diagnostic AND by practice/review (studyScore).
  // Stage words match the phone exactly (same thresholds): one vocabulary.
  const stageName = (pct) => {
    if (pct >= 80) return 'Mastered';
    if (pct >= 50) return 'Familiar';
    if (pct >= 10) return 'Building';
    return 'New';
  };
  // Mastery is desk-earned (ADR 0020): coverage of the chapter's problems,
  // with the readiness read as a floor worth at most 25. Practice on the phone
  // are a warm-up; their count is shown, never added.
  const getProgress = (chapter) => {
    const cm = chapterMastery[chapter.id];
    const pct = cm && cm.totalMastery > 0 ? cm.totalMastery : 0;
    return {
      masteryPct: pct,
      gamesCleared: cm && cm.gamesCleared > 0 ? cm.gamesCleared : 0,
      gamesTotal: cm && cm.gamesTotal > 0 ? cm.gamesTotal : 0,
      masteryName: stageName(pct),
      decaying: false,
    };
  };

  function getMasteryColor(pct) {
    if (pct >= 90) return 'var(--forest)';
    if (pct >= 70) return 'var(--sunbeam)';
    if (pct > 0) return 'var(--ember)'; // low = warm start, never error-red
    return 'var(--gray-200)';
  }

  /* Mastery % per chapter, fed into the shared readiness/focus model so the
     dashboard and the post-session summary agree. Single source: chapterMastery. */
  const masteryByChapterId = React.useMemo(
    () => Object.fromEntries(CHAPTERS.map((ch) => [ch.id, getProgress(ch).masteryPct])),
    [chapterMastery],
  );

  const readiness = React.useMemo(() => computeReadiness(masteryByChapterId), [masteryByChapterId]);
  const focusAreas = React.useMemo(() => computeFocusAreas(masteryByChapterId), [masteryByChapterId]);
  // The "Most to gain" marks on the list. Only once there is something
  // measured: before that they would be guesses, not guidance.
  const focusIds = React.useMemo(
    () => new Set(focusAreas.some((f) => f.masteryPct > 0) ? focusAreas.map((f) => f.ch.id) : []),
    [focusAreas],
  );
  const today = new Date().toLocaleDateString('en-CA');
  const hasActivity = React.useMemo(
    () => stats.totalXp > 0 || Object.values(masteryByChapterId).some((p) => p > 0),
    [stats.totalXp, masteryByChapterId],
  );


  // Ask until resolved, never after. The never-ask-twice rule lives in
  // shouldAskSource(), which is unit tested.
  const showSource = shouldAskSource({ acquisitionResolved: acqResolved });
  // Never both at once. shouldAskSchool() stands down while the source question
  // is still outstanding, so the school ask surfaces on the next render after
  // attribution resolves rather than stacking on top of it.
  const showSchool = shouldAskSchool({ acquisitionResolved: acqResolved, schoolResolved });

  // Freeze the page behind the modal so the dashboard does not scroll under it.
  React.useEffect(() => {
    if (!showSource && !showSchool) return undefined;
    const prev = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => { document.body.style.overflow = prev; };
  }, [showSource, showSchool]);

  // SourcePrompt has already POSTed the answer by the time it calls back; this
  // just closes the modal for the rest of the session. The server is the source
  // of truth on the next load, so a failed POST means they are asked again
  // rather than silently lost.
  function resolveAcquisition() {
    setAcqResolved(true);
  }

  // Same contract as resolveAcquisition: SchoolPrompt has already POSTed by the
  // time it calls back, and the server is the truth on the next load, so a
  // failed POST means they get asked again rather than silently losing it.
  function resolveSchool() {
    setSchoolResolved(true);
  }

  function handleDiagnosticSkip() {
    localStorage.setItem('diagnosticSkipped', 'true');
    setDiagnosticStatus(prev => ({ ...prev, diagnosticSkipped: true }));
  }

  if (loading) {
    return <LoadingState />;
  }

  return (
    <main>
      {/* ── Header ── */}
      <div className="dash-header">
        <div>
          <h2 className="dash-title">Dashboard</h2>
          {/* The given name only: "Jerson Test" reads "Welcome back, Jerson"
              (owner, 2026-10-16). */}
          <span className="dash-greeting">{givenName(firstName) ? `Welcome back, ${givenName(firstName)}` : 'Welcome back'}</span>
        </div>
        {/* account actions live on Profile, keep the dashboard about study */}
      </div>

      {error && <div className="error-banner" role="alert">{error}</div>}

      {/* Account-setup logistics live in the right column (SetupTodo), so the
          main panel stays focused on preparation. */}

      {/* ── Chapters first, from the top (2026-10-26 redesign, docs/dashboard.md):
          the list on the left, the road to the FE on the right, the boards
          under the list. ── */}
      <div className="dash-grid">

        {/* ── LEFT: 15 Chapters ── */}
        <section className="dash-chapters">
          <div className="ch-head">
            <h3 className="dash-section-label">
              <BookOpenText weight="bold" size={18} />
              Chapters
            </h3>
            <div className="ch-head-actions">
              {reviewDue > 0 ? (
                <button className="review-btn review-btn--due" onClick={() => navigate('/review')}>
                  <Timer weight="bold" size={16} />
                  Review
                  <span className="review-due-badge">{reviewDue > 10 ? '10+' : reviewDue}</span>
                  <ArrowRight weight="bold" size={14} />
                </button>
              ) : hasActivity ? (
                <span className="review-btn review-btn--done" title="No reviews due right now">
                  <Timer weight="bold" size={16} />
                  No reviews due
                </span>
              ) : null}
              {(() => {
                const qsTotal = CHAPTERS.length;
                const qsCount = quickstart?.sampledCount || 0;
                const label = qsCount === 0
                  ? 'See where you stand'
                  : qsCount < qsTotal
                    ? `Readiness map · ${qsCount} of ${qsTotal}`
                    : 'Readiness map · complete';
                return (
                  <button className="readiness-btn" onClick={() => navigate('/quickstart')}>
                    {label} <ArrowRight weight="bold" size={13} />
                  </button>
                );
              })()}
            </div>
          </div>
          {syncState && syncState.at && (() => {
            const d = new Date(syncState.at);
            const sameDay = d.toDateString() === new Date().toDateString();
            const when = sameDay
              ? d.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' })
              : d.toLocaleDateString([], { month: 'short', day: 'numeric' });
            const device = syncState.device ? `your ${syncState.device}` : 'your phone';
            return (
              <p className="ch-phone-line">
                <DeviceMobile weight="bold" size={13} />
                <b>Practice done in the app</b> shows under a chapter&apos;s bar. Last synced {when} from {device}.
              </p>
            );
          })()}
          <div className="ch-list">
            <div className="ch-list-header">
              <span></span>
              <span></span>
              <span className="ch-header-label">
                Chapter
                <span className="ch-header-info" data-tooltip="The 15 chapters follow the official NCEES FE Civil exam specification. Each chapter maps to one knowledge area tested on exam day.">
                  <Info weight="regular" size={13} />
                </span>
              </span>
              <button className="ch-header-label ch-header-label--right ch-header-btn" onClick={() => setScoringOpen(true)} data-tooltip="How is mastery scored? Tap to see our learning-science method.">
                Mastery
                <span className="ch-header-info ch-header-info--right">
                  <Info weight="regular" size={13} />
                </span>
              </button>
              <span className="ch-header-label ch-header-label--right">
                Exam Qs
                <span className="ch-header-info ch-header-info--right" data-tooltip="The number of questions each topic gets on the FE Civil exam, from the NCEES specification in use since July 2020. Mathematics and Statistics are one area there, 8 to 12 questions together. The exam has 110 questions.">
                  <Info weight="regular" size={13} />
                </span>
              </span>
              <span></span>
            </div>
            {CHAPTERS.map((ch) => {
              const Icon = ch.icon;
              const prog = getProgress(ch);
              const pct = prog.masteryPct;
              const barColor = getMasteryColor(pct);

              return (
                <button key={ch.id} className="ch-row-dash" onClick={() => handleChapterClick(ch)}>
                  <span className="ch-num-d">{String(ch.num).padStart(2, '0')}</span>
                  <Icon weight="bold" size={18} className={`ch-icon-d ch-icon-d--${ch.accent}`} />
                  <span className="ch-name-d">{ch.name}{focusIds.has(ch.id) && <span className="ch-focus">Most to gain</span>}</span>
                  <div className="ch-mastery">
                    <span className={`ch-pct${pct > 0 ? '' : ' ch-pct--zero'}`} style={pct > 0 ? { color: barColor } : undefined}>{pct}%</span>
                    <div className="mastery-bar-pct">
                      <div
                        className="mastery-bar-fill"
                        style={{ width: `${pct}%`, background: barColor }}
                      />
                    </div>
                    {/* The warm-up line shows only where games were played:
                        nobody sees it for an app they cannot use. It sits off
                        the bar because it is not part of the number. */}
                    {prog.gamesCleared > 0 ? (
                      <span className="ch-games" title="Practice in the app is a warm-up. It does not count toward mastery."><DeviceMobile weight="regular" size={10} /> warm-up {prog.gamesCleared} of {prog.gamesTotal}</span>
                    ) : null}
                  </div>
                  {/* badge color encodes exam weight (one scale), not the chapter's accent */}
                  <span className={`ch-badge-d ch-badge-d--${weightClass(getExamWeight(ch.id))}`} title={ch.qsShared ? `Shared with ${ch.qsShared}: one area on the exam` : undefined}>{ch.qs} Qs</span>
                  <ArrowRight weight="bold" size={14} className="ch-arrow" />
                </button>
              );
            })}
          </div>

        </section>

        {/* ── RIGHT: the road to the FE, then badges and who else is here ── */}
        <aside className="dash-sidebar">
          <RoadToFe
            today={today}
            examDate={examDate}
            examDays={examDays}
            readiness={readiness}
            masteryColor={readiness > 0 ? getMasteryColor(readiness) : 'var(--charcoal)'}
            onScoring={() => setScoringOpen(true)}
            reviewDue={reviewDue}
            phoneToday={phoneToday}
            syncState={syncState}
            focusTop={focusIds.size ? focusAreas[0].ch : null}
            weekly={leaderboard.entries}
            totalXp={stats.totalXp}
            daysStudied={stats.currentStreak}
            challenge={challenge}
          />

          {/* The raccoon sits on the road, so these come after it. */}
          {/* Account setup: logistics, kept out of the left prep panel */}
          <SetupTodo
            emailVerified={emailVerified}
            hasName={!!firstName}
            hasExam={!!examDate}
          />

          {/* The readiness map's own card, for the states the head button
              cannot carry: the first-time pitch, and the retake states. */}
          {(() => {
            const qsCount = quickstart?.sampledCount || 0;
            const inProgressOrDone = qsCount > 0 && !diagnosticStatus?.diagnosticCompleted;
            return inProgressOrDone ? null : (
              <DiagnosticCard diagnosticStatus={diagnosticStatus} quickstart={quickstart} onSkip={handleDiagnosticSkip} />
            );
          })()}


          {/* The phone app, for people who have never synced from it. */}
          <AppNudge syncState={syncState} />

          <LiveFeed today={today} presence={events} viewerName={displayName || ''} />

        </aside>

        {/* ── Under the chapters: both boards, the badges, the share line ── */}
        <div className="dash-under">
          <Boards weekly={leaderboard.entries} allTime={leaderboard.allTime} />
          <BadgeShelf allBadges={stats.allBadges} earnedIds={earnedBadgeIds} totalXp={stats.totalXp} streak={stats.currentStreak} />
          <p className="dash-share">
            Know someone taking the FE? A post on{' '}
            <a href="https://www.reddit.com/r/FE_Exam/" target="_blank" rel="noopener noreferrer">r/FE_Exam</a>
            {' '}or{' '}
            <a href={`https://x.com/intent/tweet?text=Studying%20for%20the%20FE%20Civil%20exam%3F%20FE%20for%20Raccoons%20is%20free%3A%20lessons%2C%20${PROBLEM_COUNT}%20problems%2C%20a%20diagnostic.%20fe4raccoons.com`} target="_blank" rel="noopener noreferrer">X</a>
            {' '}helps the next student find us.
          </p>
        </div>
      </div>
      {/* Attribution safety net. A modal, not a rail card: in the rail it sat
          below the fold and was effectively invisible.
          Mandatory, matching the registration ask: one tap, once, ever. There
          is no dismiss because dismissing was permanent and simply lost the
          answer; "Other" is the honest out for anyone who does not remember. */}
      {showSource && (
        <div className="source-prompt-overlay" role="dialog" aria-modal="true" aria-label="How did you find us?">
          <SourcePrompt className="is-modal" dismissible={false} onClose={resolveAcquisition} />
        </div>
      )}
      {/* School safety net, queued behind the attribution one so a brand new
          account never meets two modals in the same breath. "Not a student" is
          the out, and it resolves server-side so it is a real answer rather
          than a dismissal we would ask about again tomorrow. */}
      {showSchool && (
        <div className="school-prompt-overlay" role="dialog" aria-modal="true" aria-label="Where are you studying?">
          <SchoolPrompt
            className="is-modal"
            dismissible={false}
            onClose={resolveSchool}
            initialName={knownSchool}
          />
        </div>
      )}
      <ScoringModal open={scoringOpen} onClose={() => setScoringOpen(false)} />
    </main>
  );
}
