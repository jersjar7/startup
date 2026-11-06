import React from 'react';
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { ExamGate } from './ExamGate';

// The exam simulation gate with school site licences (ADR 0040): what a
// student sees depends on what /api/checkout/status says about their school.

const BYU = { name: 'Brigham Young University', domains: ['byu.edu'], endsAt: '2027-08-01T00:00:00Z' };
const PRICING = { standard: 49, student: 35, applies: false, studentVerified: false, verifiedStudentEmail: null };

let status;
let confirmBody;
let calls;

function mockFetch() {
  calls = [];
  return vi.fn((url, opts = {}) => {
    const u = String(url);
    calls.push({ url: u, method: opts.method || 'GET', body: opts.body });
    const ok = (body) => Promise.resolve({ ok: true, status: 200, json: () => Promise.resolve(body) });
    if (u.startsWith('/api/checkout/status')) return ok(status);
    if (u.startsWith('/api/checkout/pricing')) return ok(PRICING);
    if (u.startsWith('/api/exam/attempts')) return ok([]);
    if (u.startsWith('/api/checkout/student/start')) return ok({ sent: true });
    if (u.startsWith('/api/checkout/student/confirm')) return ok(confirmBody);
    return Promise.resolve({ ok: false, status: 404, json: () => Promise.resolve({}) });
  });
}

const renderGate = (userName = 'sam@byu.edu') => render(
  <MemoryRouter initialEntries={['/exam']}>
    <ExamGate userName={userName} />
  </MemoryRouter>,
);

describe('ExamGate and school licences', () => {
  beforeEach(() => {
    status = { purchased: false, access: null };
    confirmBody = { verified: true, student: 35, schoolAccess: false };
    vi.stubGlobal('fetch', mockFetch());
  });
  afterEach(() => {
    vi.unstubAllGlobals();
    vi.restoreAllMocks();
  });

  it('a student at a licensed school sees their school gives it, and a verify step instead of checkout', async () => {
    status = { purchased: false, access: null, school: BYU, schoolReason: 'unverified' };
    renderGate();
    expect(await screen.findByRole('heading', { name: 'Your school gives you the exam simulation' })).toBeInTheDocument();
    expect(screen.getByText(/Brigham Young University pays for its students/)).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /Buy the Exam Simulation/ })).not.toBeInTheDocument();
    // Their account address is already on the domain, so it is filled in.
    await waitFor(() => expect(screen.getByPlaceholderText('you@byu.edu')).toHaveValue('sam@byu.edu'));
  });

  it('verifying the code takes a licensed student straight to the simulation', async () => {
    status = { purchased: false, access: null, school: BYU, schoolReason: 'unverified' };
    confirmBody = { verified: true, student: 35, schoolAccess: true, school: BYU };
    renderGate();
    // The button stays disabled until the address is in the box.
    await waitFor(() => expect(screen.getByRole('button', { name: 'Send my code' })).toBeEnabled(), { timeout: 4000 });
    fireEvent.click(screen.getByRole('button', { name: 'Send my code' }));
    const codeBox = await screen.findByPlaceholderText('123456', {}, { timeout: 4000 });
    fireEvent.change(codeBox, { target: { value: '123456' } });
    fireEvent.click(screen.getByRole('button', { name: 'Verify' }));
    expect(await screen.findByRole('button', { name: /Start New Exam/ }, { timeout: 4000 })).toBeInTheDocument();
    expect(screen.getByText('Given to you by Brigham Young University')).toBeInTheDocument();
    const sent = calls.find((c) => c.url === '/api/checkout/student/start');
    expect(JSON.parse(sent.body)).toEqual({ eduEmail: 'sam@byu.edu' });
  });

  it('a student who is not at that school can still see the price', async () => {
    status = { purchased: false, access: null, school: BYU, schoolReason: 'unverified' };
    renderGate('someone@gmail.com');
    fireEvent.click(await screen.findByRole('button', { name: /Not a student there/ }));
    expect(await screen.findByRole('button', { name: /Buy the Exam Simulation for \$49/ })).toBeInTheDocument();
  });

  it('a student at an unlicensed school sees the ordinary page, told a licence would make it free', async () => {
    renderGate('lee@gmail.com');
    expect(await screen.findByRole('button', { name: /Buy the Exam Simulation for \$49/ })).toBeInTheDocument();
    expect(screen.getByText(/nothing if their school has a licence with us/)).toBeInTheDocument();
    expect(screen.queryByText(/Your school gives you/)).not.toBeInTheDocument();
  });

  it('a student their school covers lands on the simulation, credited to the school', async () => {
    status = { purchased: true, access: 'school', school: BYU };
    renderGate();
    expect(await screen.findByRole('button', { name: /Start New Exam/ })).toBeInTheDocument();
    expect(screen.getByText('Given to you by Brigham Young University')).toBeInTheDocument();
  });

  it('a buyer sees no school line', async () => {
    status = { purchased: true, access: 'purchase' };
    renderGate('buyer@gmail.com');
    await screen.findByRole('button', { name: /Start New Exam/ });
    expect(screen.queryByText(/Given to you by/)).not.toBeInTheDocument();
  });

  it('when the seats are gone, the student is told to ask their department', async () => {
    status = { purchased: false, access: null, school: BYU, schoolReason: 'seats_full' };
    renderGate();
    expect(await screen.findByText('Every seat at Brigham Young University is taken')).toBeInTheDocument();
    expect(screen.getByText(/Ask your department to add seats/)).toBeInTheDocument();
  });
});
