import { describe, it, expect, vi, beforeEach } from 'vitest';

// The owner's own alerts go to the company alias, so every FE for Raccoons
// email lands in one Oqupa account (owner, 2026-10-17), and a reply to a
// student's message goes to the student.
process.env.RESEND_API_KEY = process.env.RESEND_API_KEY || 're_test_dummy';
delete process.env.OWNER_ALERT_EMAIL;
const sent = [];
const email = require('./email.js');

beforeEach(() => {
  sent.length = 0;
  vi.spyOn(email.__resendForTests.emails, 'send').mockImplementation(async (p) => {
    sent.push(p);
    return { data: { id: 'x' } };
  });
});

describe('owner alerts', () => {
  it('a Contact us message goes to the company alias, replying to the sender', async () => {
    await email.sendContactAlertEmail({ email: 'sam@byu.edu', message: 'Hello\nthere', source: 'app', signedIn: true });
    const to = [].concat(sent[0].to);
    expect(to).toEqual(['fe4raccoons@oqupa.com']);
    expect([].concat(sent[0].replyTo ?? sent[0].reply_to)).toEqual(['sam@byu.edu']);
    expect(sent[0].html).toContain('Hello<br>there');
  });

  it('so do a sale and a flagged round', async () => {
    await email.sendSaleAlertEmail({ buyerEmail: 'b@x.com', amountCents: 2900, tier: 'student' });
    await email.sendFeedbackAlertEmail({ email: 's@x.com', gameId: 'g', chapterId: 'statics', kind: 'question', text: 'unclear' });
    for (const m of sent) expect([].concat(m.to)).toEqual(['fe4raccoons@oqupa.com']);
  });
});
