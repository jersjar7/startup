import React from 'react';
import { describe, it, expect } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { FormulaFinder } from './FormulaFinder.jsx';
import { allFormulas, matches, GUIDES } from './formulas';
import { allTopics } from './content';
import { PRERENDERED_ROUTE_PATTERN } from '../../service/prerenderedRoutes.js';

function mount() {
  return render(<MemoryRouter><FormulaFinder /></MemoryRouter>);
}

const squash = (s) => String(s).replace(/\s+/g, '');

describe('formula guide data', () => {
  it('explains every formula on every topic page, in the same order', () => {
    for (const t of allTopics()) {
      const guide = GUIDES[t.id] || [];
      expect(guide.map((g) => g.label), t.id).toEqual(t.formulas.map((f) => f.label));
    }
  });

  it('only explains symbols that are in the formula, and says when to use each one', () => {
    for (const f of allFormulas()) {
      expect(f.use, f.id).not.toBe('');
      expect(f.symbols.length, f.id).toBeGreaterThan(0);
      // Spreadsheet keys are set in \texttt; match the key itself.
      for (const s of f.symbols) expect(squash(f.latex), `${f.id}: ${s.tex}`).toContain(squash(s.tex.replace(/^\\texttt\{(.*)\}$/, '$1')));
    }
  });

  it('writes plain text where the page shows plain text', () => {
    for (const f of allFormulas()) {
      for (const text of [f.use, f.trap, ...f.symbols.flatMap((s) => [s.means, s.units])]) {
        expect(text || '', f.id).not.toMatch(/[$\\]|—/);
      }
    }
  });

  it('gives every formula its own link', () => {
    const ids = allFormulas().map((f) => f.id);
    expect(new Set(ids).size).toBe(ids.length);
  });
});

describe('formula finder page', () => {
  it('finds a formula by an apostrophe-free name and by what a symbol means', () => {
    const manning = allFormulas().find((f) => f.label === "Manning's Equation");
    expect(matches(manning, 'mannings')).toBe(true);
    expect(matches(manning, 'hydraulic radius')).toBe(true);
    expect(matches(manning, 'bearing capacity')).toBe(false);
  });

  it('narrows the list as you type and says when nothing matches', () => {
    mount();
    const all = document.querySelectorAll('.ff-entry').length;
    expect(all).toBe(allFormulas().length);
    const box = screen.getByRole('searchbox', { name: 'Search formulas' });
    fireEvent.change(box, { target: { value: 'manning' } });
    const some = document.querySelectorAll('.ff-entry').length;
    expect(some).toBeGreaterThan(0);
    expect(some).toBeLessThan(all);
    fireEvent.change(box, { target: { value: 'zzzz' } });
    expect(screen.getByText(/No formula matches/)).toBeInTheDocument();
  });

  it('is served prerendered to crawlers', () => {
    expect(PRERENDERED_ROUTE_PATTERN.test('/fe-civil/formulas')).toBe(true);
  });
});
