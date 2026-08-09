# Deployment Runbook

Production is an AWS EC2 box (`fe4raccoons.com`) running the Express service
under **pm2**, with the React build served as static files by that same Express
process. Caddy is a thin reverse proxy: `reverse_proxy localhost:4000`.

## Branch workflow

The repo keeps **two long-lived branches**, kept in sync:

- **`main`** — production. This is what gets deployed. Never commit to it directly.
- **`development`** — the active/staging line. Do work here, or on short-lived
  feature branches taken off `development` and merged back into it.

**Every deploy follows the same sequence:**

```bash
# 1. integrate work into main
git checkout main && git merge --ff-only development   # (or merge the feature branch)
git push origin main

# 2. deploy from main (see commands below)
./deployReact.sh -k secrets/jerson-cs260-key.pem -h fe4raccoons.com -s startup

# 3. re-sync development so the two branches never drift
git push origin main:development
```

After a clean deploy, `main` and `development` point at the same commit. Delete
feature branches once merged (local **and** remote) — keep only `main` and
`development` standing.

## ⚠️ The service name is `startup`, NOT `fe4raccoons`

The live pm2 process is named **`startup`** and runs from
`/home/ubuntu/services/startup/`. **Always deploy with `-s startup`:**

```bash
# Full deploy (frontend + backend, restarts pm2) — use when service/ changed:
./deployService.sh -k secrets/jerson-cs260-key.pem -h fe4raccoons.com -s startup

# Frontend-only (faster, no restart) — use when only src/ changed:
./deployReact.sh   -k secrets/jerson-cs260-key.pem -h fe4raccoons.com -s startup
```

Using `-s fe4raccoons` silently deploys to `services/fe4raccoons/` — a directory
**nothing serves** — and its `pm2 restart fe4raccoons` fails with "Process not
found", leaving the live site unchanged. `.env` is preserved across deploys
(the scripts back it up and restore it).

## ⚠️ Never deploy on top of an in-progress exam simulation

The paid **Exam Simulation** is a single timed **6-hour (5h20m)** in-app
session. A deploy that restarts the backend (`deployService.sh`) or swaps the
bundle (`deployReact.sh`) under a user **4 hours into a paid exam** breaks them.
Protections, in order of importance:

1. **Active-sim preflight (automatic).** Both deploy scripts now run
   `service/checkActiveExamSims.js` on the box first. It queries `examAttempts`
   for any `status: 'in_progress'` started within the last ~5h50m. If one is
   live, **the deploy aborts** (`PREFLIGHT_BLOCK`). A check that can't run
   (`PREFLIGHT_WARN`) fails open so a DB hiccup never blocks all deploys.
   - Override with **`-f`** only if you accept interrupting the user:
     `./deployService.sh ... -s startup -f`
2. **Graceful restart.** `deployService.sh` uses `pm2 reload --update-env`
   (drains in-flight requests) with a `pm2 restart` fallback — not a hard
   restart.
3. **Deploy window.** Target **2am Pacific** as defense-in-depth. Note a 6-hour
   session can straddle any fixed window, so the preflight (1) is the real
   guard, not the clock.
4. **Additive/back-compatible API changes** so a currently-loaded bundle never
   breaks mid-session; behavior changes ship dark + flagged (see
   `docs/mobile/study-load-implementation-plan.md`).

Only **3 users** have ever bought the sim, so an in-progress attempt is rare —
the preflight almost never fires, but when it does it is protecting a paying
user mid-exam.

The pm2 process runs `index.js 4000 startup`. Node on the box is managed by
mise/nvm, so non-interactive SSH needs a login shell: `ssh … 'bash -ilc "pm2 …"'`.


## ⚠️ Production secrets, and why `.env` must never be packaged

`deployService.sh` builds the backend by tarring the whole local `service/`
directory. That local `service/.env` is a **dev config holding Stripe TEST
keys**, and it used to be included in the package. It survived only because
`scp -r build/*` skips dotfiles under default bash globbing — one
`shopt -s dotglob`, or a switch to `rsync`, would have pushed test keys over
production and silently stopped all real card charges.

The tar now excludes `.env`/`.env.*` **and the script aborts if an env file is
still present in `build/`**. Do not remove either guard.

Production secrets live only in `~/services/<svc>/.env` on the box. To change
them:

```bash
./scripts/set-prod-secrets.sh -k secrets/jerson-cs260-key.pem -h fe4raccoons.com -s startup
```

Hidden prompt; secrets travel over **stdin**, never as ssh arguments (which are
visible in `ps` on the host); backs up the remote `.env`; **refuses a
`STRIPE_SECRET_KEY` that is not `sk_live_`**; reloads pm2. Never paste live
secrets into chat.

### Why that guard exists

Production silently reverted to a Stripe **test** key for roughly 12 days
(18–30 Jul 2026). Checkout still "worked", Stripe still reported
`payment_status: 'paid'`, both grant paths still granted lifetime access, and
the owner still received a "you made a sale" email — for $0. A real student got
the full paid product free and it was counted as revenue.

Two defences now exist:

1. **Mode match on every grant.** `service/stripeMode.js::isModeMismatch` — a
   payment whose `livemode` does not match the server's key mode is refused in
   both `webhook.js` and `checkout.js`. It is a match, not "must be live", so
   local dev on `sk_test` keeps working.
2. **A boot-time tripwire.** `service/index.js` logs the payment mode on every
   start. Check it after any deploy:

