import React from 'react';
import { describe, it, expect } from 'vitest';
import { render, screen, within } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { ExamGuide } from './ExamGuide.jsx';
import { TOPIC_IDS, EXAM_DAY } from './content';

function mount() {
  return render(<MemoryRouter><ExamGuide /></MemoryRouter>);
}

describe('FE Civil exam guide', () => {
  it('links every chapter to its study guide and its practice problems', () => {
    mount();
    const topics = document.getElementById('topics');
    for (const id of TOPIC_IDS) {
      expect(topics.querySelector(`a[href="/fe-civil/${id}"]`), id).not.toBeNull();
      expect(topics.querySelector(`a[href="/fe-civil/${id}/practice-problems"]`), id).not.toBeNull();
    }
  });

  it('draws the exam day from the NCEES appointment: 5 h 20 min of exam time plus a 25 min break', () => {
    const exam = EXAM_DAY.filter((p) => p.kind === 'exam').reduce((s, p) => s + p.minutes, 0);
    expect(exam).toBe(320);
    expect(EXAM_DAY.find((p) => p.kind === 'break').minutes).toBe(25);
    mount();
    expect(document.querySelectorAll('.eg-day-seg')).toHaveLength(EXAM_DAY.length);
  });

  it('has a contents entry for every section, and every entry lands on one', () => {
    mount();
    const rail = screen.getByRole('navigation', { name: 'On this page' });
    const links = within(rail).getAllByRole('link');
    expect(links.length).toBeGreaterThan(5);
    for (const a of links) expect(document.querySelector(a.getAttribute('href'))).not.toBeNull();
  });

  it('shows the pass rate as 100 squares with the passing share filled', () => {
    mount();
    const grid = screen.getByRole('img', { name: /of every 100 first-time takers passed/ });
    const rate = Number(grid.getAttribute('aria-label').match(/^\d+/)[0]);
    expect(grid.children).toHaveLength(100);
    expect(grid.querySelectorAll('.is-pass')).toHaveLength(rate);
  });
});
