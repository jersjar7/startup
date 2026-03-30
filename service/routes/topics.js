const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');

const router = express.Router();

// Get all topics with user's progress
router.get('/', verifyAuth, async (req, res) => {
  const topics = await DB.getTopics();
  const stats = await DB.getUserStats(req.user.email);

  const topicProgress = stats ? stats.topicProgress || {} : {};

  const result = topics.map((topic) => ({
    topicId: topic.topicId,
    name: topic.name,
    description: topic.description,
    problemCount: topic.problemCount,
    order: topic.order,
    progress: topicProgress[topic.topicId] || {
      attempted: 0,
      correct: 0,
      sessionsCompleted: 0,
    },
  }));

  res.send(result);
});

// Get a single topic with study materials
router.get('/:topicId', verifyAuth, async (req, res) => {
  const topic = await DB.getTopicById(req.params.topicId);
  if (!topic) {
    return res.status(404).send({ msg: 'Topic not found' });
  }

  res.send({
    topicId: topic.topicId,
    name: topic.name,
    description: topic.description,
    keyConcepts: topic.keyConcepts,
    videoUrl: topic.videoUrl,
    problemCount: topic.problemCount,
  });
});

// Get problems for a topic
router.get('/:topicId/problems', verifyAuth, async (req, res) => {
  const topic = await DB.getTopicById(req.params.topicId);
  if (!topic) {
    return res.status(404).send({ msg: 'Topic not found' });
  }

  const count = Math.min(parseInt(req.query.count) || 5, 8);
  const problems = await DB.getProblemsForTopic(req.params.topicId, count);

  res.send({
    topicId: topic.topicId,
    topicName: topic.name,
    problems: problems.map((p) => ({
      problemId: p._id.toString(),
      problemNumber: p.problemNumber,
      question: p.question,
      choices: p.choices,
      correctAnswer: p.correctAnswer,
      solution: p.solution,
      difficulty: p.difficulty,
    })),
  });
});

module.exports = router;
