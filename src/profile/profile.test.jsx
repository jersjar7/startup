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

// Until 2026-10-07 an email could never be changed, and "resend verification"
// mailed the SAME address, so anybody who mistyped theirs at sign-up was stuck:
// still able to study, but never receiving anything we send. One real account
// has been in that state since 2 October.
describe('changing the email address', () => {
  function openForm() {
    fireEvent.click(screen.getByRole('button', { name: /^change$/i }));
  }

  /// Mounts with a scripted answer from the change-email endpoint.
  function mountWithChange(answer) {
    return mountProfile({
      onFetch: (url) => (url === '/api/auth/change-email'
        ? Promise.resolve({ ok: answer.ok, json: () => Promise.resolve(answer.body) })
        : null),
    });
  }

  function fillForm(email, password) {
    fireEvent.change(screen.getByLabelText(/new email/i), { target: { value: email } });
    fireEvent.change(screen.getByLabelText(/your password/i), { target: { value: password } });
    fireEvent.click(screen.getByRole('button', { name: /change email/i }));
  }

  it('is not on screen until asked for', async () => {
    mountProfile();
    await screen.findByText('raccoon@uwf.edu');
    expect(screen.queryByLabelText(/new email/i)).toBeNull();
  });

  it('asks for the password, not just the new address', async () => {
    // Without it, five minutes at an unlocked laptop is enough to move the
    // account to somebody else's address.
    mountProfile();
    await screen.findByText('raccoon@uwf.edu');
    openForm();
    expect(screen.getByLabelText(/your password/i)).toBeTruthy();
  });

  it('warns that the new address starts unverified', async () => {
    mountProfile();
    await screen.findByText('raccoon@uwf.edu');
    openForm();
    expect(screen.getByText(/verification link to the new address/i)).toBeTruthy();
  });

  it('sends both the address and the password', async () => {
    const fetchFn = mountWithChange({
      ok: true, body: { email: 'fixed@school.edu', emailVerified: false },
    });
    await screen.findByText('raccoon@uwf.edu');
    openForm();
    fillForm('fixed@school.edu', 'hunter2');
    await waitFor(() => {
      const call = fetchFn.mock.calls.find(([u]) => u === '/api/auth/change-email');
      expect(call).toBeTruthy();
      const sent = JSON.parse(call[1].body);
      expect(sent.email).toBe('fixed@school.edu');
      expect(sent.password).toBe('hunter2');
    });
  });

  it('shows the new address and that it needs verifying', async () => {
    mountWithChange({ ok: true, body: { email: 'fixed@school.edu', emailVerified: false } });
    await screen.findByText('raccoon@uwf.edu');
    openForm();
    fillForm('fixed@school.edu', 'hunter2');
    expect(await screen.findByText(/verification email to fixed@school.edu/i)).toBeTruthy();
    expect(await screen.findByText('fixed@school.edu')).toBeTruthy();
  });

  it('keeps what they typed when the server refuses', async () => {
    // A wrong password must not cost them the address they just typed.
    mountWithChange({ ok: false, body: { msg: 'Password is incorrect.' } });
    await screen.findByText('raccoon@uwf.edu');
    openForm();
    fillForm('fixed@school.edu', 'wrong');
    expect(await screen.findByText(/password is incorrect/i)).toBeTruthy();
    expect(screen.getByLabelText(/new email/i).value).toBe('fixed@school.edu');
  });
});
