import { describe, it, expect } from 'vitest';
import { shouldRetrySave } from './retrySave';

describe('shouldRetrySave', () => {
  it('retries when the server failed to store the answers', () => {
    for (const s of [500, 502, 503, 504]) expect(shouldRetrySave(s), String(s)).toBe(true);
  });

  it('retries a timeout or a rate limit', () => {
    expect(shouldRetrySave(408)).toBe(true);
    expect(shouldRetrySave(429)).toBe(true);
  });

  it('does not resend a save that worked or can never work', () => {
    for (const s of [200, 204, 400, 401, 403, 404]) expect(shouldRetrySave(s), String(s)).toBe(false);
  });
});
