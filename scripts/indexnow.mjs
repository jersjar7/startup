// Tells Bing (and the other IndexNow engines) about every page in the live
// sitemap, so a new or changed page is picked up the day it ships.
// Run after a deploy: node scripts/indexnow.mjs
// The key file public/<KEY>.txt must be live on the site for this to work.
const SITE = 'https://fe4raccoons.com';
const KEY = 'f225972f6305a74deb6830856380c23b';

const xml = await (await fetch(`${SITE}/sitemap.xml`)).text();
const urlList = [...xml.matchAll(/<loc>([^<]+)<\/loc>/g)].map((m) => m[1]);
if (urlList.length === 0) throw new Error('sitemap had no URLs');

const res = await fetch('https://api.indexnow.org/indexnow', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json; charset=utf-8' },
  body: JSON.stringify({ host: 'fe4raccoons.com', key: KEY, keyLocation: `${SITE}/${KEY}.txt`, urlList }),
});
console.log(`IndexNow: ${res.status} ${res.statusText} for ${urlList.length} URLs`);
if (res.status >= 300) process.exit(1);
