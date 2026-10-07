import React from 'react';
import { X } from '@phosphor-icons/react';
import './SchoolPrompt.css';

// "Where are you studying?" Asked once per user, then never again.
//
// Why we want it: the campus channel is the highest-leverage distribution we
// have, and it is currently measured by hand. Knowing which institutions our
// users actually come from is what turns "professors work" into a list of
// professors worth writing to. Graduation year is the second half of that: it
// says whether somebody is sitting the FE this spring or in three years, which
// is the difference between a buyer and a long nurture.
//
// School stays FREE TEXT, with suggestions over the top. A select box long
// enough to be correct is unusable on a phone, which is why there is no
// dropdown, but free text alone was measured on 2026-10-07 and produced
// nothing usable: 19 users had given a school and there were 19 distinct
// names, with "UCI" and "University of California, Irvine" counted as separate
// institutions. Normalising on our side cannot fix that, because its grouping
// key strips "university" and "of" and the two forms can never meet.
//
// So the field suggests canonical names from a 2,348-school directory as you
// type, and still accepts anything. The suggestion is what makes two students
// at one university save the same string; the free text is what stops an
// incomplete list blocking anybody. See service/schoolDirectory.js.
//
// Graduation year is the opposite: a short fixed set, because every plausible
// answer for a student studying for the FE sits in a five-year window, and
// chips are one tap. "Already graduated" is the honest out for the working
// engineers who make up a real slice of the user base.
//
// Asked at registration, with the dashboard as a safety net. The rule is
// "ask until resolved, never after" (see src/dashboard/schoolGate.js).
const GRAD_YEAR_SPAN = 5;

// A May and a December graduate are a full exam cycle apart, so the year alone
// blurs two different cohorts. Four terms is two taps and it is how
// universities actually talk; twelve months would be too much friction on a
// field people already skip (owner, 2026-10-06).
export const GRAD_TERMS = ['Winter', 'Spring', 'Summer', 'Fall'];

// Chips are generated, not hardcoded, so the window does not quietly rot into
// a list of past years the next time nobody is looking.
export function gradYearOptions(now = new Date()) {
  const first = now.getFullYear();
  return Array.from({ length: GRAD_YEAR_SPAN }, (_, i) => first + i);
}

