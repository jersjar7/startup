import { describe, it, expect } from 'vitest';
import fs from 'fs';
import path from 'path';
import { checkPages } from '../../scripts/seoChecks.mjs';

const page = ({ title = 'A page', description = 'About a page', h1 = 1, text = 'x'.repeat(600) } = {}) =>
  `<html><head><title>${title}</title><meta name="description" content="${description}"></head><body>${'<h1>H</h1>'.repeat(h1)}<p>${text}</p></body></html>`;

describe('SEO checks on prerendered pages', () => {
  it('passes a good page', () => {
    expect(checkPages([{ route: '/a', html: page() }])).toEqual([]);
  });

  it('catches each problem Bing flagged', () => {
    const problems = checkPages([
      { route: '/long', html: page({ title: 'x'.repeat(71) }) },
      { route: '/noh1', html: page({ title: 'B', description: 'b', h1: 0 }) },
      { route: '/thin', html: page({ title: 'C', description: 'c', text: 'You need to enable JavaScript' }) },
      { route: '/dup', html: page({ title: 'C', description: 'c' }) },
      { route: '/nodesc', html: page({ title: 'E', description: '' }) },
    ]).join('\n');
    expect(problems).toMatch(/\/long: title is 71/);
    expect(problems).toMatch(/\/noh1: has 0 <h1>/);
    expect(problems).toMatch(/\/thin: only/);
    expect(problems).toMatch(/\/dup: same title as \/thin/);
    expect(problems).toMatch(/\/dup: same description as \/thin/);
    expect(problems).toMatch(/\/nodesc: no meta description/);
  });

  // When a build is present, the shipped pages themselves must pass.
  it('passes on the last build, if there is one', () => {
    const dist = path.resolve(__dirname, '../../dist');
    if (!fs.existsSync(path.join(dist, 'home/index.html'))) return;
    const files = fs.readdirSync(dist, { recursive: true }).filter((f) => f.endsWith('index.html') && f !== 'index.html');
    const pages = files.map((f) => ({ route: `/${path.dirname(f)}`, html: fs.readFileSync(path.join(dist, f), 'utf8') }));
    expect(checkPages(pages)).toEqual([]);
  });
});
