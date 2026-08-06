import React from 'react';
import { Link } from 'react-router-dom';
import { UserCircle, ChartLineUp, Exam } from '@phosphor-icons/react';
import { Logo } from '../logo';
import { trackPitch } from '../exam/trackPitch';

// Analytics link is shown only for the owner account. The page itself is also
// enforced server-side, so this is just the entry point, not the gate.
const ADMIN_EMAIL = 'admin@oqupa.com';

export function Header({ userName }) {
  const isAdmin = (userName || '').toLowerCase() === ADMIN_EMAIL;
  return (
    <header>
      <div className="nav-brand">
        <Logo height={52} />
      </div>
      {userName && (
        <div className="header-actions">
          {/* Permanent, ungated route to the paid product. The dashboard card
              only appears at the bottom of a long page, and the pitch banner is
              conditional by design — until this existed there was no path to
              /exam visible from every screen. */}
          <Link
            to="/exam"
            className="header-exam-link"
            aria-label="Exam Simulation"
            onClick={() => trackPitch('click', 'nav')}
          >
            <Exam size={18} weight="bold" />
            <span>Exam Sim</span>
          </Link>
          {isAdmin && (
            <Link to="/admin" className="header-admin-link" aria-label="Analytics">
              <ChartLineUp size={18} weight="bold" />
              <span>Analytics</span>
            </Link>
          )}
          <Link to="/profile" className="header-profile-link" aria-label="Profile">
            <UserCircle size={28} weight="bold" />
          </Link>
        </div>
      )}
    </header>
  );
}
