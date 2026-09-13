# 0015. The phone's home is one chapter and one button

Date: 2026-09-13
Status: Accepted

## Context

The Study tab is the home of the mobile app. Its first version fetched the
chapter list and drew fifteen identical rows with fifteen mastery rings. Its
second version (2026-09-12) drew two numbers, one dark action card, and
fifteen chapter cards in three bands, on a page two and a half screens tall.

The owner rejected the second version on 2026-09-13 for its hierarchy: the
largest type on the screen was a label, three blocks of equal weight sat
above the first chapter, the one action came third, the chapter in flight was
marked twice, and fifteen equal tiles left nothing outranking anything. Four
rounds of alternatives were drawn on a design canvas (a contents page, a
weight-sized typeset page, a treemap "blueprint", a Gantt to the exam). Every
one was rejected as a list in disguise, as chaotic, or as not working as a
home page.

The question that settled it was not "how do we show all this" but "what
does a student open the app to do". The answer is: play the next concept.

## Decision

The home screen is the next concept and nothing else.

- **One chapter per screen.** The chapter's mark, drawn at 112 points inside
  a 3-point progress ring; its name; its lesson count and exam weight in one
  mono line; the lesson that comes next; one button. It does not scroll.
- **The other fourteen are one swipe away.** The home is a horizontal pager
  in catalog order. It opens on the chapter in flight (`resumeTarget`), and
  after that the page is the student's: progress changing underneath does not
  move the pager.
- **All fifteen are one tap away.** The row of page dots opens an overview
  laid out like a home screen of icons (mark, name, count, no boxes). Tapping
  a chapter jumps the pager to it.
- **Ember appears twice.** The mark and ring of the chapter in flight, and
  the button. Every other chapter is charcoal with a forest ring.
- **Two figures leave the home.** Concepts held on the phone and problems
  answered on the website move to Profile, as two lines under a PROGRESS
  heading. Neither helps decide what to play next. They are still never
  added (ADR 0013).
- **Days to the exam stays**, as one line at the top, because it does change
  what a student does today. Without a date the line reads "Set your exam
  date" rather than inventing a countdown.

## Consequences

- The bands (`chapter_bands.dart`) are no longer drawn on the tab. They stay
  in the code because the marks contact sheet lays the drawings out by them.
- A student who wants the whole exam at a glance is one tap further from it
  than before. The overview is that glance, and it is the only screen where
  all fifteen chapters appear together.
- The chapter marks, designed on a 512 square precisely so they could be
  used large, finally are.
- Goldens: `test/goldens/home/{day-one,week-five,overview}.png`.
