# The forum, small first version: spec

Status: draft for the owner, 2026-11-04. Nothing is built. Mockups are in
`docs/forum/mockups/png/` (the HTML beside them is the source).

## Why

A student (Xueyi, 2026-11-03) went looking for "the community" as a place and
found only the league board. The owner wants FE for Raccoons to grow into the
place civil engineers go: a forum, FE Civil prep, PE prep, and later a jobs
board that only lists positions with a salary.

The first use is the owner's own: a public place to ask students what
resources they wish the site had and whether a feature idea is worth
building. Students can also ask each other about the FE, internships, jobs
and the field.

Nothing else combines these today. Discussion lives on Reddit (r/FE_Exam,
r/PE_Exam), Eng-Tips, Engineer Boards and ASCE Collaborate (members only).
Prep is sold separately (PPI2Pass, School of PE and others) with no community
attached. (Desk search, 2026-11-04.)

## What the small version proves

Whether students post. About 30 students use the site on an average day and
over 100 each week (owner's figures). A common rule of thumb says a few
percent of readers ever post (estimate, not measured), so the owner's own
questions carry the first weeks.

**Check after four weeks:** questions and replies per week from students
other than the owner, and visits to forum pages from search. If students
reply every week, build the next version (topics, votes, best answer, app).
If not, keep it as the owner's feedback board and stop there.

## In scope

1. **A tab row in the existing header** (mockup 01). Study (the dashboard),
   Forum, PE prep (the live waitlist page at `/pe-exam-prep`). "New" sits by
   Forum for its first two weeks. On a phone the tabs drop to their own row
   under the logo, three equal parts. Exam Sim and Profile stay where they
   are. Visitors who are not signed in see the same tabs with "Sign in" on
   the right; Study takes them to the landing page.
2. **A forum card on the dashboard** under "Right now" (mockup 01): the
   newest question, two more, and "Join the conversation".
3. **Forum front page, `/forum`** (mockup 02). Readable by anyone. The
   owner's questions are pinned on top with an ember edge. Below, all other
   questions by latest activity, with search. A side card says how it works
   and, for visitors, invites them to join free.
4. **Question page, `/forum/<slug>`** (mockups 03, 04). One question, its
   replies oldest first, related questions underneath. Signed out: a box
   inviting them to sign in or join free. Signed in: a reply box. The owner's
   posts carry a "Founder" mark. Replies are flat, no threads inside threads.
5. **Ask a question, `/forum/ask`** (mockup 05). The question is typed as a
   large heading line (120 characters at most). Matching questions appear
   under it while typing. Details are optional (5,000 characters at most).
6. **Approval of first posts.** A student's first question or reply is
   visible only to them, on a yellow band, until the owner approves it.
   Approving also trusts the student, so later posts go up right away.
7. **Report.** Every post has Report. A post reported by two different
   students hides until the owner decides.
8. **Owner review page** (mockup 06). A new section of `/admin`: Waiting,
   Reported, Hidden. Approve or Hide. One email a day to the owner when
   something waits, never one per post.
9. **Reply email** (mockup 07). The asker gets an email when someone
   replies, at most one per question per day, in the existing branded email
   style. A switch in Profile turns forum emails off.
10. **Google can read every question.** See "Search" below.

## Out of scope for now

Topics or categories, votes, best answer, editing after five minutes, images
and attachments, mentions, private messages, the phone app, the Jobs tab, and
any PE prep content beyond the existing waitlist.

## Who can do what

| | Visitor | Signed in, email not verified | Verified, first post pending | Trusted |
|---|---|---|---|---|
| Read everything public | Yes | Yes | Yes | Yes |
| Ask or reply | No, asked to sign in | No, asked to verify (existing banner) | Posts wait for approval | Posts go up at once |
| Report | No | Yes | Yes | Yes |

The owner account (`admin@oqupa.com`, the existing admin gate) can pin,
hide, approve and delete anything.

**Names.** Posts show the student's first name (the profile `firstName`
field, already used by the live feed and leagues) and initials. Never any
part of the email. A student with no first name is asked for one the first
time they post. A student can edit or delete their own post within five
minutes; after that, only delete.

