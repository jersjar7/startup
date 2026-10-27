import 'package:mobile/features/games/collision_figures.dart';
import 'package:mobile/features/games/energy_figures.dart';
import 'package:mobile/features/games/faster_or_slower_game.dart';
import 'package:mobile/features/games/harder_to_spin_game.dart';
import 'package:mobile/features/games/kinematics_figures.dart';
import 'package:mobile/features/games/same_spin_different_speed_game.dart';
import 'package:mobile/features/games/speeding_up_or_turning_game.dart';
import 'package:mobile/features/games/tap_the_trajectory_game.dart';
import 'package:mobile/features/games/which_piece_drives_it_game.dart';
import 'package:mobile/features/games/how_it_settles_game.dart';
import 'package:mobile/features/games/rotation_figures.dart';
import 'package:mobile/features/games/stretch_the_time_game.dart';
import 'package:mobile/features/games/vibration_figures.dart';
import 'package:mobile/features/games/where_the_energy_goes_game.dart';
import 'package:mobile/features/games/does_the_mass_matter_game.dart';
import 'package:mobile/features/games/kinetics_figures.dart';
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/mass_or_weight_game.dart';
import 'package:mobile/features/games/more_in_than_out_game.dart';
import 'package:mobile/features/games/push_it_or_spin_it_game.dart';
import 'package:mobile/features/games/stick_or_bounce_game.dart';
import 'package:mobile/features/games/what_is_missing_game.dart';
import 'package:mobile/features/games/what_survives_the_crash_game.dart';
import 'package:mobile/features/games/when_it_runs_away_game.dart';

import 'builder.dart';
import 'pick_one_adapter.dart';

/// The Dynamics games, each laid out as its own screen of blocks (see the
/// pack's pick-one game). They all share the answer buttons of the standard
/// pick-one, with a gap after every answer, the last one included.

Map<String, Object?> moreInThanOut() => pickScreen(
  id: 'more-in-than-out',
  title: 'More In Than Out',
  closing:
      'A machine always takes in more than it gives out, so the input is '
      'the output divided by the efficiency and the output is the input '
      'times it. Read which of the two you were handed before you pick '
      'the operation. And power itself is force times speed, or work '
      'over time, which are the same sentence twice.',
  right: 'THAT IS THE STEP',
  wrong: 'THE OTHER WAY',
  brief: briefJson(powerBrief, 'powerBrief'),
  rounds: [
    for (final r in powerRounds)
      (
        options: [for (final s in r.options) s.plain],
        tex: null,
        answer: r.options.indexOf(r.answer),
        why: r.why,
        source: r.source,
        screen: [
          ...heading('WHICH STEP DOES THIS NEED', r.subject, r.setting),
          gap(10),
          {'text': r.asked, 'bold': true},
          gap(12),
          {
            'math': r'$P = Fv, \quad \eta = \dfrac{P_{out}}{P_{in}}$',
            'size': 16,
          },
          gap(14),
          ...answers(8),
        ],
      ),
  ],
);

Map<String, Object?> whatIsMissing() => pickScreen(
  id: 'what-is-missing',
  title: 'What Is Missing',
  closing:
      'Five quantities, four equations, and each equation leaves exactly '
      'one of them out. Find the one the problem never mentions and it '
      'has chosen your equation for you. The one that comes up most is '
      'time: no seconds anywhere means v squared equals v naught squared '
      'plus two a s.',
  right: 'THAT IS THE ABSENT ONE',
  wrong: 'LOOK AGAIN',
  brief: briefJson(missingBrief, 'missingBrief'),
  choicePad: 12,
  rounds: [
    for (final r in absentRounds)
      (
        options: [for (final k in Known.values) k.plain],
        tex: [for (final k in Known.values) k.tex],
        answer: Known.values.indexOf(r.answer),
        why: r.why,
        source: r.source,
        screen: [
          ...heading(
            'TAP WHAT THE PROBLEM NEVER MENTIONS',
            r.subject,
            r.setting,
          ),
          gap(14),
          {'choices': true, 'space': 8, 'last': true},
          gap(6, when: 'done'),
          {
            'when': 'done',
            'box': [
              {'overline': 'SO THE EQUATION IS', 'color': 'forest'},
              gap(8),
              {'math': '\$${r.equation}\$', 'size': 17},
            ],
            'pad': [14, 12, 14, 14],
          },
          ...feedbackAfter(12),
        ],
      ),
  ],
);

