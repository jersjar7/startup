import React from 'react';
import { useCallback, useEffect, useRef, useState } from 'react';
import { useParams } from 'react-router-dom';

import { passCardData, passCardFilename, CARD } from '../data/passCard.js';
import { drawPassCard, renderPassCard, passCardBlob } from '../components/passCard/drawPassCard.js';
import './passCard.css';

// The reward for passing, reached from the email in one tap with no sign in.
//
// Three states, in the order somebody meets them: the card, the name question
// when the account has none, and the PE question once the card is theirs. The
// PE question comes last on purpose. It is research, and a celebration is not a
// toll gate for research.

/// The preview. Redrawn whenever the data changes, and once more when the brand
/// faces land: canvas takes whatever font is loaded the moment it draws, with no
/// callback and no error, so drawing once would ship the card in Helvetica for
/// anybody whose fonts had not arrived.
function CardPreview({ data }) {
  const ref = useRef(null);

  useEffect(() => {
    const canvas = ref.current;
    if (!canvas || !data) return;
    const paint = () => drawPassCard(canvas, data);
    paint();
    let live = true;
    document.fonts?.ready?.then(() => { if (live) paint(); }).catch(() => {});
    return () => { live = false; };
  }, [data]);

  return (
    <canvas
      ref={ref}
      className="pc-canvas"
      width={CARD.width}
      height={CARD.height}
      role="img"
      aria-label={
        data?.name
          ? `${data.name} passed the FE Civil exam in ${data.when}.`
          : 'The FE Civil pass card, waiting for a name.'
      }
    />
  );
}

export default function PassCard() {
  const { token } = useParams();
  const [state, setState] = useState('loading'); // loading | naming | ready | gone | error
  const [account, setAccount] = useState(null);
  const [name, setName] = useState('');
  const [saving, setSaving] = useState(false);
  const [problem, setProblem] = useState(null);
  const [pe, setPe] = useState(null);

  useEffect(() => {
    let live = true;
    (async () => {
      try {
        const r = await fetch(`/api/email/pass-card/${encodeURIComponent(token)}`);
        if (!live) return;
        if (r.status === 404) return setState('gone');
        if (!r.ok) return setState('error');
        const data = await r.json();
        if (!live) return;
        setAccount(data);
        // Account creation has never collected a name, so this is the ordinary
        // path rather than a fallback.
        setState(data.hasName ? 'ready' : 'naming');
      } catch {
        if (live) setState('error');
      }
    })();
    return () => { live = false; };
  }, [token]);

  const data = account
    ? passCardData({
        firstName: account.firstName,
        lastName: account.lastName,
        answeredAt: account.answeredAt,
      })
    : null;

  const saveName = useCallback(async (e) => {
    e.preventDefault();
    if (saving || !name.trim()) return;
    setSaving(true);
    setProblem(null);
    try {
      const r = await fetch(`/api/email/pass-card/${encodeURIComponent(token)}/name`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name }),
      });
      const body = await r.json().catch(() => ({}));
      if (!r.ok) {
        setProblem(body.msg || 'That could not be saved. Try again.');
        return;
      }
      setAccount(body);
      setState('ready');
    } catch {
      setProblem('That could not be saved. Check your connection and try again.');
    } finally {
      setSaving(false);
    }
  }, [name, saving, token]);

  const download = useCallback(async () => {
    if (!data) return;
    setProblem(null);
    try {
      const canvas = await renderPassCard(data);
      const blob = await passCardBlob(canvas);
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = passCardFilename(data);
      document.body.appendChild(a);
      a.click();
      a.remove();
      // Revoked on the next frame rather than immediately: Safari has not
      // finished reading the blob when click() returns.
      setTimeout(() => URL.revokeObjectURL(url), 1000);
    } catch {
      setProblem('The image could not be made. Try again, or take a screenshot of it.');
    }
  }, [data]);

  const answerPe = useCallback(async (wants) => {
    setPe(wants);
    // Never blocks and never reports failure: they have their card, and a
    // research answer that did not save is our problem, not theirs.
    try {
      await fetch(`/api/email/pass-card/${encodeURIComponent(token)}/pe`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ wants }),
      });
    } catch { /* nothing to say */ }
  }, [token]);

  if (state === 'loading') {
    return <Shell><p className="pc-quiet">Getting your card.</p></Shell>;
  }

  if (state === 'gone') {
    return (
      <Shell>
        <h1 className="pc-h1">Nothing here</h1>
        <p className="pc-body">
          This link does not have a card behind it. If you passed and told us so, the card is on
          your profile.
        </p>
        <a className="pc-btn" href="/profile">Go to my profile</a>
      </Shell>
    );
  }

  if (state === 'error') {
    return (
      <Shell>
        <h1 className="pc-h1">That did not load</h1>
        <p className="pc-body">Something went wrong on our side. Reload the page and it should come back.</p>
      </Shell>
    );
  }

  return (
    <Shell wide>
      {state === 'naming' ? (
        <>
          <h1 className="pc-h1">Congratulations</h1>
          <p className="pc-body">
            One thing before we draw it: what name should it carry? This is what people will read
            when you post it.
          </p>
          <form className="pc-form" onSubmit={saveName}>
            <label className="pc-label" htmlFor="pc-name">Your name</label>
            <input
              id="pc-name"
              className="pc-input"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Jerson Garcia"
              autoComplete="name"
              maxLength={40}
              autoFocus
            />
            <button className="pc-btn" type="submit" disabled={saving || !name.trim()}>
              {saving ? 'Saving' : 'Draw my card'}
            </button>
          </form>
          <p className="pc-quiet">We add the EIT. You do not have to type it.</p>
          <div className="pc-faded" aria-hidden="true"><CardPreview data={data} /></div>
        </>
      ) : (
        <>
          <h1 className="pc-h1">{data?.name ? `Yours, ${data.name.split(' ')[0].replace(',', '')}` : 'Yours'}</h1>
          <p className="pc-body">Post it, print it, or keep it. It is yours either way.</p>
          <CardPreview data={data} />
          <div className="pc-actions">
            <button className="pc-btn" type="button" onClick={download}>Download the image</button>
            <a
              className="pc-btn pc-btn--ghost"
              href="https://www.linkedin.com/feed/"
              target="_blank"
              rel="noreferrer noopener"
            >
              Open LinkedIn
            </a>
          </div>
          <p className="pc-quiet">
            Download it first, then attach it to your post. Your card stays on your profile, so you
            can come back for it whenever you want.
          </p>

          {pe === null ? (
            <div className="pc-ask">
              <p className="pc-ask-q">
                The PE is the exam after this one. Want us to tell you when we build prep for it?
              </p>
              <div className="pc-actions">
                <button className="pc-btn" type="button" onClick={() => answerPe(true)}>Yes, tell me</button>
                <button className="pc-btn pc-btn--ghost" type="button" onClick={() => answerPe(false)}>No thanks</button>
              </div>
            </div>
          ) : (
            <div className="pc-ask">
              <p className="pc-ask-q">{pe ? 'We will let you know.' : 'Noted. We will not bring it up again.'}</p>
            </div>
          )}
        </>
      )}
      {problem && <p className="pc-problem" role="alert">{problem}</p>}
    </Shell>
  );
}

function Shell({ children, wide = false }) {
  return (
    // No wordmark of its own: the app's header already carries one, and two
    // stacked read as a mistake.
    <main className={`pc-page${wide ? ' pc-page--wide' : ''}`}>
      <div className="pc-card">{children}</div>
    </main>
  );
}
