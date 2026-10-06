import { describe, it, expect, vi } from 'vitest';
import { drawPassCard } from './drawPassCard.js';
import { passCardData, CARD } from '../../data/passCard.js';

// Canvas drawing is hard to assert on pixels, so this records the calls instead.
// What matters is not how it looks here but what it is allowed to put on the
// card: never an email address, never a placeholder name, and never a number
// against a chapter.

function recordingCanvas(width = CARD.width, height = CARD.height) {
  const calls = { text: [], fonts: [] };
  const ctx = {
    save: vi.fn(), restore: vi.fn(), scale: vi.fn(), clearRect: vi.fn(),
    fillRect: vi.fn(), beginPath: vi.fn(), moveTo: vi.fn(), lineTo: vi.fn(),
    stroke: vi.fn(), fill: vi.fn(), arcTo: vi.fn(), roundRect: vi.fn(),
    measureText: () => ({ width: 7 }),
    fillText: (t, x, y) => calls.text.push({ t: String(t), x, y }),
    set font(v) { calls.fonts.push(v); },
    get font() { return calls.fonts.at(-1); },
    fillStyle: '', strokeStyle: '', lineWidth: 1, textAlign: '', textBaseline: '',
  };
  return { canvas: { width, height, getContext: () => ctx }, calls };
}

/// fillText is called per character for tracked labels, so join it back up.
const drawn = (calls) => calls.text.map((c) => c.t).join('');

describe('what reaches the canvas', () => {
  const data = passCardData({ firstName: 'Jerson', lastName: 'Garcia', answeredAt: '2026-10-20' });

  it('draws the claim, the name and the title block', () => {
    const { canvas, calls } = recordingCanvas();
    drawPassCard(canvas, data);
    const all = drawn(calls);
    expect(all).toContain('FE Civil');
    expect(all).toContain('passed.');
    expect(all).toContain('Jerson Garcia, EIT');
    expect(all).toContain('Civil Engineering');
    expect(all).toContain('October 2026');
    expect(all).toContain('FE4RACCOONS');
  });

  it('lists all fifteen chapters, numbered', () => {
    const { canvas, calls } = recordingCanvas();
    drawPassCard(canvas, data);
    const all = drawn(calls);
    for (const name of data.chapters) expect(all).toContain(name);
    expect(all).toContain('01');
    expect(all).toContain('15');
  });

  it('prints no per-chapter count, because ours are from a retired spec', () => {
    const { canvas, calls } = recordingCanvas();
    drawPassCard(canvas, data);
    // The only digits allowed are the row numbers 01-15, the total, and the year.
    const stray = calls.text
      .map((c) => c.t)
      .filter((t) => /^\d+-\d+$/.test(t));
    expect(stray).toEqual([]);
    expect(drawn(calls)).toContain('110 QUESTIONS');
  });
});

describe('the name is never faked', () => {
  it('draws no name at all rather than a placeholder', () => {
    const { canvas, calls } = recordingCanvas();
    drawPassCard(canvas, passCardData({}));
    const all = drawn(calls);
    expect(all).toContain('FE Civil');
    expect(all).not.toMatch(/EIT/);
    expect(all).not.toMatch(/name/i);
  });

  it('never puts an email address on something they will publish', () => {
    const { canvas, calls } = recordingCanvas();
    drawPassCard(canvas, { ...passCardData({}), email: 'a@b.com' });
    expect(drawn(calls)).not.toContain('@');
  });
});

describe('scaling', () => {
  it('scales the design to the canvas, so one function paints both sizes', () => {
    const big = recordingCanvas(CARD.width * 2, CARD.height * 2);
    drawPassCard(big.canvas, passCardData({ firstName: 'A' }));
    const small = recordingCanvas(300, 157);
    drawPassCard(small.canvas, passCardData({ firstName: 'A' }));
    // Same words at both sizes: nothing is dropped or added for a thumbnail.
    expect(drawn(big.calls)).toBe(drawn(small.calls));
  });

  it('survives a context with no roundRect', () => {
    const { canvas } = recordingCanvas();
    const ctx = canvas.getContext();
    delete ctx.roundRect;
    expect(() => drawPassCard(canvas, passCardData({ firstName: 'A' }))).not.toThrow();
  });

  it('does nothing rather than throwing when there is no data', () => {
    const { canvas } = recordingCanvas();
    expect(() => drawPassCard(canvas, null)).not.toThrow();
  });
});
