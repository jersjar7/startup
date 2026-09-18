# Why the UI kit reads as an app, and ours reads as a form

_2026-09-18. Written against `fe-app-ui-kit` (pristine copy at
`~/developer/fe4raccoons-design/`, corrected copy at `mobile/design/`) and
against build 799 of our Study and Profile tabs. This is the standing guide
for future mobile design work; the visual language it describes is meant to
outlast any one screen._

## The short version

A web form is a document you fill in. An app is an object you hold. The kit
gets its app feeling from a dozen concrete choices, and every one of them
pushes in the same direction: fewer things, much bigger, with color as fill
rather than outline, and the action where the thumb already is. Our screens
are tidy, but tidy is a document virtue. Nothing on them is big enough to be
held.

## The concrete choices

1. **One dominant element, at a scale that is not close to anything else.**
   The kit's hero numbers are 120 to 132 px. Headlines are 44 to 48 px at a
   line height near 1.0. The next-largest thing on the same screen is a
   third of that size. Our largest type is 28 px and the next is 17 px, so
   the eye has nowhere to land first. Hierarchy comes from scale contrast,
   not from position or boxes.

2. **Fills, not borders.** Every surface is a solid block: a full-bleed
   ground (ink, paper, lime, orange) or a solid tile on it. There is not one
   1 px border, hairline divider, or outlined card in eight screens. Borders
   and hairlines are the native vocabulary of HTML forms, and the eye reads
   them as "web" before it reads anything else. Our ring, our dots and our
   ledger lines are all hairlines.

3. **Radius that is unmistakably not a rectangle.** Tiles 32 to 36, sheets
   40, pills and buttons fully round, nothing under 22. Our 10 to 16 px
   radii are the radii of a web button. A 72 px pill cannot be mistaken for
   a form control.

4. **The action lives in the thumb zone and is enormous.** Primary actions
   are a 72 px round button at bottom right or a 72 px pill across the
   bottom, with the low-emphasis alternative as plain text at bottom left of
   the same row. Ours was a 54 px full-width rectangle with a 10 px radius:
   the shape of a web submit button, placed where a web submit button goes.

5. **You answer with a thumb, not a keyboard.** Dates come from a day
   scrubber, quantities from a stepper pair or a gauge, judgments from two
   choice pills or a card deck. A text field appears once per screen, huge,
   with no box, only an underline. Typing is the default on the web; tapping
   is the default on a phone.

6. **One job per screen, and the ground changes between jobs.** Each
   onboarding step asks one question on its own ground color (lime, ink,
   orange), so moving forward is felt as a change of room, not a scroll. The
   step indicator is a bar and dots, never "1 of 3".

7. **Numbers are heroes with a small unit on the baseline.** "37 days",
   "5 h", "5 to go". The number is display size, the unit is body size, and
   they share a baseline. A number in a table is data; a number at 120 px
   with its unit tucked in is a fact about you.

8. **Everything reacts.** Press scales to 0.95 for 120 ms, screens rise in
   with a 60 ms stagger, values overshoot slightly when they change,
   decorative cards float. A static screen reads as a page. A screen that
   answers your touch reads as a thing.

9. **The navigation floats.** A dock inset 28 px from the edges with a soft
   deep shadow and icon-only destinations, the active one a filled lime
   circle. A labeled tab bar glued to the bottom edge is the browser's
   chrome brought indoors.

10. **The type has a personality and a job split.** A display face with real
    weight (Bricolage 800, tracking -0.045 em) for anything that must be
    felt, a plain body face for anything that must be read, a mono for
    eyebrows and data. Eyebrows are the only uppercase. Our stack does the
    same split (DM Sans, Inter, JetBrains Mono) but we never let the display
    face get big enough to have a personality.

11. **The voice is a study partner.** Headlines are questions: "When's the
    big day?", "Solid or shaky?" Buttons say what happens: "Let's go", "Start
    day one". Never "Submit", "Continue", "Next". Copy that sounds like a
    registration system makes the screen a registration system.

12. **Generous, not dense.** 24 px side padding, 22 to 30 px between blocks,
    and rarely more than four things on a screen. Our chapter page had nine.

## The adjectives

Use these when briefing or judging future work. A screen should be able to
carry the first list and none of the second.

**Native, in this language:** bold · tactile · physical · confident ·
decisive · generous · playful · high-contrast · warm · immediate ·
thumb-first · one-thing-at-a-time · felt before read.

**Form, what to avoid:** tidy · polite · thin · administrative ·
informational · hesitant · evenly weighted · outlined · labeled ·
keyboard-first · read before felt.

The tell: if you could print the screen on a sheet of paper and it would
still make sense as a document, it is a form.

## Where our current screens fall on these

| Choice | Kit | Our Study tab (build 799) |
|---|---|---|
| Dominant element | 120 px number or 48 px headline | 112 px drawing in a 3 px ring; 28 px name |
| Surfaces | Solid fills, no borders | Cream ground, hairline ring, no fills |
| Radius | 32 to 36; pills round | 10 px button |
| Primary action | 72 px pill or round button, bottom third | 54 px full-width rectangle |
| Input | Scrubber, stepper, gauge, deck | Tap, swipe (good), no keyboard (good) |
| Ground per step | Changes | Cream everywhere |
| Numbers | Hero with unit | 12 px mono line |
| Motion | Press, rise, overshoot | None |
| Navigation | Floating icon dock | Material tab bar, labeled |
| Voice | Questions, "Let's go" | "Continue", "Start", "Set your exam date" |

What we already do right: one chapter per screen, no keyboard, the swipe,
the honest exam line, the marks as the identity of a chapter. The structure
is sound. The clothes are a website's.

## What this does not decide

The kit also brings its own palette (ink, paper, lime, orange) and its own
faces (Bricolage Grotesque, Geist, Geist Mono), and its DESIGN.md says not
to import the website's colors, fonts or logo. That is a brand decision, not
a hierarchy one, and it belongs to the owner. Every choice in the list above
works equally well with our brand tokens (charcoal as ink, cream as paper,
ember as the fill accent, sunbeam as the second ground, DM Sans at 800 as
the display face) or with the kit's. See `mobile/design/README.md` for the
open question.
