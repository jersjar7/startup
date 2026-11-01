import React from 'react';
import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { LeagueResult } from './LeagueResult';
import { LeagueBoard } from './LeagueBoard';

// Last week's result reads the /api/league shape, and its end state is the
// markup itself, so with no motion (as here) nothing is hidden.
const base = { weekId: '2026-W44', size: 15, xp: 1180, place: 3 };

describe('the league result', () => {
  it('says a move up, with last week\'s place and XP', () => {
    render(<LeagueResult result={{ ...base, moved: 'up', tier: 'bronze', tierName: 'Bronze', newTier: 'silver', newTierName: 'Silver' }} onClose={() => {}} />);
    expect(screen.getByRole('heading').textContent).toBe('You moved up to Silver');
    expect(screen.getByText('3rd of 15 in Bronze last week, with 1,180 XP.')).toBeTruthy();
  });

  it('says a move down without scolding', () => {
    render(<LeagueResult result={{ ...base, place: 14, moved: 'down', tier: 'gold', tierName: 'Gold', newTier: 'silver', newTierName: 'Silver' }} onClose={() => {}} />);
    expect(screen.getByRole('heading').textContent).toBe('You moved down to Silver');
    expect(screen.getByText('One good week brings you back.')).toBeTruthy();
  });

  it('says a stay, and marks the new league on the ladder', () => {
    const { container } = render(<LeagueResult result={{ ...base, moved: 'stayed', tier: 'silver', tierName: 'Silver', newTier: 'silver', newTierName: 'Silver' }} onClose={() => {}} />);
    expect(screen.getByRole('heading').textContent).toBe('You stay in Silver');
    expect(container.querySelector('li.is-now').dataset.tier).toBe('silver');
    expect(container.querySelector('li.is-was')).toBeNull();
  });

  it('closes from its button', () => {
    const onClose = vi.fn();
    render(<LeagueResult result={{ ...base, moved: 'up', tier: 'bronze', tierName: 'Bronze', newTier: 'silver', newTierName: 'Silver' }} onClose={onClose} />);
    fireEvent.click(screen.getByRole('button', { name: /see your league/i }));
    expect(onClose).toHaveBeenCalled();
  });
});

describe('the league board', () => {
  const league = {
    tier: 'silver', tierName: 'Silver', nextTierName: 'Gold', prevTierName: 'Bronze', joined: true,
    zones: { promote: 1, demote: 1 },
    rows: [
      { place: 1, name: 'Tom', xp: 900, days: 5, move: 'up', isMe: false },
      { place: 2, name: 'Maria G.', xp: 300, days: 1, move: null, isMe: true },
      { place: 3, name: 'ana***', xp: 120, days: 2, move: 'new', isMe: false },
    ],
  };

  it('names the leagues at the zone lines and shows each week', () => {
    render(<LeagueBoard league={league} />);
    expect(screen.getByText('Moving up to Gold')).toBeTruthy();
    expect(screen.getByText('Staying in Silver')).toBeTruthy();
    expect(screen.getByText('Moving down to Bronze')).toBeTruthy();
    expect(screen.getByText('900 XP · 5 days this week')).toBeTruthy();
    expect(screen.getByText('300 XP · 1 day this week')).toBeTruthy();
    expect(screen.getByText('New')).toBeTruthy();
  });
});
