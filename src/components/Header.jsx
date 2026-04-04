import React from 'react';
import { Link } from 'react-router-dom';
import { UserCircle } from '@phosphor-icons/react';
import { Logo } from '../logo';

export function Header({ userName }) {
  return (
    <header>
      <div className="nav-brand">
        <Logo height={52} />
      </div>
      {userName && (
        <Link to="/profile" className="header-profile-link" aria-label="Profile">
          <UserCircle size={28} weight="bold" />
        </Link>
      )}
    </header>
  );
}
