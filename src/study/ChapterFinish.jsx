import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Lightning, Timer, CaretRight } from '@phosphor-icons/react';
import { AppArrow } from '../components/brand/AppArrow';

// The end of a chapter's list: chapter practice, then the chapter test, each
// a row in the same list as the subtopics, and ONE main button naming the
// step that comes next. The test row hides itself if the chapter has no test
// or the request fails.

// Practice is "far enough along" for the test to become the suggested step
// once most of it has been answered correctly.
const READY_FOR_TEST = 0.7;

function nextStep(practice, problemCount, test) {
  if (test && test.openId) return 'test-continue';
  const ratio = practice && practice.total ? practice.correct / practice.total : 0;
  if (test && (problemCount === 0 || ratio >= READY_FOR_TEST)) return test.tries ? 'test-again' : 'test';
  return problemCount > 0 ? 'practice' : null;
}

const NEXT_LABEL = {
  practice: 'Practice all problems',
  test: 'Take the chapter test',
  'test-again': 'Take the chapter test again',
  'test-continue': 'Continue the chapter test',
};

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
  const step = nextStep(practice, problemCount, test);
  const goPractice = () => navigate(`/problems/${chapterId}`);
  const goTest = () => navigate(`/test/${chapterId}`);
  const minutes = test ? Math.round(test.limitSeconds / 60) : 0;

  let testMeta = '';
  if (test) {
    if (test.openId) testMeta = 'In progress';
    else if (test.best) testMeta = `Best ${test.best.percent}%`;
    else testMeta = `${test.length} questions · ${minutes} min`;
  }

  return (
    <>
      <div className="st-list st-finish">
        {problemCount > 0 && (
          <button className="st-row-btn st-finish-row" onClick={goPractice}>
            <span className="st-num"><Lightning size={16} weight="bold" /></span>
            <span className="st-finish-text">
              <span className="st-name">Chapter practice</span>
              <small>
                {practiceDone
                  // "Weighted by your weak spots" is not true when there are
                  // none left, so stop claiming it.
                  ? 'Every problem answered correctly. Run it again any time.'
                  : 'All subtopics mixed, weighted to your weak spots'}
              </small>
            </span>
            <span className={`st-row-meta ${practiceDone ? 'st-row-meta--done' : ''}`}>
              {practice && practice.total > 0 ? `${practice.correct} of ${practice.total} problems` : `${problemCount} problems`}
            </span>
            <span className="st-toggle"><CaretRight size={16} weight="bold" /></span>
          </button>
        )}
        {test && (
          <button className="st-row-btn st-finish-row" onClick={goTest}>
            <span className="st-num"><Timer size={16} weight="bold" /></span>
            <span className="st-finish-text">
              <span className="st-name">Chapter test</span>
              <small>Timed like the FE. Take it again for all new questions.</small>
            </span>
            <span className="st-row-meta">{testMeta}</span>
            <span className="st-toggle"><CaretRight size={16} weight="bold" /></span>
          </button>
        )}
      </div>

      {step && (
        <button className="study-next" onClick={step === 'practice' ? goPractice : goTest}>
          <span className="study-next-text"><small>Next step</small>{NEXT_LABEL[step]}</span>
          <AppArrow size={18} />
        </button>
      )}
    </>
  );
}
