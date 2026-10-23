import React from 'react';
import { ArrowRight } from '@phosphor-icons/react';
import './appArrow.css';

// The arrow-in-a-circle that ends the app's main buttons. The circle takes the
// button's text colour and the arrow takes the button's background, so set
// --btn-bg on the button (it defaults to ember).
export function AppArrow({ size = 20 }) {
  return (
    <span className="app-arrow" aria-hidden="true">
      <ArrowRight weight="bold" size={size} />
    </span>
  );
}
