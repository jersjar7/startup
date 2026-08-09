import { describe, it, expect } from 'vitest';
const { isStudentEmail, priceCentsForEmail, tierForCents, STUDENT_CENTS, STANDARD_CENTS } = require('./pricing');
const { STUDENT_PRICE, STANDARD_PRICE } = require('../src/data/pricing.js');

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

// The server charges cents; every page, email and JSON-LD renders dollars from
// src/data/pricing.js. Nothing at runtime connects the two, so a price change
// that updates one and not the other advertises a figure the checkout will not
// charge. That is the single worst pricing bug available to us, and this is the
// only thing that catches it.
describe('display prices match the authoritative amounts', () => {
  it('student dollars equal student cents', () => {
    expect(STUDENT_PRICE * 100).toBe(STUDENT_CENTS);
  });
  it('standard dollars equal standard cents', () => {
    expect(STANDARD_PRICE * 100).toBe(STANDARD_CENTS);
  });
});

describe('tierForCents', () => {
  it('maps the current prices', () => {
    expect(tierForCents(STUDENT_CENTS)).toBe('student');
    expect(tierForCents(STANDARD_CENTS)).toBe('standard');
  });

  // Raising the student price must not reclassify sales already made at the old
  // one. Every historical amount keeps reporting the tier it was sold at, or
  // the admin revenue breakdown loses rows the moment a price moves.
  it('still recognises the retired $29 student price', () => {
    expect(tierForCents(2900)).toBe('student');
  });

  it('returns unknown for an amount we never charged', () => {
    expect(tierForCents(1234)).toBe('unknown');
    expect(tierForCents(0)).toBe('unknown');
  });
});
