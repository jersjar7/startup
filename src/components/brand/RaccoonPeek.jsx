import React from 'react';
import peekUrl from '../../assets/brand/raccoon-peek.png';
import './raccoonPeek.css';

// The app's raccoon, peeking over the top edge of one card. One per page.
//
// Wrap the card: <RaccoonPeek at={0.86}><Card /></RaccoonPeek>. `at` is where
// the raccoon sits along the card's width (0 = left edge, 1 = right edge).
//
// `animated` is for the landing page only. Everywhere else the raccoon is
// still, so it never pulls attention from studying. When animated, it rises
// from behind the card the first time the card scrolls into view, drops its
// nose onto the edge, looks around and blinks, then stays. It plays once per
// visit, and never for people who ask their device for reduced motion.
const PLAYED_KEY = 'fe4r.peekPlayed';

export function RaccoonPeek({ at = 0.85, animated = false, className = '', children }) {
  const ref = React.useRef(null);
  const [phase, setPhase] = React.useState('still');

  React.useEffect(() => {
    if (!animated || typeof window === 'undefined' || !('IntersectionObserver' in window)) return undefined;
    if (window.matchMedia?.('(prefers-reduced-motion: reduce)').matches) return undefined;
    try {
      if (sessionStorage.getItem(PLAYED_KEY)) return undefined;
    } catch { /* storage blocked: still play once for this page view */ }

    setPhase('waiting');
    const io = new IntersectionObserver((entries) => {
      if (!entries.some((e) => e.isIntersecting)) return;
      io.disconnect();
      setPhase('playing');
      try { sessionStorage.setItem(PLAYED_KEY, '1'); } catch { /* ignore */ }
    }, { threshold: 0.6 });
    io.observe(ref.current);
    return () => io.disconnect();
  }, [animated]);

  return (
    <div className={`peek-host ${className}`} ref={ref}>
      {children}
      <span
        className={`peek peek--${phase}`}
        style={{ '--peek-at': at }}
        aria-hidden="true"
      >
        <img className="peek-img" src={peekUrl} alt="" width="288" height="133" draggable="false" />
        {animated && (
          <>
            <span className="peek-lid peek-lid--l" />
            <span className="peek-lid peek-lid--r" />
          </>
        )}
      </span>
    </div>
  );
}
