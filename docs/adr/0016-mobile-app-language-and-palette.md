# 0016. The phone gets its own app language and a palette derived from the brand

Date: 2026-09-18
Status: Accepted. Supersedes `docs/mobile/visual-language.md` (2026-06-10)
for the phone; the website's brand system is unchanged.

## Context

After ADR 0015 the Study tab was structurally right (one chapter, one
button, a pager, a grid one tap away) and the owner said it still "looks like
a website form". He commissioned an AI design agent to produce a mobile UI
kit (`fe-app-ui-kit.zip`, pristine copy at
`~/developer/fe4raccoons-design/`). The kit's screens read unmistakably as an
app. `docs/mobile/native-not-form.md` records why in twelve concrete
choices; the short version is scale contrast, fills instead of borders, big
radii, actions in the thumb zone, thumb-driven controls, one job per screen,
motion on every control, and a floating dock.

Two things in the kit could not be adopted as delivered. It showed features
the app does not have (verified against the mobile code and the Node service
on 2026-09-18: no Apple or Google sign-in, no passwordless link, no campus
code, no study-hours setting, no self-rating, no study plan, no daily sets,
no drills, no timer or stats tab). And it replaced the brand outright: a
near-black ground, lime and orange accents, Bricolage Grotesque and Geist,
with an instruction not to import the website's colors, fonts or logo.

The owner's position on the brand: the website tokens applied literally are
"super boring on the mobile app", but the app must stay recognisably the
same brand. He asked for the same color scheme translated: charcoal where
the kit had black, a "brighter, young, fun version of our green" where it
had lime. On seeing a charcoal ground he then asked for a light grey ground
instead, not white or off-white, so that cream tiles still read.

## Decision

1. **Adopt the kit's app language** as the mobile visual language. The rules
   live in `mobile/design/DESIGN.md`; the eleven reference screens in
   `mobile/design/reference-screens/` are the target look, rebuilt so that
   every one of them is a feature the app has.

2. **Derive the palette from the brand rather than replace it.** Every hue is
   a website token moved to the role the app language needs, computed in
   OKLCH and checked for contrast:
   - Fog `#E3DFD7`, a warm light grey, is the ground. Charcoal is never a
     ground. This was the owner's explicit call after seeing both.
   - Charcoal `#2C2C2C` is text on every light or accent surface, and the
     fill of dark tiles, the dock, round buttons and the avatar.
   - Spring `#63F0A8` is the one loud accent: the brand green (forest,
     L 0.52) pushed to L 0.86 on the same hue. It fills the CTA circle, the
     hero tile, the active dock item and the chapter in flight. Charcoal on
     spring is 9.7:1. Spring on cream is 1.4:1, so spring is never text.
   - Forest `#2D7A5F` stays as the green for text on light grounds: field
     underlines, headline accents, done counts.
   - Ember `#F0703F` is the web ember two steps brighter, because charcoal on
     the web ember (`#E8683A`) is 4.3:1 and fails AA; on the mobile ember it
     is 4.7:1. It is a hot ground and the mastery figure.
   - Sunbeam `#F5B731` keeps its brand job (streak, highlight) and is the
     third ground.
   - Cream `#FFF9F0` is paper: sheets, light tiles, answer blocks.
   Chosen over the kit's own greens: Mint `#8CFFC1` (softer) and Neon
   `#49FFAC` (louder) were shown beside Spring on real tiles; the owner chose
   Spring.

3. **Keep the brand's faces.** DM Sans (800 for display, which the app must
   bundle), Inter, JetBrains Mono. The kit's Bricolage and Geist are not
   used.

4. **The kit's feature inventions are out.** Sign-in is email and password
   with a verification link. Onboarding is the real exercise, the chapter
   peek, then sign-up. The dock has two destinations, Profile then Study.

5. **One proposal is carried, unbuilt:** setting the exam date on the phone
   (`04-exam-date`). Today the phone only reads the date the website set,
   and the Study tab's "Set your exam date" line has nowhere to go.

## Consequences

- `docs/mobile/visual-language.md` ("calm canvas, confident color") no
  longer governs the phone. It stays for the record; a note at its top says
  so. Its honesty rules (mastery is not a pass probability; no invented
  countdown) carry over into DESIGN.md unchanged.
- The Flutter theme (`mobile/lib/core/theme/`) must be rebuilt from
  `mobile/design/tokens.json` before any screen is restyled, and DM Sans
  ExtraBold added to `assets/fonts/`.
- Every existing mobile screen will be restyled to the references over the
  following builds, starting with the Study tab and Profile.
- The web brand deck and the marketing pipelines are untouched. The two
  surfaces now share hues and faces but not layouts; DESIGN.md says why.
- The repo's CLAUDE.md carries the "Mobile UI rules" block from
  `mobile/design/AGENT-INSTRUCTIONS.md`.
