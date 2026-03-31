const { problemCollection } = require('./connection');

async function getProblemsForTopic(topicId, count = 5) {
  return problemCollection
    .find({ topicId: topicId })
    .sort({ problemNumber: 1 })
    .limit(count)
    .toArray();
}

async function getAllProblemsForTopics(topicIds) {
  return problemCollection.find({ topicId: { $in: topicIds } }).toArray();
}

module.exports = { getProblemsForTopic, getAllProblemsForTopics };
