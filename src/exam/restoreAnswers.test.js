import { describe, it, expect } from 'vitest';
import { restoreAnswers } from './restoreAnswers';

describe('restoreAnswers', () => {
  it('lays a newer local choice over the server\'s', () => {
    const r = restoreAnswers({ q1: 'a' }, { q1: 100 }, { userAnswers: { q1: 'b' }, answerTimes: { q1: 200 } });
    expect(r.answers.q1).toBe('b');
    expect(r.times.q1).toBe(200);
  });

  it('keeps the server\'s answer when another tab saved it later', () => {
    const r = restoreAnswers({ q1: 'a' }, { q1: 300 }, { userAnswers: { q1: 'b' }, answerTimes: { q1: 200 } });
    expect(r.answers.q1).toBe('a');
  });

  it('a local copy from before stamps is laid over as before, unless the server\'s is stamped', () => {
    expect(restoreAnswers({ q1: 'a' }, {}, { userAnswers: { q1: 'b', q2: 'c' } }).answers).toEqual({ q1: 'b', q2: 'c' });
    expect(restoreAnswers({ q1: 'a' }, { q1: 100 }, { userAnswers: { q1: 'b' } }).answers).toEqual({ q1: 'a' });
  });

  it('with no local copy it is the server\'s answers', () => {
    expect(restoreAnswers({ q1: 'a' }, {}, null).answers).toEqual({ q1: 'a' });
    expect(restoreAnswers(undefined, undefined, null).answers).toEqual({});
  });
});
