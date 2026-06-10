// Renders inline LaTeX (the `$...$` segments in our content) as native
// Unicode-styled text. Covers the math the PHONE actually shows — concept
// prompts and phone-calc choices (Greek, subscripts/superscripts, √, °, slash
// fractions). Heavy paper-tier math (integrals, stacked fractions) is flagged
// for paper, not displayed for solving, so a faithful KaTeX render isn't needed
// here. Pure + native → renders on every platform, offline, instantly.

const SUP: Record<string, string> = {
  '0': '⁰', '1': '¹', '2': '²', '3': '³', '4': '⁴', '5': '⁵', '6': '⁶', '7': '⁷', '8': '⁸', '9': '⁹',
  '+': '⁺', '-': '⁻', '=': '⁼', '(': '⁽', ')': '⁾', n: 'ⁿ', i: 'ⁱ', a: 'ᵃ', b: 'ᵇ', c: 'ᶜ', d: 'ᵈ',
  e: 'ᵉ', f: 'ᶠ', g: 'ᵍ', h: 'ʰ', j: 'ʲ', k: 'ᵏ', l: 'ˡ', m: 'ᵐ', o: 'ᵒ', p: 'ᵖ', r: 'ʳ', s: 'ˢ',
  t: 'ᵗ', u: 'ᵘ', v: 'ᵛ', w: 'ʷ', x: 'ˣ', y: 'ʸ', z: 'ᶻ',
};

const SUB: Record<string, string> = {
  '0': '₀', '1': '₁', '2': '₂', '3': '₃', '4': '₄', '5': '₅', '6': '₆', '7': '₇', '8': '₈', '9': '₉',
  '+': '₊', '-': '₋', '=': '₌', '(': '₍', ')': '₎', a: 'ₐ', e: 'ₑ', h: 'ₕ', i: 'ᵢ', j: 'ⱼ', k: 'ₖ',
  l: 'ₗ', m: 'ₘ', n: 'ₙ', o: 'ₒ', p: 'ₚ', r: 'ᵣ', s: 'ₛ', t: 'ₜ', u: 'ᵤ', v: 'ᵥ', x: 'ₓ',
};

const SYMBOLS: [string, string][] = [
  ['\\rightarrow', '→'], ['\\Rightarrow', '⇒'], ['\\partial', '∂'], ['\\approx', '≈'],
  ['\\propto', '∝'], ['\\parallel', '∥'], ['\\degree', '°'], ['\\equiv', '≡'], ['\\infty', '∞'],
  ['\\Delta', 'Δ'], ['\\Sigma', 'Σ'], ['\\Omega', 'Ω'], ['\\Gamma', 'Γ'], ['\\Phi', 'Φ'],
  ['\\theta', 'θ'], ['\\alpha', 'α'], ['\\beta', 'β'], ['\\gamma', 'γ'], ['\\delta', 'δ'],
  ['\\sigma', 'σ'], ['\\omega', 'ω'], ['\\lambda', 'λ'], ['\\rho', 'ρ'], ['\\tau', 'τ'],
  ['\\phi', 'φ'], ['\\psi', 'ψ'], ['\\eta', 'η'], ['\\nu', 'ν'], ['\\mu', 'μ'], ['\\pi', 'π'],
  ['\\epsilon', 'ε'], ['\\times', '×'], ['\\cdot', '·'], ['\\div', '÷'], ['\\pm', '±'],
  ['\\mp', '∓'], ['\\leq', '≤'], ['\\geq', '≥'], ['\\neq', '≠'], ['\\angle', '∠'],
  ['\\perp', '⊥'], ['\\circ', '°'], ['\\le', '≤'], ['\\ge', '≥'], ['\\to', '→'],
];

// Function/operator names → kept as plain text (otherwise the generic command
// strip would delete them, e.g. \arctan).
const FUNCTIONS = [
  'arcsin', 'arccos', 'arctan', 'sinh', 'cosh', 'tanh', 'sin', 'cos', 'tan', 'cot', 'sec', 'csc',
  'ln', 'log', 'exp', 'lim', 'min', 'max', 'det', 'deg', 'mod',
];

