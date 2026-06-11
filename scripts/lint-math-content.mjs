#!/usr/bin/env node
// Content lint: flags prose words typeset as math-variable products — runs of
// 4+ letters inside $...$ that aren't wrapped in \text{}/\mathrm{}/known
// function names. Report-only (subscripts like E_{steel} and names like
// \tan are filtered); run before shipping new card/problem content:
//   node scripts/lint-math-content.mjs
import fs from 'node:fs';
import path from 'node:path';

const ROOTS = ['src/data/exam-bank', 'src/data/lessons', 'src/data/chapter-practice'];
const OVERRIDES = 'scripts/card-answer-overrides.json';
const KNOWN = new Set([
  'text', 'mathrm', 'operatorname', 'frac', 'sqrt', 'times', 'cdot', 'degree',
  'theta', 'alpha', 'beta', 'gamma', 'delta', 'sigma', 'omega', 'epsilon',
  'lambda', 'mu', 'phi', 'tan', 'sin', 'cos', 'arctan', 'arcsin', 'arccos',
  'Sigma', 'Phi', 'Omega', 'pi', 'rho', 'tau', 'nu', 'eta', 'psi', 'leq', 'geq',
  'log', 'ln', 'max', 'min', 'left', 'right', 'quad', 'qquad', 'Delta',
]);

let flagged = 0;
function scan(label, content) {
  for (const m of content.matchAll(/\$([^$]+)\$/g)) {
    let inner = m[1];
    inner = inner.replace(/\\(?:text|mathrm|operatorname)\s*\{[^}]*\}/g, ' ');
    inner = inner.replace(/\\[A-Za-z]+/g, ' '); // command names are never prose
    inner = inner.replace(/_\{[^}]{1,12}\}|_[A-Za-z0-9]/g, ' '); // subscripts are conventional
    for (const w of inner.matchAll(/[A-Za-z]{4,}/g)) {
      // all-caps runs are engineering initialism variables (BCWP, ACWP, NPSH)
      if (/^[A-Z]{2,6}$/.test(w[0])) continue;
      flagged++;
      console.log(`${label}: bare word "${w[0]}" in $${m[1].slice(0, 60)}$`);
    }
  }
}

for (const root of ROOTS) {
  for (const f of fs.readdirSync(root)) {
    if (!f.endsWith('.js')) continue;
    scan(path.join(root, f), fs.readFileSync(path.join(root, f), 'utf8'));
  }
}
const ov = JSON.parse(fs.readFileSync(OVERRIDES, 'utf8'));
for (const [id, o] of Object.entries(ov)) {
  if (o.answer) scan(`override:${id}`, o.answer);
  if (o.prompt) scan(`override:${id}`, o.prompt);
}
console.log(flagged ? `\n${flagged} bare words flagged` : 'clean');
process.exit(0);
