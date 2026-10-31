import { describe, it, expect, beforeEach } from 'vitest';

process.env.STRIPE_SECRET_KEY = 'sk_test_reversals';
process.env.STRIPE_WEBHOOK_SECRET = 'whsec_reversals';
process.env.RESEND_API_KEY = process.env.RESEND_API_KEY || 're_test_dummy';

const express = require('express');
const request = require('supertest');
const Stripe = require('stripe');
const DB = require('./database.js');
const { readReversal, planReversal } = require('./stripeReversals.js');
const webhook = require('./routes/webhook.js');
const checkout = require('./routes/checkout.js');

// Refunds and disputes arrive from Stripe and change who has the Exam
// Simulation (ADR 0036). The owner's rules: a full refund or an opened dispute
// takes it away, a partial refund does not, a won dispute gives it back.

const signer = new Stripe('sk_test_reversals');
const USER = '64b000000000000000000001';

let purchases;
let users;
let lookups;

beforeEach(() => {
  purchases = [{ _id: 'p1', userId: USER, stripeSessionId: 'cs_1', status: 'completed', amount: 4900 }];
  users = { [USER]: { examSimAccess: true } };
  lookups = 0;
  Object.assign(DB, {
    getPurchaseBySessionId: async (id) => purchases.find((p) => p.stripeSessionId === id) || null,
    // Same status guard as the real write.
    applyPurchaseReversal: async (purchase, plan) => {
      const row = purchases.find((p) => p._id === purchase._id && p.status === purchase.status);
      if (!row) return false;
      Object.assign(row, plan.purchase.$set);
      if (plan.user) Object.assign(users[row.userId], plan.user.$set);
      return true;
    },
    hasPurchased: async (userId) => purchases.some((p) => p.userId === userId && p.status === 'completed'),
    recordPurchase: async (userId, p) => { purchases.push({ _id: `p${purchases.length + 1}`, userId, ...p }); },
    getSessionByToken: async (token) => (token === 'tok' ? { email: 'buyer@x.com', lastSeen: new Date() } : null),
    getUser: async () => ({ _id: { toString: () => USER }, email: 'buyer@x.com' }),
    touchSession: async () => {},
  });
  webhook.stripe.checkout.sessions.list = async ({ payment_intent }) => {
    lookups += 1;
    return { data: payment_intent === 'pi_1' ? [{ id: 'cs_1' }] : [] };
  };
  checkout.stripe.checkout.sessions.retrieve = async (id) => ({
    id, payment_status: 'paid', client_reference_id: USER, amount_total: 4900, currency: 'usd', metadata: {},
  });
});

function app() {
  const a = express();
  a.use('/api/webhook', express.raw({ type: 'application/json' }), webhook);
  a.use(express.json());
  a.use(require('cookie-parser')());
  a.use('/api/checkout', checkout);
  return a;
}

function send(type, object, extra = {}) {
  const payload = JSON.stringify({ id: 'evt_1', type, livemode: false, data: { object }, ...extra });
  const header = signer.webhooks.generateTestHeaderString({ payload, secret: 'whsec_reversals' });
  return request(app()).post('/api/webhook/stripe')
    .set('stripe-signature', header).set('content-type', 'application/json').send(payload);
}

const refund = (refunded) => send('charge.refunded', { payment_intent: 'pi_1', refunded, livemode: false });

describe('readReversal', () => {
  it('reads a full and a partial refund apart', () => {
    expect(readReversal({ type: 'charge.refunded', data: { object: { payment_intent: 'pi', refunded: true } } }).kind).toBe('refund');
    expect(readReversal({ type: 'charge.refunded', data: { object: { payment_intent: 'pi', refunded: false } } }).kind).toBe('partial-refund');
  });

  it('counts an inquiry that closed without a chargeback as ours', () => {
    expect(readReversal({ type: 'charge.dispute.closed', data: { object: { status: 'warning_closed' } } }).kind).toBe('dispute-won');
    expect(readReversal({ type: 'charge.dispute.closed', data: { object: { status: 'lost' } } }).kind).toBe('dispute-lost');
  });

  it('ignores every other event', () => {
    expect(readReversal({ type: 'checkout.session.completed', data: { object: {} } })).toBeNull();
  });
});

