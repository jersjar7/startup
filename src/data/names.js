// The first word of what someone typed as their first name: the given name.
// Sign-up asks "What should we call you?" in one field and people type a
// whole name into it, so "Jerson Test" is greeted as "Jerson" (owner,
// 2026-10-16). The server's service/profile.js givenName does the same.
export function givenName(typed) {
  const words = String(typed || '').trim().split(/\s+/);
  return words[0] || '';
}
