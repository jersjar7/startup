import React from 'react';
import { Link } from 'react-router-dom';
import { GooglePlayLogo } from '@phosphor-icons/react';
import { useSeo } from '../seo/useSeo';
import { pageTitle } from '../seo/pageTitle';
import { AppArrow } from '../components/brand/AppArrow';
import { PLAY_URL, APP_PAGE } from '../data/appLinks';
import './public.css';
import './appPage.css';

const SITE = 'https://fe4raccoons.com';

// A real screen from the app, in a plain phone frame. The images are the
// app's own store captures (mobile/test/goldens/appstore), exported to
// public/app/ at two widths. The figure is a size container so the bezel and
// the screen corners scale with the phone and stay concentric at every size.
function Phone({ name, alt, className = '' }) {
  return (
    <figure className={`ap-phone ${className}`}>
      <div className="ap-phone-body">
        <img
          src={`/app/${name}-360.webp`}
          srcSet={`/app/${name}-360.webp 360w, /app/${name}-720.webp 720w`}
          sizes="(max-width: 600px) 60vw, 280px"
          width="360"
          height="782"
          loading="lazy"
          alt={alt}
        />
      </div>
    </figure>
  );
}

function PlayButton() {
  return (
    <a className="pub-btn pub-btn-primary ap-play" href={PLAY_URL} target="_blank" rel="noopener noreferrer">
      <GooglePlayLogo size={22} weight="bold" aria-hidden="true" />
      Get it on Google Play
      <AppArrow />
    </a>
  );
}

const STEPS = [
  {
    phone: 'study',
    alt: 'The app\'s Study tab, showing the Mathematics chapter with the next lesson and a Continue button.',
    title: 'Pick up a lesson',
    body: 'The app follows the same 15 chapters and lessons as the website. Open the chapter you are studying and keep going from where you left off.',
  },
  {
    phone: 'round-mohr',
    alt: 'A round asking which point on a Mohr\'s circle is the largest stress pulling a point apart.',
    title: 'Read the drawing, make the call',
    body: 'Each round puts a real engineering figure in front of you: a flow net, a Mohr\'s circle, a truss. You answer on the drawing itself, the way you read figures on the exam.',
  },
  {
    phone: 'sheet-piles',
    alt: 'A concept sheet on deep foundations: a footing on soft clay, then piles carrying the load past it.',
    title: 'See why it works',
    body: 'Every concept starts with a picture and a few short steps, so the next round makes sense before you play it, and points you to the handbook section it comes from.',
  },
];