Map<String, Object?> whenItRunsAway() => pickScreen(
  id: 'when-it-runs-away',
  title: 'When It Runs Away',
  closing:
      'Resonance is not a property of a structure, it is what happens '
      'when something pushes it at its own frequency. Far above is safe '
      'and far below is safe; it is the middle that tears things apart. '
      'And two frequencies can only be compared once they are in the '
      'same units: turns a minute, cycles a second and radians a second '
      'are three ways of saying the same kind of thing.',
  right: 'THAT IS THE CASE',
  wrong: 'LOOK AT THE TWO',
  brief: briefJson(resonanceBrief, 'resonanceBrief'),
  rounds: [
    for (final (i, r) in tuneRounds.indexed)
      (
        options: [for (final d in Danger.values) d.plain],
        tex: null,
        answer: Danger.values.indexOf(r.answer),
        why: r.why,
        source: r.source,
        screen: [
          ...heading('IS THIS HEADED FOR RESONANCE', r.subject, r.setting),
          gap(12),
          figure(
            (answered) => TunePainter(
              naturalHz: r.naturalHz,
              forcingHz: answered ? r.forcingHz : null,
            ).paint,
            130,
            frame: 'none',
            what: 'when-it-runs-away round $i',
          ),
          gap(4),
          {
            'when': 'ask',
            'mono': 'the peak is the natural frequency',
            'size': 11,
            'color': 'ink3',
          },
          {
            'when': 'done',
            'mono': 'the mark is where the forcing lands',
            'size': 11,
            'color': 'ink3',
          },
          gap(10),
          {
            'math':
                r'$1\ \mathrm{Hz} = 60\ \mathrm{rpm} = 2\pi\ \mathrm{rad/s}$',
            'size': 14,
          },
          gap(14),
          ...answers(8),
        ],
      ),
  ],
);

Map<String, Object?> whatSurvivesTheCrash() => pickScreen(
  id: 'what-survives-the-crash',
  title: 'What Survives the Crash',
  closing:
      'Momentum survives every collision, because nothing outside is '
      'pushing on the pair while it happens. Kinetic energy survives '
      'only a perfect bounce. Everything in between loses some, and a '
      'crash where things stick together loses the most. Read the word '
      'stick and you already know the energy is gone.',
  right: 'THAT IS WHAT SURVIVES',
  wrong: 'LOOK AGAIN',
  brief: briefJson(survivesBrief, 'survivesBrief'),
  rounds: [
    for (final (i, r) in surviveRounds.indexed)
      (
        options: [for (final s in Survives.values) s.plain],
        tex: null,
        answer: Survives.values.indexOf(r.answer),
        why: r.why,
        source: r.source,
        screen: [
          ...heading('WHAT COMES THROUGH UNCHANGED', r.subject, r.setting),
          gap(12),
          figure(
            (_) => CrashPainter(crash: r.crash, showAfter: true).paint,
            150,
            frame: 'grid',
            what: 'what-survives-the-crash round $i',
          ),
          gap(14),
          {'choices': true, 'space': 8, 'last': true},
          gap(6, when: 'done'),
          {
            'when': 'done',
            'mono': 'about ${r.energyLeft} percent of the energy is left',
            'size': 12,
            'color': 'forest',
          },
          ...feedbackAfter(10),
        ],
      ),
  ],
);

Map<String, Object?> pushItOrSpinIt() => pickScreen(
  id: 'push-it-or-spin-it',
  title: 'Push It or Spin It',
  closing:
      'Forces move the mass center and moments about that center spin '
      'the body. An axle stops it moving off, so only the moment '
      'equation is left. A force through the mass center has no arm, so '
      'only the force equation is left. Anything else needs both, and a '
      'force only becomes a moment once you multiply it by its distance '
      'from the center.',
  right: 'THAT IS WHAT IT NEEDS',
  wrong: 'NOT QUITE',
  brief: briefJson(twoEquationsBrief, 'twoEquationsBrief'),
  rounds: [
    for (final (i, r) in shoveRounds.indexed)
      (
        options: [for (final n in Needs2.values) n.plain],
        tex: null,
        answer: Needs2.values.indexOf(r.answer),
        why: r.why,
        source: r.source,
        screen: [
          ...heading('WHICH EQUATION DOES THIS NEED', r.subject, r.setting),
          gap(12),
          figure(
            (_) => PushPainter(pushed: r.pushed).paint,
            180,
            frame: 'grid',
            what: 'push-it-or-spin-it round $i',
          ),
          gap(4),
          {
            'mono': r.pushed.held == Held2.axle
                ? 'the ring at the middle is a fixed axle'
                : r.pushed.held == Held2.floor
                ? 'resting on a frictionless floor'
                : 'nothing is holding it',
            'size': 11,
            'color': 'ink3',
          },
          gap(10),
          {'math': r'$\sum F = ma_c, \quad \sum M_c = I_c\alpha$', 'size': 15},
          gap(14),
          ...answers(8),
        ],
      ),
  ],
);

