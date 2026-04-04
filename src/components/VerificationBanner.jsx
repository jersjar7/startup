import React from 'react';
import { ShieldWarning } from '@phosphor-icons/react';

export function VerificationBanner({ emailVerified }) {
  const [dismissed, setDismissed] = React.useState(false);
  const [resending, setResending] = React.useState(false);
  const [sent, setSent] = React.useState(false);

  if (emailVerified !== false || dismissed) return null;

  async function handleResend() {
    setResending(true);
    try {
      await fetch('/api/auth/resend-verification', { method: 'POST' });
      setSent(true);
    } catch {
      // silently fail
    } finally {
      setResending(false);
    }
  }

  return (
    <div className="verification-banner" role="alert">
      <div className="verification-banner-content">
        <ShieldWarning size={18} weight="bold" />
        <span>
          {sent
            ? 'Verification email sent! Check your inbox.'
            : 'Please verify your email address.'}
        </span>
      </div>
      <div className="verification-banner-actions">
        {!sent && (
          <button onClick={handleResend} disabled={resending} className="verification-resend-btn">
            {resending ? 'Sending...' : 'Resend'}
          </button>
        )}
        <button onClick={() => setDismissed(true)} className="verification-dismiss-btn" aria-label="Dismiss">
          &times;
        </button>
      </div>
    </div>
  );
}
