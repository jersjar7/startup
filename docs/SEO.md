# Search and AI visibility: how a public page ships

What Google, Bing and AI assistants (ChatGPT, Copilot, Claude, Perplexity)
read about FE for Raccoons, and the rules every public page follows. Each rule
below comes from something that went wrong on the live site.

## How crawlers see the site

- The app is a single-page React app. A crawler that does not run JavaScript
  gets an empty shell ("You need to enable JavaScript") unless the page is
  **prerendered**. `npm run build:seo` renders each public route with
  Playwright into `dist/<route>/index.html`; the server sends those files.
- The home page is prerendered into `dist/home/index.html` (not
  `dist/index.html`, which is the shell every app route falls back to) and the
  server sends it for `/` only. Until 2026-10-29 the home page was an empty
  shell, while it was the page Copilot cited most (487 citations in 3 months).
- Every other route (login, dashboard, study screens, mistyped URLs) gets the
  shell with `X-Robots-Tag: noindex`. Bing had flagged them as duplicate titles,
  duplicate descriptions, missing h1 and thin content.
- ChatGPT search draws on Bing's index (confirmed by a Bing product manager,
  per Search Engine Roundtable). Bing matters as much as Google for AI answers.

## Adding a public page: the checklist

1. Add the route to `ROUTES` in `scripts/prerender.mjs` **and** to
   `PRERENDERED_ROUTE_PATTERN` in `service/prerenderedRoutes.js`. Miss the
   second and crawlers get the shell while the page looks fine in a browser.
   `service/prerenderedRoutes.test.js` fails on the drift.
2. Call `useSeo({ title, description, canonical, jsonLd })`. Build the title
   with `pageTitle()` from `src/seo/pageTitle.js`: it keeps the brand suffix
   only when the title stays at or under 70 characters.
3. Give the page exactly one `<h1>`, a description unique to it, and real text.
4. Add it to the sitemap list and to `llms.txt` in `scripts/prerender.mjs`.
5. Run `npm run build:seo` **before** merging. It fails on any of: a title over
   70 characters, a missing description, not exactly one h1, under 500
   characters of text, or a title or description another page already uses
   (`scripts/seoChecks.mjs`). Unit tests do not load every page; on
   2026-10-29 a page with a broken quote passed the suite and only the build
   caught it.
6. After the deploy, run `node scripts/indexnow.mjs` so Bing (and through it
   ChatGPT) hears about the change the same day, and request indexing for the
   new URL in Google Search Console (about 10 requests a day).

## Where to look

- **Bing Webmaster Tools** (bing.com/webmasters): Recommendations lists every
  flagged page; AI Performance shows Copilot citations by query and by page.
- **Google Search Console**: indexing status and search queries.
- `public/robots.txt` welcomes the AI crawlers by name; `llms.txt` is the
  plain summary written for AI assistants.

## What only other sites can fix

Bing reports no backlinks. Rankings for "fe civil prep" and AI recommendations
both lean on other sites naming us, so outreach (university library guides,
ASCE student chapters, professors, genuine answers on Reddit) is the next
lever, not more on-page work.
