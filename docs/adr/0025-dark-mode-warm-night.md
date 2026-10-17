# 0025. Dark mode is "Warm night": every token has a night value, and the app follows the phone

Date: 2026-10-17
Status: Accepted 2026-10-17 (owner)

## Context

The tester's point 9 (build 1075 notes): "I'd love to see a dark mode
version. I think a lot of users might find themselves studying before bed or
just prefer dark mode normally."

The app's look (ADR 0016, `mobile/design/DESIGN.md`) leans on each screen
having its own ground: fog for most, butter for the Daily, spring for a step
or a right answer, peach for a miss. Every colour lives in `AppColors`, but
there are about 8,500 references to it across 563 files, most of them inside
the 375 games' figures, many inside `const` expressions.

## Decision

1. **"Warm night".** Two night styles were mocked against today's light one
   on Profile, the Daily and a right answer: A, where each screen keeps its
   colour turned down (the Daily a deep amber, a right answer a deep green),
   and B, one near-black ground everywhere with colour only on small marks.
   The owner chose A: a screen should still say which screen it is.

2. **Automatic, plus a choice.** The app follows the phone's own setting. The
   account sheet has Appearance: Auto, Light, Dark, kept on the phone.

3. **Every token is a pair, still `const`.** `ThemedColor` extends `Color`
   with a day and a night ARGB and answers `a`, `r`, `g`, `b` for
   `AppPalette.dark` at the moment it is read. Paints, text styles and
   decorations read those when they draw, so no call site changed and the
   figures follow on their own: charcoal ink turns light, white paper turns
   to the night board.

   *Rejected: a `ThemeExtension` read from the context.* Correct by the book,
   but it means rewriting thousands of call sites, mostly inside painters
   that have no context, and every one is a chance to miss a colour.

4. **Switching repaints in place.** `ThemeModeHost` flips the palette and
   asks the whole tree to build and paint again
   (`reassembleApplication`, which works in a release build and disposes no
   State), so a sheet open on the Appearance choice stays open. Two kinds of
   render object keep what they made on their first paint and compare equal
   across modes, so the host resets them by hand: a `DecoratedBox`'s
   decoration painter and a paragraph's laid-out text (every `Text` and
   `Icon`). This was measured, not assumed: a rounded tile and all text stayed
   their day colours until reset. `test/dark_mode_test.dart` reads pixels
   before and after a switch and fails if any of them regress.

5. **Spring has three roles, and each has its own token.** `spring` is the
   bright accent and stays bright (a pill's circle, the active dock item);
   what sits on it is `onAccent`, dark in both modes. `springField` is spring
   as a ground or a big tile; at night it is a deep green and what sits on it
   needs nothing. `springOnDark` is spring as a mark on a charcoal fill;
   charcoal turns light at night, so it turns a deep green. Text on a dark
   tile that stays dark (the streak row, the menu) is `onTile`.

6. **Some things stay as they are.** The pass card is an image someone saves
   and shares, so it stays light. Badge coins are objects, not surfaces, so
   their colours do not change; the badge card under them follows the mode
   through a new `card` property in the Rive file. The iOS launch screen and
   the Android launch window have night versions of their own, from the asset
   catalog and `values-night`, so a dark phone does not flash the day ground.

## Consequences

- A new colour must be added to `AppColors` as a `ThemedColor` with a night
  value, or it will stay its day colour at night. DESIGN.md says so.
- Putting something on spring: use `onAccent` for what sits on a bright
  spring fill, or `springField` for the fill if it is a ground or a big tile.
- `flutter test --dart-define=DARK_PALETTE=true` draws every tested screen
  and board at night; the goldens are day pictures, so every one fails and
  Flutter writes the night picture beside it for review.
- A colour written straight into a widget (`Color(0x...)`) does not follow
  the mode. The two that mattered, the figure paper and the panel base, are
  now the `paper` token.
