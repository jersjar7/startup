const express = require('express');
const cookieParser = require('cookie-parser');
const bcrypt = require('bcryptjs');
const uuid = require('uuid');
const DB = require('./database.js');
const { peerProxy } = require('./peerProxy.js');

const app = express();

// Parse JSON bodies and cookies
app.use(express.json());
app.use(cookieParser());

// Serve the frontend static files from the public directory
app.use(express.static('public'));

// Router for API endpoints
const apiRouter = express.Router();
app.use('/api', apiRouter);

// Auth cookie name
const authCookieName = 'token';

// ---- Authentication Endpoints ----

// Register a new user
apiRouter.post('/auth/create', async (req, res) => {
  if (await DB.getUser(req.body.email)) {
    res.status(409).send({ msg: 'Existing user' });
  } else {
    const passwordHash = await bcrypt.hash(req.body.password, 10);
    const user = {
      email: req.body.email,
      password: passwordHash,
      token: uuid.v4(),
    };
    await DB.addUser(user);
    setAuthCookie(res, user.token);
    res.send({ email: user.email });
  }
});

// Login an existing user
apiRouter.post('/auth/login', async (req, res) => {
  const user = await DB.getUser(req.body.email);
  if (user && (await bcrypt.compare(req.body.password, user.password))) {
    user.token = uuid.v4();
    await DB.updateUser(user);
    setAuthCookie(res, user.token);
    res.send({ email: user.email });
  } else {
    res.status(401).send({ msg: 'Unauthorized' });
  }
});

// Logout a user
apiRouter.delete('/auth/logout', async (req, res) => {
  const user = await DB.getUserByToken(req.cookies[authCookieName]);
  if (user) {
    delete user.token;
    await DB.updateUser(user);
  }
  res.clearCookie(authCookieName);
  res.status(204).end();
});

// Get the current authenticated user
apiRouter.get('/user/me', async (req, res) => {
  const user = await DB.getUserByToken(req.cookies[authCookieName]);
  if (user) {
    res.send({ email: user.email });
  } else {
    res.status(401).send({ msg: 'Unauthorized' });
  }
});

// Middleware to verify authentication
const verifyAuth = async (req, res, next) => {
  const user = await DB.getUserByToken(req.cookies[authCookieName]);
  if (user) {
    req.user = user;
    next();
  } else {
    res.status(401).send({ msg: 'Unauthorized' });
  }
};

// ---- Application Endpoints ----

// Get all topics
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

// Get user progress
apiRouter.get('/progress', verifyAuth, async (req, res) => {
  const userProgress = await DB.getProgress(req.user.email);
  res.send(userProgress);
});

// Save user progress
apiRouter.post('/progress', verifyAuth, async (req, res) => {
  const { problemId, completed } = req.body;
  const userProgress = await DB.saveProgress(req.user.email, problemId, completed);
  res.send(userProgress);
});

// ---- Helper Functions ----

function setAuthCookie(res, authToken) {
  res.cookie(authCookieName, authToken, {
    secure: true,
    httpOnly: true,
    sameSite: 'strict',
  });
}

// Default error handler
app.use(function (err, req, res, next) {
  res.status(500).send({ type: err.name, message: err.message });
});

// Return the application's default page if the path is unknown
app.use((_req, res) => {
  res.sendFile('index.html', { root: 'public' });
});

// Port configuration
const port = process.argv.length > 2 ? process.argv[2] : 4000;

const httpServer = app.listen(port, () => {
  console.log(`Listening on port ${port}`);
});

peerProxy(httpServer);
