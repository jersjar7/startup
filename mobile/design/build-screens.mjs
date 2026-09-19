// Generates reference-screens/html/*.html from tokens.json.
//
//   node build-screens.mjs          # writes the HTML
//   node render.mjs                 # screenshots them to reference-screens/png/
//
// Every screen is the app language of DESIGN.md applied to a feature the app
// actually has (or, for 04, one the owner has asked to see). Values here are
// the source of truth for the Flutter theme; keep them in tokens.json first.
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';

const T = JSON.parse(readFileSync(new URL('./tokens.json', import.meta.url)));
const C = T.color;
const F = {
  display: `'DM Sans', 'Helvetica Neue', Arial, sans-serif`,
  body: `'Inter', 'Helvetica Neue', Arial, sans-serif`,
  mono: `'JetBrains Mono', Menlo, Consolas, monospace`,
};

// The chapter marks are drawn by the app (chapter_marks.dart, 512-point
// designs). These are stand-ins at 24 units so the references show where a
// mark goes and how big; the real ones replace them.
const glyph = {
  mathematics: '<path d="M4 20V4M4 20h16"/><path d="M7 6c1.5 10 3.5 12 5 12s3.5-2 5-12"/>',
  statistics: '<path d="M3 19c6 0 6-14 9-14s3 14 9 14"/><path d="M12 5v14" stroke-dasharray="1.2 2.2"/>',
  ethics: '<path d="M12 4v16M7 20h10M5 8h14"/><path d="M5 8l-2.5 6h5zM19 8l-2.5 6h5z"/>',
  economics: '<path d="M3 17h18"/><path d="M8 17V10m5 7V8m5 9V6"/>',
  statics: '<path d="M3 17l5-9 5 9 5-9 3 9M3 17h18M8 8h10"/>',
  dynamics: '<path d="M3 18Q12 2 21 18"/><path d="M12 6v12" stroke-dasharray="1.2 2.2"/>',
  'mechanics-materials': '<path d="M3 15q9 4 18 0"/><path d="M12 5v7M10 10l2 2 2-2"/>',
  materials: '<path d="M4 20V4M4 20h16"/><path d="M4 20c2-10 4-14 6-14s5 2 9 1"/>',
  'fluid-mechanics': '<path d="M6 4v10a6 6 0 0 0 12 0V4"/><path d="M6 9h4M14 11h4"/>',
  surveying: '<path d="M5 8l9-4 5 8-10 7z"/>',
  'water-resources': '<path d="M3 6l4 12h10l4-12"/><path d="M5 11h14"/>',
  structural: '<path d="M4 20V8h16v12"/><path d="M6 8V5m4 3V5m4 3V5m4 3V5M4 5h16"/>',
  geotechnical: '<path d="M9 4v6h6V4M5 10h14"/><path d="M3 14h18"/><path d="M3 18h18" stroke-dasharray="2 2.5"/>',
  transportation: '<path d="M3 20C8 13 16 13 21 6"/><path d="M3 14C8 7 15 7 19 2"/>',
  construction: '<path d="M4 4h16M4 8h7M8 12h8M13 16h7"/>',
};
const chapters = [
  ['mathematics', 'Mathematics', 16], ['statistics', 'Probability & Statistics', 6],
  ['ethics', 'Ethics & Professional Practice', 7], ['economics', 'Engineering Economics', 6],
  ['statics', 'Statics', 7], ['dynamics', 'Dynamics', 6], ['mechanics-materials', 'Mechanics of Materials', 9],
  ['materials', 'Materials', 10], ['fluid-mechanics', 'Fluid Mechanics', 8], ['surveying', 'Surveying', 8],
  ['water-resources', 'Water Resources & Environmental', 11], ['structural', 'Structural Engineering', 11],
  ['geotechnical', 'Geotechnical Engineering', 12], ['transportation', 'Transportation Engineering', 11],
  ['construction', 'Construction Engineering', 7],
];
const mark = (id, color, size, stroke = 1.6) =>
  `<svg width="${size}" height="${size}" viewBox="0 0 24 24" fill="none" stroke="${color}" stroke-width="${stroke}" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${glyph[id]}</svg>`;

// ── primitives ──
const page = (title, ground, ink, body, extraCss = '') => `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=390">
<title>${title}</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=DM+Sans:opsz,wght@9..40,500;9..40,600;9..40,700;9..40,800&amp;family=Inter:wght@400;500;600&amp;family=JetBrains+Mono:wght@500;600;700&amp;display=swap">
<style>
body{margin:0;font-family:${F.body};background:${ground};color:${ink};-webkit-font-smoothing:antialiased}
a{color:${ink}}a:hover{color:${ink}}
a:focus-visible,button:focus-visible{outline:3px solid ${C.ember};outline-offset:3px}
button{font-family:inherit;cursor:pointer}
button:active,a:active{transform:scale(0.95)}
input::placeholder{color:${C.placeholder}}input:focus{outline:none}
@keyframes rise{from{transform:translateY(18px);opacity:0}to{transform:translateY(0);opacity:1}}
${extraCss}
</style>
</head>
<body>
<div style="width: 390px; height: 844px; box-sizing: border-box; position: relative; overflow: hidden; background: ${ground}; color: ${ink};">
${body}
</div>
</body>
</html>
`;

const eyebrow = (t, color = C.charcoal) =>
  `<span style="font-family: ${F.mono}; font-size: 12px; font-weight: 600; letter-spacing: 0.06em; text-transform: uppercase; color: ${color};">${t}</span>`;
const headline = (html, size = 48, color = C.charcoal) =>
  `<h1 style="margin: 0; font-family: ${F.display}; font-weight: 800; font-size: ${size}px; line-height: 0.98; letter-spacing: -0.045em; color: ${color}; text-wrap: balance;">${html}</h1>`;
const arrow = `<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"></path><path d="M13 6l6 6-6 6"></path></svg>`;
const chevronLeft = `<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M15 18l-6-6 6-6"></path></svg>`;

// Round icon button (back/close): charcoal on every light ground.
const roundIcon = (href, label, svg) =>
  `<a href="${href}" aria-label="${label}" style="display: flex; align-items: center; justify-content: center; width: 48px; height: 48px; margin-left: -4px; border-radius: 24px; background: ${C.charcoal}; color: ${C.cream}; text-decoration: none;">${svg}</a>`;
// Round next button: charcoal with a spring arrow on fog/cream; on spring, ember and sunbeam grounds also charcoal (ink on accent).
const roundNext = (href, label = 'Next') =>
  `<a href="${href}" aria-label="${label}" style="display: flex; align-items: center; justify-content: center; width: 72px; height: 72px; border-radius: 36px; background: ${C.charcoal}; color: ${C.spring}; text-decoration: none;">${arrow}</a>`;
// Pill CTA: on a light ground the pill is charcoal with a spring circle.
const pill = (href, label) => `
<a href="${href}" style="display: flex; align-items: center; justify-content: space-between; height: 72px; box-sizing: border-box; padding: 0 8px 0 28px; border-radius: 36px; background: ${C.charcoal}; color: ${C.cream}; text-decoration: none;">
<span style="font-family: ${F.display}; font-weight: 700; font-size: 22px; letter-spacing: -0.02em;">${label}</span>
<span style="display: flex; align-items: center; justify-content: center; width: 56px; height: 56px; border-radius: 28px; background: ${C.spring}; color: ${C.charcoal};">${arrow}</span>
</a>`;
const textAction = (href, label) =>
  `<a href="${href}" style="display: flex; align-items: center; height: 48px; font-size: 15px; font-weight: 600; color: ${C.charcoal}; text-decoration: underline; text-underline-offset: 4px;">${label}</a>`;
