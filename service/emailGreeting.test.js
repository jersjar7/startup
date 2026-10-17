import { describe, it, expect, vi, beforeEach } from 'vitest';

// The greeting emails say the given name only (owner, 2026-10-16): sign-up
// asks "What should we call you?" in one field and people type a whole name
// into it, so "Jerson Test" must read "Hey Jerson", never "Hey Jerson Test".
// Drives the real email code with the sending client replaced, and reads
// what it would have sent.
process.env.RESEND_API_KEY = process.env.RESEND_API_KEY || 're_test_dummy';
const sent = [];
const email = require('./email.js');

beforeEach(() => {
  sent.length = 0;
  vi.spyOn(email.__resendForTests.emails, 'send').mockImplementation(async (p) => {
    sent.push(p);
    return { data: { id: 'x' } };
  });
});

describe('greeting emails', () => {
  it('the countdown note says the given name', async () => {
    await email.sendExamCountdownEmail('a@x.com', { daysLeft: 14, unsubUrl: 'u', simPitch: true, firstName: 'Jerson Test' });
    expect(sent[0].subject).toBe("Hey Jerson, it's Jerson");
    expect(sent[0].text || sent[0].html).not.toContain('Jerson Test');
  });

  it('the follow-up says the given name', async () => {
    await email.sendSimPitchFollowupEmail('a@x.com', { unsubUrl: 'u', firstName: 'Ana María Ruiz' });
    expect(sent[0].subject).toBe("Hey Ana, it's Jerson again");
  });

  it('the outcome ask says the given name', async () => {
    await email.sendExamOutcomeEmail('a@x.com', { unsubUrl: 'u', firstName: 'Sam Reyes', outcomeToken: 't' });
    const body = sent[0].text || sent[0].html;
    expect(body).toContain('Sam, how');
    expect(body).not.toContain('Sam Reyes');
  });

  it('and nothing when there is no name', async () => {
    await email.sendExamCountdownEmail('a@x.com', { daysLeft: 14, unsubUrl: 'u', simPitch: true });
    expect(sent[0].subject).toBe("Hey, it's Jerson");
  });
});
