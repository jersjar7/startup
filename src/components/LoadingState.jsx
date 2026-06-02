import React from 'react';
import './LoadingState.css';

export function LoadingState() {
  return (
    <main className="loading-state" role="status" aria-live="polite">
      <div className="loading-spinner" aria-hidden="true" />
      <span className="loading-text">Loading</span>
    </main>
  );
}
