import React from 'react';
import {
  Users, ClipboardText, CreditCard, CheckCircle, CurrencyDollar,
  ChartLineUp, Lightning, TrendUp, Exam, Receipt, Pulse, Compass,
  MagnifyingGlass, X, Info, EnvelopeSimple, CalendarBlank, Megaphone, CursorClick,
} from '@phosphor-icons/react';
import { Chart } from './Chart';
import { fmtInt, fmtMoney, fmtJoined, SOURCE_LABEL } from './format';

/* ──────────────────────────────────────────────────────────────────────────
   Shared pieces
   ────────────────────────────────────────────────────────────────────────── */

// One headline number with its info button and definition bubble.
export function StatCard({ metric, openInfo, setOpenInfo }) {
  if (!metric) return null;
  const Icon = metric.icon;
  const open = openInfo === metric.id;
  return (
    <div className={`kpi-card kpi--${metric.accent}`}>
      <button
        type="button"
        className={`kpi-info-btn ${open ? 'is-open' : ''}`}
        aria-label={`What does "${metric.label}" mean?`}
        aria-expanded={open}
        onClick={(e) => { e.stopPropagation(); setOpenInfo(open ? null : metric.id); }}
      >
        <Info weight={open ? 'fill' : 'bold'} size={15} />
      </button>
      <Icon weight="bold" size={18} className="kpi-icon" />
      <span className="kpi-value">{metric.value}</span>
      <span className="kpi-label">{metric.label}</span>
      {open && (
        <div className="kpi-tip" role="tooltip" onClick={(e) => e.stopPropagation()}>
          {metric.desc}
          {metric.example && <span className="tip-eg"><strong>Example:</strong> {metric.example}</span>}
        </div>
      )}
    </div>
  );
}

