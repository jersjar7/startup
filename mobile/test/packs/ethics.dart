import 'package:mobile/features/games/can_you_claim_that_game.dart';
import 'package:mobile/features/games/can_you_seal_it_game.dart';
import 'package:mobile/features/games/contract_figures.dart';
import 'package:mobile/features/games/does_it_hold_game.dart';
import 'package:mobile/features/games/enough_or_too_far_game.dart';
import 'package:mobile/features/games/grounds_or_not_game.dart';
import 'package:mobile/features/games/how_many_protections_game.dart';
import 'package:mobile/features/games/is_that_negligence_game.dart';
import 'package:mobile/features/games/is_there_a_deal_game.dart';
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/lifecycle_figures.dart';
import 'package:mobile/features/games/over_the_whole_life_game.dart';
import 'package:mobile/features/games/practice_or_title_game.dart';
import 'package:mobile/features/games/what_is_missing_yet_game.dart';
import 'package:mobile/features/games/what_it_triggers_game.dart';
import 'package:mobile/features/games/which_clock_ran_out_game.dart';
import 'package:mobile/features/games/which_delivery_game.dart';
import 'package:mobile/features/games/which_element_missing_game.dart';
import 'package:mobile/features/games/which_protection_game.dart';
import 'package:mobile/features/games/which_section_game.dart';
import 'package:mobile/features/games/who_has_to_agree_game.dart';
import 'package:mobile/features/games/who_may_do_that_game.dart';
import 'package:mobile/features/games/who_pays_the_overrun_game.dart';

import 'package:flutter/material.dart' hide Path, TextPainter;
import 'package:mobile/core/theme/app_colors.dart';

import 'builder.dart';
import 'nodes.dart';
import 'pick_one_adapter.dart';
import 'statistics.dart'
    show doneOverline, feedback, overline, stacked, subject, withRounds;

/// The Ethics games. Most are a scene and a short list of rows to choose
/// from, each row a title over a small note, so the screens are written as
/// screen nodes from a few shared pieces.

/// The scene a round is about, in the games' body text.
Map<String, Object?> ethicsScene(
  String words, {
  num size = 15.5,
  num line = 1.5,
}) => {'text': words, 'size': size, if (line != 1.5) 'line': line};

/// The round's subject, for where a parameter named subject hides it.
Map<String, Object?> subjectLine(String words) => subject(words);

/// The games' answer row: a title with a small note under it.
Node noted(
  int i,
  String title,
  String note, {
  num size = 15,
  List<num> pad = const [14, 11, 14, 11],
}) => tinted(
  i,
  col([
    t(title, size: size),
    gapH(2),
    t(note, font: 'mono', size: 10.5, color: 'ink3'),
  ], cross: 'start'),
  pad: pad,
);

/// Once answered: where the answer comes from (a heading over a line of
/// code, or a heading alone), then the feedback.
List<Map<String, Object?>> ruled(String heading, [String? rule]) => [
  gap(16, when: 'done'),
  doneOverline(heading),
  if (rule != null) ...[
    gap(4, when: 'done'),
    {'code': rule, 'size': 13, 'when': 'done'},
  ],
  ...feedback(14),
];

/// A round with only a scene, a subject and rows of noted answers.
ScreenRound notedRound({
  required String heading,
  required String scene,
  num sceneSize = 15.5,
  required String subject,
  num before = 16,
  num space = 8,
  required List<(String, String)> rows,
  num size = 15,
  List<num> pad = const [14, 11, 14, 11],
  required int answer,
  required String why,
  required String source,
  required List<Map<String, Object?>> after,
}) => (
  options: [for (final r in rows) r.$1],
  notes: null,
  tex: null,
  answer: answer,
  why: why,
  source: source,
  screen: [
    overline(heading),
    gap(8),
    ethicsScene(scene, size: sceneSize),
    gap(6),
    subjectLine(subject),
    gap(before),
    ...stacked([
      for (final (i, r) in rows.indexed)
        noted(i, r.$1, r.$2, size: size, pad: pad),
    ], space: space),
    ...after,
  ],
);

/// A tick box: filled in its state's color, with a check, once it is
/// picked or turns out to be one of the right ones.
Node tickBox() => box(
  w: 22,
  h: 22,
  radius: 6,
  fill: tone(null, 'ember', 'forest', 'error'),
  border: tone('line', 'ember', 'forest', 'error'),
  child: tone(
    null,
    icon('check', size: 15, color: 'white'),
    icon('check', size: 15, color: 'white'),
    icon('check', size: 15, color: 'white'),
  ),
);

