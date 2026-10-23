import React from 'react';

// "Also on your phone": introduces the mobile app with the App Store header
// art. It says "coming very soon" with no store badges or links on purpose:
// the owner wants both badges to go up together on the day the App Store
// listing is live, even though Google Play is already live.
export function AppComingSoon() {
  return (
    <section className="s-app">
      <div className="s-app__inner">
        <span className="section-label">
          <span className="section-label-dash" />
          Coming very soon
        </span>
        <h2 className="s-app__heading">
          One concept at a time, <em>in the minutes between.</em>
        </h2>
        <p className="s-app__sub">
          The FE for Raccoons phone app turns each lesson into short rounds built on the same
          drawings you study here. Completely free, for iPhone and Android.
        </p>
      </div>
      <img
        className="s-app__art"
        src="/brand/app-phones-1920.webp"
        srcSet="/brand/app-phones-960.webp 960w, /brand/app-phones-1920.webp 1920w"
        sizes="(max-width: 1400px) 100vw, 1400px"
        width="1920"
        height="665"
        loading="lazy"
        alt="Three phones showing the FE for Raccoons app: a concept lesson on foundations, a Mohr's circle round, and Today's Daily, with a truss drawing and a seepage drawing lifted out beside them."
      />
    </section>
  );
}
