import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'earthwork_figures.dart';

/// Can You Skip a Section — the second item for `earthwork-volumes`.
///
/// The average end area formula takes two sections and the distance between
/// them, and nothing in it objects if those two sections are a thousand feet
/// apart with a hill in between. That is the lesson's own third trap, and
/// the lesson's own numbers make it vivid: a run that starts at nothing,
/// rises to 400 square feet and closes back to nothing gives 40,000 cubic
/// feet worked properly and exactly ZERO worked end to end. The rule is that
/// the formula is honest between any two sections where the section runs
/// straight from one to the other, and blind everywhere else.
class CanYouSkipASectionGame extends StatefulWidget {
  const CanYouSkipASectionGame({super.key});

  @override
  State<CanYouSkipASectionGame> createState() =>
      _CanYouSkipASectionGameState();
}

/// What working end to end does to the answer.
enum Skipped { same, tooSmall, tooBig }

extension SkippedWords on Skipped {
  String get plain => switch (this) {
        Skipped.same => 'Nothing: the same answer',
        Skipped.tooSmall => 'It comes out too small',
        Skipped.tooBig => 'It comes out too big',
      };
}

@immutable
class SkipRound {
  const SkipRound({
    required this.subject,
    required this.setting,
    required this.haul,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Haul haul;
  final String why;
  final String source;

  /// Worked out from the two ways of adding it up, never declared.
  Skipped get answer {
    final gap = haul.endToEnd - haul.byEndAreas;
    if (gap.abs() < 1) return Skipped.same;
    return gap > 0 ? Skipped.tooBig : Skipped.tooSmall;
  }
}

const skipRounds = <SkipRound>[
  SkipRound(
    subject: 'the lesson\'s own run',
    setting:
        'Nothing at 0+00, 400 square feet at 1+00, nothing again at 2+00. '
        'What happens if the end area formula is used once across the whole '
        'run instead of station by station?',
    haul: Haul(slabs: [
      Slab(station: 0, area: 0),
      Slab(station: 100, area: 400),
      Slab(station: 200, area: 0),
    ]),
    why:
        'Far too small: it gives exactly nothing. Both end sections are '
        'zero, so their average is zero, and the formula reports no dirt at '
        'all where there are 40,000 cubic feet of it. This is the most '
        'useful wrong answer in the lesson, because nobody argues with it '
        'once they have seen it.',
    source: 'surv-ev-q3',
  ),
  SkipRound(
    subject: 'a section opening out evenly',
    setting:
        'Nothing at 0+00, 200 at 1+00, 400 at 2+00. Worked end to end '
        'instead of station by station.',
    haul: Haul(slabs: [
      Slab(station: 0, area: 0),
      Slab(station: 100, area: 200),
      Slab(station: 200, area: 400),
    ]),
    why:
        'Nothing: 40,000 either way. Where the section grows evenly from one '
        'end to the other, the middle measurement adds no information the '
        'ends did not already carry, and the end area method is exact. This '
        'is the case the formula was built for, and the reason it survives '
        'in practice.',
    source: 'surv-ev-q3',
  ),
  SkipRound(
    subject: 'a saddle between two cuts',
    setting: '400 at 0+00, 100 at 1+00, 400 at 2+00, worked end to end.',
    haul: Haul(slabs: [
      Slab(station: 0, area: 400),
      Slab(station: 100, area: 100),
      Slab(station: 200, area: 400),
    ]),
    why:
        'Too big: 80,000 against 50,000. The ends are the deepest part of '
        'this run and working from them alone assumes the cut stays deep all '
        'the way through, when it shallows out to a quarter in the middle. '
        'Skipping sections does not always underestimate. It reports '
        'whatever the two ends happen to suggest.',
    source: 'surv-ev-q3',
  ),
  SkipRound(
    subject: 'a hump between two shallow ends',
    setting: '100 at 0+00, 500 at 1+00, 100 at 2+00, worked end to end.',
    haul: Haul(slabs: [
      Slab(station: 0, area: 100),
      Slab(station: 100, area: 500),
      Slab(station: 200, area: 100),
    ]),
    why:
        'Too small: 20,000 against 60,000, so two thirds of the dirt goes '
        'unbooked. On a pay quantity that is the contractor moving material '
        'nobody is paying for. The middle section is the only one that knows '
        'about the hump.',
    source: 'surv-ev-q3',
  ),
  SkipRound(
    subject: 'four stations up an even grade',
    setting:
        'Nothing, 100, 200 and 300 square feet at hundred foot stations, '
        'worked end to end.',
    haul: Haul(slabs: [
      Slab(station: 0, area: 0),
      Slab(station: 100, area: 100),
      Slab(station: 200, area: 200),
      Slab(station: 300, area: 300),
    ]),
    why:
        'Nothing: 45,000 either way. However many stations a run has, if the '
        'section climbs evenly through all of them the ends carry the whole '
        'story. Extra sections on an even grade are a check on the survey, '
        'not a change to the volume.',
    source: 'surv-ev-q3',
  ),
  SkipRound(
    subject: 'an embankment with a flat top',
    setting:
        'Nothing at 0+00, 300 at 1+00, 300 at 2+00, nothing at 3+00, worked '
        'end to end.',
    haul: Haul(slabs: [
      Slab(station: 0, area: 0),
      Slab(station: 100, area: 300),
      Slab(station: 200, area: 300),
      Slab(station: 300, area: 0),
    ]),
    why:
        'Too small, and again the answer is nothing at all. Both ends run '
        'out to zero, so the end to end sum reports an empty job while the '
        'station by station sum gives 60,000. Any run that starts and '
        'finishes at nothing will do this, which covers most embankments and '
        'most borrow pits.',
    source: 'surv-ev-q3',
  ),
];

class _CanYouSkipASectionGameState extends State<CanYouSkipASectionGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'can-you-skip-a-section',
    chapterId: 'surveying',
    total: skipRounds.length,
    sourceProblemIdOf: (round) => skipRounds[round].source,
  )..addListener(_onSession);

  Skipped? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SkipRound get _round => skipRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Can You Skip a Section',
        closing:
            'The end area formula is exact between two sections when the '
            'section runs straight from one to the other, and blind to '
            'anything in between when it does not. A hump goes unbooked, a '
            'saddle gets paid for twice, and a run that starts and finishes '
            'at nothing reports nothing at all. Work it station by station '
            'and add the segments up.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: stationBrief,
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
            'WHAT DOES WORKING END TO END DO',
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
                  painter: HaulPainter(haul: r.haul, skipMiddle: true),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$V = \frac{L}{2}(A_1 + A_2)$, segment by segment',
              style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 14),
          for (final option in Skipped.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 6),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHAT IT DOES' : 'THE OTHER WAY',
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
