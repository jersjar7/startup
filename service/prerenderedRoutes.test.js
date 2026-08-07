import { describe, it, expect } from 'vitest';
import fs from 'fs';
import path from 'path';
import { PRERENDERED_ROUTE_PATTERN } from './prerenderedRoutes.js';

// The prerenderer is an ESM script with top-level side effects (it launches a
// vite preview server and a browser), so its route list is read as text rather
// than imported.
function routesFromPrerenderScript() {
  const src = fs.readFileSync(
    path.resolve(__dirname, '../scripts/prerender.mjs'), 'utf8');

  const routesLine = src.match(/const ROUTES = \[(.*?)\];/s);
  expect(routesLine, 'could not find `const ROUTES = [...]` in scripts/prerender.mjs').toBeTruthy();

  // Literal paths, e.g. '/fe-civil-exam-guide'
  const literals = [...routesLine[1].matchAll(/'(\/[^']*)'/g)].map((m) => m[1]);

  // The topic pages are spread in as `...TOPICS.map(([id]) => `/fe-civil/${id}`)`,
  // so take the ids from the TOPICS list the same file builds.
  const topicsBlock = src.match(/const TOPICS = \[(.*?)\];/s);
  const topicIds = topicsBlock
    ? [...topicsBlock[1].matchAll(/\[\s*'([^']+)'/g)].map((m) => `/fe-civil/${m[1]}`)
    : [];

  return [...literals, ...topicIds];
}

describe('prerendered route pattern', () => {
  const routes = routesFromPrerenderScript();

  it('finds routes to check', () => {
    expect(routes.length).toBeGreaterThan(1);
    expect(routes).toContain('/fe-civil-exam-guide');
    expect(routes).toContain('/exam-simulation');
  });

  // The reason this test exists. A prerendered route the server does not match
  // still answers 200 from the SPA catch-all, so nothing else fails: not the
  // build, not the deploy, not a status-code check. Only the served HTML
  // differs, and only for crawlers.
  it.each(routesFromPrerenderScript())('serves the prerendered file for %s', (route) => {
    expect(PRERENDERED_ROUTE_PATTERN.test(route)).toBe(true);
  });

  it('matches the trailing-slash form too', () => {
    for (const route of routes) {
      expect(PRERENDERED_ROUTE_PATTERN.test(`${route}/`)).toBe(true);
    }
  });

  it('does not swallow app routes or the root', () => {
    for (const notPrerendered of ['/', '/dashboard', '/login', '/exam', '/exam/preview', '/api/user/me']) {
      expect(PRERENDERED_ROUTE_PATTERN.test(notPrerendered)).toBe(false);
    }
  });
});
