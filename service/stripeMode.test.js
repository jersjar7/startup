import { describe, it, expect } from 'vitest';
const { serverIsLiveMode, isModeMismatch, describeMode } = require('./stripeMode.js');

const LIVE = 'sk_live_abc123';
const TEST = 'sk_test_abc123';

// This guard exists because production ran on a test key for ~12 days, granted a
// real student the full paid product for $0, and reported it as a sale. Nothing
// checked livemode. These tests pin the behaviour that would have caught it.
describe('serverIsLiveMode', () => {
  it('detects live and test keys', () => {
    expect(serverIsLiveMode(LIVE)).toBe(true);
    expect(serverIsLiveMode(TEST)).toBe(false);
  });

  it('treats a missing or malformed key as not live', () => {
    expect(serverIsLiveMode(undefined)).toBe(false);
    expect(serverIsLiveMode('')).toBe(false);
    expect(serverIsLiveMode('rk_live_restricted')).toBe(false);
  });
});

describe('isModeMismatch', () => {
  it('BLOCKS a test-mode payment on a live server — the actual incident', () => {
    expect(isModeMismatch({ livemode: false }, LIVE)).toBe(true);
  });

  it('blocks a live-mode payment on a test server', () => {
    expect(isModeMismatch({ livemode: true }, TEST)).toBe(true);
  });

  it('allows a matching pair, so live prod and local dev both keep working', () => {
    expect(isModeMismatch({ livemode: true }, LIVE)).toBe(false);
    expect(isModeMismatch({ livemode: false }, TEST)).toBe(false);
  });

  it('does not block when livemode is absent', () => {
    // Older records and hand-built test fixtures have no livemode field. This
    // guard must never reject a legitimate purchase over a schema gap.
    expect(isModeMismatch({}, LIVE)).toBe(false);
    expect(isModeMismatch({ livemode: undefined }, LIVE)).toBe(false);
    expect(isModeMismatch({ livemode: 'true' }, LIVE)).toBe(false); // not a boolean
    expect(isModeMismatch(null, LIVE)).toBe(false);
  });
});

describe('describeMode', () => {
  it('names the mode for logs and admin surfaces', () => {
    expect(describeMode(LIVE)).toBe('live');
    expect(describeMode(TEST)).toBe('test');
    expect(describeMode(undefined)).toBe('unset');
  });
});