Map<String, Object?> whatItTriggers() => pickScreen(
  id: 'what-it-triggers',
  chapter: 'ethics',
  title: 'What Does It Trigger',
  closing:
      'Work down the same list every time. Is the public at risk? Has '
      'the chain been walked? Is there a relationship in the room? And '
      'sometimes the honest answer is that a disagreement is only a '
      'disagreement.',
  right: 'THAT IS THE ONE',
  wrong: 'A DIFFERENT RULE',
  brief: briefJson(publicFirstBrief, 'publicFirstBrief'),
  rounds: [
    for (final r in triggerRounds)
      notedRound(
        heading: 'WHICH OBLIGATION IS THIS',
        scene: r.scenario,
        subject: r.subject,
        before: 14,
        space: 7,
        rows: duties,
        size: 14.5,
        pad: const [14, 10, 14, 10],
        answer: r.answer,
        why: r.why,
        source: r.source,
        after: ruled('THE RULE', r.rule),
      ),
  ],
);

Map<String, Object?> enoughOrTooFar() {
  const labels = [
    'Not enough',
    'What the rules ask',
    'More than this asks for',
  ];
  return pickScreen(
    id: 'enough-or-too-far',
    chapter: 'ethics',
    title: 'Enough, or Too Far',
    closing:
        'The rules ask for a particular amount of action. Meaning well is '
        'not enough, and doing more than was asked is its own answer to a '
        'question nobody put. Read what the rule actually requires, and do '
        'that.',
    right: 'THE RIGHT SIZE',
    wrong: 'NOT THAT SIZE',
    brief: briefJson(proportionBrief, 'proportionBrief'),
    rounds: [
      for (final r in proportionRounds)
        (
          options: labels,
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: [
            overline('IS THAT THE RIGHT SIZE'),
            gap(8),
            t(r.scenario, size: 14.5, line: 1.5, color: 'ink2'),
            gap(6),
            subject(r.subject),
            gap(14),
            box(
              w: 'max',
              pad: [14, 14, 14, 14],
              fill: 'creamDark',
              radius: 14,
              cross: 'start',
              c: [
                t('THE PROPOSED RESPONSE', font: 'overline', color: 'ink3'),
                gapH(8),
                t(r.response, size: 16, line: 1.45),
              ],
            ),
            gap(16),
            answerRow([
              for (final (i, l) in labels.indexed)
                tinted(
                  i,
                  t(l, size: 12.5, line: 1.25, align: 'center'),
                  h: 64,
                  pad: [6, 0, 6, 0],
                  align: 'center',
                ),
            ]),
            ...feedback(),
          ],
        ),
    ],
  );
}

Map<String, Object?> canYouSealIt() => pickScreen(
  id: 'can-you-seal-it',
  chapter: 'ethics',
  title: 'Can You Seal It',
  closing:
      'Two halves, both required: it has to be your technical field, and '
      'it has to have been prepared under your responsible charge. '
      'Coordinating a whole project is fine, and it leaves every other '
      'discipline sealed by the person who did it.',
  right: 'THAT IS RIGHT',
  wrong: 'NOT QUITE',
  brief: briefJson(competenceBrief, 'competenceBrief'),
  rounds: [
    for (final r in sealRounds)
      notedRound(
        heading: 'DOES YOUR SEAL GO ON IT',
        scene: r.situation,
        subject: r.subject,
        rows: const [
          ('Yes, seal it', 'your field, and prepared under your direction'),
          (
            'No, not yours to seal',
            'either the field or the charge is missing',
          ),
          (
            'Seal your part of it only',
            'the rest carries the seal of whoever did it',
          ),
        ],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        after: ruled('THE RULE', r.rule),
      ),
  ],
);

Map<String, Object?> whoHasToAgree() => pickSeveral(
  id: 'who-has-to-agree',
  chapter: 'ethics',
  title: 'Who Has to Agree',
  closing:
      'Full disclosure and written agreement from everyone with an '
      'interest, which is usually more than one name. And some things '
      'consent cannot repair: a gratuity from a bidder, and work taken '
      'from a body you sit on.',
  right: 'THAT IS EVERYONE',
  wrong: 'NOT THAT SET',
  brief: briefJson(consentBrief, 'consentBrief'),
  rounds: [
    for (final r in consentRounds)
      (
        options: r.parties,
        answer: [...r.answer]..sort(),
        alone: [r.parties.length - 1],
        why: r.why,
        source: r.source,
        screen: [
          overline('WHOSE WRITTEN AGREEMENT'),
          gap(8),
          ethicsScene(r.arrangement),
          gap(6),
          {
            'mono': 'tap everyone who has to agree, which may be nobody',
            'size': 11,
            'color': 'ink3',
          },
          gap(14),
          ...stacked([
            for (final (i, p) in r.parties.indexed)
              tinted(
                i,
                row([tickBox(), gapW(10), flex(t(p, size: 14.5, line: 1.35))]),
                pad: [12, 13, 12, 13],
              ),
          ]),
          ...ruled('THE RULE', r.rule),
        ],
      ),
  ],
);

