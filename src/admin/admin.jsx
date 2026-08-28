import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import { LoadingState } from '../components/LoadingState';
import {
  SignOut, Users, ClipboardText, CreditCard, CheckCircle, CurrencyDollar,
  ChartLineUp, Lightning, TrendUp, Exam, Receipt, Pulse, Compass, Timer,
  MagnifyingGlass, X, Info, EnvelopeSimple, CalendarBlank, Megaphone, CursorClick, Warning,
} from '@phosphor-icons/react';
import { Chart } from './Chart';
import { STUDENT_PRICE, STANDARD_PRICE } from '../data/pricing';
import './admin.css';

const RANGES = [
  { days: 7, label: '7d' },
  { days: 30, label: '30d' },
  { days: 90, label: '90d' },
];

const fmtInt = (v) => (v >= 1000 ? `${(v / 1000).toFixed(1)}k` : `${Math.round(v)}`);
const fmtMoney = (v) => `$${v >= 1000 ? `${(v / 1000).toFixed(1)}k` : Math.round(v * 100) / 100}`;
const money = (v) => `$${Number(v).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;

const SOURCE_LABEL = {
  reddit: 'Reddit', search: 'Google / search', youtube: 'YouTube',
  instagram: 'Instagram', tiktok: 'TikTok', friend: 'A friend', other: 'Other',
};

// Account-created date + time in Pacific Time, e.g. "6/9/26, 5:38 PM".
const fmtJoined = (iso) => {
  if (!iso) return '—';
  try {
    return new Intl.DateTimeFormat('en-US', {
      timeZone: 'America/Los_Angeles',
      month: 'numeric', day: 'numeric', year: '2-digit',
      hour: 'numeric', minute: '2-digit',
    }).format(new Date(iso));
  } catch { return '—'; }
};

export function Admin({ userName, onLogout }) {
  const navigate = useNavigate();
  useDocumentTitle('Admin · Analytics');
  const [days, setDays] = React.useState(30);
  const [state, setState] = React.useState({ loading: true });
  const [lookup, setLookup] = React.useState({ q: '', result: null, err: '', loading: false });
  const [openInfo, setOpenInfo] = React.useState(null); // which KPI's definition is open

  // Tap anywhere else closes an open KPI definition.
  React.useEffect(() => {
    if (!openInfo) return undefined;
    const close = () => setOpenInfo(null);
    document.addEventListener('click', close);
    return () => document.removeEventListener('click', close);
  }, [openInfo]);

  // Funnel + revenue snapshot (loaded once).
  React.useEffect(() => {
    if (!userName) { navigate('/'); return; }
    fetch('/api/admin/metrics')
      .then((res) => {
        if (res.status === 403) { setState({ loading: false, forbidden: true }); return null; }
        if (!res.ok) throw new Error();
        return res.json();
      })
      .then((metrics) => { if (metrics) setState((s) => ({ ...s, loading: false, metrics })); })
      .catch(() => setState({ loading: false, error: true }));
  }, [userName, navigate]);

  // Time-series (reloads when the range changes).
  React.useEffect(() => {
    if (!userName) return undefined;
    let cancelled = false;
    setState((s) => ({ ...s, tsLoading: true }));
    fetch(`/api/admin/timeseries?days=${days}`)
      .then((res) => (res.ok ? res.json() : null))
      .then((ts) => { if (!cancelled && ts) setState((s) => ({ ...s, ts, tsLoading: false })); })
      .catch(() => { if (!cancelled) setState((s) => ({ ...s, tsLoading: false })); });
    return () => { cancelled = true; };
  }, [userName, days]);

  // Recent users + purchases (masked), loaded once.
  React.useEffect(() => {
    if (!userName) return;
    fetch('/api/admin/recent')
      .then((res) => (res.ok ? res.json() : null))
      .then((recent) => { if (recent) setState((s) => ({ ...s, recent })); })
      .catch(() => {});
    fetch('/api/admin/acquisition')
      .then((res) => (res.ok ? res.json() : null))
      .then((acquisition) => { if (acquisition) setState((s) => ({ ...s, acquisition })); })
      .catch(() => {});
    fetch('/api/admin/exam-dates')
      .then((res) => (res.ok ? res.json() : null))
      .then((examDates) => { if (examDates) setState((s) => ({ ...s, examDates })); })
      .catch(() => {});
    fetch('/api/admin/email-status')
      .then((res) => (res.ok ? res.json() : null))
      .then((emailStatus) => { if (emailStatus) setState((s) => ({ ...s, emailStatus })); })
      .catch(() => {});
    fetch('/api/admin/pitch-stats')
      .then((res) => (res.ok ? res.json() : null))
      .then((pitchStats) => { if (pitchStats) setState((s) => ({ ...s, pitchStats })); })
      .catch(() => {});
  }, [userName]);

  async function handleLookup(e) {
    e.preventDefault();
    const q = lookup.q.trim();
    if (!q) return;
    setLookup((l) => ({ ...l, loading: true, err: '', result: null }));
    try {
      const res = await fetch(`/api/admin/user-lookup?email=${encodeURIComponent(q)}`);
      if (res.status === 404) { setLookup((l) => ({ ...l, loading: false, err: 'No user with that email.' })); return; }
      if (!res.ok) throw new Error();
      const result = await res.json();
      setLookup((l) => ({ ...l, loading: false, result }));
    } catch {
      setLookup((l) => ({ ...l, loading: false, err: 'Lookup failed — try again.' }));
    }
  }

  const handleLogout = () => { onLogout(); navigate('/'); };

  if (state.loading) return <LoadingState />;

  if (state.forbidden) {
    return (
      <main className="admin-msg">
        <h2>Owner only</h2>
        <p>This analytics page is restricted to the account owner.</p>
        <button className="btn-secondary" onClick={() => navigate('/dashboard')}>Back to Dashboard</button>
      </main>
    );
  }
  if (state.error || !state.metrics) {
    return (
      <main className="admin-msg">
        <h2>Couldn't load analytics</h2>
        <button className="btn-secondary" onClick={() => window.location.reload()}>Retry</button>
      </main>
    );
  }

  const m = state.metrics;
  const c = m.conversion;
  const ts = state.ts;
  const snap = ts?.snapshot;

  const kpis = snap ? [
    { icon: Users, label: 'Total users', value: snap.totalUsers.toLocaleString(), accent: 'ember',
      desc: `The all-time number of real accounts ever created — everyone who signed up, minus your own test accounts (admin & QA). It only goes up.`,
      example: `If 58 people have made an account, this shows 58 — and the newest one is #58 in the Recent users table below.` },
    { icon: Compass, label: 'Activation rate', value: snap.activationRate != null ? `${snap.activationRate}%` : '—', accent: 'ember',
      desc: `Of the people who signed up since the quick-start launched, the share who actually started it (answered at least one quick-start question). Your honest "are new users engaging, not just registering?" number.`,
      example: `20 people signed up since launch and 5 of them answered a quick-start question → 5 ÷ 20 = 25%.` },
    { icon: Users, label: 'Activated · since launch', value: snap.cohortSignups != null ? `${snap.cohortActivated}/${snap.cohortSignups}` : '—', accent: 'forest',
      desc: `The two raw numbers behind the activation rate: people who started the quick-start ÷ everyone who signed up since launch.`,
      example: `Shown as 5/20 — 5 of the 20 post-launch signups have started. That fraction is the 25% above.` },
    { icon: Timer, label: 'Median time to start', value: snap.activationMedianMinutes != null ? `${snap.activationMedianMinutes} min` : '—', accent: 'info',
      desc: `Among users who activated, the typical wait between signing up and answering their first question. It's the median (the middle person), so one slow returner can't skew the number.`,
      example: `If activators waited 2, 6, and 40 minutes, the median is 6 min — half started faster, half slower. Lower is better.` },
    { icon: Lightning, label: 'Active · 7 days', value: snap.activeUsers7d.toLocaleString(), accent: 'info',
      desc: `How many different people finished at least one study session in the last 7 days. The same person studying five times counts once — it's your weekly engaged-user count.`,
      example: `If 12 distinct people studied at least once this week, this shows 12.` },
    { icon: CurrencyDollar, label: 'Total revenue', value: money(snap.totalRevenue), accent: 'forest',
      desc: `Money actually collected for the exam simulation, all time (after Stripe). Complimentary grants and purchases we were never paid for are excluded.`,
      example: `Two $${STUDENT_PRICE} student purchases + one $${STANDARD_PRICE} standard = $${STUDENT_PRICE * 2 + STANDARD_PRICE}.` },
    { icon: CreditCard, label: 'Purchases', value: snap.totalPurchases.toLocaleString(), accent: 'forest',
      desc: `The all-time count of exam-sim purchases we were actually paid for, regardless of the price paid. Complimentary grants and unpaid grants are excluded.`,
      example: `If 3 people have bought the timed exam sim, this shows 3.` },
    { icon: TrendUp, label: 'Rev / paying user', value: money(snap.arppu), accent: 'sunbeam',
      desc: `Average money per paying customer — total revenue ÷ number of purchases. (The industry name for this is ARPPU.)`,
      example: `$107 in revenue from 3 purchases = about $36 per paying user.` },
  ] : [];

  const funnelStages = [
    { icon: Users, label: 'Signups', value: m.signups, conv: null, convLabel: null,
      desc: `The top of the funnel: total real accounts ever created (excludes your test accounts).`,
      example: `If 58 people have signed up all-time, this shows 58.` },
    { icon: Compass, label: 'Activated (quick-start)', value: m.quickstartActivated, conv: c.signupToActivation, convLabel: 'of signups',
      desc: `Distinct people who completed at least one quick-start segment, all-time. (This whole funnel is all-time; the "Activation rate" KPI above is the cleaner post-launch-cohort version.)`,
      example: `If 9 of the 58 signups answered a quick-start question, this shows 9 — about 16% of signups.` },
    { icon: CreditCard, label: 'Started checkout', value: m.checkoutStarts, conv: c.signupToCheckout, convLabel: 'of signups',
      desc: `Distinct people who opened the Stripe payment page for the exam sim — whether or not they finished paying. The "% of signups" is this ÷ signups.`,
      example: `If 4 people clicked through to checkout, this shows 4, even if only some of them paid.` },
    { icon: CheckCircle, label: 'Purchased', value: m.purchases, conv: c.checkoutToPurchase, convLabel: 'of checkouts',
      desc: `Exam-sim purchases we were actually paid for, all-time. Complimentary and unpaid grants are excluded. The "% of checkouts" is this ÷ checkouts started.`,
      example: `If 2 of the 4 who started checkout paid, this shows 2 — a 50% checkout→purchase rate.` },
  ];

  return (
    <main className="admin">
      <div className="admin-header">
        <div>
          <h2 className="admin-title">Analytics</h2>
          <span className="admin-greeting">
            Growth, engagement &amp; revenue{ts ? ` · days in ${ts.tz.split('/').pop().replace('_', ' ')} time` : ''}
          </span>
        </div>
        <div className="admin-header-right">
          <div className="admin-range" role="tablist" aria-label="Time range">
            {RANGES.map((r) => (
              <button key={r.days} role="tab" aria-selected={days === r.days}
                className={`admin-range-btn ${days === r.days ? 'is-active' : ''}`}
                onClick={() => setDays(r.days)}>{r.label}</button>
            ))}
          </div>
          <button className="logout-btn" onClick={handleLogout}>
            <SignOut weight="bold" size={18} /> Logout
          </button>
        </div>
      </div>

      {/* ── Email health alert: fires if delivery falls back to the test sender ── */}
      {state.emailStatus?.usingTestSender && (
        <div className="admin-email-alert" role="alert">
          <Warning weight="fill" size={24} />
          <div>
            <strong>Email delivery is DOWN.</strong> The server is using the{' '}
            <code>{state.emailStatus.from}</code> test sender, so real users are <u>not</u> receiving
            any email (verification, password resets, lifecycle). Set a valid <code>RESEND_API_KEY</code>{' '}
            and <code>RESEND_FROM_EMAIL=noreply@fe4raccoons.com</code> in the server <code>.env</code>, then reload.
          </div>
        </div>
      )}

      {/* ── KPI cards ── */}
      <div className="kpi-grid">
        {kpis.length === 0
          ? Array.from({ length: 6 }).map((_, i) => <div key={i} className="kpi-card kpi-skeleton" />)
          : kpis.map((k) => {
            const Icon = k.icon;
            const open = openInfo === k.label;
            return (
              <div key={k.label} className={`kpi-card kpi--${k.accent}`}>
                <button
                  type="button"
                  className={`kpi-info-btn ${open ? 'is-open' : ''}`}
                  aria-label={`What does "${k.label}" mean?`}
                  aria-expanded={open}
                  onClick={(e) => { e.stopPropagation(); setOpenInfo(open ? null : k.label); }}
                >
                  <Info weight={open ? 'fill' : 'bold'} size={15} />
                </button>
                <Icon weight="bold" size={18} className="kpi-icon" />
                <span className="kpi-value">{k.value}</span>
                <span className="kpi-label">{k.label}</span>
                {open && (
                  <div className="kpi-tip" role="tooltip" onClick={(e) => e.stopPropagation()}>
                    {k.desc}
                    {k.example && <span className="tip-eg"><strong>Example:</strong> {k.example}</span>}
                  </div>
                )}
              </div>
            );
          })}
      </div>

      {/* ── Primary charts ── */}
      <div className="chart-grid">
        <ChartCard icon={Users} title="New signups" sub="per day" series={ts?.series.signups} axis={ts?.axis}
          type="bar" color="ember" fmt={fmtInt} />
        <ChartCard icon={TrendUp} title="Total users" sub="cumulative" series={ts?.series.cumulativeUsers} axis={ts?.axis}
          type="area" color="forest" fmt={fmtInt} />
        <ChartCard icon={Lightning} title="Active users" sub="per day" series={ts?.series.activeUsers} axis={ts?.axis}
          type="area" color="info" fmt={fmtInt} />
        <ChartCard icon={ClipboardText} title="Problems answered" sub="per day" series={ts?.series.problems} axis={ts?.axis}
          type="bar" color="sunbeam" fmt={fmtInt} />
        <ChartCard icon={CurrencyDollar} title="Revenue" sub="per day" series={ts?.series.revenue} axis={ts?.axis}
          type="bar" color="forest" fmt={fmtMoney} />
        <ChartCard icon={CurrencyDollar} title="Total revenue" sub="cumulative" series={ts?.series.cumulativeRevenue} axis={ts?.axis}
          type="area" color="forest" fmt={fmtMoney} />
      </div>

      {/* ── Engagement strip ── */}
      <div className="chart-grid chart-grid--thirds">
        <ChartCard icon={Compass} title="Quick-start started" sub="per day" series={ts?.series.quickstartActivations} axis={ts?.axis}
          type="bar" color="ember" fmt={fmtInt} compact />
        <ChartCard icon={Exam} title="Exam sims completed" sub="per day" series={ts?.series.examSims} axis={ts?.axis}
          type="bar" color="info" fmt={fmtInt} compact />
        <ChartCard icon={Receipt} title="Checkout starts" sub="per day" series={ts?.series.checkoutStarts} axis={ts?.axis}
          type="bar" color="sunbeam" fmt={fmtInt} compact />
      </div>

      {/* ── Conversion funnel ── */}
      <div className="admin-section-head">
        <ChartLineUp weight="bold" size={18} />
        <h3>Conversion funnel</h3>
        <span className="admin-section-note">all-time · {c.signupToPurchase}% signup → purchase</span>
      </div>
      <div className="admin-funnel">
        {funnelStages.map((s) => {
          const Icon = s.icon;
          const key = `fn:${s.label}`;
          const open = openInfo === key;
          return (
            <div key={s.label} className="funnel-stage">
              <Icon weight="bold" size={20} className="funnel-icon" />
              <span className="funnel-label">
                {s.label}
                <button
                  type="button"
                  className={`funnel-info-btn ${open ? 'is-open' : ''}`}
                  aria-label={`What does "${s.label}" mean?`}
                  aria-expanded={open}
                  onClick={(e) => { e.stopPropagation(); setOpenInfo(open ? null : key); }}
                >
                  <Info weight={open ? 'fill' : 'bold'} size={14} />
                </button>
                {open && (
                  <div className="funnel-tip" role="tooltip" onClick={(e) => e.stopPropagation()}>
                    {s.desc}
                    {s.example && <span className="tip-eg"><strong>Example:</strong> {s.example}</span>}
                  </div>
                )}
              </span>
              <span className="funnel-value">{s.value}</span>
              {s.conv !== null && <span className="funnel-conv">{s.conv}% {s.convLabel}</span>}
            </div>
          );
        })}
      </div>

      {/* ── How users found us ── */}
      {state.acquisition && (
        <>
          <div className="admin-section-head">
            <Compass weight="bold" size={18} />
            <h3>How users found us</h3>
            <span className="admin-section-note">{state.acquisition.answered} of {state.acquisition.totalUsers} answered</span>
          </div>
          <div className="acq-grid">
            <div className="acq-block">
              <span className="acq-block-label">They told us</span>
              {state.acquisition.selfReported.length === 0 ? (
                <p className="acq-empty">No answers yet — new users get a one-tap question on their dashboard.</p>
              ) : state.acquisition.selfReported.map((sr) => {
                const maxC = Math.max(...state.acquisition.selfReported.map((x) => x.count), 1);
                return (
                  <div key={sr.source} className="acq-row">
                    <span className="acq-name">{SOURCE_LABEL[sr.source] || sr.source}</span>
                    <span className="acq-bar-track"><span className="acq-bar-fill" style={{ width: `${(sr.count / maxC) * 100}%` }} /></span>
                    <span className="acq-count">{sr.count}</span>
                  </div>
                );
              })}
            </div>
            <div className="acq-block">
              <span className="acq-block-label">Referrer (captured automatically)</span>
              {state.acquisition.referrers.length === 0 ? (
                <p className="acq-empty">No referrer data yet.</p>
              ) : state.acquisition.referrers.map((r) => {
                const maxR = Math.max(...state.acquisition.referrers.map((x) => x.count), 1);
                return (
                  <div key={r.host} className="acq-row">
                    <span className="acq-name">{r.host}</span>
                    <span className="acq-bar-track"><span className="acq-bar-fill acq-bar-fill--alt" style={{ width: `${(r.count / maxR) * 100}%` }} /></span>
                    <span className="acq-count">{r.count}</span>
                  </div>
                );
              })}
            </div>
          </div>
        </>
      )}

      {/* ── Upcoming exam dates (from user profiles) ── */}
      {state.examDates && state.examDates.dates.length > 0 && (
        <>
          <div className="admin-section-head">
            <CalendarBlank weight="bold" size={18} />
            <h3>Upcoming exam dates</h3>
            <span className="admin-section-note">{state.examDates.total} user{state.examDates.total === 1 ? '' : 's'} with a date set</span>
          </div>
          <ExamCalendar dates={state.examDates.dates} />
        </>
      )}

      {/* ── Email budget (Resend free plan) ── */}
      {state.emailStatus?.budget && (
        <>
          <div className="admin-section-head">
            <EnvelopeSimple weight="bold" size={18} />
            <h3>Email budget</h3>
            <span className="admin-section-note">Resend free plan · resets at UTC midnight</span>
          </div>
          <div className="budget-grid">
            <BudgetBar label="Today" sent={state.emailStatus.budget.day} cap={state.emailStatus.budget.dailyCap}
              soft={state.emailStatus.budget.dailyLifecycleMax} softLabel="lifecycle stops here" />
            <BudgetBar label="This month" sent={state.emailStatus.budget.month} cap={state.emailStatus.budget.monthlyCap}
              soft={state.emailStatus.budget.monthlySoft} softLabel="soft cap" />
          </div>
        </>
      )}

      {/* ── Exam-sim pitch funnel (countdown-email sim pitch) ── */}
      {state.pitchStats && (
        <>
          <div className="admin-section-head">
            <Megaphone weight="bold" size={18} />
            <h3>Exam-sim pitch</h3>
            <span className="admin-section-note">From the countdown emails · non-buyers ~2-4 weeks out</span>
          </div>
          <PitchFunnel s={state.pitchStats} />
        </>
      )}

      {/* ── Recent users (masked) + single-user lookup ── */}
      <div className="admin-section-head">
        <Users weight="bold" size={18} />
        <h3>Recent users</h3>
        <span className="admin-section-note">emails masked · look one up for support</span>
      </div>

      <form className="user-lookup" onSubmit={handleLookup}>
        <MagnifyingGlass weight="bold" size={16} className="user-lookup-icon" />
        <input
          type="email"
          className="user-lookup-input"
          placeholder="Look up a user by full email…"
          value={lookup.q}
          onChange={(e) => setLookup((l) => ({ ...l, q: e.target.value }))}
        />
        <button type="submit" className="user-lookup-btn" disabled={lookup.loading || !lookup.q.trim()}>
          {lookup.loading ? 'Searching…' : 'Look up'}
        </button>
      </form>
      {lookup.err && <p className="user-lookup-err">{lookup.err}</p>}
      {lookup.result && <UserCard u={lookup.result} onClose={() => setLookup((l) => ({ ...l, result: null }))} />}

      <div className="recent-table">
        <div className="recent-row recent-row--head">
          <span>#</span><span>Email</span><span>Joined (PT)</span><span>Verified</span><span>Activated</span><span>Chapters</span><span>XP</span><span>Paid</span>
        </div>
        {(state.recent?.users || []).map((u, i) => (
          <div key={i} className="recent-row">
            <span className="recent-num">{(state.recent.total || (state.recent.users || []).length) - i}</span>
            <span className="recent-email">{u.emailMasked}</span>
            <span>{fmtJoined(u.createdAt)}</span>
            <span>{u.emailVerified ? <CheckCircle weight="fill" size={15} className="recent-ok" /> : <span className="recent-muted">—</span>}</span>
            <span>{u.activated ? <CheckCircle weight="fill" size={15} className="recent-ok" /> : <span className="recent-muted">—</span>}</span>
            <span>{u.chaptersMapped}/15</span>
            <span>{u.totalXp}</span>
            <span>{u.purchased ? <CheckCircle weight="fill" size={15} className="recent-paid" /> : <span className="recent-muted">—</span>}</span>
          </div>
        ))}
        {state.recent && (state.recent.users || []).length === 0 && <div className="recent-empty">No users yet.</div>}
      </div>

      {state.recent && (state.recent.purchases || []).length > 0 && (
        <div className="recent-purchases">
          <span className="recent-purchases-label">Recent purchases</span>
          {state.recent.purchases.map((p, i) => (
            <div key={i} className="recent-purchase-row">
              <span className="recent-email">{p.emailMasked}</span>
              <span>${(p.amount / 100).toFixed(2)}</span>
              <span className="recent-muted">{p.tier || '—'}</span>
              <span className="recent-muted">{p.createdAt ? new Date(p.createdAt).toLocaleDateString() : '—'}</span>
            </div>
          ))}
        </div>
      )}
    </main>
  );
}