```bash
ssh -i secrets/jerson-cs260-key.pem ubuntu@fe4raccoons.com \
  'bash -ilc "pm2 logs startup --lines 60 --nostream | grep \"stripe] mode\""'
# expect: [stripe] mode: LIVE - real cards will be charged
```

## ⚠️ Verifying a deploy — status codes lie

The Express SPA catch-all returns `index.html` with **HTTP 200** for *any*
unknown path, including a missing `/assets/<hash>.js`. So a status-only check is
a FALSE POSITIVE. Verify one of these ways instead:

```bash
# Content-type must be JS (not text/html) for a real asset:
curl -s -o /dev/null -w '%{content_type}\n' https://fe4raccoons.com/assets/<hash>.js

# Or grep the served bundle for a string you just changed:
INDEX=$(curl -s https://fe4raccoons.com/ | grep -oE '/assets/index-[A-Za-z0-9_-]+\.js' | head -1)
curl -s "https://fe4raccoons.com$INDEX" | grep -c "<a unique string from your change>"

# For API changes, hit the endpoint — 401/JSON means mounted; 404/HTML means not:
curl -s https://fe4raccoons.com/api/<route>
```

## ⚠️ Changing a price — the full surface list

Prices live in two modules and everything else must derive from them:

- `service/pricing.js` — **authoritative**, cents, what Stripe actually charges
- `src/data/pricing.js` — display, dollars

`service/pricing.test.js` asserts the two agree, so a half-finished change fails
the suite rather than advertising a figure the checkout will not charge.

Every surface that shows a price, and how it gets updated:

| Surface | How it updates |
|---|---|
| Landing page, pricing card | imports `src/data/pricing.js` — automatic |
| `/exam-simulation` (+ Product JSON-LD offers) | imports — automatic, needs a rebuild |
| `/fe-civil-exam-guide` FAQ | imports — automatic, needs a rebuild |
| `/stories/mitch` | imports — automatic |
| Logged-in checkout gate | reads `GET /api/checkout/pricing`, falls back to the display module |
| Stripe checkout page | `unit_amount` from `service/pricing.js`; the product *name* carries no price |
| Weekly digest email footer | imports `service/pricing.js` — automatic |
| `/llms.txt` | generated by `scripts/prerender.mjs`, which imports the display module |
| **Landing-page video** `public/explainer.mp4` | **NOT automatic — must be re-rendered** |

**The video is the trap.** `video/Explainer.jsx` reads the price module, but the
served file is a *rendered artifact*. Changing the constant does nothing until:

```bash
npx remotion render video/index.jsx Explainer out/explainer.mp4
cp -f out/explainer.mp4 public/explainer.mp4
```

**Then bump `EXPLAINER_VERSION` in `src/landing/landing.jsx`.** The file has a
stable name, so the page requests `/explainer.mp4?v=N`; without a new N, anyone
who already has the video keeps playing the old cut. This was missed once and the
re-rendered video sat on the server for an hour looking deployed.

Then rebuild and deploy. Verify by extracting the price frame, not by trusting
the render log:

```bash
ffmpeg -ss 24 -i public/explainer.mp4 -frames:v 1 /tmp/frame.png
```

Verifying the video is live means checking the URL the PAGE requests, in a
browser, not `curl`-ing `/explainer.mp4`. The origin can serve new bytes while
every returning visitor still sees the old file.

`public/explainer-poster.jpg` is a title card with no price, so it does not need
re-rendering. The Mitch testimonial video quotes no price.

Surfaces with **no** price, confirmed: OG image, Terms, Privacy, the dashboard
sim card and pitch banner, the countdown and follow-up founder emails (plain
text, deliberately no price), and the unreferenced `public/Slide*.png` CS260
wireframes.

After deploying a price change, grep the live surfaces for the OLD figure — it
must return zero:

```bash
for u in / /exam-simulation /fe-civil-exam-guide /llms.txt; do
  curl -s https://fe4raccoons.com$u | grep -c '\$29'
done
```

Note `/` and `/stories/mitch` render client-side, so raw HTML shows no price at
all; check those in a browser.

## Cache policy — hashed vs stable filenames

Two static middlewares in `service/index.js`, split by whether the filename
changes when the content does:

| Path | Header | Why |
|---|---|---|
| `/assets/*` (Vite output) | `max-age=1y, immutable` | content-hashed, so a change is a new URL |
| everything else in `public/` | `max-age=10m` | hand-authored, stable names, must be able to change |

Until 2026-08-09 **everything** got `1y, immutable`. That froze `explainer.mp4`,
`llms.txt`, `sitemap.xml`, `robots.txt` and `og-image.png` in every browser that
had ever loaded them, and `immutable` means the browser will not revalidate even
on an explicit reload.

**Shortening a cache header does not fix already-cached clients.** A cached
response keeps the directive it arrived with, so a file that went out with
`1y, immutable` stays stuck for a year no matter what the server sends next. The
only fix for those is a new URL — hence `?v=N` on the video.

If you add a stable-named public asset that will ever be updated, either give it
a version query or accept a 10-minute lag.

## Quick facts

- SSH key: `secrets/jerson-cs260-key.pem` (user `ubuntu`).
- Live dir: `/home/ubuntu/services/startup/` — Express serves `./public`.
- MongoDB Atlas is **shared** between local dev and prod (one database). Namespace
  any test accounts with `@qa.invalid` and clean them up.
- pm2: `pm2 list`, `pm2 logs startup`, `pm2 restart startup` (via `bash -ilc`).
