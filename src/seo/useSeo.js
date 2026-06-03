import React from 'react';

/**
 * Per-page SEO head management for the public, crawlable pages.
 * Sets <title>, meta description, canonical, Open Graph, and JSON-LD structured
 * data on mount. The build-time prerender (scripts/prerender.mjs) renders the
 * page with Playwright and captures this head, so crawlers and AI bots see real
 * metadata + structured data instead of an empty SPA shell.
 */
function upsertMeta(attr, key, content) {
  if (!content) return;
  let el = document.head.querySelector(`meta[${attr}="${key}"]`);
  if (!el) {
    el = document.createElement('meta');
    el.setAttribute(attr, key);
    document.head.appendChild(el);
  }
  el.setAttribute('content', content);
}

function upsertLink(rel, href) {
  if (!href) return;
  let el = document.head.querySelector(`link[rel="${rel}"]`);
  if (!el) {
    el = document.createElement('link');
    el.setAttribute('rel', rel);
    document.head.appendChild(el);
  }
  el.setAttribute('href', href);
}

export function useSeo({ title, description, canonical, jsonLd }) {
  React.useEffect(() => {
    if (title) document.title = title;
    upsertMeta('name', 'description', description);
    upsertLink('canonical', canonical);
    upsertMeta('property', 'og:title', title);
    upsertMeta('property', 'og:description', description);
    upsertMeta('property', 'og:url', canonical);
    upsertMeta('property', 'og:type', 'article');
    upsertMeta('name', 'twitter:title', title);
    upsertMeta('name', 'twitter:description', description);

    // Replace any JSON-LD this hook previously added.
    document.head.querySelectorAll('script[data-seo-jsonld]').forEach((n) => n.remove());
    const blocks = Array.isArray(jsonLd) ? jsonLd : jsonLd ? [jsonLd] : [];
    for (const block of blocks) {
      const s = document.createElement('script');
      s.type = 'application/ld+json';
      s.setAttribute('data-seo-jsonld', '');
      s.textContent = JSON.stringify(block);
      document.head.appendChild(s);
    }
    // Signal to the prerenderer that the page-specific head is in place.
    document.documentElement.setAttribute('data-seo-ready', '1');
    return () => document.documentElement.removeAttribute('data-seo-ready');
  }, [title, description, canonical, JSON.stringify(jsonLd)]);
}
