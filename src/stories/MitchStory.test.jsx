import React from 'react';
import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import * as mod from './MitchStory.jsx';

describe('Mitch story page', () => {
  it('renders, and names Mitch instead of using pronouns', () => {
    const Page = mod.MitchStory || mod.default;
    const { container } = render(<MemoryRouter><Page /></MemoryRouter>);
    expect(screen.getByRole('heading', { level: 1 })).toBeInTheDocument();
    expect(container.textContent).not.toMatch(/\b(he|his|him)\b/i);
  });
});
