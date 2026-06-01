require('dotenv').config();
require('express-async-errors');
const express = require('express');
const helmet = require('helmet');
const compression = require('compression');
const cookieParser = require('cookie-parser');
const rateLimit = require('express-rate-limit');
const { peerProxy } = require('./peerProxy.js');
const { requestLogger } = require('./middleware/logger.js');

const app = express();

// Security, compression, and parsing middleware
app.use(helmet());
app.use(compression());

// Stripe webhook needs raw body for signature verification — mount BEFORE express.json()
app.use('/api/webhook', express.raw({ type: 'application/json' }), require('./routes/webhook.js'));

app.use(express.json({ limit: '1mb' }));
app.use(cookieParser());
app.use(requestLogger);

// Global rate limit: 200 requests per 15 minutes per IP (skip static assets)
app.use(rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  standardHeaders: true,
  legacyHeaders: false,
  skip: (req) => /\.(js|css|ico|png|svg|woff2?)$/.test(req.path),
  message: { msg: 'Too many requests, try again later' },
}));

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

// Strict rate limit on auth: 20 requests per 15 minutes per IP
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { msg: 'Too many attempts, try again later' },
});
apiRouter.use('/auth', authLimiter, require('./routes/auth.js'));

apiRouter.use('/', require('./routes/health.js'));
apiRouter.use('/user', require('./routes/auth.js'));
apiRouter.use('/topics', require('./routes/topics.js'));
apiRouter.use('/sessions', require('./routes/sessions.js'));
apiRouter.use('/review', require('./routes/review.js'));
apiRouter.use('/leaderboard', require('./routes/leaderboard.js'));
apiRouter.use('/diagnostic', require('./routes/diagnostic.js'));
apiRouter.use('/checkout', require('./routes/checkout.js'));
apiRouter.use('/exam', require('./routes/exam.js'));
apiRouter.use('/admin', require('./routes/admin.js'));

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
