// Walks a chapter test the way a student does, in a real browser, and checks
// what they see at every step: before (chapter page, rules page), during
// (answer, change, clear, flag, refresh, leave and come back), hand in, the
// result and review, a second try (all new questions), a third try (the first
// set again, choices in a new order), the clock running out, a try opened and
// left (not counted, ADR 0001), a try worked on and left (graded), and the
// security edges (no key before hand in, no one else's results).
//
// It signs in as the QA account through a minted session (scripts/qa-session.mjs)
// and deletes that account's chapter test tries before and after, so it can run
// against production. It moves a try's start time in the database to test the
// clock, so only ever point it at the QA account.
//
// Usage:
//   node --env-file=service/.env scripts/ct-e2e.mjs                 # production
//   SITE=http://localhost:5173 node --env-file=service/.env scripts/ct-e2e.mjs
//   CH=ethics (default; the shortest test)   OUT=<screenshot dir>
// See docs/CHAPTER-TESTS.md.
import fs from 'node:fs';
import pw from 'playwright';
import { mintQaSession, revokeToken } from './qa-session.mjs';
const SITE = process.env.SITE || 'https://fe4raccoons.com';
const CH = process.env.CH || 'ethics';               // shortest test: 6 questions
const OUT = process.env.OUT || 'ct-e2e-shots';
const HOST = new URL(SITE).hostname, SECURE = SITE.startsWith('https');
const log = []; const ok = (name, cond, extra='') => { log.push(`${cond ? 'PASS' : 'FAIL'}  ${name}${extra ? '  ('+extra+')' : ''}`); };
const { token, email } = await mintQaSession();
const b = await pw.chromium.launch();
const ctx = await b.newContext({ viewport: { width: 1300, height: 900 } });
await ctx.addCookies([{ name:'token', value:token, domain:HOST, path:'/', httpOnly:true, secure:SECURE, sameSite:'Strict' }]);
const p = await ctx.newPage();
const pageErrors = []; p.on('pageerror', e => pageErrors.push(e.message));
const api = async (path, opts={}) => { const r = await p.request.fetch(SITE + '/api/chapter-tests' + path, opts); return { status: r.status(), body: r.headers()['content-type']?.includes('json') ? await r.json() : null }; };
const shot = (n) => p.screenshot({ path: `${OUT}/${n}.png`, fullPage: false });
const wayMeta = async () => (await p.locator('.study-way').nth(1).locator('.study-way-meta').textContent()).trim();
const gotoStudy = async () => { await p.goto(SITE + '/study/' + CH, { waitUntil: 'networkidle' }); await p.waitForTimeout(800); };
const openTest = async () => { await p.locator('.study-way').nth(1).click(); await p.waitForSelector('.ct-intro'); };
const questionIds = async () => (await api('/' + CH)).body;
const handIn = async () => { await p.locator('.dx-submit-btn').click(); await p.locator('.ct-confirm .btn-primary').click(); await p.waitForURL(/\/test\/result\//); await p.waitForSelector('.ct-score'); };

fs.mkdirSync(OUT, { recursive: true });
const { chapterTestAttemptsCollection: attempts } = await import('../service/db/connection.js');
await attempts.deleteMany({ email });   // the QA account only

try {
  await gotoStudy();
  ok('chapter page: test option says Not taken yet', (await wayMeta()) === 'Not taken yet', await wayMeta());
  await shot('01-study-fresh');

  // 1. intro
  await openTest();
  ok('intro: button says Start the test', (await p.locator('.ct-start').textContent()).includes('Start the test'));
  ok('intro: best says Not taken', (await p.locator('.ct-facts').textContent()).includes('Not taken'));
  await shot('02-intro-fresh');

  // 2. during: answer, change, clear, flag
  await p.locator('.ct-start').click(); await p.waitForSelector('.dx-question-card');
  const clock1 = await p.locator('.dx-timer span').textContent();
  const choiceTexts = async () => (await p.locator('.dx-choice-text').allTextContents()).map(t => t.trim());
  const order1 = await choiceTexts();
  await p.getByRole('button', { name: /Next/ }).click(); await p.getByRole('button', { name: /Previous/ }).click();
  ok('choices: same order after going to the next question and back', JSON.stringify(await choiceTexts()) === JSON.stringify(order1));
  ok('test: clock starts at 18 min for a 6-question test', /^1[78]:\d\d$/.test(clock1), clock1);
  await p.locator('.dx-choice').nth(0).click();                 // Q1 = A
  await p.locator('.dx-choice').nth(1).click();                 // Q1 changed to B
  ok('test: changing an answer keeps one selected', (await p.locator('.dx-choice--selected').count()) === 1);
  await p.getByRole('button', { name: /Next/ }).click();
  await p.locator('.dx-choice').nth(2).click();                 // Q2 = C
  await p.locator('.dx-choice').nth(2).click();                 // Q2 cleared
  ok('test: tapping the chosen answer again clears it', (await p.locator('.dx-choice--selected').count()) === 0);
  await p.getByRole('button', { name: /Next/ }).click();
  await p.locator('.dx-choice').nth(3).click();                 // Q3 = D
  await p.locator('.dx-flag-btn').click();                       // flag Q3
  ok('test: 2 answered shown in grid', (await p.locator('.dx-grid-stats').textContent()).includes('2/'));
  await shot('03-during');
  await p.waitForTimeout(1500);                                  // let autosave land
  const open1 = await questionIds();
  ok('server: try is open while taking it', !!open1.openId);
  const attemptA = open1.openId;

  // 3. refresh mid-test
  await p.reload({ waitUntil: 'networkidle' }); await p.waitForTimeout(800);
  const introBtn = (await p.locator('.ct-start').textContent()).trim();
  ok('refresh: intro offers Continue the test', introBtn.includes('Continue'), introBtn);
  await p.locator('.ct-start').click(); await p.waitForSelector('.dx-question-card');
  ok('choices: same order after a refresh', JSON.stringify(await choiceTexts()) === JSON.stringify(order1));
  ok('refresh: same 2 answers restored', (await p.locator('.dx-grid-stats').textContent()).includes('2/'), await p.locator('.dx-grid-stats').textContent());
  const clock2 = await p.locator('.dx-timer span').textContent();
  ok('refresh: clock kept running, not reset', clock2 < clock1 || clock2 === clock1, `${clock1} -> ${clock2}`);
  ok('refresh: flag survives', (await p.locator('.dx-grid-cell--flagged').count()) > 0);

  // 4. leave mid-test to the chapter page
  await gotoStudy();
  ok('chapter page while a try is open: says In progress', (await wayMeta()) === 'In progress', await wayMeta());
  await shot('04-study-in-progress');

  // 5. hand in try 1
  await openTest(); await p.locator('.ct-start').click(); await p.waitForSelector('.dx-question-card');
  await p.locator('.dx-submit-btn').click();
  const confirmText = await p.locator('.ct-confirm p').textContent();
  ok('hand in: warns about unanswered questions', /no answer/.test(confirmText), confirmText);
  await shot('05-confirm');
  await p.locator('.ct-confirm .btn-primary').click(); await p.waitForURL(/\/test\/result\//); await p.waitForSelector('.ct-score');
  const result1 = await api('/attempts/' + attemptA);
  ok('result 1: graded 2 answers', result1.body.questions.filter(q => q.chosen).length === 2);
  const ids1 = result1.body.questions.map(q => q.id);
  const reviewOrder = await p.locator('.ct-review-card').first().locator('.ct-choice-text').allTextContents();
  ok('review: shows choices in the order the student saw', reviewOrder.every((t, i) => t.trim().startsWith(order1[i])), reviewOrder.map(t => t.slice(0, 12)).join(' | '));
  const orders1 = result1.body.questions.map(q => q.choices.map(c => c.id).join());
  await shot('06-result-1');
  await p.waitForTimeout(800);
  const againLabel1 = (await p.locator('.ct-actions .ct-start').textContent()).trim();
  ok('result 1: promises new questions (true: set 2 unseen)', /new questions/.test(againLabel1), againLabel1);

  // 6. back button after hand in
  await p.goBack({ waitUntil: 'networkidle' }); await p.waitForTimeout(800);
  ok('back after hand in: does not reopen the finished test', !(await p.locator('.dx-question-card').count()), p.url());
  await shot('07-after-back');

  // 7. chapter page after 1 try
  await gotoStudy();
  ok('chapter page after 1 try: shows best and 1 try', /Best \d+% · 1 try/.test(await wayMeta()), await wayMeta());
  await openTest();
  ok('rules page: lists try 1 with a way back to its answers', (await p.locator('.ct-history .ct-link').count()) === 1);
  await shot('08b-intro-history');
  await p.locator('.ct-history .ct-link').first().click(); await p.waitForSelector('.ct-score');
  ok('see answers: opens the try 1 result', p.url().endsWith(attemptA), p.url());
  await gotoStudy();
  await shot('08-study-1-try');

  // 8. try 2: all new questions
  await openTest();
  ok('intro 2: button says Take the test again', (await p.locator('.ct-start').textContent()).includes('again'));
  ok('intro 2: says this try has all new questions', (await p.locator('.ct-rules').textContent()).includes('This try has all new questions'));
  await p.locator('.ct-start').click(); await p.waitForSelector('.dx-question-card');
  const attemptB = (await questionIds()).openId;
  for (let i = 0; i < 6; i++) { await p.locator('.dx-choice').nth(0).click(); if (i < 5) await p.getByRole('button', { name: /Next/ }).click(); }
  await p.locator('.dx-submit-btn').click();
  const confirm2 = await p.locator('.ct-confirm p').textContent();
  ok('hand in all answered: says every question has an answer', confirm2.includes('Every question'), confirm2);
  await p.locator('.ct-confirm .btn-primary').click(); await p.waitForURL(/\/test\/result\//); await p.waitForSelector('.ct-score');
  const ids2 = (await api('/attempts/' + attemptB)).body.questions.map(q => q.id);
  ok('try 2: zero questions repeated from try 1', ids2.every(id => !ids1.includes(id)), `${ids2.filter(id => ids1.includes(id)).length} repeats`);
  await p.waitForTimeout(800);
  const againLabel2 = (await p.locator('.ct-actions .ct-start').textContent()).trim();
  ok('result 2: does not promise new questions when none are left', !/new questions/.test(againLabel2), againLabel2);
  await shot('09-result-2');

  // 9. chapter page after 2 tries
  await gotoStudy();
  const meta2 = await wayMeta();
  ok('chapter page after 2 tries: says 2 tries', /2 tries/.test(meta2), meta2);
  await shot('10-study-2-tries');

  // 10. try 3: which questions?
  await openTest();
  ok('intro 3: says it repeats the set seen longest ago', (await p.locator('.ct-rules').textContent()).includes('repeats'));
  ok('intro 3: lists both tries', (await p.locator('.ct-history li').count()) === 2);
  await shot('10b-intro-3');
  await p.locator('.ct-start').click(); await p.waitForSelector('.dx-question-card');
  const attemptC = (await questionIds()).openId;
  const s3 = await api('/' + CH + '/A/start', { method: 'POST' });   // same open try, returns its questions
  const ids3 = s3.body.questions.map(q => q.id);
  const orders3 = ids1.map(id => s3.body.questions.find(q => q.id === id)?.choices.map(c => c.id).join());
  ok('try 3: same questions as try 1 but choices in a new order', orders3.filter((o, i) => o !== orders1[i]).length >= 3, `${orders3.filter((o, i) => o !== orders1[i]).length}/6 reordered`);
  ok('try 3: reuses the set seen longest ago (try 1)', ids3.every(id => ids1.includes(id)), `${ids3.filter(id => ids1.includes(id)).length}/${ids3.length} from try 1`);
  await shot('11-try-3');

  // 11. clock runs out: pull this try's start back so 4 s remain
  const { chapterTestAttemptsCollection } = await import('../service/db/connection.js');
  const { ObjectId } = await import('../service/node_modules/mongodb/lib/index.js');
  const doc = await chapterTestAttemptsCollection.findOne({ _id: new ObjectId(attemptC) });
  await chapterTestAttemptsCollection.updateOne({ _id: doc._id }, { $set: { startedAt: new Date(Date.now() - (doc.limitSeconds - 6) * 1000) } });
  await p.reload({ waitUntil: 'networkidle' }); await p.locator('.ct-start').click(); await p.waitForSelector('.dx-question-card');
  await p.locator('.dx-choice').nth(1).click();
  await p.waitForURL(/\/test\/result\//, { timeout: 20000 }).catch(() => {});
  ok('clock at zero: test hands itself in and shows the result', /\/test\/result\//.test(p.url()), p.url());
  const r3 = await api('/attempts/' + attemptC);
  ok('clock at zero: the last answer was kept', r3.body.questions.filter(q => q.chosen).length === 1, String(r3.body.questions.filter(q => q.chosen).length));
  ok('clock at zero: not marked late', r3.body.late === false);
  await shot('12-timeout-result');

  // 12a. a look, not a sitting: open a try, answer nothing, leave for hours
  await gotoStudy(); await openTest(); await p.locator('.ct-start').click(); await p.waitForSelector('.dx-question-card');
  const attemptD = (await questionIds()).openId;
  await chapterTestAttemptsCollection.updateOne({ _id: new ObjectId(attemptD) }, { $set: { startedAt: new Date(Date.now() - 3 * 3600 * 1000) } });
  await gotoStudy();
  const metaD = await wayMeta();
  ok('peeked try: chapter page no longer says In progress', metaD !== 'In progress', metaD);
  await openTest();
  const btnD = (await p.locator('.ct-start').textContent()).trim();
  ok('peeked try: intro offers a fresh start, not Continue', !btnD.includes('Continue'), btnD);
  await p.locator('.ct-start').click(); await p.waitForSelector('.dx-question-card');
  ok('peeked try: new try gets a full clock', /^1[78]:\d\d$/.test(await p.locator('.dx-timer span').textContent()), await p.locator('.dx-timer span').textContent());
  const dDoc = await chapterTestAttemptsCollection.findOne({ _id: new ObjectId(attemptD) });
  ok('peeked try: closed with no score (ADR 0001)', !!dDoc.submittedAt && dDoc.retired === true && !dDoc.result);
  ok('peeked try: not counted as a try', (await questionIds()).history.length === 3, String((await questionIds()).history.length));
  ok('peeked try: its result page is refused', (await api('/attempts/' + attemptD)).status === 404);

  // 12b. a real sitting: answer one of six (a tenth, rounded up), then leave
  const attemptE = (await questionIds()).openId;
  await p.locator('.dx-choice').nth(0).click(); await p.waitForTimeout(1500);
  await chapterTestAttemptsCollection.updateOne({ _id: new ObjectId(attemptE) }, { $set: { startedAt: new Date(Date.now() - 3 * 3600 * 1000) } });
  await gotoStudy(); await openTest(); await p.locator('.ct-start').click(); await p.waitForSelector('.dx-question-card');
  const eDoc = await chapterTestAttemptsCollection.findOne({ _id: new ObjectId(attemptE) });
  ok('abandoned real try: graded from what was saved', !!eDoc.result && eDoc.result.total === 6);
  ok('abandoned real try: counted as a try', (await questionIds()).history.length === 4, String((await questionIds()).history.length));
  await shot('12b-after-abandon');

  // 13. security: someone else's result, a bogus id, a result while open
  ok('result of an unknown id: 404', (await api('/attempts/000000000000000000000000')).status === 404);
  const openNow = (await questionIds()).openId;
  ok('review of an open try is refused (409)', (await api('/attempts/' + openNow)).status === 409);
  const startPub = (await api('/' + CH + '/A/start', { method: 'POST' })).body;
  ok('questions sent while testing carry no answer key', !JSON.stringify(startPub).includes('correctAnswerId') && !JSON.stringify(startPub).includes('choiceNotes'));
  await p.goto(SITE + '/test/result/' + openNow, { waitUntil: 'networkidle' }); await p.waitForTimeout(800);
  ok('result page for an open try: shows a clear message, not a blank page', (await p.locator('.dx-error').count()) > 0);
  await shot('13-result-while-open');
  ok('unknown chapter: 404', (await api('/not-a-chapter')).status === 404);
  ok('no page errors during the whole walk', pageErrors.length === 0, pageErrors.slice(0,3).join(' | '));
} catch (e) {
  log.push('CRASH  ' + e.message.split('\n')[0]);
  await shot('99-crash');
} finally {
  await b.close(); await revokeToken(token);
  await attempts.deleteMany({ email });   // leave no test tries behind
  console.log(log.join('\n'));
  const failed = log.filter((l) => !l.startsWith('PASS')).length;
  console.log(`\n${log.length - failed} passed, ${failed} failed`);
  process.exit(0);
}