Map<String, Object?> canYouClaimThat() => pickScreen(
  id: 'can-you-claim-that',
  chapter: 'ethics',
  title: 'Can You Claim That',
  closing:
      'Say what you did, and say who did the rest. The rule is not '
      'aimed at outright lies, it is aimed at sentences that are true if '
      'you read them slowly and flattering if you do not.',
  right: 'YOU MAY SAY THAT',
  wrong: 'NOT THAT ONE',
  brief: briefJson(claimsBrief, 'claimsBrief'),
  rounds: [
    for (final r in claimRounds)
      (
        options: r.claims,
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          overline('WHICH LINE MAY YOU WRITE'),
          gap(10),
          box(
            w: 'max',
            pad: [14, 12, 14, 12],
            fill: 'creamDark',
            radius: 14,
            cross: 'start',
            c: [
              t('WHAT ACTUALLY HAPPENED', font: 'overline', color: 'ink3'),
              gapH(8),
              t(r.facts, size: 14.5, line: 1.5),
            ],
          ),
          gap(6),
          subject(r.subject),
          gap(14),
          ...stacked([
            for (final (i, c) in r.claims.indexed)
              tinted(i, t(c, size: 14.5, line: 1.4), pad: [14, 12, 14, 12]),
          ]),
          ...ruled('THE RULE', r.rule),
        ],
      ),
  ],
);

Map<String, Object?> whoMayDoThat() {
  const tiers = [
    ('Anyone', 'no licence needed for this'),
    ('An Engineer Intern', 'certified by the board, not licensed'),
    ('Only a licensed PE', 'licensed by the board'),
  ];
  // The three tiers are a ladder, each a rung taller than the last.
  Node rung(int i) => box(
    w: 26,
    h: 34,
    child: col(
      [
        box(
          w: 6,
          h: 10.0 + i * 12,
          radius: 3,
          fill: tone('ink3/0.55', 'ember', 'forest', 'error'),
        ),
      ],
      main: 'end',
      cross: 'start',
    ),
  );
  return pickScreen(
    id: 'who-may-do-that',
    chapter: 'ethics',
    title: 'Who May Do That',
    closing:
        'Certified and licensed are different words. An Engineer Intern '
        'has passed the FE and may hold the title; a Professional Engineer '
        'is licensed and may seal. And a great deal of real engineering '
        'work needs no licence at all, as long as somebody licensed is in '
        'responsible charge of it.',
    right: 'THAT IS THE TIER',
    wrong: 'A DIFFERENT TIER',
    brief: briefJson(standingBrief, 'standingBrief'),
    rounds: [
      for (final r in standingRounds)
        (
          options: [for (final s in tiers) s.$1],
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: [
            overline('THE LOWEST STANDING THAT IS ENOUGH'),
            gap(10),
            box(
              w: 'max',
              pad: [14, 14, 14, 14],
              fill: 'creamDark',
              radius: 14,
              child: t(r.action, size: 16, line: 1.45),
            ),
            gap(6),
            subject(r.subject),
            gap(16),
            ...stacked([
              for (final (i, s) in tiers.indexed)
                tinted(
                  i,
                  row([
                    rung(i),
                    flex(
                      col([
                        t(s.$1, size: 15),
                        gapH(2),
                        t(s.$2, font: 'mono', size: 10.5, color: 'ink3'),
                      ], cross: 'start'),
                    ),
                  ]),
                  pad: [14, 11, 14, 11],
                ),
            ]),
            ...ruled('THE RULE', r.rule),
          ],
        ),
    ],
  );
}

