# What we told Google, and why

Every declaration made in the Play Console, with the evidence behind it.
First recorded for the 1.0 submission, 2026-10-08.

Same rule as `../appstore/declarations.md`: these are statements, not
preferences. Each was derived by reading the code rather than from memory, and
each carries the check that proves it. **Re-check every answer here before each
release.** Several change the moment a feature lands.

Where Play and Apple ask the same question, the answers agree. Where they
differ, it is because the question differs, and that is said below.

---

## App signing

**Play App Signing, with our own upload key.**

Google holds the app signing key and re-signs every release. We hold the upload
key, which only proves the bundle came from us. That is the default and the
right choice: if the upload key is ever lost, Google can reset it, whereas a
lost app signing key with no Play App Signing would mean the app can never be
updated again by anyone.

The upload key is a 2048-bit RSA key valid to 2054, `CN=Oqupa LLC`, alias
`upload`. It lives in `secrets/fe4raccoons-upload.jks` with its password in
`secrets/android-upload-key.json`, both gitignored. **Neither is reproducible:
back up both off this machine.**

Before this, the release build signed with the DEBUG key, which is Flutter's
template default and which Play rejects outright.

**Check:** `flutter build appbundle --release`, then
`jarsigner -verify -certs build/app/outputs/bundle/release/app-release.aab`
shows `CN=Oqupa LLC`, not `CN=Android Debug`.
`mobile/test/android_release_test.dart` fails if the debug default returns.

---

## App access

**Sign-in required: yes.** The router sends a signed-out person away from
everything except game previews and the verification link, so a reviewer
cannot see a chapter without an account.

**Demo account:** `appreview@fe4raccoons.com`, credentials in
`secrets/app-review-login.json` (gitignored). The same real production account
given to Apple: seeded so the app opens populated, opted out of lifecycle
email, and excluded from analytics in `service/internalAccounts.js`.

---

## Ads, purchases and financial features

| Question | Answer | Why |
|---|---|---|
| Contains ads | **No** | No ad SDK in `pubspec.yaml`, nothing paid in the app |
| In-app purchases | **No** | The Exam Simulation is sold on the website only, and the app neither offers nor mentions buying it |
| Uses advertising ID | **No** | No `com.google.android.gms.permission.AD_ID` in the merged manifest and no Play Services dependency at all |
| Financial features | **None** | The app takes no money and shows no financial product |

**Check:** `bundletool dump manifest --bundle <aab>` lists exactly three
permissions, and `grep -n play-services mobile/android/app/build.gradle.kts`
finds nothing.

---

## Data safety

Worked out from the code, and consistent with `../appstore/app-privacy.md`.
The app bundles **no** third-party SDK that collects anything: no analytics,
no crash reporting, no advertising, no attribution. Every byte it sends goes to
our own server. Plausible runs on the website only and is not in the app.

### Collected

Nothing below is **shared** with anybody, and nothing is processed ephemerally.

| Type | Required | Purposes |
|---|---|---|
| Personal info · Email address | Required | App functionality, Account management |
| Personal info · Name | Optional | App functionality, Account management |
| Personal info · User IDs | Required | App functionality, Account management |
| Personal info · Other info | Optional | App functionality |
| App activity · App interactions | Required | App functionality, **Analytics** |
| App activity · Other user-generated content | Required | App functionality |

- **Other info** is the exam date, the school and the graduation term. Play has
  no better home for them and under-declaring is the costly direction.
- **App interactions** is which rounds were answered and whether each was
  right. It drives the progress the person sees, and we read it in aggregate to
  judge the product, so both purposes are true and both are ticked.
- **Other user-generated content** is their answers to practice rounds and to
  the post-exam outcome question. Marked **required**, not optional: the
  outcome question is genuinely optional, but answering rounds is the core
  action of the app and is recorded whenever it happens. Play takes one answer
  per data type, and over-declaring is the cheap direction.

Two more answers the form asks that are not in the table:

- **Can users request that SOME of their data is deleted, without deleting the
  account?** **No.** There is no partial-deletion flow in the product. The
  deletion page does offer, in writing, to leave out the counter row on
  request, but a sentence in an email route is not a feature, and claiming one
  invites a reviewer to look for something that does not exist.

### Not collected

Location, Financial info, Health and fitness, Messages, Photos and videos,
Audio, Files and docs, Calendar, Contacts, App info and performance (including
crash logs), Device or other IDs, Web browsing history, In-app search history,
Installed apps.

**Check:** `mobile/pubspec.yaml` has fourteen dependencies and not one is an
analytics, crash, ads or attribution SDK. The merged manifest asks for
`POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED` and `INTERNET` and nothing else,
asserted by `test/android_release_test.dart`.

### Security practices

