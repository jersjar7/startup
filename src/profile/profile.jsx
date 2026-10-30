import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import { priceForEmail } from '../data/pricing';
import {
  ArrowLeft,
  SignOut,
  ShieldCheck,
  WarningCircle,
  Trash,
  Eye,
  EyeSlash,
  CheckCircle,
} from '@phosphor-icons/react';
import { AppArrow } from '../components/brand/AppArrow';
import './profile.css';
import { examDateBounds } from '../data/examDateBounds';
import { gradYearOptions, graduatedYearOptions } from '../dashboard/SchoolPrompt';

const EXAM_DATE_BOUNDS = examDateBounds();
// Borrowed from the prompt rather than re-declared, so the window the sign-up
// question offers and the window this page accepts can never drift apart.
const GRAD_YEARS = gradYearOptions();
const GRADUATED_YEARS = graduatedYearOptions();

export function Profile({ userName, onLogout }) {
  useDocumentTitle('Profile');
  const navigate = useNavigate();
  const [userData, setUserData] = React.useState(null);
  const [loading, setLoading] = React.useState(true);

  // Change password state
  const [currentPw, setCurrentPw] = React.useState('');
  const [newPw, setNewPw] = React.useState('');
  const [confirmPw, setConfirmPw] = React.useState('');
  const [pwError, setPwError] = React.useState('');
  const [pwSuccess, setPwSuccess] = React.useState('');
  const [pwSubmitting, setPwSubmitting] = React.useState(false);
  const [showCurrentPw, setShowCurrentPw] = React.useState(false);
  const [showNewPw, setShowNewPw] = React.useState(false);
  const [showConfirmPw, setShowConfirmPw] = React.useState(false);

  // Changing the email address.
  //
  // Until 2026-10-07 this was impossible, and "resend verification" mailed the
  // SAME address, so anybody who mistyped theirs at sign-up was stuck: still
  // able to study, but never receiving anything we send.
  const [emailOpen, setEmailOpen] = React.useState(false);
  const [newEmail, setNewEmail] = React.useState('');
  const [emailPw, setEmailPw] = React.useState('');
  const [emailError, setEmailError] = React.useState('');
  const [emailSuccess, setEmailSuccess] = React.useState('');
  const [emailBusy, setEmailBusy] = React.useState(false);

  async function handleChangeEmail(e) {
    e.preventDefault();
    setEmailError('');
    setEmailSuccess('');
    setEmailBusy(true);
    try {
      const res = await fetch('/api/auth/change-email', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: newEmail, password: emailPw }),
      });
      const body = await res.json().catch(() => ({}));
      if (!res.ok) {
        setEmailError(body.msg || 'That could not be saved.');
        return;
      }
      setEmailSuccess(`Changed. We have sent a verification email to ${body.email}.`);
      setNewEmail('');
      setEmailPw('');
      setEmailOpen(false);
      // The address and the verified badge both change, and the badge is the
      // part that tells them to go and click the link.
      setUserData((u) => ({ ...u, email: body.email, emailVerified: false }));
    } catch {
      setEmailError('Network error. Check your connection and try again.');
    } finally {
      setEmailBusy(false);
    }
  }

  // Details (name + school + exam date) state
  const [detFirst, setDetFirst] = React.useState('');
  const [detLast, setDetLast] = React.useState('');
  const [detSchool, setDetSchool] = React.useState('');
  const [detGradYear, setDetGradYear] = React.useState('');
  // "Already graduated" is an answer of its own (owner, 2026-10-16). Kept
  // here so saving this form never quietly turns a graduate back into a
  // student, which a past year without it used to.
  const [detGraduated, setDetGraduated] = React.useState(false);
  const [detExam, setDetExam] = React.useState('');
  const [detError, setDetError] = React.useState('');
  const [detSuccess, setDetSuccess] = React.useState('');
  const [detSubmitting, setDetSubmitting] = React.useState(false);

  // Delete account state
  // Purchase status
  const [purchaseStatus, setPurchaseStatus] = React.useState(null);

  const [deleteOpen, setDeleteOpen] = React.useState(false);
  const [delPassword, setDelPassword] = React.useState('');
  const [delConfirm, setDelConfirm] = React.useState('');
  const [delError, setDelError] = React.useState('');
  const [delSubmitting, setDelSubmitting] = React.useState(false);

  React.useEffect(() => {
    if (!userName) {
      navigate('/login');
      return;
    }
    Promise.allSettled([
      fetch('/api/user/me').then(r => r.ok ? r.json() : Promise.reject()),
      fetch('/api/checkout/status').then(r => r.ok ? r.json() : Promise.reject()),
    ]).then(([userResult, purchaseResult]) => {
      if (userResult.status === 'fulfilled') {
        setUserData(userResult.value);
        setDetFirst(userResult.value.firstName || '');
        setDetLast(userResult.value.lastName || '');
        setDetSchool(userResult.value.school?.name || '');
        setDetGradYear(userResult.value.school?.graduationYear ? String(userResult.value.school.graduationYear) : '');
        setDetGraduated(userResult.value.school?.graduated === true);
        setDetExam(userResult.value.examDate || '');
      } else {
        navigate('/login');
        return;
      }
      if (purchaseResult.status === 'fulfilled') {
        setPurchaseStatus(purchaseResult.value);
      }
    }).finally(() => setLoading(false));
  }, [userName, navigate]);

  function handleLogout() {
    onLogout();
    navigate('/login');
  }

  async function handleChangePassword(e) {
    e.preventDefault();
    setPwError('');
    setPwSuccess('');

    if (newPw !== confirmPw) {
      setPwError('New passwords do not match');
      return;
    }
    if (newPw.length < 8 || !/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/.test(newPw)) {
      setPwError('Must be 8+ characters with uppercase, lowercase, and a number');
      return;
    }

    setPwSubmitting(true);
    try {
      const res = await fetch('/api/auth/change-password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ currentPassword: currentPw, newPassword: newPw }),
      });
      if (res.ok) {
        setPwSuccess('Password changed successfully');
        setCurrentPw('');
        setNewPw('');
        setConfirmPw('');
      } else {
        const body = await res.json();
        setPwError(body.msg || 'Failed to change password');
      }
    } catch {
      setPwError('Network error');
    } finally {
      setPwSubmitting(false);
    }
  }

  // School lives behind its own route, so one Save button means two writes.
  // Only send it when the pair actually moved: otherwise somebody who came here
  // to fix a typo in their surname would get a school write (and any error it
  // carries) they never asked for.
  function schoolEdited(existing) {
    const name = detSchool.trim();
    const year = detGradYear ? Number(detGradYear) : null;
    return name !== (existing?.name || '')
      || year !== (existing?.graduationYear ?? null)
      || detGraduated !== (existing?.graduated === true);
  }

  async function handleSaveDetails(e) {
    e.preventDefault();
    setDetError('');
    setDetSuccess('');
    setDetSubmitting(true);
    const sendSchool = schoolEdited(userData?.school);
    try {
      // Independent requests on purpose. A school write that fails must not
      // throw away a name or exam date that saved fine, so they are settled
      // separately and only the part that failed is reported.
      const [profileResult, schoolResult] = await Promise.allSettled([
        fetch('/api/user/profile', {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            firstName: detFirst.trim(),
            lastName: detLast.trim(),
            examDate: detExam || null,
          }),
        }),
        sendSchool
          ? fetch('/api/user/school', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              name: detSchool.trim(),
              graduationYear: detGradYear ? Number(detGradYear) : null,
              graduated: detGraduated,
            }),
          })
          : Promise.resolve(null),
      ]);

      const problems = [];

      if (profileResult.status === 'fulfilled') {
        const res = profileResult.value;
        const body = await res.json().catch(() => ({}));
        if (res.ok) {
          setUserData((u) => ({ ...u, ...body }));
        } else {
          problems.push(body.msg || 'Could not save your details');
        }
      } else {
        problems.push('Network error');
      }

      if (sendSchool) {
        const ok = schoolResult.status === 'fulfilled' && schoolResult.value?.ok;
        if (ok) {
          const body = await schoolResult.value.json().catch(() => ({}));
          setUserData((u) => ({ ...u, school: body.school ?? u?.school }));
        } else {
          problems.push('Could not save your school');
        }
      }

      if (problems.length) setDetError(problems.join('. '));
      else setDetSuccess('Saved');
    } catch {
      setDetError('Network error');
    } finally {
      setDetSubmitting(false);
    }
  }

  async function handleDeleteAccount(e) {
    e.preventDefault();
    setDelError('');

    if (delConfirm !== 'DELETE') {
      setDelError('Type DELETE to confirm');
      return;
    }
    if (!delPassword) {
      setDelError('Password is required');
      return;
    }

    setDelSubmitting(true);
    try {
      const res = await fetch('/api/auth/account', {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ password: delPassword, confirmation: delConfirm }),
      });
      if (res.ok) {
        onLogout();
        navigate('/login');
      } else {
        const body = await res.json();
        setDelError(body.msg || 'Failed to delete account');
      }
    } catch {
      setDelError('Network error');
    } finally {
      setDelSubmitting(false);
    }
  }

  if (loading || !userData) return null;

  const joinedDate = userData.createdAt
    ? new Date(userData.createdAt).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })
    : null;

  const emailVerified = userData.emailVerified ?? true;

  const f = detFirst.trim();
  const l = detLast.trim();
  const previewName = f
    ? (l ? `${f} ${l[0].toUpperCase()}.` : f)
    : (userData.email || '').split('@')[0];

  // Counted the way the dashboard counts it, so the two never disagree.
  const examDays = userData.examDate
    ? Math.ceil((new Date(`${userData.examDate}T00:00:00`).getTime() - Date.now()) / 86400000)
    : null;
  const examLong = userData.examDate
    ? new Date(`${userData.examDate}T00:00:00`).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })
    : null;
  const savedName = [userData.firstName, userData.lastName].filter(Boolean).join(' ');
  const school = userData.school?.name;
  const schoolLine = school
    ? `${school}${userData.school?.graduationYear ? `, ${userData.school.graduated ? 'graduated' : 'class of'} ${userData.school.graduationYear}` : ''}`
    : null;

  return (
    <main className="profile-main">
      <div className="profile-header">
        <div>
          <Link to="/dashboard" className="back-link">
            <ArrowLeft size={16} /> Dashboard
          </Link>
          <h1>Profile</h1>
        </div>
        <button className="logout-btn" onClick={handleLogout}>
          <SignOut size={16} /> Logout
        </button>
      </div>

      {/* Who you are at a glance, read left to right like a line of a
          record: identity, then the numbers. */}
      <section className="profile-strip" aria-label="Summary">
        <div className="profile-strip-who">
          <p className="profile-name">{savedName || previewName}</p>
          {schoolLine && <p className="profile-school">{schoolLine}</p>}
        </div>
        <dl className="profile-stats">
          <div><dt>Total XP</dt><dd>{userData.totalXp?.toLocaleString() || 0}</dd></div>
          <div><dt>Days studied</dt><dd>{userData.currentStreak || 0}</dd></div>
          <div><dt>Badges</dt><dd>{userData.badges?.length || 0}</dd></div>
          <div>
            <dt>FE exam</dt>
            <dd className="profile-stat-text">
              {examLong ? (
                <>
                  {examLong}
                  {examDays !== null && examDays >= 0 && (
                    <span className="profile-mono">{examDays === 0 ? 'today' : `${examDays} ${examDays === 1 ? 'day' : 'days'} left`}</span>
                  )}
                </>
              ) : (
                <span className="profile-muted">Not set</span>
              )}
            </dd>
          </div>
          <div>
            <dt>Exam Simulation</dt>
            <dd className="profile-stat-text">
              {purchaseStatus?.purchased ? (
                <>
                  <span className="verified-badge"><CheckCircle size={16} weight="bold" /> Purchased</span>
                  {purchaseStatus.purchaseDate && (
                    <span className="profile-mono">
                      {new Date(purchaseStatus.purchaseDate).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}
                    </span>
                  )}
                </>
              ) : (
                <Link to="/exam" className="profile-text-link">Not purchased (${priceForEmail(userName)})</Link>
              )}
            </dd>
          </div>
        </dl>
      </section>

      {/* The pass card, for good once a pass is recorded, so nobody has to
          find the email again (ADR 0023). */}
      {userData?.passCard && (
        <section className="profile-card profile-pass">
          <div>
            <h2 className="profile-section-title">Your pass card</h2>
            <p className="profile-hint">You passed the FE. Your card is here whenever you want it.</p>
          </div>
          <Link to="/pass-card/me" className="profile-cta">Get my card <AppArrow size={16} /></Link>
        </section>
      )}

      <div className="profile-columns">
        {/* Your details: name (for Live Activity) + school + exam date. School
            is editable here and not only at sign-up: people transfer, and the
            one-time prompt is deliberately never shown twice. */}
        <section className="profile-card">
          <h2 className="profile-section-title">Your details</h2>
          {detError && <p className="error-banner" role="alert">{detError}</p>}
          {detSuccess && <p className="success-banner" role="status">{detSuccess}</p>}
          <form onSubmit={handleSaveDetails} className="profile-grid">
            <div className="details-field">
              <label className="profile-input-label" htmlFor="first-name">First name</label>
              <input id="first-name" type="text" autoComplete="given-name" maxLength={40}
                placeholder="Maria" value={detFirst} onChange={(e) => setDetFirst(e.target.value)} />
            </div>
            <div className="details-field">
              <label className="profile-input-label" htmlFor="last-name">Last name</label>
              <input id="last-name" type="text" autoComplete="family-name" maxLength={40}
                placeholder="Gomez" value={detLast} onChange={(e) => setDetLast(e.target.value)} />
            </div>
            <p className="details-hint profile-span">
              Shown as <strong>{previewName}</strong> in Live Activity. Other students never see your email.
            </p>

            <div className="details-field">
              <label className="profile-input-label" htmlFor="school-name">School</label>
              <input id="school-name" type="text" autoComplete="organization" maxLength={120}
                placeholder="University of West Florida" value={detSchool}
                onChange={(e) => setDetSchool(e.target.value)} />
            </div>
            <div className="details-field">
              <label className="profile-input-label" htmlFor="grad-year">
                {detGraduated ? 'Year you graduated (optional)' : 'Graduation year'}
              </label>
              {/* Bounded to the same five-year window the sign-up prompt offers,
                  for the same reason the exam date is bounded: the two surfaces
                  must not be able to store values the other cannot show. */}
              <input id="grad-year" type="number" inputMode="numeric" step={1}
                min={detGraduated ? GRADUATED_YEARS[GRADUATED_YEARS.length - 1] : GRAD_YEARS[0]}
                max={detGraduated ? GRADUATED_YEARS[0] : GRAD_YEARS[GRAD_YEARS.length - 1]}
                placeholder={String(detGraduated ? GRADUATED_YEARS[3] : GRAD_YEARS[0])} value={detGradYear}
                onChange={(e) => setDetGradYear(e.target.value)} />
            </div>
            <div className="profile-span">
              <label className="profile-check">
                <input type="checkbox" checked={detGraduated}
                  onChange={(e) => { setDetGraduated(e.target.checked); setDetGradYear(''); }} />
                I have already graduated
              </label>
              <p className="details-hint">
                Tells us which programs our students come from, so we know whose
                syllabus to follow.
              </p>
            </div>

            <div className="details-field">
              <label className="profile-input-label" htmlFor="exam-date">FE exam date</label>
              {/* Bounded so the picker cannot offer a date the server will reject.
                  An unbounded input is how two users saved 2028 dates. */}
              <input
                id="exam-date"
                type="date"
                value={detExam}
                min={EXAM_DATE_BOUNDS.min}
                max={EXAM_DATE_BOUNDS.max}
                onChange={(e) => setDetExam(e.target.value)}
              />
            </div>
            <p className="details-hint profile-beside">
              We count down to exam day on your dashboard. Rescheduled? Update it here, or clear it.
            </p>

            <div className="profile-span">
              <button type="submit" className="profile-cta" disabled={detSubmitting}>
                {detSubmitting ? 'Saving...' : 'Save details'} <AppArrow size={16} />
              </button>
            </div>
          </form>
        </section>

        {/* Account info: sign-in email, its status, and the password. */}
        <section className="profile-card">
          <h2 className="profile-section-title">Account</h2>
          <div className="profile-field">
            <span className="profile-label">Email</span>
            <span className="profile-value">
              {userData.email}
              <button
                type="button"
                className="profile-link-btn"
                onClick={() => { setEmailOpen((v) => !v); setEmailError(''); setEmailSuccess(''); }}
              >
                {emailOpen ? 'Cancel' : 'Change'}
              </button>
            </span>
          </div>
          {emailSuccess && <p className="success-banner" role="status">{emailSuccess}</p>}
          {emailOpen && (
            <form className="profile-email-form" onSubmit={handleChangeEmail}>
              {emailError && <p className="error-banner" role="alert">{emailError}</p>}
              <label className="profile-label" htmlFor="new-email">New email</label>
              <input
                id="new-email"
                type="email"
                autoComplete="email"
                value={newEmail}
                onChange={(e) => setNewEmail(e.target.value)}
                disabled={emailBusy}
              />
              <label className="profile-label" htmlFor="email-pw">Your password</label>
              <input
                id="email-pw"
                type="password"
                autoComplete="current-password"
                value={emailPw}
                onChange={(e) => setEmailPw(e.target.value)}
                disabled={emailBusy}
              />
              {/* Said before they submit, because it is the consequence people
                  do not expect: the new address starts unverified. */}
              <p className="profile-hint">
                We will send a verification link to the new address. Your account
                stays signed in.
              </p>
              <button type="submit" className="profile-cta profile-cta--small" disabled={emailBusy}>
                {emailBusy ? 'Saving' : 'Change email'}
              </button>
            </form>
          )}
          <div className="profile-field">
            <span className="profile-label">Email status</span>
            <span className="profile-value">
              {emailVerified ? (
                <span className="verified-badge"><ShieldCheck size={16} weight="bold" /> Verified</span>
              ) : (
                <span className="unverified-badge"><WarningCircle size={16} weight="bold" /> Unverified</span>
              )}
            </span>
          </div>
          {joinedDate && (
            <div className="profile-field">
              <span className="profile-label">Joined</span>
              <span className="profile-value">{joinedDate}</span>
            </div>
          )}

          <h3 className="profile-sub-title">Change password</h3>
          {pwError && <p className="error-banner" role="alert">{pwError}</p>}
          {pwSuccess && <p className="success-banner" role="status">{pwSuccess}</p>}
          <form onSubmit={handleChangePassword} className="profile-grid">
            <div className="profile-span">
              <label className="profile-input-label" htmlFor="current-pw">Current password</label>
              <div className="password-field">
                <input
                  id="current-pw"
                  type={showCurrentPw ? 'text' : 'password'}
                  autoComplete="current-password"
                  value={currentPw}
                  onChange={(e) => setCurrentPw(e.target.value)}
                  required
                />
                <button type="button" className="password-toggle" onClick={() => setShowCurrentPw(!showCurrentPw)} aria-label={showCurrentPw ? 'Hide password' : 'Show password'}>
                  {showCurrentPw ? <EyeSlash size={18} /> : <Eye size={18} />}
                </button>
              </div>
            </div>
            <div className="details-field">
              <label className="profile-input-label" htmlFor="new-pw">New password</label>
              <div className="password-field">
                <input
                  id="new-pw"
                  type={showNewPw ? 'text' : 'password'}
                  placeholder="8+ characters"
                  autoComplete="new-password"
                  value={newPw}
                  onChange={(e) => setNewPw(e.target.value)}
                  required
                />
                <button type="button" className="password-toggle" onClick={() => setShowNewPw(!showNewPw)} aria-label={showNewPw ? 'Hide password' : 'Show password'}>
                  {showNewPw ? <EyeSlash size={18} /> : <Eye size={18} />}
                </button>
              </div>
            </div>
            <div className="details-field">
              <label className="profile-input-label" htmlFor="confirm-pw">Confirm new password</label>
              <div className="password-field">
                <input
                  id="confirm-pw"
                  type={showConfirmPw ? 'text' : 'password'}
                  placeholder="Repeat new password"
                  autoComplete="new-password"
                  value={confirmPw}
                  onChange={(e) => setConfirmPw(e.target.value)}
                  required
                />
                <button type="button" className="password-toggle" onClick={() => setShowConfirmPw(!showConfirmPw)} aria-label={showConfirmPw ? 'Hide password' : 'Show password'}>
                  {showConfirmPw ? <EyeSlash size={18} /> : <Eye size={18} />}
                </button>
              </div>
            </div>
            <div className="profile-span">
              <button type="submit" className="profile-cta profile-cta--quiet" disabled={pwSubmitting || !(currentPw && newPw && confirmPw)}>
                {pwSubmitting ? 'Changing...' : 'Change password'}
              </button>
            </div>
          </form>
        </section>
      </div>

      {/* Used once if ever, and destructive, so it stays folded away until
          asked for instead of taking a card's worth of the page. */}
      {!deleteOpen ? (
        <button type="button" className="profile-delete-open" onClick={() => setDeleteOpen(true)}>
          <Trash size={16} weight="bold" /> Delete account
        </button>
      ) : (
        <section className="profile-card danger-zone">
          <h2 className="profile-section-title danger-title">
            <Trash size={20} weight="bold" /> Delete account
          </h2>
          <p className="danger-description">
            This permanently deletes your account and all associated data. This action cannot be undone.
          </p>
          {delError && <p className="error-banner" role="alert">{delError}</p>}
          <form onSubmit={handleDeleteAccount} className="profile-grid">
            <div className="details-field">
              <label className="profile-input-label" htmlFor="del-pw">Password</label>
              <input
                id="del-pw"
                type="password"
                autoComplete="current-password"
                value={delPassword}
                onChange={(e) => setDelPassword(e.target.value)}
                required
              />
            </div>
            <div className="details-field">
              <label className="profile-input-label" htmlFor="del-confirm">Type DELETE to confirm</label>
              <input
                id="del-confirm"
                type="text"
                placeholder="DELETE"
                autoComplete="off"
                value={delConfirm}
                onChange={(e) => setDelConfirm(e.target.value)}
                required
              />
            </div>
            <div className="profile-span profile-actions">
              <button
                type="submit"
                className="btn-danger"
                disabled={delSubmitting || delConfirm !== 'DELETE' || !delPassword}
              >
                {delSubmitting ? 'Deleting...' : 'Permanently delete account'}
              </button>
              <button type="button" className="profile-link-btn profile-cancel" onClick={() => { setDeleteOpen(false); setDelPassword(''); setDelConfirm(''); setDelError(''); }}>
                Cancel
              </button>
            </div>
          </form>
        </section>
      )}
    </main>
  );
}
