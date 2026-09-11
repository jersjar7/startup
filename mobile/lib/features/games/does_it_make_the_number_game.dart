import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'concrete_figures.dart';
import 'lesson_brief.dart';

/// Does It Make the Number — the second item for `concrete-curing-strength`.
///
/// The lesson's hardest problem gives two pours, a lab strength and a curing
/// factor for each, and a strength the slab has to make. Its named trap is not
/// arithmetic: it is comparing the LAB figures to the specification and never
/// applying the curing at all. So the drawing does the multiplying, the bars
/// show what the curing takes off the top, and what is left is what gets
/// compared to the line. Which is the judgment the problem is actually about.
class DoesItMakeTheNumberGame extends StatefulWidget {
  const DoesItMakeTheNumberGame({super.key});

  @override
  State<DoesItMakeTheNumberGame> createState() =>
      _DoesItMakeTheNumberGameState();
}

/// Which of the two pours will make the strength the job needs.
enum Passes { left, right, both, neither }

extension PassesWords on Passes {
  String get plain => switch (this) {
        Passes.left => 'Only the left one',
        Passes.right => 'Only the right one',
        Passes.both => 'Both of them',
        Passes.neither => 'Neither of them',
      };
}

@immutable
class SlabRound {
  const SlabRound({
    required this.subject,
    required this.setting,
    required this.left,
    required this.right,
    required this.needs,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Pour left;
  final Pour right;

  /// The strength the job is specified at, in psi.
  final double needs;
  final String why;
  final String source;

  /// Worked out from the two pours, never declared.
  Passes get answer {
    final a = left.inPlace >= needs;
    final b = right.inPlace >= needs;
    if (a && b) return Passes.both;
    if (a) return Passes.left;
    if (b) return Passes.right;
    return Passes.neither;
  }

  /// The margin the closer of the two is clear by, as a share of what is
  /// needed. A round nobody could call by eye is a round not worth asking.
  double get closest {
    final a = (left.inPlace - needs).abs() / needs;
    final b = (right.inPlace - needs).abs() / needs;
    return a < b ? a : b;
  }
}

const slabRounds = <SlabRound>[
  SlabRound(
    subject: 'the lesson\'s two mixes',
    setting:
        'A structural slab specified at 4,500 psi. Both mixes broke well '
        'above that in the lab.',
    left: Pour(
      name: 'Mix A',
      lab: 5400,
      factor: 0.92,
      curing: '14 days moist',
    ),
    right: Pour(
      name: 'Mix B',
      lab: 4600,
      factor: 0.85,
      curing: '7 days moist',
    ),
    needs: 4500,
    why:
        'Only Mix A. Both lab figures clear 4,500, which is exactly the trap: '
        'the cylinders were cured in a laboratory and the slab will not be. '
        'Mix A keeps about 4,970 and passes. Mix B starts lower and is cured '
        'worse, so it lands near 3,910 and fails by a long way.',
    source: 'mat-ccs-q3',
  ),
  SlabRound(
    subject: 'a well cured job',
    setting:
        'A 3,000 psi footing. Both pours are kept wet under plastic for a '
        'fortnight.',
    left: Pour(
      name: 'north',
      lab: 4200,
      factor: 0.95,
      curing: '14 days moist',
    ),
    right: Pour(
      name: 'south',
      lab: 3800,
      factor: 0.95,
      curing: '14 days moist',
    ),
    needs: 3000,
    why:
        'Both. Good curing costs very little and both mixes had strength in '
        'hand to begin with. Worth noticing what makes this easy: the mixes '
        'were specified well above the requirement, so the curing has room to '
        'take its cut and still leave enough.',
    source: 'mat-ccs-q3',
  ),
  SlabRound(
    subject: 'forms off in a hot week',
    setting:
        'A 4,000 psi slab. Both pours were stripped at three days and left in '
        'hot dry wind with no curing compound.',
    left: Pour(
      name: 'east',
      lab: 5000,
      factor: 0.60,
      curing: '3 days, then dry',
    ),
    right: Pour(
      name: 'west',
      lab: 4800,
      factor: 0.60,
      curing: '3 days, then dry',
    ),
    needs: 4000,
    why:
        'Neither, and this is what the lesson\'s warning looks like on a job. '
        'Concrete that dries out early can be left with something like sixty '
        'percent of what it was capable of, which turns two comfortable mixes '
        'into two failures. The cylinders in the lab will break fine, which '
        'is why the argument on site is always about the cores.',
    source: 'mat-ccs-q2',
  ),
  SlabRound(
    subject: 'the weaker mix, better looked after',
    setting:
        'A 3,500 psi wall. The left pour is a stronger mix cured badly and '
        'the right one a weaker mix cured properly.',
    left: Pour(
      name: 'left',
      lab: 5200,
      factor: 0.60,
      curing: '3 days, then dry',
    ),
    right: Pour(
      name: 'right',
      lab: 4200,
      factor: 0.95,
      curing: '14 days moist',
    ),
    needs: 3500,
    why:
        'Only the right one, though it is the weaker mix on paper. Curing is '
        'not a detail you can trade against the mix design: a thousand psi of '
        'extra cement is worth less than two more weeks of water. This is the '
        'cheapest strength on any concrete job and the first thing dropped '
        'when a schedule tightens.',
    source: 'mat-ccs-q2',
  ),
  SlabRound(
    subject: 'the same mix, two crews',
    setting:
        'A 4,000 psi deck, one truck, two pours. The left crew covered theirs '
        'and the right crew did not.',
    left: Pour(
      name: 'covered',
      lab: 4900,
      factor: 0.93,
      curing: '14 days moist',
    ),
    right: Pour(
      name: 'left dry',
      lab: 4900,
      factor: 0.65,
      curing: '3 days, then dry',
    ),
    needs: 4000,
    why:
        'Only the covered one. Identical concrete out of the same truck, and '
        'the only difference is what happened to it for a fortnight '
        'afterwards. Hydration needs water: stop feeding it and the reaction '
        'stops with it, permanently. Rewetting it later does not bring the '
        'strength back.',
    source: 'mat-ccs-q2',
  ),
  SlabRound(
    subject: 'a specification with no room in it',
    setting:
        'A 4,500 psi slab again. Both mixes are cured to the same standard '
        'this time, and only the mix is different.',
    left: Pour(
      name: 'Mix C',
      lab: 5600,
      factor: 0.90,
      curing: '10 days moist',
    ),
    right: Pour(
      name: 'Mix D',
      lab: 4500,
      factor: 0.90,
      curing: '10 days moist',
    ),
    needs: 4500,
    why:
        'Only Mix C. Mix D was designed to hit the specification exactly, so '
        'it has nothing left to pay the curing with and lands around 4,050. '
        'A mix is chosen ABOVE the number for this reason: the field takes '
        'its cut whatever the drawings say, and a mix with no margin in it is '
        'already short before anybody pours it.',
    source: 'mat-ccs-q3',
  ),
];

class _DoesItMakeTheNumberGameState extends State<DoesItMakeTheNumberGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'does-it-make-the-number',
    chapterId: 'materials',
    total: slabRounds.length,
    sourceProblemIdOf: (round) => slabRounds[round].source,
  )..addListener(_onSession);

  Passes? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SlabRound get _round => slabRounds[_session.round];

  List<bool>? _flags(Passes? which) => switch (which) {
        null => null,
        Passes.left => [true, false],
        Passes.right => [false, true],
        Passes.both => [true, true],
        Passes.neither => [false, false],
      };

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Does It Make the Number',
        closing:
            'The cylinder is cured in a laboratory and the structure is not, '
            'so the lab figure is never the one to compare against the '
            'specification. Take the curing off first. Concrete left to dry '
            'early can lose a third of what it was capable of, which is more '
            'than any sensible change to the mix would ever buy back.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: fieldBrief,
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
            'WHICH ONE MAKES THE SPECIFICATION',
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
          EngineeringGrid(
            minor: 18,
            major: 90,
            child: SizedBox(
              height: 250,
              width: double.infinity,
              child: CustomPaint(
                painter: PourPainter(
                  pours: [r.left, r.right],
                  needs: r.needs,
                  picked: _flags(_picked),
                  answer: answered ? _flags(r.answer) : null,
                  locked: answered,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'the hatched piece is what the curing takes off the lab break',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          for (final option in Passes.values) ...[
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
              title: _session.correct! ? 'THAT IS RIGHT' : 'NOT QUITE',
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
