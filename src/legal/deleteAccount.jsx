import React from 'react';
import { Link } from 'react-router-dom';
import { useSeo } from '../seo/useSeo';
import { ArrowLeft } from '@phosphor-icons/react';
import './legal.css';

// Google Play requires a publicly reachable page, needing no sign-in and no
// install, where somebody can find out how to delete their account and ask for
// it to be deleted. It is a required field on the Data Safety form for any app
// that lets people create an account, and a privacy policy that mentions
// deletion in passing is not accepted as one.
//
// Everything on this page is checked against service/db/accountDeletion.js.
// If that file changes, this page changes with it: promising to erase
// something we keep is worse than keeping it.
export function DeleteAccount() {
  // useSeo rather than useDocumentTitle: this page is prerendered, and the
  // prerenderer waits on the signal this hook sets. Google fetches this URL
  // from the Data Safety form, so it has to be real HTML, not an SPA shell.
  useSeo({
    title: 'Delete your account | FE for Raccoons',
    description:
      'How to delete your FE for Raccoons account and everything in it, from '
      + 'the website or the mobile app, and how to ask us to do it if you '
      + 'cannot sign in.',
    canonical: 'https://fe4raccoons.com/delete-account',
  });

  return (
    <main className="legal-main">
      <div className="legal-card">
        <Link to="/" className="back-link">
          <ArrowLeft size={18} /> Home
        </Link>

        <h1>Delete your account</h1>
        <p className="legal-updated">Applies to fe4raccoons.com and the FE4Raccoons mobile app</p>

        <section className="legal-section">
          <h2>Delete it yourself, in about ten seconds</h2>
          <p>
            You do not need to ask us, and you do not need to install anything. Deleting from
            either place deletes everywhere, because the website and the app are one account.
          </p>
          <ul>
            <li>
              <strong>On the website:</strong> sign in, open the{' '}
              <Link to="/profile">Profile page</Link>, scroll to Delete Account, enter your
              password and type DELETE.
            </li>
            <li>
              <strong>In the mobile app:</strong> open Profile, tap your account, choose Delete
              account, and enter your password.
            </li>
          </ul>
          <p>
            Your password is asked for because this cannot be undone. There is no grace period and
            no way for us to restore an account afterwards.
          </p>
        </section>

        <section className="legal-section">
          <h2>If you cannot sign in</h2>
          <p>
            Email <a href="mailto:fe4raccoons@oqupa.com">fe4raccoons@oqupa.com</a> from the address
            on the account and ask us to delete it. We will confirm and delete it by hand. We
            answer these within a few days, and we will not ask you to do anything else first.
          </p>
        </section>

        <section className="legal-section">
          <h2>What is erased</h2>
          <p>Deleting the account removes all of this immediately and permanently:</p>
          <ul>
            <li>Your account, email address and password</li>
            <li>Every problem you have answered and the mastery built from it</li>
            <li>Session history, XP, badges and days studied</li>
            <li>Diagnostic and quick-start results</li>
            <li>Exam Simulation attempts and your purchase records</li>
            <li>Everything the mobile app recorded: rounds, hand-offs to paper, and feedback</li>
            <li>Your answer to how you found us</li>
          </ul>
        </section>

        <section className="legal-section">
          <h2>The one thing we keep, and why</h2>
          <p>
            We keep a single counter row recording that an account was deleted on a given date,
            which reason it was deleted for, and three facts with no person attached: whether the
            email had been verified, roughly how old the account was, and whether it had ever
            bought anything. It holds no name, no email address and no identifier, so it cannot be
            traced back to you or to anyone else.
          </p>
          <p>
            It exists so the account total does not quietly drop with nothing to explain it. If you
            would rather we did not keep even that, say so in your email and we will leave it out.
          </p>
        </section>

        <section className="legal-section">
          <h2>Related</h2>
          <p>
            Full detail on what we collect and why is in the{' '}
            <Link to="/privacy">Privacy Policy</Link>. Account terms are in the{' '}
            <Link to="/terms">Terms of Service</Link>.
          </p>
        </section>
      </div>
    </main>
  );
}