async function postSchool(body) {
  const res = await fetch('/api/user/school', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  return res.ok;
}

// `dismissible`  show the X. False where the ask is the point of the screen.
// The skip button is always there regardless: a user with no school has no true
// answer to give, and there is no "Other" chip that would cover them.
export function SchoolPrompt({
  onClose,
  dismissible = true,
  className = '',
  // The school we already worked out from their .edu address, if any. Starts
  // the field filled in so they confirm rather than retype, and so the prompt
  // is mostly about the graduation year, which is the part a domain can never
  // tell us (2026-10-07).
  initialName = '',
}) {
  const [name, setName] = React.useState(initialName);
  const [suggestions, setSuggestions] = React.useState([]);
  // Set when a suggestion is clicked and cleared on the next keystroke, so the
  // list does not reopen underneath the name they just chose.
  const justPicked = React.useRef(false);
  // What the field held when the last request went out, so a reply that
  // arrives after they have typed on is dropped rather than flashing stale
  // names under the cursor.
  const inFlightFor = React.useRef('');

  React.useEffect(() => {
    if (justPicked.current) {
      justPicked.current = false;
      return undefined;
    }
    const q = name.trim();
    if (q.length < 2) {
      setSuggestions([]);
      return undefined;
    }
    // Typing is faster than the network, so one request per keystroke makes
    // the list jump around behind the cursor.
    const timer = setTimeout(async () => {
      inFlightFor.current = q;
      try {
        const res = await fetch(`/api/auth/schools?q=${encodeURIComponent(q)}`);
        if (!res.ok) throw new Error('no suggestions');
        const data = await res.json();
        if (inFlightFor.current !== q) return;
        setSuggestions(Array.isArray(data.schools) ? data.schools : []);
      } catch {
        // Suggestions are a convenience. Losing them must never stop somebody
        // typing their own school.
        setSuggestions([]);
      }
    }, 250);
    return () => clearTimeout(timer);
  }, [name]);

  const pick = (school) => {
    justPicked.current = true;
    setName(school);
    setSuggestions([]);
  };
  const [year, setYear] = React.useState(null); // a year, or 'graduated'
  const [term, setTerm] = React.useState(null);
  const [busy, setBusy] = React.useState(false);
  const years = React.useMemo(() => gradYearOptions(), []);

  const trimmed = name.trim();

  async function save() {
    if (busy || !trimmed) return;
    setBusy(true);
    try {
      // "Already graduated" sends a null year rather than a guessed one: the
      // contract has no slot for a past date we were never told. A name with a
      // null year still reads correctly, because schoolResolved is what marks
      // the question answered, not the year.
      await postSchool({
        name: trimmed,
        graduationYear: typeof year === 'number' ? year : null,
        graduationTerm: term ? term.toLowerCase() : null,
      });
    } catch { /* non-blocking: never trap a user behind a profile question */ }
    onClose(true);
  }

  async function skip() {
    if (busy) return;
    setBusy(true);
    try {
      await postSchool({ dismissed: true });
    } catch { /* non-blocking, same reason, and the server asks again next load */ }
    onClose(true);
  }

  return (
    <div className={`school-prompt ${className}`.trim()}>
      {dismissible && (
        <button className="school-prompt-x" onClick={() => onClose(false)} aria-label="Dismiss">
          <X size={14} weight="bold" />
        </button>
      )}
      <span className="school-prompt-q">Where are you studying?</span>
      <span className="school-prompt-why">
        So we can show you how you compare with other students at your school.
      </span>
      <input
        className="school-prompt-input"
        type="text"
        aria-label="School name"
        placeholder="University of West Florida"
        autoComplete="organization"
        maxLength={120}
        value={name}
        disabled={busy}
        onChange={(e) => setName(e.target.value)}
      />
      {suggestions.length > 0 && (
        <div className="school-suggestions" role="listbox" aria-label="Matching schools">
          {suggestions.map((school) => (
            <button
              key={school}
              type="button"
              role="option"
              aria-selected="false"
              className="school-suggestion"
              onClick={() => pick(school)}
            >
              {school}
            </button>
          ))}
          <span className="school-suggestion-note">
            Not listed? Type it and we will take it.
          </span>
        </div>
      )}
      <span className="school-prompt-sub">When do you graduate?</span>
      <div className="school-prompt-chips">
        {GRAD_TERMS.map((t) => (
          <button
            key={t}
            type="button"
            className={`school-chip ${term === t ? 'is-picked' : ''}`.trim()}
            aria-pressed={term === t}
            disabled={busy}
            onClick={() => setTerm(term === t ? null : t)}
          >
            {t}
          </button>
        ))}
      </div>
      <div className="school-prompt-chips">
        {years.map((y) => (
          <button
            key={y}
            type="button"
            className={`school-chip ${year === y ? 'is-picked' : ''}`.trim()}
            aria-pressed={year === y}
            disabled={busy}
            onClick={() => setYear(year === y ? null : y)}
          >
            {y}
          </button>
        ))}
        <button
          type="button"
          className={`school-chip ${year === 'graduated' ? 'is-picked' : ''}`.trim()}
          aria-pressed={year === 'graduated'}
          disabled={busy}
          onClick={() => {
            setYear(year === 'graduated' ? null : 'graduated');
            setTerm(null);
          }}
        >
          Already graduated
        </button>
      </div>
      <div className="school-prompt-actions">
        {/* Save needs a name but not a year. Somebody who taps their school and
            is unsure of their finish date has still told us the useful half. */}
        <button type="button" className="school-prompt-save" disabled={busy || !trimmed} onClick={save}>
          {busy ? 'Saving...' : 'Save'}
        </button>
        <button type="button" className="school-prompt-skip" disabled={busy} onClick={skip}>
          Not a student
        </button>
      </div>
    </div>
  );
}
