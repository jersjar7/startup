import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Does It Go Up — the third item for `wood-masonry`.
///
/// Wood design is a reference value multiplied by a string of factors, and
/// the exam question about them is never the arithmetic. It is the direction:
/// a load that comes and goes quickly lets wood carry MORE, which is the one
/// that surprises people, while wet service, heat and sheer size take
/// capacity away. Each round is one condition, and the answer is which way it
/// pushes.
class DoesItGoUpGame extends StatefulWidget {
  const DoesItGoUpGame({super.key});

  @override
  State<DoesItGoUpGame> createState() => _DoesItGoUpGameState();
}

/// Which way a factor moves the allowable stress.
enum Moves2 { up, down, flat }

extension PushWords on Moves2 {
  String get plain => switch (this) {
        Moves2.up => 'Up: the factor is bigger than one',
        Moves2.down => 'Down: the factor is smaller than one',
        Moves2.flat => 'Neither: the factor is one',
      };
}

@immutable
class FactorRound {
  const FactorRound({
    required this.subject,
    required this.setting,
    required this.factor,
    required this.value,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;

  /// The factor's symbol, as the code writes it.
  final String factor;

  /// What it is worth in this case.
  final String value;
  final Moves2 answer;
  final String why;
  final String source;
}

const ndsRounds = <FactorRound>[
  FactorRound(
    subject: 'a gust on a roof',
    setting:
        'A sawn lumber beam takes a wind load, which is on it for seconds at '
        'a time.',
    factor: r'$C_D$',
    value: '1.6',
    answer: Moves2.up,
    why:
        'Up, and by a lot: the load duration factor is 1.6 for wind or '
        'seismic. Wood carries more stress the more briefly it is asked to, '
        'which is the direction people get backwards. A member that would '
        'fail under a permanent load of that size is fine under a gust, and '
        'this factor is how the code says so.',
    source: 'mat-wm-q3',
  ),
  FactorRound(
    subject: 'the weight of the building itself',
    setting:
        'The same beam carrying nothing but permanent dead load, for the '
        'whole life of the structure.',
    factor: r'$C_D$',
    value: '0.9',
    answer: Moves2.down,
    why:
        'Down. The same factor goes below one for a load that never comes '
        'off: 0.9 for permanent. Wood creeps and loses capacity under a load '
        'it has to hold forever, so the longest duration carries the harshest '
        'factor. One factor, both directions, decided entirely by how long '
        'the load sits there.',
    source: 'mat-wm-q3',
  ),
  FactorRound(
    subject: 'a ten year load',
    setting:
        'The beam under normal occupancy loading, which the code takes as the '
        'ten year reference case.',
    factor: r'$C_D$',
    value: '1.0',
    answer: Moves2.flat,
    why:
        'Neither. Normal occupancy is the case the published reference values '
        'were quoted for, so the factor is exactly one. Everything else on '
        'the list is measured against this: quicker than this and it goes up, '
        'longer and it goes down.',
    source: 'mat-wm-q3',
  ),
  FactorRound(
    subject: 'a joist over a damp crawl space',
    setting:
        'The joist will sit above the fiber saturation point for much of the '
        'year.',
    factor: r'$C_M$',
    value: 'less than 1.0',
    answer: Moves2.down,
    why:
        'Down. Wet service takes capacity away, which is the same fact the '
        'moisture item is about seen from the code side: water back in the '
        'cell walls is a weaker, softer timber. The published values assume '
        'dry service, so wet conditions are a penalty rather than the other '
        'way round.',
    source: 'mat-wm-q3',
  ),
  FactorRound(
    subject: 'a member in a hot roof space',
    setting:
        'The timber runs at sustained high temperature under a dark roof.',
    factor: r'$C_t$',
    value: 'less than 1.0',
    answer: Moves2.down,
    why:
        'Down. Sustained heat costs wood strength, so the temperature factor '
        'is a penalty too. Almost every factor on the list is a penalty: the '
        'load duration factor is the one that regularly goes above one, which '
        'is why it is the one the exam asks about.',
    source: 'mat-wm-q3',
  ),
  FactorRound(
    subject: 'a week of construction load',
    setting:
        'The beam is propping a temporary deck for seven days during the '
        'build.',
    factor: r'$C_D$',
    value: '1.25',
    answer: Moves2.up,
    why:
        'Up, though not as far as wind: 1.25 for a seven day load. The whole '
        'ladder runs the same way, from 0.9 for permanent through 1.0 for '
        'normal and 1.15 for two months up to 1.6 for wind and seismic. '
        'Shorter is always higher.',
    source: 'mat-wm-q3',
  ),
];

class _DoesItGoUpGameState extends State<DoesItGoUpGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'does-it-go-up',
    chapterId: 'materials',
    total: ndsRounds.length,
    sourceProblemIdOf: (round) => ndsRounds[round].source,
  )..addListener(_onSession);

  Moves2? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  FactorRound get _round => ndsRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Does It Go Up',
        closing:
            'Wood design is a reference value times a string of factors, and '
            'nearly all of them are penalties: wet service, heat, size. The '
            'load duration factor is the exception and the one worth knowing '
            'cold. The quicker the load comes and goes, the more wood will '
            'carry: 1.6 for wind, 1.25 for a week, 1.0 for normal occupancy, '
            'and 0.9 for a load that never comes off.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: factorBrief,
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
            'WHICH WAY DOES THIS FACTOR PUSH',
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
          const SizedBox(height: 16),
          Center(
            child: MathText(
              r'$F\prime = F \times C_D \times C_M \times C_t \times \dots$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'the factor here is ',
                  style: AppTheme.mono(size: 12.5, color: AppColors.ink3),
                ),
                MathText(
                  r.factor,
                  style:
                      const TextStyle(fontSize: 16, color: AppColors.charcoal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final option in Moves2.values) ...[
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
              title: _session.correct!
                  ? 'THAT IS THE WAY, ${r.value.toUpperCase()}'
                  : 'THE OTHER WAY',
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
