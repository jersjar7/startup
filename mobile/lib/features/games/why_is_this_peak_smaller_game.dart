import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'hydrograph_figures.dart';

/// Why Is This Peak Smaller — the second item for `hydrograph-watershed`.
///
/// The Rational Method's design storm lasts exactly as long as the time of
/// concentration, and that is not a convention: it is where the peak is
/// largest. A shorter storm is more intense but never gets the whole
/// watershed contributing at once. A longer one has the whole watershed but
/// at a gentler intensity. Both fall short of the design case, and for
/// opposite reasons, which is what makes the question worth asking.
class WhyIsThisPeakSmallerGame extends StatefulWidget {
  const WhyIsThisPeakSmallerGame({super.key});

  @override
  State<WhyIsThisPeakSmallerGame> createState() =>
      _WhyIsThisPeakSmallerGameState();
}

/// Why this storm does not give the design peak, if it does not.
enum Falls { itIsTheDesign, tooShort, tooLong }

extension FallsWords on Falls {
  String get plain => switch (this) {
        Falls.itIsTheDesign =>
          'It is not smaller: this is the design storm',
        Falls.tooShort =>
          'Too short: the far ground has not reported in yet',
        Falls.tooLong =>
          'Too long: the intensity for that duration is lower',
      };
}

@immutable
class BasinRound {
  const BasinRound({
    required this.subject,
    required this.setting,
    required this.basin,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Basin basin;
  final String why;
  final String source;

  /// Read off the two durations, never declared.
  Falls get answer {
    if (basin.tooShort) return Falls.tooShort;
    if (basin.tooLong) return Falls.tooLong;
    return Falls.itIsTheDesign;
  }
}

const basinRounds = <BasinRound>[
  BasinRound(
    subject: 'the lesson\'s own watershed',
    setting:
        'A hundred acre watershed where water from the far corner takes 30 '
        'minutes to reach the outlet. The storm lasts 30 minutes.',
    basin: Basin(travelTime: 30, stormMinutes: 30),
    why:
        'This is the design storm. At exactly the time of concentration the '
        'last of the watershed starts contributing at the same moment the '
        'storm is still going, so the whole area is delivering at once. Any '
        'other duration gives a smaller peak, which is why the Rational '
        'Method is always run at the time of concentration rather than at '
        'some convenient round number.',
    source: 'wr-hw-q2',
  ),
  BasinRound(
    subject: 'a cloudburst',
    setting:
        'The same watershed, 30 minutes to the outlet from the far corner. '
        'This storm is a ten minute cloudburst, far more intense.',
    basin: Basin(travelTime: 30, stormMinutes: 10),
    why:
        'Too short. Ten minutes in, only the ground within ten minutes of '
        'the outlet is contributing, about a third of the watershed, and then '
        'the rain stops. The intensity is higher, which is what makes this '
        'tempting, but it is being applied to a third of the area. Intensity '
        'up and area down, and the area loses.',
    source: 'wr-hw-q2',
  ),
  BasinRound(
    subject: 'an afternoon of rain',
    setting:
        'The same watershed. This storm lasts two hours.',
    basin: Basin(travelTime: 30, stormMinutes: 120),
    why:
        'Too long. The whole watershed is contributing, which is the good '
        'news, but the intensity you may use is the two hour intensity off '
        'the IDF curve, and that is a great deal lower than the thirty minute '
        'one. Rain that lasts is rain that falls gently: the curves say so '
        'and the peak follows.',
    source: 'wr-hw-q2',
  ),
  BasinRound(
    subject: 'a slow catchment',
    setting:
        'A long flat catchment where the far corner takes 90 minutes to '
        'drain. The storm lasts 90 minutes.',
    basin: Basin(travelTime: 90, stormMinutes: 90),
    why:
        'The design storm again, and note how much gentler it is. A slow '
        'catchment has to be designed on a long storm, and long storms are '
        'not intense, so a big flat watershed can have a surprisingly modest '
        'peak per acre. The time of concentration is doing more work in this '
        'method than anything except the area.',
    source: 'wr-hw-q2',
  ),
  BasinRound(
    subject: 'a short burst on the slow catchment',
    setting:
        'The same 90 minute catchment, hit by a 20 minute storm.',
    basin: Basin(travelTime: 90, stormMinutes: 20),
    why:
        'Too short, and badly: barely a fifth of the catchment is in play. '
        'On a slow catchment the short intense storms that dominate small '
        'urban sites hardly matter, because most of the ground never gets a '
        'chance to contribute before the rain is over.',
    source: 'wr-hw-q2',
  ),
  BasinRound(
    subject: 'a quick catchment in a long storm',
    setting:
        'A small paved site where everything reaches the inlet in 8 minutes. '
        'The storm lasts 45 minutes.',
    basin: Basin(travelTime: 8, stormMinutes: 45),
    why:
        'Too long. This site is fully contributing after eight minutes and '
        'stays that way, so the extra thirty seven minutes of rain add '
        'nothing to the peak: they only mean the intensity quoted for a 45 '
        'minute storm is far below the eight minute one. Small paved sites '
        'are designed on short, sharp storms for exactly this reason.',
    source: 'wr-hw-q2',
  ),
];

class _WhyIsThisPeakSmallerGameState extends State<WhyIsThisPeakSmallerGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'why-is-this-peak-smaller',
    chapterId: 'water-resources',
    total: basinRounds.length,
    sourceProblemIdOf: (round) => basinRounds[round].source,
  )..addListener(_onSession);

  Falls? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  BasinRound get _round => basinRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Why Is This Peak Smaller',
        closing:
            'The Rational Method peaks when the storm lasts exactly as long '
            'as the time of concentration. Shorter, and the far ground never '
            'joins in: high intensity on part of the area. Longer, and the '
            'whole area is in but the intensity for that duration is lower. '
            'Both fall short of the design case, and knowing which reason '
            'applies tells you what to change.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: concentrationBrief,
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
            'AGAINST THE DESIGN PEAK, WHY',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            '${r.setting} The bands are ground that drains to the outlet in '
            'the same time, and the filled ones are contributing when the '
            'rain stops.',
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
                  painter: BasinPainter(basin: r.basin),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\text{design storm} : D = t_c$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Falls.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Falls.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE REASON' : 'THE OTHER REASON',
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
