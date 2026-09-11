import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'standards_figures.dart';

/// Removed or Remaining — the third item for `water-quality-standards`.
///
/// Removal efficiency is what came out over what went in, and the lesson's
/// trap is reporting the other piece: the fraction still there. The two add
/// to one, so an 87.5 percent plant leaves 12.5 percent, and both numbers
/// appear in the choices. What is worth seeing past the arithmetic is how
/// the last few percent behave: going from 90 to 95 percent removal halves
/// what the plant discharges, and going from 95 to 97.5 halves it again.
class RemovedOrRemainingGame extends StatefulWidget {
  const RemovedOrRemainingGame({super.key});

  @override
  State<RemovedOrRemainingGame> createState() =>
      _RemovedOrRemainingGameState();
}

/// What the required removal does when something changes.
enum Duty3 { up, down, same }

extension Duty3Words on Duty3 {
  String get plain => switch (this) {
        Duty3.up => 'The plant has to remove a larger share',
        Duty3.down => 'The plant can get away with removing less',
        Duty3.same => 'The required share does not change',
      };
}

@immutable
class DutyRound2 {
  const DutyRound2({
    required this.subject,
    required this.change,
    required this.before,
    required this.after,
    required this.why,
    required this.source,
  });

  final String subject;
  final String change;
  final Removal before;
  final Removal after;
  final String why;
  final String source;

  /// Worked out of the two duties, never declared.
  Duty3 get answer {
    if ((after.efficiency - before.efficiency).abs() < 0.001) {
      return Duty3.same;
    }
    return after.efficiency > before.efficiency ? Duty3.up : Duty3.down;
  }
}

const dutyRounds2 = <DutyRound2>[
  DutyRound2(
    subject: 'the lesson\'s own plant',
    change:
        'A 240 mg/L influent against a 30 mg/L secondary limit. The influent '
        'strengthens to 400 mg/L and the limit stays where it is.',
    before: Removal(influent: 240, limit: 30),
    after: Removal(influent: 400, limit: 30),
    why:
        'Up, from 87.5 percent to 92.5. A stronger influent against a fixed '
        'limit means more of it has to come out, which is why a works taking '
        'strong industrial waste has to treat harder than one on domestic '
        'sewage alone. Note that the lesson offers 12.5 percent as a wrong '
        'answer to the first case: that is the fraction REMAINING, and the '
        'two add to one.',
    source: 'wr-wqs-q2',
  ),
  DutyRound2(
    subject: 'a tighter permit',
    change:
        'The same 240 mg/L influent, but the permit is tightened from 30 '
        'mg/L to 10.',
    before: Removal(influent: 240, limit: 30),
    after: Removal(influent: 240, limit: 10),
    why:
        'Up, from 87.5 percent to 95.8. The percentage barely moves and the '
        'work does not: what matters is that the discharge is now a third of '
        'what it was. This is why removal percentages flatter a plant near '
        'the top of the range, and why permits are written on a '
        'CONCENTRATION rather than on a percentage.',
    source: 'wr-wqs-q2',
  ),
  DutyRound2(
    subject: 'a dilute day',
    change:
        'Storm water dilutes the influent from 240 mg/L to 120. The limit '
        'holds at 30 mg/L.',
    before: Removal(influent: 240, limit: 30),
    after: Removal(influent: 120, limit: 30),
    why:
        'Down, from 87.5 percent to 75. Less to take out for the same '
        'allowed discharge, so the required efficiency falls. The plant is '
        'not having an easier day, though: the flow doubled to dilute it, so '
        'the LOAD is the same and the hydraulic side of the works is working '
        'harder than ever.',
    source: 'wr-wqs-q2',
  ),
  DutyRound2(
    subject: 'more water, same strength',
    change:
        'The flow through the works doubles, at the same 240 mg/L in and the '
        'same 30 mg/L limit.',
    before: Removal(influent: 240, limit: 30),
    after: Removal(influent: 240, limit: 30),
    why:
        'No change. Removal efficiency is about CONCENTRATIONS and the flow '
        'is in neither term, so it cancels out entirely. Whether the plant '
        'can actually achieve that efficiency at twice the flow is a '
        'different question with a much less comfortable answer, but the '
        'required percentage is what it was.',
    source: 'wr-wqs-q2',
  ),
  DutyRound2(
    subject: 'the last few percent',
    change:
        'A plant achieving 90 percent removal is asked to reach 95 percent '
        'on the same influent.',
    before: Removal(influent: 200, limit: 20),
    after: Removal(influent: 200, limit: 10),
    why:
        'Up, and only by five percentage points, which is the misleading way '
        'to say it. What actually happened is that the discharge was halved: '
        '20 mg/L down to 10. Every five points near the top halves it again, '
        'and each halving is harder and more expensive than the one before. '
        'Think in what is LEFT rather than in what is removed.',
    source: 'wr-wqs-q2',
  ),
  DutyRound2(
    subject: 'a stronger influent and a looser permit together',
    change:
        'The influent doubles from 200 to 400 mg/L, and the permit is '
        'relaxed from 20 mg/L to 40 in the same breath.',
    before: Removal(influent: 200, limit: 20),
    after: Removal(influent: 400, limit: 40),
    why:
        'No change: 90 percent either way. Doubling both terms leaves the '
        'RATIO alone, and the required efficiency only ever sees the ratio of '
        'the limit to the influent. The plant is removing twice as many '
        'kilograms a day, which is real work, and the percentage cannot see '
        'it. Percentages are a poor way to describe a load.',
    source: 'wr-wqs-q2',
  ),
];

class _RemovedOrRemainingGameState extends State<RemovedOrRemainingGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'removed-or-remaining',
    chapterId: 'water-resources',
    total: dutyRounds2.length,
    sourceProblemIdOf: (round) => dutyRounds2[round].source,
  )..addListener(_onSession);

  Duty3? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  DutyRound2 get _round => dutyRounds2[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Removed or Remaining',
        closing:
            'Removal efficiency is what came out over what went in, and the '
            'fraction still there is one minus it: an 87.5 percent plant '
            'leaves 12.5 percent, and both numbers turn up in the choices. '
            'The flow cancels, so only the ratio of the limit to the influent '
            'matters, and near the top of the range five percentage points '
            'halve the discharge. Think in what is left.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: efficiencyBrief,
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
            'WHAT HAPPENS TO THE REQUIRED REMOVAL',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.change,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 214,
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
                  painter: RemovalPainter(
                    removal: answered ? r.after : r.before,
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
              r'$E = \dfrac{S_0 - S}{S_0}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Duty3.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Duty3.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
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
