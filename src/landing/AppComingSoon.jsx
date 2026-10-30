import React from 'react';
import { Link } from 'react-router-dom';
import { GooglePlayLogo } from '@phosphor-icons/react';
import { AppArrow } from '../components/brand/AppArrow';
import { PLAY_URL, APP_PAGE } from '../data/appLinks';

// "Also on your phone": introduces the mobile app with the App Store header
// art. Until 2026-10-29 it said "coming very soon" with no store links, so
// both badges could go up together; the owner then chose to point at Google
// Play now and keep iPhone as "coming soon" in plain words.
export function AppComingSoon() {
  return (
    <section className="s-app">
      <div className="s-app__inner">
        <span className="section-label">
          <span className="section-label-dash" />
          The phone app
        </span>
        <h2 className="s-app__heading">
          One concept at a time, <em>in the minutes between.</em>
        </h2>
        <p className="s-app__sub">
          The FE for Raccoons phone app turns each lesson into short rounds built on the same
          drawings you study here. Completely free.
        </p>
        <div className="s-app__get">
          <a className="s-app__play" href={PLAY_URL} target="_blank" rel="noopener noreferrer">
            <GooglePlayLogo size={20} weight="bold" aria-hidden="true" />
            Get it on Google Play
            <AppArrow />
          </a>
          <Link className="s-app__more" to={APP_PAGE}>See how the app works</Link>
        </div>
        <p className="s-app__soon">iPhone: coming soon to the App Store.</p>
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