Map<String, Object?> doesItHold() => pickScreen(
  id: 'does-it-hold',
  chapter: 'ethics',
  title: 'Does the Exemption Hold',
  closing:
      'Two conditions, both required. Somebody licensed has to be in '
      'responsible charge, and the final design decisions have to be '
      'theirs. Break either one and the work needs a licence, however '
      'ordinary it looked.',
  right: 'THAT IS IT',
  wrong: 'THE OTHER CONDITION',
  brief: briefJson(exemptionBrief, 'exemptionBrief'),
  rounds: [
    for (final r in exemptionRounds)
      notedRound(
        heading: 'UNLICENSED WORK, TWO CONDITIONS',
        scene: r.scene,
        subject: r.subject,
        rows: const [
          ('The exemption holds', 'both conditions are met'),
          (
            'Nobody licensed is in charge of it',
            'there is nothing to hang it from',
          ),
          (
            'They are making the final call',
            'the decision was theirs, not the PE\'s',
          ),
        ],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        after: ruled('MODEL LAW 170.20 C'),
      ),
  ],
);

Map<String, Object?> practiceOrTitle() => pickScreen(
  id: 'practice-or-title',
  chapter: 'ethics',
  title: 'Practice, or the Title',
  closing:
      'Two separate offenses that usually arrive together. Doing the '
      'work without a licence is one, and claiming the title without a '
      'licence is the other, and either is enough on its own. The medium '
      'the work is delivered on has never been part of the test.',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: briefJson(holdingOutBrief, 'holdingOutBrief'),
  rounds: [
    for (final r in verdictCases)
      notedRound(
        heading: 'WHAT IS BEING BROKEN, IF ANYTHING',
        scene: r.scene,
        sceneSize: 15,
        subject: r.subject,
        rows: const [
          (
            'Practising without a licence',
            'engineering judgment reaching the public',
          ),
          (
            'The title, not the work',
            'held out as a PE, whatever the work was',
          ),
          ('Neither', 'no engineering, and no claim to be one'),
        ],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        after: ruled('THE RULE', r.rule),
      ),
  ],
);

Map<String, Object?> whatIsMissingYet() {
  const ready = 'Nothing. This record is complete.';
  return pickScreen(
    id: 'what-is-missing-yet',
    chapter: 'ethics',
    title: 'What Is Missing Yet',
    closing:
        'Four years after a bachelor\'s, three after a master\'s, two '
        'after a doctorate with the FE behind it. The degree that bought '
        'the education requirement cannot be spent again on the '
        'experience, and five references are a requirement rather than a '
        'courtesy.',
    right: 'THAT IS THE GAP',
    wrong: 'LOOK AGAIN',
    brief: briefJson(ladderBrief, 'ladderBrief'),
    rounds: [
      for (final r in recordRounds)
        (
          options: [...requirements, ready],
          notes: null,
          tex: null,
          answer: r.answer,
          why: r.why,
          source: r.source,
          screen: [
            overline('THE FIRST THING THIS RECORD LACKS'),
            gap(8),
            subject(r.subject),
            gap(10),
            box(
              w: 'max',
              pad: [12, 6, 12, 6],
              fill: 'white',
              radius: 14,
              border: 'line',
              c: [
                for (final (i, (label, value)) in [
                  ('DEGREE', r.degree),
                  ('FE EXAM', r.fe),
                  ('EXPERIENCE', r.experience),
                  ('PE EXAM', r.pe),
                  ('REFERENCES', r.references),
                ].indexed) ...[
                  if (i > 0) rule(color: 'line'),
                  box(
                    pad: [0, 9, 0, 9],
                    child: row([
                      box(
                        w: 84,
                        child: t(label, font: 'overline', color: 'ink3'),
                      ),
                      flex(t(value, size: 13.5, line: 1.35)),
                    ], cross: 'start'),
                  ),
                ],
              ],
            ),
            gap(14),
            ...stacked([
              for (final (i, label) in [...requirements, ready].indexed)
                tinted(i, t(label, size: 14.5), pad: [14, 12, 14, 12]),
            ], space: 7),
            ...feedback(),
          ],
        ),
    ],
  );
}