function UserCard({ u, onClose }) {
  const fields = [
    ['Name', [u.firstName, u.lastName].filter(Boolean).join(' ') || '—'],
    ['Joined', u.createdAt ? new Date(u.createdAt).toLocaleDateString() : '—'],
    ['Verified', u.emailVerified ? 'Yes' : 'No'],
    ['Exam date', u.examDate || '—'],
    ['XP', u.totalXp],
    ['Days studied', `${u.currentStreak}`],
    ['Chapters mapped', `${u.chaptersMapped}/15`],
    ['Activated', u.activatedAt ? new Date(u.activatedAt).toLocaleDateString() : 'No'],
    ['Exam sim', u.examSimAccess ? 'Purchased' : '—'],
  ];
  return (
    <div className="user-card">
      <button className="user-card-x" onClick={onClose} aria-label="Close"><X weight="bold" size={14} /></button>
      <div className="user-card-head">
        <span className="user-card-email">{u.email}</span>
        <span className="user-card-pii">full email · don't screenshot</span>
      </div>
      <div className="user-card-grid">
        {fields.map(([k, v]) => (
          <div key={k} className="uc-cell"><span className="uc-k">{k}</span><span className="uc-v">{v}</span></div>
        ))}
      </div>
      {u.purchases && u.purchases.length > 0 && (
        <div className="user-card-purchases">
          {u.purchases.map((p, i) => (
            <div key={i}>${(p.amount / 100).toFixed(2)} · {p.tier || '—'} · {p.status}{p.createdAt ? ` · ${new Date(p.createdAt).toLocaleDateString()}` : ''}{p.comp ? ' · complimentary (not a sale)' : ''}{p.uncollected ? ' · not collected (excluded from revenue)' : ''}</div>
          ))}
        </div>
      )}
    </div>
  );
}

