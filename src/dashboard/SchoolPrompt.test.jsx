import React from 'react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { SchoolPrompt, gradYearOptions, GRAD_TERMS } from './SchoolPrompt';

// What matters about this prompt is not how it looks, it is that it cannot trap
// anybody and cannot lose what they typed. Both of those are behaviour, so they
// are tested here rather than left to a screenshot.
function mockFetch(impl) {
  const fn = vi.fn(impl);
  vi.stubGlobal('fetch', fn);
  return fn;
}

function lastBody(fn) {
  return JSON.parse(fn.mock.calls.at(-1)[1].body);
}

describe('gradYearOptions', () => {
  it('offers the current year and the next four', () => {
    expect(gradYearOptions(new Date('2026-10-06T12:00:00Z'))).toEqual([2026, 2027, 2028, 2029, 2030]);
  });

  it('rolls forward with the calendar, so the window cannot go stale', () => {
    expect(gradYearOptions(new Date('2031-01-02T12:00:00Z'))[0]).toBe(2031);
  });
});

describe('SchoolPrompt', () => {
  beforeEach(() => {
    mockFetch(() => Promise.resolve({ ok: true, json: () => Promise.resolve({}) }));
  });

  afterEach(() => {
    vi.unstubAllGlobals();
    vi.restoreAllMocks();
  });

  it('cannot be saved without a school name', () => {
    render(<SchoolPrompt onClose={vi.fn()} />);
    expect(screen.getByRole('button', { name: 'Save' })).toBeDisabled();
  });

  it('saves the name with the picked year and resolves the question', async () => {
    const fetchFn = mockFetch(() => Promise.resolve({ ok: true, json: () => Promise.resolve({}) }));
    const onClose = vi.fn();
    const years = gradYearOptions();
    render(<SchoolPrompt onClose={onClose} />);

    fireEvent.change(screen.getByLabelText('School name'), { target: { value: '  Brigham Young University  ' } });
    fireEvent.click(screen.getByRole('button', { name: String(years[1]) }));
    fireEvent.click(screen.getByRole('button', { name: 'Save' }));

    await waitFor(() => expect(onClose).toHaveBeenCalledWith(true));
    expect(fetchFn).toHaveBeenCalledWith('/api/user/school', expect.objectContaining({ method: 'POST' }));
    expect(lastBody(fetchFn)).toEqual({
      name: 'Brigham Young University',
      graduationYear: years[1],
      graduationTerm: null,
    });
  });

  it('accepts a school with no year, because half an answer is still useful', async () => {
    const fetchFn = mockFetch(() => Promise.resolve({ ok: true, json: () => Promise.resolve({}) }));
    const onClose = vi.fn();
    render(<SchoolPrompt onClose={onClose} />);

    fireEvent.change(screen.getByLabelText('School name'), { target: { value: 'UWF' } });
    fireEvent.click(screen.getByRole('button', { name: 'Save' }));

    await waitFor(() => expect(onClose).toHaveBeenCalledWith(true));
    expect(lastBody(fetchFn)).toEqual({ name: 'UWF', graduationYear: null, graduationTerm: null });
  });

  it('sends a null year for someone who has already graduated', async () => {
    const fetchFn = mockFetch(() => Promise.resolve({ ok: true, json: () => Promise.resolve({}) }));
    render(<SchoolPrompt onClose={vi.fn()} />);

    fireEvent.change(screen.getByLabelText('School name'), { target: { value: 'UWF' } });
    fireEvent.click(screen.getByRole('button', { name: 'Already graduated' }));
    fireEvent.click(screen.getByRole('button', { name: 'Save' }));

    await waitFor(() => expect(lastBody(fetchFn)).toEqual({ name: 'UWF', graduationYear: null, graduationTerm: null }));
  });

  it('lets a year be unpicked, so a mis-tap is not permanent', async () => {
    const fetchFn = mockFetch(() => Promise.resolve({ ok: true, json: () => Promise.resolve({}) }));
    const years = gradYearOptions();
    render(<SchoolPrompt onClose={vi.fn()} />);

    fireEvent.change(screen.getByLabelText('School name'), { target: { value: 'UWF' } });
    const chip = screen.getByRole('button', { name: String(years[0]) });
    fireEvent.click(chip);
    expect(chip).toHaveAttribute('aria-pressed', 'true');
    fireEvent.click(chip);
    expect(chip).toHaveAttribute('aria-pressed', 'false');

    fireEvent.click(screen.getByRole('button', { name: 'Save' }));
    await waitFor(() => expect(lastBody(fetchFn)).toEqual({ name: 'UWF', graduationYear: null, graduationTerm: null }));
  });

  it('resolves the question server-side when skipped, so it is not asked again', async () => {
    const fetchFn = mockFetch(() => Promise.resolve({ ok: true, json: () => Promise.resolve({}) }));
    const onClose = vi.fn();
    render(<SchoolPrompt onClose={onClose} dismissible={false} />);

    fireEvent.click(screen.getByRole('button', { name: 'Not a student' }));

    await waitFor(() => expect(onClose).toHaveBeenCalledWith(true));
    expect(lastBody(fetchFn)).toEqual({ dismissed: true });
  });

  it('offers the skip out even where the X is hidden, so nobody is ever stuck', () => {
    render(<SchoolPrompt onClose={vi.fn()} dismissible={false} />);
    expect(screen.queryByLabelText('Dismiss')).toBeNull();
    expect(screen.getByRole('button', { name: 'Not a student' })).toBeEnabled();
  });

  it('closes without resolving when the X is used, so the ask survives', () => {
    const fetchFn = mockFetch(() => Promise.resolve({ ok: true, json: () => Promise.resolve({}) }));
    const onClose = vi.fn();
    render(<SchoolPrompt onClose={onClose} />);

    fireEvent.click(screen.getByLabelText('Dismiss'));

    expect(onClose).toHaveBeenCalledWith(false);
    expect(fetchFn).not.toHaveBeenCalled();
  });

  it('never blocks the user when the POST rejects', async () => {
    mockFetch(() => Promise.reject(new Error('offline')));
    const onClose = vi.fn();
    render(<SchoolPrompt onClose={onClose} />);

    fireEvent.change(screen.getByLabelText('School name'), { target: { value: 'UWF' } });
    fireEvent.click(screen.getByRole('button', { name: 'Save' }));

    await waitFor(() => expect(onClose).toHaveBeenCalledWith(true));
  });

  it('never blocks the user when the POST returns an error status', async () => {
    mockFetch(() => Promise.resolve({ ok: false, status: 500, json: () => Promise.resolve({}) }));
    const onClose = vi.fn();
    render(<SchoolPrompt onClose={onClose} />);

    fireEvent.change(screen.getByLabelText('School name'), { target: { value: 'UWF' } });
    fireEvent.click(screen.getByRole('button', { name: 'Save' }));

    await waitFor(() => expect(onClose).toHaveBeenCalledWith(true));
  });

  it('never blocks the user when the skip POST fails', async () => {
    mockFetch(() => Promise.reject(new Error('offline')));
    const onClose = vi.fn();
    render(<SchoolPrompt onClose={onClose} dismissible={false} />);

    fireEvent.click(screen.getByRole('button', { name: 'Not a student' }));

    await waitFor(() => expect(onClose).toHaveBeenCalledWith(true));
  });

  it('writes once however many times Save is tapped', async () => {
    let release;
    const fetchFn = mockFetch(() => new Promise((resolve) => { release = () => resolve({ ok: true, json: () => Promise.resolve({}) }); }));
    const onClose = vi.fn();
    render(<SchoolPrompt onClose={onClose} />);

    fireEvent.change(screen.getByLabelText('School name'), { target: { value: 'UWF' } });
    const save = screen.getByRole('button', { name: 'Save' });
    fireEvent.click(save);
    fireEvent.click(save);
    fireEvent.click(save);

    expect(fetchFn).toHaveBeenCalledTimes(1);
    release();
    await waitFor(() => expect(onClose).toHaveBeenCalledTimes(1));
  });
});

