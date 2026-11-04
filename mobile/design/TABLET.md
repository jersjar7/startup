# TABLET.md: the app on an iPad or an Android tablet

Proposed 2026-11-03, approved by the owner the same day (ADR 0039, Accepted). Read DESIGN.md first: every
rule there still holds on a tablet. This file only says what changes when the
window is wide, and why. Nothing here adds a feature, a screen or a line of
content. It is the same app, laid out for a bigger window.

Mockups: `tablet-screens/png/` (11-inch iPad, 1180 by 820 landscape and
820 by 1180 portrait, at 2x), from `tablet-screens/html/`, built by
`build-tablet-screens.mjs` and rendered by `render-tablet.mjs`:

    node build-tablet-screens.mjs && node render-tablet.mjs

## Why this exists

Today the app is phone only. On an iPad it opens in iPhone compatibility mode,
a phone-sized island in the middle of the glass, locked to portrait. On an
Android tablet it shows the phone layout stretched edge to edge. A student who
studies on an iPad gets the worst of both: small drawings and long lines.

The owner's brief: "not just make font larger or leave more blank spaces."
So the rule for every screen below is: **use the room to put two things that
belong together side by side**, and only where that helps the student. Where it
does not, the screen stays one thing, drawn bigger and better, and says so.

The single most useful thing a tablet allows is that a student can keep the
NCEES Handbook PDF open next to the app. That is why split screen is a first
class size here, not an afterthought.

## 1. Size classes

The layout is chosen by the **width of the app's window**, never by the
device. An iPad in split screen is a phone-width window, and must get the phone
layout. A foldable opened flat is a tablet.

| Class | Window width (pt) | What it gets | Typical windows |
|---|---|---|---|
| compact | under 600 | The phone app, exactly as DESIGN.md draws it | Every phone. iPad Slide Over (320). iPad split at one third (about 320 to 375) and at one half on an 11-inch (about 585 landscape, 400 portrait). Narrow iPadOS 26 windows |
| medium | 600 to 899 | One pane, drawn larger, with the rail | iPad mini portrait (744). 11-inch portrait (820, 834). Split at two thirds on an 11-inch (about 795). Half of a 13-inch landscape (about 683). Android foldables open (about 673 to 840) |
| expanded | 900 and up | Two panes where a screen has two things | 11-inch landscape (1180, 1210). 13-inch portrait (1024, 1032) and landscape (1366, 1376). Android 10-inch tablets landscape |

Two finer thresholds, both proposed as tokens:

- **conceptBeside, 960.** At this width or more, the concept sheet opens beside
  a round instead of over it (section 5). Between 900 and 959 it opens over the
  round as a side sheet, the same as medium.
- **Short windows.** If the window is under 560 tall (a small iPadOS 26 window,
  a phone in landscape is not possible because phones stay portrait), panes
  scroll as one column; nothing is laid out side by side that would need to be
  shorter than that.

Rules that keep this from going wrong:

1. **Compact is the phone, byte for byte.** No tablet rule may change a phone
   golden. The builder should prove it by running the existing golden suite at
   390 wide unchanged.
2. **The class is re-read on every size change**, not at launch. Rotating,
   dragging a split divider and resizing an iPadOS window all change it while
   the app is open (section 9).
3. **Never between classes.** There is no layout that is half phone and half
   tablet. At 599 it is a phone; at 600 it is a tablet with the rail.

## 2. The navigation model

**On a tablet, the dock becomes a rail down the left edge.** Same three
destinations, same order read top to bottom as the phone reads left to right:
Profile, Study, Daily. Same 54 circles, same 12 labels, the active one a spring
circle with a filled icon, the Daily's ember dot on its shoulder.