Map<String, Object?> doesTheMassMatter() => pickScreen(
  id: 'does-the-mass-matter',
  title: 'Does the Mass Matter',
  closing:
      'Mass cancels when it sits on both sides of an energy balance: the '
      'speed at the bottom of a ramp, the height of a throw, the '
      'stopping distance under friction. It does not cancel when it sits '
      'on one side only: the energy carried, the power to lift, the '
      'speed a fixed spring can give. Look for it before you compute.',
  right: 'THAT IS RIGHT',
  wrong: 'LOOK AT THE FORMULA',
  brief: briefJson(cancelBrief, 'cancelBrief'),
  rounds: [
    for (final r in massRounds)
      (
        options: [for (final h in Heavier.values) h.plain],
        tex: null,
        answer: Heavier.values.indexOf(r.answer),
        why: r.why,
        source: r.source,
        screen: [
          ...heading('HEAVY, LIGHT, OR NO DIFFERENCE', r.subject, r.setting),
          gap(10),
          {'text': r.asked, 'bold': true},
          gap(14),
          {'choices': true, 'space': 8, 'last': true},
          gap(6, when: 'done'),
          {
            'when': 'done',
            'box': [
              {'overline': 'WHAT IT COMES FROM', 'color': 'forest'},
              gap(8),
              {'math': '\$${r.formula}\$', 'size': 17},
            ],
            'pad': [14, 12, 14, 14],
          },
          ...feedbackAfter(12),
        ],
      ),
  ],
);

Map<String, Object?> stickOrBounce() => pickScreen(
  id: 'stick-or-bounce',
  title: 'Stick or Bounce',
  closing:
      'Stuck, locked, coupled, embedded: all of them mean e is nothing '
      'and one equation does it, with the masses added together. A '
      'perfect bounce is e of one and is the only case where the energy '
      'survives too. Anything else needs the momentum equation AND the '
      'restitution equation, because two unknown speeds need two '
      'equations.',
  right: 'THAT IS THE KIND',
  wrong: 'A DIFFERENT KIND',
  brief: briefJson(impactBrief, 'impactBrief'),
  rounds: [
    for (final (i, r) in impactRounds.indexed)
      (
        options: [for (final k in Impact.values) k.plain],
        tex: null,
        answer: Impact.values.indexOf(r.answer),
        why: r.why,
        source: r.source,
        screen: [
          ...heading('WHAT KIND OF IMPACT IS THIS', r.subject, r.setting),
          gap(12),
          figure(
            (answered) =>
                CrashPainter(crash: r.crash, showAfter: answered).paint,
            {'ask': 90, 'done': 150},
            frame: 'grid',
            what: 'stick-or-bounce round $i',
          ),
          gap(10),
          {'math': r"$e = \dfrac{v_2' - v_1'}{v_1 - v_2}$", 'size': 16},
          gap(14),
          {'choices': true, 'space': 8, 'last': true},
          gap(6, when: 'done'),
          {
            'when': 'done',
            'mono': r.equations == 1
                ? 'one equation is enough'
                : 'this one needs two equations',
            'size': 12,
            'color': 'forest',
          },
          ...feedbackAfter(10),
        ],
      ),
  ],
);

