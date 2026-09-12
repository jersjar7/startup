import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'load_figures.dart';

/// Which One Controls — the second item for `load-combinations`.
///
/// Working all three combinations out is arithmetic and belongs on paper.
/// What decides the answer before any of it is the SHAPE of the loading:
/// floor live load big next to everything else and combination 2 wins, roof
/// load big and combination 3 does, almost nothing but dead load and the
/// lonely 1.4 beats them both. Each round shows the service loads as bars and
/// asks which combination the picture is pointing at.
class WhichOneControlsGame extends StatefulWidget {
  const WhichOneControlsGame({super.key});

  @override
  State<WhichOneControlsGame> createState() => _WhichOneControlsGameState();
}

@immutable
class ControlRound {
  const ControlRound({
    required this.subject,
    required this.asked,
    required this.bundle,
    required this.unit,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Bundle bundle;
  final String unit;
  final String why;
  final String source;

  /// Never written down: the loads decide it, so a round cannot disagree
  /// with its own numbers.
  Combo get answer => bundle.controls;

  static String label(Combo which) => switch (which) {
        Combo.one => 'Combination 1: 1.4D',
        Combo.two => 'Combination 2: 1.2D + 1.6L + 0.5S',
        Combo.three => 'Combination 3: 1.2D + 1.6S + L',
      };
}

const controlRounds = <ControlRound>[
  ControlRound(
    subject: 'the lesson\'s own beam',
    asked:
        'A beam with dead and floor live load on it and nothing else. Which '
        'combination has to be designed for?',
    bundle: Bundle(dead: 20, live: 40),
    unit: 'kips',
    why:
        'Combination 2. The floor live load is the biggest thing on the beam '
        'and it is the one that gets the 1.6, so the sum runs away from the '
        'others. This is the ordinary gravity case and combination 2 wins it '
        'almost every time, which is exactly why it is worth knowing when it '
        'does not.',
    source: 'str-lc-q1',
  ),
  ControlRound(
    subject: 'the lesson\'s own column',
    asked:
        'A column carrying dead load, floor live load and snow. No wind, no '
        'earthquake. Which combination controls?',
    bundle: Bundle(dead: 30, live: 50, snow: 20),
    unit: 'kips',
    why:
        'Combination 2 again. The floor live load is well clear of the snow, '
        'so putting 1.6 on the live load and only half the snow beats putting '
        '1.6 on the snow and the live load at its face value. Notice that '
        'snow does not disappear from combination 2, it comes along at half '
        'strength, and forgetting that companion term is a common way to lose '
        'a few kips.',
    source: 'str-lc-q2',
  ),
  ControlRound(
    subject: 'a roof in heavy snow country',
    asked:
        'A column under a roof where the snow load is much the largest thing '
        'on it. Which combination controls?',
    bundle: Bundle(dead: 30, live: 10, snow: 60),
    unit: 'kips',
    why:
        'Combination 3, and this is the case the lesson warns about. The 1.6 '
        'follows whichever of the two is bigger: combination 3 is the one '
        'that puts it on the snow and lets the floor live load in at its full '
        'value beside it. Reaching for combination 2 out of habit here '
        'understates the load badly.',
    source: 'str-lc-q2',
  ),
  ControlRound(
    subject: 'a heavy floor with nothing on it yet',
    asked:
        'A transfer girder carrying a great deal of dead load and almost no '
        'live load. Which combination controls?',
    bundle: Bundle(dead: 100, live: 5),
    unit: 'kips',
    why:
        'Combination 1, the lonely 1.4D. With hardly any live load for the '
        '1.6 to work on, the extra two tenths that combination 1 puts on a '
        'very large dead load is worth more than anything combination 2 can '
        'add. This is the whole reason combination 1 exists, and the only '
        'time it is the one that matters.',
    source: 'str-lc-q2',
  ),
  ControlRound(
    subject: 'a roof with no floor under it',
    asked:
        'A roof beam: dead load, snow, and no floor live load at all. Which '
        'combination controls?',
    bundle: Bundle(dead: 30, live: 0, snow: 40),
    unit: 'kips',
    why:
        'Combination 3. With no floor live load in the picture, combination 2 '
        'has nothing to put its 1.6 on and takes the snow at half, while '
        'combination 3 takes the snow at 1.6. The winner is whichever '
        'combination points its big factor at the load that is actually '
        'there.',
    source: 'str-lc-q2',
  ),
  ControlRound(
    subject: 'a plain floor beam',
    asked:
        'A floor beam in an office: a moderate dead load and a live load '
        'rather larger than it. Which combination controls?',
    bundle: Bundle(dead: 25, live: 45),
    unit: 'kips',
    why:
        'Combination 2, for the same reason as the first round: the live load '
        'is the big one and combination 2 is the one that multiplies it by '
        '1.6. Once the shape of the loading is read off, the arithmetic only '
        'confirms what the bars already say. That is the habit worth having '
        'under exam time.',
    source: 'str-lc-q1',
  ),
];

class _WhichOneControlsGameState extends State<WhichOneControlsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-one-controls',
    chapterId: 'structural',
    total: controlRounds.length,
    sourceProblemIdOf: (round) => controlRounds[round].source,
  )..addListener(_onSession);

  Combo? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ControlRound get _round => controlRounds[_session.round];

  /// How many service loads the figure will draw, which decides how tall the
  /// panel has to be.
  static int _rows(Bundle b) =>
      2 + (b.snow > 0 ? 1 : 0) + (b.roofLive > 0 ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which One Controls',
        closing:
            'The big factor follows the big load. Floor live load ahead of '
            'the roof load and combination 2 wins; roof load ahead of the '
            'floor and combination 3 does; hardly any live load at all and '
            'the lonely 1.4 on the dead load beats them both. Read the shape '
            'of the loading first and the arithmetic is only there to confirm '
            'it.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: controlsBrief,
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
            'WHICH COMBINATION WINS',
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
            height: answered
                ? 90.0 + 20 * (_rows(r.bundle) + 3)
                : 40.0 + 20 * _rows(r.bundle),
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
                  painter: LoadBarPainter(
                    bundle: r.bundle,
                    unit: r.unit,
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
              r'$\text{the largest total is the one you design for}$',
              style: const TextStyle(fontSize: 13, color: AppColors.ink3),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Combo.values) ...[
            _Choice(
              label: ControlRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Combo.values.last) const SizedBox(height: 8),
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
