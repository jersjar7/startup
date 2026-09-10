import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Can You Get There — the third item for `stress-strain-diagrams`.
///
/// The hard problem in this lesson hands you a specimen's length and diameter
/// before and after the test, and none of it is used: E and Poisson's ratio
/// are already sitting there and one formula finishes the job. The lesson says
/// so itself, that the extra data is there to waste your time. The other half
/// of the same skill is knowing when you are genuinely short, because E on its
/// own will never give you G.
///
/// So no arithmetic. You are shown what you have and what is wanted, and the
/// answer is whether the road exists and how long it is.
class CanYouGetThereGame extends StatefulWidget {
  const CanYouGetThereGame({super.key});

  @override
  State<CanYouGetThereGame> createState() => _CanYouGetThereGameState();
}

/// The quantities this lesson deals in.
enum Quantity {
  stress,
  strain,
  e,
  nu,
  g,
  startLength,
  endLength,
  elongation,
  yieldStress,
  ultimate,
}

extension QuantityWords on Quantity {
  String get plain => switch (this) {
        Quantity.stress => 'a stress in the elastic range',
        Quantity.strain => 'the strain at that stress',
        Quantity.e => 'the modulus of elasticity',
        Quantity.nu => "Poisson's ratio",
        Quantity.g => 'the shear modulus',
        Quantity.startLength => 'the gauge length before the test',
        Quantity.endLength => 'the length after it broke',
        Quantity.elongation => 'the percent elongation',
        Quantity.yieldStress => 'the yield strength',
        Quantity.ultimate => 'the ultimate strength',
      };

  String get tex => switch (this) {
        Quantity.stress => r'\sigma',
        Quantity.strain => r'\varepsilon',
        Quantity.e => 'E',
        Quantity.nu => r'\nu',
        Quantity.g => 'G',
        Quantity.startLength => 'L_0',
        Quantity.endLength => 'L_f',
        Quantity.elongation => r'\%\,El',
        Quantity.yieldStress => r'\sigma_y',
        Quantity.ultimate => r'\sigma_u',
      };
}

/// Every road this lesson gives you, and there are only these.
final relations = <(Set<Quantity>, Quantity)>[
  ({Quantity.stress, Quantity.strain}, Quantity.e),
  ({Quantity.e, Quantity.nu}, Quantity.g),
  ({Quantity.g, Quantity.nu}, Quantity.e),
  ({Quantity.e, Quantity.g}, Quantity.nu),
  ({Quantity.startLength, Quantity.endLength}, Quantity.elongation),
];

/// How far it is from what you have to what is wanted.
enum Road { oneStep, further, cannot }

/// Worked out by walking the relations above, so a round cannot claim a road
/// that does not exist or miss one that does.
Road routeTo(Set<Quantity> have, Quantity want) {
  if (have.contains(want)) return Road.oneStep;
  var known = {...have};
  for (var step = 1; step <= 4; step++) {
    final gained = <Quantity>{};
    for (final (needs, gives) in relations) {
      if (!known.contains(gives) && needs.every(known.contains)) {
        gained.add(gives);
      }
    }
    if (gained.contains(want)) return step == 1 ? Road.oneStep : Road.further;
    if (gained.isEmpty) return Road.cannot;
    known = {...known, ...gained};
  }
  return Road.cannot;
}

@immutable
class ReachRound {
  const ReachRound({
    required this.setting,
    required this.have,
    required this.want,
    required this.why,
    required this.source,
    this.spare = const <String>[],
  });

  final String setting;
  final List<Quantity> have;
  final Quantity want;

  /// Numbers the question also hands you that are not quantities of this
  /// lesson at all, listed so the reader sees the full pile.
  final List<String> spare;

  final String why;
  final String source;

  Road get answer => routeTo(have.toSet(), want);
}