Map<String, Object?> massOrWeight() => pickScreen(
  id: 'mass-or-weight',
  title: 'Mass or Weight',
  closing:
      'Kilograms and slugs are mass. Newtons and pounds are force. F '
      'equals m a wants a force on one side and a mass on the other, so '
      'read which one you were given before you write anything down. '
      'Weight is m g, and on this exam g is nine point eight one or '
      'thirty two point two depending on the units.',
  right: 'THAT IS THE STEP',
  wrong: 'THE OTHER WAY',
  brief: briefJson(weightBrief, 'weightBrief'),
  rounds: [
    for (final r in unitRounds)
      (
        options: [for (final p in Prep.values) p.plain],
        tex: null,
        answer: Prep.values.indexOf(r.answer),
        why: r.why,
        source: r.source,
        screen: [
          {'overline': 'WHAT HAS TO HAPPEN TO THE NUMBER', 'color': 'ember'},
          gap(6),
          {'mono': r.subject, 'size': 11.5, 'color': 'ink3'},
          gap(12),
          {
            'box': [
              {'overline': 'THE PROBLEM SAYS', 'color': 'info'},
              gap(8),
              {'text': r.setting},
              gap(12),
              {'overline': 'YOU WANT', 'color': 'ember'},
              gap(8),
              {'text': r.wanted},
            ],
            'pad': [14, 13, 14, 14],
          },
          gap(12),
          {'math': r'$W = mg, \quad \sum F = ma$', 'size': 16},
          gap(14),
          ...answers(8),
        ],
      ),
  ],
);

Map<String, Object?> fasterOrSlower() => pickScreen(
  id: 'faster-or-slower',
  title: 'Faster or Slower',
  closing:
      'Stiffer is quicker, heavier is slower, and the square root '
      'softens both: four times the stiffness is only twice the '
      'frequency. What matters is the RATIO of the two, so doubling both '
      'changes nothing. And how far you pull it does not appear in the '
      'formula at all.',
  right: 'THAT IS THE QUICKER ONE',
  wrong: 'THE OTHER WAY',
  brief: briefJson(naturalBrief, 'naturalBrief'),
  rounds: [
    for (final (n, r) in pairRounds3.indexed)
      (
        options: [for (final q in Quicker.values) q.plain],
        tex: null,
        answer: Quicker.values.indexOf(r.answer),
        why: r.why,
        source: r.source,
        screen: [
          ...heading('WHICH ONE SHAKES QUICKER', r.subject, r.setting),
          gap(12),
          panels(
            [
              for (final (bouncer, pull) in [
                (r.left, r.pulls?.$1),
                (r.right, r.pulls?.$2),
              ])
                (canvas, size, _) => SpringPainter(
                  bouncer: bouncer,
                  frame: r.frame,
                  pull: pull,
                  label:
                      '${bouncer.mass.round()} kg on '
                      '${bouncer.stiffness.round()} N/m',
                ).paint(canvas, size),
            ],
            h: 190,
            pad: 4,
            row: true,
            toned: false,
            what: 'faster-or-slower round $n',
          ),
          gap(8),
          {'math': r'$\omega_n = \sqrt{\dfrac{k}{m}}$', 'size': 17},
          gap(12),
          {
            'choices': [2],
          },
          ...feedbackAfter(14),
        ],
      ),
  ],
);

Map<String, Object?> howItSettles() => pickScreen(
  id: 'how-it-settles',
  title: 'How It Settles',
  closing:
      'Under one it swings and dies away, which is nearly every real '
      'structure. At one it comes back fastest without swinging, which '
      'is what a door closer is tuned to. Over one it still does not '
      'swing and it takes LONGER, which is the part that surprises '
      'people: more damping past critical is slower, not quicker.',
  right: 'THAT IS THE ONE',
  wrong: 'A DIFFERENT CURVE',
  brief: briefJson(dampingBrief, 'dampingBrief'),
  rounds: [
    for (final (n, r) in settleRounds.indexed)
      (
        options: [for (final d in r.options) d.plain],
        tex: null,
        answer: r.options.indexOf(r.answer),
        why: r.why,
        source: r.source,
        screen: [
          ...heading('TAP THE CURVE THAT MATCHES', r.subject, r.setting),
          gap(12),
          panels(
            [
              for (final d in r.options)
                (canvas, size, state) => SettlePainter(
                  damped: d,
                  tone: toneOf(state),
                ).paint(canvas, size),
            ],
            h: 104,
            toned: true,
            what: 'how-it-settles round $n',
          ),
          {
            'when': 'picked',
            'pickedLabel': [for (final d in r.options) d.plain],
            'size': 12,
            'color': 'ember',
          },
          gap(8, when: 'picked'),
          {'math': r'$\zeta = \dfrac{c}{2\sqrt{km}}$', 'size': 16},
          ...feedbackAfter(14),
        ],
      ),
  ],
);

