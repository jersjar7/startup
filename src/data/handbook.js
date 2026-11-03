// The FE Reference Handbook edition every cited page refers to. NCEES
// supplies the current edition on exam day; when it changes, remap the pages
// and change this one value. Every page label on the site shows it.
export const HANDBOOK_EDITION = '10.6';

// "p. 182" (or a bare "182") becomes "Handbook 10.6, p. 182".
export function handbookRef(page, name = 'Handbook') {
  const text = String(page).trim();
  return `${name} ${HANDBOOK_EDITION}, ${/^\d/.test(text) ? `p. ${text}` : text}`;
}