const steps = (n, at, onColor = C.charcoal) =>
  `<div style="flex-grow: 1; display: flex; gap: 6px;" aria-label="Step ${at} of ${n}">${Array.from({ length: n }, (_, i) => `<div style="width: ${i + 1 === at ? 36 : 8}px; height: 8px; border-radius: 4px; background: ${onColor}; opacity: ${i + 1 === at ? 1 : 0.35};"></div>`).join('')}</div>`;
const field = (id, label, placeholder, type = 'text', caption = '') => `
<div style="display: flex; flex-direction: column; gap: 12px;">
<label for="${id}" style="position: absolute; width: 1px; height: 1px; overflow: hidden; clip-path: inset(50%);">${label}</label>
<input id="${id}" type="${type}" placeholder="${placeholder}" style="width: 100%; box-sizing: border-box; height: 64px; padding: 0; border: none; border-bottom: 3px solid ${C.forest}; border-radius: 0; background: transparent; color: ${C.charcoal}; caret-color: ${C.forest}; font-family: ${F.display}; font-weight: 600; font-size: 30px; letter-spacing: -0.03em;">
${caption ? `<p style="margin: 0; font-size: 14px; line-height: 1.45; color: ${C.mutedOnLight};">${caption}</p>` : ''}
</div>`;
// The dock: a full-bleed cream bar with rounded top corners under the
// content (owner's call, 2026-09-18: a floating dark pill read as a second
// CTA and the content slid under it). Two labeled destinations, the active
// one a spring circle.
const DOCK_H = 106; // 12 + 54 + 4 + 16 label + 8, plus the 34 home-indicator inset below
const dock = (active) => {
  const item = (href, label, svgOff, svgOn, on) => `
<a href="${href}" aria-label="${label}"${on ? ' aria-current="page"' : ''} style="display: flex; flex-direction: column; align-items: center; gap: 4px; width: 96px; text-decoration: none; color: ${on ? C.charcoal : C.mutedOnLight};">
<span style="display: flex; align-items: center; justify-content: center; width: 54px; height: 54px; border-radius: 27px; ${on ? `background: ${C.spring}; color: ${C.charcoal};` : ''}">${on ? svgOn : svgOff}</span>
<span style="font-family: ${F.display}; font-size: 12px; font-weight: 600; letter-spacing: -0.01em;">${label}</span>
</a>`;
  const person = (fill) => `<svg width="24" height="24" viewBox="0 0 24 24" fill="${fill ? 'currentColor' : 'none'}" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8.5" r="3.5"></circle><path d="M5 20c1-4 4-5.5 7-5.5s6 1.5 7 5.5z"></path></svg>`;
  const book = (fill) => `<svg width="24" height="24" viewBox="0 0 24 24" fill="${fill ? 'currentColor' : 'none'}" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 5.5A2.5 2.5 0 0 1 6.5 3H12v16H6.5A2.5 2.5 0 0 0 4 21z"></path><path d="M20 5.5A2.5 2.5 0 0 0 17.5 3H12v16h5.5a2.5 2.5 0 0 1 2.5 2z"></path></svg>`;
  return `
<nav aria-label="Main" style="position: absolute; left: 0; right: 0; bottom: 0; box-sizing: border-box; padding: 12px 24px 42px; display: flex; align-items: flex-start; justify-content: space-around; border-radius: 40px 40px 0 0; background: ${C.cream}; box-shadow: 0 -6px 30px rgba(44,44,44,0.12);">
${item('08-home.html', 'Profile', person(false), person(true), active === 'profile')}
${item('09-study.html', 'Study', book(false), book(true), active === 'study')}
</nav>`;
};

// ── 01 welcome ──
const welcome = page('Welcome', C.fog, C.charcoal, `
<div style="position: absolute; top: 62px; left: 24px;">${eyebrow('FE for Raccoons', C.mutedOnLight)}</div>
<div aria-hidden="true" style="position: absolute; top: 112px; left: 24px; width: 200px; height: 236px; box-sizing: border-box; padding: 20px; border-radius: 30px; background: ${C.spring}; color: ${C.charcoal}; display: flex; flex-direction: column; transform: rotate(-6deg); animation: floatA 7s ease-in-out infinite;">
${eyebrow('Statics')}
<div style="flex-grow: 1; display: flex; align-items: center; justify-content: center;">${mark('statics', C.charcoal, 128, 1.15)}</div>
</div>
<div aria-hidden="true" style="position: absolute; top: 168px; right: -18px; width: 172px; height: 214px; box-sizing: border-box; padding: 20px; border-radius: 30px; background: ${C.peach}; color: ${C.charcoal}; display: flex; flex-direction: column; transform: rotate(8deg); animation: floatB 8s ease-in-out infinite;">
${eyebrow('Fluids')}
<div style="flex-grow: 1; display: flex; align-items: center; justify-content: center;">${mark('fluid-mechanics', C.charcoal, 112, 1.15)}</div>
</div>
<div aria-hidden="true" style="position: absolute; top: 394px; left: 98px; width: 196px; height: 122px; box-sizing: border-box; padding: 20px; border-radius: 28px; background: ${C.cream}; color: ${C.charcoal}; display: flex; flex-direction: column; justify-content: space-between; box-shadow: 0 18px 40px rgba(44,44,44,0.16); animation: floatC 6s ease-in-out infinite;">
${eyebrow('Concepts')}
<div style="display: flex; align-items: baseline; gap: 6px;"><span style="font-family: ${F.display}; font-weight: 800; font-size: 54px; line-height: 0.82; letter-spacing: -0.06em;">375</span><span style="font-family: ${F.display}; font-weight: 700; font-size: 16px;">free</span></div>
</div>
<div style="position: absolute; left: 24px; right: 24px; bottom: 34px; display: flex; flex-direction: column; gap: 22px;">
${headline('The FE Civil,<br>one concept at a time.', 44)}
${pill('02-create-email.html', "Let's go")}
<a href="03-log-in.html" style="align-self: center; font-size: 15px; font-weight: 500; color: ${C.mutedOnLight}; text-decoration: none;">I already have an account</a>
</div>`, `
@keyframes floatA{0%,100%{transform:rotate(-6deg) translateY(0)}50%{transform:rotate(-5deg) translateY(-8px)}}
@keyframes floatB{0%,100%{transform:rotate(8deg) translateY(0)}50%{transform:rotate(9deg) translateY(7px)}}
@keyframes floatC{0%,100%{transform:rotate(-2deg) translateY(0)}50%{transform:rotate(-3deg) translateY(-5px)}}`);

// ── 02 create account: email, password, check your email ──
const createEmail = page('Create account: email', C.fog, C.charcoal, `
<div style="box-sizing: border-box; padding: 56px 24px 0; display: flex; flex-direction: column; gap: 30px;">
<div style="display: flex; align-items: center; gap: 14px;">${roundIcon('01-welcome.html', 'Back', chevronLeft)}${steps(3, 1)}</div>
${headline(`First,<br><span style="color: ${C.forest};">your email.</span>`)}
${field('ca-email', 'Email', 'you@school.edu', 'email', 'Completely free. Your progress follows you to the website.')}
<div style="display: flex; align-items: center; justify-content: space-between;">
${textAction('03-log-in.html', 'Log in instead')}
${roundNext('02b-create-password.html')}
</div>
</div>`);

const createPassword = page('Create account: password', C.spring, C.charcoal, `
<div style="box-sizing: border-box; padding: 56px 24px 0; display: flex; flex-direction: column; gap: 30px;">
<div style="display: flex; align-items: center; gap: 14px;">${roundIcon('02-create-email.html', 'Back', chevronLeft)}${steps(3, 2)}</div>
${headline('Pick a<br>password.')}
${field('ca-password', 'Password', '••••••••', 'password', 'Eight characters or more. You can reset it by email any time.').replaceAll(C.forest, C.charcoal)}
<div style="display: flex; align-items: center; justify-content: flex-end;">
${roundNext('02c-check-email.html', 'Create account')}
</div>
</div>`);

