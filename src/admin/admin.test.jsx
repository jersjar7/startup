import React from 'react';
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { render, screen, within, waitFor, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { Admin } from './admin';

/* jsdom has no ResizeObserver and Chart.jsx measures its container with one. */
class RO {
  observe() {}
  unobserve() {}
  disconnect() {}
}

const AXIS = ['2026-10-01', '2026-10-02', '2026-10-03'];

const series = (a, b, c) => [a, b, c];

const timeseries = (days, allTime = false) => ({
  tz: 'America/Los_Angeles',
  days,
  allTime,
  axis: AXIS,
  series: {
    signups: series(1, 2, 3),
    cumulativeUsers: series(50, 52, 55),
    activeUsers: series(4, 5, 6),
    sessions: series(7, 8, 9),
    problems: series(40, 50, 60),
    correct: series(30, 40, 45),
    diagnostics: series(1, 0, 2),
    quickstartActivations: series(2, 1, 3),
    examSims: series(0, 1, 0),
    checkoutStarts: series(1, 1, 2),
    purchases: series(0, 1, 1),
    revenue: series(0, 29, 49),
    cumulativeRevenue: series(205, 234, 283),
  },
  snapshot: {
    totalUsers: 252,
    activeUsers7d: 12,
    activeUsers30d: 31,
    totalPurchases: 7,
    totalRevenue: 283,
    arppu: 40.43,
    quickstartActivated: 9,
    activationMedianMinutes: 6,
    activationRate: 25,
    cohortSignups: 20,
    cohortActivated: 5,
    activationRateAllTime: 3.6,
  },
});

const METRICS = {
  signups: 58,
  diagnosticUsers: 11,
  quickstartActivated: 9,
  quickstartCompleted: 4,
  checkoutStarts: 4,
  purchases: 2,
  revenue: 283,
  conversion: {
    signupToActivation: 15.5,
    activationToCompletion: 44.4,
    signupToDiagnostic: 19,
    signupToCheckout: 6.9,
    checkoutToPurchase: 50,
    signupToPurchase: 3.4,
  },
};

const RECENT = {
  total: 252,
  users: [
    { emailMasked: 'j***n@gmail.com', createdAt: '2026-10-03T12:00:00Z', emailVerified: true, activated: true, chaptersMapped: 3, totalXp: 940, purchased: true },
    { emailMasked: 'a***a@byu.edu', createdAt: '2026-10-02T12:00:00Z', emailVerified: false, activated: false, chaptersMapped: 0, totalXp: 0, purchased: false },
  ],
  purchases: [
    { emailMasked: 'j***n@gmail.com', amount: 4900, tier: 'standard', createdAt: '2026-10-03T12:00:00Z' },
  ],
};

const ACQUISITION = {
  answered: 26,
  totalUsers: 252,
  selfReported: [{ source: 'search', count: 14 }, { source: 'reddit', count: 8 }],
  referrers: [{ host: 'google.com', count: 19 }, { host: 'reddit.com', count: 5 }],
};

// A date far enough out that the calendar always has an upcoming month.
const futureYmd = (() => {
  const d = new Date();
  d.setDate(d.getDate() + 40);
  return new Intl.DateTimeFormat('en-CA', { year: 'numeric', month: '2-digit', day: '2-digit' }).format(d);
})();

const EXAM_DATES = { total: 4, dates: [{ date: futureYmd, count: 4 }] };

const EMAIL_STATUS = {
  from: 'noreply@fe4raccoons.com',
  usingTestSender: false,
  budget: { day: 12, month: 310, dailyCap: 100, monthlyCap: 3000, dailyLifecycleMax: 60, monthlySoft: 2500 },
};

const PITCH = { pitched: 18, clicked: 6, converted: 2, storyClicks: 3, examClicks: 4, followups: 5 };

let tsRequests = [];

function mockFetch() {
  tsRequests = [];
  return vi.fn((url) => {
    const u = String(url);
    const ok = (body) => Promise.resolve({ ok: true, status: 200, json: () => Promise.resolve(body) });
    if (u.startsWith('/api/admin/metrics')) return ok(METRICS);
    if (u.startsWith('/api/admin/timeseries')) {
      // Kept as sent: "all" is a word, and coercing it to a number here would
      // hide the one case this needs to prove.
      const raw = new URL(u, 'http://x').searchParams.get('days');
      tsRequests.push(raw === 'all' ? 'all' : Number(raw));
      return ok(timeseries(raw === 'all' ? 126 : Number(raw), raw === 'all'));
    }
    if (u.startsWith('/api/admin/recent')) return ok(RECENT);
    if (u.startsWith('/api/admin/acquisition')) return ok(ACQUISITION);
    if (u.startsWith('/api/admin/exam-dates')) return ok(EXAM_DATES);
    if (u.startsWith('/api/admin/email-status')) return ok(EMAIL_STATUS);
    if (u.startsWith('/api/admin/pitch-stats')) return ok(PITCH);
    if (u.startsWith('/api/admin/user-lookup')) {
      return ok({
        email: 'jerson@example.com', firstName: 'Jerson', lastName: 'Garcia',
        createdAt: '2026-10-01T12:00:00Z', emailVerified: true, examDate: '2026-12-01',
        totalXp: 940, currentStreak: 5, chaptersMapped: 3, activatedAt: '2026-10-01T13:00:00Z',
        examSimAccess: true, purchases: [{ amount: 4900, tier: 'standard', status: 'paid' }],
      });
    }
    return Promise.resolve({ ok: false, status: 404, json: () => Promise.resolve({}) });
  });
}

async function renderAdmin() {
  const utils = render(
    <MemoryRouter>
      <Admin userName="admin@oqupa.com" onLogout={() => {}} />
    </MemoryRouter>,
  );
  // The page renders a loading state until /metrics resolves.
  await screen.findByRole('tablist', { name: 'Dashboard sections' });
  // ...and the summary row fills in once the time-series snapshot lands.
  await screen.findByText('252');
  return utils;
}

const tab = (name) => screen.getByRole('tab', { name: new RegExp(name, 'i') });
const openTab = async (name) => {
  fireEvent.click(tab(name));
  await waitFor(() => expect(tab(name)).toHaveAttribute('aria-selected', 'true'));
};

describe('Admin dashboard', () => {
  beforeEach(() => {
    vi.stubGlobal('ResizeObserver', RO);
    vi.stubGlobal('fetch', mockFetch());
  });
  afterEach(() => {
    vi.unstubAllGlobals();
    vi.restoreAllMocks();
  });

  it('shows the four summary numbers above the tabs, with no tab opened', async () => {
    const { container } = await renderAdmin();
    const summary = container.querySelector('.admin-summary');
    expect(summary).toBeTruthy();

    // Headline values, present before anything is clicked.
    expect(within(summary).getByText('252')).toBeInTheDocument();   // total users
    expect(within(summary).getByText('12')).toBeInTheDocument();    // active 7 days
    expect(within(summary).getByText('$283.00')).toBeInTheDocument(); // total revenue
    expect(within(summary).getByText('25%')).toBeInTheDocument();   // activation rate
    expect(within(summary).getByText('Total users')).toBeInTheDocument();
    expect(within(summary).getByText('Active · 7 days')).toBeInTheDocument();
    expect(within(summary).getByText('Total revenue')).toBeInTheDocument();
    expect(within(summary).getByText('Activation rate')).toBeInTheDocument();

    // The summary row sits outside every tab panel.
    expect(container.querySelector('.admin-panel')?.contains(summary)).toBe(false);
  });

  it('renders all four tabs, Growth first', async () => {
    await renderAdmin();
    const tabs = screen.getAllByRole('tab').filter((b) => b.className.includes('admin-tab'));
    expect(tabs.map((b) => b.textContent)).toEqual(['Growth', 'Engagement', 'Revenue', 'Users']);
    expect(tab('Growth')).toHaveAttribute('aria-selected', 'true');
  });

  it('every tab renders its own content', async () => {
    await renderAdmin();

    // Growth
    expect(screen.getByText('New signups')).toBeInTheDocument();
    expect(screen.getByText('How users found us')).toBeInTheDocument();

    await openTab('Engagement');
    expect(screen.getByText('Active users')).toBeInTheDocument();
    expect(screen.getByText('Problems answered')).toBeInTheDocument();
    expect(screen.getByText('Upcoming exam dates')).toBeInTheDocument();
    expect(screen.queryByText('New signups')).not.toBeInTheDocument();

    await openTab('Revenue');
    expect(screen.getByText('Conversion funnel')).toBeInTheDocument();
    expect(screen.getByText('Exam-sim pitch')).toBeInTheDocument();
    expect(screen.getByText('Recent purchases')).toBeInTheDocument();

    await openTab('Users');
    expect(screen.getByText('Recent users')).toBeInTheDocument();
    expect(screen.getByText('Email budget')).toBeInTheDocument();
    expect(screen.getByPlaceholderText(/Look up a user by full email/)).toBeInTheDocument();
  });

  it('keeps the selected range when the tab changes, and keeps the summary row visible', async () => {
    const { container } = await renderAdmin();
    const range = (label) => within(container.querySelector('.admin-range')).getByText(label);

    expect(range('30d')).toHaveAttribute('aria-selected', 'true');
    fireEvent.click(range('90d'));
    await waitFor(() => expect(range('90d')).toHaveAttribute('aria-selected', 'true'));
    expect(tsRequests).toContain(90);

    const before = tsRequests.length;
    for (const name of ['Engagement', 'Revenue', 'Users', 'Growth']) {
      await openTab(name);
      expect(range('90d')).toHaveAttribute('aria-selected', 'true');
      expect(range('7d')).toHaveAttribute('aria-selected', 'false');
      // Summary row stays put on every tab.
      const summary = container.querySelector('.admin-summary');
      expect(within(summary).getByText('252')).toBeInTheDocument();
      expect(within(summary).getByText('$283.00')).toBeInTheDocument();
    }
    // Changing tabs must not refetch the time-series.
    expect(tsRequests.length).toBe(before);
    expect(tsRequests.at(-1)).toBe(90);

    fireEvent.click(range('7d'));
    await waitFor(() => expect(range('7d')).toHaveAttribute('aria-selected', 'true'));
    expect(tsRequests).toContain(7);
  });

  it('offers all time, and asks the server for it by name rather than a number', async () => {
    // A fixed ceiling would have silently started truncating all-time once the
    // platform was a year old, with nothing on the page saying so. The server
    // works the window out from the first real account instead.
    const { container } = await renderAdmin();
    const range = (label) => within(container.querySelector('.admin-range')).getByText(label);

    fireEvent.click(range('All'));
    await waitFor(() => expect(range('All')).toHaveAttribute('aria-selected', 'true'));
    expect(tsRequests).toContain('all');
    expect(tsRequests).not.toContain(NaN);
  });

  it('keeps all time selected across every tab', async () => {
    const { container } = await renderAdmin();
    const range = (label) => within(container.querySelector('.admin-range')).getByText(label);
    fireEvent.click(range('All'));
    await waitFor(() => expect(range('All')).toHaveAttribute('aria-selected', 'true'));

    const before = tsRequests.length;
    for (const name of ['Engagement', 'Revenue', 'Users', 'Growth']) {
      await openTab(name);
      expect(range('All')).toHaveAttribute('aria-selected', 'true');
      expect(range('30d')).toHaveAttribute('aria-selected', 'false');
    }
    expect(tsRequests.length).toBe(before);
  });

  it('a metric definition still opens from the summary row', async () => {
    await renderAdmin();
    fireEvent.click(screen.getByRole('button', { name: 'What does "Total users" mean?' }));
    expect(await screen.findByRole('tooltip')).toHaveTextContent(/all-time number of real accounts/i);
  });

  it('looks a single user up from the Users tab', async () => {
    await renderAdmin();
    await openTab('Users');
    fireEvent.change(screen.getByPlaceholderText(/Look up a user by full email/), {
      target: { value: 'jerson@example.com' },
    });
    fireEvent.click(screen.getByRole('button', { name: 'Look up' }));
    expect(await screen.findByText('jerson@example.com')).toBeInTheDocument();
    expect(screen.getByText('Jerson Garcia')).toBeInTheDocument();
    expect(screen.getByText('Chapters mapped')).toBeInTheDocument();
  });

  it('warns when email delivery has fallen back to the test sender', async () => {
    const base = mockFetch();
    vi.stubGlobal('fetch', vi.fn((url) => {
      if (String(url).startsWith('/api/admin/email-status')) {
        return Promise.resolve({
          ok: true, status: 200,
          json: () => Promise.resolve({ ...EMAIL_STATUS, usingTestSender: true, from: 'onboarding@resend.dev' }),
        });
      }
      return base(url);
    }));
    await renderAdmin();
    expect(await screen.findByRole('alert')).toHaveTextContent(/Email delivery is DOWN/);
  });

  it('still blocks a non-owner and reports a failed load', async () => {
    vi.stubGlobal('fetch', vi.fn(() => Promise.resolve({ ok: false, status: 403, json: () => Promise.resolve({}) })));
    render(
      <MemoryRouter>
        <Admin userName="someone@else.com" onLogout={() => {}} />
      </MemoryRouter>,
    );
    expect(await screen.findByText('Owner only')).toBeInTheDocument();
  });

  /* ── Regression guard: the single-column page showed all of this at once.
     After the tab split every one of these must still be reachable. ── */
  it('loses none of the data the single-column page displayed', async () => {
    const { container } = await renderAdmin();

    const expected = {
      growth: [
        'Total users', 'New signups', 'cumulative',
        'Activated · since launch', '5/20',
        'Median time to start', '6 min',
        'Quick-start started',
        'How users found us', '26 of 252 answered',
        'They told us', 'Google / search', 'Reddit',
        'Referrer (captured automatically)', 'google.com', 'reddit.com',
      ],
      engagement: [
        'Active users', 'Problems answered', 'Exam sims completed',
        'Upcoming exam dates', '4 users with a date set',
      ],
      revenue: [
        'Purchases', '7', 'Rev / paying user', '$40.43',
        'Revenue', 'Total revenue', 'Checkout starts',
        'Conversion funnel', 'all-time · 3.4% signup to purchase',
        'Signups', '58', 'Activated (quick-start)', '9', '15.5% of signups',
        'Started checkout', '4', '6.9% of signups',
        'Purchased', '2', '50% of checkouts',
        'Exam-sim pitch', 'Pitched', '18', 'Link opens', '6',
        'Bought after pitch', '2', '11% of pitched',
        'Recent purchases', '$49.00', 'standard',
      ],
      users: [
        'Recent users', 'Joined (PT)', 'Verified', 'Activated', 'Chapters', 'XP', 'Paid',
        'j***n@gmail.com', 'a***a@byu.edu', '3/15', '940', '0/15',
        'Email budget', 'Today', 'This month', '100', '3000',
        'lifecycle stops here at 60', 'soft cap at 2500',
      ],
    };

    const seen = new Set();
    for (const [name, needles] of Object.entries(expected)) {
      await openTab(name);
      const text = container.textContent;
      for (const needle of needles) {
        expect(text, `"${needle}" missing from the ${name} tab`).toContain(needle);
        seen.add(needle);
      }
    }
    // Every label in the table above was actually checked somewhere.
    expect(seen.size).toBe(new Set(Object.values(expected).flat()).size);
  });
});
