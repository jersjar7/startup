import React from 'react';
import { describe, it, expect, vi, afterEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { Login } from './login';

// Registration onboarding, as a sequence. The thing worth protecting here is
// the ORDER: attribution, then school, then the exam date, one screen at a
// time. Two questions on screen together reads as an interrogation on an
// account that is thirty seconds old, and the only thing stopping it is that
// these are steps rather than stacked prompts.
const SOURCE_Q = /how did you find us/i;
const SCHOOL_Q = /where are you studying/i;
const EXAM_Q = /when are you sitting the FE/i;

function routeFetch() {
  return vi.fn((url) => Promise.resolve({
    ok: true,
    json: () => Promise.resolve(url === '/api/auth/create' ? { email: 'raccoon@uwf.edu' } : {}),
  }));
}

async function register() {
  const fetchFn = routeFetch();
  vi.stubGlobal('fetch', fetchFn);
  render(
    <MemoryRouter>
      <Login userName={null} onLogin={vi.fn()} />
    </MemoryRouter>,
  );

  fireEvent.click(screen.getByRole('button', { name: /create a free account/i }));
  fireEvent.change(screen.getByLabelText('Email'), { target: { value: 'raccoon@uwf.edu' } });
  fireEvent.change(screen.getByLabelText('Password'), { target: { value: 'Password1' } });
  fireEvent.click(screen.getByRole('checkbox'));
  fireEvent.click(screen.getByRole('button', { name: /create account/i }));

  await screen.findByText(SOURCE_Q);
  return fetchFn;
}

describe('registration onboarding', () => {
  afterEach(() => {
    vi.unstubAllGlobals();
    vi.restoreAllMocks();
  });

  it('asks where they found us first, and does not ask about school yet', async () => {
    await register();
    expect(screen.getByText(SOURCE_Q)).toBeInTheDocument();
    expect(screen.queryByText(SCHOOL_Q)).toBeNull();
  });

  it('asks about school only once attribution is answered, never alongside it', async () => {
    await register();

    fireEvent.click(screen.getByRole('button', { name: 'Reddit' }));

    await screen.findByText(SCHOOL_Q);
    expect(screen.queryByText(SOURCE_Q)).toBeNull();
  });

  it('carries on to the exam date once school is answered', async () => {
    const fetchFn = await register();

    fireEvent.click(screen.getByRole('button', { name: 'Reddit' }));
    await screen.findByText(SCHOOL_Q);

    fireEvent.change(screen.getByLabelText('School name'), { target: { value: 'University of West Florida' } });
    fireEvent.click(screen.getByRole('button', { name: 'Save' }));

    await screen.findByText(EXAM_Q);
    expect(screen.queryByText(SCHOOL_Q)).toBeNull();
    expect(fetchFn).toHaveBeenCalledWith('/api/user/school', expect.objectContaining({ method: 'POST' }));
  });

  it('carries on even when the school write fails, rather than stranding them', async () => {
    await register();

    fireEvent.click(screen.getByRole('button', { name: 'Reddit' }));
    await screen.findByText(SCHOOL_Q);

    // Only the school POST breaks. A dead analytics endpoint must not be able
    // to hold somebody outside the product they just signed up for.
    vi.stubGlobal('fetch', vi.fn(() => Promise.reject(new Error('offline'))));
    fireEvent.change(screen.getByLabelText('School name'), { target: { value: 'UWF' } });
    fireEvent.click(screen.getByRole('button', { name: 'Save' }));

    await screen.findByText(EXAM_Q);
  });

  it('lets a non-student past the school step', async () => {
    await register();

    fireEvent.click(screen.getByRole('button', { name: 'Reddit' }));
    await screen.findByText(SCHOOL_Q);

    fireEvent.click(screen.getByRole('button', { name: 'Not a student' }));

    await screen.findByText(EXAM_Q);
  });

  it('gives no way to dismiss either question out of the flow', async () => {
    await register();
    expect(screen.queryByLabelText('Dismiss')).toBeNull();

    fireEvent.click(screen.getByRole('button', { name: 'Reddit' }));
    await screen.findByText(SCHOOL_Q);
    await waitFor(() => expect(screen.queryByLabelText('Dismiss')).toBeNull());
  });
});