Map<String, Object?> groundsOrNot() {
  // Each event is a question of its own, answered yes or no: answer 2e is
  // its yes and 2e + 1 its no.
  Node pip(int i, String label) => answer(
    i,
    box(
      w: 42,
      h: 34,
      align: 'center',
      radius: 8,
      border: tone('line', 'ember', 'forest', 'line'),
      child: t(
        label,
        font: 'mono',
        size: 12,
        color: tone('ink3', 'white', 'white', 'ink3'),
      ),
    ),
    radius: 8,
    fill: tone('white', 'ember', 'forest', 'white'),
  );
  Node event(int e, Event ev) {
    final yes = 2 * e, no = yes + 1;
    // Once answered, a row is wrong when the answer that is not true was
    // the one picked.
    final untrue = ev.grounds ? no : yes;
    Object before(Object idle, Object picked) => tone(
      tone(idle, picked, null, null, of: no),
      picked,
      null,
      null,
      of: yes,
    );
    return box(
      w: 'max',
      pad: [12, 10, 10, 10],
      radius: 12,
      fill: askDone(
        'white',
        tone('forestBg', null, null, 'errorBg', of: untrue),
      ),
      border: askDone(
        before('line', 'ember'),
        tone('forest', null, null, 'error', of: untrue),
      ),
      stroke: askDone(before(1, 2), 2),
      child: row([
        flex(t(ev.text, size: 13.5, line: 1.35)),
        gapW(8),
        pip(yes, 'Yes'),
        gapW(6),
        pip(no, 'No'),
      ]),
    );
  }

  return withRounds(
    pickSeveral(
      id: 'grounds-or-not',
      chapter: 'ethics',
      title: 'Grounds, or Not',
      closing:
          'Any felony, whatever it was about. A misdemeanour only when it '
          'involves dishonesty or the practice. And for somebody who is not '
          'licensed at all, the grounds are practising, claiming the title, '
          'and using a seal that is not theirs.',
      right: 'ALL FOUR',
      wrong: 'NOT ALL FOUR',
      brief: briefJson(disciplineBrief, 'disciplineBrief'),
      rounds: [
        for (final r in groundsRounds)
          (
            options: [
              for (final _ in r.events) ...['Yes', 'No'],
            ],
            answer: [
              for (final (e, ev) in r.events.indexed)
                2 * e + (ev.grounds ? 0 : 1),
            ],
            alone: const [],
            why: r.why,
            source: r.source,
            screen: [
              overline('GROUNDS FOR THE BOARD TO ACT'),
              gap(8),
              ethicsScene(r.who, size: 16, line: 1.4),
              gap(4),
              {
                'mono': 'answer each one on its own',
                'size': 11,
                'color': 'ink3',
              },
              gap(14),
              ...stacked([
                for (final (e, ev) in r.events.indexed) event(e, ev),
              ]),
              ...feedback(),
            ],
          ),
      ],
    ),
    (i) => {
      'groups': [
        for (var e = 0; e < groundsRounds[i].events.length; e++)
          [2 * e, 2 * e + 1],
      ],
      'need': groundsRounds[i].events.length,
    },
  );
}

Map<String, Object?> whichSection() => pickScreen(
  id: 'which-section',
  chapter: 'ethics',
  title: 'Which Section',
  closing:
      'Ask whether they hold a licence before anything else. Revoked, '
      'suspended and expired all mean the same thing for this question, '
      'which is that they do not, and that puts them on the other list '
      'entirely.',
  right: 'THAT IS THE LIST',
  wrong: 'THE OTHER LIST',
  brief: briefJson(sectionsBrief, 'sectionsBrief'),
  rounds: [
    for (final r in sectionRounds)
      notedRound(
        heading: 'WHICH LIST REACHES THEM',
        scene: r.scene,
        subject: r.subject,
        rows: const [
          ('The licensee list', 'suspend, revoke, fine or reprimand'),
          ('The unlicensed list', 'fined, and each day counts again'),
          ('Neither. Not a ground at all.', 'the board has nothing to reach'),
        ],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        after: feedback(),
      ),
  ],
);

Map<String, Object?> isThereADeal() {
  const never = 'It never became a contract at all.';
  return pickScreen(
    id: 'is-there-a-deal',
    chapter: 'ethics',
    title: 'Is There a Deal Yet',
    closing:
        'An offer, taken as it stands, with something of value moving both '
        'ways. A counter-offer kills the offer before it. An invitation is '
        'not an offer. And no amount of agreement makes a contract out of '
        'a favor or out of something unlawful.',
    right: 'THAT IS THE MOMENT',
    wrong: 'NOT THERE',
    brief: briefJson(formationBrief, 'formationBrief'),
    rounds: [
      for (final r in dealRounds)
        (
          options: [for (final l in r.lines) l.text, never],
          notes: null,
          tex: null,
          answer: r.answer == noDeal ? r.lines.length : r.answer,
          why: r.why,
          source: r.source,
          screen: [
            overline('TAP THE LINE IT BECAME BINDING ON'),
            gap(6),
            subject(r.subject),
            gap(12),
            ...stacked([
              for (final (i, l) in r.lines.indexed)
                tinted(
                  i,
                  col([
                    t(l.who.toUpperCase(), font: 'overline', color: 'ink3'),
                    gapH(3),
                    t(l.text, size: 14.5, line: 1.35),
                  ], cross: 'start'),
                  pad: [12, 10, 12, 10],
                ),
            ]),
            gap(12),
            tinted(r.lines.length, t(never, size: 14.5), pad: [14, 13, 14, 13]),
            ...ruled('WHAT DECIDED IT', r.rule),
          ],
        ),
    ],
  );
}

