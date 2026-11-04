# Reminders ask: the invitation to turn on reminders

Proposed 2026-11-04 for the owner's approval. Mock only; nothing is built.
Mocks in `png/` (3x), from `html/`, built by `python3 build.py`.

| Mock | What |
|---|---|
| `A1-daily-done-ask-day` | Moment 1, phone, day |
| `A1n-daily-done-ask-night` | Moment 1, phone, night (Warm night) |
| `A2-reminders-on-day` | After yes: the sheet's confirmed state |
| `A3-first-lesson-ask-day` | Moment 2, phone, day |
| `T-A1-daily-done-ask-landscape` | Moment 1, tablet 1180 by 820 |

## Form

Both moments use the same cream bottom sheet (DESIGN.md: top radius 40,
grabber, padding 12 / 24 / 34, over the dimmed screen). It rises only after
the result and any badge moment have finished, so the student has seen what
they earned before we ask. On a tablet the sheet follows TABLET.md: capped at
640 wide, centred, the scrim covering everything.

- **Moment 1** sits over the Daily done screen, which stays exactly as it is
  today underneath (hero, time and streak tiles, Share and How others did).
  The sheet carries the streak the way the Daily draws it: a butter block with
  the figure (`1 day streak`) and the `STREAK` eyebrow.
- **Moment 2** sits over the chapter map. Its eyebrow (forest) names the
  lesson just cleared. The sheet is at least 424 tall with the buttons pinned
  to its foot, so only the cleared node shows above it.

## Copy (in the mocks)

Never a time of day, anywhere (owner, 2026-11-04). The plan's hours can move.

**Moment 1, after the first Daily**
- Figure: `1 day streak` (the real streak)
- Title: `Don't let day 1 be your only day.`
- Body: `Most streaks end on a busy day, not a hard one. We can remind you, so yours does not.`

**Moment 2, after a lesson is fully cleared** (any lesson, so students updating with lessons behind them are asked too; still once at most)
- Eyebrow: `<LESSON NAME> · CLEARED`
- Title: `One lesson down.` / `Don't stop at one.` (break after "down.")
- Body: `We can remind you to keep going. A few minutes a day beats a night of cramming.`

**Both:** pill `Remind me`; text action `Not now`. The decline label stays
neutral on purpose: Apple 5.1.1 forbids pushing people into consent, and we
have been rejected once already.

**After yes:** title `Reminders on.`, one line under it:
- Moment 1: `We will nudge you so the streak keeps going.`
- Moment 2: `We will nudge you so the road keeps moving.`

The pill becomes `Done`. The sheet also closes itself 2s after the confirmed
state appears, so nobody has to tap it.

**Denied by the system dialog:** the body becomes one line,
`Notifications are off for this app in your iPhone settings.`, with
`Settings` as a text action (opens the app's settings page). Device word from
`deviceNounOf`. The pill becomes `Done`.

## Alternates (not in the mocks)

Moment 1:
1. `Tomorrow makes 2.` / `We can remind you so the streak keeps going. One tap now, and you will not lose it to a busy day.`
2. `Day 2 is where most streaks end.` / `Not because it is hard, but because the day gets away. We can remind you before it does.`

Moment 2:
1. `A little every day adds up.` / `We can remind you to come back. A few minutes a day beats cramming the week before the exam.`
2. `Lesson one is done. Keep the road moving.` / `We can remind you to come back, so a busy week does not undo the start you just made.`

"Most stop here" is a claim about our students. Before it ships, check it
against the data (share who clear lesson 1 and never clear lesson 2). If it is
not true, use Moment 2 alternate 1.

Wording rules held: no em dashes, no exclamation points, no emojis, no price
words, no one-word last line in any title or body at phone or tablet width.

## Timing rules

- At most two invitations, ever, per install. Moment 1 first; Moment 2 only if
  Moment 1 was dismissed or never shown.
- At least 3 calendar days between the two.
- Never on the first launch day.
- Never if reminders are already on, or if the system has already denied
  notifications (the Profile row stays the way back).
- Signed-in students only (guests have no Daily streak).
- Moment 1: when the streak first becomes 1, after the first-Daily badge
  moment closes, 400ms after the done screen settles.
- Moment 2: the first time a lesson is fully cleared, after the road unlock
  moment (`road.moment.total`, 2.4s) plus 400ms.
- Dismissed means `Not now`, a swipe down, or a tap on the scrim. Each counts
  as one used invitation.
- Store `remindersAskCount` and `remindersAskLastDay` on the phone.

## States

1. **Ask** (A1, A3). Our own soft ask; no system dialog yet.
2. **Remind me tapped.** Only now the system permission dialog appears (iOS
   allows it once). On grant, the same calls as the Profile row:
   `setEnabled(true)`, then `rearm(examDay)`.
3. **On** (A2). Confirmed in place, then the sheet closes.
4. **Denied.** One line pointing to Settings, nothing more.
5. **Not now.** The sheet drops; no toast.

What reminders exist is unchanged (`notification_plan.dart`): the morning
"Daily is ready", the evening one only while today's Daily is open (naming the
streak), and the exam ones when a date is set. The sheet promises none of
their hours.

## Night

All tokens are `ThemedColor`: the sheet `sheet` (#2E2B27), the streak block
`butter` (deep amber), text `charcoal` (light), the pill `charcoal` fill with
`cream` label and the spring circle with an `onAccent` arrow (A1n). The butter
block is quiet against the night sheet; the figure carries it.

## Self-check (DESIGN.md)

1. One dominant element: the sheet title, with the streak figure above it in
   Moment 1.
2. One thumb, no keyboard.
3. The action in the bottom third, pill at the right, `Not now` at the left.
4. No borders, hairlines, pills behind labels, icons on tiles, or charcoal
   ground.
5. Every colour and font from `tokens.json` / `app_colors.dart`.
6. Closest reference: `02c-check-email` (the cream sheet over the dimmed
   screen). Behind it, `13c-game-done` (Moment 1) and `11-chapter-map`
   (Moment 2); tablet `T21b-daily-done-landscape` under a 640 sheet.
