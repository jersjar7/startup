import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Lightning, Timer } from '@phosphor-icons/react';
import { AppArrow } from '../components/brand/AppArrow';

// Under the subtopics: the chapter's two ways to work on it, side by side as
// equals. Practice teaches (answer after each problem); the test measures
// (timed, answers at the end). The test option hides itself if the chapter
// has no test or the request fails.

export function ChapterFinish({ chapterId, practice, problemCount }) {
  const navigate = useNavigate();
  const [test, setTest] = React.useState(null);

  React.useEffect(() => {
    let live = true;
    fetch(`/api/chapter-tests/${chapterId}`)
      .then((r) => (r.ok ? r.json() : null))
      .then((d) => { if (live) setTest(d); })
      .catch(() => {});
    return () => { live = false; };
  }, [chapterId]);

  const practiceDone = practice && practice.total > 0 && practice.correct >= practice.total;
  const minutes = test ? Math.round(test.limitSeconds / 60) : 0;

  let testMeta = '';
  if (test) {
    if (test.openId) testMeta = 'In progress';
    else if (test.best) testMeta = `Best ${test.best.percent}% · ${test.tries} ${test.tries === 1 ? 'try' : 'tries'}`;
    else testMeta = 'Not taken yet';
  }

  if (problemCount === 0 && !test) return null;

  return (
    <div className="study-ways">
      {problemCount > 0 && (
        <button className="study-way" onClick={() => navigate(`/problems/${chapterId}`)}>
          <span className="study-way-icon"><Lightning size={20} weight="bold" /></span>
          <span className="study-way-title">Practice the chapter</span>
          <span className="study-way-line">One problem at a time. See the answer after each one.</span>
          <span className={`study-way-meta ${practiceDone ? 'study-way-meta--done' : ''}`}>
            {practice && practice.total > 0 ? `${practice.correct} of ${practice.total} problems` : `${problemCount} problems`}
          </span>
          <AppArrow size={16} />
        </button>
      )}
      {test && (
        <button className="study-way" onClick={() => navigate(`/test/${chapterId}`)}>
          <span className="study-way-icon"><Timer size={20} weight="bold" /></span>
          <span className="study-way-title">Test yourself, timed</span>
          <span className="study-way-line">
            {test.length} questions in {minutes} minutes, like the FE. Answers at the end.
          </span>
          <span className="study-way-meta">{testMeta}</span>
          <AppArrow size={16} />
        </button>
      )}
    </div>
  );
}