Map<String, Object?> whoPaysTheOverrun() {
  const labels = ['The owner', 'The contractor'];
  return pickScreen(
    id: 'who-pays-the-overrun',
    chapter: 'ethics',
    title: 'Who Pays the Overrun',
    closing:
        'Lump sum puts the risk on the contractor, cost plus and time and '
        'materials put it on the owner, and a guaranteed maximum draws a '
        'line and swaps them at it. Unit price is not an overrun at all, '
        'and changing the scope hands the risk back whatever was signed.',
    right: 'THEY DO',
    wrong: 'THE OTHER SIDE',
    brief: briefJson(riskBrief, 'riskBrief'),
    rounds: [
      for (final (i, r) in overrunRounds.indexed)
        () {
          Object bar(bool revealed) => record(
            (canvas, size) => CostBarPainter(
              priced: r.priced,
              actual: r.actual,
              pricedLabel: r.pricedLabel,
              revealed: revealed,
            ).paint(canvas, size),
            120,
            what: 'who-pays-the-overrun round $i${revealed ? ' revealed' : ''}',
          );
          final hidden = bar(false);
          final revealed = bar(true);
          final answer = r.answer.index;
          return (
            options: labels,
            notes: null,
            tex: null,
            answer: answer,
            why: r.why,
            source: r.source,
            screen: <Map<String, Object?>>[
              overline('WHO ABSORBS THE DIFFERENCE'),
              gap(8),
              box(
                w: 'max',
                pad: [12, 10, 12, 10],
                fill: 'creamDark',
                radius: 12,
                child: t(r.contract, font: 'code', size: 14),
              ),
              gap(10),
              ethicsScene(r.what, size: 15),
              gap(12),
              // The bar shows what it really cost only after a wrong answer.
              pictured(
                askDone(hidden, {
                  'pick': [
                    for (var p = 0; p < labels.length; p++)
                      p == answer ? hidden : revealed,
                  ],
                }),
                120,
              ),
              gap(14),
              answerRow([
                for (final (p, l) in labels.indexed)
                  tinted(p, t(l, size: 15), h: 56, align: 'center'),
              ]),
              ...feedback(),
            ],
          );
        }(),
    ],
  );
}

Map<String, Object?> whichDelivery() {
  const labels = ['Design, bid, build', 'Design-build', 'Manager at risk'];
  // Each shape drawn once in every color its card can take.
  Object shape(Delivery d, String state, Color color) => record(
    (canvas, size) =>
        DeliveryPainter(boxes: boxesFor(d), color: color).paint(canvas, size),
    84,
    range: (132, 133),
    what: 'which-delivery ${d.name} $state',
  );
  final shapes = [
    for (final d in Delivery.values)
      tone(
        shape(d, 'idle', AppColors.charcoal),
        shape(d, 'picked', AppColors.ember),
        shape(d, 'right', AppColors.forest),
        shape(d, 'wrong', AppColors.error),
      ),
  ];
  return pickScreen(
    id: 'which-delivery',
    chapter: 'ethics',
    title: 'Which Delivery',
    closing:
        'Count the lines out of the owner. Two, with the design finished '
        'before anybody bids, is the traditional route. One is '
        'design-build, and the owner has no agreement with the designer at '
        'all. Two, with the builder advising early and then guaranteeing a '
        'maximum, is a manager at risk.',
    right: 'THAT SHAPE',
    wrong: 'A DIFFERENT SHAPE',
    brief: briefJson(deliveryBrief, 'deliveryBrief'),
    rounds: [
      for (final r in deliveryRounds)
        (
          options: labels,
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: [
            overline('WHICH SHAPE IS THIS'),
            gap(8),
            ethicsScene(r.description),
            gap(6),
            subject(r.subject),
            gap(14),
            ...stacked([
              for (final (i, l) in labels.indexed)
                tinted(
                  i,
                  row([
                    box(w: 132, h: 84, child: draw(shapes[i])),
                    gapW(12),
                    flex(t(l, size: 15, line: 1.3)),
                  ]),
                  radius: 14,
                  pad: [12, 10, 12, 10],
                ),
            ]),
            ...feedback(),
          ],
        ),
    ],
  );
}

