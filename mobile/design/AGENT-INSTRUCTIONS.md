# The block that lives in the repo's CLAUDE.md

Kept here so it can be re-pasted if CLAUDE.md is ever rewritten.

---

## Mobile UI rules

Before building or changing any screen in `mobile/`:

1. Read `mobile/design/DESIGN.md` in full.
2. Look at the images in `mobile/design/reference-screens/png/` and open the
   matching file in `mobile/design/reference-screens/html/` for exact values.
3. Use only the tokens in `mobile/design/tokens.json`, through the theme in
   `mobile/lib/core/theme/`. Never hardcode colors, fonts, radii or sizes in
   a screen.

The reference screens define the visual language only. They are not a
feature list: every screen in them is a feature the app has, except
`04-exam-date`, which is a proposal. Do not add features, screens or content
because they appear in a reference. Build what the owner asks for, styled
like the references.

If a screen starts to look like a web form (stacked labeled inputs, bordered
cards in a column, a full-width rectangular button, a hairline list), stop
and redesign the interaction using the translation table in DESIGN.md.

Before saying a screen is done, run the self-check at the bottom of DESIGN.md
and say which reference screen yours is closest to.
