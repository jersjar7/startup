import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import { LoadingState } from '../components/LoadingState';
import {
  SignOut, Users, ClipboardText, CreditCard, CheckCircle, CurrencyDollar,
  ChartLineUp, Lightning, TrendUp, Exam, Receipt, Pulse,
} from '@phosphor-icons/react';
import { Chart } from './Chart';
import './admin.css';

const RANGES = [
  { days: 7, label: '7d' },
  { days: 30, label: '30d' },
  { days: 90, label: '90d' },
];

const fmtInt = (v) => (v >= 1000 ? `${(v / 1000).toFixed(1)}k` : `${Math.round(v)}`);
const fmtMoney = (v) => `$${v >= 1000 ? `${(v / 1000).toFixed(1)}k` : Math.round(v * 100) / 100}`;
const money = (v) => `$${Number(v).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;

export function Admin({ userName, onLogout }) {
  const navigate = useNavigate();
  useDocumentTitle('Admin · Analytics');
  const [days, setDays] = React.useState(30);
  const [state, setState] = React.useState({ loading: true });

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
    { icon: Users, label: 'Total users', value: snap.totalUsers.toLocaleString(), accent: 'ember' },
    { icon: Lightning, label: 'Active · 7 days', value: snap.activeUsers7d.toLocaleString(), accent: 'info' },
    { icon: Lightning, label: 'Active · 30 days', value: snap.activeUsers30d.toLocaleString(), accent: 'info' },
    { icon: CurrencyDollar, label: 'Total revenue', value: money(snap.totalRevenue), accent: 'forest' },
    { icon: CreditCard, label: 'Purchases', value: snap.totalPurchases.toLocaleString(), accent: 'forest' },
    { icon: TrendUp, label: 'Rev / paying user', value: money(snap.arppu), accent: 'sunbeam' },
  ] : [];

  const funnelStages = [
    { icon: Users, label: 'Signups', value: m.signups, conv: null, convLabel: null },
    { icon: ClipboardText, label: 'Took diagnostic', value: m.diagnosticUsers, conv: c.signupToDiagnostic, convLabel: 'of signups' },
    { icon: CreditCard, label: 'Started checkout', value: m.checkoutStarts, conv: c.signupToCheckout, convLabel: 'of signups' },
    { icon: CheckCircle, label: 'Purchased', value: m.purchases, conv: c.checkoutToPurchase, convLabel: 'of checkouts' },
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

      {/* ── KPI cards ── */}
      <div className="kpi-grid">
        {kpis.length === 0
          ? Array.from({ length: 6 }).map((_, i) => <div key={i} className="kpi-card kpi-skeleton" />)
          : kpis.map((k) => {
            const Icon = k.icon;
            return (
              <div key={k.label} className={`kpi-card kpi--${k.accent}`}>
                <Icon weight="bold" size={18} className="kpi-icon" />
                <span className="kpi-value">{k.value}</span>
                <span className="kpi-label">{k.label}</span>
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
        <ChartCard icon={Exam} title="Diagnostics" sub="per day" series={ts?.series.diagnostics} axis={ts?.axis}
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
          return (
            <div key={s.label} className="funnel-stage">
              <Icon weight="bold" size={20} className="funnel-icon" />
              <span className="funnel-label">{s.label}</span>
              <span className="funnel-value">{s.value}</span>
              {s.conv !== null && <span className="funnel-conv">{s.conv}% {s.convLabel}</span>}
            </div>
          );
        })}
      </div>
    </main>
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
