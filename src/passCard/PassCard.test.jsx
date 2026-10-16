import React from 'react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import PassCard from './PassCard.jsx';

// The page somebody lands on from the outcome email, usually on a phone,
// usually within a minute of finding out they passed. What is guarded here is
// the order it asks things in and what it refuses to do: the card is never
// drawn with an invented name, the PE question never comes before the card, and
// a link that has no card behind it says so instead of implying one exists.

const PASSED_NAMED = {
  firstName: 'Sammy', lastName: null, hasName: true, cardName: null,
  suggestedName: 'Sammy',
  answeredAt: '2026-10-20T10:00:00Z',
};
const PASSED_NAMELESS = {
  firstName: null, lastName: null, hasName: false, cardName: null,
  suggestedName: null,
  answeredAt: '2026-10-20T10:00:00Z',
};
const SAVED = (name) => ({ ...PASSED_NAMED, cardName: name, suggestedName: name });

function mountAt(token = 'abc123') {
  return render(
    <MemoryRouter initialEntries={[`/pass-card/${token}`]}>
      <Routes>
        <Route path="/pass-card/:token" element={<PassCard />} />
      </Routes>
    </MemoryRouter>,
  );
}

/// jsdom has no canvas, so the 2D context is stubbed. The drawing itself is
/// tested in drawPassCard.test.js; what matters here is that the page does not
/// fall over without a real one.
beforeEach(() => {
  HTMLCanvasElement.prototype.getContext = vi.fn(() => ({
    save: vi.fn(), restore: vi.fn(), scale: vi.fn(), clearRect: vi.fn(), fillRect: vi.fn(),
    beginPath: vi.fn(), moveTo: vi.fn(), lineTo: vi.fn(), stroke: vi.fn(), fill: vi.fn(),
    arcTo: vi.fn(), roundRect: vi.fn(), fillText: vi.fn(),
    measureText: () => ({ width: 7 }),
    fillStyle: '', strokeStyle: '', lineWidth: 1, textAlign: '', textBaseline: '', font: '',
  }));
});

afterEach(() => vi.restoreAllMocks());

const respond = (body, status = 200) =>
  Promise.resolve({ ok: status < 400, status, json: () => Promise.resolve(body) });

