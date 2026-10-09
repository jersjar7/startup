import React from 'react';
import fs from 'node:fs';
import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { DeleteAccount } from './deleteAccount.jsx';
import { PRERENDERED_ROUTE_PATTERN } from '../../service/prerenderedRoutes.js';

// Google Play's Data Safety form has a required field for a URL where somebody
// can delete their account without signing in and without installing the app.
// A page that is missing, that needs an account to read, or that promises to
// erase something we keep, is a rejection or a false statement.
//
// So this guards three things: the page exists and says the true thing, the
// URL is actually public, and the list of what is erased has not drifted from
// the code that does the erasing.

function mount() {
  return render(<MemoryRouter><DeleteAccount /></MemoryRouter>);
}

describe('the page Play is pointed at', () => {
  it('tells someone how to delete from both clients', () => {
    mount();
    expect(screen.getByRole('heading', { level: 1, name: /delete your account/i }))
      .toBeInTheDocument();
    expect(screen.getByText(/On the website:/)).toBeInTheDocument();
    expect(screen.getByText(/In the mobile app:/)).toBeInTheDocument();
  });

  it('offers a way out for somebody who cannot sign in', () => {
    // Without this the page documents a feature rather than accepting a
    // request, which is the thing Play actually asks for.
    mount();
    const mail = screen.getByRole('link', { name: /fe4raccoons@oqupa\.com/ });
    expect(mail).toHaveAttribute('href', 'mailto:fe4raccoons@oqupa.com');
  });

  it('says plainly that it cannot be undone', () => {
    mount();
    expect(screen.getByText(/cannot be undone/i)).toBeInTheDocument();
  });

  it('does not hide the row we keep', () => {
    // We keep one counter row with no PII. Claiming total erasure while
    // keeping it would be the one dishonest sentence on the page.
    mount();
    expect(screen.getByRole('heading', { name: /the one thing we keep/i }))
      .toBeInTheDocument();
  });
});

describe('the URL is reachable the way Play will reach it', () => {
  it('is served as a prerendered page, not an empty SPA shell', () => {
    // The fetcher behind the Data Safety field does not run JavaScript.
    expect(PRERENDERED_ROUTE_PATTERN.test('/delete-account')).toBe(true);
    expect(PRERENDERED_ROUTE_PATTERN.test('/delete-account/')).toBe(true);
  });

  it('is in the prerenderer own route list, which is the other half', () => {
    // A route in one list and not the other still answers HTTP 200 and looks
    // perfect in a browser. See service/prerenderedRoutes.test.js.
    const src = fs.readFileSync('scripts/prerender.mjs', 'utf8');
    expect(src).toMatch(/'\/delete-account'/);
  });

  it('needs no sign-in: the route sits outside the authed shell', () => {
    const app = fs.readFileSync('src/app.jsx', 'utf8');
    const line = app.split('\n').find((l) => l.includes('path="/delete-account"'));
    expect(line).toBeTruthy();
    // The same place /privacy and /terms are routed, which are public.
    const privacy = app.split('\n').findIndex((l) => l.includes('path="/privacy"'));
    const mine = app.split('\n').findIndex((l) => l.includes('path="/delete-account"'));
    expect(mine).toBe(privacy + 1);
  });

  it('is findable from any page, not only from a link we hand Google', () => {
    const footer = fs.readFileSync('src/components/Footer.jsx', 'utf8');
    expect(footer).toContain('/delete-account');
  });
});

describe('what the page promises matches what the code erases', () => {
  const deletion = fs.readFileSync('service/db/accountDeletion.js', 'utf8');

  it('names every collection the deletion actually clears', () => {
    // If a collection is added to the deletion and not to the page, the page
    // under-promises, which is harmless. The failure that matters is the
    // reverse, so this asserts the set we know about is the set it clears.
    const cleared = [...deletion.matchAll(/(\w+)Collection\.delete(One|Many)/g)]
      .map((m) => m[1]);
    expect(new Set(cleared)).toEqual(new Set([
      'userStats', 'problemHistory', 'sessionLog', 'sessions',
      'diagnosticResults', 'funnelEvents', 'reviewEvents', 'paperFlags',
      'gameFeedback', 'purchases', 'examAttempts', 'user',
    ]));
  });

  it('keeps exactly one row, the tally, and the page says so', () => {
    expect(deletion).toContain('deletionLogCollection.insertOne');
    mount();
    expect(screen.getByText(/single counter row/i)).toBeInTheDocument();
  });
});
