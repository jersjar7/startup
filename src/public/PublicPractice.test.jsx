import React from 'react';
import { describe, it, expect } from 'vitest';
import { render, screen, fireEvent, within } from '@testing-library/react';
import { MemoryRouter, Routes, Route } from 'react-router-dom';
import { PublicPractice, plainText } from './PublicPractice.jsx';
import { getChapterPracticeProblems } from '../data/chapter-practice/index';
import { TOPIC_IDS } from './content';
import { PRERENDERED_ROUTE_PATTERN } from '../../service/prerenderedRoutes.js';

function mount(path) {
  return render(
    <MemoryRouter initialEntries={[path]}>
      <Routes><Route path="/fe-civil/:topicId/practice-problems" element={<PublicPractice />} /></Routes>
    </MemoryRouter>,
  );
}

describe('free practice problems page', () => {
  it('shows every chapter practice problem for the chapter, with no account', () => {
    mount('/fe-civil/statics/practice-problems');
    const count = getChapterPracticeProblems('statics').length;
    expect(screen.getByRole('heading', { level: 1, name: 'FE Civil Statics practice problems' })).toBeInTheDocument();
    expect(screen.getAllByRole('article')).toHaveLength(count);
    expect(screen.getByRole('link', { name: 'Create a free account' })).toHaveAttribute('href', '/login');
  });

  it('marks the pick, opens the worked solution, and keeps score', () => {
    mount('/fe-civil/statics/practice-problems');
    const first = getChapterPracticeProblems('statics')[0];
    const card = screen.getAllByRole('article')[0];
    const wrongIndex = first.choices.findIndex((c) => c.id !== first.correctAnswerId);
    const buttons = within(card).getAllByRole('button');
    fireEvent.click(buttons[wrongIndex]);
    expect(within(card).getByRole('status')).toHaveTextContent('Not quite');
    expect(card.querySelector('details')).toHaveAttribute('open');
    expect(buttons.every((b) => b.disabled)).toBe(true);
    expect(screen.getByText(/0 of 1 right so far/)).toBeInTheDocument();
  });

  it('has a page for every chapter, and the server serves each one prerendered', () => {
    for (const id of TOPIC_IDS) {
      expect(getChapterPracticeProblems(id).length, id).toBeGreaterThan(0);
      expect(PRERENDERED_ROUTE_PATTERN.test(`/fe-civil/${id}/practice-problems`), id).toBe(true);
    }
  });

  it('turns formulas into plain words for search engines', () => {
    expect(plainText('$150$ N at $53.1\\degree$ from the horizontal')).toBe('150 N at 53.1 degrees from the horizontal');
    expect(plainText('$400$ N$\\cdot$m')).toBe('400 N·m');
  });
});
