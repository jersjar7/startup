# App Store screenshots

    flutter test test/appstore_test.dart --update-goldens --tags appstore
    python3 design/appstore/build.py

The first command photographs the app. The second composes the posters into
`design/appstore/out/`, ready to upload, plus two review images:
`contact-sheet.png` to judge the set and `search-tiles.png`, which is the same
eight at 150 pixels wide, the size a stranger sees in search results. Anything
unreadable in that strip is decoration and should come out.

## Why the screens are rendered on a narrow phone

The poster is 1320 wide and the app screen sits in a card about 84 percent of
that. A screen captured at a real 440 points would carry its 17 point body text
at about 45 pixels on the poster, which is grey noise in the search tile. So
the app is rendered on a 340 point screen at 4x: the real app laying itself out
for a small phone, no faked screen, and once it is scaled into the card every
word is about a third larger.

## Rules worth not relearning

- **1320 x 2868 is the only iPhone size you need.** It is the 6.9 inch class,
  the one Apple requires; every smaller class is scaled down from it.
- **No alpha channel.** Apple rejects a screenshot that has one. `build.py`
  flattens on export and will stop if a file comes out the wrong size.
- **Never lead with the splash screen.** Guideline 2.3.3 names title art and
  splash screens as something a screenshot may not merely be. The opening
  titles card was slot 1 in the first pass and came out.
- **Do not draw an iPhone.** Apple's marketing guidelines require their own
  bezel, used unmodified, with no added shadow or reflection and a full status
  bar on screen. A plain rounded card sidesteps all of it, and is what
  Brilliant, Quizlet and Pocket Prep do.
- **The moment a paid item appears in a shot**, guideline 2.3.2 requires the
  screenshots to make clear it needs a separate purchase. Nothing in the
  current set shows one.
- **Lock the ground, the headline position and the card geometry** across the
  set. The first three tiles sit side by side in search and are read as one
  composition whether or not they were designed as one.

## Changing the copy

Headlines, overline pills and which screen goes in which slot all live in
`frames.json`. `<em>` inside a headline sets that word in ember. Rebuild with
the second command above.

## Loading the listing

    python3 design/appstore/listing.py

Writes the eight screenshots, the description, keywords, promotional text,
subtitle, URLs, category and the build onto version 1.0. It is safe to re-run:
it replaces the screenshots in the set rather than adding to them. It does NOT
submit, and it does not touch App Privacy, the age rating or export compliance.
Those three are the owner's, and the first of them is not in Apple's API at all.

The copy itself lives at the top of that file, which is the source of truth for
what is on the store page.

**Mint one token and reuse it.** `asc.py` caches the JWT for fifteen minutes.
Generating a fresh one per request trips Apple's rate limit and comes back as a
bare 401 that reads exactly like a bad key. That cost one failed run halfway
through an upload.

**1320 x 2868 is called `APP_IPHONE_67` in the API.** There is no
`APP_IPHONE_69`; sending it returns a 409 on the attribute type.

## What we told Apple

`declarations.md` records every declaration made in App Store Connect, with the
check that proves each one: content rights, age rating, export compliance,
device and orientation, and the review account. `app-privacy.md` has the
data-collection detail; `review-notes.md` is the text pasted into App Review
Information.

Re-read declarations.md before every submission. Several answers change the
moment a feature lands: a leaderboard changes the age rating AND the privacy
answers, and saving the pass card to photos adds a permission to declare.
