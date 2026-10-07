import React from 'react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { SchoolPrompt } from './SchoolPrompt.jsx';

// Free text alone was measured and produced nothing usable: 19 users had given
// a school and there were 19 distinct names, with "UCI" and "University of
// California, Irvine" counted as separate institutions. Suggestions make it
// likely two students at one university save the same string. They are only
// ever a shortcut, and this file is mostly about that word "only".

const reply = (schools) => Promise.resolve({
  ok: true,
  json: () => Promise.resolve({ schools }),
});

beforeEach(() => { vi.useRealTimers(); });
afterEach(() => { vi.restoreAllMocks(); });

describe('suggesting a school', () => {
  it('offers canonical names once enough is typed', async () => {
    global.fetch = vi.fn(() => reply(['University of California, Irvine']));
    render(<SchoolPrompt onClose={() => {}} />);
    await userEvent.type(screen.getByLabelText(/school name/i), 'irv');
    expect(await screen.findByText('University of California, Irvine')).toBeTruthy();
  });

  it('fills the field when one is clicked', async () => {
    global.fetch = vi.fn(() => reply(['Clemson University']));
    render(<SchoolPrompt onClose={() => {}} />);
    const field = screen.getByLabelText(/school name/i);
    await userEvent.type(field, 'clem');
    await userEvent.click(await screen.findByText('Clemson University'));
    await waitFor(() => expect(field.value).toBe('Clemson University'));
  });

  it('asks for nothing until two characters, which would match everything', async () => {
    global.fetch = vi.fn(() => reply(['Anything']));
    render(<SchoolPrompt onClose={() => {}} />);
    await userEvent.type(screen.getByLabelText(/school name/i), 'u');
    await new Promise((r) => setTimeout(r, 400));
    expect(global.fetch).not.toHaveBeenCalled();
  });
});

describe('what it must never do', () => {
  it('always says a school that is not listed is still accepted', async () => {
    global.fetch = vi.fn(() => reply(['Clemson University']));
    render(<SchoolPrompt onClose={() => {}} />);
    await userEvent.type(screen.getByLabelText(/school name/i), 'clem');
    expect(await screen.findByText(/not listed/i)).toBeTruthy();
  });

  it('keeps what was typed when nothing matched', async () => {
    // The directory is a seed and always will be incomplete. An unknown
    // university must never block somebody from answering.
    global.fetch = vi.fn(() => reply([]));
    render(<SchoolPrompt onClose={() => {}} />);
    const field = screen.getByLabelText(/school name/i);
    await userEvent.type(field, 'Universidad Nacional de Ingenieria');
    await new Promise((r) => setTimeout(r, 400));
    expect(field.value).toBe('Universidad Nacional de Ingenieria');
    expect(screen.queryByText(/not listed/i)).toBeNull();
  });

  it('loses the list rather than the field when the request fails', async () => {
    global.fetch = vi.fn(() => Promise.reject(new Error('offline')));
    render(<SchoolPrompt onClose={() => {}} />);
    const field = screen.getByLabelText(/school name/i);
    await userEvent.type(field, 'clemson');
    await new Promise((r) => setTimeout(r, 400));
    expect(field.value).toBe('clemson');
    expect(screen.queryByRole('listbox')).toBeNull();
  });
});