describe('somebody whose account already has a name (ADR 0023)', () => {
  beforeEach(() => {
    global.fetch = vi.fn((url, opts) =>
      opts?.method === 'POST'
        ? respond(SAVED(JSON.parse(opts.body).name))
        : respond(PASSED_NAMED));
  });

  it('still asks, filled in with that name', async () => {
    mountAt();
    const field = await screen.findByLabelText(/your full name/i);
    expect(field.value).toBe('Sammy');
    // Nothing they could keep until the name is confirmed.
    expect(screen.queryByRole('button', { name: /download the image/i })).toBeNull();
  });

  it('lets them print a different name, and saves it as the card\'s own', async () => {
    mountAt();
    const field = await screen.findByLabelText(/your full name/i);
    await userEvent.clear(field);
    await userEvent.type(field, 'Samantha Reyes');
    await userEvent.click(screen.getByRole('button', { name: /draw my card/i }));
    expect(await screen.findByRole('button', { name: /download the image/i })).toBeTruthy();
    const [url, opts] = global.fetch.mock.calls.find(([, o]) => o?.method === 'POST');
    expect(url).toBe('/api/email/pass-card/abc123/name');
    expect(JSON.parse(opts.body)).toEqual({ name: 'Samantha Reyes' });
    const img = screen.getByRole('img');
    expect(img.getAttribute('aria-label')).toMatch(/Samantha Reyes, EIT passed/);
  });

  it('shows the name in the preview as it is typed', async () => {
    mountAt();
    const field = await screen.findByLabelText(/your full name/i);
    await userEvent.clear(field);
    await userEvent.type(field, 'Sam Reyes');
    await waitFor(() =>
      expect(screen.getByRole('img', { hidden: true }).getAttribute('aria-label'))
        .toMatch(/Sam Reyes, EIT/));
  });

  it('asks about the PE only after the card is theirs', async () => {
    mountAt();
    await userEvent.click(await screen.findByRole('button', { name: /draw my card/i }));
    await screen.findByRole('button', { name: /download the image/i });
    const pe = screen.getByText(/the exam after this one/i);
    const download = screen.getByRole('button', { name: /download the image/i });
    // The celebration is not a toll gate for a research question.
    expect(download.compareDocumentPosition(pe) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
  });

  it('takes a PE answer and does not ask twice', async () => {
    mountAt();
    await userEvent.click(await screen.findByRole('button', { name: /draw my card/i }));
    await screen.findByRole('button', { name: /download the image/i });
    await userEvent.click(screen.getByRole('button', { name: /yes, tell me/i }));
    await waitFor(() => expect(screen.getByText(/we will let you know/i)).toBeTruthy());
    expect(screen.queryByRole('button', { name: /yes, tell me/i })).toBeNull();
  });
});

describe('somebody who made a card before', () => {
  it('is asked again, filled in with the name the card printed', async () => {
    global.fetch = vi.fn(() => respond(SAVED('Samantha Reyes')));
    mountAt();
    expect((await screen.findByLabelText(/your full name/i)).value).toBe('Samantha Reyes');
  });
});

describe('somebody with no name on the account, which is most people', () => {
  beforeEach(() => {
    global.fetch = vi.fn((url, opts) =>
      opts?.method === 'POST'
        ? respond(SAVED(JSON.parse(opts.body).name))
        : respond(PASSED_NAMELESS));
  });

  it('asks for a name before drawing anything they could keep', async () => {
    mountAt();
    expect((await screen.findByLabelText(/your full name/i)).value).toBe('');
    expect(screen.queryByRole('button', { name: /download the image/i })).toBeNull();
  });

  it('will not submit an empty name', async () => {
    mountAt();
    await screen.findByLabelText(/your full name/i);
    expect(screen.getByRole('button', { name: /draw my card/i }).disabled).toBe(true);
  });

  it('draws the card once a name is given', async () => {
    mountAt();
    const field = await screen.findByLabelText(/your full name/i);
    await userEvent.type(field, 'Jerson Garcia');
    await userEvent.click(screen.getByRole('button', { name: /draw my card/i }));
    expect(await screen.findByRole('button', { name: /download the image/i })).toBeTruthy();
  });

  it('says we add the EIT, so nobody types it themselves', async () => {
    mountAt();
    await screen.findByLabelText(/your full name/i);
    expect(screen.getByText(/we add the eit/i)).toBeTruthy();
  });
});

describe('signed in, from the profile', () => {
  it('reads the card from the account and saves through it', async () => {
    global.fetch = vi.fn((url, opts) => {
      if (url === '/api/auth/me') return respond({ email: 'a@b.com', passCard: PASSED_NAMED });
      if (url === '/api/auth/card-name') return respond(SAVED(JSON.parse(opts.body).name));
      return respond({}, 404);
    });
    mountAt('me');
    expect((await screen.findByLabelText(/your full name/i)).value).toBe('Sammy');
    await userEvent.click(screen.getByRole('button', { name: /draw my card/i }));
    expect(await screen.findByRole('button', { name: /download the image/i })).toBeTruthy();
    // The PE question belongs to the email's moment, not a return visit.
    expect(screen.queryByText(/the exam after this one/i)).toBeNull();
  });

  it('asks them to log in when they are not', async () => {
    global.fetch = vi.fn(() => respond({}, 401));
    mountAt('me');
    expect(await screen.findByRole('link', { name: /log in/i })).toBeTruthy();
  });

  it('has nothing for an account without a pass', async () => {
    global.fetch = vi.fn(() => respond({ email: 'a@b.com', passCard: null }));
    mountAt('me');
    expect(await screen.findByText(/nothing here/i)).toBeTruthy();
  });
});

describe('a link with no card behind it', () => {
  it('says so plainly instead of implying one exists', async () => {
    global.fetch = vi.fn(() => respond({ msg: 'No card here.' }, 404));
    mountAt();
    expect(await screen.findByText(/nothing here/i)).toBeTruthy();
    expect(screen.queryByRole('button', { name: /download/i })).toBeNull();
  });

  it('offers a way on rather than a dead end', async () => {
    global.fetch = vi.fn(() => respond({}, 404));
    mountAt();
    expect(await screen.findByRole('link', { name: /profile/i })).toBeTruthy();
  });
});

describe('when our side is down', () => {
  it('says it is us, and that reloading should fix it', async () => {
    global.fetch = vi.fn(() => Promise.reject(new Error('offline')));
    mountAt();
    expect(await screen.findByText(/did not load/i)).toBeTruthy();
  });
});
