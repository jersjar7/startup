# 0034. Retire pack versions no phone can need

**Status:** Accepted (2026-10-29)

## Context

Every FE Civil pack version ever published sat in `service/packs/fe-civil/`
and shipped with the service: versions 1 to 20, 521 MB. Versions 1 to 18
are format 1 (the whole pack in one file), 453 MB of it, because each
carries every game moved so far, and the last ones all 375.

The production server had 982 MB free on 2026-10-29. A deploy keeps the
old service beside the new one until it switches, so shipping 521 MB of
packs would have run it out of disk partway through.

No phone has ever read a format 1 version from the server. Packs are off
in every build students have (`packsOn`, a `--dart-define`), and the app
that will first read them carries version 20 inside it
([ADR 0033](0033-a-pack-is-published-as-one-file-per-chapter.md)) and
cannot read format 1 at all (`refresh()` returns false unless the manifest
format is the app's).

## Decision

Retire versions 1 to 18 from the server: their files are deleted from
`service/packs/fe-civil/` and their entries from the manifest's
`versions`. Versions 19 and 20 (format 2) stay, 64 MB with the chapter
files they name. The published-packs test now asks that the versions still
served run without a gap up to the latest, not that they start at 1.

Version numbers are never reused: the next publish is `latest + 1`, so the
next is 21.

## Consequences

- The server carries about 64 MB of packs, and each new version adds only
  its index and the chapters that changed (usually one, a few hundred KB).
- The retired files stay in git history. To serve one again, restore its
  file and manifest entry from history; nothing else depends on them.
- Once phones read packs, the same rule decides later retirements: a
  version can go when no app that could still hold it as current would ask
  for it. A phone only ever asks for the latest version and the chapters it
  names, so in practice anything older than the version bundled in the
  oldest supported app.
