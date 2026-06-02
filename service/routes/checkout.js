const express = require('express');
const Stripe = require('stripe');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const { isStudentEmail, STUDENT_CENTS, STANDARD_CENTS } = require('../pricing.js');

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

  // Tiered, server-authoritative pricing: students pay less. The student price
  // applies if the ACCOUNT email is academic, or the buyer supplies a .edu
  // email at checkout (trust-based — it's a goodwill discount, not a gate).
  // Inline price_data avoids managing Stripe Price objects.
  const studentEmail = typeof req.body?.studentEmail === 'string' ? req.body.studentEmail : '';
  const isStudent = isStudentEmail(req.user.email) || isStudentEmail(studentEmail);
  const unitAmount = isStudent ? STUDENT_CENTS : STANDARD_CENTS;

  const session = await stripe.checkout.sessions.create({
    mode: 'payment',
    line_items: [
      {
        price_data: {
          currency: 'usd',
          unit_amount: unitAmount,
          product_data: { name: 'FE for Raccoons — Exam Simulation (full access)' },
        },
        quantity: 1,
      },
    ],
    client_reference_id: userId,
    customer_email: req.user.email,
    success_url: `${origin}/exam?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${origin}/exam`,
    allow_promotion_codes: true,
  });

  // Funnel analytics: a checkout was initiated (for start->paid conversion).
  await DB.logEvent('checkout_started', req.user.email, { sessionId: session.id });

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
