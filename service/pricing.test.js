import { describe, it, expect } from 'vitest';
const { isStudentEmail, priceCentsForEmail, STUDENT_CENTS, STANDARD_CENTS } = require('./pricing');

describe('isStudentEmail', () => {
  it('accepts .edu and common academic domains', () => {
    expect(isStudentEmail('a@stanford.edu')).toBe(true);
    expect(isStudentEmail('a@student.byu.edu')).toBe(true);
    expect(isStudentEmail('a@ox.ac.uk')).toBe(true);
    expect(isStudentEmail('a@uni.edu.au')).toBe(true);
  });
  it('rejects non-academic and malformed', () => {
    expect(isStudentEmail('a@gmail.com')).toBe(false);
    expect(isStudentEmail('a@edu.com')).toBe(false); // .edu not the TLD
    expect(isStudentEmail('')).toBe(false);
    expect(isStudentEmail(null)).toBe(false);
  });
});

describe('priceCentsForEmail', () => {
  it('charges the student price for academic emails', () => {
    expect(priceCentsForEmail('a@mit.edu')).toBe(STUDENT_CENTS);
  });
  it('charges the standard price otherwise', () => {
    expect(priceCentsForEmail('a@gmail.com')).toBe(STANDARD_CENTS);
  });
});
