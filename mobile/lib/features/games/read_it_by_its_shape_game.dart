import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'sign_figures.dart';

/// Read It by Its Shape — the first item for `traffic-control-devices`.
///
/// The shape and the color of a sign carry its category before a word of it
/// is read, which is the whole point of a uniform manual. Two of the
/// lesson's three problems are exactly this question asked about two
/// different signs.
class ReadItByItsShapeGame extends StatefulWidget {
  const ReadItByItsShapeGame({super.key});

  @override
  State<ReadItByItsShapeGame> createState() => _ReadItByItsShapeGameState();
}

@immutable
class SignKindRound {
  const SignKindRound({
    required this.subject,
    required this.asked,
    required this.sign,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final RoadSign sign;
  final SignKind answer;
  final String why;
  final String source;

  static String label(SignKind kind) => switch (kind) {
        SignKind.regulatory =>
          'Regulatory: it tells you what you must or must not do',
        SignKind.warning => 'Warning: it tells you what is coming',
        SignKind.guide => 'Guide: it tells you where things are',
      };
}

const signKindRounds = <SignKindRound>[
  SignKindRound(
    subject: 'a yellow diamond',
    asked:
        'This sign warns of a curve ahead. Which category does it belong to?',
    sign: RoadSign(
      shape: SignShape.diamond,
      color: 'yellow',
      legend: 'curve',
      kind: SignKind.warning,
    ),
    answer: SignKind.warning,
    why:
        'Warning, and the shape says so before the legend does. A yellow '
        'diamond means something is coming that the driver should prepare '
        'for: a curve, a crossing, a drop in the pavement. It does not '
        'require anything, it only tells.',
    source: 'trans-tcd-q1',
  ),
  SignKindRound(
    subject: 'the one shape reserved',
    asked: 'A STOP sign. Which category?',
    sign: RoadSign(
      shape: SignShape.octagon,
      color: 'red',
      legend: 'STOP',
      kind: SignKind.regulatory,
    ),
    answer: SignKind.regulatory,
    why:
        'Regulatory: it imposes a legal requirement, and failing to obey it '
        'is a violation. The octagon is reserved for this one sign alone, '
        'which is why it can be recognized from behind, in the dark, or with '
        'its face covered in snow.',
    source: 'trans-tcd-q3',
  ),
  SignKindRound(
    subject: 'a green rectangle',
    asked:
        'A green sign giving the distance to the next two towns. Which '
        'category?',
    sign: RoadSign(
      shape: SignShape.rectangle,
      color: 'green',
      legend: 'town 4',
      kind: SignKind.guide,
    ),
    answer: SignKind.guide,
    why:
        'Guide. Green carries directions, distances and destinations, and it '
        'asks nothing of the driver at all. Nothing on a guide sign is '
        'enforceable, which is why it can afford to carry so many words.',
    source: 'trans-tcd-q1',
  ),
  SignKindRound(
    subject: 'a white rectangle',
    asked: 'A white rectangle reading SPEED LIMIT 45. Which category?',
    sign: RoadSign(
      shape: SignShape.rectangle,
      color: 'white',
      legend: 'limit 45',
      kind: SignKind.regulatory,
    ),
    answer: SignKind.regulatory,
    why:
        'Regulatory again, and this is the shape most of them use: a white '
        'rectangle with black legend. The octagon and the yield triangle are '
        'the exceptions, kept for the two messages that have to be readable '
        'at a glance from any angle.',
    source: 'trans-tcd-q3',
  ),
  SignKindRound(
    subject: 'the same color, a different job',
    asked:
        'A yellow diamond showing a truck on a slope, meaning a steep grade '
        'ahead. Which category?',
    sign: RoadSign(
      shape: SignShape.diamond,
      color: 'yellow',
      legend: 'grade',
      kind: SignKind.warning,
    ),
    answer: SignKind.warning,
    why:
        'Warning, like every yellow diamond. Notice what the driver is NOT '
        'told: how slowly to go. A warning sign describes the road, and any '
        'speed that goes with it is advisory rather than enforceable, which '
        'is why it appears on a separate yellow plate and not on a white '
        'one.',
    source: 'trans-tcd-q1',
  ),
  SignKindRound(
    subject: 'why uniformity is the point',
    asked:
        'Which category does a red octagon belong to, in any country that '
        'follows the manual?',
    sign: RoadSign(
      shape: SignShape.octagon,
      color: 'red',
      legend: 'STOP',
      kind: SignKind.regulatory,
    ),
    answer: SignKind.regulatory,
    why:
        'Regulatory, everywhere, and that is the reason for having a manual '
        'at all. A driver who has never seen this particular intersection '
        'has seen this sign a thousand times, and recognizes it before '
        'reading it. Uniformity is what buys the reaction time.',
    source: 'trans-tcd-q3',
  ),
];

class _ReadItByItsShapeGameState extends State<ReadItByItsShapeGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'read-it-by-its-shape',
    chapterId: 'transportation',
    total: signKindRounds.length,
    sourceProblemIdOf: (round) => signKindRounds[round].source,
  );

  SignKind? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  SignKindRound get _round => signKindRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Read It by Its Shape',
        closing:
            'Red octagon and white rectangle: regulatory, and legally '
            'binding. Yellow diamond: warning, describing what is ahead. '
            'Green: guide, asking nothing at all. The shape and color carry '
            'the category before a word is read, which is what a uniform '
            'manual is for.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: signCategoryBrief,
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
            'WHAT KIND OF SIGN',
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
            height: 200,
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
                  painter: SignPainter(
                    sign: r.sign,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in SignKind.values) ...[
            _Choice(
              label: SignKindRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != SignKind.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS IT' : 'NOT THAT ONE',
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
