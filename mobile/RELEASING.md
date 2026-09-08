# Cutting a TestFlight build

Ask first. The owner said so on 2026-09-08 after a build was spent on a
one-line change that was also wrong. Lessons land on `development` and wait;
they do not each get a build.

## The four steps

```sh
cd mobile

# 1. Bump the build number only. The version stays 1.0.0 until there is a
#    reason for it not to; TestFlight testers see "same version, new build".
#    pubspec.yaml -> version: 1.0.0+<n+1>

# 2. Archive. This succeeds; the IPA step inside it does not, see below.
flutter build ipa --release

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

If step 3 says no profiles were found, pull it from App Store Connect. The API
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

## Build log

| Build | What was in it |
| ----- | -------------- |
| 516   | Mathematics lessons 1 to 4 |
| 517   | Mathematics lessons 5 to 11 (unit circle through vector basics) |
