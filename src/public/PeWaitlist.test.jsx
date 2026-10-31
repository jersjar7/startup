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

  it('switches problems with the tabs', () => {
    mount();
    expect(document.getElementById('pv-normal-depth').hidden).toBe(true);
    fireEvent.click(screen.getByRole('tab', { name: /Normal depth/ }));
    expect(document.getElementById('pv-normal-depth').hidden).toBe(false);
    expect(document.getElementById('pv-runoff').hidden).toBe(true);
    expect(screen.getByText('Question 2 of 3')).toBeTruthy();
  });
});

describe('PE waitlist form', () => {
  it('sends the address, the timing and where the form is, then confirms', async () => {
    const fetchMock = vi.spyOn(globalThis, 'fetch').mockResolvedValue({ ok: true, json: async () => ({ ok: true }) });
    mount();
    const form = document.querySelector('.pe-form');
    fireEvent.change(within(form).getByLabelText('Email'), { target: { value: 'pat@firm.com' } });
    fireEvent.change(within(form).getByLabelText('When are you taking it?'), { target: { value: '2027-04-to-12' } });
    fireEvent.submit(form);
    await waitFor(() => expect(screen.getByText(/You are on the list/)).toBeTruthy());
    const [url, opts] = fetchMock.mock.calls[0];
    expect(url).toBe('/api/waitlist');
    expect(JSON.parse(opts.body)).toMatchObject({ email: 'pat@firm.com', when: '2027-04-to-12', place: 'top', exam: 'pe-civil-wre' });
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