| Question | Answer | Why |
|---|---|---|
| Encrypted in transit | **Yes** | `lib/core/network/api_config.dart` points at `https://fe4raccoons.com/api`; no cleartext config anywhere in `android/`, and target SDK 36 forbids cleartext by default |
| Users can request data deletion | **Yes** | https://fe4raccoons.com/delete-account |
| Users can request account deletion | **Yes** | same URL |
| Independently validated against a global security standard | **No** | we have not been audited, and saying otherwise would be a lie |

**The deletion URL is a hard requirement**, not a nicety: Play will not accept
the form without one for an app that creates accounts, and a privacy policy
that mentions deletion in passing does not count. The page is public,
prerendered so the fetcher behind that field sees real HTML rather than an
empty SPA shell, linked from the site footer, and guarded by
`src/legal/deleteAccount.test.jsx`, which also asserts that what the page
promises to erase matches what `service/db/accountDeletion.js` actually clears.

It is honest about the one thing deletion keeps: a counter row with a date, a
reason and three aggregate facts, and no identifier of any kind.

### Measured, 2026-10-08: the policy URL served nothing

Before the fix, `curl https://fe4raccoons.com/privacy` returned HTTP 200 with
the generic landing title and zero words of the policy. So did `/terms` and
`/delete-account`. All three were client-rendered SPA routes, and the SPA
catch-all answers 200 for anything, so nothing anywhere would have reported a
problem. Fixed by prerendering all three.

**Unverified:** whether Google's automated check would actually have rejected
the listing over it. That cannot be tested without submitting. The cheapest
test is the submission itself; the fix costs one deploy and removes the
question, so it was not worth finding out the expensive way.

**Check after the next deploy:**

    curl -s https://fe4raccoons.com/privacy | grep -c "Data Retention"

---

## Content rating (IARC)

**Category: Reference, News or Educational. Every content question: No.**

Nothing in the app depicts violence, sex, drugs, gambling, crude humour or
fear. There is no user-to-user contact, no sharing of location, and no digital
purchase.

Expected outcome: **Everyone / PEGI 3 / ESRB Everyone**, matching Apple's
calculated 4+.

**This changes the day a leaderboard ships.** Students seeing each other's
names makes the "users can interact" and "shares user-provided content"
questions both Yes, which raises the rating in several regions.

---

## Target audience and content

**18 and over. Not appealing to children.**

The audience is engineering students and working engineers preparing for a
professional licensure exam. Selecting any group under 18 would put the app in
the Families programme, whose requirements do not fit an app that collects an
email address at sign-up and links out to a website.

This is the one place Play and Apple read differently: Apple's **4+** says the
content is harmless at any age, which is true, while Play's **18 and over**
says who it is designed for, which is adults. Both are accurate answers to the
question actually asked.

**Check:** the Terms of Service set no age minimum, and the Privacy Policy's
children's section states the platform is designed for adults.

---

## The questions whose answer is simply no

| Question | Answer |
|---|---|
| News app | No |
| COVID-19 contact tracing or status | No |
| Government app | No |
| Health app | No |

---

## Store settings

- **App, not Game.** Play ranks the two separately and the Game category
  carries its own policies. This is exam preparation, whatever the app calls
  its exercises internally.
- **Category: Education.**
- **Contact email:** admin@oqupa.com. **Website:** https://fe4raccoons.com.
  The website field prefills `http://` and keeps it unless the full URL is
  typed. Check it reads **https** after saving.
- **Privacy policy:** https://fe4raccoons.com/privacy.

---

## Before the next release

1. Re-read every answer above. Features change what is true.
2. **A leaderboard changes the content rating and the data safety answers**,
   exactly as it does for Apple.
3. **Saving the pass card to photos** adds a storage or photo permission, which
   is a new line in Data Safety and a new permission a reviewer will ask about.
4. Confirm the bundle's version code. It is the git commit count, the same rule
   the iOS build number uses, so the two platforms stay comparable.
5. `flutter test test/android_release_test.dart` before every upload.

---

## Still open after the first submission

**App Links do not verify yet.** The manifest claims
`https://fe4raccoons.com/verify-email/*` with `autoVerify="true"`, and Android
checks that against `/.well-known/assetlinks.json`. That file needs the SHA-256
of the **app signing** certificate, which Google generates and which does not
exist until the first bundle is uploaded. Until then the route returns 404 and
the link opens the website, which is the correct fallback and not a bug.

To close it: Play Console, Test and release, Setup, App integrity, copy the app
signing key's SHA-256, set `ANDROID_CERT_SHA256` on the server with
`./scripts/set-prod-secrets.sh`, deploy, then confirm
`curl -s https://fe4raccoons.com/.well-known/assetlinks.json` returns the
fingerprint. See `docs/mobile/universal-links.md`.
