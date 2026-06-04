import React from 'react';
import { X, Target, ArrowsClockwise, ChartLineUp, Compass, Heart } from '@phosphor-icons/react';
import './scoring-modal.css';

const PRINCIPLES = [
  {
    Icon: Target,
    accent: 'ember',
    title: 'Recall, don’t just read',
    body: 'You earn mastery by answering correctly from memory. Pulling the answer out of your own head — not recognizing it on the page — is the rep that actually sticks.',
  },
  {
    Icon: ArrowsClockwise,
    accent: 'forest',
    title: 'Spacing beats cramming',
    body: 'A problem you nail again a few days later counts far more than ten in one sitting — that’s how knowledge holds up on exam day. Daily Review schedules those comebacks for you automatically.',
  },
  {
    Icon: ChartLineUp,
    accent: 'sunbeam',
    title: 'The last stretch is earned',
    body: 'The first chunk of a chapter comes quickly; the final climb to true mastery takes review. That’s on purpose — it mirrors how ready you really are, not just how busy you’ve been.',
  },
  {
    Icon: Compass,
    accent: 'ember',
    title: 'We point you where it counts',
    body: 'Focus Areas surfaces the chapters that move your score the most — weighted by how often each one shows up on the FE Civil exam — so your time goes where it pays off.',
  },
];

export function ScoringModal({ open, onClose }) {
  React.useEffect(() => {
    if (!open) return;
    const onKey = (e) => { if (e.key === 'Escape') onClose(); };
    document.addEventListener('keydown', onKey);
    return () => document.removeEventListener('keydown', onKey);
  }, [open, onClose]);

  if (!open) return null;

  return (
    <div className="scoring-overlay" onClick={onClose} role="dialog" aria-modal="true" aria-label="How your mastery is scored">
      <div className="scoring-modal" onClick={(e) => e.stopPropagation()}>
        <button className="scoring-close" onClick={onClose} aria-label="Close">
          <X weight="bold" size={18} />
        </button>

        <p className="scoring-overline">Built on how people actually learn</p>
        <h2 className="scoring-title">How your mastery is scored</h2>
        <p className="scoring-lede">
          We built FE for Raccoons on real learning science — not on how many problems you click.
          Here’s what actually moves your mastery and Exam Readiness.
        </p>

        <ul className="scoring-principles">
          {PRINCIPLES.map(({ Icon, accent, title, body }) => (
            <li key={title}>
              <span className={`scoring-ico scoring-ico--${accent}`}><Icon weight="duotone" size={22} /></span>
              <div>
                <h3>{title}</h3>
                <p>{body}</p>
              </div>
            </li>
          ))}
        </ul>

        <div className="scoring-callout">
          <Heart weight="fill" size={18} />
          <p>
            <strong>And the rule that matters most: any studying beats none.</strong> A five-minute
            session still moves you forward. Study in whatever way fits your life — we’ll meet you
            there and help you make every minute count.
          </p>
        </div>

        <button className="scoring-done" onClick={onClose}>Got it</button>
      </div>
    </div>
  );
}
