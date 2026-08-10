import { describe, it, expect } from 'vitest';
const { DESTS, CAMPUS_PLACEMENTS, resolveGoDest } = require('./goDests.js');

describe('resolveGoDest', () => {
  it('resolves the email and content codes that are already in print', () => {
    // These appear in emails already sent. Removing or renaming one breaks a
    // link in somebody's inbox, so they are asserted explicitly.
    expect(resolveGoDest('exam').url).toBe('/exam');
    expect(resolveGoDest('mitch').url).toBe('/stories/mitch');
    expect(resolveGoDest('digest').url).toBe('/exam-simulation');
  });

  it('returns null for an unknown code', () => {
    expect(resolveGoDest('nope')).toBeNull();
  });

  // The whole point of the allowlist. A caller must never be able to steer the
  // redirect, or /go becomes a way to borrow our domain for a phishing link.
  it('cannot be steered to an external URL', () => {
    for (const attempt of [
      'https://evil.example.com', '//evil.example.com', 'http:/evil.example.com',
      '..%2F..%2Fevil', '__proto__', 'constructor', 'toString', 'hasOwnProperty',
    ]) {
      expect(resolveGoDest(attempt)).toBeNull();
    }
  });

  it('ignores non-string input', () => {
    for (const bad of [undefined, null, 1, {}, []]) expect(resolveGoDest(bad)).toBeNull();
  });

  it('every destination is a site-relative path', () => {
    for (const [code, d] of Object.entries(DESTS)) {
      expect(d.url.startsWith('/'), `${code} must be site-relative`).toBe(true);
      expect(d.url.startsWith('//'), `${code} must not be protocol-relative`).toBe(false);
    }
  });
});

describe('campus placements', () => {
  it('tags every campus link with the campus medium', () => {
    // utm_medium=campus is the convention the attribution doc groups on. One
    // placement missing it would silently fall out of the channel's totals.
    for (const code of Object.keys(CAMPUS_PLACEMENTS)) {
      expect(resolveGoDest(code).url).toContain('utm_medium=campus');
    }
  });

  it('carries campus and placement through to the logged event', () => {
    const d = resolveGoDest('byub');
    expect(d.event).toBe('campus_scan');
    expect(d.meta).toEqual({ campus: 'byu', placement: 'board' });
  });

  it('distinguishes a seminar slide from a bulletin board on the same campus', () => {
    // If these collided we could not tell which placement earned a signup,
    // which is the only reason to print separate codes.
    const seminar = resolveGoDest('byu');
    const board = resolveGoDest('byub');
    expect(seminar.url).not.toBe(board.url);
    expect(seminar.meta.campus).toBe(board.meta.campus);
    expect(seminar.meta.placement).not.toBe(board.meta.placement);
  });

  it('lands campus scans on the home page, never on the paid product', () => {
    // A flyer promises a free platform. Dropping a cold scan onto the one paid
    // page would contradict the thing that earned the scan.
    for (const code of Object.keys(CAMPUS_PLACEMENTS)) {
      expect(resolveGoDest(code).url.startsWith('/?')).toBe(true);
    }
  });

  it('keeps codes short enough to print', () => {
    for (const code of Object.keys(CAMPUS_PLACEMENTS)) {
      expect(code.length, `${code} is too long for a projected QR`).toBeLessThanOrEqual(6);
      expect(code).toMatch(/^[a-z]+$/);
    }
  });
});
