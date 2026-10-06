import React from 'react';
import { describe, it, expect, vi, afterEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { Profile } from './profile';

// One Save button, two endpoints. The two things worth protecting: the school
// write must not fire for somebody who only came here to fix their surname, and
// a school write that fails must not take the name and exam date down with it.
const ME = {
  email: 'raccoon@uwf.edu',
  firstName: 'Maria',
  lastName: 'Gomez',
  examDate: '',
  emailVerified: true,
  school: { name: 'University of West Florida', graduationYear: 2027 },
};

function mountProfile({ me = ME, onFetch } = {}) {
  const fetchFn = vi.fn((url, opts) => {
    if (onFetch) {
      const override = onFetch(url, opts);
      if (override) return override;
    }
    if (url === '/api/user/me') return Promise.resolve({ ok: true, json: () => Promise.resolve(me) });
    if (url === '/api/checkout/status') return Promise.resolve({ ok: true, json: () => Promise.resolve({ purchased: false }) });
    return Promise.resolve({ ok: true, json: () => Promise.resolve({}) });
  });
  vi.stubGlobal('fetch', fetchFn);
  render(
    <MemoryRouter>
      <Profile userName="raccoon@uwf.edu" onLogout={vi.fn()} />
    </MemoryRouter>,
  );
  return fetchFn;
}

function schoolCalls(fetchFn) {
  return fetchFn.mock.calls.filter(([url]) => url === '/api/user/school');
}

describe('Profile school fields', () => {
  afterEach(() => {
    vi.unstubAllGlobals();
    vi.restoreAllMocks();
  });

  it('shows the school already on file, so it reads as editable rather than blank', async () => {
    mountProfile();
    expect(await screen.findByDisplayValue('University of West Florida')).toBeInTheDocument();
    expect(screen.getByDisplayValue('2027')).toBeInTheDocument();
  });

  it('saves a changed school and year', async () => {
    const fetchFn = mountProfile();
    await screen.findByDisplayValue('University of West Florida');

    fireEvent.change(screen.getByLabelText(/^School$/), { target: { value: 'Brigham Young University' } });
    fireEvent.change(screen.getByLabelText(/graduation year/i), { target: { value: '2028' } });
    fireEvent.click(screen.getByRole('button', { name: /save details/i }));

    await screen.findByText('Saved');
    const [, opts] = schoolCalls(fetchFn).at(-1);
    expect(JSON.parse(opts.body)).toEqual({ name: 'Brigham Young University', graduationYear: 2028 });
  });

  it('clears the year to null when the field is emptied', async () => {
    const fetchFn = mountProfile();
    await screen.findByDisplayValue('2027');

    fireEvent.change(screen.getByLabelText(/graduation year/i), { target: { value: '' } });
    fireEvent.click(screen.getByRole('button', { name: /save details/i }));

    await screen.findByText('Saved');
    const [, opts] = schoolCalls(fetchFn).at(-1);
    expect(JSON.parse(opts.body)).toEqual({ name: 'University of West Florida', graduationYear: null });
  });

  it('does not touch the school when only the name was edited', async () => {
    const fetchFn = mountProfile();
    await screen.findByDisplayValue('Maria');

    fireEvent.change(screen.getByLabelText(/first name/i), { target: { value: 'Mariana' } });
    fireEvent.click(screen.getByRole('button', { name: /save details/i }));

    await screen.findByText('Saved');
    expect(schoolCalls(fetchFn)).toHaveLength(0);
  });

  it('keeps the details save when the school write fails', async () => {
    const fetchFn = mountProfile({
      onFetch: (url) => (url === '/api/user/school' ? Promise.reject(new Error('offline')) : null),
    });
    await screen.findByDisplayValue('University of West Florida');

    fireEvent.change(screen.getByLabelText(/^School$/), { target: { value: 'Utah State' } });
    fireEvent.click(screen.getByRole('button', { name: /save details/i }));

    // The profile PUT still went out, and the failure names the half that broke
    // instead of a blanket "could not save" that would send them hunting.
    await screen.findByText(/could not save your school/i);
    expect(fetchFn.mock.calls.some(([url, opts]) => url === '/api/user/profile' && opts?.method === 'PUT')).toBe(true);
  });
});
