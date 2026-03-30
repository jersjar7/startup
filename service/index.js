const express = require('express');
const cookieParser = require('cookie-parser');
const bcrypt = require('bcryptjs');
const uuid = require('uuid');

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

// In-memory data stores (will move to MongoDB later)
let users = [];
let progress = {};

// ---- Authentication Endpoints ----

// Register a new user
apiRouter.post('/auth/create', async (req, res) => {
  if (await findUser('email', req.body.email)) {
    res.status(409).send({ msg: 'Existing user' });
  } else {
    const user = await createUser(req.body.email, req.body.password);
    setAuthCookie(res, user.token);
    res.send({ email: user.email });
  }
});

// Login an existing user
apiRouter.post('/auth/login', async (req, res) => {
  const user = await findUser('email', req.body.email);
  if (user && (await bcrypt.compare(req.body.password, user.password))) {
    user.token = uuid.v4();
    setAuthCookie(res, user.token);
    res.send({ email: user.email });
  } else {
    res.status(401).send({ msg: 'Unauthorized' });
  }
});

// Logout a user
apiRouter.delete('/auth/logout', async (req, res) => {
  const user = await findUser('token', req.cookies[authCookieName]);
  if (user) {
    delete user.token;
  }
  res.clearCookie(authCookieName);
  res.status(204).end();
});

// Get the current authenticated user
apiRouter.get('/user/me', async (req, res) => {
  const user = await findUser('token', req.cookies[authCookieName]);
  if (user) {
    res.send({ email: user.email });
  } else {
    res.status(401).send({ msg: 'Unauthorized' });
  }
});

// Middleware to verify authentication
const verifyAuth = async (req, res, next) => {
  const user = await findUser('token', req.cookies[authCookieName]);
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
apiRouter.get('/progress', verifyAuth, (req, res) => {
  const userProgress = progress[req.user.email] || {};
  res.send(userProgress);
});

// Save user progress
apiRouter.post('/progress', verifyAuth, (req, res) => {
  const { problemId, completed } = req.body;
  if (!progress[req.user.email]) {
    progress[req.user.email] = {};
  }
  progress[req.user.email][problemId] = completed;
  res.send(progress[req.user.email]);
});

// ---- Helper Functions ----

async function createUser(email, password) {
  const passwordHash = await bcrypt.hash(password, 10);
  const user = {
    email: email,
    password: passwordHash,
    token: uuid.v4(),
  };
  users.push(user);
  return user;
}

async function findUser(field, value) {
  if (!value) return null;
  return users.find((u) => u[field] === value);
}

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

app.listen(port, () => {
  console.log(`Listening on port ${port}`);
});
