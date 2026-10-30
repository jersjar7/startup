// Mechanical checks for the chapter test bank. Fails (exit 1) on any error.
//
//   node scripts/ct-check.mjs statics-a      one version
//   node scripts/ct-check.mjs all            the whole bank
//
// Checks: schema, ids, answer key, distinct choices, KaTeX, figure component
// exists and renders, near-copies of any existing problem or of another
// chapter test question, counts and difficulty mix.
import katex from 'katex';
import { load, unitProblems, UNITS, mathSegments, tokens, jaccard } from './ct-lib.mjs';

const arg = process.argv[2];
if (!arg) { console.error('usage: node scripts/ct-check.mjs <unit|all>'); process.exit(2); }
const units = arg === 'all' ? UNITS : [arg];
if (units.some((u) => !UNITS.includes(u))) { console.error(`unknown unit ${arg}; one of ${UNITS.join(', ')}`); process.exit(2); }

const mod = await load();
const registry = new Set(mod.registry);
const existing = mod.existing().map((x) => ({ ...x, tok: tokens(x.statement) }));
const allNew = UNITS.flatMap((u) => unitProblems(mod, u).map((x) => ({ unit: u, id: x.id, tok: tokens(x.statement || '') })));

const pascal = (s) => s.split('-').map((w) => w[0].toUpperCase() + w.slice(1)).join('');
const SIM = 0.5; // error at or above
const NEAR = 0.38; // warn: read both and make sure it is not a reworded copy
let errors = 0;
let warnings = 0;
const err = (u, id, m) => { errors++; console.log(`ERROR ${u} ${id}: ${m}`); };
const warn = (u, id, m) => { warnings++; console.log(`warn  ${u} ${id}: ${m}`); };

