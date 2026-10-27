# 0031. A pack drawing matches when its geometry matches, not every pixel

**Status:** Proposed (2026-10-27, overnight; for the owner to accept or
overturn)

## Context

[ADR 0030](0030-content-packs-and-game-types.md) moves every game's drawings
into a downloadable pack. Each drawing is recorded by running the game's own
painter at every width a phone can give it and keeping each number as a
function of the width, to within a ten thousandth of a pixel (see
`docs/mobile/content-packs.md`, "How a drawing is kept"). The migration
plan's check 1, "looks the same", was run as a strict picture comparison:
the built-in screen and the pack screen had to be identical, pixel for
pixel, on three phone widths in day and night.

That held for phase 0, Construction and Dynamics (about 8,700 screens, no
pixel different). It failed on the first Economics concept sheet, Which
Rate's dashed line climbing on a diagonal, by a few pixels a few shades
apart, and no tightening made it go away. Measured on 2026-10-27:

- Painted off screen at 124 widths, the original painter and the pack's
  replay differed somewhere at 66 of them. Almost always one to five pixels
  by one to five shades out of 255.
- At one width a single pixel differed by 23 shades. Every number in that
  drawing was within four hundred thousandths of a pixel of the original.
- With the tolerance tightened a thousandfold, a few pixels still differed.

The renderer decides how much of a pixel an edge covers by sampling a few
points inside it. An edge that moves by any amount, however small, can
cross one of those points, and that pixel's shade jumps by a sixteenth or
so of the contrast between the line and the ground. Pixel-for-pixel
equality therefore needs the numbers to be identical to the last bit, not
merely close. The first three chapters passed because nearly all their
numbers are straight lines in the width, which the pack stores exactly. A
dash placed along a diagonal, an arc, a label centred on a curve: none of
those can be stored exactly as a function of the width, and the big
chapters are full of them.

## Decision

A pack drawing matches the built-in one when:

1. **Its geometry matches.** Every number in it is within a ten thousandth
   of a pixel of the painter's own, at every width (the builder fits to
   this; turns and moves of the canvas closer, see the reference).
2. **Its pixels match up to sampling.** On every compared screen, no pixel
   differs by more than 32 shades out of 255 in any channel, and no more
   than 0.05% of the screen's pixels (about 160 on a 390 by 844 phone)
   differ at all.

Everything else in check 1 to 4 stays exact: the same screens in the same
order, the same words, the same answers recorded and rounds cleared, the
same layout errors. Every screen that differs at all is still written to
`build/packs/parity/` and printed with its count and largest difference, so
nothing is hidden.

## Consequences

- The big chapters can be moved without storing every curved number at a
  precision that would make the pack many times larger (Does the Mass
  Matter's slope picture alone went from 190 KB to download, at a tenth of
  that tolerance, to 70 KB with an exact angle form).
- A real mistake still fails. A dash missing, a label moved by half a
  pixel, a wrong color, a wrong state drawn: each of these changes many
  pixels by far more than 32 shades.
- What is given up: a change smaller than one sampling flip, on fewer than
  160 pixels, would pass. No such change can be seen on a phone.
- The first three chapters still match exactly; their records say so.

## Alternatives considered

- **Keep strict equality and store curved numbers to the last bit.** Not
  possible as a function of the width: a number like a dash position along
  a diagonal is not a straight line or any short formula in the width. It
  would mean storing the drawing at every width a phone can have, which is
  every real number between 250 and 1,000.
- **Tighten the tolerance until the comparisons pass.** Tried. A thousand
  times tighter still left differing pixels, and the pack grows with every
  step (a tenth of the tolerance roughly triples the points kept for a
  curved number).
- **Store drawings as pictures instead of steps.** Loses day and night,
  every phone width and sharpness, which is why packs keep steps
  ([ADR 0030](0030-content-packs-and-game-types.md)).
- **Compare by eye.** Does not scale to 375 games, and is check 6 anyway:
  the owner plays each chapter before it is switched on.
