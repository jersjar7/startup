# Cutting a TestFlight build

Ask first. The owner said so on 2026-09-08 after a build was spent on a
one-line change that was also wrong. Lessons land on `development` and wait;
they do not each get a build.

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
flutter build ipa --release --build-number=$N

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
