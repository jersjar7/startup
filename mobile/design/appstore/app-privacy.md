# App Privacy answers (App Store Connect → App Privacy → Get Started)

Worked out from the code on 2026-10-08, not from memory. The app bundles NO
third-party SDK that collects anything: no analytics, no crash reporting, no
advertising, no attribution. Every byte it sends goes to our own server at
fe4raccoons.com. Plausible runs on the WEBSITE only and is not in the app.

Privacy policy URL is already set: https://fe4raccoons.com/privacy

---

## The first question: "Do you or your third-party partners collect data?"

**YES.** The app has accounts, so it collects at least an email address.

---

## What to tick, and nothing else

### Contact Info → Email Address
- Collected: **Yes**
- Linked to the user: **Yes** (it identifies the account)
- Used for tracking: **No**
- Purposes: **App Functionality** (sign-in, verification, password reset)
  - Also tick **Product Personalisation**? No.
  - Also tick **Analytics**? No.

### Contact Info → Name
- Collected: **Yes**
- Linked: **Yes**
- Tracking: **No**
- Purposes: **App Functionality**
- Why: first and last name are optional profile fields, shown back to the
  person and printed on the pass card. Never required to use the app.

### User Content → Other User Content
- Collected: **Yes**
- Linked: **Yes**
- Tracking: **No**
- Purposes: **App Functionality**
- Why: their exam date, their school and graduation term, their answers to
  practice rounds, and their answer to the post-exam outcome question.

### Usage Data → Product Interaction
- Collected: **Yes**
- Linked: **Yes**
- Tracking: **No**
- Purposes: **App Functionality**, and **Analytics**
- Why: which rounds were answered and whether each was right. It drives the
  chapter progress the person sees, and we also read it in aggregate to judge
  the product. Both purposes are true, so both are ticked.

### Identifiers → User ID
- Collected: **Yes**
- Linked: **Yes**
- Tracking: **No**
- Purposes: **App Functionality**
- Why: the account id ties their progress to them across devices.

---

## What to leave UNTICKED, and why

Each of these is a real question the form asks. The answer is no for all of
them, and it is worth being able to say why.

- **Location** — never requested, no location permission in Info.plist.
- **Contacts, Photos, Health, Financial Info** — none requested. Info.plist
  declares NO usage descriptions at all, which is checkable.
- **Device ID / Advertising ID** — no IDFA, no ad SDK, no attribution SDK.
- **Purchases** — there are none in the app.
- **Diagnostics / Crash Data** — no crash reporting SDK is bundled.
- **Search History, Browsing History, Sensitive Info, Audio, Gameplay Content,
  Customer Support, Emails or Text Messages, Other Data** — not collected.

## Tracking

The whole app answers **No** to tracking. "Tracking" in Apple's sense means
linking this data to third-party data for advertising or sharing it with a
data broker. We do neither, and there is no SDK in the binary that could.
That is why App Tracking Transparency is not implemented and no prompt
appears.
