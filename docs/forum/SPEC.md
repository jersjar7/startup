# The forum, small first version: spec

Status: approved by the owner 2026-11-06 (decisions at the end); first drafted 2026-11-04. Nothing is built. Mockups are in
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
   posts carry a "Founder" mark. Replies stay one list, oldest first, with no
   threads inside threads. Every reply has a Reply button that quotes the
   reply it answers (a short excerpt with the author's first name, linking
   back to it), so a student can answer one comment without the page
   splitting into hidden branches.
5. **Ask a question, `/forum/ask`** (mockup 05). The question is typed as a
   large heading line (120 characters at most). Matching questions appear
   under it while typing. Details are optional (5,000 characters at most).
6. **Automatic moderation** (see "Keeping it safe without reviewing every
   post" below). Most posts go up at once. Only posts the checks are unsure
   about wait for the owner, visible to their author on a yellow band.
7. **Report.** Every post has Report. A post reported by two different
   students hides until the owner decides.
8. **Owner review page** (mockup 06). A new section of `/admin`: Waiting,
   Reported, Hidden, each post showing why it was held. Approve or Hide. One
   email a day to the owner when something waits, never one per post.
9. **Reply email** (mockup 07). The asker gets an email when someone
   replies, at most one per question per day, in the existing branded email
   style. A switch in Profile turns forum emails off.
10. **Google can read every question.** See "Search" below.

## Out of scope for now

Topics or categories, votes, best answer, editing after five minutes, images
and attachments, mentions, private messages, the phone app, the Jobs tab, and
any PE prep content beyond the existing waitlist.

## Who can do what

| | Visitor | Signed in, email not verified | Verified, not yet trusted | Trusted (3 posts up, none hidden) |
|---|---|---|---|---|
| Read everything public | Yes | Yes | Yes | Yes |
| Ask or reply | No, asked to sign in | No, asked to verify (existing banner) | After 20 answered problems; posts go through the checks | Same checks |
| Links clickable | n/a | n/a | No, shown as plain text | Yes, after 3 posts that went up |
| Report | No | Yes | Yes | Yes |

Students can ask their own
questions from day one, not only reply to the owner's.

The owner account (`admin@oqupa.com`, the existing admin gate) can pin,
hide, approve and delete anything.

**Names.** Posts show the student's first name (the profile `firstName`
field, already used by the live feed and leagues) and initials. Never any
part of the email. A student with no first name is asked for one the first
time they post. A student can edit or delete their own post within five
minutes; after that, only delete.

**Rate limits.** At most 5 questions and 30 replies per student per day.

**Links.** Allowed. Until a student is trusted their links show as plain
text, not clickable. Trusted students' links are clickable and carry
`rel="ugc nofollow"`, so posting a link never helps another site rank, which
removes the main reason spammers post. Link shorteners (bit.ly and similar)
are refused outright because they hide where a link goes. No images or
attachments in this version.

**Names.** Nobody but the owner account can show the Founder mark, and a
first name of "Jerson", "Founder", "Admin" or "FE for Raccoons" is refused
for everyone else.

## Keeping it safe without reviewing every post

The owner does not review every post. Each new question or reply passes three
gates in order; only posts the gates are unsure about reach him.

1. **Who can post.** A verified email and at least 20 answered problems on
   the site. Bots and drive-by spammers do not study first, and a real
   student reaches 20 in one sitting.
2. **Rule check, instant, no cost.** Holds the post if it contains a phone
   number, an email address, payment or messaging-app words ("WhatsApp",
   "Telegram", "Venmo", "Cash App", "crypto", "DM me"), a link shortener, or
   exam-leak phrases ("questions I got", "on my exam I had", "exact
   question"). The list lives in one file the owner can extend.
3. **AI read.** A small Claude model (Haiku) reads each post that passed the
   rules and answers one of: fine, unsure, harmful, with a one-line reason.
   Fine goes up at once. Harmful is hidden and listed under Hidden. Unsure
   waits for the owner. If the AI call fails, the post waits rather than
   going up unchecked. Cost estimate, not measured: well under a dollar a
   month at expected volume.

After a post is up, two reports from different students hide it at once. A
student with two posts hidden loses posting until the owner restores it.

Estimate, not measured: a few held posts a week reach the owner, in the one
daily email.

## Risks we designed against

- **Leaked exam content.** NCEES forbids sharing real exam questions, and a
  forum full of "what I got on my FE" could put the site at risk. The rule
  check and the AI read both look for it, and the forum rules say so plainly.
- **Spam and SEO link farming.** The 20-problem gate, plain-text links
  until trusted, `nofollow` after, and no shorteners.
- **Scams.** Fake tutors, "guaranteed pass" sellers, fake job offers, and
  anyone steering students off the site to private chat or payment apps.
- **Personal details.** Phone numbers and emails are held, protecting
  students who post their own without thinking.
- **Harassment and impersonation.** The AI read, two-report hiding, and the
  reserved names above.
- **Copied paid material.** Pasted pages from prep books or the handbook.
  Report and the AI read catch most; a copyright contact handles the rest
  (unverified: registering a DMCA agent with the US Copyright Office costs
  about $6 and gives takedown requests a proper address).
- **Wrong engineering answers.** Not removable by rule. The Founder mark
  shows which answers are the owner's, and a short note on each question page
  says replies are from students.
- **Attacks through posts.** All text is stored and shown as plain text, so
  nothing a user types can run on the page.

The Terms page needs a short user-content section (what may be posted, that
we can remove posts) before launch.

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

`users.forumTrusted: true` after three posts go up with none hidden, `users.forumHiddenCount`, and
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

## Decisions (owner, 2026-11-06)

1. The tab is named "Forum".
2. Students can ask their own questions from day one.
3. The owner's posts carry the "Founder" mark.
4. Replies quote the reply they answer; no nested threads.
5. Links allowed, clickable only once a student is trusted.
6. Automatic moderation replaces approving every first post.
