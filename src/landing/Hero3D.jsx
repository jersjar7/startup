import React, { Suspense } from 'react';
import { HeroSvg } from './hero-svg';

// Lazy-load the Three.js scene so the ~Three bundle never blocks first paint and
// never ships to crawlers/SSR. The SVG hero is the fallback for reduced-motion,
// small screens, no-WebGL, and while the 3D chunk is still loading.
const HeroScene = React.lazy(() => import('./HeroScene').then((m) => ({ default: m.HeroScene })));

function canUse3D() {
  if (typeof window === 'undefined') return false;
  if (window.matchMedia?.('(prefers-reduced-motion: reduce)').matches) return false;
  if (window.matchMedia?.('(max-width: 768px)').matches) return false;
  try {
    const c = document.createElement('canvas');
    if (!(c.getContext('webgl2') || c.getContext('webgl'))) return false;
  } catch {
    return false;
  }
  return true;
}

export function Hero3D() {
  // Decide on the client only — SSR/prerender and the first paint get the SVG.
  const [use3D, setUse3D] = React.useState(false);
  React.useEffect(() => {
    setUse3D(canUse3D());
  }, []);

  if (!use3D) return <HeroSvg />;

  return (
    <div className="hero-3d" aria-hidden="true">
      <Suspense fallback={<HeroSvg />}>
        <HeroScene />
      </Suspense>
    </div>
  );
}
