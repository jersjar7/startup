# Cutting a TestFlight build

Ask first. The owner said so on 2026-09-08 after a build was spent on a
one-line change that was also wrong. Lessons land on `development` and wait;
they do not each get a build.

## iOS notification delivery: VERIFIED 2026-10-07

Measured, on a real iPhone running TestFlight build 1065. The 7pm "nothing
studied today" reminder arrived on the lock screen reading "A few minutes
counts / One round is enough to put today on your calendar", and tapping it
opened the app.

That one observation covers four things no simulator run could:

  - the permission was granted through the real iOS dialog, which no automated
    run can tap;
  - zonedSchedule actually fires on iOS, not just Android;
  - the schedule survived the app being closed, since these are local
    notifications with no server involved;
  - the tap handler routes, rather than opening to wherever the app happened
    to be.

Before this, 1032's line below said Android was verified against a real
operating system and iOS was not. That gap is closed. It was the last
unverified thing standing between this app and an App Store submission.

Still unverified: that the OUTCOME notification lands on the question rather
than the home screen. It fires nine days after an exam date, so the cheapest
test is setting an exam date nine days in the past on a throwaway account.

## The four steps

```sh
cd mobile

# 1. The build number is the git commit count, the same rule the fastlane
#    lane uses (ios/fastlane/Fastfile, git_build_number). Do NOT bump
#    pubspec.yaml: on 2026-09-13 a pubspec bump produced build 526 while
#    fastlane had already shipped 788-794 from the commit count, and
#    TestFlight only offers the highest number, so 526 never reached the
#    phone. Commit everything first, then read the count.
N=$(git rev-list --count HEAD)

# 2. Archive. This succeeds; the IPA step inside it does not, see below.
flutter build ipa --release --build-number=$N --dart-define=BUILD_NUMBER=$N

# 3. Export a signed IPA with MANUAL signing.
xcodebuild -exportArchive \
  -archivePath build/ios/archive/Runner.xcarchive \
  -exportOptionsPlist ios/ExportOptions.plist \
  -exportPath build/ios/signed

# 4. Upload.
KEY=$(python3 -c "import json;print(json.load(open('../secrets/appstore-connect.json'))['key_id'])")
ISS=$(python3 -c "import json;print(json.load(open('../secrets/appstore-connect.json'))['issuer_id'])")
xcrun altool --upload-app -f build/ios/signed/mobile.ipa -t ios \
  --apiKey "$KEY" --apiIssuer "$ISS"
```

## Signing, since 2026-09-18

