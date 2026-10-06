import { describe, it, expect } from 'vitest';
import {
  PASS_CARD_CHAPTERS,
  TOTAL_QUESTIONS,
  CARD,
  passCardData,
  passCardFilename,
} from './passCard.js';

// The card is the one thing a student publishes under their own name, so the
// rules here are about what it is allowed to claim. Two of them exist because
// the alternative was caught before it shipped: it must never invent a name,
// and it must never print a per-chapter question count, because ours are from
// the retired 2014 specification.

describe('what the card is allowed to say', () => {
  it('lists the fifteen chapters and nothing numeric per chapter', () => {
    expect(PASS_CARD_CHAPTERS).toHaveLength(15);
    for (const name of PASS_CARD_CHAPTERS) {
      expect(name).not.toMatch(/\d/);
    }
  });

  it('prints only the total, which both our sources agree on', () => {
    expect(TOTAL_QUESTIONS).toBe(110);
  });

  it('carries no per-person figures at all', () => {
    const d = passCardData({ firstName: 'Jerson', lastName: 'Garcia' });
    // If this ever grows a coverage/score/mastery field, the card stops being
    // safe to render from a tokenised email link without a sign in.
    expect(Object.keys(d).sort()).toEqual(
      ['chapters', 'discipline', 'hasName', 'name', 'result', 'totalQuestions', 'when'].sort(),
    );
  });
});

describe('the name', () => {
  it('appends EIT so nobody has to know the abbreviation', () => {
    expect(passCardData({ firstName: 'Jerson', lastName: 'Garcia' }).name)
      .toBe('Jerson Garcia, EIT');
  });

  it('takes a first name alone', () => {
    const d = passCardData({ firstName: 'Jerson' });
    expect(d.name).toBe('Jerson, EIT');
    expect(d.hasName).toBe(true);
  });

  it('says it has none rather than inventing one', () => {
    // Account creation has never collected a name, so this is the common case,
    // not an edge case. The caller has to ask before drawing.
    const d = passCardData({});
    expect(d.name).toBeNull();
    expect(d.hasName).toBe(false);
  });

  it('never falls back to the email address', () => {
    const d = passCardData({ firstName: null, lastName: null });
    expect(d.name).toBeNull();
    expect(JSON.stringify(d)).not.toMatch(/@/);
  });

  it('ignores whitespace that is not a name', () => {
    expect(passCardData({ firstName: '  ', lastName: '' }).hasName).toBe(false);
  });
});

describe('the date', () => {
  it('reads as a month and year, never a precise day', () => {
    const d = passCardData({ answeredAt: '2026-10-20T10:00:00Z' });
    expect(d.when).toBe('October 2026');
  });

  it('falls back to now when the answer carries no timestamp', () => {
    expect(passCardData({ now: new Date('2026-04-02T12:00:00Z') }).when).toBe('April 2026');
  });
});

describe('geometry both renderers share', () => {
  it('is the link preview ratio the social networks crop to', () => {
    expect(CARD.width / CARD.height).toBeCloseTo(1.91, 2);
  });

  it('exports at 2x so it survives a retina timeline', () => {
    expect(CARD.width * CARD.exportScale).toBe(2400);
  });

  it('leaves the fifteen rows inside the title block', () => {
    const lastRow = CARD.index.top + 14 * CARD.index.rowHeight;
    const titleRule = CARD.height - CARD.titleBlock.fromBottom;
    expect(lastRow).toBeLessThan(titleRule);
  });
});

describe('the file they end up with', () => {
  it('is named after them, so it is findable in a downloads folder', () => {
    const d = passCardData({ firstName: 'Jerson', lastName: 'Garcia' });
    expect(passCardFilename(d)).toBe('Jerson-Garcia-EIT-FE-Civil-passed.png');
  });

  it('still has a sensible name when they have none', () => {
    expect(passCardFilename(passCardData({}))).toBe('FE-Civil-passed.png');
  });
});
