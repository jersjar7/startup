import React from 'react';
import { useNavigate } from 'react-router-dom';
import { ChapterCoin } from '../components/brand/ChapterCoin';
import { AppArrow } from '../components/brand/AppArrow';
import { CHAPTERS } from '../data/chapters';
import { daysLeft, progressLine, daysLine, finishedLine, nextLesson, finishLine } from './challengeText';
import './challenge.css';

// This month's chapter challenge on the dashboard (ADR 0027). The student's
// progress comes with the account state; the finished count is the public
// read. Each lesson is one mark: filled when cleared at the desk, an outline
// when cleared on the phone, dashed while still to do. The card goes away
// once every lesson is cleared at the desk.
export function ChallengeCard({ progress, today }) {
  const navigate = useNavigate();
  const [meta, setMeta] = React.useState(null);

  React.useEffect(() => {
    if (!progress) return;
    let live = true;
    fetch(`/api/challenge/current?date=${today}`)
      .then((r) => (r.ok ? r.json() : null))
      .then((d) => { if (live && d?.current) setMeta(d); })
      .catch(() => {});
    return () => { live = false; };
  }, [progress, today]);

  if (!progress || progress.finishedAtDesk) return null;
  const current = meta?.current;
  const chapter = CHAPTERS.find((c) => c.id === progress.chapterId);
  const next = nextLesson(progress);
  const left = current ? daysLeft(today, current.end) : 0;
  const finish = finishLine(progress);

  return (
    <section className="challenge-card" aria-label={current ? current.name : 'This month\'s challenge'}>
      <ChapterCoin chapterId={progress.chapterId} accent={chapter?.accent || 'sunbeam'} size={64} className="challenge-coin" />
      <div className="challenge-body">
        <span className="challenge-overline">{current ? `${current.monthName} challenge` : 'This month\'s challenge'}</span>
        <h3 className="challenge-title">{chapter?.name || current?.name}</h3>
        <p className="challenge-line">{finish || current?.line}</p>
        <ol className="challenge-marks">
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
        <p className="challenge-meta">
          {[progressLine(progress), daysLine(left), meta ? finishedLine(meta.finished) : ''].filter(Boolean).join(' · ')}
        </p>
        <p className="challenge-key">
          <span className="challenge-mark challenge-mark--desk" aria-hidden="true" /> at the desk
          <span className="challenge-mark challenge-mark--phone" aria-hidden="true" /> on the phone
        </p>
      </div>
      {next && (
        <button className="challenge-cta" onClick={() => navigate(`/lesson/${progress.chapterId}/${next.id}`)}>
          <span className="challenge-cta-text">
            <small>Next lesson</small>
            {next.name}
          </span>
          <AppArrow />
        </button>
      )}
    </section>
  );
}
