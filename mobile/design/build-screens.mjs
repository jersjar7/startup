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
// The floating dock: two destinations, Profile (home) and Study. Charcoal
// tile on the fog ground, active item a spring circle.
const dock = (active) => {
  const item = (href, label, svgOff, svgOn, on) =>
    `<a href="${href}" aria-label="${label}"${on ? ' aria-current="page"' : ''} style="display: flex; align-items: center; justify-content: center; width: 54px; height: 54px; border-radius: 27px; ${on ? `background: ${C.spring}; color: ${C.charcoal};` : `color: ${C.mutedOnDark};`}">${on ? svgOn : svgOff}</a>`;
  const person = (fill) => `<svg width="22" height="22" viewBox="0 0 24 24" fill="${fill ? 'currentColor' : 'none'}" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8.5" r="3.5"></circle><path d="M5 20c1-4 4-5.5 7-5.5s6 1.5 7 5.5z"></path></svg>`;
  const book = (fill) => `<svg width="22" height="22" viewBox="0 0 24 24" fill="${fill ? 'currentColor' : 'none'}" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 5.5A2.5 2.5 0 0 1 6.5 3H12v16H6.5A2.5 2.5 0 0 0 4 21z"></path><path d="M20 5.5A2.5 2.5 0 0 0 17.5 3H12v16h5.5a2.5 2.5 0 0 1 2.5 2z"></path></svg>`;
  return `
<nav aria-label="Main" style="position: absolute; left: 28px; right: 28px; bottom: 28px; height: 72px; box-sizing: border-box; padding: 0 10px; display: flex; align-items: center; justify-content: space-around; border-radius: 36px; background: ${C.tile}; border: 1px solid ${C.line}; box-shadow: 0 18px 40px rgba(44,44,44,0.28);">
${item('08-home.html', 'Profile', person(false), person(true), active === 'profile')}
${item('09-study.html', 'Study', book(false), book(true), active === 'study')}
</nav>`;
};

// ── 01 welcome ──
const welcome = page('Welcome', C.fog, C.charcoal, `
<div style="position: absolute; top: 62px; left: 24px;">${eyebrow('FE for Raccoons', C.mutedOnLight)}</div>
<div aria-hidden="true" style="position: absolute; top: 112px; left: 22px; width: 232px; height: 284px; box-sizing: border-box; padding: 22px; border-radius: 30px; background: ${C.spring}; color: ${C.charcoal}; display: flex; flex-direction: column; justify-content: space-between; animation: floatA 7s ease-in-out infinite;">
${eyebrow('Statics')}
<div style="font-family: ${F.display}; font-weight: 800; font-size: 58px; line-height: 0.95; letter-spacing: -0.05em;">&Sigma;F<br>= 0</div>
<div style="display: flex; gap: 8px;">
<span style="display: flex; align-items: center; justify-content: center; width: 38px; height: 38px; border-radius: 19px; border: 2px solid ${C.charcoal}; font-family: ${F.mono}; font-size: 12px; font-weight: 700;">A</span>
<span style="display: flex; align-items: center; justify-content: center; width: 38px; height: 38px; border-radius: 19px; background: ${C.charcoal}; color: ${C.spring}; font-family: ${F.mono}; font-size: 12px; font-weight: 700;">B</span>
<span style="display: flex; align-items: center; justify-content: center; width: 38px; height: 38px; border-radius: 19px; border: 2px solid ${C.charcoal}; font-family: ${F.mono}; font-size: 12px; font-weight: 700;">C</span>
</div>
</div>
<div aria-hidden="true" style="position: absolute; top: 186px; right: -26px; width: 206px; height: 246px; box-sizing: border-box; padding: 22px; border-radius: 30px; background: ${C.ember}; color: ${C.charcoal}; display: flex; flex-direction: column; justify-content: space-between; animation: floatB 8s ease-in-out infinite;">
${eyebrow('Fluids')}
<div style="font-family: ${F.display}; font-weight: 800; font-size: 50px; line-height: 0.95; letter-spacing: -0.05em;">Q =<br>VA</div>
</div>
<div aria-hidden="true" style="position: absolute; top: 348px; left: 112px; width: 190px; height: 138px; box-sizing: border-box; padding: 20px; border-radius: 28px; background: ${C.cream}; color: ${C.charcoal}; display: flex; flex-direction: column; justify-content: space-between; box-shadow: 0 18px 40px rgba(44,44,44,0.16); animation: floatC 6s ease-in-out infinite;">
${eyebrow('Concepts')}
<div style="display: flex; align-items: baseline; gap: 6px;"><span style="font-family: ${F.display}; font-weight: 800; font-size: 54px; line-height: 0.82; letter-spacing: -0.06em;">375</span><span style="font-family: ${F.display}; font-weight: 700; font-size: 16px;">free</span></div>
</div>
<div style="position: absolute; left: 24px; right: 24px; bottom: 34px; display: flex; flex-direction: column; gap: 22px;">
${headline('The FE Civil,<br>one concept at a time.', 44)}
${pill('02-create-email.html', "Let's go")}
<a href="03-log-in.html" style="align-self: center; font-size: 15px; font-weight: 500; color: ${C.mutedOnLight}; text-decoration: none;">I already have an account</a>
</div>`, `
@keyframes floatA{0%,100%{transform:rotate(-7deg) translateY(0)}50%{transform:rotate(-6deg) translateY(-8px)}}
@keyframes floatB{0%,100%{transform:rotate(9deg) translateY(0)}50%{transform:rotate(10deg) translateY(7px)}}
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
<div aria-hidden="true" style="position: absolute; top: 160px; right: -26px; width: 206px; height: 246px; border-radius: 30px; background: ${C.ember}; opacity: 0.45; transform: rotate(9deg);"></div>
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
<div aria-hidden="true" style="position: absolute; left: -24px; bottom: -130px; font-family: ${F.display}; font-weight: 800; font-size: 440px; line-height: 1; letter-spacing: -0.08em; color: ${C.creamDark};">FE</div>
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
const tryOne = page('Onboarding: try one', C.ember, C.charcoal, `
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
const chaptersPeek = page('Onboarding: fifteen chapters', C.sunbeam, C.charcoal, `
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
<div style="box-sizing: border-box; padding: 58px 16px 0; display: flex; flex-direction: column; gap: 10px;">
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
<div style="display: flex; flex-direction: column; justify-content: space-between; height: 172px; box-sizing: border-box; padding: 20px; border-radius: 32px; background: ${C.sunbeam}; color: ${C.charcoal}; animation: rise 0.5s 0.14s ease-out both;">
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
<div style="box-sizing: border-box; padding: 58px 24px 0; display: flex; flex-direction: column; gap: 22px;">
<div style="display: flex; align-items: center; justify-content: space-between;">${eyebrow('73 days to the exam', C.mutedOnLight)}${toggle('10-study-grid.html', 'All chapters', gridIcon)}</div>
<div style="display: flex; flex-direction: column; justify-content: space-between; height: 470px; box-sizing: border-box; padding: 24px; border-radius: 36px; background: ${C.cream}; animation: rise 0.5s ease-out both;">
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
<div style="box-sizing: border-box; padding: 58px 16px 0; display: flex; flex-direction: column; gap: 16px;">
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
};
for (const [name, html] of Object.entries(out)) {
  writeFileSync(new URL(`./reference-screens/html/${name}`, import.meta.url), html);
}
console.log(`wrote ${Object.keys(out).length} screens`);
