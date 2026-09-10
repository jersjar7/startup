# Drawing figures for the mobile items

Most items in the app answer by pointing at a picture, so the picture is the
question. A figure that is merely untidy is a bad item; a figure that is wrong
teaches the opposite of what the lesson says.

This is what a figure audit in September 2026 turned up across 24 painters, and
what to do so it does not come back. The mechanical half is enforced by
`mobile/test/figures_test.dart`. The rest needs eyes, and the last section says
how to use them so they actually see something.

## The two rules almost every defect broke

### 1. Never a fixed number where a measurement belongs

Padding comes from the width of the labels that sit in it. Scales come from
the range of the data. Positions come from the geometry.

Every one of these was a constant somebody guessed:

- A right-hand gutter of 46 points, and `Option A` arrived as `ption A`.
- A datum pinned at 56% of the box height, so a curve peaking below the datum
  drew entirely in the bottom half and the thumbnails cut its vertex off.
- A dimension line pushed 20 points off its own axis, which put it straight
  through the member it was measuring.
- Bars scaled by a flat 1.12, so the biggest count printed half outside the
  box.
- A dot plot fixed at 230 points tall, so a round with no repeated readings sat
  in the bottom fifth of an empty box.
- A vertical scale from zero to 2.4 times the target, which put the three
  candidates of one round a pixel and a half apart. That round could not be
  answered from its own picture.

The fix is always the same shape: measure the thing, then lay out from the
measurement. `MomentPainter` places every dimension line off the figure's own
bounding box; `BreakEvenPainter` measures its gutter from its widest line name;
`DotPlotPainter.heightFor` sizes the box from the tallest stack.

### 2. Frame the drawing to its content, and centre it

Anchor to a corner and the leftover space collects in one place, which reads as
a mistake even when nothing is wrong. Anchored at the bottom-left, a tall narrow
force triangle sat in the left third of its box; anchored at the bottom, a wide
flat pair of spreads sat in the lower third of its own.

Work out what has to fit — the axis, the vertex, both ends of every arm, the
labels — and centre that in what is left.

## Text on a drawing

- **Measure the label before you place it.** A label that is wider than the gap
  it was given will be drawn anyway, over whatever is there.
- **Clamp every label to the canvas.** `limitations, from discovery` came out as
  `limitations, from dis` because nothing stopped it.
- **Draw labels last**, after the lines and arrows they sit among. An arrow
  standing on the last period ran its shaft straight through that period's
  number, and drawing the number first only put it underneath.
- **Give a label a patch of canvas** when it has to cross something. Cheaper and
  more reliable than finding somewhere it does not cross.
- **Break the dimension line for its label**, except on a near-vertical one,
  where a horizontal label eats the whole line and leaves two stubs. That one
  goes beside it.
- **Stagger, do not shrink.** Two numbers too close together go on two rows.

## Fonts

DM Sans, the heading face, has **no Greek at all**. A theta set in it draws as an
empty box. Inter has everything the app uses; JetBrains Mono has everything
except subscripts and the double arrow.

- Symbols on figures go in **mono**. Prose goes in the body face, which is Inter.
- **Never a combining mark.** The mono face gives one a full advance, so `x̄`
  comes out as an x with a stroke floating off its shoulder. Use
  `TextDecoration.overline`, or the math renderer.
- Formulas go through `MathText`, which is KaTeX and brings its own fonts. That
  is the right home for anything with real notation in it.

`figures_test.dart` checks every non-ASCII character in every string literal
against the bundled faces. Where a character is safe because of the face it is
drawn in, add it to the allowlist there **with the file and the reason** — the
entry is keyed by both, so the same letter somewhere else has to be thought
about again rather than inheriting the exemption.

## Paths

- **Never ask a path where it starts.** `Path.getBounds()` on a path holding
  nothing but `moveTo` reports empty, so a loop using it to choose between
  `moveTo` and `lineTo` takes the `moveTo` branch every time and draws no line
  at all. One curve in this app was invisible for months that way. Track the
  first point with a flag.
- **A `Paint` with no style fills.** Given an unclosed polyline that means a
  zero-area shape and nothing on the screen. Either close the path or set
  `PaintingStyle.stroke`.

Both are enforced.

## Say the true thing

A figure that renders beautifully can still be a lie.

- Grade Sense drew the **same ramp on every row** whatever the grade, in an item
  whose question is which stretch is steepest. Three identical pictures say they
  are the same.
- The delivery diagram drew design-build's subs hanging where they could not be
  told apart from a contract with the owner, and one contract out of the owner
  **is** what design-build means.
- The cross product's box card was a true rectangle drawn turned the way the
  numbers gave it, so it leaned and read as a second parallelogram, which is the
  one thing those three cards must not do.

Before shipping a figure, ask what a student would conclude from the picture
alone, and whether that is what the lesson says.

## The review pass

Reading the contact sheets is not enough. At three across they are the right
scale for checking content and the wrong scale for checking drawings: the
never-drawn curve read as a design choice and the empty box read as a glyph.

After regenerating the goldens, for **each item with a figure**:

1. Crop the figure out of its own golden in `test/goldens/<lesson>/` and blow it
   up 2x. Six rounds at a time is about right.
2. Look for the things above: labels touching or crossing anything, a drawing
   pushed into one corner of its box, anything clipped at an edge, anything
   whose position is a guess.
3. Check the round the figure is hardest for — the flattest, the steepest, the
   one with the most arrows, the one where two values are nearly equal. Defects
   hide in the extreme round, and the extreme round is the one a student is most
   likely to get wrong for the wrong reason.

Then send both sheet kinds as usual.
