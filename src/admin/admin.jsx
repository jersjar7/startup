import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import { LoadingState } from '../components/LoadingState';
import {
  SignOut, Users, CurrencyDollar, ChartLineUp, Lightning, Warning,
} from '@phosphor-icons/react';
import { buildMetrics, SUMMARY_IDS } from './metricDefs';
import { StatCard, GrowthPanel, EngagementPanel, RevenuePanel, UsersPanel } from './panels';
import './admin.css';

// "All" is a word, not a number, so the server works the window out from the
// first real account. A fixed ceiling would have silently started truncating
// all-time once the platform was a year old, with nothing on the page saying so.
const RANGES = [
  { days: 7, label: '7d' },
  { days: 30, label: '30d' },
  { days: 90, label: '90d' },
  { days: 'all', label: 'All' },
];

// Four groups, each answering one question the owner actually asks:
// how many people are arriving, whether they study, whether they pay, and who
// they are. The range toggle and the summary row sit above all four.
const TABS = [
  { id: 'growth', label: 'Growth', icon: ChartLineUp },
  { id: 'engagement', label: 'Engagement', icon: Lightning },
  { id: 'revenue', label: 'Revenue', icon: CurrencyDollar },
  { id: 'users', label: 'Users', icon: Users },
];

export function Admin({ userName, onLogout }) {
  const navigate = useNavigate();
  useDocumentTitle('Admin · Analytics');
  const [days, setDays] = React.useState(30);
  const [tab, setTab] = React.useState('growth');
  const [state, setState] = React.useState({ loading: true });
  const [lookup, setLookup] = React.useState({ q: '', result: null, err: '', loading: false });
  const [openInfo, setOpenInfo] = React.useState(null); // which number's definition is open

  // Tap anywhere else closes an open definition.
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

  // Time-series (reloads when the range changes, never when the tab changes).
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

  // Recent users + purchases (masked), acquisition, exam dates, email, pitch.
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
      setLookup((l) => ({ ...l, loading: false, err: 'Lookup failed, try again.' }));
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
  const ts = state.ts;
  const metrics = buildMetrics(ts?.snapshot);
  const hasSummary = SUMMARY_IDS.some((id) => metrics[id]);

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

      {/* ── Summary row: always visible, whichever tab is open ── */}
      <section className="admin-summary" aria-label="Headline numbers">
        <div className="admin-grid admin-grid--summary">
          {hasSummary
            ? SUMMARY_IDS.map((id) => (
              <StatCard key={id} metric={metrics[id]} openInfo={openInfo} setOpenInfo={setOpenInfo} />
            ))
            : SUMMARY_IDS.map((id) => <div key={id} className="kpi-card kpi-skeleton" />)}
        </div>
      </section>

      {/* ── Tabs ── */}
      <div className="admin-tabs" role="tablist" aria-label="Dashboard sections">
        {TABS.map((t) => {
          const Icon = t.icon;
          const active = tab === t.id;
          return (
            <button key={t.id} type="button" role="tab" id={`admin-tab-${t.id}`}
              aria-selected={active} aria-controls={`admin-panel-${t.id}`}
              className={`admin-tab ${active ? 'is-active' : ''}`}
              onClick={() => setTab(t.id)}>
              <Icon weight="bold" size={16} />
              {t.label}
            </button>
          );
        })}
      </div>

      <div className="admin-panel" role="tabpanel" id={`admin-panel-${tab}`} aria-labelledby={`admin-tab-${tab}`}>
        {tab === 'growth' && (
          <GrowthPanel ts={ts} metrics={metrics} acquisition={state.acquisition}
            openInfo={openInfo} setOpenInfo={setOpenInfo} />
        )}
        {tab === 'engagement' && (
          <EngagementPanel ts={ts} examDates={state.examDates} />
        )}
        {tab === 'revenue' && (
          <RevenuePanel ts={ts} m={m} metrics={metrics} pitchStats={state.pitchStats}
            recent={state.recent} openInfo={openInfo} setOpenInfo={setOpenInfo} />
        )}
        {tab === 'users' && (
          <UsersPanel recent={state.recent} lookup={lookup} setLookup={setLookup}
            onLookup={handleLookup} emailStatus={state.emailStatus} />
        )}
      </div>
    </main>
  );
}
