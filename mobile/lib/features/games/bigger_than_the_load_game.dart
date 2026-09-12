import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'truss_section_figures.dart';

/// Bigger Than the Load — the second item for `truss-analysis-methods`.
///
/// At a joint where a vertical load is carried away by one diagonal, the
/// diagonal is the only member with anything pointing up, so it has to carry
/// the whole load with only PART of itself. That makes it larger than the
/// load, always, and the shallower it lies the larger it gets. The number is
/// the load over the sine of the angle, and it is worth knowing as a shape
/// rather than as a formula: a steep diagonal is an efficient one.
class BiggerThanTheLoadGame extends StatefulWidget {
  const BiggerThanTheLoadGame({super.key});

  @override
  State<BiggerThanTheLoadGame> createState() =>
      _BiggerThanTheLoadGameState();
}

/// How the diagonal's force compares with the load it is carrying.
enum HowBig { less, about, more }

extension Size3Words on HowBig {
  String get plain => switch (this) {
        HowBig.less => 'Smaller than the load',
        HowBig.about => 'About the same as the load',
        HowBig.more => 'Larger than the load, and by a good margin',
      };
}

@immutable
class CornerRound {
  const CornerRound({
    required this.subject,
    required this.setting,
    required this.corner,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Corner corner;
  final String why;
  final String source;

  /// Worked out of the geometry, never declared. The diagonal can never be
  /// smaller than the load it is resolving: that option is there because
  /// people reach for it, not because it happens.
  HowBig get answer {
    if (corner.ratio < 1.15) return HowBig.about;
    return HowBig.more;
  }
}

const webRounds = <CornerRound>[
  CornerRound(
    subject: 'the lesson\'s own joint',
    setting:
        'A 500 pound load hangs at the joint. A flat member runs off to one '
        'side and a diagonal leaves at 45 degrees.',
    corner: Corner(load: 500, degrees: 45),
    why:
        'Larger: 707 pounds, which is the load over the sine of 45 degrees. '
        'The diagonal is the only member with any vertical in it, so all 500 '
        'pounds has to be carried by its vertical COMPONENT, and the member '
        'force is bigger than its own component. At 45 degrees the factor is '
        '1.41, and the flat member takes the other 500 horizontally.',
    source: 'str-tam-q1',
  ),
  CornerRound(
    subject: 'a shallow diagonal',
    setting:
        'The same 500 pound load, but the diagonal lies at only 20 degrees '
        'above the horizontal.',
    corner: Corner(load: 500, degrees: 20),
    why:
        'Larger, and now much larger: the factor is nearly three, so the '
        'member carries about 1,460 pounds. A shallow diagonal is a bad '
        'diagonal, because only a small part of it points the way the load '
        'needs to go. This is why truss webs are not laid flat and why the '
        'depth of a truss is worth paying for.',
    source: 'str-tam-q1',
  ),
  CornerRound(
    subject: 'a steep diagonal',
    setting:
        'The same load with the diagonal at 75 degrees, nearly upright.',
    corner: Corner(load: 500, degrees: 75),
    why:
        'About the same: the factor is 1.04, so the member carries about 518 '
        'pounds. Nearly all of a steep member points upward, so it barely has '
        'to work harder than the load itself. Vertical would be exactly the '
        'load, and no member carrying a load off a joint can ever do better '
        'than that.',
    source: 'str-tam-q1',
  ),
  CornerRound(
    subject: 'the usual panel proportion',
    setting:
        'A truss four meters per panel and three deep, so the diagonal '
        'leaves the joint at about 37 degrees. The load is 30 kN.',
    corner: Corner(load: 30, degrees: 36.87),
    why:
        'Larger: the factor is 1.67, so about 50 kN. Three four five is the '
        'triangle hiding in most textbook trusses, and the numbers are worth '
        'knowing by sight: sine 0.6, cosine 0.8. A load of 30 puts 50 in the '
        'diagonal and 40 in the flat member, and every one of those is a '
        'round number for a reason.',
    source: 'str-tam-q1',
  ),
  CornerRound(
    subject: 'a nearly flat tie',
    setting: 'A 12 kN load hung off a joint whose only diagonal rises at 10 '
        'degrees.',
    corner: Corner(load: 12, degrees: 10),
    why:
        'Larger, and alarmingly: the factor is 5.8, so about 69 kN in a '
        'member carrying a 12 kN load. This is the arithmetic behind why a '
        'washing line pulled nearly straight snaps: the flatter the angle, '
        'the more force it takes to hold the same weight, and it runs away '
        'toward infinity as the member approaches horizontal.',
    source: 'str-tam-q1',
  ),
  CornerRound(
    subject: 'almost upright',
    setting: 'The same 12 kN load, with the diagonal at 80 degrees.',
    corner: Corner(load: 12, degrees: 80),
    why:
        'About the same: 12.2 kN. Between this round and the last one the '
        'load never changed and the member force went from 69 to 12, purely '
        'on the angle. Nothing else in a truss rewards attention to geometry '
        'quite this much, and it is the reason the first thing to write down '
        'at a joint is the rise over the run.',
    source: 'str-tam-q1',
  ),
];

class _BiggerThanTheLoadGameState extends State<BiggerThanTheLoadGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'bigger-than-the-load',
    chapterId: 'structural',
    total: webRounds.length,
    sourceProblemIdOf: (round) => webRounds[round].source,
  )..addListener(_onSession);

  HowBig? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  CornerRound get _round => webRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Bigger Than the Load',
        closing:
            'A diagonal carrying a load off a joint is always larger than '
            'the load, because only its vertical component is doing the '
            'carrying. The factor is one over the sine of the angle: 1.04 at '
            '75 degrees, 1.41 at 45, 1.67 on a three four five, and nearly '
            'six at 10 degrees. Steep is efficient, flat is expensive, and a '
            'member can never carry less than the load it is resolving.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: jointForceBrief,
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
            'HOW BIG IS THE FORCE IN THE DIAGONAL',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
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
          const SizedBox(height: 12),
          Container(
            height: 240,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter:
                      CornerPainter(corner: r.corner, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$F = \dfrac{P}{\sin\theta}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in HowBig.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != HowBig.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE SIZE OF IT' : 'NOT THAT',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
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
