# One link, two places: the verification email on the phone

_2026-09-18. The owner's ask: when a student creates an account in the app and
taps the link in the verification email, the link has to know whether to open
the website or the app._

## How it works

The email links to `https://fe4raccoons.com/verify-email/<token>`, and that
does not change. What decides where it opens is the operating system:

- **iOS (Universal Links).** At install time iOS fetches
  `https://fe4raccoons.com/.well-known/apple-app-site-association` through
  Apple's CDN. If the file lists the app's App ID and the link's path, iOS
  opens the app; if not, or if the app is not installed, Safari opens the
  website. The app claims only `/verify-email/*`.
- **Android (App Links).** The same idea with
  `/.well-known/assetlinks.json`, which must carry the SHA-256 fingerprint of
  the certificate the APK is signed with. The intent filter is in place and
  the route returns 404 until `ANDROID_CERT_SHA256` is set in the service's
  environment.

  **The fingerprint is Google's APP SIGNING key, not our upload key.** Play
  re-signs every release, so the certificate a phone sees is Google's. Using
  the upload key's fingerprint is the classic mistake here: the file serves
  happily, the verification fails silently, and the link keeps opening the
  website with nothing to say why.

      ANDROID_CERT_SHA256=15:AA:AF:7E:E4:4F:E7:EA:54:24:59:21:35:39:0E:D7:3C:D9:B4:A2:48:98:67:48:63:E5:0B:87:B5:C5:7E:1C

  Read on 2026-10-09 from Play Console → Protected with Play → App signing
  (direct URL `/app/<appId>/keymanagement`; the menu entry has moved twice).
  That page shows two SHA-256 values. The other one,
  `68:B4:38:…:43:90:DF`, is **our upload key**, which is how this one was
  identified: it matches `secrets/fe4raccoons-upload.jks` exactly, so the
  remaining value is the app signing key by elimination.

  **Applied 2026-10-10**, once the deploy preflight came back
  `PREFLIGHT_OK`. `ANDROID_CERT_SHA256` is set in the service's `.env` (a
  timestamped backup of the previous file sits beside it on the box) and pm2
  was reloaded with `--update-env`. Verified straight after: the route serves
  the fingerprint as `application/json`, the site and `/api` answer normally,
  and the pm2 log still reads `[stripe] mode: LIVE`.

      curl -s https://fe4raccoons.com/.well-known/assetlinks.json

  Android verifies App Links at install time and caches the result, so this
  only takes effect for installs made after this point. There is nothing on
  Play yet, so every real install will be after it.
- **Desktop, or no app.** The website's `/verify-email/:token` page handles
  it, as it always has.

## The pieces

| Piece | Where | Notes |
|---|---|---|
| Association files | `service/appLinks.js`, routes in `service/index.js` | Served with `application/json`, before the SPA catch-all. Tested by `service/appLinks.test.js`. |
| Domain claim | `mobile/ios/Runner/Runner.entitlements` | `applinks:fe4raccoons.com`; `CODE_SIGN_ENTITLEMENTS` in the Xcode project points at it. |
| App ID capability | App Store Connect | `ASSOCIATED_DOMAINS` enabled on `com.fe4raccoons.mobile`; the App Store provisioning profile was regenerated afterwards, because a profile carries the capabilities of the moment it was made. |
| Flutter deep linking | `mobile/ios/Runner/Info.plist` | `FlutterDeepLinkingEnabled` so the link reaches go_router as a path. |
| The route | `mobile/lib/core/router.dart`, `verify_link_screen.dart` | `/verify-email/:token` is reachable signed in or out. It makes the same request the website makes, refreshes the account when signed in, and offers the way on. |

## Verifying a deploy

```sh
curl -sI https://fe4raccoons.com/.well-known/apple-app-site-association | grep -i content-type
# content-type: application/json
curl -s https://fe4raccoons.com/.well-known/apple-app-site-association
```

Apple's CDN caches the file; after the first deploy it can take up to a day
for a fresh install to see it. Apple's validator:
`https://app-site-association.cdn-apple.com/a/v1/fe4raccoons.com`.

## Testing on a phone

1. Install a build made after the profile regeneration (build 829 or later).
2. Create an account in the app, open the email on the same phone, tap the
   link. The app should open on "You're verified."
3. Long-press the link in Mail to see "Open in FE for Raccoons" if the
   association is recognised; if the option is missing, the association file
   was not fetched (see the CDN note above).

## What is deliberately not claimed

`/reset-password/*` stays a website page. The app has no reset screen, and
claiming a path the app cannot handle would open the app onto nothing.
