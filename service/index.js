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

// Port configuration
const port = process.argv.length > 2 ? process.argv[2] : 4000;

app.listen(port, () => {
  console.log(`Listening on port ${port}`);
});
