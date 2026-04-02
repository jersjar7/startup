require('dotenv').config();
require('express-async-errors');
const express = require('express');
const helmet = require('helmet');
const cookieParser = require('cookie-parser');
const rateLimit = require('express-rate-limit');
const { peerProxy } = require('./peerProxy.js');
const { requestLogger } = require('./middleware/logger.js');

const app = express();

// Security and parsing middleware
app.use(helmet());
app.use(express.json());
app.use(cookieParser());
app.use(requestLogger);

// Global rate limit: 100 requests per 15 minutes per IP
app.use(rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { msg: 'Too many requests, try again later' },
}));

// Serve the frontend static files
app.use(express.static('public'));

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

// Default error handler
app.use(function (err, req, res, next) {
  console.error(`[ERROR] ${req.method} ${req.originalUrl} — ${err.message}`);
  res.status(500).send({ msg: 'Internal server error' });
});

// SPA fallback
app.use((_req, res) => {
  res.sendFile('index.html', { root: 'public' });
});

// Start server
const port = process.argv.length > 2 ? process.argv[2] : 4000;

const httpServer = app.listen(port, () => {
  console.log(`Listening on port ${port}`);
});

peerProxy(httpServer);