Map<String, Object?> stretchTheTime() => pickScreen(
  id: 'stretch-the-time',
  title: 'Stretch the Time',
  closing:
      'The impulse is the force times the time, and it is the whole of '
      'the change in momentum. A crash decides the momentum change; the '
      'design decides how long it takes, and the force follows. Stretch '
      'the time to soften a blow, shorten it to deliver one.',
  right: 'THAT IS THE ONE',
  wrong: 'THE OTHER SHAPE',
  brief: briefJson(impulseBrief, 'impulseBrief'),
  rounds: [
    for (final (n, r) in pulseRounds.indexed)
      (
        // A drawing has no words; these are only for the audit and reports.
        options: [for (var i = 0; i < r.options.length; i++) 'shape ${i + 1}'],
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...heading('TAP A FORCE AGAINST TIME', r.subject, r.setting),
          gap(8),
          {'text': r.asked, 'bold': true},
          gap(12),
          panels(
            [
              for (final pulse in r.options)
                (canvas, size, state) => PulsePainter(
                  pulse: pulse,
                  tallest: r.tallest,
                  longest: r.longest,
                  tone: toneOf(state),
                ).paint(canvas, size),
            ],
            h: 104,
            toned: true,
            what: 'stretch-the-time round $n',
          ),
          {'math': r'$F\,\Delta t = m\,\Delta v$', 'size': 17},
          ...feedbackAfter(14),
        ],
      ),
  ],
);

Map<String, Object?> harderToSpin() => pickScreen(
  id: 'harder-to-spin',
  title: 'Harder to Spin',
  closing:
      'Same mass, same size, and what is left is where the material sits '
      'and where the axis is. Mass at the rim counts for everything and '
      'mass near the axis counts for almost nothing. Move the axis off '
      'the body and the transfer term, m d squared, takes over '
      'completely.',
  right: 'THAT IS THE HEAVY ONE TO SPIN',
  wrong: 'THE OTHER ONE',
  brief: briefJson(spinInertiaBrief, 'spinInertiaBrief'),
  rounds: [
    for (final (n, r) in pairRounds2.indexed)
      (
        options: const ['the left one', 'the right one'],
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...heading(
            'TAP THE ONE THAT TAKES MORE TO SPIN UP',
            r.subject,
            r.setting,
          ),
          gap(12),
          panels(
            [
              for (final body in [r.left, r.right])
                (canvas, size, state) => BodyPainter(
                  body: body,
                  frame: r.frame,
                  tone: toneOf(state),
                ).paint(canvas, size),
            ],
            h: 160,
            pad: 4,
            row: true,
            toned: true,
            what: 'harder-to-spin round $n',
          ),
          gap(8),
          {
            'mono': 'same mass on both sides. the ring marks the axis',
            'size': 11,
            'color': 'ink3',
          },
          gap(10),
          {'math': r'$I = I_c + md^2$', 'size': 17},
          ...feedbackAfter(14),
        ],
      ),
  ],
);

Map<String, Object?> whereTheEnergyGoes() => pickScreen(
  id: 'where-the-energy-goes',
  title: 'Where the Energy Goes',
  closing:
      'What it started with, plus anything put in, minus anything rubbed '
      'away, is what it ends with. A spring stores and gives back. '
      'Friction takes and never returns. A motor adds from outside. Read '
      'which of those a problem has before you write a single term.',
  right: 'THAT IS THE ACCOUNT',
  wrong: 'A DIFFERENT STORY',
  brief: briefJson(ledgerBrief, 'ledgerBrief'),
  rounds: [
    for (final (n, r) in ledgerRounds.indexed)
      (
        options: [
          for (var i = 0; i < r.options.length; i++) 'account ${i + 1}',
        ],
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...heading('TAP THE ACCOUNT THAT MATCHES', r.subject, r.setting),
          gap(12),
          panels(
            [
              for (final ledger in r.options)
                (canvas, size, _) => LedgerPainter(
                  ledger: ledger,
                  tallest: r.tallest,
                ).paint(canvas, size),
            ],
            h: 116,
            toned: false,
            what: 'where-the-energy-goes round $n',
          ),
          {'mono': 'all three to one scale', 'size': 11, 'color': 'ink3'},
          ...feedbackAfter(14),
        ],
      ),
  ],
);

