import React from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowRight, Info } from '@phosphor-icons/react';
import { ChapterCoin } from '../components/brand/ChapterCoin';
import { AppArrow } from '../components/brand/AppArrow';
import { RaccoonPeek } from '../components/brand/RaccoonPeek';
import { CHAPTERS } from '../data/chapters';
import { progressLine, finishedLine, nextLesson } from '../challenge/challengeText';
import { trackPitch } from '../exam/trackPitch';
import { roadStops, passLine } from './road';
import '../challenge/challenge.css';
import './road.css';

// The road to the FE (docs/dashboard.md): one line from today to exam day,
// with a stop for each thing that has a date. Today's work, the week's board,
// the month's challenge, the timed simulation, the exam.
export function RoadToFe({
  today, examDate, examDays, readiness, masteryColor, onScoring,
  reviewDue, phoneToday, syncState, focusTop, weekly, totalXp, daysStudied, challenge,
}) {
  const navigate = useNavigate();
  const [challengeMeta, setChallengeMeta] = React.useState(null);
  const [sim, setSim] = React.useState(null); // { purchased, attempts, best }
  const pitchLogged = React.useRef(false);

  React.useEffect(() => {
    if (!challenge) return undefined;
    let live = true;
    fetch(`/api/challenge/current?date=${today}`)
      .then((r) => (r.ok ? r.json() : null))
      .then((d) => { if (live && d?.current) setChallengeMeta(d); })
      .catch(() => {});
    return () => { live = false; };
  }, [challenge, today]);

  React.useEffect(() => {
    let live = true;
    fetch('/api/checkout/status')
      .then((r) => (r.ok ? r.json() : null))
      .then(async (d) => {
        if (!d) return;
        if (!d.purchased) { if (live) setSim({ purchased: false }); return; }
        const attempts = await fetch('/api/exam/attempts').then((r) => (r.ok ? r.json() : [])).catch(() => []);
        const done = attempts.filter((a) => a.status === 'completed');
        if (live) setSim({ purchased: true, attempts: done.length, best: done.length ? Math.max(...done.map((a) => a.overallPercentage || 0)) : null });
      })
      .catch(() => {});
    return () => { live = false; };
  }, []);

  React.useEffect(() => {
    if (sim && !sim.purchased && !pitchLogged.current) {
      pitchLogged.current = true;
      trackPitch('shown', 'road');
    }
  }, [sim]);

  const stops = roadStops({
    today,
    examDate,
    challenge,
    challengeEnd: challengeMeta?.current?.end || null,
    simOwned: Boolean(sim?.purchased),
  });

  const body = (s) => {
    switch (s.key) {
      case 'today': return <TodayStop reviewDue={reviewDue} phoneToday={phoneToday} syncState={syncState} focusTop={focusTop} navigate={navigate} />;
      case 'week': return <WeekStop weekly={weekly} totalXp={totalXp} daysStudied={daysStudied} />;
      case 'challenge': return <ChallengeStop progress={challenge} meta={challengeMeta} navigate={navigate} />;
      case 'sim': return sim ? <SimStop sim={sim} navigate={navigate} /> : null;
      case 'exam': return (
        <>
          <div className="road-title">Exam day</div>
          {!s.date && <button type="button" className="road-link" onClick={() => navigate('/profile')}>Set your exam date <ArrowRight weight="bold" size={12} /></button>}
        </>
      );
      default: return null;
    }
  };

  return (
    <RaccoonPeek at={0.86}>
      <section className="road-card" aria-label="Your road to the FE">
        <div className="road-head">
          <div>
            <span className="road-over">Your road to the FE</span>
            {examDays !== null && examDays >= 0 ? (
              <p className="road-count"><b>{examDays === 0 ? 'Today' : examDays}</b>{examDays > 0 ? ` ${examDays === 1 ? 'day' : 'days'} left` : ''}</p>
            ) : (
              <button type="button" className="road-set" onClick={() => navigate('/profile')}>Set your exam date <ArrowRight weight="bold" size={13} /></button>
            )}
          </div>
          <button type="button" className="road-mastery" onClick={onScoring} title="How is mastery scored?">
            <b style={{ color: masteryColor }}>{readiness}%</b>
            <span>mastery <Info weight="regular" size={12} /></span>
          </button>
        </div>
        <ol className="road-stops">
          {stops.map((s) => {
            const content = body(s);
            if (!content) return null;
            return (
              <li key={s.key} className={`road-stop road-stop--${s.key}`}>
                <span className="road-dot" aria-hidden="true" />
                <span className="road-when">{s.when}</span>
                {content}
              </li>
            );
          })}
        </ol>
      </section>
    </RaccoonPeek>
  );
}

