import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'consolidation_figures.dart';

/// Stiff Until It Remembers — the second item for `consolidation`.
///
/// A clay squeezed onto ground it has covered before behaves quite unlike a
/// clay pushed past anything it has carried. The recompression index is
/// roughly a sixth of the compression index, so the same load can settle six
/// times as much depending only on where it lands, and the e against log p
/// curve shows why: a shallow line, a corner, and a steep one.
class StiffUntilItRemembersGame extends StatefulWidget {
  const StiffUntilItRemembersGame({super.key});

  @override
  State<StiffUntilItRemembersGame> createState() =>
      _StiffUntilItRemembersGameState();
}

@immutable
class IndexRound {
  const IndexRound({
    required this.subject,
    required this.asked,
    required this.squeeze,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Squeeze squeeze;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const _overconsolidated = Squeeze(
    now: 800, remembered: 1800, added: 400, cc: 0.40, cr: 0.065,
    thickness: 12, voidRatio: 1.10);

const _normally =
    Squeeze(now: 1000, remembered: 1000, added: 500, cc: 0.30, cr: 0.05);

const indexRounds = <IndexRound>[
  IndexRound(
    subject: 'the two slopes',
    asked:
        'The curve has a shallow stretch and then a steep one. What happens '
        'at the corner between them?',
    squeeze: _overconsolidated,
    options: [
      'The clay reaches the largest pressure it has ever carried',
      'The clay becomes fully saturated',
      'The water finishes draining out',
      'The sample reaches its liquid limit',
    ],
    answer: 0,
    why:
        'The corner IS the memory. Up to it the clay is being pushed back '
        'over ground it has been over before, and it goes stiffly. Past it '
        'the clay is being asked to do something it has never done, and the '
        'grains rearrange in earnest. Everything about consolidation hangs on '
        'which side of that corner a load leaves you.',
    source: 'geo-co-q3',
  ),
  IndexRound(
    subject: 'how much stiffer',
    asked:
        'Roughly how does the recompression index compare with the '
        'compression index?',
    squeeze: _overconsolidated,
    options: [
      'About a sixth of it',
      'About the same',
      'About six times it',
      'They are unrelated and have to be measured separately',
    ],
    answer: 0,
    why:
        'About a sixth, which is the rule of thumb the lesson gives. It means '
        'the SAME load on the SAME clay can settle six times as much '
        'depending only on whether it stays under the memory or goes past it. '
        'That is why the preconsolidation pressure is worth paying a lab to '
        'find.',
    source: 'geo-co-q3',
  ),
  IndexRound(
    subject: 'where the memory comes from',
    asked:
        'How does a clay come to remember a pressure larger than the one it '
        'carries now?',
    squeeze: _overconsolidated,
    options: [
      'Ground above it was taken away, or it dried out, or ice sat on it',
      'It was compacted when it was placed',
      'The water table rose over it',
      'It cannot: the memory is always what it carries now',
    ],
    answer: 0,
    why:
        'Something once pressed harder and then left. Glaciers are the '
        'classic case, along with erosion of the ground above and drying, '
        'which shrinks a clay as fiercely as a load would. Such a clay is '
        'overconsolidated, and it will take a surprising amount of new load '
        'before it starts settling in earnest.',
    source: 'geo-co-q3',
  ),
  IndexRound(
    subject: 'a normally consolidated clay',
    asked:
        'This clay has never carried more than it carries now. Which part of '
        'the curve is it sitting on?',
    squeeze: _normally,
    options: [
      'The steep part: it is on its virgin line already',
      'The shallow part, with room to spare',
      'The corner exactly',
      'Neither: the curve does not apply to it',
    ],
    answer: 0,
    why:
        'On the virgin line, at the corner and about to go down the steep '
        'side. It has no stiff stretch left to spend, so every pound added '
        'settles it on the soft index. Young deposits and recent fills are '
        'like this, and they are the ones that go on settling for years.',
    source: 'geo-co-q1',
  ),
  IndexRound(
    subject: 'what the settlement depends on',
    asked:
        'Two identical clays are loaded from 800 to 1,200 pounds a square '
        'foot. One remembers 3,000 and the other has never carried more than '
        '800. What differs?',
    squeeze: _overconsolidated,
    options: [
      'The second settles several times as much, on the same load',
      'They settle the same: the load is the same',
      'The first settles more, being older',
      'Nothing can be said without the void ratios',
    ],
    answer: 0,
    why:
        'The second settles several times as much. Same thickness, same void '
        'ratio, same load, and a completely different answer, because one is '
        'moving over ground it has covered and the other is breaking new. '
        'The load alone never tells you how much a clay will settle.',
    source: 'geo-co-q1',
  ),
  IndexRound(
    subject: 'the log in the formula',
    asked:
        'Every settlement formula in the lesson takes the LOG of the stress '
        'ratio. What does that say about the second half of a load?',
    squeeze: _normally,
    options: [
      'Doubling the stress again settles as much as doubling it the first '
          'time',
      'The second half settles twice as much as the first',
      'Settlement stops once the stress has doubled',
      'The log is only a convenience and has no meaning',
    ],
    answer: 0,
    why:
        'Equal RATIOS give equal settlement: 1,000 to 2,000 settles as much '
        'as 2,000 to 4,000. So the first few hundred pounds on a lightly '
        'loaded clay matter far more than the same few hundred added later, '
        'which is why soft shallow ground is where the trouble is.',
    source: 'geo-co-q1',
  ),
];

class _StiffUntilItRemembersGameState
    extends State<StiffUntilItRemembersGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'stiff-until-it-remembers',
    chapterId: 'geotechnical',
    total: indexRounds.length,
    sourceProblemIdOf: (round) => indexRounds[round].source,
  )..addListener(_onSession);

  int? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  IndexRound get _round => indexRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Stiff Until It Remembers',
        closing:
            'The corner in the curve is the largest pressure the clay has '
            'ever carried. Under it the clay is stiff, on an index about a '
            'sixth of the other, because it is only going back over ground it '
            'has covered. Past it the grains rearrange in earnest. A memory '
            'comes from ground that was removed, or ice, or drying. And the '
            'log in the formula means equal ratios settle equally, so the '
            'first few hundred pounds on a soft clay are the expensive ones.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: memoryBrief,
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
            'THE TWO SLOPES',
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
            height: 210,
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
                      ElogPPainter(squeeze: r.squeeze, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$C_r \approx C_c / 6$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < r.options.length; i++) ...[
            _Choice(
              label: r.options[i],
              selected: _picked == i,
              locked: answered,
              isTruth: r.answer == i,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            if (i != r.options.length - 1) const SizedBox(height: 8),
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