export function AppPage() {
  const title = pageTitle('FE Civil Study App for Android, iPhone Coming Soon');
  const description = 'The FE for Raccoons phone app: short FE Civil concept rounds built on real engineering drawings, a chapter path and a daily challenge. Completely free on Google Play.';
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'MobileApplication',
    name: 'FE for Raccoons',
    operatingSystem: 'Android',
    applicationCategory: 'EducationalApplication',
    description,
    url: `${SITE}${APP_PAGE}`,
    downloadUrl: PLAY_URL,
    offers: { '@type': 'Offer', price: '0', priceCurrency: 'USD' },
    publisher: { '@type': 'Organization', name: 'FE for Raccoons', url: SITE },
  };
  useSeo({ title, description, canonical: `${SITE}${APP_PAGE}`, jsonLd });

  return (
    <main className="pub ap">
      <header className="ap-hero">
        <div className="ap-hero-text">
          <p className="pub-label">The phone app</p>
          <h1>FE for Raccoons, now on your phone</h1>
          <p className="pub-lede">
            Short rounds built on the same drawings you study on the website. Read a figure, make
            the call, and see why, in the few minutes you have between classes. Completely free.
          </p>
          <div className="ap-get">
            <PlayButton />
            <p className="ap-soon">iPhone: coming soon to the App Store.</p>
          </div>
        </div>
        <div className="ap-hero-phones" aria-hidden="false">
          <Phone name="calendar" className="ap-phone--back" alt="Days studied: 27 days since August 3, with a calendar of the days you studied." />
          <Phone name="round-seepage" className="ap-phone--front" alt="A round on a flow net under a sheet pile wall, asking which way round the flow channels and head drops go in the seepage formula." />
        </div>
      </header>

      <section className="ap-section" aria-labelledby="ap-how">
        <h2 id="ap-how">How a round works</h2>
        <ol className="ap-steps">
          {STEPS.map((s, i) => (
            <li key={s.phone} className="ap-step">
              <Phone name={s.phone} alt={s.alt} />
              <span className="ap-step-n">{i + 1}</span>
              <h3>{s.title}</h3>
              <p>{s.body}</p>
            </li>
          ))}
        </ol>
      </section>

      <section className="ap-section" aria-labelledby="ap-why">
        <h2 id="ap-why">Why it keeps you coming back</h2>
        <p className="pub-section-lede">
          Two ideas borrowed from apps people already open every day, put to work on the FE.
        </p>

        <div className="ap-idea">
          <div className="ap-idea-phones">
            <Phone name="map" alt="Chapter 1 as a path of lessons: Straight Lines, Logarithms and Right Triangle Trigonometry cleared, one after another." />
          </div>
          <div className="ap-idea-text">
            <p className="pub-label">The chapter path</p>
            <h3>A path through every chapter, inspired by Duolingo</h3>
            <p>
              Each chapter is a road of lessons you clear one at a time, the same idea that keeps
              millions of people learning a language a few minutes a day. You always know where you
              are and what comes next, and short steps make it easy to come back tomorrow.
            </p>
          </div>
        </div>

        <div className="ap-idea ap-idea--flip">
          <div className="ap-idea-phones ap-idea-phones--pair">
            <Phone name="daily-today" alt="Today's Daily before you play: three concepts from three chapters and a Play button." />
            <Phone name="daily-results" alt="The Daily results screen with a chart of how many players got each score and a list of the fastest players, shown with sample players." />
          </div>
          <div className="ap-idea-text">
            <p className="pub-label">The Daily</p>
            <h3>One challenge a day, inspired by Wordle</h3>
            <p>
              Three games from three chapters, the same for every student, played once a day. When
              you finish, you see how everyone did and where you landed. Once enough students from
              your school play, your school gets its own board.
            </p>
            <p>
              Sharing your result shows your score and time without giving away a single answer, so
              a friend can still play it fresh.
            </p>
            <p className="ap-note">The results screen above is shown with sample players.</p>
          </div>
        </div>
      </section>

      <section className="ap-section" aria-labelledby="ap-fit">
        <h2 id="ap-fit">Made to work with the website, not replace it</h2>
        <p className="pub-section-lede">
          The phone is for the minutes in between. Full problems and your mastery score live at the
          desk, where you have paper and the handbook open.
        </p>
        <div className="ap-split">
          <div className="ap-split-col">
            <h3>On your phone</h3>
            <ul>
              <li>Short concept rounds on real drawings, one idea at a time.</li>
              <li>The Daily, the same three games for every student.</li>
              <li>A warm-up that keeps the ideas fresh between study sessions.</li>
            </ul>
          </div>
          <div className="ap-split-col ap-split-col--desk">
            <h3>At your desk, on the website</h3>
            <ul>
              <li>Full FE-style problems with step-by-step solutions.</li>
              <li>The diagnostic that builds your study plan.</li>
              <li>Mastery, earned only on full problems. Rounds on the phone never inflate it.</li>
            </ul>
          </div>
          <div className="ap-split-phone">
            <Phone name="mastery" alt="The app's mastery screen: 21 percent, earned at the desk on the website, with a chart of which chapters to work on first." />
          </div>
        </div>
        <p className="ap-shared">
          <strong>One account for both.</strong> The days you study count across the app and the
          website, and the practice you do in the app shows under each chapter on your dashboard.
        </p>
      </section>

      <section className="ap-end" aria-labelledby="ap-end">
        <h2 id="ap-end">Try a round on your next break</h2>
        <div className="ap-get">
          <PlayButton />
          <Link className="pub-btn pub-btn-ghost" to="/login">Or start on the website</Link>
        </div>
        <p className="ap-soon">iPhone: coming soon to the App Store.</p>
      </section>
    </main>
  );
}
