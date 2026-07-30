// Pure helpers for user profile fields (display name + exam date). DB-free and
// testable. The display name is what other users see in the Live Activity feed,
// so it must never fall back to the full email address (PII).

// Allow letters (any language), marks, spaces, hyphen, apostrophe; collapse
// whitespace; cap length. Strips anything else.
function sanitizeName(s) {
  if (typeof s !== 'string') return '';
  return s.replace(/[^\p{L}\p{M} '\-]/gu, '').replace(/\s+/g, ' ').trim().slice(0, 40);
}

// "Maria G." from first + last; first-only if no last; else the email's local
// part (before @) — never the full email.
function displayName(user) {
  const first = sanitizeName(user?.firstName || '');
  const last = sanitizeName(user?.lastName || '');
  if (first) return last ? `${first} ${last[0].toUpperCase()}.` : first;
  const local = String(user?.email || '').split('@')[0];
  return local || 'A student';
}

// Returns the normalized 'YYYY-MM-DD' string, null to clear, or undefined if
// invalid (so the caller can reject).
function normalizeExamDate(v) {
  if (v === null || v === '') return null;
  if (typeof v !== 'string') return undefined;
  const trimmed = v.trim();
  if (!/^\d{4}-\d{2}-\d{2}$/.test(trimmed)) return undefined;
  const d = new Date(`${trimmed}T00:00:00Z`);
  if (Number.isNaN(d.getTime())) return undefined;
  const year = d.getUTCFullYear();
  if (year < 2024 || year > 2100) return undefined;
  // Reject if the parsed date rolled over (e.g. 2026-02-31 -> Mar 3).
  if (d.toISOString().slice(0, 10) !== trimmed) return undefined;
  return trimmed;
}

// Whole days from now until the exam (ceil; 0 = today, negative = past).
function daysUntilExam(examDate, now = new Date()) {
  if (!examDate) return null;
  const d = new Date(`${examDate}T00:00:00Z`);
  if (Number.isNaN(d.getTime())) return null;
  return Math.ceil((d.getTime() - now.getTime()) / 86400000);
}

// Pull the frozen exam-timing fields back off a Stripe session's metadata.
//
// Stripe stores metadata as strings, so daysUntilExam has to be parsed back to
// a number here. Both purchase-recording paths (the webhook and the
// /checkout/status fallback) go through this so they cannot drift apart and
// record the field in two different shapes.
//
// Returns null for each value that was never set, which is the common case
// while most users still have no exam date on file.
function examTimingFromMetadata(metadata = {}) {
  const raw = metadata.daysUntilExam;
  const n = raw === undefined || raw === null || raw === '' ? null : Number(raw);
  return {
    daysUntilExam: n === null || Number.isNaN(n) ? null : n,
    examDateAtPurchase: metadata.examDateAtPurchase || null,
  };
}

module.exports = {
  sanitizeName, displayName, normalizeExamDate, daysUntilExam, examTimingFromMetadata,
};
