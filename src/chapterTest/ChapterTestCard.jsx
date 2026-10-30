import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Timer } from '@phosphor-icons/react';
import './chapterTest.css';

// The chapter test block on a chapter page: two versions, each with the best
// score so far and a way in. Hidden when the chapter has no test or the
// request fails, so the page never shows a broken block.
export function ChapterTestCard({ chapterId }) {
  const navigate = useNavigate();
  const [info, setInfo] = React.useState(null);

  React.useEffect(() => {
    let live = true;
    fetch(`/api/chapter-tests/${chapterId}`)
      .then((r) => (r.ok ? r.json() : null))
      .then((d) => { if (live) setInfo(d); })
      .catch(() => {});
    return () => { live = false; };
  }, [chapterId]);

  if (!info) return null;
  const minutes = Math.round(info.limitSeconds / 60);

  return (
    <section className="ct-card" aria-labelledby="ct-card-title">
      <div className="ct-card-head">
        <h2 className="ct-card-title" id="ct-card-title">Chapter test</h2>
        <span className="ct-card-facts"><Timer size={14} weight="bold" /> {info.length} questions · {minutes} min</span>
      </div>
      <p className="ct-card-lede">
        Timed like the FE, with no hints and no answers until you hand it in.
        Two versions with different questions.
      </p>
      <ul className="ct-card-rows">
        {info.versions.map((v) => {
          const label = v.openId ? 'Continue' : v.tries ? 'Retake' : 'Start';
          return (
            <li key={v.version} className="ct-card-row">
              <span className="ct-card-version">Version {v.version}</span>
              <span className="ct-card-best">
                {v.best ? `Best ${v.best.percent}%` : v.openId ? 'In progress' : 'Not taken'}
                {v.last && v.last.id !== v.best.id && <span className="ct-card-last"> · last {v.last.percent}%</span>}
              </span>
              {v.best && (
                <button className="ct-link" onClick={() => navigate(`/test/result/${v.last.id}`)}>Review</button>
              )}
              <button
                className={`ct-card-go ${v.openId ? 'ct-card-go--open' : ''}`}
                onClick={() => navigate(`/test/${chapterId}/${v.version}`)}
              >
                {label}
              </button>
            </li>
          );
        })}
      </ul>
    </section>
  );
}
