// Internal/test accounts to exclude from public leaderboards AND owner-facing
// analytics, so they never pollute rankings or metrics. Override or extend via
// the EXCLUDED_ACCOUNTS env var (comma-separated) without a code change.
// Emails are stored normalized (lowercased) by the auth pipeline, so the $nin
// match against this lowercased list works directly.
const EXCLUDED_EMAILS = (process.env.EXCLUDED_ACCOUNTS || 'admin@oqupa.com,qa-bot@fe4raccoons.com')
  .split(',')
  .map((s) => s.trim().toLowerCase())
  .filter(Boolean);

function isExcluded(email) {
  return EXCLUDED_EMAILS.includes(String(email || '').trim().toLowerCase());
}

module.exports = { EXCLUDED_EMAILS, isExcluded };