const MONTH_NAMES = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
const DOW = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

// Month grids for upcoming months that have exam dates; a day with N users
// testing shows an ember badge with the count.
function ExamCalendar({ dates }) {
  const byDate = React.useMemo(() => Object.fromEntries(dates.map((d) => [d.date, d.count])), [dates]);
  const today = new Date();
  const todayStr = new Intl.DateTimeFormat('en-CA', { year: 'numeric', month: '2-digit', day: '2-digit' }).format(today);
  const months = [...new Set(dates.filter((d) => d.date >= todayStr).map((d) => d.date.slice(0, 7)))].sort();
  if (months.length === 0) return <p className="cal-empty">No upcoming exam dates.</p>;

  return (
    <div className="cal-grid">
      {months.slice(0, 6).map((ym) => {
        const [y, mo] = ym.split('-').map(Number);
        const startDow = new Date(y, mo - 1, 1).getDay();
        const daysIn = new Date(y, mo, 0).getDate();
        const cells = [...Array(startDow).fill(null), ...Array.from({ length: daysIn }, (_, i) => i + 1)];
        const monthTotal = dates.filter((d) => d.date.slice(0, 7) === ym).reduce((a, b) => a + b.count, 0);
        return (
          <div key={ym} className="cal-month">
            <div className="cal-month-head">
              <span className="cal-month-name">{MONTH_NAMES[mo - 1]} {y}</span>
              <span className="cal-month-total">{monthTotal}</span>
            </div>
            <div className="cal-dow">{DOW.map((x, i) => <span key={i}>{x}</span>)}</div>
            <div className="cal-days">
              {cells.map((d, i) => {
                if (d === null) return <span key={i} className="cal-cell cal-cell--empty" />;
                const ds = `${ym}-${String(d).padStart(2, '0')}`;
                const count = byDate[ds] || 0;
                return (
                  <span key={i}
                    className={`cal-cell ${count ? 'cal-cell--has' : ''} ${ds === todayStr ? 'cal-cell--today' : ''}`}
                    title={count ? `${count} testing on ${ds}` : ds}>
                    <span className="cal-day">{d}</span>
                    {count > 0 && <span className="cal-count">{count}</span>}
                  </span>
                );
              })}
            </div>
          </div>
        );
      })}
    </div>
  );
}

