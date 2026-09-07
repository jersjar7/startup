import React from 'react';
import { Link } from 'react-router-dom';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import { ArrowLeft } from '@phosphor-icons/react';
import { STUDENT_PRICE, STANDARD_PRICE } from '../data/pricing';
import './legal.css';

export function Terms() {
  useDocumentTitle('Terms of Service');

  return (
    <main className="legal-main">
      <div className="legal-card">
        <Link to="/" className="back-link">
          <ArrowLeft size={18} /> Home
        </Link>

        <h1>Terms of Service</h1>
        <p className="legal-updated">Last updated: September 7, 2026</p>

        <section className="legal-section">
          <h2>1. Acceptance of Terms</h2>
          <p>
            By creating an account or using FE for Raccoons ("the Platform," "we," "us," or "our"),
            you agree to be bound by these Terms of Service. If you do not agree, do not use the Platform.
          </p>
        </section>

        <section className="legal-section">
          <h2>2. Description of Service</h2>
          <p>
            FE for Raccoons is an online study platform designed to help users prepare for the
            Fundamentals of Engineering (FE) Civil exam administered by the National Council of
            Examiners for Engineering and Surveying (NCEES). The Platform provides lessons, practice
            problems, progress tracking, and gamified study tools.
          </p>
        </section>

        <section className="legal-section">
          <h2>3. Account Responsibilities</h2>
          <p>
            You must provide a valid email address and create a secure password to register.
            You are responsible for maintaining the confidentiality of your account credentials
            and for all activity that occurs under your account. You agree to notify us immediately
            of any unauthorized use of your account.
          </p>
        </section>

        <section className="legal-section">
          <h2>4. Permitted Use</h2>
          <p>
            The Platform is intended for personal, non-commercial educational use. You may not:
          </p>
          <ul>
            <li>Copy, redistribute, or republish any content from the Platform</li>
            <li>Use automated tools to scrape, crawl, or extract data from the Platform</li>
            <li>Share your account credentials with others</li>
            <li>Attempt to gain unauthorized access to any part of the Platform</li>
            <li>Use the Platform to compete with or replicate its services</li>
          </ul>
        </section>

        <section className="legal-section">
          <h2>5. Intellectual Property</h2>
          <p>
            All original content on the Platform — including lessons, practice problems, illustrations,
            and user interface design — is the property of FE for Raccoons and is protected by
            copyright law. References to the FE Reference Handbook and exam specifications are the
            intellectual property of NCEES. FE for Raccoons is not affiliated with, endorsed by, or
            sponsored by NCEES.
          </p>
        </section>

        <section className="legal-section">
          <h2>6. Educational Disclaimer</h2>
          <p>
            The Platform is a supplemental study tool. We do not guarantee that using the Platform
            will result in passing the FE exam or achieving any particular score. Exam outcomes
            depend on many factors including your own preparation, prior knowledge, and test-day
            performance. The content is provided for educational purposes only and should not be
            used as a sole study resource.
          </p>
        </section>

        <section className="legal-section">
          <h2>7. Limitation of Liability</h2>
          <p>
            To the maximum extent permitted by law, FE for Raccoons and its owner shall not be
            liable for any indirect, incidental, special, consequential, or punitive damages arising
            out of or related to your use of the Platform. This includes, but is not limited to,
            loss of profits, data, or exam results. The Platform is provided "as is" and "as available"
            without warranties of any kind, either express or implied.
          </p>
        </section>

        <section className="legal-section">
          <h2>8. Paid Features</h2>
          <p>
            The lessons, the practice problems and the diagnostic are free, and the free features
            available at the time of your registration will remain accessible to you.
          </p>
          <p>
            The Exam Simulation is the only paid item. It is a one-time purchase of ${STANDARD_PRICE},
            or ${STUDENT_PRICE} for students who verify a .edu email address with a code we send to it.
            It does not renew, it is not a subscription, and it does not expire. Payments are handled by
            Stripe; we never receive or store your card details.
          </p>
          <p>
            <strong>Refunds.</strong> The Exam Simulation carries a 14-day money-back guarantee. Ask us
            for a refund within 14 days of your purchase, for any reason or none, and we will refund it
            in full to the original payment method. You do not have to have used it, and you do not have
            to explain why. Separately, if you sit the FE and do not pass, we will extend your access
            free of charge. Refunding a purchase ends your access to the Exam Simulation; the rest of
            your account, including all of your study progress, is unaffected.
          </p>
          <p>
            To request a refund, email <a href="mailto:fe4raccoons@oqupa.com">fe4raccoons@oqupa.com</a> from the
            address on your account.
          </p>
        </section>

        <section className="legal-section">
          <h2>9. Account Termination and Deletion</h2>
          <p>
            You may delete your account at any time from the Profile page. Deleting your account
            permanently removes all your data from our systems, including your progress, session
            history, and diagnostic results. This action is irreversible.
          </p>
          <p>
            We reserve the right to suspend or terminate accounts that violate these Terms, engage
            in abusive behavior, or compromise the security of the Platform.
          </p>
        </section>

        <section className="legal-section">
          <h2>10. Changes to These Terms</h2>
          <p>
            We may update these Terms from time to time. If we make material changes, we will
            update the "Last updated" date at the top of this page. Your continued use of the
            Platform after changes constitutes acceptance of the revised Terms.
          </p>
        </section>

        <section className="legal-section">
          <h2>11. Governing Law</h2>
          <p>
            These Terms are governed by and construed in accordance with the laws of the State of
            Utah, United States, without regard to its conflict of law provisions.
          </p>
        </section>

        <section className="legal-section">
          <h2>12. Contact</h2>
          <p>
            If you have questions about these Terms, you can reach us at{' '}
            <a href="mailto:fe4raccoons@oqupa.com">fe4raccoons@oqupa.com</a>.
          </p>
        </section>
      </div>
    </main>
  );
}
