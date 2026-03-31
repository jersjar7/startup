import React from 'react';
import { Logo } from '../logo';

export function Header() {
  return (
    <header>
      <div className="nav-brand">
        <Logo height={52} />
      </div>
    </header>
  );
}
