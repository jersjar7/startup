const express = require('express');
const Stripe = require('stripe');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');

const router = express.Router();

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

// POST /api/checkout/create-session — Create Stripe Checkout Session
router.post('/create-session', verifyAuth, async (req, res) => {
  const userId = req.user._id.toString();

  // Check if already purchased
  const alreadyPurchased = await DB.hasPurchased(userId);
  if (alreadyPurchased) {
    return res.status(400).send({ msg: 'You already own the Exam Simulation' });
  }

  // Use Referer/Origin so Stripe redirects back to the frontend (not the API server)
  const referer = req.get('referer') || req.get('origin') || '';
  const origin = referer ? new URL(referer).origin : `${req.protocol}://${req.get('host')}`;

  const session = await stripe.checkout.sessions.create({
    mode: 'payment',
    line_items: [
      {
        price: process.env.STRIPE_PRICE_ID,
        quantity: 1,
      },
    ],
    client_reference_id: userId,
    customer_email: req.user.email,
    success_url: `${origin}/exam?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${origin}/exam`,
    allow_promotion_codes: true,
  });

  res.send({ url: session.url });
});

// GET /api/checkout/status — Check purchase status for current user
router.get('/status', verifyAuth, async (req, res) => {
  const userId = req.user._id.toString();
  let purchased = await DB.hasPurchased(userId);

  // If not in DB but a session_id is provided, verify directly with Stripe
  // This handles the case where the webhook hasn't fired yet (e.g., local dev)
  if (!purchased && req.query.session_id) {
    try {
      const session = await stripe.checkout.sessions.retrieve(req.query.session_id);
      if (session.payment_status === 'paid' && session.client_reference_id === userId) {
        await DB.recordPurchase(userId, {
          stripeSessionId: session.id,
          amount: session.amount_total,
          currency: session.currency,
          status: 'completed',
        });
        purchased = true;
      }
    } catch (e) {
      console.error('[checkout/status] Stripe verification failed:', e.message);
    }
  }

  const result = { purchased };
  if (purchased) {
    result.purchaseDate = req.user.examSimPurchaseDate || null;
  }

  res.send(result);
});

module.exports = router;
