import React from 'react';
import { GraduationCap, Plus, PencilSimple, X } from '@phosphor-icons/react';

// School site licences (ADR 0040): a college pays yearly, and every student
// with a verified address on its email domain gets the Exam Simulation. The
// owner creates, edits and ends them here and watches the seats fill.

const STATE_LABEL = { active: 'Active', scheduled: 'Starts later', expired: 'Expired', ended: 'Ended early' };

const ymd = (v) => (v ? new Date(v).toISOString().slice(0, 10) : '');
const fmtDay = (v) => (v
  ? new Date(v).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric', timeZone: 'UTC' })
  : '');

const EMPTY = {
  schoolName: '', domains: '', startsAt: '', endsAt: '', seatCap: '', contactName: '', contactEmail: '', notes: '',
};

function toForm(l) {
  if (!l) {
    const start = new Date();
    const end = new Date(start);
    end.setUTCFullYear(end.getUTCFullYear() + 1);
    return { ...EMPTY, startsAt: ymd(start), endsAt: ymd(end), seatCap: '500' };
  }
  return {
    schoolName: l.schoolName,
    domains: (l.domains || []).join(', '),
    startsAt: ymd(l.startsAt),
    endsAt: ymd(l.endsAt),
    seatCap: String(l.seatCap),
    contactName: l.contactName || '',
    contactEmail: l.contactEmail || '',
    notes: l.notes || '',
  };
}

function LicenseForm({ initial, onSave, onCancel, busy, error }) {
  const [f, setF] = React.useState(() => toForm(initial));
  const set = (k) => (e) => setF((s) => ({ ...s, [k]: e.target.value }));
  const submit = (e) => {
    e.preventDefault();
    onSave({ ...f, seatCap: Number(f.seatCap) });
  };
  return (
    <form className="lic-form" onSubmit={submit} aria-label={initial ? 'Edit licence' : 'New licence'}>
      <div className="lic-form-head">
        <h4>{initial ? `Edit ${initial.schoolName}` : 'New licence'}</h4>
        <button type="button" className="lic-icon-btn" onClick={onCancel} aria-label="Close">
          <X weight="bold" size={16} />
        </button>
      </div>
      <div className="lic-form-grid">
        <label className="lic-field lic-field--wide">
          <span>School</span>
          <input value={f.schoolName} onChange={set('schoolName')} placeholder="Brigham Young University" required />
        </label>
        <label className="lic-field lic-field--wide">
          <span>Student email domains</span>
          <input value={f.domains} onChange={set('domains')} placeholder="byu.edu, student.byu.edu" required />
          <em>Exact match. A subdomain counts only if you list it.</em>
        </label>
        <label className="lic-field">
          <span>Starts</span>
          <input type="date" value={f.startsAt} onChange={set('startsAt')} required />
        </label>
        <label className="lic-field">
          <span>Ends</span>
          <input type="date" value={f.endsAt} onChange={set('endsAt')} required />
        </label>
        <label className="lic-field">
          <span>Seats</span>
          <input type="number" min="1" step="1" inputMode="numeric" value={f.seatCap} onChange={set('seatCap')} required />
        </label>
        <label className="lic-field">
          <span>Contact name</span>
          <input value={f.contactName} onChange={set('contactName')} placeholder="Dr. Ames" />
        </label>
        <label className="lic-field lic-field--wide">
          <span>Contact email</span>
          <input type="email" value={f.contactEmail} onChange={set('contactEmail')} placeholder="department@byu.edu" />
        </label>
        <label className="lic-field lic-field--wide">
          <span>Notes</span>
          <textarea rows={2} value={f.notes} onChange={set('notes')} placeholder="Invoice, purchase order, renewal terms" />
        </label>
      </div>
      {error && <p className="lic-error" role="alert">{error}</p>}
      <div className="lic-form-actions">
        <button type="submit" className="btn-primary lic-save" disabled={busy}>
          {busy ? 'Saving…' : initial ? 'Save changes' : 'Create licence'}
        </button>
        <button type="button" className="btn-secondary" onClick={onCancel} disabled={busy}>Cancel</button>
      </div>
    </form>
  );
}

function SeatBar({ used, cap }) {
  const pct = cap > 0 ? Math.min(100, (used / cap) * 100) : 0;
  const level = used >= cap ? 'full' : pct >= 85 ? 'warn' : 'ok';
  return (
    <div className="lic-seats">
      <div className="lic-seats-top">
        <span className="lic-seats-label">Seats used</span>
        <span className="lic-seats-nums"><strong>{used}</strong> / {cap}</span>
      </div>
      <div className="lic-seats-track" role="meter" aria-valuemin={0} aria-valuemax={cap} aria-valuenow={used}
        aria-label={`${used} of ${cap} seats used`}>
        <span className={`lic-seats-fill lic-seats-fill--${level}`} style={{ width: `${pct}%` }} />
      </div>
      {level === 'full' && <span className="lic-seats-note">Full. New students are told to ask their department.</span>}
    </div>
  );
}

