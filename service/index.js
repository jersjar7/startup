require('dotenv').config();
require('express-async-errors');
const fs = require('fs');
const path = require('path');
const express = require('express');
const helmet = require('helmet');
const compression = require('compression');
const cookieParser = require('cookie-parser');
const rateLimit = require('express-rate-limit');
const { peerProxy } = require('./peerProxy.js');
const { requestLogger } = require('./middleware/logger.js');

const app = express();

// Behind Caddy (a single reverse proxy on the same host). Trust the first hop
// so req.ip / X-Forwarded-For resolve to the real client — without this,
// express-rate-limit keys every user to the proxy's IP (one shared bucket) and
// warns about an X-Forwarded-For misconfiguration.
app.set('trust proxy', 1);

// Security, compression, and parsing middleware.
// CSP: helmet's defaults are script-src 'self' only, which blocks the Plausible
// tag (script) AND its event beacon (connect, which falls back to default-src).
// Allow plausible.io on exactly those two directives and leave the rest strict.
// The init snippet lives in public/plausible-init.js rather than inline so we
// never need 'unsafe-inline' or a hash that breaks on every edit.
const PLAUSIBLE = 'https://plausible.io';
app.use(
  helmet({
    contentSecurityPolicy: {
      useDefaults: true,
      directives: {
        'script-src': ["'self'", PLAUSIBLE],
        'connect-src': ["'self'", PLAUSIBLE],
      },
    },
  }),
);
app.use(compression());

// Say the payment mode out loud at boot. Production silently ran on a Stripe
// TEST key for ~12 days and collected nothing, with no signal anywhere. A single
// unmissable log line is the cheapest possible tripwire.
{
  const { describeMode, serverIsLiveMode } = require('./stripeMode.js');
  if (serverIsLiveMode()) {
    console.log('[stripe] mode: LIVE - real cards will be charged');
  } else {
    console.warn(
      `[stripe] mode: ${describeMode().toUpperCase()} - NO real money will be collected. `
      + 'If this is production, checkout is broken. Payments made in the other mode '
      + 'are now refused rather than silently granting free access.',
    );
  }
}

// Stripe webhook needs raw body for signature verification — mount BEFORE express.json()
app.use('/api/webhook', express.raw({ type: 'application/json' }), require('./routes/webhook.js'));

app.use(express.json({ limit: '1mb' }));
app.use(cookieParser());
app.use(requestLogger);

// Global rate limit per IP. Generous because the SPA makes several read
// requests per navigation; skips static assets and the cheap auth-check poll
// so normal usage (incl. shared NAT) doesn't trip it.
app.use(rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 600,
  standardHeaders: true,
  legacyHeaders: false,
  skip: (req) => /\.(js|css|ico|png|svg|woff2?)$/.test(req.path) || req.path === '/api/user/me',
  message: { msg: 'Too many requests, try again later' },
}));

// Prerendered public pages: serve the build-time HTML (full content + JSON-LD
// for crawlers / AI bots). Must run BEFORE express.static, which would otherwise
// 301-redirect these directory paths to a trailing slash. Falls through to the
// SPA if the prerendered file is missing.
app.get(/^\/(fe-civil-exam-guide|fe-civil\/[a-z-]+)\/?$/, (req, res, next) => {
  const file = path.resolve('public', req.path.replace(/^\/|\/$/g, ''), 'index.html');
  fs.access(file, fs.constants.F_OK, (err) => {
    if (err) return next();
    res.set('Cache-Control', 'no-cache');
    res.sendFile(file);
  });
});

// Serve static assets with long-term caching (hashed filenames)
app.use(express.static('public', { maxAge: '1y', immutable: true, index: false }));

// Serve index.html with no-cache so browsers always get the latest version
app.get('/', (_req, res) => {
  res.set('Cache-Control', 'no-cache');
  res.sendFile('index.html', { root: 'public' });
});

// API routes
const apiRouter = express.Router();
app.use('/api', apiRouter);

// Auth rate limit: counts only FAILED attempts, so brute-forcing is throttled
// but legitimate signups/logins (incl. many users behind one IP) aren't locked out.
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 30,
  skipSuccessfulRequests: true,
  standardHeaders: true,
  legacyHeaders: false,
  message: { msg: 'Too many attempts, try again later' },
});
apiRouter.use('/auth', authLimiter, require('./routes/auth.js'));

apiRouter.use('/', require('./routes/health.js'));
apiRouter.use('/user', require('./routes/auth.js'));
apiRouter.use('/sessions', require('./routes/sessions.js'));
apiRouter.use('/review', require('./routes/review.js'));
apiRouter.use('/content', require('./routes/content.js'));
apiRouter.use('/sync', require('./routes/sync.js'));
apiRouter.use('/leaderboard', require('./routes/leaderboard.js'));
apiRouter.use('/diagnostic', require('./routes/diagnostic.js'));
apiRouter.use('/quickstart', require('./routes/quickstart.js'));
apiRouter.use('/checkout', require('./routes/checkout.js'));
apiRouter.use('/exam', require('./routes/exam.js'));
apiRouter.use('/admin', require('./routes/admin.js'));
apiRouter.use('/email', require('./routes/email.js'));
apiRouter.use('/track', require('./routes/track.js'));

// Clean click-tracking redirects used in the plain-text founder emails.
app.use('/go', require('./routes/go.js'));

// Default error handler
app.use(function (err, req, res, next) {
  console.error(`[ERROR] ${req.method} ${req.originalUrl} — ${err.message}`);
  res.status(500).send({ msg: 'Internal server error' });
});

// SPA fallback — no-cache so the browser always gets the current entry point
app.use((_req, res) => {
  res.set('Cache-Control', 'no-cache');
  res.sendFile('index.html', { root: 'public' });
});

// Start server
const port = process.argv.length > 2 ? process.argv[2] : 4000;

const httpServer = app.listen(port, () => {
  console.log(`Listening on port ${port}`);
});

peerProxy(httpServer);

// Lifecycle email scheduler (welcome / weekly digest / win-back).
require('./mailer-jobs.js').startScheduler();
