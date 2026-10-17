# Badges in the app

The why is in ADR 0024. This is how it works and how to change it.

## Where things live

| What | Where |
|---|---|
| The badges, their words, the rules, the ledger | `mobile/lib/features/profile/badges.dart` |
| The drawings (chapter marks plus four milestones) | `mobile/lib/features/profile/badge_marks.dart`, `mobile/lib/features/study/chapter_marks.dart` |
| The Rive loader, the earned card, the coin | `mobile/lib/features/profile/badge_art.dart` |
| The moment screen and the host that shows it | `mobile/lib/features/profile/badge_moment.dart` |
| The Badges page | `mobile/lib/features/profile/badges_page.dart` |
| The drawing export | `mobile/tool/export_badge_marks_test.dart` -> `mobile/rive/badge/marks.json` |
| The artwork generator | `mobile/rive/badge/gen.py` -> `mobile/rive/badge/scene.rml` |
| The built file the app bundles | `mobile/assets/rive/badge.riv` |
| Tests (rules, ledger, Rive contract, screens) | `mobile/test/badges_test.dart` |
| The release setting Rive needs, and its test | `mobile/ios/Flutter/Release.xcconfig`, `mobile/test/ios_release_build_test.dart` |
| Checking an archive before upload | `mobile/tool/check_release_rive.sh` |
| Looking at it on a real renderer | `flutter run -t lib/dev/badge_gallery.dart` (add `--dart-define=SCREEN=page` for the page) |

## The rules

| Badge | Earned when |
|---|---|
| A chapter's badge (15) | Any lesson in that chapter is finished (every built game in it cleared) |
| Flawless | A finished lesson where every round of every game was cleared on the first try |
| First Daily | The account's longest Daily run is at least 1 |
| Seven in a row | The account's longest Daily run is at least 7 |
| Every chapter | At least one round cleared in each of the fifteen chapters |

"First try" is what `GameProgress.firstTryCount` already records: a round
cleared without a miss on it in the sitting it was cleared in.

The longest Daily run is the server's `streak.best`, sent with today's Daily
(`GET /api/daily`) and with every result (`POST /api/daily/:n/result`). The
phone keeps the largest value it has seen (`badge_daily_best` in shared
preferences) and forgets it on sign out. A result kept offline counts its
run the way the server will.

## When a badge is shown

`BadgeLedger.watch` wraps every cleared round (in `BoardSession.submit`). It
compares the earned set before and after; anything new goes on a queue. A
Daily result does the same through `noteDailyBest(..., announce: true)`.

`BadgeMomentHost` wraps the two screens a badge is earned on, a board's
summary and the Daily's last screen. When it is on top and something is
queued it shows the moment screen, one badge at a time. The Daily's host
waits until the result is back, so badges from the Daily's games and from
the Daily itself arrive together, after the score.

Restored progress never goes through `watch`, so it is never announced.

## The artwork contract

One `.riv`, two artboards, one view model called `Badge`:

| Property | Type | Set by the app to |
|---|---|---|
| `mark` | number | The badge's index in `allBadges`: which drawing shows |
| `coin` | colour | The face: spring for a chapter, butter for a milestone |
| `rim` | colour | The edge, plinth, back face and the ring: forest or sunbeam |
| `ink` | colour | The drawing: charcoal |
| `glow` | colour | The glow behind the coin, strong stop |
| `glowSoft` | colour | The glow, soft stop |

- **BadgeEarned** (780 by 920): the card and the whole moment, 198 frames at
  60 a second. It fires `land` at frame 46 and `traced` at frame 102; the app
  answers with a medium and a light haptic. The words are not in the
  artboard. Flutter sets them over the card at `BadgeArt.wordsTop`, so they
  are real text for a screen reader, on the same clock.
- **BadgeCoin** (340 by 372): the coin at rest with its drawing complete, and
  one shine across it as it appears. Used on the Badges page for earned
  badges. A badge not yet earned is painted by Dart in paper colours.

Each drawing is a group named `Mark <badge id>` inside the face, all hidden.
A state machine layer called `Mark` shows the one `mark` names. In the earned
artboard every stroke has its own trim path, so the drawing traces in the
order the painter draws it, and solid markers pop in when their turn comes.

Until the file loads, and in every widget test, painters draw the badge at
rest. `badges_test.dart` reads `scene.rml` and fails if the view model's
names, the drawings' order, the events or the artboard size drift from
`BadgeArt` and `allBadges`.

## Changing a drawing, or adding a badge

From `mobile/`:

```
flutter test tool/export_badge_marks_test.dart   # the painters -> marks.json
python3 rive/badge/gen.py                         # marks.json -> scene.rml
~/.rive/bin/rive rive/badge --once                # scene.rml -> assets/rive/badge.riv
flutter test test/badges_test.dart
```

A new badge goes in `allBadges` (at the end, so no other badge's index
moves), gets its drawing in `BadgeMarkPainter` if it is a milestone, and a
rule in `earnedBadgeIds`. Then run the four commands.

To look at frames without a phone, `rive rive/badge --screenshot=f.png
--data=mark=4 --advance=100` renders the earned artboard at frame 100 for
Statics.

## Release builds: check before every TestFlight upload

Dart reaches the Rive engine by looking its functions up by name. Until
build 1136 the App Store archive stripped those names, so on every real
phone the badges (and the lesson nodes) were their still drawings. The
simulator does not strip, so it never showed. `STRIP_STYLE = non-global` in
`ios/Flutter/Release.xcconfig` fixes it, and a test fails if it goes.

The test guards the setting, not the build. After `flutter build ipa` and
before uploading, run from `mobile/`:

```
./tool/check_release_rive.sh    # prints RIVE_RELEASE_OK, or fails
```

It compares every name `rive_native` looks up with what the archived app
exports. Run it again after upgrading `rive` or `rive_native`, or after
changing any iOS build setting.