Release and Profile sign MANUALLY in the Xcode project (Apple Distribution,
the "com.fe4raccoons.mobile AppStore" profile). They have to: the app claims
`applinks:fe4raccoons.com` (`Runner/Runner.entitlements`), and Xcode's
automatic signing reaches for a generic team profile that has no Associated
Domains capability, so the archive fails to sign. Debug stays automatic and
uses `RunnerDebug.entitlements`, which claims nothing, so `flutter run` on a
simulator or a device still works; Universal Links are simply off in a debug
run. If two profiles with the same name are installed, Xcode may pick the
stale one (that produced a false "profile doesn't include the Associated
Domains capability" error on 2026-09-18), so keep exactly one copy installed.

## Why step 3 exists

`flutter build ipa` archives fine and then fails the export with:

```
error: exportArchive No Accounts
error: exportArchive No profiles for 'com.fe4raccoons.mobile' were found
```

Xcode is not signed in to an Apple account on this machine, so automatic
signing has nothing to work with. The archive is already built and correct by
that point, so the fix is to export it separately with manual signing, which
needs two things present:

- **The distribution certificate.** `security find-identity -v -p codesigning`
  must list `Apple Distribution: Oqupa LLC (79KW5HMNLY)`.
- **The provisioning profile**, installed under
  `~/Library/MobileDevice/Provisioning Profiles/`. It is NOT in the repo and a
  clean machine will not have it.

## Reinstalling the provisioning profile

Expect to do this on most builds. The profile has not survived between
builds 520 through 525 on this machine, so pull it from App Store Connect
before step 3 rather than waiting for step 3 to fail. The API
key id and issuer are in `secrets/appstore-connect.json` (gitignored) and the
`.p8` lives at `~/.appstoreconnect/private_keys/AuthKey_<key_id>.p8`, never in
the repo.

```python
import base64, json, pathlib, re, plistlib, time, urllib.request, jwt

cfg = json.loads(pathlib.Path('secrets/appstore-connect.json').read_text())
key = pathlib.Path.home().joinpath(
    f".appstoreconnect/private_keys/AuthKey_{cfg['key_id']}.p8").read_text()
now = int(time.time())
tok = jwt.encode({"iss": cfg["issuer_id"], "iat": now, "exp": now + 900,
                  "aud": "appstoreconnect-v1"},
                 key, algorithm="ES256",
                 headers={"kid": cfg["key_id"], "typ": "JWT"})

def get(path):
    req = urllib.request.Request(
        f"https://api.appstoreconnect.apple.com/v1/{path}",
        headers={"Authorization": f"Bearer {tok}"})
    with urllib.request.urlopen(req) as r:
        return json.load(r)

# Find the IOS_APP_STORE profile named "com.fe4raccoons.mobile AppStore",
# then write its content out by uuid:
for p in get("profiles?limit=200")["data"]:
    a = p["attributes"]
    if a["name"] == "com.fe4raccoons.mobile AppStore":
        raw = base64.b64decode(get(f"profiles/{p['id']}")
                               ["data"]["attributes"]["profileContent"])
        info = plistlib.loads(re.search(rb"<\?xml.*?</plist>", raw, re.S)[0])
        out = pathlib.Path.home() / "Library/MobileDevice/Provisioning Profiles"
        out.mkdir(parents=True, exist_ok=True)
        (out / f"{info['UUID']}.mobileprovision").write_bytes(raw)
```

The profile in use expires **2027-06-23**.

The profile carries the **Associated Domains** capability (Universal Links,
`applinks:fe4raccoons.com`, see `docs/mobile/universal-links.md`). It was
regenerated on 2026-09-18 after the capability was enabled on the App ID; a
profile carries the capabilities of the moment it was made, so if the App ID
ever gains another capability, delete and recreate the profile the same way.

## Build log

| Build | What was in it |
| ----- | -------------- |
| 516   | Mathematics lessons 1 to 4 |
| 517   | Mathematics lessons 5 to 11 (unit circle through vector basics) |
| 518   | Mathematics lessons 12 to 16; chapter one complete |
| 519   | No start-here pill; subtopic names wrap instead of truncating |
| 520   | The silhouette node: four shapes, plinth derived from the face |
| 521   | Statistics, all six lessons; chapter two complete |
| 522   | Ethics, all seven lessons; chapter three complete |
| 523   | Economics, all six lessons; chapter four complete |
| 524   | Statics, all seven lessons; chapter five complete |
| 525   | Mechanics of Materials opens; four lessons that were a game short get their fourth; the untappable arrow |
| 788-794 | Rive lesson nodes, chapter marks, Study tab rebuilt around two numbers (fastlane, commit-count numbering) |
| 526   | Mis-numbered from pubspec; same code as 797. Expired on App Store Connect. |
| 797   | The home is one chapter and one button: pager, overview, ring; Profile carries the two numbers (ADR 0015) |
| 799   | Profile first and the opening tab; Study toggles between one chapter and the grid (built from the working tree one commit before c47dcf3's follow-up landed, so it carries the commit after it too) |
| 806   | The app language, step one: fog ground, spring accent, bundled fonts; Profile home with the hero tile and account sheet, Study tile and grid, the floating dock (ADR 0016) |
| 808   | The dock becomes a full-bleed labeled bar under the content; nothing slides under it any more |
| 810   | The app language, step two: splash, onboarding on four grounds with a real round, two-step create and log in, the verify and forgot sheets |
| 812   | Welcome is the signed-out root; the tour is three pages behind Let's go; back arrows return to Welcome |
| 814   | The tour-seen flag moves out of the keychain so a fresh install shows the tour |
| 816   | Welcome cards carry the chapter marks instead of formulas; the fan no longer hides anything |
| 818   | Back slides back: the signed-out flow pushes and pops, sign in and out fade, the email-to-password step slides |
| 820   | The log-in watermark is anchored by its baseline so the E keeps its foot on every screen |
| 825   | Peach replaces every ember background; the tour rewritten around what the phone is, the website, and the 60 percent cap; the watermark where the owner set it |
| 827   | Butter replaces every sunbeam background |
| 832   | The keyboard leaves when focus does; the verification email link opens the app (Universal Links, signed with the regenerated profile) |
| 837   | The chapter map, lesson sheet and concept sheet in the app language; Rive nodes and plinths kept, recolored; the log-in watermark stays put under the keyboard |
| 840   | The three pages behind the Profile tiles: concept mastery (weighted like the website), exam date set/change/clear, the days-studied calendar (needs the 2026-09-19 backend deploy) |
| 842   | A calmer chapter path: plain lesson names with a tile only on the lesson in flight, a wider weave, a thinner road, progress as a ring in the Rive artwork, no blur under the plinths |
| 844   | The map keeps one chip; the progress arc stands alone, no spring track |
| 848   | The game frame in the app language: pips, book with a one-time dot, the flag above the pill with its own dot after a first miss, the feedback sheet, spring/peach panels, the done hero tile. Feedback needs the 2026-09-19 backend deploy |
| 851   | The feedback chips follow the round: four parts before an answer, six after |
| 853   | The thank-you after feedback stays until put away |
| 859   | Mastery as one number with two halves on every tile (games N of 50); the map hands off to the desk once every game is cleared; a new phone rebuilds its map from the server; the dead lesson screens are gone |
| 863   | The mastery row and page say "Total concept mastery", the website's name for the same number |
| 874   | The phone rebuilds its map from the account read (GET /api/account/state), the same derived state the website reads; the whole log stays as the fallback |
| 880   | Games no longer count toward mastery: the tile says "games N of M cleared" beside the number, the mastery page says games here do not count, and the hand-off tile says every game cleared, the ideas are covered, mastery is earned at the desk |
| 882   | Mechanics of Materials concept sheets read picture first: the game's drawing, three or four short steps for a reader new to the words, each rule read out in words. The first chapter written this way |
| 938   | Every concept sheet in all fifteen chapters reads picture first: the game's own drawing, three or four short steps written for a reader new to the words, then each rule read out in plain words. 372 sheets, fifteen picture files |
| 957   | Second pass on the concept sheets: 43 drawings the writers flagged as thin, redone so the picture carries the idea. Ethics and Economics reviewed. The old rule lists removed, 4,748 lines of dead code |
| 979   | No line runs through a label on a concept sheet: 32 labels moved into open ground, 11 clipped by the panel corner fixed (every Mohr circle read "normal stres"), and the knockout patch painted in the panel's own color instead of a visible tint |
| 983   | Home screen rebuilt as two containers: where you stand (app chapters first, website figures under them at half size) then the chapter in flight. Launch shows the website wordmark on fog, on both the native screen and the Flutter one |
| 987   | Study tab: the Continue pill is the foot of the chapter card, the card's bottom corners go to 60 so they run parallel with the pill's 36, and the card keeps the height it had so the chapter mark does not float |
| 1012  | Mastery page: every chapter as a place on a field, worth against how far, tap a dot for the detail. Says "in this app", never "games". No label on any of the 372 figures sits on another, guarded by a test. Every screen lays out on all six iPhone sizes |
| 1014  | The tour is the first thing a fresh download sees, ahead of the welcome screen, and Skip hands off to welcome. It stops teaching the 60 percent model the app abandoned. Replayable from "How it works" in the account sheet, which is now one action with two beside it |
| 1016  | An opening titles card between the splash and the tour: "Welcome to" drops in from above the screen, the wordmark slides in from past the right edge, "the mobile app" from past the left, each holding about a second. The wordmark is a sticker cut, a five point white margin grown from each letter. A tap skips |
| 1019  | The ember disc closes over the whole screen before the tour arrives. It was clamped to the screen box, so it stopped the moment it touched an edge, and the hand off fired before it had finished opening |
| 1021  | The email placeholder stops asking for a school address: four domains spanning personal mail, Apple, work and school, one picked per screen |
| 1023  | The email placeholder's domain rolls: "you@" stays put and the part after it changes every 1.5 seconds, old up and out, next up into its place. Stops on typing, holds still under reduce motion |
| 1073  | The bundled fonts now ship with their Open Font License text and a Licences entry in the account sheet. DM Sans, Inter and JetBrains Mono are all OFL, which permits bundling but requires the notice to travel with the fonts; they shipped without it until now |
| 1065  | The email address can be changed, which was impossible before: a mistyped address could never be fixed and every email we sent was lost. Requires the password. The study reminders toggle sits at the far right, where every other row's value sits |
| 1063  | The school field suggests universities as you type, from a 2,348-school directory, and still accepts anything typed. A school is named automatically from a .edu address. The account row shows the full university name where it fits and the abbreviation where it does not, and says when a graduation year is still missing rather than reading as finished |
| 1053  | The school form opens inside the account sheet instead of as a second sheet on top of it, with a labelled way back. The field no longer focuses itself, so one tap opens the form rather than the form, the focus and the keyboard at once. The form scrolls, so the save button survives the keyboard on a short phone |
| 1051  | The pass card: a shareable image for somebody who passed, drawn on the phone and matching the website's exactly. Notifications now rebuild when the exam date moves or changes and when a session syncs, so a moved exam stops counting down to the old date and studying in the evening stops earning the seven o'clock nudge. Font loading fixed: the card could export with every heading as an empty box |
| 1032  | Study reminders, all local: an evening nudge on any day with nothing studied, countdowns at three weeks, two weeks, one week and three days, a settle-down message the night before, and the exam outcome question nine days after. School and graduation year at sign-up and in the account sheet. Verified against a real operating system on Android; the iOS permission dialog is the one thing no automated run can tap |
