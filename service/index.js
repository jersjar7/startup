require('dotenv').config();
const express = require('express');
const helmet = require('helmet');
const cookieParser = require('cookie-parser');
const { peerProxy } = require('./peerProxy.js');
const { requestLogger } = require('./middleware/logger.js');
const { verifyAuth } = require('./middleware/auth.js');
const DB = require('./database.js');

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

// Protected application endpoints (kept here for now, will move to routes/ in Branch 3)
apiRouter.get('/topics', verifyAuth, (_req, res) => {
  const topics = [
    { id: 'analytic-geometry', name: 'Analytic Geometry', problemCount: 5 },
    { id: 'dynamics', name: 'Dynamics', problemCount: 8 },
    { id: 'fluid-mechanics', name: 'Fluid Mechanics', problemCount: 12 },
    { id: 'soils', name: 'Soils', problemCount: 9 },
    { id: 'materials', name: 'Materials', problemCount: 7 },
    { id: 'transportation', name: 'Transportation', problemCount: 10 },
  ];
  res.send(topics);
});

apiRouter.get('/progress', verifyAuth, async (req, res) => {
  const userProgress = await DB.getProgress(req.user.email);
  res.send(userProgress);
});

apiRouter.post('/progress', verifyAuth, async (req, res) => {
  const { problemId, completed } = req.body;
  const userProgress = await DB.saveProgress(req.user.email, problemId, completed);
  res.send(userProgress);
});

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
