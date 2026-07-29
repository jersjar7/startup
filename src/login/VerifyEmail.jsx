import React from 'react';
import { useParams, Link } from 'react-router-dom';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import { CheckCircle, WarningCircle, SpinnerGap } from '@phosphor-icons/react';
import { SourcePrompt } from '../dashboard/SourcePrompt';
import './index.css';

export function VerifyEmail() {
  useDocumentTitle('Verify Email');
  const { token } = useParams();
  const [status, setStatus] = React.useState('loading'); // loading | success | error
  const [message, setMessage] = React.useState('');
  // Attribution is asked here because this screen is the one step every verified
  // user passes through, regardless of whether they ever open a lesson. Asking
  // on the dashboard instead meant only already-engaged users were ever counted.
  const [askedSource, setAskedSource] = React.useState(false);

  React.useEffect(() => {
    let cancelled = false;
    async function verify() {
      try {
        const res = await fetch(`/api/auth/verify-email/${token}`);
        const body = await res.json();
        if (cancelled) return;
        if (res.ok) {
          setStatus('success');
          setMessage(body.msg);
        } else {
          setStatus('error');
          setMessage(body.msg || 'Verification failed');
        }
      } catch {
        if (!cancelled) {
          setStatus('error');
          setMessage('Network error. Please try again.');
        }
      }
    }
    verify();
    return () => { cancelled = true; };
  }, [token]);

  return (
    <main className="login-main">
      <div className="login-form-container" style={{ textAlign: 'center' }}>
        {status === 'loading' && (
          <>
            <SpinnerGap size={48} weight="bold" color="var(--ember)" className="spin" style={{ marginBottom: '1rem' }} />
            <h2>Verifying...</h2>
            <p className="login-subtitle">Please wait while we verify your email.</p>
          </>
        )}
        {status === 'success' && (
          <>
            <CheckCircle size={48} weight="bold" color="var(--forest)" style={{ marginBottom: '1rem' }} />
            <h2>Email Verified</h2>
            <p className="login-subtitle">{message}</p>
            {/* Mandatory single tap, per the 90-day plan: the continue link does
                not appear until they answer. verify-email issues no session, so
                `deferred` parks the answer in localStorage for the dashboard to
                flush on the next authenticated render. */}
            {!askedSource ? (
              <SourcePrompt
                className="is-standalone"
                deferred
                dismissible={false}
                onClose={() => setAskedSource(true)}
              />
            ) : (
              <Link to="/dashboard" className="btn-primary" style={{ display: 'inline-flex', textDecoration: 'none', marginTop: '0.5rem' }}>
                Go to Dashboard
              </Link>
            )}
          </>
        )}
        {status === 'error' && (
          <>
            <WarningCircle size={48} weight="bold" color="var(--error)" style={{ marginBottom: '1rem' }} />
            <h2>Verification Failed</h2>
            <p className="login-subtitle">{message}</p>
            <Link to="/login" className="btn-primary" style={{ display: 'inline-flex', textDecoration: 'none', marginTop: '0.5rem' }}>
              Go to Login
            </Link>
          </>
        )}
      </div>
    </main>
  );
}
