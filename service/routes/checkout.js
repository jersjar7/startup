const express = require('express');
const Stripe = require('stripe');
const rateLimit = require('express-rate-limit');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const {
  isStudentEmail, qualifiesForStudent, tierForCents, STUDENT_CENTS, STANDARD_CENTS,
} = require('../pricing.js');
const { generateNumericCode, hashToken } = require('../crypto.js');
const { daysUntilExam, examTimingFromMetadata } = require('../profile.js');
const { sendStudentCodeEmail } = require('../email.js');

const router = express.Router();

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

const STUDENT_CODE_TTL_MS = 15 * 60 * 1000; // 15 minutes
const STUDENT_CODE_MAX_ATTEMPTS = 5;
const STUDENT_CODE_FIELDS = ['studentCode', 'studentCodeEmail', 'studentCodeExpiry', 'studentCodeAttempts'];

// Limit how often a user can trigger a code email (prevents using us to
// email-bomb an academic address, and curbs abuse).
const studentStartLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  standardHeaders: true,
  legacyHeaders: false,
  message: { msg: 'Too many code requests. Please wait a few minutes and try again.' },
});

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

  // Server-authoritative, anti-fraud pricing: the student price applies ONLY to
  // a verified student (see qualifiesForStudent). A raw .edu typed at checkout
  // is no longer trusted — it must be verified via /student/confirm first.
  const freshUser = await DB.getUser(req.user.email);
  const isStudent = qualifiesForStudent(freshUser);
  const unitAmount = isStudent ? STUDENT_CENTS : STANDARD_CENTS;

  // How far out the exam is AT THE MOMENT OF PURCHASE. Nobody in test prep
  // publishes this, so it has to be captured here rather than derived later.
  //
  // Design notes, because each of these is a deliberate choice:
  //  - FROZEN at purchase time. Users edit their exam date afterwards, so
  //    recomputing later would silently rewrite history. examDateAtPurchase is
  //    stored alongside it so the number stays auditable.
  //  - Reuses daysUntilExam() from profile.js, the same helper the countdown
  //    emails use, so this figure matches what the user was actually shown.
  //  - null when no date is on file. Only ~24% of users have one, so most
  //    purchases will be null at first. That is honest, and "what share of
  //    buyers even set a date" is itself a useful number.
  //  - NEGATIVE values are kept, not clamped. A retaker carrying a stale past
  //    date is real signal, not corruption.
  const examDateAtPurchase = freshUser?.examDate || null;
  const daysLeft = daysUntilExam(examDateAtPurchase);

  // Stripe metadata values must be strings, and a key set to undefined is
  // dropped. Only attach these when known so absence stays distinguishable
  // from a genuine zero (exam day itself).
  const timingMetadata = {};
  if (daysLeft !== null) timingMetadata.daysUntilExam = String(daysLeft);
  if (examDateAtPurchase) timingMetadata.examDateAtPurchase = examDateAtPurchase;

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
    metadata: { tier: isStudent ? 'student' : 'standard', userId, ...timingMetadata },
  });

  // Funnel analytics: a checkout was initiated (for start->paid conversion).
  // The timing goes on this event too, not just the purchase record, so
  // ABANDONED checkouts carry it as well. That is the only way to ask whether
  // buyers close to their exam convert better than those still weeks out — a
  // purchases-only field can never answer it, because the people who did not
  // buy leave no purchase row.
  await DB.logEvent('checkout_started', req.user.email, {
    sessionId: session.id,
    daysUntilExam: daysLeft,
    examDateAtPurchase,
  });

  res.send({ url: session.url });
});

// GET /api/checkout/pricing — prices + this user's student eligibility (for UI).
router.get('/pricing', verifyAuth, async (req, res) => {
  const user = await DB.getUser(req.user.email);
  res.send({
    standard: STANDARD_CENTS / 100,
    student: STUDENT_CENTS / 100,
    applies: qualifiesForStudent(user),
    studentVerified: !!user?.studentVerified,
    verifiedStudentEmail: user?.verifiedStudentEmail || null,
    eligibleByAccount: isStudentEmail(user?.email) && user?.emailVerified === true,
  });
});