Map<String, Object?> whichPieceDrivesIt() => pickScreen(
  id: 'which-piece-drives-it',
  title: 'Which Piece Drives It',
  closing:
      'Gravity pulls straight down. On a slope that splits into a piece '
      'running down the surface, weight times the sine, which is the '
      'only thing accelerating the block, and a piece pressing into it, '
      'weight times the cosine, which the surface answers exactly. Past '
      'forty five degrees the driving piece is the bigger one.',
  right: 'THAT IS THE ONE',
  wrong: 'A DIFFERENT ARROW',
  brief: briefJson(slopeBrief, 'slopeBrief'),
  rounds: [
    for (final (n, r) in slopeRounds.indexed)
      (
        options: [for (final a in r.arrows) a.plain],
        tex: null,
        answer: r.arrows.indexOf(r.answer),
        why: r.why,
        source: r.source,
        screen: [
          ...heading('TAP AN ARROW ON THE BLOCK', r.subject, r.asked),
          gap(12),
          tapMarks(
            paint: (canvas, size, mark, answered) => SlopePainter2(
              slope: r.slope,
              arrows: r.arrows,
              picked: mark == null ? null : r.arrows[mark],
              truth: answered ? r.answer : null,
              locked: answered,
            ).paint(canvas, size),
            marks: r.arrows.length,
            at: (size, i) => SlopePainter2.headOf(r.slope, size, r.arrows[i]),
            within: 32,
            hits: [for (var i = 0; i < r.arrows.length; i++) i],
            h: 230,
            what: 'which-piece-drives-it round $n',
          ),
          gap(6, when: 'picked'),
          {
            'when': 'picked',
            'pickedLabel': [for (final a in r.arrows) a.plain],
            'size': 12,
            'color': 'ember',
          },
          ...feedbackAfter(12),
        ],
      ),
  ],
);

Map<String, Object?> speedingUpOrTurning() => pickScreen(
  id: 'speeding-up-or-turning',
  title: 'Speeding Up or Turning',
  closing:
      'Along the road changes how fast. Toward the middle of the bend '
      'changes which way, and it is there even at a steady speed. They '
      'sit at right angles, so the total is the two combined as a right '
      'triangle and never the two added up.',
  right: 'THAT IS THE ONE',
  wrong: 'A DIFFERENT ARROW',
  brief: briefJson(bendBrief, 'bendBrief'),
  rounds: [
    for (final (n, r) in cornerRounds.indexed)
      (
        options: [for (final p in r.shown) p.name],
        tex: null,
        answer: r.shown.indexOf(r.answer),
        why: r.why,
        source: r.source,
        screen: [
          ...heading('TAP AN ARROW ON THE ROAD', r.subject, r.setting),
          gap(8),
          {'text': r.asked, 'bold': true},
          gap(12),
          tapMarks(
            paint: (canvas, size, mark, answered) => BendPainter(
              bend: r.bend,
              show: r.shown,
              picked: mark == null ? null : r.shown[mark],
              truth: answered ? r.answer : null,
              locked: answered,
            ).paint(canvas, size),
            marks: r.shown.length,
            at: (size, i) => BendPainter.headOf(r.bend, size, r.shown[i]),
            within: 34,
            hits: [for (var i = 0; i < r.shown.length; i++) i],
            h: 210,
            what: 'speeding-up-or-turning round $n',
          ),
          gap(10),
          {
            'math':
                r'$a_t = \dot{v}, \quad a_n = \dfrac{v^2}{\rho}, \quad '
                r'a = \sqrt{a_t^2 + a_n^2}$',
            'size': 14,
          },
          ...feedbackAfter(14),
        ],
      ),
  ],
);

Map<String, Object?> sameSpinDifferentSpeed() => pickScreen(
  id: 'same-spin-different-speed',
  title: 'Same Spin, Different Speed',
  closing:
      'One body, one angular velocity, and a different speed at every '
      'radius. Speed is r omega and the pull toward the middle is r '
      'omega squared, so both grow as you go out and neither depends on '
      'where a point sits around the circle. And rpm is not omega: it '
      'takes two pi over sixty to get there.',
  right: 'THAT IS THE POINT',
  wrong: 'NOT THAT ONE',
  brief: briefJson(spinBrief, 'spinBrief'),
  rounds: [
    for (final (n, r) in spinRounds.indexed)
      (
        options: [
          for (var i = 0; i < r.spinner.marks.length; i++) 'point ${i + 1}',
          'No single point: they are equal on this',
        ],
        tex: null,
        answer: r.everywhere ? r.spinner.marks.length : r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...heading('TAP A POINT ON THE BODY', r.subject, r.asked),
          gap(12),
          tapMarks(
            paint: (canvas, size, mark, answered) => SpinnerPainter(
              spinner: r.spinner,
              picked: mark,
              truth: answered && !r.everywhere ? r.answer : null,
              locked: answered,
              arm: r.arm,
            ).paint(canvas, size),
            marks: r.spinner.marks.length,
            at: (size, i) =>
                SpinnerPainter.markAt(r.spinner, size, i, arm: r.arm),
            within: 30,
            hits: [for (var i = 0; i < r.spinner.marks.length; i++) i],
            h: r.arm ? 150 : 230,
            what: 'same-spin-different-speed round $n',
          ),
          gap(8),
          {'math': r'$v = r\omega, \quad a_n = r\omega^2$', 'size': 16},
          gap(12),
          {
            'choices': [r.spinner.marks.length],
          },
          ...feedbackAfter(14),
        ],
      ),
  ],
);

