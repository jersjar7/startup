// What every prerendered page must get right before it ships. Each rule is a
// problem Bing Webmaster Tools flagged on the live site in October 2026, or a
// page that reached production broken. scripts/prerender.mjs runs this on the
// pages it renders and fails the build on any problem, so a new public page
// cannot ship without them.
export const TITLE_MAX = 70;
export const MIN_TEXT = 500;

function decode(s) {
  return s.replace(/&amp;/g, '&').replace(/&quot;/g, '"').replace(/&#39;/g, "'").replace(/&lt;/g, '<').replace(/&gt;/g, '>');
}

export function readPage(html) {
  const title = decode((html.match(/<title>([^<]*)<\/title>/) || [])[1] || '');
  const description = decode((html.match(/<meta name="description" content="([^"]*)"/) || [])[1] || '');
  const canonical = (html.match(/<link rel="canonical" href="([^"]*)"/) || [])[1] || '';
  const h1s = (html.match(/<h1[\s>]/g) || []).length;
  const body = html.replace(/<script[\s\S]*?<\/script>|<style[\s\S]*?<\/style>/g, '');
  const text = body.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();
  return { title, description, canonical, h1s, textLength: text.length };
}

// pages: [{ route, html }]. Returns a list of plain-English problems.
export function checkPages(pages) {
  const problems = [];
  const seenTitle = new Map();
  const seenDescription = new Map();
  for (const { route, html } of pages) {
    const p = readPage(html);
    if (!p.title) problems.push(`${route}: no <title>`);
    else if (p.title.length > TITLE_MAX) problems.push(`${route}: title is ${p.title.length} characters, over ${TITLE_MAX} (search engines cut it): "${p.title}"`);
    if (!p.description) problems.push(`${route}: no meta description`);
    if (p.h1s !== 1) problems.push(`${route}: has ${p.h1s} <h1> tags, needs exactly 1`);
    if (p.textLength < MIN_TEXT) problems.push(`${route}: only ${p.textLength} characters of text, crawlers read it as an empty page`);
    if (p.title && seenTitle.has(p.title)) problems.push(`${route}: same title as ${seenTitle.get(p.title)}`);
    if (p.description && seenDescription.has(p.description)) problems.push(`${route}: same description as ${seenDescription.get(p.description)}`);
    seenTitle.set(p.title, route);
    seenDescription.set(p.description, route);
  }
  return problems;
}
