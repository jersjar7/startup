const crypto = require('crypto');

function generateToken() {
  return crypto.randomBytes(32).toString('hex');
}

function hashToken(token) {
  return crypto.createHash('sha256').update(token).digest('hex');
}

// Cryptographically strong numeric code (default 6 digits). Rejects byte
// values >= 250 so each digit is uniform (256 = 25*10 + 6 would bias 0–5).
function generateNumericCode(length = 6) {
  let code = '';
  while (code.length < length) {
    const b = crypto.randomBytes(1)[0];
    if (b < 250) code += String(b % 10);
  }
  return code;
}

module.exports = { generateToken, hashToken, generateNumericCode };
