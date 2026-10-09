# The Play store listing

The copy below is the source of truth for what goes on the Play page. It is
deliberately close to the App Store copy in `../appstore/listing.py`, because
the two pages describe the same app and a stranger comparing them should not
find two different products. Where they differ, it is because Play asks a
different question.

Play has no API for creating an app or for the Data Safety form, so unlike the
App Store listing, this one is typed into the console by hand.

## App name (30 characters max)

    FE4Raccoons

The same name as the App Store, which is also the name registered to the
bundle. Not "FE for Raccoons": the shorter form is what the icon and the
website already use.

## Short description (80 characters max)

    Fifteen chapters of FE Civil practice, completely free. Nothing locked.

This is the line that appears under the icon in search results, and it is the
only copy many people read. It carries the two things that separate this from
every paid FE app: the scope, and the price.

## Full description (4000 characters max)

    FE4Raccoons is a study app for the Fundamentals of Engineering Civil exam,
    and all of it is free.

    Fifteen chapters. 135 lessons. 2,269 rounds. Nothing is locked and nothing
    asks for a card.

    ONE CONCEPT AT A TIME
    Each lesson is a short run of rounds. A round puts a figure in front of
    you, asks one question about it, and tells you straight away whether you
    were right and why. Two minutes waiting for a bus is a real session.

    EVERY IDEA STARTS WITH A PICTURE
    Behind every concept there is a sheet that draws the idea before it names
    it. You see what is going on first, then the words for it, then the
    formula. There are 370 of them, written so that someone meeting the topic
    for the first time can follow.

    BUILT FOR CIVIL
    The drawings are the ones the exam actually uses. Mohr's circle, flow nets
    under a sheet pile wall, shear and moment diagrams, orifice plates, phase
    diagrams, hydraulic jumps, stress blocks. They were drawn for this exam
    rather than borrowed from a textbook.

    SEE WHERE THE EFFORT PAYS
    Every chapter sits on a field: how far along you are against how much of
    the exam it is worth. One look tells you which chapter is costing you the
    most, so you always know what to open next.

    A FEW MINUTES COUNTS AS A DAY
    Open the app, finish one round, and the day is on your calendar. The count
    only ever goes up.

    THE SAME ACCOUNT AS THE WEBSITE
    Sign in with the account you use at fe4raccoons.com. What you do here warms
    up the work you do there, and the website is where concept mastery is
    earned at the desk. This app tells you that plainly rather than inflating a
    number.

    Completely free. No subscription, no trial, no card.

## Category and tags

- **App, not Game.** Play ranks the two in separate charts and the Game
  category carries its own policies. This is exam preparation.
- **Category: Education.**
- **Tags:** Test prep, Study tools, Engineering. Tags are Play's own
  controlled list, so pick the nearest three rather than inventing wording.

## Contact details

| Field | Value |
|---|---|
| Email | admin@oqupa.com |
| Website | https://fe4raccoons.com |
| Phone | optional, leave empty |
| Privacy policy | https://fe4raccoons.com/privacy |

## Graphics

Built by `python3 design/appstore/build.py play`, from the same
`frames.json` the App Store set uses.

| Asset | Size | Path |
|---|---|---|
| App icon | 512 x 512 | `design/play/icon-512.png` |
| Feature graphic | 1024 x 500 | `design/play/feature-graphic.png` |
| Phone screenshots | 1080 x 1920 | `design/play/screenshots/01-free.png` and seven more |

Play wants 9:16 or 16:9. The iPhone poster is 1320 x 2868, which is 2.17:1,
so the Play set is not a crop or a resize of it: the same design is laid out
again on a shorter canvas. Review the set at
`design/appstore/contact-sheet-play.png` before uploading, and the row of
150 pixel tiles at `search-tiles-play.png`, which is the size a stranger sees.

No tablet or TV screenshots: the app is phone only, the same decision taken
for iPad (see `../appstore/declarations.md`).
