const { userCollection } = require('./connection');

function getUser(email) {
  return userCollection.findOne({ email: email });
}

function getUserByToken(token) {
  return userCollection.findOne({ token: token });
}

async function addUser(user) {
  await userCollection.insertOne(user);
}

async function updateUser(user) {
  await userCollection.updateOne({ email: user.email }, { $set: user });
}

function getUserByResetToken(hashedToken) {
  return userCollection.findOne({
    resetToken: hashedToken,
    resetTokenExpiry: { $gt: new Date() },
  });
}

function getUserByVerificationToken(hashedToken) {
  return userCollection.findOne({ verificationToken: hashedToken });
}

async function setUserFields(email, fields) {
  await userCollection.updateOne({ email }, { $set: fields });
}

async function unsetUserFields(email, fields) {
  const unsetObj = {};
  for (const f of fields) unsetObj[f] = '';
  await userCollection.updateOne({ email }, { $unset: unsetObj });
}

module.exports = {
  getUser,
  getUserByToken,
  addUser,
  updateUser,
  getUserByResetToken,
  getUserByVerificationToken,
  setUserFields,
  unsetUserFields,
};
