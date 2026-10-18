# Marketing agent brief

Read this first if your job is making posts, reels or carousels for
FE for Raccoons. It tells you what the product is today, what you may and may
not say, where the existing marketing machinery lives, and where to find (or
make) fresh visual material from the website and the phone app.

Written 2026-10-18. Numbers and store status change; the "Check before you
claim" section says how to re-verify each one.

---

## 0. The campaign right now: the app is coming soon

**Status (owner, 2026-10-18): the app is NOT live in either store yet.** Both
are submitted and in review. For the 7 days from 2026-10-18 through
2026-10-24, the job is to build anticipation for the app.

- Say "coming soon" or "coming to iPhone and Android". **Never** give a launch
  date, never show App Store or Google Play badges, never write "download now"
  or "available today". Review timing is not ours to promise.
- There is no waitlist or "notify me" page. The call to action is the website,
  which is live and completely free: "Start on fe4raccoons.com today. The app
  is coming soon." Before claiming that progress carries over to the app,
  confirm with the owner how he wants it worded (the app signs in with the
  same account and syncs, but games do not move the mastery number).
- Show the real app: game rounds, the chapter path, badges, the concept
  sheets, dark mode (section 4 lists where every frame is). No mockups of
  features that do not exist.
- Keep the paid Exam Simulation out of these pieces entirely.
- Suggested arc (adjust to the current cadence in `_CALENDAR.txt`):
  1. Teaser: "Studying for the FE on your phone, done properly. Coming soon."
  2. The chapter path: 15 chapters as stepping stones.
  3. One game round as a playable carousel (question, then answer slide).
  4. "Every lesson gets its own game", a fast montage of different rounds.
  5. Badges drawing themselves.
  6. Warm night: the same screens day and night.
  7. "The phone teaches it, the desk proves it", app plus website together.
- Draft the week as one plan first (one line per post: format, hook, source
  frames), show it to the owner, then build.
- When the owner says the app is approved, this section is over: swap to
  store links and update it.

## 1. What FE for Raccoons is

A study platform for the **FE Civil exam** (Fundamentals of Engineering, the
first licensure exam for civil engineers in the US). Two surfaces:

- **The website**, fe4raccoons.com. The desk: lessons, worked problems, a
  diagnostic, chapter practice, spaced review, a dashboard with an
  NCEES-weighted mastery number, and the paid Exam Simulation.
- **The phone app** (Flutter, iOS and Android). Not a shrunken website. Each of
  the 15 chapters is a path of stepping stones (one stone per lesson), and each
  lesson is taught through **games authored for that lesson alone**: you drag,
  flip, trace, point at, and predict, and each round ends with a short
  picture-first concept sheet. There is a Daily step, a Review tab, 19 badges
  drawn as animations, and a warm dark mode ("Warm night").
  The app's job is honest: concepts and quick recall on the phone, then an
  honest hand-off to paper and the website for the long calculations. Games
  never count toward the mastery number (see `docs/mobile-app-north-star.md`).

"The new fe4raccoons" means the phone app plus the rebuilt exam simulation.
Lead with the app: it is the newest thing and the most visual.

Who it is for: civil engineering seniors and recent grads studying for the FE,
usually with a booked exam date, often studying around a job or classes.
Adults. Tone is calm, competent, a little warm. Never cartoonish.

## 2. Rules you must follow (owner decisions, not suggestions)

**Messaging**
1. The platform is **completely free**. Say exactly that. Never "free to
   start", "free core", "$0 to start", "the core is free": those imply a
   charge later. Note: the `carousel` skill text still says "free core";
   that wording is outdated, use "completely free".
2. The only paid item is the optional **Exam Simulation** (110 questions,
   5 h 20 min, a 25-minute break after question 55, like the real exam):
   $35 for students with a verified .edu email, $49 standard, one time.
   (Older notes, skills and reels say $29; that was the student price until
   2026-08-10.)
   **Never mix "completely free" and the paid sim in one piece.** A piece
   about the sim talks only about the sim.
3. Claims must be exact and checkable (see section 5). No invented
   statistics, pass rates or testimonials.
4. The name has no backstory. The owner chose it to be fun, different and
   memorable and leaves its meaning to each student. Never invent an origin.

**Writing style (all copy, captions, slides)**
- No emojis, anywhere. Phosphor icons replace them in designed assets.
- No em dashes. Use commas, periods or parentheses.
- No exclamation points unless quoting someone.
- Left-aligned body text in designed assets.

**Brand (designed assets)**
- Colors: cream `#FFF9F0` canvas, charcoal `#2C2C2C` text, ember `#E8683A`
  primary accent, sunbeam `#F5B731`, forest `#2D7A5F`. At most two accents in
  one section. No purple gradients, no neon.