describe('the graduation term', () => {
  // A May and a December graduate are a full exam cycle apart, so the year
  // alone merges two different cohorts into one row of a report.
  it('offers the four terms and sends the chosen one lowercase', async () => {
    const fetchFn = mockFetch();
    render(<SchoolPrompt onClose={() => {}} />);
    for (const t of GRAD_TERMS) expect(screen.getByText(t)).toBeInTheDocument();

    fireEvent.change(screen.getByLabelText('School name'), { target: { value: 'Purdue' } });
    fireEvent.click(screen.getByText('Fall'));
    fireEvent.click(screen.getByRole('button', { name: /save/i }));
    await waitFor(() => expect(lastBody(fetchFn).graduationTerm).toBe('fall'));
  });

  it('sends a term without a year, and a year without a term', async () => {
    const fetchFn = mockFetch();
    const { unmount } = render(<SchoolPrompt onClose={() => {}} />);
    fireEvent.change(screen.getByLabelText('School name'), { target: { value: 'Purdue' } });
    fireEvent.click(screen.getByText('Spring'));
    fireEvent.click(screen.getByRole('button', { name: /save/i }));
    await waitFor(() => {
      expect(lastBody(fetchFn).graduationTerm).toBe('spring');
      expect(lastBody(fetchFn).graduationYear).toBeNull();
    });
    unmount();

    const f2 = mockFetch();
    render(<SchoolPrompt onClose={() => {}} />);
    fireEvent.change(screen.getByLabelText('School name'), { target: { value: 'Purdue' } });
    fireEvent.click(screen.getByText(String(gradYearOptions()[0])));
    fireEvent.click(screen.getByRole('button', { name: /save/i }));
    await waitFor(() => {
      expect(lastBody(f2).graduationYear).toBe(gradYearOptions()[0]);
      expect(lastBody(f2).graduationTerm).toBeNull();
    });
  });

  it('"Already graduated" clears the term too', async () => {
    const fetchFn = mockFetch();
    render(<SchoolPrompt onClose={() => {}} />);
    fireEvent.change(screen.getByLabelText('School name'), { target: { value: 'Purdue' } });
    fireEvent.click(screen.getByText('Summer'));
    fireEvent.click(screen.getByText('Already graduated'));
    fireEvent.click(screen.getByRole('button', { name: /save/i }));
    await waitFor(() => {
      expect(lastBody(fetchFn).graduationTerm).toBeNull();
      expect(lastBody(fetchFn).graduationYear).toBeNull();
    });
  });
});