const roadRounds = <ReachRound>[
  ReachRound(
    setting:
        'This lesson\'s own hard problem. A test report gives the modulus of '
        'elasticity and Poisson\'s ratio, then the specimen\'s length and '
        'diameter before the test and again after it broke. You are asked for '
        'the shear modulus.',
    have: [Quantity.e, Quantity.nu],
    spare: [
      'length before and after',
      'diameter before and after',
    ],
    want: Quantity.g,
    why:
        'One formula, G equals E over two times one plus nu, and four of the '
        'six numbers you were handed do nothing at all. That is not an '
        'accident in the question, it is the question: the four dimensions '
        'are a page of arithmetic that leads nowhere. Find what is asked, '
        'find the shortest road, and stop reading.',
    source: 'mm-ssd-q3',
  ),
  ReachRound(
    setting:
        'A tensile test gives one stress in the elastic range and the strain '
        'measured at it, and the report also lists Poisson\'s ratio. You want '
        'the shear modulus.',
    have: [Quantity.stress, Quantity.strain, Quantity.nu],
    want: Quantity.g,
    why:
        'Two steps, and neither is hard. The stress over the strain is E, '
        'because that pair is in the elastic range and that is what E means. '
        'Then E and nu give G. The road exists, it just is not one hop, and '
        'noticing that before you start is worth more than speed.',
    source: 'mm-ssd-q1',
  ),
  ReachRound(
    setting:
        'All you are told is that the material is a steel with a modulus of '
        'elasticity of 200 GPa. You want its shear modulus.',
    have: [Quantity.e],
    want: Quantity.g,
    why:
        'You cannot get there. G needs E AND Poisson\'s ratio, and nothing '
        'here gives you nu. In practice you would look it up, near 0.3 for '
        'steel, which gives G at about 0.38 of E, but that is a table, not '
        'this question. Half of exam speed is knowing quickly that a road '
        'does not exist.',
    source: 'mm-ssd-q3',
  ),
  ReachRound(
    setting:
        'A broken specimen: you have the gauge length marked on it before the '
        'test and the length of the two halves fitted back together. You want '
        'the percent elongation.',
    have: [Quantity.startLength, Quantity.endLength],
    want: Quantity.elongation,
    why:
        'One step. Percent elongation is the change in length over the '
        'original length, times a hundred. It is a strain wearing a percent '
        'sign, and it is the most direct ductility number there is, which is '
        'why a test report always carries it.',
    source: 'mm-ssd-q2',
  ),
  ReachRound(
    setting:
        'A report lists a yield strength of 830 MPa and an ultimate strength '
        'of 830 MPa, and nothing else. You want the percent elongation.',
    have: [Quantity.yieldStress, Quantity.ultimate],
    want: Quantity.elongation,
    why:
        'Not from these. Strength and ductility are separate properties and '
        'no formula turns one into the other. What the two numbers being '
        'EQUAL does tell you is that this material is brittle, so you can '
        'expect the elongation to be tiny when you find it. Expecting a number '
        'and computing it are different things.',
    source: 'mm-ssd-q2',
  ),
  ReachRound(
    setting:
        'A handbook page gives the shear modulus and Poisson\'s ratio for a '
        'material but has no column for the modulus of elasticity. You want E.',
    have: [Quantity.g, Quantity.nu],
    want: Quantity.e,
    why:
        'One step, running the same formula backwards: E is G times two times '
        'one plus nu. Any two of the three constants hand you the third, in '
        'whichever direction you need. They were never three independent '
        'facts about the material.',
    source: 'mm-ssd-q3',
  ),
];

class _CanYouGetThereGameState extends State<CanYouGetThereGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'can-you-get-there',
    chapterId: 'mechanics-materials',
    total: roadRounds.length,
    sourceProblemIdOf: (round) => roadRounds[round].source,
  )..addListener(_onSession);

  Road? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ReachRound get _round => roadRounds[_session.round];

  String _label(Road r) => switch (r) {
        Road.oneStep => 'Yes, one formula does it',
        Road.further => 'Yes, but it takes more than one',
        Road.cannot => 'No, something is missing',
      };

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Can You Get There',
        closing:
            'E comes from a stress and its strain. G comes from E and nu, in '
            'either direction. Elongation comes from two lengths. Nothing in '
            'this lesson turns a strength into a ductility. Everything else '
            'on the page is there to be left alone.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: linkedBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _picked = null);
              _session.next();
            }
          : (_picked == null
                ? null
                : () => _session.submit(
                    ok: _picked == r.answer,
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CAN YOU GET THERE FROM HERE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 10),
          Text(
            r.setting,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 14),
          _Panel(
            title: 'YOU HAVE',
            tone: AppColors.info,
            children: [
              for (final q in r.have) _Line(quantity: q),
              for (final s in r.spare)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    s,
                    style: AppTheme.mono(size: 12, color: AppColors.ink3),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _Panel(
            title: 'YOU WANT',
            tone: AppColors.ember,
            children: [_Line(quantity: r.want)],
          ),
          const SizedBox(height: 14),
          for (final route in Road.values) ...[
            _Choice(
              label: _label(route),
              selected: _picked == route,
              locked: answered,
              isTruth: route == r.answer,
              onTap: answered ? null : () => setState(() => _picked = route),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 8),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ROAD' : 'LOOK AGAIN',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.tone,
    required this.children,
  });

  final String title;
  final Color tone;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 13),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTheme.overline(color: tone)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      );
}

class _Line extends StatelessWidget {
  const _Line({required this.quantity});

  final Quantity quantity;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 34,
              child: MathText(
                '\$${quantity.tex}\$',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.charcoal,
                ),
              ),
            ),
            Expanded(
              child: Text(
                quantity.plain,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.charcoal,
                ),
              ),
            ),
          ],
        ),
      );
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    if (locked && isTruth) {
      border = AppColors.forest;
    } else if (locked && selected) {
      border = AppColors.error;
    } else if (selected) {
      border = AppColors.ember;
    } else {
      border = AppColors.line;
    }

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