Map<String, Object?> tapTheTrajectory() => pickScreen(
  id: 'tap-the-trajectory',
  title: 'Tap the Trajectory',
  closing:
      'Across and up and down are two separate problems. Across never '
      'changes. Up and down runs steadily downhill through zero at the '
      'top. The acceleration is the same everywhere, gravity, including '
      'at the moment the ball is slowest. Split them at the start and '
      'never mix them again.',
  right: 'THAT IS THE MOMENT',
  wrong: 'NOT THERE',
  brief: briefJson(flightBrief, 'flightBrief'),
  rounds: [
    for (final (n, r) in arcRounds.indexed)
      (
        options: [
          for (final m in Moment.values) m.plain,
          'No single moment: it is the same the whole way',
        ],
        tex: null,
        answer: r.everywhere
            ? Moment.values.length
            : Moment.values.indexOf(r.answer),
        why: r.why,
        source: r.source,
        screen: [
          ...heading('TAP A MOMENT IN THE FLIGHT', r.subject, r.asked),
          gap(12),
          tapMarks(
            paint: (canvas, size, mark, answered) => FlightPainter(
              flight: r.flight,
              moments: Moment.values,
              picked: mark == null ? null : Moment.values[mark],
              truth: answered && !r.everywhere ? r.answer : null,
              locked: answered,
              showVelocities: answered,
            ).paint(canvas, size),
            marks: Moment.values.length,
            at: (size, i) =>
                FlightPainter.momentAt(r.flight, size, Moment.values[i]),
            within: 34,
            hits: [for (var i = 0; i < Moment.values.length; i++) i],
            h: 220,
            what: 'tap-the-trajectory round $n',
          ),
          gap(6),
          {
            'when': 'ask',
            'mono': 'five moments, from the launch to the landing',
            'size': 11,
            'color': 'ink3',
          },
          {
            'when': 'done',
            'mono': 'the arrows are the velocity at each moment',
            'size': 11,
            'color': 'ink3',
          },
          {
            ...gap(6, when: 'picked'),
            'of': [for (var i = 0; i < Moment.values.length; i++) i],
          },
          {
            'when': 'picked',
            'of': [for (var i = 0; i < Moment.values.length; i++) i],
            'pickedLabel': [for (final m in Moment.values) m.plain],
            'size': 12,
            'color': 'ember',
          },
          gap(12),
          {
            'choices': [Moment.values.length],
          },
          ...feedbackAfter(14),
        ],
      ),
  ],
);

final adapters = <String, Map<String, Object?> Function()>{
  'more-in-than-out': moreInThanOut,
  'what-is-missing': whatIsMissing,
  'when-it-runs-away': whenItRunsAway,
  'what-survives-the-crash': whatSurvivesTheCrash,
  'push-it-or-spin-it': pushItOrSpinIt,
  'does-the-mass-matter': doesTheMassMatter,
  'stick-or-bounce': stickOrBounce,
  'mass-or-weight': massOrWeight,
  'faster-or-slower': fasterOrSlower,
  'how-it-settles': howItSettles,
  'stretch-the-time': stretchTheTime,
  'harder-to-spin': harderToSpin,
  'where-the-energy-goes': whereTheEnergyGoes,
  'which-piece-drives-it': whichPieceDrivesIt,
  'speeding-up-or-turning': speedingUpOrTurning,
  'same-spin-different-speed': sameSpinDifferentSpeed,
  'tap-the-trajectory': tapTheTrajectory,
};
