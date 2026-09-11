import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'channel_figures.dart';

/// Which Number Goes In Front — the third item for `open-channel-flow`.
///
/// The lesson calls the 1.486 factor the single most common trap on
/// Manning's problems, and it is the only place in the equation where the
/// unit system shows up at all: n is dimensionless and so is the slope.
/// Deciding it takes one look at the lengths on the drawing, which is a
/// thing a phone can ask and a calculator cannot help with. The wrinkle
/// worth drilling is the drawing dimensioned in inches or millimeters,
/// where the honest answer is that nothing goes in front yet.
class WhichNumberGoesInFrontGame extends StatefulWidget {
  const WhichNumberGoesInFrontGame({super.key});

  @override
  State<WhichNumberGoesInFrontGame> createState() =>
      _WhichNumberGoesInFrontGameState();
}

/// What belongs in front of Manning's for the drawing on the screen.
enum Kay { usCustomary, si, notYet }

extension KayWords on Kay {
  String get plain => switch (this) {
        Kay.usCustomary => 'K = 1.486',
        Kay.si => 'K = 1.0',
        Kay.notYet => 'Neither yet: fix the lengths first',
      };
}

@immutable
class KayRound {
  const KayRound({
    required this.subject,
    required this.setting,
    required this.channel,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Channel channel;
  final String why;
  final String source;

  /// Read off the drawing's own dimensions. Feet take 1.486, meters take
  /// 1.0, and anything else is not a length Manning's will accept.
  Kay get answer {
    if (!channel.readyToUse) return Kay.notYet;
    return channel.unit == 'm' ? Kay.si : Kay.usCustomary;
  }
}

const kayRounds = <KayRound>[
  KayRound(
    subject: 'the lesson\'s own channel',
    setting: 'A concrete channel, n 0.013, on a slope of 0.001.',
    channel: Channel(shape: Shaped.rectangle, width: 4, depth: 2, rim: 0.6),
    why:
        'K = 1.486, because the drawing is in feet. That number is not a '
        'physical constant, it is a unit conversion baked into the formula: '
        'Manning\'s was derived in metric and 1.486 is what a cubic meter per '
        'second becomes in feet. Leave it out on a US problem and every answer '
        'comes out a third too small, which is the 19.5 against 28.9 in the '
        'lesson.',
    source: 'wr-ocf-q1',
  ),
  KayRound(
    subject: 'a storm sewer on a metric job',
    setting: 'A concrete pipe running full, n 0.015, on a slope of 0.002.',
    channel: Channel(shape: Shaped.circle, width: 0.9, depth: 0.9, unit: 'm'),
    why:
        'K = 1.0, because the drawing is in meters, which is to say there is '
        'no conversion to make. Putting 1.486 in here would inflate the '
        'discharge by 49 percent. The n value does not change between the two '
        'systems: roughness is dimensionless, and 0.015 is 0.015 whichever '
        'set of units the pipe is drawn in.',
    source: 'wr-ocf-q2',
  ),
  KayRound(
    subject: 'a pipe called out in inches',
    setting: 'A 24 inch concrete pipe running full, n 0.013.',
    channel: Channel(shape: Shaped.circle, width: 24, depth: 24, unit: 'in'),
    why:
        'Neither yet. Inches are a US length, so 1.486 is where this ends up, '
        'but not until the 24 inches is 2 feet. Manning\'s takes feet or '
        'meters and nothing else, and a diameter left in inches runs through '
        'the arithmetic without complaining and gives an answer that is '
        'wrong by a factor of twelve to the eight thirds. Pipe sizes are '
        'quoted in inches almost everywhere, so this is a real habit, not a '
        'trick question.',
    source: 'wr-ocf-q2',
  ),
  KayRound(
    subject: 'a drainage channel dimensioned in millimeters',
    setting: 'An earth channel with sloped sides, n 0.022.',
    channel: Channel(
        shape: Shaped.trapezoid,
        width: 2500,
        depth: 900,
        sideRun: 1.5,
        rim: 400,
        unit: 'mm'),
    why:
        'Neither yet. Millimeters are metric, so this one lands on 1.0, but '
        'only after 2,500 millimeters becomes 2.5 meters. The mistake to '
        'watch is reaching for the constant the moment you recognize the unit '
        'system: what the equation needs first is a length it accepts.',
    source: 'wr-ocf-q1',
  ),
  KayRound(
    subject: 'a US drawing, an answer wanted in SI',
    setting:
        'A concrete channel, n 0.013, slope 0.002, and the report wants the '
        'discharge in cubic meters per second.',
    channel: Channel(shape: Shaped.rectangle, width: 6, depth: 3, rim: 0.8),
    why:
        'K = 1.486. What decides the constant is the units the LENGTHS are '
        'in, which here is feet, and the units the answer is reported in have '
        'nothing to do with it. Work the equation in feet, get cubic feet per '
        'second, and convert once at the end. Switching the constant to get '
        'metric out of a US drawing is not a conversion, it is a mistake '
        'dressed as one.',
    source: 'wr-ocf-q1',
  ),
  KayRound(
    subject: 'a metric channel, slope given as a percentage',
    setting: 'An earth channel, n 0.025, on a grade of 0.2 percent.',
    channel: Channel(
        shape: Shaped.trapezoid,
        width: 3,
        depth: 1.2,
        sideRun: 2,
        rim: 0.5,
        unit: 'm'),
    why:
        'K = 1.0, from the meters on the drawing. The 0.2 percent does need '
        'writing as 0.002 before it goes in, but that is true in both systems: '
        'a slope is a rise over a run, so it has no units at all and cannot '
        'tell you anything about which constant to use. Only the lengths can.',
    source: 'wr-ocf-q2',
  ),
];

class _WhichNumberGoesInFrontGameState
    extends State<WhichNumberGoesInFrontGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-number-goes-in-front',
    chapterId: 'water-resources',
    total: kayRounds.length,
    sourceProblemIdOf: (round) => kayRounds[round].source,
  )..addListener(_onSession);

  Kay? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  KayRound get _round => kayRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Number Goes In Front',
        closing:
            'The constant is the only place the unit system appears in '
            'Manning\'s equation. Feet take 1.486, meters take 1.0, and the '
            'lengths on the drawing are what decide it: not the roughness, '
            'which is dimensionless, not the slope, which is dimensionless '
            'too, and not the units somebody wants the answer reported in. '
            'Inches and millimeters are not lengths the equation accepts, so '
            'they get fixed before anything goes in front of it.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: unitFactorBrief,
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
            'WHAT GOES IN FRONT OF MANNING\'S',
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
                  painter: SectionPainter(channel: r.channel),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$Q = \dfrac{K}{n} A R_H^{2/3} S^{1/2}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Kay.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Kay.values.last) const SizedBox(height: 8),
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
