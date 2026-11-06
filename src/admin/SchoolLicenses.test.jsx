import React from 'react';
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { render, screen, fireEvent, within, waitFor } from '@testing-library/react';
import { SchoolLicensesPanel } from './SchoolLicenses';

// The owner's school licence list on /admin (ADR 0040).

const lic = (over = {}) => ({
  id: 'l1', schoolName: 'Brigham Young University', domains: ['byu.edu', 'student.byu.edu'],
  startsAt: '2026-08-01T00:00:00.000Z', endsAt: '2027-08-01T00:00:00.000Z', endedAt: null,
  seatCap: 500, seatsUsed: 37, seatsLeft: 463, state: 'active',
  contactName: 'Dr. Ames', contactEmail: 'ames@byu.edu', notes: 'PO 4471', createdAt: '2026-08-01T00:00:00Z',
  ...over,
});

let list;
let calls;
let nextError;

function mockFetch() {
  calls = [];
  return vi.fn((url, opts = {}) => {
    const u = String(url);
    const method = opts.method || 'GET';
    calls.push({ url: u, method, body: opts.body ? JSON.parse(opts.body) : null });
    const ok = (body, s = 200) => Promise.resolve({ ok: true, status: s, json: () => Promise.resolve(body) });
    if (u === '/api/admin/school-licenses' && method === 'GET') return ok({ licenses: list });
    if (nextError) {
      const msg = nextError;
      nextError = null;
      return Promise.resolve({ ok: false, status: 400, json: () => Promise.resolve({ msg }) });
    }
    if (u === '/api/admin/school-licenses' && method === 'POST') {
      const b = JSON.parse(opts.body);
      list = [...list, lic({ id: 'l2', ...b, domains: b.domains.split(/,\s*/), seatsUsed: 0 })];
      return ok(list[list.length - 1], 201);
    }
    if (u.endsWith('/end')) { list = list.map((l) => ({ ...l, state: 'ended', endedAt: '2026-11-06T00:00:00Z' })); return ok(list[0]); }
    if (method === 'PATCH') {
      const b = JSON.parse(opts.body);
      list = list.map((l) => ({ ...l, ...b, domains: b.domains.split(/,\s*/) }));
      return ok(list[0]);
    }
    return Promise.resolve({ ok: false, status: 404, json: () => Promise.resolve({}) });
  });
}

describe('SchoolLicensesPanel', () => {
  beforeEach(() => {
    list = [lic(), lic({ id: 'l0', schoolName: 'Utah State University', domains: ['usu.edu'], seatCap: 40, seatsUsed: 40, seatsLeft: 0 })];
    nextError = null;
    vi.stubGlobal('fetch', mockFetch());
    vi.stubGlobal('confirm', () => true);
  });
  afterEach(() => {
    vi.unstubAllGlobals();
    vi.restoreAllMocks();
  });

  it('lists each licence with its domains, dates and seats used', async () => {
    render(<SchoolLicensesPanel />);
    const card = await screen.findByRole('article', { name: 'Brigham Young University' });
    expect(within(card).getByText('@byu.edu, @student.byu.edu')).toBeInTheDocument();
    expect(within(card).getByRole('meter', { name: '37 of 500 seats used' })).toBeInTheDocument();
    expect(within(card).getByText('Active')).toBeInTheDocument();
    expect(screen.getByText('2 active · 77 seats in use')).toBeInTheDocument();
  });

  it('says plainly when a licence is full', async () => {
    render(<SchoolLicensesPanel />);
    const card = await screen.findByRole('article', { name: 'Utah State University' });
    expect(within(card).getByText(/Full\. New students are told to ask their department/)).toBeInTheDocument();
  });

  it('creates a licence', async () => {
    list = [];
    render(<SchoolLicensesPanel />);
    fireEvent.click(await screen.findByRole('button', { name: /New licence/ }));
    const form = screen.getByRole('form', { name: 'New licence' });
    fireEvent.change(within(form).getByPlaceholderText('Brigham Young University'), { target: { value: 'Weber State University' } });
    fireEvent.change(within(form).getByPlaceholderText('byu.edu, student.byu.edu'), { target: { value: 'weber.edu' } });
    fireEvent.change(within(form).getByRole('spinbutton'), { target: { value: '120' } });
    fireEvent.click(within(form).getByRole('button', { name: 'Create licence' }));
    expect(await screen.findByRole('article', { name: 'Weber State University' })).toBeInTheDocument();
    const post = calls.find((c) => c.method === 'POST');
    expect(post.body).toMatchObject({ schoolName: 'Weber State University', domains: 'weber.edu', seatCap: 120 });
    expect(post.body.startsAt).toMatch(/^\d{4}-\d{2}-\d{2}$/);
  });

  it('shows the server\'s reason when a licence is refused', async () => {
    list = [];
    render(<SchoolLicensesPanel />);
    fireEvent.click(await screen.findByRole('button', { name: /New licence/ }));
    const form = screen.getByRole('form', { name: 'New licence' });
    fireEvent.change(within(form).getByPlaceholderText('Brigham Young University'), { target: { value: 'X' } });
    fireEvent.change(within(form).getByPlaceholderText('byu.edu, student.byu.edu'), { target: { value: 'gmail.com' } });
    nextError = 'gmail.com is not a school domain (.edu, .edu.xx or .ac.xx).';
    fireEvent.click(within(form).getByRole('button', { name: 'Create licence' }));
    expect(await screen.findByRole('alert')).toHaveTextContent('gmail.com is not a school domain');
  });

  it('edits seats on a licence', async () => {
    render(<SchoolLicensesPanel />);
    const card = await screen.findByRole('article', { name: 'Brigham Young University' });
    fireEvent.click(within(card).getByRole('button', { name: /Edit/ }));
    const form = screen.getByRole('form', { name: 'Edit licence' });
    expect(within(form).getByDisplayValue('byu.edu, student.byu.edu')).toBeInTheDocument();
    fireEvent.change(within(form).getByRole('spinbutton'), { target: { value: '600' } });
    fireEvent.click(within(form).getByRole('button', { name: 'Save changes' }));
    await waitFor(() => expect(calls.some((c) => c.method === 'PATCH' && c.url === '/api/admin/school-licenses/l1')).toBe(true));
    expect(calls.find((c) => c.method === 'PATCH').body.seatCap).toBe(600);
  });

  it('ends a licence after a confirmation', async () => {
    list = [lic()];
    render(<SchoolLicensesPanel />);
    const card = await screen.findByRole('article', { name: 'Brigham Young University' });
    fireEvent.click(within(card).getByRole('button', { name: 'End now' }));
    expect(await screen.findByText('Ended early')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Reopen' })).toBeInTheDocument();
  });
});