const checkEmail = page('Create account: check your email', C.fog, C.charcoal, `
<div aria-hidden="true" style="position: absolute; top: 96px; left: 22px; width: 232px; height: 284px; box-sizing: border-box; padding: 22px; border-radius: 30px; background: ${C.spring}; opacity: 0.45; transform: rotate(-7deg);"></div>
<div aria-hidden="true" style="position: absolute; top: 160px; right: -26px; width: 206px; height: 246px; border-radius: 30px; background: ${C.peach}; opacity: 0.45; transform: rotate(9deg);"></div>
<div style="position: absolute; top: 56px; left: 24px; display: flex; align-items: center; gap: 14px; right: 24px;">${roundIcon('02b-create-password.html', 'Back', chevronLeft)}${steps(3, 3)}</div>
<div style="position: absolute; left: 0; right: 0; bottom: 0; box-sizing: border-box; padding: 12px 24px 34px; border-radius: 40px 40px 0 0; background: ${C.cream}; color: ${C.charcoal}; display: flex; flex-direction: column; gap: 22px; animation: sheetUp 0.5s cubic-bezier(0.2, 0.8, 0.2, 1) both;">
<div style="align-self: center; width: 44px; height: 5px; border-radius: 3px; background: ${C.charcoal}; opacity: 0.25;"></div>
<div style="display: flex; flex-direction: column; gap: 8px;">
${headline('Check your email.', 38)}
<p style="margin: 0; font-size: 16px; line-height: 1.4; color: ${C.mutedOnLight};">We sent a link to <strong style="color: ${C.charcoal};">you@school.edu</strong>. Tap it and you're in.</p>
</div>
<div style="display: flex; flex-direction: column; gap: 10px;">
<a href="#open-mail" style="display: flex; align-items: center; justify-content: center; height: 64px; border-radius: 32px; background: ${C.charcoal}; color: ${C.cream}; font-weight: 600; font-size: 17px; text-decoration: none;">Open email app</a>
<a href="#resend" style="display: flex; align-items: center; justify-content: center; height: 64px; box-sizing: border-box; border-radius: 32px; border: 2px solid ${C.charcoal}; color: ${C.charcoal}; font-weight: 600; font-size: 17px; text-decoration: none;">Resend link</a>
</div>
<div style="display: flex; align-items: center; justify-content: space-between;">
${textAction('02-create-email.html', 'Wrong email? Go back')}
<a href="08-home.html" style="display: flex; align-items: center; height: 44px; font-size: 14px; font-weight: 600; color: ${C.forest}; text-decoration: none;">Continue to the app</a>
</div>
</div>`, `@keyframes sheetUp{from{transform:translateY(60px);opacity:0}to{transform:translateY(0);opacity:1}}`);