| | Phone dock | Tablet rail |
|---|---|---|
| Where | Bottom, full bleed | Left, full height |
| Shape | Cream bar, top corners 40 | Cream bar, right corners 40, 104 wide |
| Items | Three, spread across | Three, stacked in the vertical middle, 28 apart |
| Shadow | Soft, upward | Soft, to the right |
| Under the content | Yes (the scaffold's bottom bar) | Yes (a row, the content never slides under it) |

Why the left edge, and why the middle: a tablet held in two hands is held at
its sides, so the thumb zone is the left and right edges at mid height, not the
bottom middle. The rail puts navigation under the left thumb; the pill, the
screen's one action, stays bottom right under the right thumb. On a desk or a
stand, a pointer reaches either.

Why the rail is used in portrait too: one model per device. If portrait used
the bottom dock and landscape the rail, rotating the iPad would move the
navigation across the screen. The only time navigation moves is when the
window becomes compact, and then it is the phone's dock, exactly.

**What covers the rail, and what does not.**

- **A sitting covers it**, as a sitting covers the dock on the phone: a round,
  the done screen, the Daily's steps and its done screen, a badge moment, a
  league moment. These are bounded focus modes with their own close button.
  Leaving one is a deliberate act.
- **Auth and onboarding cover it**, because there is nothing to navigate to yet.
- **Every other pushed page opens beside the rail**, in the content area: the
  chapter map in portrait, Mastery, Days studied, the League, Badges, XP,
  Concepts, the exam date, the pass card, About, Contact, Edit profile. Each
  keeps its own round back button top left.

Sheets (the account sheet, the feedback sheet, the share sheet) rise from the
bottom of the content area, capped at 640 wide and centred in it, over a scrim
that covers the rail too.

## 3. Panes

A pane is a column of the window that holds one thing. Expanded screens have
at most two. Two rules from DESIGN.md decide what may share a window:

- **One dominant element per window, not per pane.** The second pane is always
  the quieter one: it is the detail, the map, the board, never a second hero.
- **One action per window.** Only one pill on the screen. The second pane's
  controls are its own taps (a node, a row), never a second pill.

| Token (proposed) | Value | Use |
|---|---|---|
| `tablet.pane.leading` | 400 | The left pane of Study (the chapter tile, the grid, the lesson) |
| `tablet.pane.conceptSheet` | 460 | The concept sheet beside a round |
| `tablet.pane.sheetMax` | 640 | Any bottom sheet on a tablet: capped and centred |
| `tablet.space.paneX` | 32 | From the rail to the first pane |
| `tablet.space.paneGap` | 24 to 40 | Between two panes (32 is the default) |
| `tablet.space.screenX` | 48 | Side margin on screens with no rail (rounds, onboarding) |
| `tablet.space.top` | 24 | Below the status bar, which is 24 tall on iPad (phones use 56 to 58 from the top of the screen because of the island) |

Panes are not boxed. A pane is a cream tile (the chapter tile, the lesson) or
plain fog (the path, the facts). There are no divider lines between panes;
the gap is the divider.

## 4. Screen by screen

The inventory is every screen in `lib/features` as of 2026-11-03. "Stays
phone-like" means the layout is the phone's, scaled with the type and spacing
rules of section 7, on purpose.

### Study tab (expanded: the chapter beside its path)

Mockups: `T01-study-landscape`, `T01n-study-landscape-night`.

- **Left pane (400):** the chapter tile, exactly the one-chapter object of ADR
  0015 (eyebrows, the mark in its circle, the name, the mono line, the pill
  inside the foot), with the 15 page dots under it. It still pages
  horizontally; swiping it changes the chapter.
- **Right pane:** that chapter's path, live. Swiping the tile redraws the path
  for the chapter on the tile. The path opens scrolled so the lesson in flight
  sits in the upper middle of the pane.
- **The pill behaves as on the phone** (owner, 2026-11-03). On the phone,
  Continue takes the student to the chapter map with the lesson in flight in
  view, and the student taps the node to open the lesson. On a tablet the map
  is already the second pane, so Continue scrolls the path to the lesson in
  flight and rings its node; tapping the node opens the lesson, exactly as on
  the phone. Continue never skips that step. (The first draft had Continue
  open the lesson directly; the owner kept the phone's behaviour.)
- **The grid toggle** (top right of the left pane) swaps the tile for the
  grid of all fifteen (`T02-chapter-map-landscape`): three columns of grid
  tiles in the left pane. Tapping a tile shows that chapter's path on the
  right, with the chapter's eyebrow and name above it. The chapter whose path
  is showing is a **charcoal tile** with a spring mark; the chapter in flight
  stays spring. Selection changes the fill, never only a colour of text.
- What stays phone-like: the tile itself. It does not grow a second column of
  facts. ADR 0015 decided the home is one chapter and one button, and the path
  beside it is the detail of that same chapter, not a second subject.

**Medium (portrait):** `T01p-study-portrait`. The same pairing as landscape,
stacked, because portrait has height to spare and no width to spare. The
chapter becomes a band across the top (the mark in a 200 circle on the left;
the eyebrows, the name at 48, the mono line and Continue on the right), the
page dots under it, and the chapter's live path fills the rest of the window
below. Swiping the band changes the chapter and redraws the path, as in
landscape, and Continue behaves as in landscape. A tile
drawn twice as large with nothing beside it was tried first and rejected: it
is the "bigger, with more blank space" version the owner ruled out.

### Chapter map

Mockups: `T02p-chapter-map-portrait` (medium), and the right pane of
`T01`, `T02` and `T03` (expanded).

- On a tablet it is never a pushed screen: in landscape it is Study's right
  pane, in portrait the lower part of Study (above).
- **All chapters, medium** (`T02p-chapter-map-portrait`): the grid toggle puts
  the fifteen grid tiles in five columns across the top (three rows), and the
  picked chapter's eyebrow, name and path below them. The picked tile is
  charcoal, the chapter in flight spring, as in landscape.
- **The path gets bigger, not just wider.** Nodes 100 (phone 84), the weave
  amplitude 110 (phone 70), steps 150 apart, labels in DM Sans 16 on
  two lines at most. Labels start 28 from the node face, clear of the ring.
  The road is the one in `road/ROAD.md` (24 wide on a tablet, 20 on a
  phone): a raised slab, dark with a cream centre line behind the student,
  pale ahead, its wall shorter than the node plinths. The weave was 150;
  with a road this wide, a 150 weave runs the road nearly flat through the
  labels, so it is 110 (`PathMetrics.ampFor` should cap at 110).
  Only the lesson in flight gets a label tile, in spring.
- **The path is centred in its pane** (owner, 2026-11-03). The node column,
  meaning the middle line of the zigzag (halfway between the left nodes and
  the right nodes), sits on the pane's own middle line, in every place the
  path appears: Study in both orientations, All chapters, and behind the
  opened lesson. The labels hang off the nodes (to the right of a left node,
  to the left of a right node) and are not counted when centring. The cleared
  chip and the section eyebrows stay at the pane's left edge. The first draft
  set the zigzag at 42 percent to make room for labels; it read as off-centre
  and was dropped. If a label would run out of the pane, it wraps to a second
  line; the zigzag never moves to make room for it.

### Lesson sheet

Mockups: `T03-lesson-sheet-landscape`, `T03p-lesson-sheet-portrait`.

- **Expanded: the lesson takes the chapter's pane.** Tapping a node replaces the chapter tile with the lesson: a cream tile at the same
  size with the eyebrow, the lesson name as a 40 headline, the games as row
  tiles (the next one spring, each with its 48 round play or check), and
  "Read the concept first" as the outline pill at the foot. A 48 round close
  button top right returns to the chapter tile. The tapped node on the path is
  ringed in charcoal with a fog gap, so the student sees which lesson the left
  pane is about.
- Why not a bottom sheet: the sheet would cover the path, which is the reason
  the path is on screen. Why the left pane and not a third column: two panes
  is the most a window holds, and the left pane is "what to do now" in both
  states (a chapter, then a lesson in it).
- **Medium** (`T03p`): the lesson takes the band's place at the top, as it
  takes the left pane in landscape, and the path stays in view below with the
  lesson's node ringed. The width allows the games side by side: three
  columns, each with its name, its blurb and its 48 round play or check, the
  next one spring. "Read the concept first" spans the foot of the lesson. A
  bottom sheet over the dimmed path was the first version; it hid the path,
  which is the thing that tells the student where this lesson sits.
- **Compact:** the phone's lesson sheet over the chapter map, unchanged.

### A round (the board)

Mockups: `T04-round-landscape` (unanswered), `T05-round-answered-landscape`,
`T06-round-with-concept-landscape`, `T04p-round-portrait`. The game is Which
Ratio, from Right Triangle Trigonometry (`which_ratio_game.dart`), round 1.

The frame is the phone's (board.dart): close button, pips, the mono counter,
the book with its one-time ember dot, the flag, the pill. What changes is
where the game's body goes.

- **Expanded: the drawing beside the answer.** The drawing pane takes the left
  of the window at full height (about 640 by 664 on an 11-inch landscape). The
  right column (420) is **pinned to the drawing's two edges** (owner,
  2026-11-03): the game's overline, the question at 20 and the answer choices
  start at the very top, level with the drawing's top edge; the flag and the
  pill sit at the very bottom, level with the drawing's bottom edge. After an
  answer the feedback panel and the spoken rule follow the choices at the
  top, never floating mid-column. Whatever space is left sits between the
  last of those and the pill, and that is fine. The choices are 88 tall
  (labels at 26) in both states, so answering never moves them. The flag sits
  left of the pill in the same row (on the phone it sits above the pill).
  The first draft bottom-aligned the whole column on the pill to keep the
  question near the right thumb; the owner did not want the top right half of
  the window empty, and the reading order (question at the top beside the top
  of the drawing) wins over thumb reach.
- Why: in landscape the window is short (820). A phone column (question,
  drawing, answers, feedback, pill) does not fit without scrolling, and
  scrolling a round hides either the drawing or the answer. Side by side,
  nothing scrolls and the drawing grows to more than twice its phone area.
- The pips are capped at 560 wide. Eight capsules stretched over 1,000 points
  read as a loading bar, not as rounds.
- **Answered:** the drawing marks the answer the way the game already does
  (here, the two sides in ember); the feedback panel appears under the
  controls in the same column, so the student's eye never leaves the right
  column to read why.
- **Medium (portrait):** one column like the phone, at the full content width
  (724 on an 11-inch). The drawing gets the extra height (about 560). The pill
  is capped at 440 and sits bottom right with the flag beside it.

**The builder's cost, said plainly.** Every game today hands the frame one
column (`BoardShell(child: Column(...))`). To put the drawing beside the
answer, the frame has to receive the drawing separately. Proposed:
`BoardShell` takes an optional `figure` widget. A game that passes its
drawing as `figure` (and the rest as `child`) gets the side-by-side layout; a
game that does not gets the single column, capped at 640 wide and set on the
left of the window, with the concept sheet's slot to its right. 292 of the 375
built games draw a picture; the four pack game types (`lib/features/packs/
games`) are shared and should be moved first. The move is mechanical (the
drawing widget already exists in every game) but it is 292 files, so it should
go chapter by chapter with the contact sheets regenerated at 1180 by 820 for
each.

### The concept sheet beside a round

Mockup: `T06-round-with-concept-landscape`.

- **At 960 wide or more, the book opens the concept sheet beside the round.**
  The sheet is a cream pane, 460 wide, full height, its left corners rounded at
  40, with the sheet's own close button. The round compresses to the left
  (drawing over the answers, as one column) and **stays playable**: the student
  can read a step, look at the drawing, and answer, without closing anything.
  While the sheet is open, the book button is charcoal (pressed), so it reads
  as a toggle.
- **The sheet never opens by itself.** The north star's first rule is
  generation over recognition: a rule that is always on screen turns a
  retrieval into a lookup. The sheet opens only from the book, and closes
  when the round's close button is tapped or the sitting ends. Within a
  sitting it stays open across rounds if the student leaves it open (their
  choice, not ours).
- **Under 960, the sheet opens over the round** as a side sheet from the right
  (460 wide, over a scrim), which is the phone's behaviour turned on its side.
- The sheet's content is the phone's, unchanged: the eyebrow with the
  Handbook page, the lesson name, the title, the picture first, the three or
  four steps, the spoken rules, the paper line. On the tablet the picture is
  drawn at the pane's width, not the phone's.

### The lesson brief (the concept, from the lesson sheet)

Mockups: `T07-lesson-brief-landscape`, `T07p-lesson-brief-portrait`.

When the concept is opened from "Read the concept first" there is no round to
sit beside, so it opens as a full page.

- **Expanded: the picture beside the steps.** Left column (540): the eyebrow
  line, the lesson name, the title at 52, the picture at 540 by 330, its mono
  caption. Right column (about 500, inside the 620 measure): the steps, then
  the spoken rules as three creamDark tiles in a row. The paper line sits at
  the foot on the left, the pill "Back to the lesson" on the right.
- **Medium: the picture full width, the steps in two columns.** The picture at
  724 wide, then the four steps as a two by two grid (reading order left to
  right, top to bottom; each step is an eyebrow and at most 60 words, so the
  columns stay short), then the three spoken rules in a row.
- Why: the concept sheet's whole shape (concept-sheet-shape) is picture first.
  On a tablet the picture can stay in view while the student reads every step,
  which the phone cannot do. That is the point of the layout.

### The done screen (end of a sitting)

Mockup: `T19b-round-done-landscape`. The hero tile (the count on spring) and
the two half tiles (first try, lesson) stack on the left at 560; the closing
line at 52 and the honest paper line sit on the right, with Start over and the
Done pill at the right column's foot. The phone stacks all of it; side by side
the student reads the score and the line about paper together. Medium keeps
the phone layout at a 560 column on the left with the pill bottom right.

### The Daily

Mockups: `T08-daily-landscape` (before playing), `T08b-daily-results-landscape`
(after).

- **Before playing (expanded):** left column: the date, "Today's Daily" at 64,
  the count as the hero number (3, at 200) with its unit "concepts, about 3
  min", the one line, and the streak row tile at the foot. Right: the cream
  hero with the three games, each a tall creamDark row with its chapter mark at
  52, the game, its lesson and its round count, and the pill at the foot. One
  pill on the window, under the right thumb.
- **After playing (expanded):** left: the eyebrow, the headline ("You beat 70%
  today"), the Everyone and school chips, the spread as cream bars (yours
  charcoal), and the streak. Right: "Yesterday's score" top right (where it
  sits on the phone), the top two and you as row tiles, the school's line,
  then Today's concepts with their three play-again rows, Share your result and
  "Next one at midnight". Everything the phone shows, in two columns, so the
  student sees where they stand and what to replay without scrolling.
- **Medium:** the phone layout at the content width, the hero card capped at
  640; the rows get the taller tablet row (the mark at 52).
- **A Daily step** (`T21-daily-step-landscape`): the three concepts of today
  as rows on the left (done with a check and its score, the current one
  charcoal, the next one quiet), the current concept's card on the right
  (chapter, mark, lesson, game name at 52, its line, "Read the concept
  first"), the pill bottom right. The phone shows only pips for the other two;
  the tablet names them, which is arrangement, not new content: the same three
  rows are on the Daily tab.
- **The Daily's done screen** (`T21b-daily-done-landscape`): the spring hero
  (16 of 18, the eighteen pips, the line) fills the left; time and streak
  stack on the right with Share and "How others did" at the foot.
- **Yesterday's score** (`T21c-daily-yesterday-landscape`): the place as a
  headline with yesterday's spread under it on the left, the board's rows on
  the right, the student's row charcoal. The phone shows the top two and you;
  the right column has room for the rows around you as well.
- **The share sheet** (`T21d-daily-share-landscape`): a bottom sheet capped at
  640, the share card on the left of it and the two actions on the right.

### Profile

Mockups: `T09-profile-landscape`, `T09p-profile-portrait`.

- Profile is a page of type with no tiles (ADR 0023). That holds.
- **Expanded:** the date and the avatar on the top line. Left: "Welcome back,
  Jerson." at 96, and the raccoon peeking over the Carry on pill at the foot,
  the mono line under it. Right: the four facts (rounds left with its bar, days
  studied, days to the exam, the league line with its coin), as tile-number
  figures at 84 with their units and lines, stacked with 46 between them.
- **Medium** (`T09p`): the headline at 92, then **the fact Carry on acts on
  leads**: rounds left at 150 with its bar the full width of the column. The
  other three facts sit in a row of three under it (the figure at 76, the unit
  under the figure, the line under that). Carry on and the raccoon sit bottom
  right. Ranking the facts this way is an arrangement, not new content: the
  pill and its fact read as one thing. A two by two grid of equal facts was
  the first version; it left a third of the window empty.
- The empty face (nothing done yet) follows the same split: the headline left,
  the app's own figures right.
- Every page behind a fact (Mastery, Days studied, the League, Concepts, XP,
  Badges, the pass card, the exam date) opens beside the rail, not as a pane.
  Profile has no list for a list-detail split to hang from, and turning its
  facts into a list would undo ADR 0023.

### League

Mockup: `T11-league-landscape`. (The brief asked for a Review screen. The app
has no Review: ADR 0014 removed it. The League is drawn in its place because it
is the newest pushed page and the one with the most to arrange.)

- **Expanded:** left: back, "Ends Saturday", the coin and "Silver league", the
  place as the hero (3rd, at 150) with "of 15", and the two lines. Right: the
  three zones (moving up, staying, moving down) as cream tiles of rows, the
  student's row charcoal. All fifteen fit, or nearly, without scrolling.
- **Medium:** the phone layout at the content width.

### Onboarding and the welcome

Mockups: `T10-welcome-landscape`, `T10p-welcome-portrait`,
`T13-onboarding-together-landscape`, `T13b-onboarding-games-landscape`,
`T13c-onboarding-honest-landscape`, `T13p-onboarding-honest-portrait`,
`T14-titles-landscape`.

- **Welcome, expanded:** the headline and the pill on the left, set low, the
  three floating cards (Statics on spring, Fluids on peach, the 375 card on
  cream) on the right at about 1.5 times the phone's size. "I already have an
  account" sits beside the pill, not under it.
- **Welcome, medium:** stays phone-like on purpose: a poster seen once, one
  object and one action; splitting it would make two heroes.
- **The three tour steps** (two parts; a minute each; honest by design), on
  their phone grounds (fog, peach, butter): the headline and the paragraph on
  the left at the 480 measure, the step's object on the right at tablet size
  (the two cards with the raccoon between them; the sample truss round with
  its three choices; the mastery card). The next button sits bottom right,
  Skip top right. On honest by design the mastery card sits at the top of the
  right column and the actions (Create my account, Try a round first, I
  already have an account, the terms line) at its foot.
- **Medium:** honest by design (`T13p`) puts the headline and the paragraph
  side by side across the top, the mastery card under them, the actions at
  the foot. The other two steps follow the same order.
- **Titles** and the **splash** (`T14b-splash-landscape`): centred marks,
  phone-like on purpose. There is nothing to arrange, and they last seconds.
- The app has no separate try-one or paper hand-off screens any more (the old
  reference kit drew them): "Try a round first" opens a real round, which
  follows the board rules above.

### Sign up, log in, forgot password, check your email

Mockups: `T12-create-email-landscape`, `T12b-create-name-landscape`,
`T12c-create-password-landscape`, `T12d-create-school-landscape`,
`T12e-log-in-landscape`, `T12f-forgot-landscape`,
`T12g-check-email-landscape`, `T12p-create-email-portrait`.

- **Expanded:** the ground colour runs edge to edge (fog, butter for the name,
  spring for the password, peach for the school, as the phone's flow). The
  close or back button and the step dots on the top line; the headline at 76
  to 84 on the left; the one oversized field, its caption and the row with
  the text link and the round next button on the right. One field per screen
  still.
- **The keyboard is drawn.** On an iPad in landscape the keyboard takes about
  300 of the 820 points. Every field, its caption and its next button sit in
  the band above it; the mockups show the keyboard (a plain stand-in for the
  system one) to prove it. On the school step the graduating chips move under
  the headline on the left, because under the field they would sit behind the
  keyboard. The big FE letters the phone sets behind log in are left out: on
  a tablet the keyboard covers that band.
- **Check your email:** the verify sheet, capped at 640 and centred, with its
  two actions side by side and the two text actions on one line under them.
- **Medium:** stays phone-like on purpose (`T12p`): the phone's column, set
  left, above the keyboard. With the keyboard up, a portrait window has a
  phone-sized band left, and one field per screen already fills it.

### Every other screen

Each row says what the tablet does and whether it passes the test in the
self-check: does the screen show more, or arrange better, than the phone, or
is it only larger? Where a screen stays phone-like, the row says why that is
on purpose.

| Screen | Mockup | On a tablet | Test |
|---|---|---|---|
| Exam date | `T15-exam-date-landscape` | The question and the chosen date (Jan 15, its weekday, "73 days out") on the left; month chips and two full weeks of days on the right, so the days around the exam are visible at once; Clear the date and the round next button at the foot | Arranges better, shows more days |
| Days studied | `T16-days-studied-landscape` | The count (27 days), its line and the month chips on the left; this month and last month as grids on the right | Shows more: two months, not one |
| Mastery | `T17-mastery-landscape` | The total (21 percent), its line and "where effort pays" on the left; the picked chapter's card and every chapter's tile on the right, the picked tile charcoal | Arranges better: the chart and the chapter it points at side by side |
| Account sheet (the settings: appearance, reminders) | `T18-account-sheet-landscape` | Bottom sheet capped at 640 over the dimmed Profile | Phone-like on purpose: a short settings sheet; a side pane would compete with Profile |
| About | `T18b-about-landscape` | The same sheet, taller, text at the 620 measure | Phone-like on purpose: one column of prose is the right form for reading |
| Edit profile | `T18c-edit-profile-landscape` | The same sheet, three rows | Phone-like on purpose: three rows |
| Contact us | `T18d-contact-landscape` | The headline and the promise on the left; the email and message fields on the right; Send it bottom right | Arranges better: the message box gets the height |
| Feedback sheet ("Something unclear?") | `T19-feedback-sheet-landscape` | Docks on the right at 460 like the concept sheet, so the round and its drawing stay in view while the student says what is wrong | Arranges better |
| Badges | `T20-badges-landscape` | The headline and the count on the left; the fifteen chapter coins five across and the four milestones on the right, all on one screen | Shows more: no scrolling |
| Badge moment | `T20b-badge-moment-landscape` | The card centred, the coin larger; All badges and Carry on at the foot | Phone-like on purpose: a moment is one thing |
| League moment | `T22-league-moment-landscape` | The same shape: the coin, "You moved up to Silver", the line, Carry on | Phone-like on purpose: a moment |
| XP | `T23-xp-landscape` | The total, its line and the app and website halves on the left; how it is earned and today's bar on the right | Arranges better |
| Concepts | `T23b-concepts-landscape` | The count and its line on the left; the concepts grouped by chapter, two columns of rows, on the right | Shows more |
| Exam outcome ("How did it go?") | `T24-exam-outcome-landscape` | The question as a headline on the left; why we ask and the three answers on the right | Arranges better |
| Pass card | `T24b-pass-card-landscape` | The card large on the left (a stand-in here; `pass_card.dart` draws the real one); "It is yours." and Save or share on the right | Arranges better: the card is the object, the actions sit beside it |
| Outcome link (the email link's page) | none | As the exam outcome: the question left, the choices right | Same pattern as `T24` |
| Update needed | `T25-update-needed-landscape` | The headline left, the reason right, the pill bottom right | Phone-like on purpose: one message and one action |
| A lesson not ready yet | none | The lesson pane's own message ("This lesson is not ready yet...") in place of the game rows | Lives inside the lesson pane (`T03`) |
| Guest Profile | `T25b-guest-profile-landscape` | The headline and the rounds on the left; what a free account adds and Create an account on the right | Arranges better |
| Guest Daily | `T25c-guest-daily-landscape` | The Daily's left column as signed in; the three concepts and Sign up to play on the right | Same split as `T08` |
| Splash, titles | `T14b`, `T14` | Centred marks | Phone-like on purpose: nothing to arrange |

## 5. Games, concept sheets and pictures: bigger and clearer

A drawing on a tablet must get **larger and clearer, not padded**.

1. **The box grows first.** The drawing takes the space the layout gives it
   (section 4), keeping the aspect ratio its painter was designed at. It is
   never letterboxed inside a phone-sized box.
2. **Strokes and labels grow with it, to a limit.** Each painter gets a figure
   scale, `s = clamp(box width / 342, 1, 1.6)` (342 is the phone's figure
   width; 1.6 is `tablet.figure.maxScale`). Strokes, label sizes, the angle
   arc, the right-angle square and hit areas multiply by `s`. Above 1.6 the box
   still grows but lines and labels stop: a 6 point line is already bold.
3. **The engineering grid scales with the drawing**, so a drawing shows the
   same number of cells it shows on the phone. Otherwise a bigger drawing on
   the same grid reads as a smaller object.
4. **The gate still applies, at more widths.** The automation gate today checks
   that a round fits 320 to 430 points. Add 560 and 700 wide figure boxes to
   it, and render the contact sheets at 1180 by 820 for review. Half-width pairs
   that clip labels on the phone (concept-sheet-shape) must be checked again;
   the cause is the same.
5. **Engineering correctness is not scaled away.** Scaling must not change
   orientation, proportions or symbols. If a painter places a label by fixed
   offsets, those offsets scale with `s` too, or the label drifts off its
   member. The owner checks drawings; review them at tablet size.

## 6. Split screen and the Handbook

The point of supporting split screen is the Handbook PDF beside the app.

- On an 11-inch iPad in landscape, half and half gives the app about 585
  points: **compact, the phone app**. That is correct. The phone layout is
  designed for exactly that width, and the student is looking at the PDF.
- Two thirds for the app (about 795) gives medium: one pane, larger drawing.
- On a 13-inch iPad, half and half gives about 683: medium.
- iPadOS 26 lets windows be any size. The classes handle any width; nothing
  is designed for a specific split ratio.
- Requirements for iPad multitasking: the app must support all four
  orientations on iPad and must not set `UIRequiresFullScreen`.

## 7. Type and spacing on a tablet

Most type stays at its phone size: a tablet is held a little further from the
eye than a phone, so 16 to 17 body text reads the same. What grows is the top
of the scale, so hierarchy still comes from scale contrast on a bigger window.

| Style | Phone | Tablet | Note |
|---|---|---|---|
| hero number | 118 to 132 | 150 to 200 (`tablet.type.heroXL`, 150) | One per window |
| tile number | 68 | 84 to 104 | Profile facts |
| headline | 40 to 48 | 52 to 64 (`tablet.type.headlineXL`, 64); welcome and Profile up to 96 | |
| sheet title | 38 | 38 to 44 | |
| pill label | 22 | 22 | The pill does not grow; it is a button |
| body | 15 to 17 | 17 (`tablet.type.bodyTablet`, line height 1.5) | Question text in a round 18 to 20 |
| caption, eyebrow, data | as phone | as phone | |

**Measure.** Body text never runs wider than 620 points
(`tablet.measure.body`), which is about 70 characters of Inter at 17. Wider
columns are split (two step columns) or capped and set left; body text is never
centred to fill a line.

**Spacing.** The phone's scale holds; the tablet adds the pane tokens of
section 3. Gaps between blocks run 24 to 46 (the phone's 22 to 30, one step up)
because the blocks are bigger.

**Controls.** Touch targets stay at least 44. The pill is 72 tall and capped at
440 wide (`tablet.size.pillMax`) except inside a pane narrower than that, where
it spans the pane. A 1,000 point pill reads as a banner.

## 8. Dark mode

Nothing new. Every colour on a tablet is a `ThemedColor` from
`app_colors.dart`, so Warm night (ADR 0025) carries over. Two things to check
on the new layouts:

- **The rail** is cream by day and `cream` at night (#272522), with the same
  soft shadow; it must stand off the fog (#1B1A18) the way the dock does.
- **Spring roles in the second pane.** The path's lesson-in-flight label is
  spring with `onAccent` text in both themes; the chapter circle is
  `springField` (deep green at night). Mixing those two up makes text
  unreadable at night; the night mockup `T01n` shows the right pairing.
- The concept sheet beside a round uses `sheet` (night #2E2B27) so it stands
  off the fog behind the round.

Run the night goldens at tablet size too:
`flutter test --dart-define=DARK_PALETTE=true` with the tablet surface sizes.

## 9. Orientation and rotation mid-round

- **Phones stay portrait-only** (as today). **Tablets allow all four
  orientations.** The lock is chosen by the device's shortest side (600 or
  more is a tablet), not by the platform, so foldables and Android tablets get
  it too.
- **Rotating never loses state.** The rules for the builder:
  1. The size class is read inside the layout (a `LayoutBuilder` or
     `MediaQuery.sizeOf`), and switching it rearranges the same widgets. It
     never replaces a route, pops a sheet, or rebuilds a game's `State`.
  2. Everything a round knows lives above the layout: `BoardSession` (round,
     answers, sync), the game's own state (the student's pick, here
     `_choice`), the open or closed concept sheet. Moving the drawing from
     beside the answer to above it must not reset the pick.
  3. Anything with its own state that moves between panes (a painter with an
     animation, a Rive artboard, a scroll position) keeps a `GlobalKey`.
  4. If the window becomes compact while the concept sheet is open beside a
     round, the sheet becomes the phone's sheet over the round, still open.
  5. The Daily's clock keeps running through a rotation; it pauses only when
     the app leaves the front, as today.
  6. On Study, the paged chapter, the grid-or-tile view and the opened lesson
     survive rotation; on a change to compact the opened lesson becomes the
     phone's lesson sheet over the chapter map.
- Test it: a widget test that pumps a round at 1180 by 820, picks an answer,
  pumps at 820 by 1180 and at 390 by 844, and checks the pick, the round
  number and the sheet's state each time. One such test per layout family
  (board, Study, Daily) is enough.

## 10. Keyboard and pointer (only what comes free)

Flutter gives these for little or no work; nothing beyond them is proposed.

**Deferred (2026-11-03).** The first tablet release ships without this
section. Hover, the focus ring and the keys are left for a later release;
nothing in the layouts above depends on them.

- **Hover:** pills, round buttons, rail items, rows and nodes take a pressed
  look at about half strength on hover (a pointer is a promise to tap). No
  hover-only information, ever: a touch user must see everything.
- **Focus:** a visible 3 point ember focus ring with a 3 point gap on every
  control, the same as the reference HTML's `:focus-visible`. Tab order follows
  reading order: rail, then the left pane, then the right.
- **Keys:** Return or Space activates the focused control; Escape closes the
  open sheet or the concept pane. No other shortcuts.
- **Pointer cursor** on tappable things, a text cursor in the one field.

## 11. Store screenshots

Turning on iPad support means App Store Connect will require iPad
screenshots for every future submission. Sizes as of 2026-11 (check the
consoles at submission time; both stores revise these):

| Store | Slot | Size (pixels) | Note |
|---|---|---|---|
| App Store | 13-inch iPad | 2064 by 2752 portrait, or 2752 by 2064 landscape (2048 by 2732 also accepted) | Required once iPad is supported; Apple scales it down for smaller iPads |
| Google Play | 7-inch tablet | 1200 by 1920 portrait, or 1920 by 1200 | Each side 320 to 3,840; aspect no more than 2 to 1 |
| Google Play | 10-inch tablet | 1600 by 2560 portrait, or 2560 by 1600 | Each side at least 1,080 to be eligible for tablet features |

They go in `mobile/design/appstore/` and `mobile/design/play/` beside the phone
sets. Landscape shows the side by side layouts best: Study with its path, a
round with the drawing beside the answer, the concept beside a round.

## 12. Ideas, not in scope

Things a tablet makes tempting. None is designed here, and none should be
built without the owner asking.

- An in-app Handbook viewer, so the student does not need split screen.
- Apple Pencil: writing the working on a scratch layer over a round.
- A two-pane Profile where each fact's page shows beside the facts.
- Hardware keyboard shortcuts for answering (1, 2, 3).
- Showing all fifteen chapters' paths as one map on a 13-inch screen.

## Self-check before calling a tablet screen done

Run DESIGN.md's self-check first, then:

1. Render it at 1180 by 820, 820 by 1180 and 585 by 820 (half of an 11-inch).
   Does the last one look exactly like the phone?
2. Squint at the whole window: one dominant element, and only one pill?
3. If there are two panes, are they one subject (a thing and its detail)? Is
   the second one quieter?
4. Is any area larger than a third of the window empty with no reason? Fill
   it by arranging, never by stretching type or tiles.
5. Is body text inside the 620 measure, and left aligned?
6. Is the drawing bigger and are its strokes and labels bigger with it, and
   still correct (orientation, proportions, symbols)?
7. Rotate mid-round, with an answer picked and the concept sheet open. Is
   everything still there?
8. Night: does it pass with `DARK_PALETTE=true`, spring roles right?
9. Which phone reference is it closest to? Same app?
