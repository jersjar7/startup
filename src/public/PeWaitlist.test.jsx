import React from 'react';
import { describe, it, expect, vi, afterEach } from 'vitest';
import { render, screen, fireEvent, waitFor, within } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { PeWaitlist } from './PeWaitlist.jsx';
import { PE_PROBLEMS, isRight } from './peProblems';

function mount() {
  return render(<MemoryRouter><PeWaitlist /></MemoryRouter>);
}

afterEach(() => vi.restoreAllMocks());

describe('PE sample problems', () => {
  it('never says which PE exam we are building first', () => {
    mount();
    // The exam's name may appear only among the others, on the book stack.
    const words = document.body.textContent
      .replaceAll('PE Civil: Water Resources and Environmental', '')
      .replaceAll('PE Civil: Water Resources', '');
    expect(words).not.toMatch(/Water Resources/);
  });

  it('uses the three question formats of the computer-based exam', () => {
    expect(PE_PROBLEMS.map((p) => p.kind)).toEqual(['one', 'number', 'many']);
  });

  it('marks only the right answers right', () => {
    const [runoff, depth, clar] = PE_PROBLEMS;
    expect(isRight(runoff, ['B'])).toBe(true);
    expect(isRight(runoff, ['D'])).toBe(false);
    expect(isRight(depth, '3.85')).toBe(true);
    expect(isRight(depth, '3,85')).toBe(true);
    expect(isRight(depth, '4.68')).toBe(false);
    expect(isRight(depth, '')).toBe(false);
    expect(isRight(clar, ['C', 'A', 'B'])).toBe(true);
    expect(isRight(clar, ['A', 'B'])).toBe(false);
    expect(isRight(clar, ['A', 'B', 'C', 'D'])).toBe(false);
  });

  it('shows the worked solution once an answer is checked', () => {
    mount();
    expect(screen.queryByText('Worked solution')).toBeNull();
    const panel = document.getElementById('pv-runoff');
    fireEvent.click(within(panel).getByText('28.5 ac-ft'));
    fireEvent.click(within(panel).getByRole('button', { name: /Check answer/ }));
    expect(within(panel).getByRole('status').textContent).toMatch(/Correct.*28\.5 ac-ft/);
    expect(within(panel).getByText('Worked solution')).toBeTruthy();
  });

  it('shows the three problems below the signup, switched with tabs', () => {
    mount();
    expect(document.querySelector('.pe-hero #pv-runoff')).toBeNull();
    expect(document.getElementById('pv-runoff').hidden).toBe(false);
    expect(document.getElementById('pv-clarifier').hidden).toBe(true);
    fireEvent.click(screen.getByRole('tab', { name: /Clarifier design check/ }));
    expect(document.getElementById('pv-clarifier').hidden).toBe(false);
    expect(document.getElementById('pv-runoff').hidden).toBe(true);
    expect(screen.getByText('Question 3 of 3')).toBeTruthy();
  });
});

describe('PE waitlist form', () => {
  it('asks only for an email first, then which PE and when, optional', async () => {
    const fetchMock = vi.spyOn(globalThis, 'fetch').mockResolvedValue({ ok: true, json: async () => ({ ok: true }) });
    mount();
    const form = document.querySelector('.pe-hero .pe-form');
    expect(form.querySelector('select')).toBeNull();
    expect(within(form).getByRole('button').textContent).toMatch('Join the waiting list');
    fireEvent.change(within(form).getByLabelText('Email'), { target: { value: 'pat@firm.com' } });
    fireEvent.submit(form);
    await waitFor(() => expect(screen.getByText(/You are on the waiting list/)).toBeTruthy());
    const [url, opts] = fetchMock.mock.calls[0];
    expect(url).toBe('/api/waitlist');
    expect(JSON.parse(opts.body)).toMatchObject({ email: 'pat@firm.com', place: 'top' });
    expect(JSON.parse(opts.body).exam).toBeUndefined();

    fireEvent.change(screen.getByLabelText('Which PE exam?'), { target: { value: 'pe-civil-geotechnical' } });
    fireEvent.change(screen.getByLabelText('When are you taking it?'), { target: { value: '2027-04-to-12' } });
    fireEvent.submit(document.querySelector('.pe-when'));
    await waitFor(() => expect(screen.getByText(/Saved\. Thank you/)).toBeTruthy());
    expect(JSON.parse(fetchMock.mock.calls[1][1].body)).toMatchObject({ email: 'pat@firm.com', exam: 'pe-civil-geotechnical', when: '2027-04-to-12' });
  });

  it('shows the server message when the address is turned away', async () => {
    vi.spyOn(globalThis, 'fetch').mockResolvedValue({ ok: false, json: async () => ({ msg: 'That email address does not look right.' }) });
    mount();
    const form = document.querySelectorAll('.pe-form')[1];
    fireEvent.change(within(form).getByLabelText('Email'), { target: { value: 'x@y.z' } });
    fireEvent.submit(form);
    await waitFor(() => expect(screen.getByRole('alert').textContent).toMatch(/does not look right/));
  });
});
