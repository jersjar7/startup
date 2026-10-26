# 0029. The challenge calendar is a yearly cycle of the twelve heaviest chapters

Date: 2026-10-26
Status: Accepted 2026-10-26 (owner: "Yes to 12"). Refines decision 2 of
[0027](0027-monthly-chapter-challenges.md) ("then chapters by exam weight").
The rest of 0027 stands.

## Context

0027 started the challenges with Statics in December 2026, then went "by
exam weight". The calendar file held six dated months, and nothing said what
happened after May 2027. The owner pointed out on 2026-10-26 that there are
15 chapters and 12 months. His proposal: pick the 12 chapters the exam asks
most about, one per month, every year.

## Decision

1. **Twelve chapters, one per calendar month, the same month every year,**
   starting December 2026. `service/challenges.json` holds `since` and a
   12-entry `cycle` keyed by month (`MM`). No year has to be planned again.
2. **The twelve are the heaviest by the weights mastery already uses**
   (`service/examWeights.js`, from the NCEES July 2020 specification):
   - Water Resources, Structural and Geotechnical: 11 each.
   - Transportation: 10.
   - Statics and Construction: 9 each.
   - Mechanics of Materials: 8.
   - Mathematics: 7.
   - Economics, Materials, Fluid Mechanics and Surveying: 6 each.

   The cut is clean: the twelfth weighs 6 and the thirteenth 4. A test
   checks the calendar against the weights, so a change to the weights that
   moves the cut fails loudly.
3. **Left out:** Ethics and Dynamics (4 each) and Statistics (2), 10 of the
   110 questions between them. Students still study them every day. They
   just never get a month.
4. **The order:**
   - December: Statics, because its event art already exists.
   - January to May, as already published: Geotechnical, Structural,
     Water Resources, Transportation, Construction.
   - June: Mechanics of Materials. July: Mathematics.
   - August to November: Economics, Materials, Fluid Mechanics, Surveying.
5. **A coin is per year.** Finishing Statics in December 2026 and again in
   December 2027 gives two coins.
6. `GET /api/challenge/current` now always returns `next`, so the phone can
   plan the first-of-the-month notification before the month starts.

## Consequences

- **If NCEES changes the specification,** the weights move, the calendar
  test fails, and the twelve are picked again from the new weights.
- **App Store event names:** they must stay at 30 characters or fewer. Four
  months need a shorter name: March, June, August and October. Each carries
  a `storeName`.
