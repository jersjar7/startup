import React from 'react';
import { describe, it, expect, beforeEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { AppNudge, APP_NUDGE_KEY, shouldShowAppNudge } from './AppNudge';

const renderNudge = (props = {}) => render(<MemoryRouter><AppNudge syncState={null} {...props} /></MemoryRouter>);

describe('AppNudge', () => {
  beforeEach(() => localStorage.clear());

  it('shows to someone who has never synced from the phone, and links to the app page', () => {
    renderNudge();
    expect(screen.getByText('Have you seen our new app?')).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'See how it works' })).toHaveAttribute('href', '/app');
  });

  it('stays away for anyone who already uses the app', () => {
    renderNudge({ syncState: { at: '2026-10-28T12:00:00Z', device: 'Pixel' } });
    expect(screen.queryByText('Have you seen our new app?')).toBeNull();
  });

  it('hides when closed, and stays hidden on the next visit', () => {
    const { unmount } = renderNudge();
    fireEvent.click(screen.getByRole('button', { name: 'Hide the app card' }));
    expect(screen.queryByText('Have you seen our new app?')).toBeNull();
    expect(localStorage.getItem(APP_NUDGE_KEY)).toBe('1');
    unmount();
    renderNudge();
    expect(screen.queryByText('Have you seen our new app?')).toBeNull();
  });

  it('decides from the sync and the close button only', () => {
    expect(shouldShowAppNudge({ syncState: null, hidden: false })).toBe(true);
    expect(shouldShowAppNudge({ syncState: { at: 'x' }, hidden: false })).toBe(false);
    expect(shouldShowAppNudge({ syncState: null, hidden: true })).toBe(false);
  });
});