export function ChartCard({ icon: Icon, title, sub, series, axis, type, color, fmt, compact }) {
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

function SectionHead({ icon: Icon, title, note }) {
  return (
    <div className="admin-section-head">
      <Icon weight="bold" size={18} />
      <h3>{title}</h3>
      {note && <span className="admin-section-note">{note}</span>}
    </div>
  );
}

/* ──────────────────────────────────────────────────────────────────────────
   Growth
   ────────────────────────────────────────────────────────────────────────── */

export function GrowthPanel({ ts, metrics, acquisition, openInfo, setOpenInfo }) {
  return (
    <>
      <div className="admin-grid admin-grid--charts">
        <ChartCard icon={Users} title="New signups" sub="per day" series={ts?.series.signups} axis={ts?.axis}
          type="bar" color="ember" fmt={fmtInt} />
        <ChartCard icon={TrendUp} title="Total users" sub="cumulative" series={ts?.series.cumulativeUsers} axis={ts?.axis}
          type="area" color="forest" fmt={fmtInt} />
        <ChartCard icon={Compass} title="Quick-start started" sub="per day" series={ts?.series.quickstartActivations} axis={ts?.axis}
          type="bar" color="ember" fmt={fmtInt} compact />
      </div>

      <SectionHead icon={Compass} title="Activation" note="new users who actually start the quick-start" />
      <div className="admin-grid admin-grid--stats">
        <StatCard metric={metrics.cohortActivated} openInfo={openInfo} setOpenInfo={setOpenInfo} />
        <StatCard metric={metrics.medianStart} openInfo={openInfo} setOpenInfo={setOpenInfo} />
      </div>

      {acquisition && (
        <>
          <SectionHead icon={Compass} title="How users found us"
            note={`${acquisition.answered} of ${acquisition.totalUsers} answered`} />
          <div className="admin-grid admin-grid--halves">
            <div className="acq-block">
              <span className="acq-block-label">They told us</span>
              {acquisition.selfReported.length === 0 ? (
                <p className="acq-empty">No answers yet, new users get a one-tap question on their dashboard.</p>
              ) : acquisition.selfReported.map((sr) => {
                const maxC = Math.max(...acquisition.selfReported.map((x) => x.count), 1);
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
              {acquisition.referrers.length === 0 ? (
                <p className="acq-empty">No referrer data yet.</p>
              ) : acquisition.referrers.map((r) => {
                const maxR = Math.max(...acquisition.referrers.map((x) => x.count), 1);
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
    </>
  );
}

/* ──────────────────────────────────────────────────────────────────────────
   Engagement
   ────────────────────────────────────────────────────────────────────────── */

export function EngagementPanel({ ts, examDates }) {
  return (
    <>
      <div className="admin-grid admin-grid--charts">
        <ChartCard icon={Lightning} title="Active users" sub="per day" series={ts?.series.activeUsers} axis={ts?.axis}
          type="area" color="info" fmt={fmtInt} />
        <ChartCard icon={ClipboardText} title="Problems answered" sub="per day" series={ts?.series.problems} axis={ts?.axis}
          type="bar" color="sunbeam" fmt={fmtInt} />
        <ChartCard icon={Exam} title="Exam sims completed" sub="per day" series={ts?.series.examSims} axis={ts?.axis}
          type="bar" color="info" fmt={fmtInt} compact />
      </div>

      {examDates && examDates.dates.length > 0 && (
        <>
          <SectionHead icon={CalendarBlank} title="Upcoming exam dates"
            note={`${examDates.total} user${examDates.total === 1 ? '' : 's'} with a date set`} />
          <ExamCalendar dates={examDates.dates} />
        </>
      )}
    </>
  );
}

/* ──────────────────────────────────────────────────────────────────────────
   Revenue
   ────────────────────────────────────────────────────────────────────────── */

export function RevenuePanel({ ts, m, metrics, pitchStats, recent, openInfo, setOpenInfo }) {
  const c = m.conversion;
  const funnelStages = [
    { icon: Users, label: 'Signups', value: m.signups, conv: null, convLabel: null,
      desc: 'The top of the funnel: total real accounts ever created (excludes your test accounts).',
      example: 'If 58 people have signed up all-time, this shows 58.' },
    { icon: Compass, label: 'Activated (quick-start)', value: m.quickstartActivated, conv: c.signupToActivation, convLabel: 'of signups',
      desc: 'Distinct people who completed at least one quick-start segment, all-time. (This whole funnel is all-time; the "Activation rate" number above the tabs is the cleaner post-launch-cohort version.)',
      example: 'If 9 of the 58 signups answered a quick-start question, this shows 9, about 16% of signups.' },
    { icon: CreditCard, label: 'Started checkout', value: m.checkoutStarts, conv: c.signupToCheckout, convLabel: 'of signups',
      desc: 'Distinct people who opened the Stripe payment page for the exam sim, whether or not they finished paying. The "% of signups" is this ÷ signups.',
      example: 'If 4 people clicked through to checkout, this shows 4, even if only some of them paid.' },
    { icon: CheckCircle, label: 'Purchased', value: m.purchases, conv: c.checkoutToPurchase, convLabel: 'of checkouts',
      desc: 'Exam-sim purchases we were actually paid for, all-time. Complimentary and unpaid grants are excluded. The "% of checkouts" is this ÷ checkouts started.',
      example: 'If 2 of the 4 who started checkout paid, this shows 2, a 50% checkout to purchase rate.' },
  ];

  return (
    <>
      <div className="admin-grid admin-grid--stats">
        <StatCard metric={metrics.purchases} openInfo={openInfo} setOpenInfo={setOpenInfo} />
        <StatCard metric={metrics.arppu} openInfo={openInfo} setOpenInfo={setOpenInfo} />
      </div>

      <div className="admin-grid admin-grid--charts">
        <ChartCard icon={CurrencyDollar} title="Revenue" sub="per day" series={ts?.series.revenue} axis={ts?.axis}
          type="bar" color="forest" fmt={fmtMoney} />
        <ChartCard icon={CurrencyDollar} title="Total revenue" sub="cumulative" series={ts?.series.cumulativeRevenue} axis={ts?.axis}
          type="area" color="forest" fmt={fmtMoney} />
        <ChartCard icon={Receipt} title="Checkout starts" sub="per day" series={ts?.series.checkoutStarts} axis={ts?.axis}
          type="bar" color="sunbeam" fmt={fmtInt} compact />
      </div>

      <SectionHead icon={ChartLineUp} title="Conversion funnel"
        note={`all-time · ${c.signupToPurchase}% signup to purchase`} />
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

      {pitchStats && (
        <>
          <SectionHead icon={Megaphone} title="Exam-sim pitch"
            note="From the countdown emails · non-buyers ~2-4 weeks out" />
          <PitchFunnel s={pitchStats} />
        </>
      )}

      {(recent?.purchases || []).length > 0 && (
        <>
          <SectionHead icon={Receipt} title="Recent purchases" note="emails masked" />
          <div className="recent-purchases">
            {recent.purchases.map((p, i) => (
              <div key={i} className="recent-purchase-row">
                <span className="recent-email">{p.emailMasked}</span>
                <span>${(p.amount / 100).toFixed(2)}</span>
                <span className="recent-muted">{p.tier || '—'}</span>
                <span className="recent-muted">{p.createdAt ? new Date(p.createdAt).toLocaleDateString() : '—'}</span>
              </div>
            ))}
          </div>
        </>
      )}
    </>
  );
}

/* ──────────────────────────────────────────────────────────────────────────
   Users
   ────────────────────────────────────────────────────────────────────────── */

export function UsersPanel({ recent, lookup, setLookup, onLookup, emailStatus }) {
  return (
    <>
      <SectionHead icon={Users} title="Recent users" note="emails masked · look one up for support" />

      <form className="user-lookup" onSubmit={onLookup}>
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
        {(recent?.users || []).map((u, i) => (
          <div key={i} className="recent-row">
            <span className="recent-num">{(recent.total || (recent.users || []).length) - i}</span>
            <span className="recent-email">{u.emailMasked}</span>
            <span>{fmtJoined(u.createdAt)}</span>
            <span>{u.emailVerified ? <CheckCircle weight="fill" size={15} className="recent-ok" /> : <span className="recent-muted">—</span>}</span>
            <span>{u.activated ? <CheckCircle weight="fill" size={15} className="recent-ok" /> : <span className="recent-muted">—</span>}</span>
            <span>{u.chaptersMapped}/15</span>
            <span>{u.totalXp}</span>
            <span>{u.purchased ? <CheckCircle weight="fill" size={15} className="recent-paid" /> : <span className="recent-muted">—</span>}</span>
          </div>
        ))}
        {recent && (recent.users || []).length === 0 && <div className="recent-empty">No users yet.</div>}
      </div>

      {emailStatus?.budget && (
        <>
          <SectionHead icon={EnvelopeSimple} title="Email budget" note="Resend free plan · resets at UTC midnight" />
          <div className="admin-grid admin-grid--halves">
            <BudgetBar label="Today" sent={emailStatus.budget.day} cap={emailStatus.budget.dailyCap}
              soft={emailStatus.budget.dailyLifecycleMax} softLabel="lifecycle stops here" />
            <BudgetBar label="This month" sent={emailStatus.budget.month} cap={emailStatus.budget.monthlyCap}
              soft={emailStatus.budget.monthlySoft} softLabel="soft cap" />
          </div>
        </>
      )}
    </>
  );
}

export function UserCard({ u, onClose }) {
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
export function ExamCalendar({ dates }) {
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
export function BudgetBar({ label, sent, cap, soft, softLabel }) {
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
        <span className="budget-soft" style={{ left: `${softPct}%` }} title={`${soft}, ${softLabel}`} />
      </div>
      <span className="budget-note">{softLabel} at {soft}</span>
    </div>
  );
}

export function PitchFunnel({ s }) {
  const pct = (n, d) => (d > 0 ? Math.round((n / d) * 100) : 0);
  const steps = [
    { icon: Megaphone, label: 'Pitched', value: s.pitched, of: null, color: 'ember' },
    { icon: CursorClick, label: 'Link opens', value: s.clicked, of: null, color: 'ember' },
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