for (const unit of units) {
  const ch = unit.slice(0, -2);
  const v = unit.slice(-1).toUpperCase();
  const list = unitProblems(mod, unit);
  const target = mod.TEST_LENGTH[ch];
  const prefix = `ct-${ch}-${v.toLowerCase()}-`;
  const figPrefix = `Ct${pascal(ch)}${v}`;
  const ids = new Set();
  const mix = { easy: 0, medium: 0, hard: 0 };
  const keys = { c1: 0, c2: 0, c3: 0, c4: 0 };

  for (const x of list) {
    const id = x.id || '(no id)';
    if (!x.id || !x.id.startsWith(prefix)) err(unit, id, `id must start with ${prefix}`);
    if (ids.has(x.id)) err(unit, id, 'duplicate id');
    ids.add(x.id);
    if (x.chapterId !== ch) err(unit, id, `chapterId must be '${ch}'`);
    if (x.version !== v) err(unit, id, `version must be '${v}'`);
    if (!['computational', 'conceptual'].includes(x.type)) err(unit, id, 'type must be computational or conceptual');
    if (!x.topic || typeof x.topic !== 'string') err(unit, id, 'topic (the NCEES knowledge area) is required');
    if (!x.statement || x.statement.length < 40) err(unit, id, 'statement missing or too short');
    if (!Array.isArray(x.choices) || x.choices.length !== 4) err(unit, id, 'needs exactly 4 choices');
    else {
      const cids = x.choices.map((c) => c.id).join(',');
      if (cids !== 'c1,c2,c3,c4') err(unit, id, `choice ids must be c1..c4, got ${cids}`);
      const texts = x.choices.map((c) => String(c.text).trim().toLowerCase());
      if (new Set(texts).size !== 4) err(unit, id, 'two choices have the same text');
      if (!Array.isArray(x.choiceNotes) || x.choiceNotes.length !== 4) err(unit, id, 'choiceNotes: one line per choice saying why it is right or which mistake gives it');
    }
    if (!['c1', 'c2', 'c3', 'c4'].includes(x.correctAnswerId)) err(unit, id, 'correctAnswerId must be c1..c4');
    else keys[x.correctAnswerId]++;
    if (!mix.hasOwnProperty(x.difficulty)) err(unit, id, 'difficulty must be easy, medium or hard');
    else mix[x.difficulty]++;
    if (!x.eli5) err(unit, id, 'eli5 (plain-English explanation) is required');
    if (!Array.isArray(x.steps) || x.steps.length < 2) err(unit, id, 'steps: at least 2');
    if (!('handbookPage' in x)) err(unit, id, "handbookPage is required (a verified 'p. N' or null when the handbook does not cover it)");
    else if (x.handbookPage !== null && !/^p\. \d+(?:[-–]\d+)?$/.test(x.handbookPage)) err(unit, id, `handbookPage must look like 'p. 94', got ${x.handbookPage}`);
    if (!Array.isArray(x.traps) || x.traps.length < 1) err(unit, id, 'traps: at least 1');
    if (/\\\$/.test(JSON.stringify(x))) err(unit, id, "escaped dollar sign; write the word 'dollars'");
    if (/[—]/.test(JSON.stringify(x))) warn(unit, id, 'em dash in text');

    const texts = [x.statement, x.eli5, x.hint, ...(x.choices || []).map((c) => c.text), ...(x.choiceNotes || []), ...(x.traps || []), ...(x.steps || []).map((s) => s.text)];
    for (const t of texts) for (const m of mathSegments(t)) {
      try { katex.renderToString(m, { throwOnError: true }); } catch (e) { err(unit, id, `KaTeX: ${m.slice(0, 60)} -> ${e.message.slice(0, 80)}`); }
    }
    for (const s of x.steps || []) if (s.latex) {
      try { katex.renderToString(s.latex, { throwOnError: true }); } catch (e) { err(unit, id, `KaTeX step: ${s.latex.slice(0, 60)} -> ${e.message.slice(0, 80)}`); }
    }

    if (x.diagram) {
      const c = x.diagram.component;
      if (!registry.has(c)) err(unit, id, `figure ${c} is not in the registry (add it to src/components/diagrams/chapter-tests/${unit}/index.js)`);
      else {
        if (!c.startsWith(figPrefix) && !mod.registry.includes(c)) err(unit, id, `new figures must be named ${figPrefix}...`);
        try {
          const svg = mod.render(c, x.diagram.props);
          if (!svg || !/viewBox="0 0 [\d.]+ [\d.]+"/.test(svg)) err(unit, id, `figure ${c} has no viewBox="0 0 W H"`);
        } catch (e) { err(unit, id, `figure ${c} throws: ${e.message.slice(0, 120)}`); }
      }
    } else if (x.diagram !== null) err(unit, id, 'diagram must be null or { component, props }');

    const tok = tokens(x.statement || '');
    let best = { s: 0 };
    for (const e of existing) { const s = jaccard(tok, e.tok); if (s > best.s) best = { s, id: e.id, bank: e.bank }; }
    if (best.s >= SIM) err(unit, id, `too close to existing ${best.bank} problem ${best.id} (${best.s.toFixed(2)})`);
    else if (best.s >= NEAR) warn(unit, id, `similar wording to existing ${best.bank} problem ${best.id} (${best.s.toFixed(2)}): make sure it is not the same problem`);
    for (const n of allNew) {
      if (n.id === x.id) continue;
      const s = jaccard(tok, n.tok);
      if (s >= SIM) err(unit, id, `too close to chapter test ${n.id} (${s.toFixed(2)})`);
    }
  }

  const n = list.length;
  const top = Math.max(...Object.values(keys));
  if (n && top / n > 0.4) warn(unit, '-', `answer key leans on one position: ${JSON.stringify(keys)}`);
  console.log(`${unit}: ${n} questions (test needs ${target}, aim ${target + 2}) · easy ${mix.easy} medium ${mix.medium} hard ${mix.hard} · keys ${JSON.stringify(keys)} · figures ${list.filter((x) => x.diagram).length}`);
  if (n < target) warn(unit, '-', `only ${n} of ${target} questions`);
}
console.log(`\n${errors} error(s), ${warnings} warning(s)`);
process.exit(errors ? 1 : 0);