/// The three liability games share one row, the title over its note.
Map<String, Object?> _liability({
  required String id,
  required String title,
  required String closing,
  required String right,
  required String wrong,
  required BriefSection brief,
  required String briefName,
  required String heading,
  required List<(String, String)> rows,
  required List<
    ({String scene, String subject, int answer, String why, String source})
  >
  rounds,
  num space = 8,
  num before = 16,
}) => pickScreen(
  id: id,
  chapter: 'ethics',
  title: title,
  closing: closing,
  right: right,
  wrong: wrong,
  brief: briefJson(brief, briefName),
  rounds: [
    for (final r in rounds)
      notedRound(
        heading: heading,
        scene: r.scene,
        sceneSize: 15,
        subject: r.subject,
        before: before,
        space: space,
        rows: rows,
        answer: r.answer,
        why: r.why,
        source: r.source,
        after: feedback(),
      ),
  ],
);

Map<String, Object?> isThatNegligence() => _liability(
  id: 'is-that-negligence',
  title: 'Is That Negligence',
  closing:
      'Not perfection, and not intent. The measure is what a reasonably '
      'competent engineer would have done in the same circumstances, so '
      'a design can fail without anybody being negligent, and an '
      'engineer who meant it has done something the word does not cover.',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: standardOfCareBrief,
  briefName: 'standardOfCareBrief',
  heading: 'AGAINST WHAT A COMPETENT PEER WOULD DO',
  rows: const [
    ('Negligent', 'fell short of what a peer would do'),
    ('Not negligent', 'the standard was met, outcome aside'),
    ('Not negligence. Deliberate.', 'they knew, and did it anyway'),
  ],
  rounds: [
    for (final r in faultRounds)
      (
        scene: r.scene,
        subject: r.subject,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
      ),
  ],
);

Map<String, Object?> whichElementMissing() => _liability(
  id: 'which-element-missing',
  title: 'Which Element Is Missing',
  closing:
      'Duty, breach, causation, damages. All four or no claim, and '
      'intent is not among them. Causation is the one that goes missing '
      'quietly: a real breach and a real loss that had nothing to do '
      'with each other is still not negligence.',
  right: 'THAT IS THE GAP',
  wrong: 'LOOK AGAIN',
  brief: negligenceBrief,
  briefName: 'negligenceBrief',
  heading: 'WHAT CANNOT BE PROVED',
  rows: elements,
  space: 7,
  before: 14,
  rounds: [
    for (final r in elementRounds)
      (
        scene: r.claim,
        subject: r.subject,
        answer: r.answer,
        why: r.why,
        source: r.source,
      ),
  ],
);

Map<String, Object?> whichProtection() => _liability(
  id: 'which-protection',
  title: 'Which Protection',
  closing:
      'Disclosure decides most of them. A patent publishes the invention '
      'and buys twenty years; a trade secret publishes nothing and lasts '
      'until somebody finds out. A mark protects the name and not the '
      'goods, and a copyright protects the writing and not the idea in '
      'it.',
  right: 'THAT IS THE ONE',
  wrong: 'A DIFFERENT ONE',
  brief: propertyBrief,
  briefName: 'propertyBrief',
  heading: 'WHAT PROTECTS THIS',
  rows: protections,
  space: 7,
  before: 14,
  rounds: [
    for (final r in protectionRounds)
      (
        scene: r.asset,
        subject: r.subject,
        answer: r.answer,
        why: r.why,
        source: r.source,
      ),
  ],
);

Map<String, Object?> whichClockRanOut() {
  const rows = [
    ('In time', 'inside both windows'),
    ('Barred, the limitations clock', 'too long after it was found'),
    ('Barred, the repose clock', 'too long after the job finished'),
  ];
  return pickScreen(
    id: 'which-clock-ran-out',
    chapter: 'ethics',
    title: 'Which Clock Ran Out',
    closing:
        'Limitations runs from when the harm was found. Repose runs from '
        'substantial completion and nothing extends it, which is why it '
        'can bar a claim before the harm has appeared at all. A claim has '
        'to land inside both windows.',
    right: 'THAT IS RIGHT',
    wrong: 'THE OTHER CLOCK',
    brief: briefJson(clocksBrief, 'clocksBrief'),
    rounds: [
      for (final (i, r) in clockRounds.indexed)
        (
          options: [for (final r in rows) r.$1],
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: [
            overline('DID THE CLAIM LAND IN TIME'),
            gap(6),
            subject(r.subject),
            gap(4),
            {
              'mono':
                  'repose ${ClockRound.reposeYears} years from completion, '
                  'limitations ${ClockRound.limitationYears} from discovery',
              'size': 10.5,
              'color': 'ink3',
            },
            gap(12),
            pictured(
              record(
                (canvas, size) => TwoClocksPainter(
                  from: 2006,
                  to: 2030,
                  completion: r.completion,
                  discovery: r.discovery,
                  filed: r.filed,
                  reposeYears: ClockRound.reposeYears,
                  limitationYears: ClockRound.limitationYears,
                ).paint(canvas, size),
                190,
                what: 'which-clock-ran-out round $i',
              ),
              190,
            ),
            gap(14),
            ...stacked([
              for (final (k, row) in rows.indexed) noted(k, row.$1, row.$2),
            ]),
            ...feedback(),
          ],
        ),
    ],
  );
}