function TodayStop({ reviewDue, phoneToday, syncState, focusTop, navigate }) {
  const synced = syncState && syncState.at ? new Date(syncState.at) : null;
  const when = synced
    ? (synced.toDateString() === new Date().toDateString()
      ? synced.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' })
      : synced.toLocaleDateString([], { month: 'short', day: 'numeric' }))
    : null;
  const misses = phoneToday ? (phoneToday.paperFlags?.length ? phoneToday.paperFlags : (phoneToday.missed || [])) : [];
  const byCh = {};
  for (const m of misses) byCh[m.chapterId] = (byCh[m.chapterId] || 0) + 1;
  const missCh = Object.keys(byCh).sort((a, b) => byCh[b] - byCh[a])[0];

  const parts = [];
  if (reviewDue > 0) {
    parts.push(
      <p key="rev" className="road-text">
        <b>{reviewDue > 10 ? '10+' : reviewDue} {reviewDue === 1 ? 'review' : 'reviews'} due.</b>{' '}
        <button type="button" className="road-link" onClick={() => navigate('/review')}>Review <ArrowRight weight="bold" size={12} /></button>
      </p>,
    );
  }
  if (phoneToday) {
    parts.push(
      <p key="phone" className="road-text">
        Your phone did {phoneToday.cards} {phoneToday.cards === 1 ? 'round' : 'rounds'}
        {phoneToday.misses > 0 ? ` and missed ${phoneToday.misses}` : ''}{when ? ` (synced ${when})` : ''}.{' '}
        {missCh && (
          <button type="button" className="road-link" onClick={() => navigate(`/problems/${missCh}`)}>Practice the misses <ArrowRight weight="bold" size={12} /></button>
        )}
      </p>,
    );
  }
  if (!parts.length && focusTop) {
    parts.push(
      <p key="focus" className="road-text">
        Nothing due. <b>{focusTop.name}</b> has the most to gain.{' '}
        <button type="button" className="road-link" onClick={() => navigate(`/study/${focusTop.id}`)}>Start <ArrowRight weight="bold" size={12} /></button>
      </p>,
    );
  }
  return parts.length ? <>{parts}</> : <p className="road-text">Nothing due today.</p>;
}

function WeekStop({ weekly, totalXp, daysStudied }) {
  const entries = weekly || [];
  const me = entries.find((e) => e.isCurrentUser);
  const top = entries.slice(0, 10);
  const bars = me && !top.includes(me) ? [...top.slice(0, 9), me] : top;
  const max = Math.max(1, ...bars.map((e) => e.weeklyXp || 0));
  const pass = passLine(entries, 'weeklyXp');
  return (
    <>
      <div className="road-title">{me ? `#${me.rank} this week` : 'Not on this week\'s board yet'}</div>
      {bars.length > 0 && (
        <div className="road-bars" aria-hidden="true">
          {bars.map((e) => (
            <span key={e.rank} className={e.isCurrentUser ? 'is-you' : ''} style={{ height: `${Math.max(8, ((e.weeklyXp || 0) / max) * 100)}%` }} title={`#${e.rank} ${e.isCurrentUser ? 'You' : e.name}`} />
          ))}
        </div>
      )}
      <p className="road-mono">
        {[pass || (me ? '' : 'Earn XP this week to join it.'), `${daysStudied} ${daysStudied === 1 ? 'day' : 'days'} studied`, `${totalXp} XP`].filter(Boolean).join(' · ')}
      </p>
    </>
  );
}

function ChallengeStop({ progress, meta, navigate }) {
  const chapter = CHAPTERS.find((c) => c.id === progress.chapterId);
  const next = nextLesson(progress);
  return (
    <>
      <div className="road-title road-title--coin">
        <ChapterCoin chapterId={progress.chapterId} accent={chapter?.accent || 'sunbeam'} size={24} />
        {chapter?.name || 'This month\'s'} challenge
      </div>
      <ol className="road-marks">
        {progress.lessons.map((l) => (
          <li key={l.id}>
            <button
              type="button"
              className={`challenge-mark challenge-mark--${l.cleared || 'todo'}`}
              title={`${l.name}${l.cleared === 'desk' ? ', cleared at the desk' : l.cleared === 'phone' ? ', cleared on the phone' : ''}`}
              aria-label={`${l.name}${l.cleared === 'desk' ? ', cleared at the desk' : l.cleared === 'phone' ? ', cleared on the phone' : ', to do'}`}
              onClick={() => navigate(`/lesson/${progress.chapterId}/${l.id}`)}
            />
          </li>
        ))}
      </ol>
      <p className="road-mono">{[progressLine(progress), meta ? finishedLine(meta.finished) : ''].filter(Boolean).join(' · ')}</p>
      {next && (
        <button type="button" className="challenge-cta road-cta" onClick={() => navigate(`/lesson/${progress.chapterId}/${next.id}`)}>
          <span className="challenge-cta-text"><small>Next lesson</small>{next.name}</span>
          <AppArrow size={16} />
        </button>
      )}
    </>
  );
}

function SimStop({ sim, navigate }) {
  if (sim.purchased) {
    return (
      <>
        <div className="road-title">Your timed simulation</div>
        <p className="road-text">
          {sim.attempts > 0 ? `${sim.attempts} ${sim.attempts === 1 ? 'run' : 'runs'}${sim.best !== null ? `, best ${sim.best}%` : ''}.` : 'Ready for your first run.'}{' '}
          <button type="button" className="road-link" onClick={() => navigate('/exam')}>Open it <ArrowRight weight="bold" size={12} /></button>
        </p>
      </>
    );
  }
  return (
    <>
      <div className="road-title">Timed simulation</div>
      <p className="road-text">
        110 questions on the real clock, with time left to fix what it finds.{' '}
        <button type="button" className="road-link" onClick={() => { trackPitch('click', 'road'); navigate('/exam'); }}>See it <ArrowRight weight="bold" size={12} /></button>
      </p>
    </>
  );
}