// Send count vs a cap, with a marker at the "soft" line where lifecycle stops.
function BudgetBar({ label, sent, cap, soft, softLabel }) {
  const pct = Math.min(100, (sent / cap) * 100);
  const softPct = Math.min(100, (soft / cap) * 100);
  const level = sent >= cap ? 'over' : sent >= soft ? 'warn' : 'ok';
  return (
    <div className="budget-card">
      <div className="budget-top">
        <span className="budget-label">{label}</span>
        <span className="budget-nums"><strong>{sent}</strong> / {cap}</span>
      </div>
      <div className="budget-track">
        <span className={`budget-fill budget-fill--${level}`} style={{ width: `${pct}%` }} />
        <span className="budget-soft" style={{ left: `${softPct}%` }} title={`${soft} — ${softLabel}`} />
      </div>
      <span className="budget-note">{softLabel} at {soft}</span>
    </div>
  );
}

function PitchFunnel({ s }) {
  const pct = (n, d) => (d > 0 ? Math.round((n / d) * 100) : 0);
  const steps = [
    { icon: Megaphone, label: 'Pitched', value: s.pitched, of: null, color: 'ember' },
    { icon: CursorClick, label: 'Link opens', value: s.clicked, of: null, color: 'sunbeam' },
    { icon: CheckCircle, label: 'Bought after pitch', value: s.converted, of: s.pitched, color: 'forest' },
  ];
  return (
    <div className="pitch-funnel">
      {steps.map((st) => (
        <div key={st.label} className={`pitch-step pitch-step--${st.color}`}>
          <st.icon weight="bold" size={18} className="pitch-step-icon" />
          <span className="pitch-step-value">{st.value}</span>
          <span className="pitch-step-label">{st.label}</span>
          {st.of != null && <span className="pitch-step-rate">{pct(st.value, st.of)}% of pitched</span>}
        </div>
      ))}
      <p className="pitch-funnel-note">
        Story-video link: {s.storyClicks} · Exam-sim link: {s.examClicks}
        {s.followups != null && <> · 48h follow-ups sent: {s.followups}</>}. Clicks may include
        email-scanner prefetches, so read them as a trend, not an exact count.
      </p>
    </div>
  );
}

function ChartCard({ icon: Icon, title, sub, series, axis, type, color, fmt, compact }) {
  return (
    <div className={`chart-card ${compact ? 'chart-card--compact' : ''}`}>
      <div className="chart-card-head">
        <Icon weight="bold" size={16} className={`chart-card-icon chart-card-icon--${color}`} />
        <span className="chart-card-title">{title}</span>
        <span className="chart-card-sub">{sub}</span>
      </div>
      {series && axis
        ? <Chart axis={axis} data={series} type={type} color={color} label={`${title} ${sub}`} fmt={fmt} />
        : <div className="chart-loading"><Pulse weight="bold" size={18} /></div>}
    </div>
  );
}