- Fonts: DM Sans (headings, tight letter-spacing), Inter (body),
  JetBrains Mono (formulas, numbers). Never system fonts.
- Radii 6/10/16/24 px, never sharp corners. Warm, subtle shadows.
- Full system: the root `CLAUDE.md` (the brand section) and the live
  tokens in `src/app.css`. (Older notes point at a `fe4raccoons-brand-deck.html`
  and a `fe4raccoons-brand` skill; neither exists any more.) The phone app has its own visual language:
  `mobile/design/DESIGN.md` and `mobile/design/tokens.json`.

**Legal and accounts**
- Do not build the account on copyrighted movie or TV clips. Footage must be
  defensible: your own renders, the owner's own video, US federal public domain
  (NARA, NASA, USGS, USACE, Bureau of Reclamation), Prelinger Archives,
  Wikimedia Commons with a compatible license, free stock (Pexels, Pixabay,
  Mixkit). Avoid "Content ID registered" music; the owner has an ElevenLabs
  plan for original beds.
- Never post to the owner's accounts yourself unless he explicitly says
  "post it" for that specific piece. Default output is files he posts from his
  phone (section 4).
- Never use a real student's name, face or words without their consent. The
  one consented testimonial is Mitch Rose (section 3).
- Never use the owner's real email as a test account on the live site.

**Repo rules**
- This repo is code only. Media, drafts and marketing scripts go in
  `~/developer/fe4raccoons-marketing/`, never in git.
- If you do commit something (code change, doc), work on `development`, stage
  files by name, no AI mentions or trailers in commit messages, and never push
  to `main` without the owner's explicit yes.

## 3. What already exists (reuse before you rebuild)

These live **on the owner's Mac**, outside git. If your session cannot see
them, ask the owner; do not recreate a pipeline that already exists.

**`~/developer/fe4raccoons-marketing/`** (README.md inside explains it)
- `reels/<name>/`: about 50 finished reels (`<name>.mp4` + `<name>-cover.png`),
  e.g. formula traps (`beam-moment-trap`, `friction-trap`), 3D concepts
  (`moment-3d`, `inertia-3d`), failures (`fail-hyatt`), news/data
  (`news-fe-pe-rates`, `news-civil-salary`), the brand intro and founder clips.
- `carousels/`: built carousels (`fe-civil-decoded`, `topic-weights`,
  `pay-by-sector`, `friction`, `memes`).
- `remotion/`: the Remotion engine (`BrandReel`, `AdReel`, `QuizReel`,
  `TestimonialReel`, `ReelCover`).
- Kokoro TTS voiceover (Python 3.12 venv at `.venv`), music beds in
  `assets/music/`, Manim 3D template `manim/moment_3d.py`.
- `youtube/`: uploader (`upload_youtube.py`) and view stats (`views.py`); the
  token expires, re-auth with `youtube/auth.py`.
- `linkedin/`: HTML templates + `render.mjs` for 1200x1200 brand images.
- `analysis/90-day-growth-plan.xlsx`: the hired analyst's growth plan. Follow
  it as written; log what you did in column L.
- `reels/mitch-testimonial/`: the one real student testimonial (passed Civil FE
  first try). Free-leaning on social; the paid-sim version is the site page
  `/stories/mitch`.

**`.claude/skills/`** (in this repo folder but gitignored): one self-contained
skill per series. Invoke the matching one before building:
`carousel`, `exercise-quiz-reel`, `concept-3d-reel`, `brand-reel`,
`founder-clip-reel`, `testimonial-reel`, `failures-reel`, `megaprojects-reel`,
`projects-now-reel`, `mini-documentary-reel`, `fe-pe-numbers-reel`,
`salary-reel`, `pay-by-sector-reel`, `degree-roi-reel`, `schools-reel`,
`who-hires-reel`, `what-ces-do-reel`, `advanced-degrees-reel`,
`career-profession-clip-reel`, `movie-clip-reel` (treat that one with the
legal rule above).