// Free text alone was measured on 2026-10-07 and produced nothing usable: 19
// users had given a school and there were 19 distinct names, with "UCI" and
// "University of California, Irvine" counted as separate institutions. The
// field now suggests canonical names over the top. These tests are mostly
// about the word "only": a suggestion is a shortcut, never a gate.
describe('suggesting a school', () => {
  it('offers canonical names once enough is typed', async () => {
    mockFetch(() => Promise.resolve({
      ok: true,
      json: () => Promise.resolve({ schools: ['University of California, Irvine'] }),
    }));
    render(<SchoolPrompt onClose={() => {}} />);
    fireEvent.change(screen.getByLabelText(/school name/i), { target: { value: 'irv' } });
    expect(await screen.findByText('University of California, Irvine')).toBeTruthy();
  });

  it('fills the field when one is clicked', async () => {
    mockFetch(() => Promise.resolve({
      ok: true,
      json: () => Promise.resolve({ schools: ['Clemson University'] }),
    }));
    render(<SchoolPrompt onClose={() => {}} />);
    const field = screen.getByLabelText(/school name/i);
    fireEvent.change(field, { target: { value: 'clem' } });
    fireEvent.click(await screen.findByText('Clemson University'));
    await waitFor(() => expect(field.value).toBe('Clemson University'));
  });

  it('asks for nothing until two characters, which would match everything', async () => {
    const fn = mockFetch(() => Promise.resolve({
      ok: true, json: () => Promise.resolve({ schools: [] }),
    }));
    render(<SchoolPrompt onClose={() => {}} />);
    fireEvent.change(screen.getByLabelText(/school name/i), { target: { value: 'u' } });
    await new Promise((r) => setTimeout(r, 400));
    expect(fn).not.toHaveBeenCalled();
  });

  it('always says a school that is not listed is still accepted', async () => {
    mockFetch(() => Promise.resolve({
      ok: true,
      json: () => Promise.resolve({ schools: ['Clemson University'] }),
    }));
    render(<SchoolPrompt onClose={() => {}} />);
    fireEvent.change(screen.getByLabelText(/school name/i), { target: { value: 'clem' } });
    expect(await screen.findByText(/not listed/i)).toBeTruthy();
  });

  it('keeps what was typed when nothing matched', async () => {
    // The directory is a seed and always will be incomplete. An unknown
    // university must never block somebody from answering.
    mockFetch(() => Promise.resolve({
      ok: true, json: () => Promise.resolve({ schools: [] }),
    }));
    render(<SchoolPrompt onClose={() => {}} />);
    const field = screen.getByLabelText(/school name/i);
    fireEvent.change(field, { target: { value: 'Universidad Nacional de Ingenieria' } });
    await new Promise((r) => setTimeout(r, 400));
    expect(field.value).toBe('Universidad Nacional de Ingenieria');
    expect(screen.queryByText(/not listed/i)).toBeNull();
  });

  it('loses the list rather than the field when the request fails', async () => {
    mockFetch(() => Promise.reject(new Error('offline')));
    render(<SchoolPrompt onClose={() => {}} />);
    const field = screen.getByLabelText(/school name/i);
    fireEvent.change(field, { target: { value: 'clemson' } });
    await new Promise((r) => setTimeout(r, 400));
    expect(field.value).toBe('clemson');
    expect(screen.queryByRole('listbox')).toBeNull();
  });
});
