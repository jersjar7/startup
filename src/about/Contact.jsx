import React from 'react';
import { Link } from 'react-router-dom';
import { ArrowLeft, PaperPlaneRight, CheckCircle } from '@phosphor-icons/react';
import { useSeo } from '../seo/useSeo';
import './about.css';

// "Contact us" (the tester's point 12a). One message box that emails the
// owner (POST /api/feedback/contact, service/contact.js). Signed in, the
// account's address goes with it; signed out, the visitor gives one.
export function Contact({ userName = '' }) {
  useSeo({
    title: 'Contact | FE for Raccoons',
    description: 'Send FE for Raccoons a message. A person reads every one and writes back.',
    canonical: 'https://fe4raccoons.com/contact',
  });

  const signedIn = !!userName;
  const [message, setMessage] = React.useState('');
  const [email, setEmail] = React.useState('');
  const [name, setName] = React.useState('');
  const [website, setWebsite] = React.useState(''); // the hidden field bots fill
  const [state, setState] = React.useState('idle'); // idle | sending | sent
  const [error, setError] = React.useState('');

  async function send(e) {
    e.preventDefault();
    setError('');
    if (!message.trim()) return setError('Write a message first.');
    if (!signedIn && !email.trim()) return setError('Add an email address so we can write back.');
    setState('sending');
    try {
      const r = await fetch('/api/feedback/contact', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({ message, email, name, website, source: 'web' }),
      });
      if (!r.ok) {
        const body = await r.json().catch(() => ({}));
        setError(body.msg || 'That did not send. Try again in a minute.');
        setState('idle');
        return;
      }
      setState('sent');
    } catch {
      setError('That did not send. Check your connection and try again.');
      setState('idle');
    }
  }

  return (
    <main className="about-main">
      <article className="about-card">
        <Link to="/" className="back-link">
          <ArrowLeft size={18} /> Home
        </Link>

        <h1>Contact us</h1>
        {state === 'sent' ? (
          <div className="contact-sent" role="status">
            <CheckCircle size={28} weight="bold" />
            <div>
              <p className="contact-sent-title">Sent. Thank you.</p>
              <p>A person reads every message and writes back to the address it came from.</p>
            </div>
          </div>
        ) : (
          <>
            <p>
              A question, a problem that looks wrong, something you wish the site did. A person reads every
              message and writes back.
            </p>
            <form className="contact-form" onSubmit={send} noValidate>
              <label htmlFor="contact-message">Your message</label>
              <textarea
                id="contact-message"
                rows={7}
                maxLength={2000}
                value={message}
                onChange={(e) => setMessage(e.target.value)}
              />
              {signedIn ? (
                <p className="contact-from">We'll reply to the email on your account.</p>
              ) : (
                <div className="contact-row">
                  <div>
                    <label htmlFor="contact-email">Your email</label>
                    <input id="contact-email" type="email" autoComplete="email" value={email} onChange={(e) => setEmail(e.target.value)} />
                  </div>
                  <div>
                    <label htmlFor="contact-name">Your name <span className="contact-optional">(optional)</span></label>
                    <input id="contact-name" type="text" autoComplete="name" value={name} onChange={(e) => setName(e.target.value)} />
                  </div>
                </div>
              )}
              <div className="contact-hp" aria-hidden="true">
                <label htmlFor="contact-website">Website</label>
                <input id="contact-website" type="text" tabIndex={-1} autoComplete="off" value={website} onChange={(e) => setWebsite(e.target.value)} />
              </div>
              {error && <p className="contact-error" role="alert">{error}</p>}
              <button type="submit" className="btn-primary contact-send" disabled={state === 'sending'}>
                <PaperPlaneRight size={18} weight="bold" /> {state === 'sending' ? 'Sending' : 'Send message'}
              </button>
            </form>
          </>
        )}
        <p className="contact-about">
          Want to know who's behind this? <Link to="/about">Read why it exists</Link>.
        </p>
      </article>
    </main>
  );
}
