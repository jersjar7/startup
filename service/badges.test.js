import { describe, it, expect } from 'vitest';
const { evaluateBadges, getBadgeDetails, getAllBadges } = require('./badges.js');

function makeStats(overrides = {}) {
  return {
    totalXp: 0,
    currentStreak: 0,
    longestStreak: 0,
    topicProgress: {},
    badges: [],
    ...overrides,
  };
}

describe('evaluateBadges', () => {
  it('awards first-session badge after 1 session', () => {
    const stats = makeStats({
      topicProgress: { 'topic-1': { sessionsCompleted: 1 } },
    });
    const result = evaluateBadges(stats, { correct: 3, total: 5 });
    expect(result).toContain('first-session');
  });

  it('awards five-sessions badge after 5 sessions', () => {
    const stats = makeStats({
      topicProgress: { 'topic-1': { sessionsCompleted: 5 } },
    });
    const result = evaluateBadges(stats, { correct: 3, total: 5 });
    expect(result).toContain('five-sessions');
    expect(result).toContain('first-session');
  });

  it('awards twenty-sessions badge after 20 sessions', () => {
    const stats = makeStats({
      topicProgress: { 'topic-1': { sessionsCompleted: 20 } },
    });
    const result = evaluateBadges(stats, { correct: 3, total: 5 });
    expect(result).toContain('twenty-sessions');
  });

  it('awards streak-3 badge', () => {
    const stats = makeStats({ longestStreak: 3 });
    const result = evaluateBadges(stats, { correct: 0, total: 0 });
    expect(result).toContain('streak-3');
  });

  it('awards streak-7 badge', () => {
    const stats = makeStats({ longestStreak: 7 });
    const result = evaluateBadges(stats, { correct: 0, total: 0 });
    expect(result).toContain('streak-7');
    expect(result).toContain('streak-3');
  });

  it('awards streak-30 badge', () => {
    const stats = makeStats({ longestStreak: 30 });
    const result = evaluateBadges(stats, { correct: 0, total: 0 });
    expect(result).toContain('streak-30');
  });

  it('awards xp-100 badge', () => {
    const stats = makeStats({ totalXp: 100 });
    const result = evaluateBadges(stats, { correct: 0, total: 0 });
    expect(result).toContain('xp-100');
  });

  it('awards xp-500 badge', () => {
    const stats = makeStats({ totalXp: 500 });
    const result = evaluateBadges(stats, { correct: 0, total: 0 });
    expect(result).toContain('xp-500');
    expect(result).toContain('xp-100');
  });

  it('awards xp-1000 badge', () => {
    const stats = makeStats({ totalXp: 1000 });
    const result = evaluateBadges(stats, { correct: 0, total: 0 });
    expect(result).toContain('xp-1000');
  });

  it('awards first-mastery badge when any topic reaches level 3', () => {
    const stats = makeStats({
      topicProgress: { 'topic-1': { masteryLevel: 3, sessionsCompleted: 3 } },
    });
    const result = evaluateBadges(stats, { correct: 3, total: 5 });
    expect(result).toContain('first-mastery');
  });

  it('does not award first-mastery at level 2', () => {
    const stats = makeStats({
      topicProgress: { 'topic-1': { masteryLevel: 2, sessionsCompleted: 3 } },
    });
    const result = evaluateBadges(stats, { correct: 3, total: 5 });
    expect(result).not.toContain('first-mastery');
  });

  it('awards multi-topic badge with 3 different topics', () => {
    const stats = makeStats({
      topicProgress: {
        'topic-1': { sessionsCompleted: 1 },
        'topic-2': { sessionsCompleted: 1 },
        'topic-3': { sessionsCompleted: 1 },
      },
    });
    const result = evaluateBadges(stats, { correct: 0, total: 0 });
    expect(result).toContain('multi-topic');
  });

  it('does not award multi-topic with only 2 topics', () => {
    const stats = makeStats({
      topicProgress: {
        'topic-1': { sessionsCompleted: 1 },
        'topic-2': { sessionsCompleted: 1 },
      },
    });
    const result = evaluateBadges(stats, { correct: 0, total: 0 });
    expect(result).not.toContain('multi-topic');
  });

  it('awards perfect-session badge for 100% on 5+ problems', () => {
    const stats = makeStats();
    const result = evaluateBadges(stats, { correct: 5, total: 5 });
    expect(result).toContain('perfect-session');
  });

  it('does not award perfect-session for 100% on fewer than 5 problems', () => {
    const stats = makeStats();
    const result = evaluateBadges(stats, { correct: 4, total: 4 });
    expect(result).not.toContain('perfect-session');
  });

  it('does not award perfect-session for less than 100%', () => {
    const stats = makeStats();
    const result = evaluateBadges(stats, { correct: 4, total: 5 });
    expect(result).not.toContain('perfect-session');
  });

  it('does not re-award badges already earned', () => {
    const stats = makeStats({
      totalXp: 200,
      badges: ['xp-100'],
    });
    const result = evaluateBadges(stats, { correct: 0, total: 0 });
    expect(result).not.toContain('xp-100');
  });

  it('returns empty array when no new badges earned', () => {
    const stats = makeStats({
      badges: ['first-session', 'xp-100'],
      totalXp: 100,
      topicProgress: { 'topic-1': { sessionsCompleted: 1 } },
    });
    const result = evaluateBadges(stats, { correct: 3, total: 5 });
    expect(result).toEqual([]);
  });
});

describe('getBadgeDetails', () => {
  it('returns details for given badge IDs', () => {
    const details = getBadgeDetails(['first-session', 'streak-3']);
    expect(details).toHaveLength(2);
    expect(details[0]).toEqual({
      id: 'first-session',
      name: 'First Steps',
      description: 'Complete your first study session',
    });
  });

  it('returns empty array for unknown IDs', () => {
    expect(getBadgeDetails(['nonexistent'])).toEqual([]);
  });
});

describe('getAllBadges', () => {
  it('returns all 12 badges', () => {
    const all = getAllBadges();
    expect(all).toHaveLength(12);
    expect(all[0]).toHaveProperty('id');
    expect(all[0]).toHaveProperty('name');
    expect(all[0]).toHaveProperty('description');
  });
});
