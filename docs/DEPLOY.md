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

The pm2 process runs `index.js 4000 startup`. Node on the box is managed by
mise/nvm, so non-interactive SSH needs a login shell: `ssh … 'bash -ilc "pm2 …"'`.

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

## Quick facts

- SSH key: `secrets/jerson-cs260-key.pem` (user `ubuntu`).
- Live dir: `/home/ubuntu/services/startup/` — Express serves `./public`.
- MongoDB Atlas is **shared** between local dev and prod (one database). Namespace
  any test accounts with `@qa.invalid` and clean them up.
- pm2: `pm2 list`, `pm2 logs startup`, `pm2 restart startup` (via `bash -ilc`).
