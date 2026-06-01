import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import { LoadingState } from '../components/LoadingState';
import {
  SignOut, Users, ClipboardText, CreditCard, CheckCircle, CurrencyDollar, ChartLineUp,
} from '@phosphor-icons/react';
import './admin.css';

export function Admin({ userName, onLogout }) {
  const navigate = useNavigate();
  useDocumentTitle('Admin · Metrics');
  const [state, setState] = React.useState({ loading: true });

  React.useEffect(() => {
    if (!userName) { navigate('/'); return; }
    fetch('/api/admin/metrics')
      .then((res) => {
        if (res.status === 403) { setState({ loading: false, forbidden: true }); return null; }
        if (!res.ok) throw new Error();
        return res.json();
      })
      .then((m) => { if (m) setState({ loading: false, metrics: m }); })
      .catch(() => setState({ loading: false, error: true }));
  }, [userName, navigate]);

  const handleLogout = () => { onLogout(); navigate('/'); };

  if (state.loading) return <LoadingState />;

  if (state.forbidden) {
    return (
      <main className="admin-msg">
        <h2>Owner only</h2>
        <p>This metrics page is restricted to the account owner.</p>
        <button className="btn-secondary" onClick={() => navigate('/dashboard')}>Back to Dashboard</button>
      </main>
    );
  }
  if (state.error || !state.metrics) {
    return (
      <main className="admin-msg">
        <h2>Couldn't load metrics</h2>
        <button className="btn-secondary" onClick={() => window.location.reload()}>Retry</button>
      </main>
    );
  }

  const m = state.metrics;
  const c = m.conversion;
  const stages = [
    { icon: Users, label: 'Signups', value: m.signups, conv: null, convLabel: null },
    { icon: ClipboardText, label: 'Took diagnostic', value: m.diagnosticUsers, conv: c.signupToDiagnostic, convLabel: 'of signups' },
    { icon: CreditCard, label: 'Started checkout', value: m.checkoutStarts, conv: c.signupToCheckout, convLabel: 'of signups' },
    { icon: CheckCircle, label: 'Purchased', value: m.purchases, conv: c.checkoutToPurchase, convLabel: 'of checkouts' },
  ];

  return (
    <main className="admin">
      <div className="admin-header">
        <div>
          <h2 className="admin-title">Metrics</h2>
          <span className="admin-greeting">Conversion funnel &amp; revenue</span>
        </div>
        <button className="logout-btn" onClick={handleLogout}>
          <SignOut weight="bold" size={18} /> Logout
        </button>
      </div>

      <div className="admin-top">
        <div className="admin-headline admin-headline--revenue">
          <CurrencyDollar weight="bold" size={20} />
          <div>
            <span className="admin-headline-value">{m.revenue.toFixed(2)} dollars</span>
            <span className="admin-headline-label">Total revenue</span>
          </div>
        </div>
        <div className="admin-headline">
          <ChartLineUp weight="bold" size={20} />
          <div>
            <span className="admin-headline-value">{c.signupToPurchase}%</span>
            <span className="admin-headline-label">Signup → purchase</span>
          </div>
        </div>
      </div>

      <div className="admin-funnel">
        {stages.map((s) => {
          const Icon = s.icon;
          return (
            <div key={s.label} className="funnel-stage">
              <Icon weight="bold" size={20} className="funnel-icon" />
              <span className="funnel-label">{s.label}</span>
              <span className="funnel-value">{s.value}</span>
              {s.conv !== null && (
                <span className="funnel-conv">{s.conv}% {s.convLabel}</span>
              )}
            </div>
          );
        })}
      </div>
    </main>
  );
}
