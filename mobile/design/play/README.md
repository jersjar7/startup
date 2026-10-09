# Google Play

Three files live here, and two of them are built rather than written:

| File | What it is |
|---|---|
| `listing.md` | The copy and the settings for the store page. Source of truth. |
| `declarations.md` | Every declaration made in the Play Console, with the check behind each. Re-read before every release. |
| `icon-512.png`, `feature-graphic.png`, `screenshots/` | Built by `python3 design/appstore/build.py play` from `mobile/`. |

## Building the graphics

    flutter test test/appstore_test.dart --update-goldens --tags appstore
    python3 design/appstore/build.py           # both stores
    python3 design/appstore/build.py play      # only this one

The first command photographs the app. The second composes the posters. Both
stores are built from the same `design/appstore/frames.json`, so the copy
cannot drift between them. Review `design/appstore/contact-sheet-play.png`
before uploading, and `search-tiles-play.png`, which is the set at the size a
stranger sees it.

**Play is 9:16, Apple is 2.17:1.** The Play posters are not a crop or a resize
of the Apple ones: the same design is laid out again on a shorter canvas. Every
length is quoted once at the 1320 poster and scaled, so the two sizes cannot be
edited apart by hand.

## Building the bundle

    cd mobile
    N=$(git rev-list --count HEAD)
    flutter build appbundle --release --build-number=$N --dart-define=BUILD_NUMBER=$N

The build number is the git commit count, the same rule the iOS build uses, so
a version code and a TestFlight build number from the same commit match.
Commit everything first, then read the count.

The output is `build/app/outputs/bundle/release/app-release.aab`, about 95 MB
because it carries four ABIs plus the native debug symbols Play uses to
deobfuscate crash reports. What a phone actually downloads is about 16.5 MB:

    bundletool build-apks --bundle=<aab> --output=/tmp/app.apks \
      --ks=../secrets/fe4raccoons-upload.jks --ks-key-alias=upload
    bundletool get-size total --apks=/tmp/app.apks --dimensions=ABI

## Uploading the graphics, and the order trap

**Play attaches a multi-file upload in completion order, not filename order.**
Uploading all eight screenshots at once put them on the listing as 05, 01, 06,
07, 02, 03, 04, 08, which puts the wrong poster in slot 1. The first three sit
side by side in search and were designed as one composition, so the order is
not cosmetic.

There is no reorder control on the tiles, only Remove. The fix is to upload one
file at a time and press Add after each: each one appends to the end, so the
order comes out exactly as uploaded.

**The "price or promotion" warning under the short description is static.**
It reads "Your app may not be promoted on Google Play because your short
description does not meet the following guidelines: Should not use keywords
that indicate price or promotion", which looks like it is flagging the word
"free". Measured on 2026-10-09: the identical warning appears for a short
description containing no price or promotional word at all. It is standing
guidance, not a check on the text, so it is not a reason to drop "completely
free" from the line.

## Rules worth not relearning

- **The release build signed with the debug key** until 2026-10-08. That is
  Flutter's template TODO, never done, and Play rejects such a bundle outright.
- **INTERNET was granted only in the debug and profile manifests**, which is
  also Flutter's template. A release build would have installed, opened, and
  failed every request, with every screen empty, and no debug run would ever
  have shown it.
- **The launcher name was `mobile`**, the project folder.
- **There was no adaptive icon**, so Android 8 and up would have shrunk the
  square PNG onto a plate.

All four are now asserted by `mobile/test/android_release_test.dart`, which
reads the real build files.

- **Keep the upload key.** `secrets/fe4raccoons-upload.jks` and its password in
  `secrets/android-upload-key.json` are not reproducible and are not in git.
  Losing them means a support round trip with Google before the app can be
  updated again.
- **No tablet or TV screenshots.** The app is phone only, the same decision
  taken for iPad.
