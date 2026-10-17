import React from 'react';
import { Link } from 'react-router-dom';
import { ArrowLeft, EnvelopeSimple } from '@phosphor-icons/react';
import { useSeo } from '../seo/useSeo';
import './about.css';

// The tester's point 12b (build 1075 notes): who made this, why, why the
// name, and what the free access and the two halves are. The owner's own
// words, approved 2026-10-17. The app's About page
// (mobile/lib/features/profile/about_story.dart) carries the same text; keep
// the two the same.
export function About() {
  useSeo({
    title: 'About | FE for Raccoons',
    description:
      'Why FE for Raccoons exists: a recent BYU civil engineering graduate building the free FE Civil prep he wished he had.',
    canonical: 'https://fe4raccoons.com/about',
  });

  return (
    <main className="about-main">
      <article className="about-card">
        <Link to="/" className="back-link">
          <ArrowLeft size={18} /> Home
        </Link>

        <h1>Why this exists</h1>
        <p>
          I'm Jerson, a recent graduate. I finished my master's in Civil Engineering at BYU in May 2025.
        </p>
        <p>
          Some engineering concepts were really hard for me. Not all of them, but some took a lot of
          work, and I wished I had something to learn from other than the books. There is only so much
          teaching assistants and professors can do, and a lot of the time I was on my own. I wished I
          had one place where I could study all my courses and find what I needed.
        </p>
        <p>
          I needed that most when I was preparing for the FE exam. The exam covers so many courses and
          chapters that I had to pull resources together from many different places, and almost none of
          them explained things in simple terms. I believe a lot of civil engineering concepts are really
          hard, but explained well, they make sense.
        </p>
        <p>
          With what I studied, and what I learned building websites and mobile apps, I thought I could
          make an impact and give other students the resource I wish I'd had. FE for Raccoons launched in
          June 2026. I'm glad it has been well received, and it has already helped hundreds of students
          prepare for the FE.
        </p>

        <h2>Why it's free</h2>
        <p>
          In college I saw other students, and their families, making a big sacrifice for them to be
          there. What I didn't like about the resources I found online is how expensive they are. Even the
          materials NCEES provides cost a lot, and the exam itself is over $200. For a college student
          that's real money. It felt like these places were taking advantage of students who are already
          working hard to be in college and to pay for their own tuition and materials.
        </p>
        <p>
          So I made this site mostly free, even though it has its own costs. The only thing I charge for
          is the timed <Link to="/exam-simulation">exam simulation</Link>, and it's optional for every
          user.
        </p>

        <h2>How it teaches</h2>
        <p>
          Every problem comes with a "teach me like I'm five" explanation: the idea in plain words before
          the math. The website is where you learn the material and earn your mastery. The app is for the
          time in between, when you're away from your desk and have a few minutes to keep the concepts
          fresh, a few rounds at a time.
        </p>

        <h2>Why raccoons?</h2>
        <p>
          Honestly, there's no special reason. I wanted it to be fun and different. I didn't want
          something serious like "FE for College Students" or "FE for Future Civil Engineers". I wanted a
          name that would stick, maybe even make you ask "why raccoons?", so that even if you heard it
          only once, you'd remember it the next time you wanted to study. And raccoons are cute.
        </p>
        <p>I'd rather not tell you what they mean, though. Make them mean whatever you like.</p>

        <div className="about-sign">
          <span>Jerson J. Garcia, EIT</span>
          <Link to="/contact" className="about-contact">
            <EnvelopeSimple size={18} weight="bold" /> Write to me
          </Link>
        </div>
      </article>
    </main>
  );
}
