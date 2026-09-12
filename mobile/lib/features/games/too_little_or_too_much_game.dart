import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'rc_figures.dart';

/// Too Little or Too Much — the second item for `rc-columns`.
///
/// The steel ratio in a column has a window round it, one per cent at the
/// bottom and eight at the top, and both ends are there for a reason worth
/// knowing rather than memorizing. Too little steel and the column behaves
/// like plain concrete the moment any bending arrives, which is to say it
/// fails without notice. Too much and there is no room left to place the
/// bars, lap them or get concrete down between them.
class TooLittleOrTooMuchGame extends StatefulWidget {
  const TooLittleOrTooMuchGame({super.key});

  @override
  State<TooLittleOrTooMuchGame> createState() =>
      _TooLittleOrTooMuchGameState();
}

/// Where a column sits against the window the code puts round its steel.
enum Window { under, inside, over }

@immutable
class RatioRound {
  const RatioRound({
    required this.subject,
    required this.asked,
    required this.cage,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Cage cage;
  final Window answer;
  final String why;
  final String source;

  static String label(Window which) => switch (which) {
        Window.under => 'Under the one per cent minimum',
        Window.inside => 'Inside the window, which is what is wanted',
        Window.over => 'Over the eight per cent maximum',
      };
}

const windowRounds = <RatioRound>[
  RatioRound(
    subject: 'the lesson\'s own column',
    asked:
        'An 18 inch square column with four number eight bars in it, which '
        'works out at 0.98 per cent. Where does that leave it?',
    cage: Cage(width: 18, depth: 18, bars: 4, barArea: 0.79),
    answer: Window.under,
    why:
        'Under the minimum, and only just, which is the point of the '
        'question. The window is not a guideline: 0.98 per cent is short of '
        'one per cent and the column has to be redrawn with more steel or '
        'bigger bars. A number this close is easy to wave through, and on the '
        'exam it is usually there because somebody wanted it waved through.',
    source: 'str-rcc-q2',
  ),
  RatioRound(
    subject: 'a working column',
    asked:
        'A 14 by 20 inch column with six bars totalling six square inches, '
        'which is about 2.1 per cent. And this one?',
    cage: Cage(width: 14, depth: 20, bars: 6, barArea: 1.0),
    answer: Window.inside,
    why:
        'Inside, and comfortably: around two per cent is where most real '
        'columns sit. Low enough that the bars can be placed and lapped '
        'without a fight, high enough that the column has real bending '
        'capacity and plenty of warning in it. When a design lands here, the '
        'ratio is not the thing to worry about.',
    source: 'str-rcc-q3',
  ),
  RatioRound(
    subject: 'a crowded cage',
    asked:
        'A 12 inch square column with twelve number nine bars in it, which '
        'comes to over eight per cent. What now?',
    cage: Cage(width: 12, depth: 12, bars: 12, barArea: 1.0),
    answer: Window.over,
    why:
        'Over the top of the window, and the drawing shows why: there is '
        'barely concrete between the bars. Steel that cannot be lapped, or '
        'that leaves no room for a vibrator to get down past it, is steel '
        'that will not do what the calculation assumed. The fix is a bigger '
        'column, not more bars.',
    source: 'str-rcc-q2',
  ),
  RatioRound(
    subject: 'exactly on the line',
    asked:
        'A column works out at exactly one per cent. Is that allowed?',
    cage: Cage(width: 20, depth: 20, bars: 4, barArea: 1.0),
    answer: Window.inside,
    why:
        'Yes: the limits are inclusive, so exactly one per cent is inside the '
        'window rather than under it. Worth knowing because an exam will '
        'occasionally land a number right on a limit to see whether you know '
        'which way it falls. It is a floor to stand on, not a floor to fall '
        'through.',
    source: 'str-rcc-q2',
  ),
  RatioRound(
    subject: 'a generous section',
    asked:
        'A 24 inch square column with eight number nine bars, around 1.4 per '
        'cent. Where does it sit?',
    cage: Cage(width: 24, depth: 24, bars: 8, barArea: 1.0),
    answer: Window.inside,
    why:
        'Inside, near the bottom of the window. The same eight bars that gave '
        'a 16 inch column over three per cent give a 24 inch column less than '
        'half of that, because the gross area grows with the SQUARE of the '
        'size while the steel does not. Growing a column is a fast way to '
        'drift toward the minimum without changing a single bar.',
    source: 'str-rcc-q1',
  ),
  RatioRound(
    subject: 'the lesson\'s first column',
    asked:
        'The 16 inch square column from the capacity problem, with eight '
        'number nine bars, about 3.1 per cent. Where does it sit?',
    cage: Cage(width: 16, depth: 16, bars: 8, barArea: 1.0),
    answer: Window.inside,
    why:
        'Inside, a little above the middle of the window, which is why that '
        'problem never mentions the ratio: it is a perfectly ordinary column. '
        'Still worth the check. The ratio is the first thing to look at on a '
        'column question, because if it fails the window, the capacity you '
        'were about to work out is not a capacity anybody may use.',
    source: 'str-rcc-q1',
  ),
];

class _TooLittleOrTooMuchGameState extends State<TooLittleOrTooMuchGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'too-little-or-too-much',
    chapterId: 'structural',
    total: windowRounds.length,
    sourceProblemIdOf: (round) => windowRounds[round].source,
  )..addListener(_onSession);

  Window? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  RatioRound get _round => windowRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Too Little or Too Much',
        closing:
            'One per cent to eight, and both limits are inclusive. Under the '
            'bottom the column behaves like plain concrete as soon as any '
            'bending arrives, which means failing without warning. Over the '
            'top there is no room to place the bars, lap them, or get '
            'concrete down between them. Check the window first: a capacity '
            'worked out for a column outside it is not a capacity anybody may '
            'use.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: steelWindowBrief,
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
            'AGAINST THE WINDOW',
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
            height: 192,
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
                  painter: CagePainter(cage: r.cage, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$0.01 \le \rho_g = \frac{A_{st}}{A_g} \le 0.08$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Window.values) ...[
            _Choice(
              label: RatioRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Window.values.last) const SizedBox(height: 8),
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
