const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const { applyDecay, isDecaying, masteryName } = require('../mastery.js');

const router = express.Router();

// Get all topics with user's progress
router.get('/', verifyAuth, async (req, res) => {
  const topics = await DB.getTopics();
  const stats = await DB.getUserStats(req.user.email);

  const topicProgress = stats ? stats.topicProgress || {} : {};
  let hasDecayed = false;

  const result = topics.map((topic) => {
    const tp = topicProgress[topic.topicId] || {
      attempted: 0,
      correct: 0,
      sessionsCompleted: 0,
      masteryLevel: 0,
      lastStudied: null,
    };
    const earned = tp.masteryLevel || 0;
    const effective = applyDecay(earned, tp.lastStudied);
    const decaying = isDecaying(earned, tp.lastStudied);

    // Persist decayed mastery so it's trackable
    if (decaying && topicProgress[topic.topicId]) {
      topicProgress[topic.topicId].masteryLevel = effective;
      hasDecayed = true;
    }

    return {
      topicId: topic.topicId,
      name: topic.name,
      description: topic.description,
      problemCount: topic.problemCount,
      order: topic.order,
      progress: {
        attempted: tp.attempted,
        correct: tp.correct,
        sessionsCompleted: tp.sessionsCompleted,
        masteryLevel: effective,
        masteryName: masteryName(effective),
        decaying,
        lastStudied: tp.lastStudied,
      },
    };
  });

  // Write decayed mastery back to DB (fire-and-forget)
  if (hasDecayed && stats) {
    DB.updateUserStats(req.user.email, { ...stats, topicProgress });
  }

  res.send(result);
});

// Get a single topic with study materials
router.get('/:topicId', verifyAuth, async (req, res) => {
  if (!/^[a-z0-9-]+$/.test(req.params.topicId)) {
    return res.status(400).send({ msg: 'Invalid topicId' });
  }
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


module.exports = router;