Map<String, Object?> howManyProtections() => pickSeveral(
  id: 'how-many-protections',
  chapter: 'ethics',
  title: 'How Many Protections',
  closing:
      'They do not compete. A patent covers the invention, a mark covers '
      'the name, a copyright covers the writing and a secret covers what '
      'was never filed, and one project can need all four at once. The '
      'one pairing that cannot happen is a patent and a secret on the '
      'same thing.',
  right: 'THAT IS ALL OF THEM',
  wrong: 'NOT THAT SET',
  brief: briefJson(portfolioBrief, 'portfolioBrief'),
  rounds: [
    for (final r in countRounds)
      (
        options: kinds,
        answer: [...r.answer]..sort(),
        alone: const [],
        why: r.why,
        source: r.source,
        screen: [
          overline('TAP EVERY PROTECTION THIS NEEDS'),
          gap(8),
          ethicsScene(r.project, size: 15),
          gap(6),
          subject(r.subject),
          gap(14),
          ...stacked([
            for (final (i, k) in kinds.indexed)
              tinted(
                i,
                row([tickBox(), gapW(10), t(k, size: 15)]),
                pad: [12, 13, 12, 13],
              ),
          ]),
          ...feedback(),
        ],
      ),
  ],
);

Map<String, Object?> overTheWholeLife() => pickScreen(
  id: 'over-the-whole-life',
  chapter: 'ethics',
  title: 'Over the Whole Life',
  closing:
      'A life-cycle assessment adds the whole bar: building it, running '
      'it, keeping it and taking it away. The cheapest thing to build is '
      'regularly not the cheapest thing to own, and sometimes it is, '
      'which is why the method is worth more than the slogan.',
  right: 'OVER THE WHOLE LIFE',
  wrong: 'ADD IT AGAIN',
  brief: briefJson(lifeCycleBrief, 'lifeCycleBrief'),
  rounds: [
    for (final (i, r) in lifeRounds.indexed)
      (
        options: [for (final o in r.options) o.name],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          overline('WHICH ONE OVER THE WHOLE LIFE'),
          gap(8),
          ethicsScene(r.setting, size: 15),
          gap(6),
          subject(r.subject),
          gap(12),
          pictured({
            for (final answered in [false, true])
              answered ? 'done' : 'ask': record(
                (canvas, size) => StagesPainter(
                  options: r.options,
                  revealed: answered,
                ).paint(canvas, size),
                130,
                what: 'over-the-whole-life round $i',
              ),
          }, 130),
          gap(14),
          answerRow([
            for (final (k, o) in r.options.indexed)
              tinted(
                k,
                t(o.name, size: 15, one: true),
                h: 56,
                pad: [4, 0, 4, 0],
                align: 'center',
              ),
          ]),
          ...feedback(),
        ],
      ),
  ],
);

final adapters = <String, Map<String, Object?> Function()>{
  'what-it-triggers': whatItTriggers,
  'enough-or-too-far': enoughOrTooFar,
  'can-you-seal-it': canYouSealIt,
  'who-has-to-agree': whoHasToAgree,
  'can-you-claim-that': canYouClaimThat,
  'who-may-do-that': whoMayDoThat,
  'does-it-hold': doesItHold,
  'practice-or-title': practiceOrTitle,
  'what-is-missing-yet': whatIsMissingYet,
  'grounds-or-not': groundsOrNot,
  'which-section': whichSection,
  'is-there-a-deal': isThereADeal,
  'who-pays-the-overrun': whoPaysTheOverrun,
  'which-delivery': whichDelivery,
  'is-that-negligence': isThatNegligence,
  'which-element-missing': whichElementMissing,
  'which-clock-ran-out': whichClockRanOut,
  'which-protection': whichProtection,
  'how-many-protections': howManyProtections,
  'over-the-whole-life': overTheWholeLife,
};
