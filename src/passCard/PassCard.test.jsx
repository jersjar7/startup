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
  firstName: 'Jerson', lastName: 'Garcia', hasName: true,
  answeredAt: '2026-10-20T10:00:00Z',
};
const PASSED_NAMELESS = {
  firstName: null, lastName: null, hasName: false,
  answeredAt: '2026-10-20T10:00:00Z',
};

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

describe('somebody whose account already has a name', () => {
  beforeEach(() => {
    global.fetch = vi.fn(() => respond(PASSED_NAMED));
  });

  it('goes straight to the card, asking nothing', async () => {
    mountAt();
    expect(await screen.findByRole('button', { name: /download the image/i })).toBeTruthy();
    expect(screen.queryByLabelText(/your name/i)).toBeNull();
  });

  it('describes the card for a screen reader rather than leaving it unlabelled', async () => {
    mountAt();
    const img = await screen.findByRole('img');
    expect(img.getAttribute('aria-label')).toMatch(/Jerson Garcia, EIT passed/);
  });

  it('asks about the PE only after the card is theirs', async () => {
    mountAt();
    await screen.findByRole('button', { name: /download the image/i });
    const pe = screen.getByText(/the exam after this one/i);
    const download = screen.getByRole('button', { name: /download the image/i });
    // The celebration is not a toll gate for a research question.
    expect(download.compareDocumentPosition(pe) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
  });

  it('takes a PE answer and does not ask twice', async () => {
    mountAt();
    await screen.findByRole('button', { name: /download the image/i });
    await userEvent.click(screen.getByRole('button', { name: /yes, tell me/i }));
    await waitFor(() => expect(screen.getByText(/we will let you know/i)).toBeTruthy());
    expect(screen.queryByRole('button', { name: /yes, tell me/i })).toBeNull();
  });
});

describe('somebody with no name on the account, which is most people', () => {
  beforeEach(() => {
    global.fetch = vi.fn((url, opts) =>
      opts?.method === 'POST' ? respond(PASSED_NAMED) : respond(PASSED_NAMELESS));
  });

  it('asks for a name before drawing anything they could keep', async () => {
    mountAt();
    expect(await screen.findByLabelText(/your name/i)).toBeTruthy();
    expect(screen.queryByRole('button', { name: /download the image/i })).toBeNull();
  });

  it('will not submit an empty name', async () => {
    mountAt();
    await screen.findByLabelText(/your name/i);
    expect(screen.getByRole('button', { name: /draw my card/i }).disabled).toBe(true);
  });

  it('draws the card once a name is given', async () => {
    mountAt();
    const field = await screen.findByLabelText(/your name/i);
    await userEvent.type(field, 'Jerson Garcia');
    await userEvent.click(screen.getByRole('button', { name: /draw my card/i }));
    expect(await screen.findByRole('button', { name: /download the image/i })).toBeTruthy();
  });

  it('says we add the EIT, so nobody types it themselves', async () => {
    mountAt();
    await screen.findByLabelText(/your name/i);
    expect(screen.getByText(/we add the eit/i)).toBeTruthy();
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
