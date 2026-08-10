// Destinations for the short /go/<code> tracked redirects.
//
// Two kinds live here:
//
// 1. EMAIL/CONTENT links (exam, mitch, digest). Short, clean, aggregate-counted.
// 2. CAMPUS PLACEMENTS (byu, byub, ...). One code per PHYSICAL placement, so a
//    seminar slide can be told apart from a bulletin board, and one campus from
//    another. A flyer that cannot be attributed to its own board teaches nothing.
//
// Every code is hardcoded on purpose. /go must never accept a caller-supplied
// URL: an allowlist is the only thing standing between this and an open redirect
// that could be used to lend our domain's credibility to a phishing page.
//
// Codes are deliberately SHORT. A seminar slide is scanned from the back of a
// lecture hall, and a shorter URL packs into a lower-density QR that survives
// being projected and photographed at an angle.

// campus = utm_source, placement = utm_campaign. utm_medium is always 'campus',
// which is the convention the attribution doc already uses so the whole channel
// can be read as one group.
const CAMPUS_PLACEMENTS = {
  byu:   { campus: 'byu',   placement: 'seminar' },
  byub:  { campus: 'byu',   placement: 'board' },
  uvu:   { campus: 'uvu',   placement: 'seminar' },
  uvub:  { campus: 'uvu',   placement: 'board' },
  uofu:  { campus: 'utah',  placement: 'seminar' },
  uofub: { campus: 'utah',  placement: 'board' },
  usu:   { campus: 'usu',   placement: 'seminar' },
  usub:  { campus: 'usu',   placement: 'board' },
  weber: { campus: 'weber', placement: 'seminar' },
  weberb:{ campus: 'weber', placement: 'board' },
  uwf:   { campus: 'uwf',   placement: 'seminar' },
};

// Campus codes land on the HOME page, not the exam-simulation page. The promise
// made on a flyer is that the platform is free, and / is the page that says so.
// Sending a cold scan straight at the one paid product would contradict the
// flyer that produced the scan.
function campusDest({ campus, placement }) {
  return {
    url: `/?utm_source=${campus}&utm_medium=campus&utm_campaign=${placement}`,
    event: 'campus_scan',
    meta: { campus, placement },
  };
}

const DESTS = {
  exam: { url: '/exam', event: 'sim_pitch_click_exam' },
  mitch: { url: '/stories/mitch', event: 'sim_pitch_click_story' },
  digest: { url: '/exam-simulation', event: 'sim_pitch_click_digest' },
};

for (const [code, placement] of Object.entries(CAMPUS_PLACEMENTS)) {
  DESTS[code] = campusDest(placement);
}

// Returns null for an unknown code so the caller can redirect to '/' rather than
// echoing anything a visitor supplied.
function resolveGoDest(code) {
  if (typeof code !== 'string') return null;
  return Object.prototype.hasOwnProperty.call(DESTS, code) ? DESTS[code] : null;
}

module.exports = { DESTS, CAMPUS_PLACEMENTS, resolveGoDest };