function LicenseCard({ l, onEdit, onEnd, onReopen, busy }) {
  return (
    <article className={`lic-card lic-card--${l.state}`} aria-label={l.schoolName}>
      <div className="lic-card-head">
        <div>
          <h4 className="lic-name">{l.schoolName}</h4>
          <p className="lic-domains">{(Array.isArray(l.domains) ? l.domains : []).map((d) => `@${d}`).join(', ')}</p>
        </div>
        <span className={`lic-state lic-state--${l.state}`}>{STATE_LABEL[l.state] || l.state}</span>
      </div>
      <p className="lic-dates">
        {fmtDay(l.startsAt)} to {fmtDay(l.endsAt)}
        {l.endedAt && <> · ended {fmtDay(l.endedAt)}</>}
      </p>
      <SeatBar used={l.seatsUsed} cap={l.seatCap} />
      {(l.contactName || l.contactEmail) && (
        <p className="lic-contact">{[l.contactName, l.contactEmail].filter(Boolean).join(' · ')}</p>
      )}
      {l.notes && <p className="lic-notes">{l.notes}</p>}
      <div className="lic-actions">
        <button type="button" className="btn-secondary lic-action" onClick={() => onEdit(l)} disabled={busy}>
          <PencilSimple weight="bold" size={14} /> Edit
        </button>
        {l.state === 'ended' ? (
          <button type="button" className="btn-secondary lic-action" onClick={() => onReopen(l)} disabled={busy}>Reopen</button>
        ) : (
          <button type="button" className="lic-end" onClick={() => onEnd(l)} disabled={busy}>End now</button>
        )}
      </div>
    </article>
  );
}

export function SchoolLicensesPanel() {
  const [licenses, setLicenses] = React.useState(null);
  const [loadError, setLoadError] = React.useState('');
  const [editing, setEditing] = React.useState(null); // null | 'new' | licence
  const [busy, setBusy] = React.useState(false);
  const [error, setError] = React.useState('');

  const load = React.useCallback(() => {
    fetch('/api/admin/school-licenses')
      .then((r) => (r.ok ? r.json() : Promise.reject()))
      .then((b) => { setLicenses(b.licenses || []); setLoadError(''); })
      .catch(() => setLoadError('Could not load licences.'));
  }, []);
  React.useEffect(() => { load(); }, [load]);

  async function send(url, method, body) {
    setBusy(true);
    setError('');
    try {
      const r = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: body ? JSON.stringify(body) : undefined,
      });
      const b = await r.json().catch(() => ({}));
      if (!r.ok) { setError(b.msg || 'That did not save.'); return false; }
      load();
      return true;
    } catch {
      setError('Network error. Try again.');
      return false;
    } finally {
      setBusy(false);
    }
  }

  async function save(fields) {
    const ok = editing === 'new'
      ? await send('/api/admin/school-licenses', 'POST', fields)
      : await send(`/api/admin/school-licenses/${editing.id}`, 'PATCH', fields);
    if (ok) setEditing(null);
  }

  async function end(l) {
    if (!window.confirm(`End the ${l.schoolName} licence now? Students mid-exam can still finish.`)) return;
    await send(`/api/admin/school-licenses/${l.id}/end`, 'POST');
  }

  const active = (licenses || []).filter((l) => l.state === 'active');
  const seatsInUse = active.reduce((n, l) => n + l.seatsUsed, 0);

  return (
    <section className="lic" aria-label="School licences">
      <div className="lic-top">
        <div className="admin-section-head">
          <GraduationCap weight="bold" size={18} />
          <h3>School licences</h3>
          <span className="admin-section-note">
            {licenses ? `${active.length} active · ${seatsInUse} ${seatsInUse === 1 ? 'seat' : 'seats'} in use` : 'loading'}
          </span>
        </div>
        {editing !== 'new' && (
          <button type="button" className="btn-primary lic-new" onClick={() => { setError(''); setEditing('new'); }}>
            <Plus weight="bold" size={16} /> New licence
          </button>
        )}
      </div>
      <p className="lic-intro">
        Students whose verified school email is on a licence&apos;s domain get the Exam Simulation free. A seat is
        taken the first time a student starts an exam, and stays theirs for the licence&apos;s life. Licence
        students never count as sales.
      </p>

      {editing === 'new' && (
        <LicenseForm initial={null} onSave={save} onCancel={() => setEditing(null)} busy={busy} error={error} />
      )}

      {loadError && <p className="lic-error" role="alert">{loadError}</p>}
      {licenses && licenses.length === 0 && editing !== 'new' && (
        <p className="lic-empty">No licences yet. Create one when a college signs.</p>
      )}

      <div className="lic-list">
        {(licenses || []).map((l) => (editing && editing !== 'new' && editing.id === l.id ? (
          <LicenseForm key={l.id} initial={l} onSave={save} onCancel={() => setEditing(null)} busy={busy} error={error} />
        ) : (
          <LicenseCard key={l.id} l={l} busy={busy}
            onEdit={(x) => { setError(''); setEditing(x); }}
            onEnd={end}
            onReopen={(x) => send(`/api/admin/school-licenses/${x.id}/reopen`, 'POST')} />
        )))}
      </div>
      {error && !editing && <p className="lic-error" role="alert">{error}</p>}
    </section>
  );
}
