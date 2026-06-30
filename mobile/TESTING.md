# Testing the app in the simulator

The app is a thin client of the existing backend. Debug builds (`flutter run`)
talk to a backend running on **your Mac's localhost:4000**, because the new
`/content` and per-device session endpoints aren't deployed to production yet.

## One-time
- Xcode + an iOS simulator (already set up).
- The backend's `service/.env` must have the DB creds (it does).

## Run it (two terminals)

**Terminal 1 — start the backend** (full API: auth, content, review, sessions):
```
cd service
node index.js          # serves http://localhost:4000, loads .env automatically
```
Leave it running. It connects to the **live** database, so accounts and progress
are real — use a **test email**, not your personal one.

**Terminal 2 — run the app:**
```
cd mobile
open -a Simulator       # if no simulator is booted
flutter run             # debug build -> talks to localhost:4000
```

## Try the flow
1. Onboarding → **Create account** with a test email (e.g. `test+1@example.com`),
   8+ char password. You'll land on the Verify screen.
2. Tap **Continue to the app** (verification is a soft step) → the three tabs.
3. **Study**: tap a chapter → a subtopic → a lesson → **Practice**. Answer the
   problems (figures + math render); finishing records the session.
4. **Review**: after missing a problem in Study, it shows up here.
5. **Profile**: XP / Days studied / Badges, concept mastery, Sign out, Delete
   account.

## If content changes
The content the app reads is generated from the website's data:
```
npm run gen:content && npm run gen:figures   # rewrites service/content.json + figures.json
```
(These also run as part of `npm run build:seo`.)

## Notes
- The whole flow works locally without deploying anything.
- To point the app at production instead, build in release (`flutter run
  --release`) once the backend is deployed.
