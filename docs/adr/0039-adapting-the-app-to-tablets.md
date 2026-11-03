# 0039. On a tablet the dock becomes a rail, and screens with two things show both

- **Status:** Accepted (owner, 2026-11-03)
- **Date:** 2026-11-03
- **Design:** [mobile/design/TABLET.md](../../mobile/design/TABLET.md), mockups in `mobile/design/tablet-screens/png/`
- **Builds on:** [ADR 0015](0015-the-home-is-one-chapter.md) (the home is one chapter), [ADR 0016](0016-mobile-app-language-and-palette.md) (the app language), [ADR 0025](0025-dark-mode-warm-night.md) (Warm night)

## Context

The app is phone only. The iOS target is iPhone only (`TARGETED_DEVICE_FAMILY
= 1`) and the app locks itself to portrait (`main.dart` and `Info.plist`). On
an iPad it runs in iPhone compatibility mode, a small island in the middle of
the screen; on an Android tablet the phone layout stretches edge to edge.

The owner asked for a tablet version that is "not just make font larger or
leave more blank spaces": screens rearranged for the room, landscape, and
split screen, so a student can keep the NCEES Handbook PDF beside the app.

Two facts shaped the decision:

- A student in split screen beside the PDF has a phone-width window (about 585
  points on an 11-inch iPad), so the layout must follow the window, not the
  device.
- 292 of the 375 built games draw a picture, and every one hands the board
  frame a single column. Putting the drawing beside the answer is a change to
  every one of those files.

## Decision

1. **The layout follows the window width.** Under 600 the app is the phone,
   unchanged. 600 to 899 is medium: one pane, drawn larger. 900 and up is
   expanded: two panes where a screen has two things.
2. **On medium and expanded, the bottom dock becomes a left rail** with the
   same three items in the same order, in portrait and landscape alike. A
   sitting (a round, the Daily, a moment), auth and onboarding cover it, as
   they cover the dock on the phone.
3. **Study on expanded is the chapter beside its path.** The chapter tile (or
   the grid) is the left pane; the selected chapter's path is the right pane.
   Opening a lesson replaces the tile with the lesson, keeping the path in
   view. The path is centred in its pane. Continue behaves as on the phone:
   it brings the lesson in flight into view, and the node opens the lesson. On medium (portrait) the same pair is stacked: the chapter as a
   band on top, its path below.
4. **A round on expanded puts the drawing beside the answer.** `BoardShell`
   gains an optional `figure` slot. Games that use it get the drawing on the
   left and the question, answers, feedback and pill on the right; games that
   do not yet use it keep the single column, capped in width. The right
   column is pinned to the drawing: question and answers (and the feedback,
   once answered) at its top edge, flag and pill at its bottom edge. Landscape
   ships before every game has moved; unmoved games use the capped column.
5. **The concept sheet docks beside the round at 960 wide or more, and only
   when the student opens it.** The round stays playable beside it. Under 960
   it opens over the round.
6. **Drawings grow and their strokes and labels grow with them**, up to 1.6
   times the phone's, keeping each painter's aspect ratio.
7. **Phones stay portrait only. Tablets (shortest side 600 or more) allow all
   four orientations**, and nothing a round knows is lost on rotation.
8. New layout tokens go under `tablet` in `tokens.json`; no new colours.

## Owner decisions, 2026-11-03

The draft went to the owner with five open questions. All five were decided
as recommended, except the second, where he kept the phone's behaviour:

1. The rail: approved.
2. Continue on a tablet: behaves as on the phone. It does not open the lesson
   directly.
3. Landscape rounds ship before every game moves to the `figure` slot;
   unmoved games use the capped single column.
4. iPad support goes in the next release, with the iPad screenshots that
   requires.
5. The League is drawn in the slot the brief gave Review, which no longer
   exists (ADR 0014).

He also asked for two layout changes, now in the decision above: the path is
centred in its pane, and the round's right column is pinned to the drawing's
top and bottom edges. The draft had bottom-aligned that column on the pill for
thumb reach; that reasoning is superseded by his call that the top right half
must not sit empty.

## Consequences

- iPad support means App Store Connect requires 13-inch iPad screenshots on
  every submission from then on, and Play shows tablet screenshots too.
- The `figure` slot is a mechanical change to about 292 game files. Until a
  game is moved, its landscape round is a capped single column: correct but
  not the full benefit. The four shared pack game types should go first.
- Painters that place labels at fixed offsets must scale those offsets, and
  drawings must be reviewed at tablet size; scaling can expose clipping and
  drift that the phone hid.
- Every layout switch has to keep the same widget state (rounds, the Daily
  clock, the opened lesson), which needs a rotation test per layout family.
- The phone's goldens must not change; tablet goldens are added beside them.

## Alternatives considered

- **Keep the bottom dock on tablets.** Rejected: on a tablet held in two hands
  the thumbs are at the side edges, and a dock across 1,180 points spreads
  three items far apart. Using the dock in portrait and the rail in landscape
  would move the navigation on every rotation.
- **A centred phone column (letterboxing).** The cheapest option and the one
  the owner ruled out: it is the "more blank space" version, and the drawings
  stay phone-sized.
- **The concept sheet always docked, or open by default.** Rejected: the
  north star puts retrieval first. A rule always in view turns a round into a
  lookup. The book opens it, the student closes it.
- **A horizontal path in landscape.** Rejected: the path's identity is a road
  that climbs, and a sideways path would scroll on the axis the chapter pager
  already uses.
- **A list and detail Profile** (facts on the left, each fact's page on the
  right). Rejected: Profile is a page of type with no tiles (ADR 0023), and
  turning its facts into a list would undo that. Its pages open beside the
  rail instead.
- **In portrait, one chapter tile drawn larger.** Tried first and rejected in
  review: it is the "bigger, with more blank space" version. Portrait has
  height to spare, so the chapter and its path are stacked instead.
- **Stay in iPhone compatibility mode.** Rejected: it is locked to portrait, so
  split screen beside the Handbook and landscape are both lost.
