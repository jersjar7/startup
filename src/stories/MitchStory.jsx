import React from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight, CheckCircle } from '@phosphor-icons/react';
import { useSeo } from '../seo/useSeo';
import { STUDENT_PRICE, STANDARD_PRICE } from '../data/pricing';
import './stories.css';

const SITE = 'https://fe4raccoons.com';

// A single, honest student story: Mitch ran a full timed exam simulation, then
// passed the Civil FE on his first try. The page hosts his video on-brand (so
// viewers stay in the funnel, no sign-in wall) and points straight at the sim.
export function MitchStory() {
  const url = `${SITE}/stories/mitch`;
  const title = 'How Mitch passed the FE Civil on his first try | FE for Raccoons';
  const description =
    'Mitch ran a full, timed exam simulation before test day, then passed the FE Civil exam on his first try. Watch his story and run the same simulation before your exam.';

  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'VideoObject',
    name: 'How Mitch passed the FE Civil on his first try',
    description,
    thumbnailUrl: `${SITE}/stories/mitch-poster.jpg`,
    contentUrl: `${SITE}/stories/mitch.mp4`,
    uploadDate: '2026-06-01',
    publisher: { '@type': 'Organization', name: 'FE for Raccoons', url: SITE },
  };

  useSeo({ title, description, canonical: url, jsonLd });

  return (
    <main className="story">
      <div className="story-inner">
        <p className="story-overline">Student story</p>
        <h1 className="story-h1">
          He walked into the FE<br />already knowing how it felt.
        </h1>
        <p className="story-lede">
          Mitch ran a full, timed exam simulation before test day. Then he
          passed the FE Civil on his first try. Here it is in his words.
        </p>

        <div className="story-video-wrap">
          <video
            className="story-video"
            controls
            playsInline
            preload="none"
            poster="/stories/mitch-poster.jpg"
          >
            <source src="/stories/mitch.mp4" type="video/mp4" />
            Your browser does not support the video tag.
          </video>
        </div>
        <p className="story-caption">Mitch, FE Civil, passed on his first attempt.</p>

        <div className="story-cta-card">
          <p className="story-cta-kicker">Do the same before your exam</p>
          <h2 className="story-cta-title">The Exam Simulation</h2>
          <p className="story-cta-body">
            All 110 questions, 5 hours 20 minutes, scored just like the real FE.
            One full timed run before the real one, so on exam day nothing feels
            new.
          </p>
          <ul className="story-cta-list">
            <li>
              <CheckCircle size={20} weight="fill" />
              <span>See exactly where your pace slips, while there's still time to fix it.</span>
            </li>
            <li>
              <CheckCircle size={20} weight="fill" />
              <span>Learn which topics to spend your last weeks on, ranked by what actually cost you points.</span>
            </li>
            <li>
              <CheckCircle size={20} weight="fill" />
              <span>Feel what 5 hours 20 minutes in the chair is really like, so exam day is familiar.</span>
            </li>
          </ul>
          <Link to="/exam" className="story-cta-btn">
            Start your exam simulation <ArrowRight size={18} weight="bold" />
          </Link>
          <p className="story-price">
            ${STANDARD_PRICE}, or ${STUDENT_PRICE} with a verified student email. Your access never expires.
          </p>
        </div>
      </div>
    </main>
  );
}