**Rate limits.** At most 5 questions and 30 replies per student per day.
Links in a first post send it to the queue even after trust is granted
(spam usually starts with a link).

## Search (the biggest piece of work)

Today only a fixed list of public pages is built ahead of time for crawlers
(`ROUTES` in `scripts/prerender.mjs` and `PRERENDERED_ROUTE_PATTERN` in
`service/prerenderedRoutes.js`). Forum questions appear every day, so the
server must build each question page when it is requested:

- `GET /forum` and `GET /forum/<slug>` return `index.html` with the title,
  description, canonical URL, the question and replies as real HTML in the
  page, and `QAPage` structured data. The React app then takes over as usual.
- Pending, hidden and deleted posts are never in that HTML. A hidden
  question returns 404 to crawlers.
- New questions are added to `sitemap.xml` and sent to IndexNow when
  approved.
- Title: the question, then "| FE for Raccoons Forum", cut to 70
  characters (the rule `npm run build:seo` enforces). Description: the first
  155 characters of the details, or a fixed line when there are none.
- `/forum/ask` and the admin section are `noindex`.

## Data

Two new collections, plus one field on users.

`forumQuestions`
- `_id`, `slug` (unique, from the title plus a short id), `title`, `body`
- `authorEmail`, `authorName` (copied at post time)
- `status`: `pending` | `live` | `hidden`
- `pinned` (owner questions), `replyCount`, `lastActivityAt`, `createdAt`
- `reports`: list of reporter emails (two different ones hide the post)

`forumReplies`
- `_id`, `questionId`, `body`, `authorEmail`, `authorName`, `status`,
  `createdAt`, `reports`

`users.forumTrusted: true` after the first approval, and
`users.forumEmails: false` when a student turns forum emails off.

Indexes: `forumQuestions` on `slug` (unique), `{status, pinned, lastActivityAt}`,
and a text index on `title` + `body` for search and "already asked";
`forumReplies` on `{questionId, createdAt}`.

**Account deletion and email change** must cover both collections
(`service/db/accountDeletion.js`, `service/db/accountEmail.js`). Deleting an
account removes the student's posts; replies to a deleted question go with
it.

## Server routes (sketch)

- `GET /api/forum/questions?q=&cursor=`, `GET /api/forum/questions/:slug`
- `GET /api/forum/similar?title=` (for "Already asked?")
- `POST /api/forum/questions`, `POST /api/forum/questions/:id/replies`
  (verified email required)
- `POST /api/forum/report` `{kind, id}`
- `PATCH`/`DELETE` own post within five minutes
- Admin: `GET /api/admin/forum/queue`, `POST /api/admin/forum/:kind/:id`
  `{action: approve|hide|pin|unpin|delete}`
- `GET /api/forum/latest` for the dashboard card

All post text is stored and shown as plain text with line breaks. No HTML or
Markdown in the first version, which removes a whole class of injection
problems.

## Emails

- To the asker on a reply: at most one per question per day.
- To the owner: one daily summary when anything waits or was reported,
  sent with the existing 8am ET lifecycle scheduler.
- The launch: one line in the Sunday weekly digest pointing to the forum
  and the owner's first question.

## Owner's part before launch

Write three or four questions for the pinned section, for example "What is one
resource you wish FE for Raccoons had?" and a feature question. Answer new
questions within a day for the first month.

## Effort (estimate)

About two weeks of build and test: server and data (3 days), server-built
pages for crawlers (3 days), the four pages and the dashboard card (3 days),
admin review and emails (2 days), tests and phone-width review (2 days).

## Decisions for the owner

1. The name in the tab: "Forum" (recommended, plain) or "Community".
2. Students can ask their own questions from day one (recommended, as
   specced), or only reply to the owner's questions at first.
3. "Founder" as the mark on the owner's posts.
