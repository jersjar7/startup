import React from 'react';
import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { AppPage } from './AppPage';
import { PLAY_URL } from '../data/appLinks';

describe('AppPage', () => {
  it('has one h1, links to Google Play, and says iPhone is coming soon', () => {
    const { container } = render(<MemoryRouter><AppPage /></MemoryRouter>);
    expect(container.querySelectorAll('h1')).toHaveLength(1);
    const play = screen.getAllByRole('link', { name: /Get it on Google Play/ });
    expect(play.length).toBeGreaterThan(0);
    play.forEach((a) => expect(a).toHaveAttribute('href', PLAY_URL));
    expect(screen.getAllByText(/iPhone: coming soon/).length).toBeGreaterThan(0);
  });

  it('keeps mastery on the website', () => {
    render(<MemoryRouter><AppPage /></MemoryRouter>);
    expect(screen.getByText(/Mastery, earned only on full problems/)).toBeInTheDocument();
  });
});