const mapAll = (s: string, table: Record<string, string>): string | null => {
  let out = '';
  for (const ch of s) {
    if (table[ch] === undefined) return null;
    out += table[ch];
  }
  return out;
};

// Read a balanced `{...}` starting at `open` (index of the `{`).
function readGroup(s: string, open: number): { content: string; end: number } | null {
  if (s[open] !== '{') return null;
  let depth = 0;
  for (let i = open; i < s.length; i++) {
    if (s[i] === '{') depth++;
    else if (s[i] === '}') {
      depth--;
      if (depth === 0) return { content: s.slice(open + 1, i), end: i + 1 };
    }
  }
  return null;
}

const wrap = (g: string): string => (/[\s+\-]/.test(g.trim()) ? `(${g.trim()})` : g.trim());

// \frac{A}{B} → A/B (parenthesising A or B when they contain operators), with
// balanced braces so nested sub/superscripts survive.
function resolveFracs(s: string): string {
  for (const name of ['\\dfrac', '\\tfrac', '\\frac']) {
    let idx = s.indexOf(name);
    while (idx !== -1) {
      const a = readGroup(s, idx + name.length);
      const b = a ? readGroup(s, a.end) : null;
      if (a && b) {
        s = s.slice(0, idx) + `${wrap(a.content)}/${wrap(b.content)}` + s.slice(b.end);
        idx = s.indexOf(name, idx);
      } else {
        idx = s.indexOf(name, idx + name.length);
      }
    }
  }
  return s;
}

// \sqrt[n]{X} → ⁿ√(X) ; \sqrt{X} → √(X), balanced braces.
function resolveSqrt(s: string): string {
  let idx = s.indexOf('\\sqrt');
  while (idx !== -1) {
    let p = idx + 5;
    let index = '';
    if (s[p] === '[') {
      const close = s.indexOf(']', p);
      if (close !== -1) {
        index = mapAll(s.slice(p + 1, close), SUP) ?? '';
        p = close + 1;
      }
    }
    const g = readGroup(s, p);
    if (g) {
      s = s.slice(0, idx) + `${index}√(${g.content})` + s.slice(g.end);
      idx = s.indexOf('\\sqrt', idx);
    } else {
      idx = s.indexOf('\\sqrt', idx + 5);
    }
  }
  return s;
}

function transformMath(input: string): string {
  let s = input;

  // \text{...} / \mathrm{...} → inner content
  s = s.replace(/\\(?:text|mathrm|mathbf|mathit|operatorname)\s*\{([^{}]*)\}/g, '$1');

  s = resolveFracs(s);
  s = resolveSqrt(s);

  for (const [k, v] of SYMBOLS) s = s.split(k).join(v);
  for (const fn of FUNCTIONS) s = s.split('\\' + fn).join(fn);

  // superscripts then subscripts
  s = s.replace(/\^\{([^{}]*)\}/g, (_m, g) => mapAll(g, SUP) ?? `^${g}`);
  s = s.replace(/\^(\\?[A-Za-z0-9+\-()])/g, (_m, g) => SUP[g] ?? `^${g}`);
  s = s.replace(/_\{([^{}]*)\}/g, (_m, g) => mapAll(g, SUB) ?? g);
  s = s.replace(/_(\\?[A-Za-z0-9+\-()])/g, (_m, g) => SUB[g] ?? g);

  s = s
    .replace(/\{,\}/g, ',')
    .replace(/\\left|\\right|\\!|\\,/g, '')
    .replace(/\\;|\\:|\\quad|\\qquad|~/g, ' ')
    .replace(/\\[A-Za-z]+/g, '') // drop any unmapped command
    .replace(/[{}]/g, '')
    .replace(/[ \t]{2,}/g, ' ');

  return s.trim();
}

/** Transform a content string, converting only its `$...$` math segments. */
export function latexToText(input: string): string {
  let out = '';
  let last = 0;
  const re = /\$([^$]*)\$/g;
  let m: RegExpExecArray | null;
  while ((m = re.exec(input)) !== null) {
    out += input.slice(last, m.index) + transformMath(m[1]);
    last = re.lastIndex;
  }
  out += input.slice(last);
  return out;
}
