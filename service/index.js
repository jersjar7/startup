require('dotenv').config();
const express = require('express');
const helmet = require('helmet');
const cookieParser = require('cookie-parser');
const { peerProxy } = require('./peerProxy.js');
const { requestLogger } = require('./middleware/logger.js');

const app = express();

// Security and parsing middleware
app.use(helmet());
app.use(express.json());
app.use(cookieParser());
app.use(requestLogger);

// Serve the frontend static files
app.use(express.static('public'));

// API routes
const apiRouter = express.Router();
app.use('/api', apiRouter);

apiRouter.use('/', require('./routes/health.js'));
apiRouter.use('/auth', require('./routes/auth.js'));
apiRouter.use('/user', require('./routes/auth.js'));
apiRouter.use('/topics', require('./routes/topics.js'));
apiRouter.use('/sessions', require('./routes/sessions.js'));

// Default error handler
app.use(function (err, req, res, next) {
  console.error(err.stack);
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