**What has worked** (owner's own analytics):
- Carousels beat reels by roughly 10 to 20 times on saves and follows.
  Cheat-sheet framing ("6 formulas the FE keeps reusing", "the whole exam in
  6 numbers") with an explicit "Save this" trigger.
- On LinkedIn, plain motion-graphic reels did poorly (around 10 views);
  footage plus commentary is the format that travels there.
- The owner's own talking head is the safest high performer.
- Professors are the strongest channel (one email reaches a whole review
  course). Tag campus links with `utm_medium=campus`.

**Delivery to the owner:** he posts from his iPhone. Finished pieces go to
iCloud Drive `~/Library/Mobile Documents/com~apple~CloudDocs/FE4Raccoons-Posts/`,
one folder per post date, with `<slug>.mp4` (or slide PNGs), `<slug>-cover.png`
and `<slug>-caption.txt`. Check the latest folders and `_CALENDAR.txt` for the
current cadence and the next serial number before adding to it.

## 4. Where to find or make fresh material

The newest and least-used material is the **phone app**. Nobody has made
content from it yet. Sources, best first:

1. **Every game round, already rendered.** `mobile/test/goldens/` holds about
   3,000 PNGs: each lesson's game rounds in their states (start, mid, answered,
   done). Folder names follow the lessons (`01-straight-lines/`, ...).
   - Night versions: run from `mobile/`
     `flutter test --update-goldens --dart-define=DARK_PALETTE=true`
     (add `REVIEW_ANSWERED=1` for after-an-answer states), copy
     `test/goldens` somewhere else, then `git checkout -- test/goldens` so the
     repo is unchanged. Skip folders `129-earthwork` and `134-delivery`
     (orphans).
   - The owner already has a browsable gallery of every round, day and night:
     https://claude.ai/artifact/PnkzDpVdmFoXfcgZezngJa
   Good for: "one lesson, one game" carousels, "how would you answer this"
   polls, before/after-answer pairs, day vs. night.
2. **Designed reference screens.** `mobile/design/reference-screens/png/`
   (splash, welcome, chapter map, lesson sheet, game round, answered, done,
   lesson brief, and more) with matching HTML in `.../html/` you can re-render
   at any size with `mobile/design/render.mjs`. Clean, store-quality frames.
3. **Store assets and copy.** `mobile/design/appstore/out/` (the 8 App Store
   screenshots: free, round, sheet, figures, map, coverage, mastery, days),
   `contact-sheet-*.png`, and `mobile/design/play/` (feature graphic,
   screenshots, `listing.md`). The app
   icon master is `mobile/design/icon-master-1024.png`.
4. **Animations.** `mobile/assets/rive/lesson_node.riv` (the stepping stones)
   and `badge.riv` (19 badge drawings that draw themselves). Screen-record the
   app in the iOS Simulator for motion: `xcrun simctl io booted recordVideo
   out.mp4` after `flutter run` from `mobile/` (see `mobile/TESTING.md`).
   Badge details: `docs/mobile/badges.md`.
5. **Website screens.** `scripts/verify-ui.mjs` screenshots signed-in pages
   using the QA account (credentials in gitignored `secrets/qa-login.json`).
   Never use a real user's account or data in a post.
6. **The question bank itself.** 1,126 problems with worked solutions and
   about 280 real engineering diagrams: lessons in `src/data/lessons/`, exam
   bank in `src/data/exam-bank/`, chapter practice in
   `src/data/chapter-practice/`, diagrams in `src/components/diagrams/`.
   `QuizReel` already turns a bank question plus its diagram into a Short.
   Do not publish exam-bank questions in bulk; one at a time as a quiz is fine.
7. **Public pages** for links and screenshots: `/`, `/fe-civil-exam-guide`,
   `/exam-simulation`, the 15 topic pages, `/stories/mitch`, `/about`.
   The explainer video and poster are in `public/`.

Fresh ideas the owner has not seen yet, all from the app:
- "Can you solve it with your thumb?" one round per post, answer on the
  next slide.
- A chapter's path from first stone to last as a single scroll video.
- Badge reveal reels (the Rive drawing finishing, in real time).
- "Warm night": the same round day and night, side by side.
- "The phone teaches it, the desk proves it": how the app and the website
  split the job (completely free framing, no sim).

## 5. Check before you claim

| Claim | Current value | How to verify |
|---|---|---|
| Problems | 1,126 (405 lesson + 473 exam bank + 248 chapter practice) | `getProblemPoolSize()` in `src/data/` |
| Topics / subtopics / lessons | 15 / 51 / 135 | `src/data/chapters` and `src/data/lessons/` |
| Exam simulation | 110 questions, 5 h 20 min, break after Q55, NCEES 2020 weights | `service/examWeights.js`, `service/routes/exam.js` |
| Sim repeats | A student's first two simulations share no question | `service/examQuestions.js` |
| Price | $35 verified student, $49 standard, one time | `service/pricing.js`; the live `/exam-simulation` page |
| App in stores | **Not live yet** (owner, 2026-10-18); both in review | Say "coming soon" until the owner says it is approved |

If a number in an old reel or skill disagrees with this table, the table (and
the code) wins.

## 6. How to work with the owner

- He reviews on his phone. Report what you made in a few short lines: what it
  is, where it is, what you need from him. No walls of text.
- Show a draft (cover plus one slide, or a 5-second cut) before building a
  whole series.
- He wants genuinely new forms, not a template refilled. Offer a couple of
  different directions, then commit to one.
- Ask once when something is ambiguous, pick the easier-to-undo reading, and
  say which you picked.
