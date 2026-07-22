const express = require('express');
const Stripe = require('stripe');
const DB = require('../database.js');
const { tierForCents } = require('../pricing.js');
const { sendSaleAlertEmail } = require('../email.js');

const router = express.Router();

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

// POST /api/webhook/stripe — Stripe webhook handler
// Note: This route must use express.raw() body parser, not express.json()
// The raw body is set up in index.js before the JSON middleware
router.post('/stripe', async (req, res) => {
  const sig = req.headers['stripe-signature'];

  let event;
  try {
    event = stripe.webhooks.constructEvent(
      req.body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    );
  } catch (err) {
    console.error(`Webhook signature verification failed: ${err.message}`);
    return res.status(400).send({ msg: `Webhook Error: ${err.message}` });
  }

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object;
    const userId = session.client_reference_id;

    if (!userId) {
      console.error('Webhook: checkout.session.completed missing client_reference_id');
      return res.status(200).send({ received: true });
    }

    // Prevent duplicate processing
    const existing = await DB.getPurchaseBySessionId(session.id);
    if (existing) {
      return res.status(200).send({ received: true });
    }

    await DB.recordPurchase(userId, {
      stripeSessionId: session.id,
      stripeCustomerId: session.customer,
      amount: session.amount_total,
      currency: session.currency,
      paymentStatus: session.payment_status,
      tier: session.metadata?.tier || tierForCents(session.amount_total),
      status: 'completed',
    });

    console.log(`Purchase recorded for user ${userId}, session ${session.id}`);

    // Owner sale alert (fire-and-forget; must never break the webhook response).
    (async () => {
      try {
        const summary = await DB.getSalesSummary();
        await sendSaleAlertEmail({
          buyerEmail: session.customer_details?.email || session.customer_email || null,
          amountCents: session.amount_total,
          tier: session.metadata?.tier || tierForCents(session.amount_total),
          totalSales: summary.count,
          totalRevenueCents: summary.revenueCents,
        });
      } catch (e) {
        console.error('[webhook] sale alert email failed:', e.message);
      }
    })();
  }

  res.status(200).send({ received: true });
});

module.exports = router;
