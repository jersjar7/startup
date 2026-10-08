# What we told Apple, and why

Every declaration made in App Store Connect, with the evidence behind it.
First recorded for the 1.0 submission on 2026-10-08 (build 1075).

These are statements, not preferences. Each one was derived by reading the
code rather than from memory, and each carries the check that proves it, so a
future release can re-verify in minutes instead of guessing. **Re-check every
answer here before each submission**: several would change the moment a
feature lands.

See also `app-privacy.md` for the data-collection detail and `review-notes.md`
for the notes pasted into App Review Information.

---

## Content Rights

> Does your app contain, show, or access third-party content?

**Yes, and I have the necessary rights.**

Two things make this a yes:

- **Bundled fonts.** DM Sans, Inter and JetBrains Mono ship as `.ttf` files in
  `assets/fonts/`. All three are under the SIL Open Font License, which permits
  bundling in a commercial app.
- **NCEES handbook references.** 1,531 problems carry `handbookPage` and
  `handbookFormula`. A page number is a citation, and a formula is a
  mathematical fact rather than a copyrightable work. The problems themselves
  were authored for this product.

Answering "No" would have been inaccurate because of the fonts alone.

**The licence notice was missing until 2026-10-08.** The OFL requires its text
and copyright notice to travel with the fonts. Fixed in build 1073: the three
licence texts are bundled in `assets/licenses/`, registered with Flutter's
`LicenseRegistry`, and reachable from the account sheet. `test/licenses_test.dart`
asserts all three are present and are the real OFL.

**Check:** `ls mobile/assets/fonts` and `flutter test test/licenses_test.dart`.

---

## Age Rating

**Calculated 4+. Age category: Not Applicable. No override. No suitability URL.**

Every answer on the features screen was **No**:

| Question | Answer | Why |
|---|---|---|
| Parental Controls | No | None exist |
| Age Assurance | No | The app never asks for or checks an age |
| Unrestricted Web Access | No | No WebView anywhere; two URLs in the whole codebase, opened in Safari |
| User-Generated Content | No | Nothing a user writes is shown to another user |
| Social Media | No | No feed, no leaderboard, no profiles |
| Messaging and Chat | No | Users cannot contact each other |
| Advertising | No | No ad SDK, nothing paid in the app |

**"Made for Kids" was deliberately NOT selected.** It puts the app in Apple's
Kids Category, which forbids collecting personal information from children and
requires a parental gate on external links. This app does both: an email
address at sign-up, and an "Open the website" button. It is also simply untrue
— the audience is engineering students and working engineers.

**No override was needed** because the Terms of Service set no age minimum. If
a minimum is ever added, Apple requires the rating to match it.

**This changes the day a leaderboard ships.** Students seeing each other's names
and ranks makes User-Generated Content and Social Media both **Yes**, which
raises the rating and adds the under-13 question.

**Check:** `grep -riE "webview|InAppBrowser" mobile/lib` and
`grep -rhoE "Uri.parse\('[^']+'\)" mobile/lib`.

---

## Export Compliance

**`ITSAppUsesNonExemptEncryption = false`**, set in `ios/Runner/Info.plist`, so
the question is answered in the binary and never asked at upload.

True because the app uses only HTTPS, which is exempt. `flutter_secure_storage`
uses the system keychain rather than implementing cryptography.

**Check:** `grep -A1 ITSAppUsesNonExemptEncryption mobile/ios/Runner/Info.plist`.

---

## Device and orientation

**iPhone only (`TARGETED_DEVICE_FAMILY = "1"`), portrait only.**

Both were Flutter defaults rather than decisions, and both shipped something
nobody designed. Measured before changing them:

| Size | Result |
|---|---|
| iPad 13" portrait | clean |
| iPad 13" landscape | study days overflowed 473px |
| iPhone 15 landscape | study 46px, exam date 160px, study days 589px |

Dropping iPad also removed Apple's 13-inch screenshot requirement, which was
the error blocking the submission. Making those screenshots would have sold an
experience the app does not deliver.

`test/orientation_test.dart` reads the real build config and fails if either
default returns.

---

## App Review Information

**Sign-in required: yes.** The router redirects a signed-out user away from
everything except game previews and the verification link, so a reviewer
cannot see a single chapter without an account.

**Demo account:** `appreview@fe4raccoons.com`, credentials in
`secrets/app-review-login.json` (gitignored). A real production account, not a
reviewer mode, seeded so the app opens populated and opted out of lifecycle
email. Excluded from analytics in `service/internalAccounts.js`, by default in
code rather than an env var so a deploy cannot lose it.

**Verified before submitting** that the password signs in, returns a mobile
bearer token, and `/auth/me` comes back with the exam date and school present.
A demo account that does not log in is the classic rejection.

---

## Known unverified at submission

**The outcome notification's routing.** It fires nine days after an exam date,
so it could not be tested before submitting. The daily reminder was verified on
a real iPhone on 2026-10-07, covering delivery, permission, scheduling and tap
handling; this is the routing of one notification type.

**Cheapest test:** an exam date nine days in the past on a throwaway account.

---

## Before the next submission

1. Re-read every answer above. Features change what is true.
2. **Age rating and privacy both change if a leaderboard ships.**
3. **Privacy changes if the pass card saves to photos**, which adds a photo
   library permission and a declaration.
4. Confirm the attached build is the newest. The 1.0 submission nearly went out
   with a build from three days earlier that predated notifications entirely.
