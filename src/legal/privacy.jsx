import React from 'react';
import { Link } from 'react-router-dom';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import { ArrowLeft } from '@phosphor-icons/react';
import './legal.css';

export function Privacy() {
  useDocumentTitle('Privacy Policy');

  return (
    <main className="legal-main">
      <div className="legal-card">
        <Link to="/" className="back-link">
          <ArrowLeft size={18} /> Home
        </Link>

        <h1>Privacy Policy</h1>
        <p className="legal-updated">Last updated: September 7, 2026</p>

        <section className="legal-section">
          <h2>1. Overview</h2>
          <p>
            FE for Raccoons ("the Platform," "we," "us," or "our") respects your privacy. This
            Privacy Policy explains what data we collect, how we use it, and your rights regarding
            that data. We are committed to being transparent about our data practices.
          </p>
        </section>

        <section className="legal-section">
          <h2>2. Data We Collect</h2>
          <p>When you use the Platform, we collect the following information:</p>
          <ul>
            <li><strong>Account information:</strong> Your email address and a securely hashed version of your password (we never store your actual password)</li>
            <li><strong>Study progress:</strong> Which problems you've attempted, your answers, mastery levels, and spaced repetition schedules</li>
            <li><strong>Session data:</strong> When you study, how many problems you complete per session, and XP earned</li>
            <li><strong>Diagnostic results:</strong> Scores and responses from practice diagnostic exams</li>
            <li><strong>Account metadata:</strong> Account creation date, email verification status</li>
            <li><strong>Profile details you choose to give us:</strong> Your first and last name and your exam date, all optional. A first name is shown on the leaderboard if you enter one; you can leave these blank or change them at any time on the Profile page.</li>
            <li><strong>How you found us:</strong> The referring website and any campaign tag in the link you arrived on, plus your answer to the one-time "how did you hear about us" question at registration. We use this only to know which channels are worth our effort.</li>
            <li><strong>Purchase records:</strong> If you buy the Exam Simulation, we store the amount, the date, the price tier and the Stripe identifiers for the transaction.</li>
          </ul>
        </section>

        <section className="legal-section">
          <h2>3. Payments</h2>
          <p>
            Payments are processed by Stripe. Your card number never reaches our servers and we
            cannot see it. To take a payment, Stripe collects the billing details it needs, which
            include your name and billing address, and holds them under its own privacy policy. We
            receive only the transaction record described above.
          </p>
        </section>

        <section className="legal-section">
          <h2>4. Analytics</h2>
          <p>
            We use Plausible Analytics on our public pages to count visits. Plausible is
            cookie-free, does not track people across other websites, and does not build a profile
            of you. It records aggregate page views, referrers and country, not individuals.
          </p>
        </section>

        <section className="legal-section">
          <h2>5. Data We Do Not Collect</h2>
          <p>We want to be clear about what we do not do:</p>
          <ul>
            <li>We do not use tracking pixels, ad cookies, or any advertising network. Our only analytics is Plausible, described above, which sets no cookies and cannot follow you off our site</li>
            <li>We do not sell, rent, or share your personal data with third parties for marketing</li>
            <li>We never see or store your card number. Stripe handles payments</li>
            <li>We do not ask for your phone number or your location</li>
            <li>We do not track your browsing activity outside of the Platform</li>
          </ul>
        </section>

        <section className="legal-section">
          <h2>6. How We Use Your Data</h2>
          <p>The data we collect is used exclusively to operate the Platform:</p>
          <ul>
            <li><strong>Authentication:</strong> Your email and hashed password let you log in securely</li>
            <li><strong>Progress tracking:</strong> We save your study progress so you can pick up where you left off</li>
            <li><strong>Gamification:</strong> XP, days studied, badges, and mastery levels are calculated from your session and problem history</li>
            <li><strong>Spaced repetition:</strong> Your problem history determines which problems are scheduled for review</li>
            <li><strong>Email we send you:</strong> Password reset and email verification messages, a welcome note, a weekly progress digest, exam-countdown reminders if you have entered an exam date, and an occasional nudge if you have been away. Every non-essential email carries a one-click unsubscribe link, and unsubscribing never affects your account</li>
          </ul>
        </section>

        <section className="legal-section">
          <h2>7. Cookies</h2>
          <p>
            We use a single cookie for authentication. This cookie is:
          </p>
          <ul>
            <li><strong>HttpOnly:</strong> It cannot be accessed by JavaScript (protection against XSS attacks)</li>
            <li><strong>Secure:</strong> It is only sent over HTTPS connections</li>
            <li><strong>SameSite strict:</strong> It is not sent with cross-site requests (protection against CSRF attacks)</li>
            <li><strong>Session duration:</strong> It expires after 7 days of inactivity</li>
          </ul>
          <p>
            We do not use advertising cookies, analytics cookies, or any third-party cookies.
          </p>
        </section>

        <section className="legal-section">
          <h2>8. Third-Party Services</h2>
          <p>We use the following third-party services to operate the Platform:</p>
          <ul>
            <li><strong>MongoDB Atlas:</strong> Cloud database hosted on AWS (US East region) for storing your account and study data. <a href="https://www.mongodb.com/legal/privacy-policy" target="_blank" rel="noopener noreferrer">MongoDB Privacy Policy</a></li>
            <li><strong>Resend:</strong> Transactional email service used to send password reset and email verification messages. <a href="https://resend.com/legal/privacy-policy" target="_blank" rel="noopener noreferrer">Resend Privacy Policy</a></li>
            <li><strong>Amazon Web Services (AWS):</strong> Cloud hosting for the Platform servers. <a href="https://aws.amazon.com/privacy/" target="_blank" rel="noopener noreferrer">AWS Privacy Policy</a></li>
            <li><strong>Stripe:</strong> Payment processing for the Exam Simulation. Stripe collects and holds the card and billing details; we never see your card number. <a href="https://stripe.com/privacy" target="_blank" rel="noopener noreferrer">Stripe Privacy Policy</a></li>
            <li><strong>Plausible Analytics:</strong> Cookie-free visitor counts on our public pages, with no cross-site tracking and no personal profiles. <a href="https://plausible.io/privacy" target="_blank" rel="noopener noreferrer">Plausible Privacy Policy</a></li>
          </ul>
          <p>
            These services process your data solely to provide their respective functions. We do not
            share your data with any other third parties.
          </p>
        </section>

        <section className="legal-section">
          <h2>9. Data Security</h2>
          <p>We take reasonable measures to protect your data:</p>
          <ul>
            <li>Passwords are hashed with bcrypt (industry-standard one-way hashing)</li>
            <li>All connections use HTTPS encryption</li>
            <li>Authentication tokens are stored as HttpOnly secure cookies</li>
            <li>Password reset tokens are SHA-256 hashed before storage</li>
            <li>Database access is restricted to authenticated application connections</li>
          </ul>
          <p>
            No system is perfectly secure. While we strive to protect your data, we cannot guarantee
            absolute security.
          </p>
        </section>

        <section className="legal-section">
          <h2>10. Data Retention and Deletion</h2>
          <p>
            We retain your data for as long as your account is active. You can delete your account
            at any time from the <Link to="/profile">Profile page</Link>. When you delete your account,
            all your data is permanently removed from our systems, including:
          </p>
          <ul>
            <li>Your account and credentials</li>
            <li>All study progress and mastery data</li>
            <li>Session history and XP records</li>
            <li>Diagnostic exam results</li>
            <li>Badge and days-studied data</li>
          </ul>
          <p>This deletion is immediate and irreversible.</p>
        </section>

        <section className="legal-section">
          <h2>11. Children's Privacy</h2>
          <p>
            The Platform is designed for adults preparing for the FE professional engineering exam.
            We do not knowingly collect data from children under 13. If you believe a child has
            created an account, please contact us and we will delete it promptly.
          </p>
        </section>

        <section className="legal-section">
          <h2>12. Your Rights</h2>
          <p>You have the right to:</p>
          <ul>
            <li><strong>Access your data:</strong> Your study progress and account information are visible on the Dashboard and Profile pages</li>
            <li><strong>Delete your data:</strong> You can permanently delete your account and all associated data from the Profile page</li>
            <li><strong>Change your credentials:</strong> You can update your password from the Profile page</li>
          </ul>
          <p>
            If you have additional data requests, contact us at{' '}
            <a href="mailto:fe4raccoons@oqupa.com">fe4raccoons@oqupa.com</a>.
          </p>
        </section>

        <section className="legal-section">
          <h2>13. Changes to This Policy</h2>
          <p>
            We may update this Privacy Policy from time to time. If we make material changes, we
            will update the "Last updated" date at the top of this page. Your continued use of the
            Platform after changes constitutes acceptance of the revised policy.
          </p>
        </section>

        <section className="legal-section">
          <h2>14. Contact</h2>
          <p>
            If you have questions about this Privacy Policy or your data, you can reach us at{' '}
            <a href="mailto:fe4raccoons@oqupa.com">fe4raccoons@oqupa.com</a>.
          </p>
        </section>
      </div>
    </main>
  );
}