describe('planReversal', () => {
  it('never restores a refunded purchase when a dispute closes', () => {
    expect(planReversal({ kind: 'dispute-won' }, { status: 'refunded' })).toBeNull();
  });

  it('lets a refund settle a purchase that is under dispute', () => {
    expect(planReversal({ kind: 'refund' }, { status: 'disputed' }).purchase.$set.status).toBe('refunded');
  });
});

describe('POST /api/webhook/stripe, refunds and disputes', () => {
  it('a full refund takes the simulation away and drops the sale', async () => {
    const res = await refund(true);
    expect(res.status).toBe(200);
    expect(purchases[0].status).toBe('refunded');
    expect(users[USER].examSimAccess).toBe(false);
  });

  it('a partial refund keeps the simulation and never asks Stripe', async () => {
    await refund(false);
    expect(purchases[0].status).toBe('completed');
    expect(users[USER].examSimAccess).toBe(true);
    expect(lookups).toBe(0);
  });

  it('the same refund delivered twice writes once', async () => {
    await refund(true);
    const at = purchases[0].refundedAt;
    await refund(true);
    expect(purchases[0].refundedAt).toBe(at);
  });

  it('an opened dispute takes it away, a won one gives it back', async () => {
    await send('charge.dispute.created', { payment_intent: 'pi_1', reason: 'fraudulent' });
    expect(purchases[0].status).toBe('disputed');
    expect(users[USER].examSimAccess).toBe(false);

    await send('charge.dispute.closed', { payment_intent: 'pi_1', status: 'won' });
    expect(purchases[0].status).toBe('completed');
    expect(users[USER].examSimAccess).toBe(true);
  });

  it('a lost dispute stays revoked', async () => {
    await send('charge.dispute.created', { payment_intent: 'pi_1' });
    await send('charge.dispute.closed', { payment_intent: 'pi_1', status: 'lost' });
    expect(purchases[0]).toMatchObject({ status: 'disputed', disputeOutcome: 'lost' });
    expect(users[USER].examSimAccess).toBe(false);
  });

  it('a refund on a payment that was not a checkout changes nothing', async () => {
    const res = await send('charge.refunded', { payment_intent: 'pi_other', refunded: true });
    expect(res.status).toBe(200);
    expect(purchases[0].status).toBe('completed');
  });

  it('a live refund reaching a test-key server is ignored', async () => {
    const res = await send('charge.refunded', { payment_intent: 'pi_1', refunded: true }, { livemode: true });
    expect(res.body.ignored).toBe('livemode-mismatch');
    expect(purchases[0].status).toBe('completed');
  });

  it('a failed lookup answers 500 so Stripe sends it again', async () => {
    webhook.stripe.checkout.sessions.list = async () => { throw new Error('Stripe down'); };
    const res = await refund(true);
    expect(res.status).toBe(500);
    expect(purchases[0].status).toBe('completed');
  });

  it('rejects an unsigned event', async () => {
    const res = await request(app()).post('/api/webhook/stripe')
      .set('content-type', 'application/json').send('{"type":"charge.refunded"}');
    expect(res.status).toBe(400);
  });
});

describe('GET /api/checkout/status after a refund', () => {
  it('the old return link does not give the simulation back', async () => {
    await refund(true);
    const res = await request(app()).get('/api/checkout/status?session_id=cs_1').set('Cookie', 'token=tok');
    expect(res.body.purchased).toBe(false);
    expect(purchases).toHaveLength(1);
  });

  it('still records a paid checkout the webhook has not delivered yet', async () => {
    purchases = [];
    const res = await request(app()).get('/api/checkout/status?session_id=cs_new').set('Cookie', 'token=tok');
    expect(res.body.purchased).toBe(true);
    expect(purchases[0]).toMatchObject({ stripeSessionId: 'cs_new', status: 'completed' });
  });
});
