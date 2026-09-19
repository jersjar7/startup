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
  the certificate the APK is signed with. There is no Android release yet, so
  the route returns 404 until `ANDROID_CERT_SHA256` is set in the service's
  environment. The intent filter in the manifest is in place.
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