// ── 03 log in ──
const logIn = page('Log in', C.fog, C.charcoal, `
<div aria-hidden="true" style="position: absolute; left: -24px; bottom: -84px; font-family: ${F.display}; font-weight: 800; font-size: 360px; line-height: 1; letter-spacing: -0.08em; color: ${C.creamDark};">FE</div>
<div style="position: relative; box-sizing: border-box; padding: 56px 24px 0; display: flex; flex-direction: column; gap: 30px;">
${roundIcon('01-welcome.html', 'Back', chevronLeft)}
${headline(`Hey again.<br><span style="color: ${C.forest};">What's your email?</span>`)}
${field('li-email', 'Email', 'you@school.edu', 'email', 'Your password comes next.')}
<div style="display: flex; align-items: center; justify-content: space-between;">
${textAction('#forgot', 'Forgot password?')}
${roundNext('08-home.html')}
</div>
</div>`);

// ── 04 exam date (Profile → Set your exam date) ──
const day = (wd, n, sel) => sel
  ? `<button type="button" aria-pressed="true" style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 4px; height: 92px; border: none; border-radius: 34px; background: ${C.charcoal}; color: ${C.spring};"><span style="font-family: ${F.mono}; font-size: 10px; font-weight: 600;">${wd}</span><span style="font-family: ${F.display}; font-size: 28px; font-weight: 800; letter-spacing: -0.03em;">${n}</span></button>`
  : `<button type="button" style="display: flex; flex-direction: column; align-items: center; justify-content: flex-end; gap: 6px; height: 92px; padding: 0 0 14px; box-sizing: border-box; border: none; background: transparent; color: ${C.charcoal};"><span style="font-family: ${F.mono}; font-size: 10px; font-weight: 600;">${wd}</span><span style="font-family: ${F.display}; font-size: 20px; font-weight: 800;">${n}</span></button>`;
const examDate = page('Profile: set your exam date', C.spring, C.charcoal, `
<div style="box-sizing: border-box; padding: 56px 24px 34px; height: 844px; display: flex; flex-direction: column;">
<div style="display: flex; align-items: center; gap: 14px;">${roundIcon('08-home.html', 'Back', chevronLeft)}</div>
<div style="margin-top: 30px;">${headline("When's the big day?")}</div>
<div style="flex-grow: 1;"></div>
<div style="display: flex; gap: 6px;">
${['Nov', 'Dec', 'Jan', 'Feb'].map((m, i) => `<button type="button" style="display: flex; align-items: center; justify-content: center; height: 40px; padding: 0 16px; border: none; border-radius: 20px; font-family: ${F.mono}; font-size: 13px; font-weight: 600; letter-spacing: 0.06em; text-transform: uppercase; ${i === 0 ? `background: ${C.charcoal}; color: ${C.spring};` : `background: transparent; color: ${C.charcoal}; opacity: 0.7;`}">${m}</button>`).join('')}
</div>
<div style="margin-top: 18px; font-family: ${F.display}; font-size: 96px; font-weight: 800; line-height: 0.9; letter-spacing: -0.06em;">Nov 28</div>
<div style="display: flex; align-items: center; gap: 12px; margin-top: 14px;">
${eyebrow('Saturday')}
<span style="display: flex; align-items: center; height: 34px; padding: 0 14px; border-radius: 17px; background: ${C.charcoal}; color: ${C.spring}; font-family: ${F.mono}; font-size: 13px; font-weight: 600;">73 days out</span>
</div>
<div style="display: grid; grid-template-columns: repeat(7, minmax(0, 1fr)); gap: 4px; margin-top: 30px;">
${day('WE', 25)}${day('TH', 26)}${day('FR', 27)}${day('SA', 28, true)}${day('SU', 29)}${day('MO', 30)}${day('TU', 1)}
</div>
<div style="display: flex; align-items: center; justify-content: space-between; margin-top: 34px;">
${textAction('08-home.html', 'No date yet')}
${roundNext('08-home.html', 'Save')}
</div>
</div>`);

// ── 05 try one: a real round from onboarding ──
const tryOne = page('Onboarding: try one', C.peach, C.charcoal, `
<div style="box-sizing: border-box; padding: 56px 24px 34px; height: 844px; display: flex; flex-direction: column;">
<div style="display: flex; align-items: center; gap: 14px;">${roundIcon('01-welcome.html', 'Back', chevronLeft)}${steps(3, 2)}${textAction('06-chapters.html', 'Skip')}</div>
<div style="margin-top: 30px; display: flex; justify-content: space-between;">${eyebrow('Statics · easy')}${eyebrow('1 / 3')}</div>
<div style="margin-top: 12px;">${headline('A crate, μ<sub style="font-size: 0.55em; vertical-align: -0.15em;">s</sub> = 0.40. Max friction force before it slides?', 40)}</div>
<div style="flex-grow: 1;"></div>
<div style="display: flex; flex-direction: column; gap: 10px;">
<button type="button" style="display: flex; align-items: center; justify-content: space-between; height: 76px; padding: 0 12px 0 26px; border: none; border-radius: 38px; background: ${C.cream}; color: ${C.charcoal}; font-family: ${F.display}; font-weight: 700; font-size: 24px; letter-spacing: -0.02em;"><span>200 N</span><span style="display: flex; align-items: center; justify-content: center; width: 52px; height: 52px; border-radius: 26px; border: 2px solid ${C.charcoal}; font-family: ${F.mono}; font-size: 13px; font-weight: 700;">A</span></button>
<button type="button" style="display: flex; align-items: center; justify-content: space-between; height: 76px; padding: 0 12px 0 26px; border: none; border-radius: 38px; background: ${C.cream}; color: ${C.charcoal}; font-family: ${F.display}; font-weight: 700; font-size: 24px; letter-spacing: -0.02em;"><span>500 N</span><span style="display: flex; align-items: center; justify-content: center; width: 52px; height: 52px; border-radius: 26px; border: 2px solid ${C.charcoal}; font-family: ${F.mono}; font-size: 13px; font-weight: 700;">B</span></button>
</div>
<div style="display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 4px; margin-top: 26px;" aria-label="Round 1 of 3">
<span style="height: 12px; border-radius: 6px; background: ${C.charcoal};"></span><span style="height: 12px; border-radius: 6px; background: ${C.pipOff};"></span><span style="height: 12px; border-radius: 6px; background: ${C.pipOff};"></span>
</div>
</div>`);

// ── 06 chapters: the peek, then sign up ──
const chaptersPeek = page('Onboarding: fifteen chapters', C.butter, C.charcoal, `
<div style="box-sizing: border-box; padding: 56px 24px 34px; height: 844px; display: flex; flex-direction: column;">
<div style="display: flex; align-items: center; gap: 14px;">${roundIcon('05-try-one.html', 'Back', chevronLeft)}${steps(3, 3)}</div>
<div style="margin-top: 30px;">${headline('Fifteen chapters.<br>Tap any.')}</div>
<p style="margin: 10px 0 0; font-size: 16px; font-weight: 500;">Nothing locks. Swipe to browse.</p>
<div style="position: relative; flex-grow: 1; margin-top: 30px;">
<div aria-hidden="true" style="position: absolute; inset: 16px 10px 0 10px; border-radius: 36px; background: ${C.charcoal}; transform: rotate(5deg);"></div>
<div aria-hidden="true" style="position: absolute; inset: 8px 4px 6px 4px; border-radius: 36px; background: ${C.spring}; transform: rotate(-3.5deg);"></div>
<div style="position: absolute; inset: 0 0 14px 0; box-sizing: border-box; padding: 26px; border-radius: 36px; background: ${C.cream}; display: flex; flex-direction: column; justify-content: space-between;">
<div style="display: flex; justify-content: space-between; align-items: center;">${eyebrow('05 / 15')}${eyebrow('8 to 12 exam questions', C.mutedOnLight)}</div>
<div style="display: flex; justify-content: center;">${mark('statics', C.forest, 150, 1.1)}</div>
<div style="display: flex; flex-direction: column; gap: 10px;">
<div style="font-family: ${F.display}; font-weight: 800; font-size: 46px; line-height: 0.98; letter-spacing: -0.045em;">Statics</div>
<div style="font-size: 15px; line-height: 1.4; color: ${C.mutedOnLight};">7 lessons · trusses, frames, centroids, friction</div>
</div>
</div>
</div>
<div style="margin-top: 26px;">${pill('02-create-email.html', 'Create my account')}</div>
</div>`);

// ── 08 home: the Profile tab, first thing you see ──
const pip = (on) => `<span style="height: 12px; border-radius: 6px; background: ${on ? C.charcoal : C.pipOff};"></span>`;
const home = page('Home (Profile tab)', C.fog, C.charcoal, `
<div style="box-sizing: border-box; height: 704px; overflow: hidden; padding: 58px 16px 0; display: flex; flex-direction: column; gap: 10px;">
<div style="display: flex; align-items: center; justify-content: space-between; padding: 0 8px 8px;">
<div style="font-family: ${F.display}; font-weight: 800; font-size: 30px; letter-spacing: -0.04em;">Morning, Jerson</div>
<a href="#account" aria-label="Account" style="display: flex; align-items: center; justify-content: center; width: 48px; height: 48px; border-radius: 24px; background: ${C.charcoal}; color: ${C.cream}; font-family: ${F.display}; font-weight: 700; font-size: 16px; text-decoration: none;">JG</a>
</div>
<a href="09-study.html" style="display: flex; flex-direction: column; justify-content: space-between; height: 252px; box-sizing: border-box; padding: 24px; border-radius: 36px; background: ${C.spring}; color: ${C.charcoal}; text-decoration: none; animation: rise 0.5s ease-out both;">
<div style="display: flex; justify-content: space-between;">${eyebrow('Statistics · lesson 1 of 6')}</div>
<div style="display: flex; align-items: flex-end; justify-content: space-between;">
<div style="display: flex; align-items: baseline; gap: 8px;"><span style="font-family: ${F.display}; font-weight: 800; font-size: 120px; line-height: 0.8; letter-spacing: -0.07em;">6</span><span style="font-family: ${F.display}; font-weight: 700; font-size: 28px; letter-spacing: -0.03em;">to go</span></div>
<span style="display: flex; align-items: center; justify-content: center; width: 76px; height: 76px; border-radius: 38px; background: ${C.charcoal}; color: ${C.spring};"><svg width="28" height="28" viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2" stroke-linejoin="round"><path d="M8 5l11 7-11 7z"></path></svg></span>
</div>
<div style="display: flex; flex-direction: column; gap: 10px;">
<div style="display: grid; grid-template-columns: repeat(6, minmax(0, 1fr)); gap: 4px;" aria-label="0 of 6 lessons done">${[0, 0, 0, 0, 0, 0].map(pip).join('')}</div>
<div style="font-size: 14px; font-weight: 500;">Up next: Measures of Central Tendency &amp; Dispersion</div>
</div>
</a>
<div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px;">
<a href="04-exam-date.html" style="display: flex; flex-direction: column; justify-content: space-between; height: 172px; box-sizing: border-box; padding: 20px; border-radius: 32px; background: ${C.cream}; color: ${C.charcoal}; text-decoration: none; animation: rise 0.5s 0.08s ease-out both;">
${eyebrow('Exam day')}
<div style="display: flex; flex-direction: column; gap: 4px;">
<div style="display: flex; align-items: baseline; gap: 6px;"><span style="font-family: ${F.display}; font-weight: 800; font-size: 68px; line-height: 0.82; letter-spacing: -0.06em;">73</span><span style="font-size: 15px; font-weight: 600;">days</span></div>
<div style="font-family: ${F.mono}; font-size: 12px; color: ${C.mutedOnLight};">Sat, Nov 28</div>
</div>
</a>
<div style="display: flex; flex-direction: column; justify-content: space-between; height: 172px; box-sizing: border-box; padding: 20px; border-radius: 32px; background: ${C.butter}; color: ${C.charcoal}; animation: rise 0.5s 0.14s ease-out both;">
${eyebrow('Days studied')}
<div style="display: flex; flex-direction: column; gap: 10px;">
<div style="display: flex; align-items: baseline; gap: 6px;"><span style="font-family: ${F.display}; font-weight: 800; font-size: 68px; line-height: 0.82; letter-spacing: -0.06em;">6</span><span style="font-size: 15px; font-weight: 600;">days</span></div>
<div style="display: grid; grid-template-columns: repeat(7, minmax(0, 1fr)); gap: 4px;" aria-hidden="true">${[1, 1, 1, 1, 1, 1].map(pip).join('')}<span style="height: 12px; box-sizing: border-box; border-radius: 6px; border: 2px solid ${C.charcoal};"></span></div>
</div>
</div>
</div>
<a href="#mastery" style="display: flex; align-items: center; gap: 16px; height: 96px; box-sizing: border-box; padding: 0 12px 0 22px; border-radius: 32px; background: ${C.tile}; color: ${C.cream}; text-decoration: none; animation: rise 0.5s 0.2s ease-out both;">
<span style="font-family: ${F.display}; font-weight: 800; font-size: 40px; letter-spacing: -0.05em; color: ${C.ember};">18%</span>
<span style="display: flex; flex-direction: column; gap: 3px; flex-grow: 1;"><span style="font-size: 17px; font-weight: 600;">Concept mastery</span><span style="font-size: 13px; color: ${C.mutedOnDark};">Not a probability of passing</span></span>
<span style="display: flex; align-items: center; justify-content: center; width: 52px; height: 52px; border-radius: 26px; background: ${C.tile2}; color: ${C.cream};"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18l6-6-6-6"></path></svg></span>
</a>
</div>
${dock('profile')}`);

// ── 09 study: one chapter ──
const toggle = (href, label, svg) =>
  `<a href="${href}" aria-label="${label}" style="display: flex; align-items: center; justify-content: center; width: 48px; height: 48px; border-radius: 24px; background: ${C.charcoal}; color: ${C.cream}; text-decoration: none;">${svg}</a>`;
const gridIcon = `<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="4" width="7" height="7" rx="2"></rect><rect x="13" y="4" width="7" height="7" rx="2"></rect><rect x="4" y="13" width="7" height="7" rx="2"></rect><rect x="13" y="13" width="7" height="7" rx="2"></rect></svg>`;
const oneIcon = `<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="4" width="16" height="16" rx="4"></rect></svg>`;
const study = page('Study: one chapter', C.fog, C.charcoal, `
<div style="box-sizing: border-box; height: 704px; padding: 58px 24px 0; display: flex; flex-direction: column; gap: 18px;">
<div style="display: flex; align-items: center; justify-content: space-between;">${eyebrow('73 days to the exam', C.mutedOnLight)}${toggle('10-study-grid.html', 'All chapters', gridIcon)}</div>
<div style="display: flex; flex-direction: column; justify-content: space-between; flex-grow: 1; box-sizing: border-box; padding: 24px; border-radius: 36px; background: ${C.cream}; animation: rise 0.5s ease-out both;">
<div style="display: flex; justify-content: space-between;">${eyebrow('Chapter 2')}${eyebrow('4 to 6 on the exam', C.mutedOnLight)}</div>
<div style="display: flex; justify-content: center;"><span style="display: flex; align-items: center; justify-content: center; width: 176px; height: 176px; border-radius: 88px; background: ${C.spring};">${mark('statistics', C.charcoal, 108, 1.15)}</span></div>
<div style="display: flex; flex-direction: column; gap: 10px;">
${headline('Probability &amp; Statistics', 40)}
<div style="font-family: ${F.mono}; font-size: 13px; color: ${C.mutedOnLight};">6 lessons · next: Measures of Central Tendency</div>
</div>
</div>
${pill('#chapter', 'Start')}
<div style="display: flex; justify-content: center; gap: 6px;" aria-label="Chapter 2 of 15">${chapters.map((_, i) => `<span style="width: ${i === 1 ? 7 : 5}px; height: ${i === 1 ? 7 : 5}px; border-radius: 4px; background: ${C.charcoal}; opacity: ${i === 1 ? 1 : 0.25};"></span>`).join('')}</div>
</div>
${dock('study')}`);

// ── 10 study: the grid ──
const studyGrid = page('Study: all chapters', C.fog, C.charcoal, `
<div style="box-sizing: border-box; height: 704px; overflow: hidden; padding: 58px 16px 0; display: flex; flex-direction: column; gap: 16px;">
<div style="display: flex; align-items: center; justify-content: space-between; padding: 0 8px;">${eyebrow('73 days to the exam', C.mutedOnLight)}${toggle('09-study.html', 'One chapter', oneIcon)}</div>
<div style="display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 8px;">
${chapters.map(([id, name, lessons], i) => { const cur = i === 1; const done = i === 0 ? 3 : 0; return `
<a href="09-study.html" style="display: flex; flex-direction: column; justify-content: space-between; height: 116px; box-sizing: border-box; padding: 14px 12px 12px; border-radius: 24px; background: ${cur ? C.spring : C.cream}; color: ${C.charcoal}; text-decoration: none; animation: rise 0.5s ${(i * 0.03).toFixed(2)}s ease-out both;">
${mark(id, cur || done ? C.charcoal : C.mutedOnLight, 28, 1.6)}
<div style="display: flex; flex-direction: column; gap: 3px;">
<span style="font-family: ${F.display}; font-weight: 700; font-size: 11.5px; line-height: 1.15; letter-spacing: -0.02em; display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden;">${name.replace('&', '&amp;').replace('Mathematics', 'Mathematics')}</span>
<span style="font-family: ${F.mono}; font-size: 10px; font-weight: 600; color: ${done ? C.forest : cur ? C.charcoal : C.mutedOnLight};">${done}/${lessons}</span>
</div>
</a>`; }).join('')}
</div>
</div>
${dock('study')}`);


// ── 00 splash ──
const splash = page('Splash', C.fog, C.charcoal, `
<div style="height: 844px; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 14px;">
<div style="display: flex; align-items: center; gap: 12px;">
<span style="display: block; width: 18px; height: 18px; border-radius: 9px; background: ${C.spring};"></span>
<span style="font-family: ${F.display}; font-weight: 800; font-size: 40px; letter-spacing: -0.045em;">FE for Raccoons</span>
</div>
</div>`);

// ── 05b the paper hand-off (onboarding slide 3, "Some problems belong on paper") ──
const handOff = page('Onboarding: the paper hand-off', C.fog, C.charcoal, `
<div style="box-sizing: border-box; padding: 56px 24px 34px; height: 844px; display: flex; flex-direction: column;">
<div style="display: flex; align-items: center; gap: 14px;">${roundIcon('05-try-one.html', 'Back', chevronLeft)}${steps(3, 2)}${textAction('06-chapters.html', 'Skip')}</div>
<div style="margin-top: 30px;">${headline('Some problems<br>belong on paper.')}</div>
<p style="margin: 12px 0 0; font-size: 16px; line-height: 1.45; color: ${C.mutedOnLight};">When a question needs real working, the app says so and saves it for your desk. No faking it on a phone.</p>
<div style="flex-grow: 1;"></div>
<div style="display: flex; flex-direction: column; gap: 18px; box-sizing: border-box; padding: 24px; border-radius: 36px; background: ${C.cream};">
<div style="display: flex; justify-content: space-between;">${eyebrow('Saved for your desk')}${eyebrow('Statics', C.mutedOnLight)}</div>
<div style="font-family: ${F.display}; font-weight: 700; font-size: 22px; line-height: 1.15; letter-spacing: -0.03em;">Find the force in member BC of the truss.</div>
<div style="font-size: 14px; line-height: 1.45; color: ${C.mutedOnLight};">Table lookups, real working. Method of sections, three equations.</div>
<a href="06-chapters.html" style="display: flex; align-items: center; justify-content: space-between; height: 72px; box-sizing: border-box; padding: 0 8px 0 28px; border-radius: 36px; background: ${C.peach}; color: ${C.charcoal}; text-decoration: none;">
<span style="font-family: ${F.display}; font-weight: 700; font-size: 22px; letter-spacing: -0.02em;">Now grab paper</span>
<span style="display: flex; align-items: center; justify-content: center; width: 56px; height: 56px; border-radius: 28px; background: ${C.charcoal}; color: ${C.ember};">${arrow}</span>
</a>
</div>
<div style="display: flex; justify-content: flex-end; margin-top: 26px;">${roundNext('06-chapters.html')}</div>
</div>`);

// ── 03b forgot password ──
const forgot = page('Forgot password', C.fog, C.charcoal, `
<div style="position: relative; box-sizing: border-box; padding: 56px 24px 0; display: flex; flex-direction: column; gap: 30px;">
${roundIcon('03-log-in.html', 'Back', chevronLeft)}
${headline(`Reset your<br><span style="color: ${C.forest};">password.</span>`)}
${field('fp-email', 'Email', 'you@school.edu', 'email', "We'll email you a reset link.")}
<div style="display: flex; align-items: center; justify-content: space-between;">
${textAction('03-log-in.html', 'Back to log in')}
${roundNext('03-log-in.html', 'Send reset link')}
</div>
</div>`);

// ── 11 chapter map: the path ──
const node = (x, y, state, label, sub, side) => {
  const circle = state === 'cleared'
    ? `<span style="display: flex; align-items: center; justify-content: center; width: 84px; height: 84px; border-radius: 42px; background: ${C.charcoal}; color: ${C.spring};"><svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12.5l4.5 4.5L19 7.5"></path></svg></span>`
    : state === 'current'
      ? `<span style="position: relative; display: flex; align-items: center; justify-content: center; width: 84px; height: 84px; border-radius: 42px; background: ${C.spring};"><span style="width: 62px; height: 62px; border-radius: 31px; background: ${C.cream};"></span><span style="position: absolute; inset: 0; border-radius: 42px; background: conic-gradient(${C.charcoal} 0 33%, transparent 33% 100%); mask: radial-gradient(circle, transparent 30px, black 31px); -webkit-mask: radial-gradient(circle, transparent 30px, black 31px);"></span></span>`
      : `<span style="display: block; width: 84px; height: 84px; border-radius: 42px; background: ${C.cream};"></span>`;
  const tile = `<span style="display: flex; flex-direction: column; gap: 3px; width: 150px; box-sizing: border-box; padding: 12px 14px; border-radius: 20px; background: ${state === 'current' ? C.spring : C.cream}; color: ${C.charcoal};"><span style="font-family: ${F.display}; font-weight: 700; font-size: 13.5px; line-height: 1.15; letter-spacing: -0.02em;">${label}</span><span style="font-family: ${F.mono}; font-size: 10px; color: ${state === 'untouched' ? C.mutedOnLight : state === 'current' ? C.charcoal : C.forest};">${sub}</span></span>`;
  return `<div style="position: absolute; top: ${y}px; ${side === 'right' ? `left: ${x}px;` : `right: ${390 - x}px;`} display: flex; align-items: center; gap: 12px; ${side === 'right' ? '' : 'flex-direction: row-reverse;'}">${circle}${tile}</div>`;
};
const chapterMap = page('Chapter map', C.fog, C.charcoal, `
<div style="box-sizing: border-box; padding: 56px 24px 0; display: flex; flex-direction: column; gap: 16px;">
<div style="display: flex; align-items: center; justify-content: space-between;">${roundIcon('09-study.html', 'Back', chevronLeft)}${eyebrow('Chapter 1', C.mutedOnLight)}</div>
${headline('Mathematics &amp; Computational Tools', 34)}
<div style="display: flex; gap: 8px;">
<span style="display: flex; align-items: center; height: 34px; padding: 0 14px; border-radius: 17px; background: ${C.charcoal}; color: ${C.spring}; font-family: ${F.mono}; font-size: 12px; font-weight: 600;">3 of 16 cleared</span>
<span style="display: flex; align-items: center; height: 34px; padding: 0 14px; border-radius: 17px; background: ${C.cream}; color: ${C.charcoal}; font-family: ${F.mono}; font-size: 12px; font-weight: 600;">11 to 17 on the exam</span>
</div>
</div>
<div style="position: relative; height: 600px; margin-top: 18px; overflow: hidden;">
<svg aria-hidden="true" width="390" height="600" viewBox="0 0 390 600" style="position: absolute; inset: 0;" fill="none">
<path d="M150 78 C 230 78, 250 146, 240 196 S 140 286, 140 336 S 250 416, 240 466 S 150 536, 150 578" stroke="${C.charcoal}" stroke-width="14" stroke-linecap="round"></path>
<path d="M150 78 C 230 78, 250 146, 240 196 S 140 286, 140 336" stroke="${C.spring}" stroke-width="6" stroke-linecap="round" stroke-dasharray="14 12"></path>
</svg>
<div style="position: absolute; top: 0; left: 24px;">${eyebrow('Analytic geometry · 6', C.mutedOnLight)}</div>
${node(108, 36, 'cleared', 'Straight Lines &amp; Quadratics', 'all 3 done', 'right')}
${node(282, 154, 'cleared', 'Logarithms', 'all 3 done', 'left')}
${node(98, 294, 'current', 'Right Triangle Trigonometry', '1 of 3 done', 'right')}
${node(282, 424, 'untouched', 'Law of Sines &amp; Law of Cosines', '0 of 3 done', 'left')}
${node(108, 536, 'untouched', 'Unit Circle &amp; Trig Identities', '0 of 3 done', 'right')}
</div>`);

// ── 12 lesson sheet (tap a node) ──
const lessonSheet = page('Lesson sheet', C.fog, C.charcoal, `
<div aria-hidden="true" style="position: absolute; inset: 0; opacity: 0.35; background: ${C.fog};"></div>
<div style="position: absolute; left: 0; right: 0; bottom: 0; box-sizing: border-box; padding: 12px 24px 34px; border-radius: 40px 40px 0 0; background: ${C.cream}; color: ${C.charcoal}; display: flex; flex-direction: column; gap: 20px; animation: sheetUp 0.5s cubic-bezier(0.2, 0.8, 0.2, 1) both;">
<div style="align-self: center; width: 44px; height: 5px; border-radius: 3px; background: ${C.charcoal}; opacity: 0.25;"></div>
<div style="display: flex; flex-direction: column; gap: 8px;">
${eyebrow('Lesson 3 · 1 of 3 done', C.mutedOnLight)}
${headline('Right Triangle Trigonometry', 34)}
</div>
<div style="display: flex; flex-direction: column; gap: 10px;">
${[['Tap the Side', 'Name the side the ratio wants.', 'done'], ['Which Ratio', 'Pick sin, cos or tan for the sides you have.', 'next'], ['Resolve It', 'Split a force into its two components.', 'todo']].map(([n, b, s]) => `
<a href="13-game-round.html" style="display: flex; align-items: center; gap: 14px; box-sizing: border-box; padding: 16px 12px 16px 20px; border-radius: 24px; background: ${s === 'next' ? C.spring : C.creamDark}; color: ${C.charcoal}; text-decoration: none;">
<span style="display: flex; flex-direction: column; gap: 3px; flex-grow: 1;"><span style="font-family: ${F.display}; font-weight: 700; font-size: 17px; letter-spacing: -0.02em;">${n}</span><span style="font-size: 13px; color: ${s === 'next' ? C.charcoal : C.mutedOnLight};">${b}</span></span>
<span style="display: flex; align-items: center; justify-content: center; width: 44px; height: 44px; border-radius: 22px; background: ${C.charcoal}; color: ${s === 'next' ? C.spring : C.cream};">${s === 'done' ? `<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12.5l4.5 4.5L19 7.5"></path></svg>` : `<svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M8 5l11 7-11 7z"></path></svg>`}</span>
</a>`).join('')}
</div>
<a href="14-lesson-brief.html" style="display: flex; align-items: center; justify-content: center; height: 64px; box-sizing: border-box; border-radius: 32px; border: 2px solid ${C.charcoal}; color: ${C.charcoal}; font-weight: 600; font-size: 17px; text-decoration: none;">Read the concept first</a>
</div>`, `@keyframes sheetUp{from{transform:translateY(60px);opacity:0}to{transform:translateY(0);opacity:1}}`);

// ── 13 a game round: the shared frame in the new language, the board as it is ──
const gameHeader = (done, total, count) => `
<div style="display: flex; align-items: center; gap: 14px;">
${roundIcon('12-lesson-sheet.html', 'Close', `<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M6 6l12 12"></path><path d="M18 6L6 18"></path></svg>`)}
<div style="flex-grow: 1; display: grid; grid-template-columns: repeat(${total}, minmax(0, 1fr)); gap: 4px;" aria-label="${count} of ${total}">${Array.from({ length: total }, (_, i) => `<span style="height: 12px; border-radius: 6px; background: ${i < done ? C.charcoal : C.pipOff};"></span>`).join('')}</div>
${eyebrow(count + ' / ' + total)}
<a href="14-lesson-brief.html" aria-label="The concept" style="display: flex; align-items: center; justify-content: center; width: 48px; height: 48px; border-radius: 24px; background: ${C.cream}; color: ${C.charcoal}; text-decoration: none;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 5.5A2.5 2.5 0 0 1 6.5 3H12v16H6.5A2.5 2.5 0 0 0 4 21z"></path><path d="M20 5.5A2.5 2.5 0 0 0 17.5 3H12v16h5.5a2.5 2.5 0 0 1 2.5 2z"></path></svg></a>
</div>`;
const figure = (slope) => `
<div style="height: 210px; border-radius: 24px; background-color: #FDFCF8; background-image: linear-gradient(rgba(100,160,140,0.10) 1px, transparent 1px), linear-gradient(90deg, rgba(100,160,140,0.10) 1px, transparent 1px), linear-gradient(rgba(100,160,140,0.05) 1px, transparent 1px), linear-gradient(90deg, rgba(100,160,140,0.05) 1px, transparent 1px); background-size: 40px 40px, 40px 40px, 8px 8px, 8px 8px; position: relative; overflow: hidden;">
<svg width="342" height="210" viewBox="0 0 342 210" fill="none" style="position: absolute; inset: 0;"><path d="${slope}" stroke="${C.charcoal}" stroke-width="3" stroke-linecap="round"></path><circle cx="171" cy="105" r="5" fill="#FDFCF8" stroke="${C.charcoal}" stroke-width="2.5"></circle></svg>
</div>`;
const boardBody = (built, tone) => `
<div style="display: flex; flex-direction: column; gap: 6px;">${eyebrow('Lay it perpendicular', C.forest)}
<div style="font-size: 17px; line-height: 1.35; font-weight: 500;">A retaining wall falls away at this slope. The tieback anchor runs perpendicular into the soil behind it.</div></div>
${figure('M40 20 L302 190')}
<div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px;">
<div style="display: flex; flex-direction: column; gap: 4px;">${eyebrow('Boundary', C.mutedOnLight)}<span style="font-family: ${F.mono}; font-size: 22px; font-weight: 600;">m = -3/4</span></div>
<div style="display: flex; flex-direction: column; gap: 4px;">${eyebrow('You built', C.mutedOnLight)}<span style="font-family: ${F.mono}; font-size: 22px; font-weight: 600; color: ${tone};">m = ${built}</span></div>
</div>`;
const choice = (title, sub, on) => `
<button type="button" aria-pressed="${on}" style="display: flex; align-items: center; gap: 14px; box-sizing: border-box; padding: 0 12px 0 22px; height: 64px; border: none; border-radius: 32px; background: ${on ? C.charcoal : C.cream}; color: ${on ? C.cream : C.charcoal}; text-align: left;">
<span style="display: flex; flex-direction: column; gap: 2px; flex-grow: 1;"><span style="font-family: ${F.display}; font-weight: 700; font-size: 16px; letter-spacing: -0.02em;">${title}</span><span style="font-size: 12.5px; color: ${on ? C.mutedOnDark : C.mutedOnLight};">${sub}</span></span>
<span style="display: block; width: 26px; height: 26px; box-sizing: border-box; border-radius: 13px; ${on ? `background: ${C.spring};` : `border: 2px solid ${C.charcoal}; opacity: 0.35;`}"></span>
</button>`;
const gameRound = page('Game round', C.fog, C.charcoal, `
<div style="box-sizing: border-box; padding: 56px 24px 34px; height: 844px; display: flex; flex-direction: column; gap: 18px;">
${gameHeader(1, 8, 2)}
${boardBody('-3/4', C.ember)}
<div style="flex-grow: 1;"></div>
<div style="display: flex; flex-direction: column; gap: 8px;">${choice('Flip the fraction', 'Swap rise and run', true)}${choice('Change the sign', 'Plus becomes minus, minus becomes plus', false)}</div>
${pill('13b-game-answered.html', 'Confirm this line')}
</div>`);

// ── 13b the same round, answered right ──
const gameAnswered = page('Game round: answered', C.fog, C.charcoal, `
<div style="box-sizing: border-box; padding: 56px 24px 34px; height: 844px; display: flex; flex-direction: column; gap: 18px;">
${gameHeader(2, 8, 2)}
${boardBody('4/3', C.forest)}
<div style="flex-grow: 1;"></div>
<div style="display: flex; flex-direction: column; gap: 8px; box-sizing: border-box; padding: 20px 22px; border-radius: 28px; background: ${C.spring}; color: ${C.charcoal}; animation: rise 0.4s ease-out both;">
<div style="font-family: ${F.display}; font-weight: 800; font-size: 26px; letter-spacing: -0.03em;">Perpendicular.</div>
<div style="font-size: 14px; line-height: 1.45;">Flip 3/4 to 4/3 and change the sign: the two lines now cross at a right angle. Doing only one of the two gives a plausible wrong line.</div>
</div>
${pill('13c-game-done.html', 'Next')}
</div>`);

// ── 13c the done screen ──
const gameDone = page('Game done', C.fog, C.charcoal, `
<div style="box-sizing: border-box; padding: 56px 24px 34px; height: 844px; display: flex; flex-direction: column;">
<div style="display: flex; align-items: center; gap: 14px;">${roundIcon('12-lesson-sheet.html', 'Close', `<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M6 6l12 12"></path><path d="M18 6L6 18"></path></svg>`)}</div>
<div style="flex-grow: 1;"></div>
<div style="display: flex; flex-direction: column; justify-content: space-between; height: 300px; box-sizing: border-box; padding: 24px; border-radius: 36px; background: ${C.spring}; color: ${C.charcoal}; animation: rise 0.5s ease-out both;">
<div style="display: flex; justify-content: space-between;">${eyebrow('All done')}${eyebrow('Perpendicular Flip')}</div>
<div style="display: flex; align-items: baseline; gap: 8px;"><span style="font-family: ${F.display}; font-weight: 800; font-size: 120px; line-height: 0.8; letter-spacing: -0.07em;">8</span><span style="font-family: ${F.display}; font-weight: 700; font-size: 28px; letter-spacing: -0.03em;">of 8</span></div>
<div style="font-size: 15px; font-weight: 500;">6 on the first try. The two you missed came back and you got them.</div>
</div>
<div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px; margin-top: 10px;">
<div style="display: flex; flex-direction: column; justify-content: space-between; height: 132px; box-sizing: border-box; padding: 18px; border-radius: 32px; background: ${C.cream};">${eyebrow('First try')}<div style="display: flex; align-items: baseline; gap: 6px;"><span style="font-family: ${F.display}; font-weight: 800; font-size: 56px; line-height: 0.82; letter-spacing: -0.06em;">6</span><span style="font-size: 14px; font-weight: 600;">of 8</span></div></div>
<div style="display: flex; flex-direction: column; justify-content: space-between; height: 132px; box-sizing: border-box; padding: 18px; border-radius: 32px; background: ${C.butter};">${eyebrow('Lesson')}<div style="display: flex; align-items: baseline; gap: 6px;"><span style="font-family: ${F.display}; font-weight: 800; font-size: 56px; line-height: 0.82; letter-spacing: -0.06em;">2</span><span style="font-size: 14px; font-weight: 600;">of 3 done</span></div></div>
</div>
<div style="flex-grow: 1;"></div>
<div style="display: flex; align-items: center; justify-content: space-between; gap: 14px;">
${textAction('13-game-round.html', 'Start over')}
<div style="flex-grow: 1;">${pill('11-chapter-map.html', 'Done')}</div>
</div>
</div>`);

// ── 14 the lesson brief (the concept card behind the book icon) ──
const lessonBrief = page('Lesson brief', C.fog, C.charcoal, `
<div style="box-sizing: border-box; padding: 56px 24px 34px; height: 844px; display: flex; flex-direction: column; gap: 22px;">
<div style="display: flex; align-items: center; gap: 14px;">${roundIcon('13-game-round.html', 'Back', chevronLeft)}${eyebrow('The concept · handbook p. 36', C.mutedOnLight)}</div>
${headline('Parallel and perpendicular', 38)}
<div style="display: flex; flex-direction: column; gap: 14px; box-sizing: border-box; padding: 22px; border-radius: 32px; background: ${C.cream};">
<p style="margin: 0; font-size: 16px; line-height: 1.5;">Parallel lines never meet, and that is the same as saying they have the same slope. Perpendicular lines cross at a right angle, and their slopes are negative reciprocals: flip the fraction and change the sign. Doing only one of the two gets you a line that looks plausible and is wrong.</p>
<div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px;">
<div style="display: flex; flex-direction: column; gap: 8px; box-sizing: border-box; padding: 16px; border-radius: 22px; background: ${C.creamDark};">${eyebrow('Parallel', C.mutedOnLight)}<span style="font-family: ${F.mono}; font-size: 20px; font-weight: 600;">m₁ = m₂</span></div>
<div style="display: flex; flex-direction: column; gap: 8px; box-sizing: border-box; padding: 16px; border-radius: 22px; background: ${C.creamDark};">${eyebrow('Perpendicular', C.mutedOnLight)}<span style="font-family: ${F.mono}; font-size: 20px; font-weight: 600;">m⊥ = −1/m</span></div>
</div>
</div>
<div style="flex-grow: 1;"></div>
<div style="font-size: 14px; line-height: 1.45; color: ${C.mutedOnLight};">Knowing this is not the same as solving with it. The full problems belong at a desk, on paper.</div>
${pill('13-game-round.html', 'Back to the round')}
</div>`);

// ── 15 account sheet (the avatar on home) ──
const accountSheet = page('Account sheet', C.fog, C.charcoal, `
<div aria-hidden="true" style="position: absolute; inset: 0; opacity: 0.35; background: ${C.fog};"></div>
<div style="position: absolute; left: 0; right: 0; bottom: 0; box-sizing: border-box; padding: 12px 24px 34px; border-radius: 40px 40px 0 0; background: ${C.cream}; color: ${C.charcoal}; display: flex; flex-direction: column; gap: 22px; animation: sheetUp 0.5s cubic-bezier(0.2, 0.8, 0.2, 1) both;">
<div style="align-self: center; width: 44px; height: 5px; border-radius: 3px; background: ${C.charcoal}; opacity: 0.25;"></div>
<div style="display: flex; align-items: center; gap: 14px;">
<span style="display: flex; align-items: center; justify-content: center; width: 56px; height: 56px; border-radius: 28px; background: ${C.charcoal}; color: ${C.cream}; font-family: ${F.display}; font-weight: 700; font-size: 18px;">JG</span>
<span style="display: flex; flex-direction: column; gap: 2px;"><span style="font-family: ${F.display}; font-weight: 800; font-size: 24px; letter-spacing: -0.03em;">Jerson Garcia</span><span style="font-family: ${F.mono}; font-size: 12px; color: ${C.mutedOnLight};">jerson@example.com</span></span>
</div>
<div style="display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 10px;">
${[['Total XP', '1,240'], ['Badges', '3'], ['Concepts', '14']].map(([k, v]) => `<div style="display: flex; flex-direction: column; gap: 8px; box-sizing: border-box; padding: 14px; border-radius: 22px; background: ${C.creamDark};">${eyebrow(k, C.mutedOnLight)}<span style="font-family: ${F.display}; font-weight: 800; font-size: 26px; line-height: 0.9; letter-spacing: -0.04em;">${v}</span></div>`).join('')}
</div>
<div style="display: flex; flex-direction: column; gap: 10px;">
<a href="#website" style="display: flex; align-items: center; justify-content: center; height: 64px; border-radius: 32px; background: ${C.charcoal}; color: ${C.cream}; font-weight: 600; font-size: 17px; text-decoration: none;">Open the website</a>
<a href="04-exam-date.html" style="display: flex; align-items: center; justify-content: center; height: 64px; box-sizing: border-box; border-radius: 32px; border: 2px solid ${C.charcoal}; color: ${C.charcoal}; font-weight: 600; font-size: 17px; text-decoration: none;">Set your exam date</a>
<a href="01-welcome.html" style="display: flex; align-items: center; justify-content: center; height: 64px; box-sizing: border-box; border-radius: 32px; border: 2px solid ${C.charcoal}; color: ${C.charcoal}; font-weight: 600; font-size: 17px; text-decoration: none;">Sign out</a>
</div>
<a href="#delete" style="align-self: center; font-size: 14px; font-weight: 600; color: ${C.error}; text-decoration: underline; text-underline-offset: 4px;">Delete account</a>
</div>`, `@keyframes sheetUp{from{transform:translateY(60px);opacity:0}to{transform:translateY(0);opacity:1}}`);

mkdirSync(new URL('./reference-screens/html/', import.meta.url), { recursive: true });
const out = {
  '01-welcome.html': welcome,
  '02-create-email.html': createEmail,
  '02b-create-password.html': createPassword,
  '02c-check-email.html': checkEmail,
  '03-log-in.html': logIn,
  '04-exam-date.html': examDate,
  '05-try-one.html': tryOne,
  '06-chapters.html': chaptersPeek,
  '08-home.html': home,
  '09-study.html': study,
  '10-study-grid.html': studyGrid,
  '00-splash.html': splash,
  '05b-hand-off.html': handOff,
  '03b-forgot.html': forgot,
  '11-chapter-map.html': chapterMap,
  '12-lesson-sheet.html': lessonSheet,
  '13-game-round.html': gameRound,
  '13b-game-answered.html': gameAnswered,
  '13c-game-done.html': gameDone,
  '14-lesson-brief.html': lessonBrief,
  '15-account-sheet.html': accountSheet,
};
for (const [name, html] of Object.entries(out)) {
  writeFileSync(new URL(`./reference-screens/html/${name}`, import.meta.url), html);
}
console.log(`wrote ${Object.keys(out).length} screens`);