// POST /api/checkout/student/start — email a 6-digit code to a .edu address.
router.post('/student/start', studentStartLimiter, verifyAuth, async (req, res) => {
  const eduEmail = String(req.body?.eduEmail || '').trim().toLowerCase();
  if (!isStudentEmail(eduEmail)) {
    return res.status(400).send({ msg: 'Enter a valid academic email (e.g. you@university.edu).' });
  }

  const code = generateNumericCode(6);
  await DB.setUserFields(req.user.email, {
    studentCode: hashToken(code),
    studentCodeEmail: eduEmail,
    studentCodeExpiry: new Date(Date.now() + STUDENT_CODE_TTL_MS),
    studentCodeAttempts: 0,
  });

  const result = await sendStudentCodeEmail(eduEmail, code);
  if (!result.ok) {
    // Don't claim we sent it when we didn't. (Until a sending domain is verified
    // in Resend, this returns 503 with a clear, honest message.)
    return res.status(503).send({
      msg: 'We could not send the code right now. Student verification is being set up — please try again shortly, or continue at the standard price.',
    });
  }
  res.send({ sent: true, to: eduEmail });
});

// POST /api/checkout/student/confirm — verify the code, unlock the discount.
router.post('/student/confirm', verifyAuth, async (req, res) => {
  const code = String(req.body?.code || '').trim();
  const user = await DB.getUser(req.user.email);

  if (!user?.studentCode || !user?.studentCodeExpiry) {
    return res.status(400).send({ msg: 'Request a verification code first.' });
  }
  if (new Date(user.studentCodeExpiry).getTime() < Date.now()) {
    await DB.unsetUserFields(user.email, STUDENT_CODE_FIELDS);
    return res.status(400).send({ msg: 'That code expired. Request a new one.' });
  }
  if ((user.studentCodeAttempts || 0) >= STUDENT_CODE_MAX_ATTEMPTS) {
    await DB.unsetUserFields(user.email, STUDENT_CODE_FIELDS);
    return res.status(429).send({ msg: 'Too many incorrect attempts. Request a new code.' });
  }
  if (hashToken(code) !== user.studentCode) {
    await DB.setUserFields(user.email, { studentCodeAttempts: (user.studentCodeAttempts || 0) + 1 });
    return res.status(400).send({ msg: 'Incorrect code. Check the email and try again.' });
  }

  await DB.setUserFields(user.email, {
    studentVerified: true,
    verifiedStudentEmail: user.studentCodeEmail,
    studentVerifiedAt: new Date(),
  });
  await DB.unsetUserFields(user.email, STUDENT_CODE_FIELDS);
  res.send({ verified: true, student: STUDENT_CENTS / 100 });
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
        // Same frozen timing the webhook records, so a webhook miss does not
        // silently drop the field on that purchase.
        await DB.recordPurchase(userId, {
          stripeSessionId: session.id,
          amount: session.amount_total,
          currency: session.currency,
          tier: session.metadata?.tier || tierForCents(session.amount_total),
          status: 'completed',
          ...examTimingFromMetadata(session.metadata),
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

// POST /api/checkout/sim-banner/:action — track the on-site exam-sim banner.
// action = 'shown' | 'click'. Logged to funnel events so the admin pitch-stats
// can compare the on-site banner against the countdown-email pitch.
router.post('/sim-banner/:action', verifyAuth, async (req, res) => {
  const type = req.params.action === 'click' ? 'sim_banner_click' : 'sim_banner_shown';
  try {
    await DB.logEvent(type, req.user.email, { via: 'dashboard' });
  } catch (e) {
    console.error('[checkout] sim-banner track failed:', e.message);
  }
  res.send({ ok: true });
});

module.exports = router;
