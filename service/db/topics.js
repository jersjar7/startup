const { topicCollection } = require('./connection');

async function getTopics() {
  return topicCollection.find({}).sort({ order: 1 }).toArray();
}

async function getTopicById(topicId) {
  return topicCollection.findOne({ topicId: topicId });
}

module.exports = { getTopics, getTopicById };
