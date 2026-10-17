import { describe, it, expect } from 'vitest';
import { givenName } from './names.js';

describe('givenName', () => {
  it('is the first word of what was typed', () => {
    expect(givenName('Jerson Test')).toBe('Jerson');
    expect(givenName('  María   José ')).toBe('María');
    expect(givenName('Sam')).toBe('Sam');
    expect(givenName('')).toBe('');
    expect(givenName(null)).toBe('');
  });
});
