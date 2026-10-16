# Testing the app the way a student uses it

Started 2026-10-16, after two bugs reached the tester's phone in one day.
Neither would have been caught by the tests we had, because every one of
them checked a single screen on its own. No test ever pressed a button and
then looked at what the student saw next.

1. **Lock it in did nothing** in 50 of the 376 games (all added on
   2026-09-11 and 2026-09-12). The answer was recorded, but the game never
   redrew, so the screen sat still until the next tap. It shipped to the
   App Store.
2. **A finished Daily was still offered as unplayed.** The games open on
   top of the Daily tab, so the tab never stopped being the visible one and
   never asked the server again. "How others did" showed nothing.

The tests are in three layers, from fastest to slowest. The first two run
with every `flutter test`. The third runs on a simulator before a
TestFlight build.

## 1. Every game plays (`mobile/test/every_game_plays_test.dart`)

This test opens every built game through `gameScreenFor`, the same function
the router uses. On each one it makes a choice with the game's own controls,
presses the pill, and fails if the answer never shows. Then it presses Next.
A game drawn outside the frame, or a built game with no screen, fails too.

The test doesn't know how each game is answered. It taps the game's buttons
top to bottom, and each spot only once per pass, because a second tap usually
takes the choice back. If that doesn't wake the pill, it tries a grid of
points on the game's drawing, for games where you tap a point on a curve, a
side or an arm. All 376 games can be answered this way today. A future game
it can't answer (a drag, a slider, typed digits) has to be listed in
`_answeredAnotherWay` with the reason, so nothing gets skipped silently.

`mobile/test/board_redraw_test.dart` is a quicker check for the same bug: it
fails if any game file builds a session and never listens to it.

Gotcha: load **both** font sets (`loadBrandFonts` and `loadMathFonts`). The
first sweep, run without the KaTeX fonts, reported overflowing formulas in 50
games. Those weren't real. Tests draw text in a wider stand-in font when the
real one isn't loaded.

## 2. The Daily walked end to end (`mobile/test/daily_journeys_test.dart`)

These tests use the app's real home shell, Daily tab, step screen, game
screens, end screen, repository and run. Only the server is a stand-in, an
`ApiClient` that follows the rules in `service/routes/daily.js`:

- the first try is kept, and a second one sent returns the first
- a day is open for one day either side of the server's date
- the streak counts days played

Because the stand-in replaces only the network, the phone's own offline
cache and its kept-to-send-later result are also under test.

| Journey | What it guards |
| --- | --- |
| A whole Daily, tab to results and back, then the app closed and reopened | The tab refreshes once a result is sent (bug 2); the results and Play again show; no second Play |
| Leaving halfway, app closed, opened again | "Pick up game 1 of 3"; rounds already cleared stay cleared; nothing sent early |
| The signal drops in game three | The result is kept on the phone and the end screen says so; the tab shows it played; it's sent on the next open with a signal |
| Played on another phone | The tab shows the results straight away |
| Play again | It opens the game with every round from the top, even though the Daily just cleared them; no Daily line; nothing sent; the first try's score unchanged; Study progress untouched |
| A game this version doesn't have | "Update the app" instead of Play |
| The clock | Stopped on the step screen and while the app is in the background; running only while a game is on screen |
| A tapped reminder | Lands on its tab from any tab, from inside a game, and from a cold launch: the Daily's two on the Daily, the exam countdowns on Study, the outcome ask and the night before on Profile |
| Midnight passes during the Daily | The result counts for the day it was started; the new day opens fresh, with the streak alive |

A later run, written when the owner asked whether reminders went to the
right place, found that only the Daily's reminders were routed at all, and
only by switching the tab: tapped while a game was open, the game stayed on
screen. Every kind now has its tab, and screens opened over the tabs are
closed first (`HomeShell._onTap`).

The first run of these found two more bugs, both fixed in the same commit:

- **Play again opened a cleared game on its summary.** Every Daily game is
  cleared in Study by the time Play again shows, so an ordinary sitting went
  straight to the game's summary instead of playing it. `BoardSession.playFresh`
  now gives Play again a sitting that plays every round from the top and
  keeps its own count.
- **The tab rebuilt in the middle of a build.** A game claiming its Daily
  slot, and a finished game handing back, both change the run while another
  screen is building. The tab now waits for the frame to finish.

Every bug in this file has a test that fails with the fix removed. Each one
was checked that way before it was committed.

## 3. On the simulator (`mobile/integration_test/daily_device_test.dart`)

These cover what only a real iOS engine can answer:

- iOS holds the Daily reminders, none of them names a Daily number, and
  playing today removes tonight's reminder while keeping tomorrow's.
- The share card renders to a real picture, not a blank one.

```sh
cd mobile
scripts/device-tests.sh            # the first booted iPhone simulator
scripts/device-tests.sh <sim id>   # or a given one
```

**Since iOS 26, the simulator holds no scheduled notification for an app
that isn't allowed to show them.** No test can answer the permission dialog,
and `xcrun simctl privacy` has no notifications switch. `applesimutils`, a
small tool Wix publishes as part of its Detox testing framework, can set it.
The owner approved trusting that one formula on 2026-10-16. Nothing else
from Wix's tap is trusted.

```sh
brew trust --formula wix/brew/applesimutils
brew install wix/brew/applesimutils
```

Every `flutter test` run reinstalls the app, and reinstalling drops the
permission. The script grants it again right before each file, which is why
the files run through the script and not by hand. Run without the
permission, the Daily reminder test stops with that explanation instead of
failing on an empty queue.

## Still checked by hand

- The share sheet itself. Nothing automated can close it, so a test that
  opens it never finishes. The card it shares is covered above.
- The notification permission dialog, on first ask.
- A reminder arriving at its hour on a real phone.

## Not covered yet

- Two phones signed in to the same account and playing the same Daily at
  the same moment. The server keeps the first one to arrive. The phone that
  loses shows the server's result once it refreshes, but no test runs the
  two at once.
- The phone's clock set wrong on purpose to see tomorrow's games. The server
  refuses any date more than a day from its own (covered in
  `service/dailyRoute.test.js`), but the phone side of that refusal is only
  covered as "NOT OPEN YET" in `daily_test.dart`.
- `DailyRepository.sendPending` decides whether a kept result's day has
  closed using the real clock (`DateTime.now`), not `appClock`. It only
  matters for whether a stale result is thrown away, not whether a good one
  is sent.
