import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import { priceForEmail } from '../data/pricing';
import {
  ArrowLeft,
  SignOut,
  ShieldCheck,
  WarningCircle,
  LockKey,
  Trash,
  Lightning,
  Fire,
  Medal,
  Eye,
  EyeSlash,
  Exam,
  CheckCircle,
  IdentificationCard,
  CalendarBlank,
} from '@phosphor-icons/react';
import './profile.css';

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

  // Details (name + exam date) state
  const [detFirst, setDetFirst] = React.useState('');
  const [detLast, setDetLast] = React.useState('');
  const [detExam, setDetExam] = React.useState('');
  const [detError, setDetError] = React.useState('');
  const [detSuccess, setDetSuccess] = React.useState('');
  const [detSubmitting, setDetSubmitting] = React.useState(false);

  // Delete account state
  // Purchase status
  const [purchaseStatus, setPurchaseStatus] = React.useState(null);

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

  async function handleSaveDetails(e) {
    e.preventDefault();
    setDetError('');
    setDetSuccess('');
    setDetSubmitting(true);
    try {
      const res = await fetch('/api/user/profile', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          firstName: detFirst.trim(),
          lastName: detLast.trim(),
          examDate: detExam || null,
        }),
      });
      const body = await res.json().catch(() => ({}));
      if (res.ok) {
        setDetSuccess('Saved');
        setUserData((u) => ({ ...u, ...body }));
      } else {
        setDetError(body.msg || 'Could not save your details');
      }
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

  return (
    <main className="profile-main">
      <div className="profile-header">
        <Link to="/dashboard" className="back-link">
          <ArrowLeft size={18} /> Dashboard
        </Link>
        <h1>Profile</h1>
        <button className="logout-btn" onClick={handleLogout}>
          <SignOut size={16} /> Logout
        </button>
      </div>

      {/* Account info */}
      <section className="profile-card">
        <h2 className="profile-section-title">Account</h2>
        <div className="profile-field">
          <span className="profile-label">Email</span>
          <span className="profile-value">{userData.email}</span>
        </div>
        {joinedDate && (
          <div className="profile-field">
            <span className="profile-label">Joined</span>
            <span className="profile-value">{joinedDate}</span>
          </div>
        )}
        <div className="profile-field">
          <span className="profile-label">Email Status</span>
          <span className="profile-value">
            {emailVerified ? (
              <span className="verified-badge"><ShieldCheck size={16} weight="bold" /> Verified</span>
            ) : (
              <span className="unverified-badge"><WarningCircle size={16} weight="bold" /> Unverified</span>
            )}
          </span>
        </div>
      </section>

      {/* Your details — name (for Live Activity) + exam date */}
      <section className="profile-card">
        <h2 className="profile-section-title">
          <IdentificationCard size={20} weight="bold" /> Your Details
        </h2>
        {detError && <p className="error-banner" role="alert">{detError}</p>}
        {detSuccess && <p className="success-banner" role="status">{detSuccess}</p>}
        <form onSubmit={handleSaveDetails}>
          <div className="details-row">
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
          </div>
          <p className="details-hint">
            Shown as <strong>{previewName}</strong> in Live Activity — other students never see your email.
          </p>

          <label className="profile-input-label" htmlFor="exam-date">
            <CalendarBlank size={15} weight="bold" style={{ verticalAlign: '-2px', marginRight: '0.3rem' }} />
            FE exam date
          </label>
          <input id="exam-date" type="date" value={detExam} onChange={(e) => setDetExam(e.target.value)} />
          <p className="details-hint">
            We'll count down to exam day on your dashboard. Rescheduled? Just update it (or clear it).
          </p>

          <button type="submit" className="btn-primary" disabled={detSubmitting}>
            {detSubmitting ? 'Saving...' : 'Save details'}
          </button>
        </form>
      </section>

      {/* Stats summary */}
      <section className="profile-card">
        <h2 className="profile-section-title">Stats</h2>
        <div className="stats-grid">
          <div className="stat-item">
            <Lightning size={20} weight="bold" color="var(--sunbeam)" />
            <span className="stat-value">{userData.totalXp?.toLocaleString() || 0}</span>
            <span className="stat-label">Total XP</span>
          </div>
          <div className="stat-item">
            <Fire size={20} weight="bold" color="var(--ember)" />
            <span className="stat-value">{userData.currentStreak || 0}</span>
            <span className="stat-label">Days studied</span>
          </div>
          <div className="stat-item">
            <Medal size={20} weight="bold" color="var(--forest)" />
            <span className="stat-value">{userData.badges?.length || 0}</span>
            <span className="stat-label">Badges</span>
          </div>
        </div>
      </section>

      {/* Purchases */}
      <section className="profile-card">
        <h2 className="profile-section-title">
          <Exam size={20} weight="bold" /> Purchases
        </h2>
        {purchaseStatus?.purchased ? (
          <div className="profile-field">
            <span className="profile-label">Exam Simulation</span>
            <span className="profile-value">
              <span className="verified-badge"><CheckCircle size={16} weight="bold" /> Purchased</span>
              {purchaseStatus.purchaseDate && (
                <span style={{ marginLeft: '0.5rem', fontSize: '0.82rem', color: 'var(--gray-400)' }}>
                  {new Date(purchaseStatus.purchaseDate).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}
                </span>
              )}
            </span>
          </div>
        ) : (
          <div className="profile-field">
            <span className="profile-label">Exam Simulation</span>
            <span className="profile-value">
              <Link to="/exam" style={{ color: 'var(--ember)', fontWeight: 600, textDecoration: 'none' }}>
                Not purchased — ${priceForEmail(userName)}
              </Link>
            </span>
          </div>
        )}
      </section>

      {/* Change password */}
      <section className="profile-card">
        <h2 className="profile-section-title">
          <LockKey size={20} weight="bold" /> Change Password
        </h2>
        {pwError && <p className="error-banner" role="alert">{pwError}</p>}
        {pwSuccess && <p className="success-banner" role="status">{pwSuccess}</p>}
        <form onSubmit={handleChangePassword}>
          <label className="profile-input-label" htmlFor="current-pw">Current Password</label>
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
          <label className="profile-input-label" htmlFor="new-pw">New Password</label>
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
          <label className="profile-input-label" htmlFor="confirm-pw">Confirm New Password</label>
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
          <button type="submit" className="btn-primary" disabled={pwSubmitting || !(currentPw && newPw && confirmPw)}>
            {pwSubmitting ? 'Changing...' : 'Change Password'}
          </button>
        </form>
      </section>

      {/* Danger zone */}
      <section className="profile-card danger-zone">
        <h2 className="profile-section-title danger-title">
          <Trash size={20} weight="bold" /> Delete Account
        </h2>
        <p className="danger-description">
          This permanently deletes your account and all associated data. This action cannot be undone.
        </p>
        {delError && <p className="error-banner" role="alert">{delError}</p>}
        <form onSubmit={handleDeleteAccount}>
          <label className="profile-input-label" htmlFor="del-pw">Password</label>
          <input
            id="del-pw"
            type="password"
            autoComplete="current-password"
            value={delPassword}
            onChange={(e) => setDelPassword(e.target.value)}
            required
          />
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
          <button
            type="submit"
            className="btn-danger"
            disabled={delSubmitting || delConfirm !== 'DELETE' || !delPassword}
          >
            {delSubmitting ? 'Deleting...' : 'Permanently Delete Account'}
          </button>
        </form>
      </section>
    </main>
  );
}
