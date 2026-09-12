import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'rc_figures.dart';

/// Which One Is d — the first item for `rc-flexure-shear`.
///
/// The lesson says it in as many words: getting d wrong changes everything,
/// and d is not the height of the beam. Every formula in reinforced concrete
/// leans on the distance from the top of the beam to the CENTROID of the
/// tension steel, and on the lever arm that is shorter still. The arithmetic
/// belongs on paper; knowing which line on the drawing each symbol means
/// does not.
class WhichOneIsDGame extends StatefulWidget {
  const WhichOneIsDGame({super.key});

  @override
  State<WhichOneIsDGame> createState() => _WhichOneIsDGameState();
}

@immutable
class DepthRound {
  const DepthRound({
    required this.subject,
    required this.asked,
    required this.section,
    required this.marked,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final RcSection section;

  /// The dimension the drawing calls out. The answer is what it is called,
  /// so the figure cannot disagree with the round.
  final Depth marked;
  final String why;
  final String source;

  Depth get answer => marked;

  static String label(Depth which) => switch (which) {
        Depth.height => 'h, the overall height of the beam',
        Depth.effective => 'd, the effective depth',
        Depth.cover => 'the clear cover',
        Depth.leverArm => 'd minus a over 2, the lever arm',
        Depth.blockDepth => 'a, the depth of the compression block',
      };
}

const rcDepthRounds = <DepthRound>[
  DepthRound(
    subject: 'the one everybody reaches for',
    asked: 'What is the dimension marked on this section?',
    section: RcSection(width: 12, height: 21),
    marked: Depth.height,
    why:
        'That is h, the overall height, and it is the one dimension the '
        'formulas do NOT want. It is the easiest to measure and the easiest '
        'to reach for, and using it in place of d overstates the capacity of '
        'every beam you check. The lesson puts this first for a reason.',
    source: 'str-rfs-q1',
  ),
  DepthRound(
    subject: 'the one the formulas want',
    asked: 'And this one?',
    section: RcSection(width: 12, height: 21),
    marked: Depth.effective,
    why:
        'That is d, the effective depth: from the top of the beam down to the '
        'CENTROID of the tension steel. It stops at the middle of the bars, '
        'not at the top of them and not at the bottom of the beam, so it is '
        'the height less the cover, less the stirrup, less half a bar '
        'diameter. Every flexure and shear formula in the lesson uses this '
        'one.',
    source: 'str-rfs-q1',
  ),
  DepthRound(
    subject: 'the strip at the bottom',
    asked: 'What about this one?',
    section: RcSection(width: 12, height: 21),
    marked: Depth.cover,
    why:
        'That is the clear cover, the concrete between the outside face and '
        'the stirrup. It is there to keep water and air off the steel and to '
        'hold the bond, and it is one of the three bites taken out of h on '
        'the way down to d. Concrete cover is protection, not capacity: no '
        'formula in the lesson uses it directly.',
    source: 'str-rfs-q1',
  ),
  DepthRound(
    subject: 'the shallow one at the top',
    asked: 'This one is measured from the top face down. What is it?',
    section: RcSection(width: 12, height: 21, blockDepth: 4.4),
    marked: Depth.blockDepth,
    why:
        'That is a, the depth of the Whitney block: the equivalent rectangle '
        'that stands in for the real, curved compression in the top of the '
        'beam. It is worked out from how much steel there is to balance, '
        'which is why a beam with more steel has a deeper block and, in the '
        'end, a shorter lever arm.',
    source: 'str-rfs-q1',
  ),
  DepthRound(
    subject: 'the distance that does the work',
    asked:
        'This one runs from the middle of the compression block down to the '
        'steel. What is it?',
    section: RcSection(width: 12, height: 21, blockDepth: 4.4),
    marked: Depth.leverArm,
    why:
        'That is the lever arm, d minus a over 2. The beam carries moment as '
        'a couple, steel pulling at the bottom and concrete pushing at the '
        'top, and the moment is the force times the distance BETWEEN them. '
        'Using d itself as the lever arm is the wrong answer the lesson lists '
        'first, and it always comes out too big.',
    source: 'str-rfs-q1',
  ),
  DepthRound(
    subject: 'a deeper beam, same question',
    asked:
        'A deeper beam with bigger bars in it. What is the marked dimension '
        'here?',
    section: RcSection(width: 14, height: 27, barDiameter: 1.27),
    marked: Depth.effective,
    why:
        'd again, and worth doing twice because the three bites are different '
        'on every beam: bigger bars push the centroid further from the '
        'bottom, and so does a second layer of steel. Read the cover, the '
        'stirrup and half a bar off the height each time rather than '
        'remembering a number from the last question.',
    source: 'str-rfs-q1',
  ),
];

class _WhichOneIsDGameState extends State<WhichOneIsDGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-one-is-d',
    chapterId: 'structural',
    total: rcDepthRounds.length,
    sourceProblemIdOf: (round) => rcDepthRounds[round].source,
  )..addListener(_onSession);

  Depth? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  DepthRound get _round => rcDepthRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which One Is d',
        closing:
            'd is the top of the beam down to the CENTROID of the tension '
            'steel, which is the height less the cover, less the stirrup, '
            'less half a bar. It is never the height of the beam. The lever '
            'arm is shorter still, d less half the block depth, because the '
            'moment is carried by a couple and what matters is the distance '
            'between its two forces.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: whichDepthBrief,
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
            'WHAT IS THE MARKED DIMENSION',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.asked,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 236,
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
                  painter: SectionMarkPainter(
                    section: r.section,
                    marked: r.marked,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$M_n = A_s f_y \left(d - \frac{a}{2}\right)$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Depth.values) ...[
            _Choice(
              label: DepthRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Depth.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'NOT THAT ONE',
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
