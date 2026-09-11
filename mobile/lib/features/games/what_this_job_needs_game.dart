import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'concrete_figures.dart';
import 'lesson_brief.dart';

/// What This Job Needs — the second item for `concrete-mix-design`.
///
/// The lesson's hardest problem is not a calculation at all: it describes a
/// structure and asks which mix belongs in it. Two questions decide it, and
/// they are independent. How strong does it have to be, which sets the ratio,
/// and does it freeze, which decides whether air is entrained. A mix that
/// answers one and ignores the other is the wrong mix, and three of the four
/// choices on that problem are exactly that mistake.
class WhatThisJobNeedsGame extends StatefulWidget {
  const WhatThisJobNeedsGame({super.key});

  @override
  State<WhatThisJobNeedsGame> createState() => _WhatThisJobNeedsGameState();
}

@immutable
class JobRound {
  const JobRound({
    required this.subject,
    required this.job,
    required this.needs,
    required this.freezes,
    required this.mixes,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;

  /// The structure, in the words a drawing would carry.
  final String job;

  /// The strength it has to reach, in psi, and whether it will freeze.
  final double needs;
  final bool freezes;

  /// The mixes offered, in the order they are offered.
  final List<Mix> mixes;
  final int answer;
  final String why;
  final String source;

  /// A mix suits the job when it makes the strength and matches the exposure.
  bool suits(Mix mix) =>
      mix.strength >= needs && mix.entrained == freezes;
}

const siteRounds = <JobRound>[
  JobRound(
    subject: 'the lesson\'s parking garage',
    job:
        'A parking garage deck in a northern city. It has to reach 4,000 psi '
        'at twenty eight days, and it will be wet and freezing all winter.',
    needs: 4000,
    freezes: true,
    mixes: [
      Mix(wc: 0.45),
      Mix(wc: 0.70, air: 5),
      Mix(wc: 0.45, air: 5),
    ],
    answer: 2,
    why:
        'The low ratio WITH air. Both questions have to be answered: 0.45 is '
        'what reaches four thousand once the air has taken its cut, and the '
        'air is what keeps the deck from spalling apart over a winter. The '
        'first mix makes the strength and will not survive the frost. The '
        'second survives the frost and never reaches the strength.',
    source: 'mat-cmd-q3',
  ),
  JobRound(
    subject: 'a heated building',
    job:
        'A floor slab inside a heated warehouse, 4,000 psi. It will never see '
        'a freezing cycle in its life.',
    needs: 4000,
    freezes: false,
    mixes: [
      Mix(wc: 0.45, air: 5),
      Mix(wc: 0.45),
      Mix(wc: 0.70),
    ],
    answer: 1,
    why:
        'The low ratio with NO air. Entrained air is not a free upgrade: it '
        'costs about a fifth of the strength, and indoors there is no frost '
        'to protect against, so you would be paying for nothing. Air goes in '
        'where concrete freezes wet, not everywhere.',
    source: 'mat-cmd-q3',
  ),
  JobRound(
    subject: 'a sidewalk up north',
    job:
        'A city sidewalk in a cold climate. It only has to make 3,000 psi, '
        'and it will be under snow, salt and freezing water every winter.',
    needs: 3000,
    freezes: true,
    mixes: [
      Mix(wc: 0.55, air: 5),
      Mix(wc: 0.75, air: 6),
      Mix(wc: 0.55),
    ],
    answer: 0,
    why:
        'The middle ratio with air. A lower strength requirement lets the '
        'ratio up a little, but not far: 0.55 with air still clears three '
        'thousand, while 0.75 does not come close. And the exposure decides '
        'the air whatever the strength is. Flatwork that freezes gets air '
        'every time.',
    source: 'mat-cmd-q3',
  ),
  JobRound(
    subject: 'the mix will not pour',
    job:
        'A northern bridge parapet at 4,000 psi. The 0.45 mix with air is '
        'correct but too stiff for the crew to place around the '
        'reinforcement.',
    needs: 4000,
    freezes: true,
    mixes: [
      Mix(wc: 0.60, air: 5),
      Mix(wc: 0.45, air: 5, plasticized: true),
      Mix(wc: 0.45),
    ],
    answer: 1,
    why:
        'Keep the ratio and add the water reducer. Workability is not a '
        'reason to move the ratio: that is what the admixture is for, and it '
        'leaves the strength and the durability exactly where the design put '
        'them. Loosening the mix with water instead gives away the strength '
        'the parapet was specified for.',
    source: 'mat-cmd-q3',
  ),
  JobRound(
    subject: 'a bridge deck that has to be strong',
    job:
        'A highway bridge deck in a cold state, specified at 5,000 psi and '
        'exposed to freezing and de-icing salts.',
    needs: 5000,
    freezes: true,
    mixes: [
      Mix(wc: 0.55, air: 5),
      Mix(wc: 0.40, air: 5),
      Mix(wc: 0.40),
    ],
    answer: 1,
    why:
        'The lowest ratio, with air. When both demands are severe they push '
        'the same way: the air costs strength, so the ratio has to come down '
        'far enough to pay for it AND still make five thousand. That is why '
        'bridge deck mixes sit near 0.40 and lean on water reducers to stay '
        'placeable.',
    source: 'mat-cmd-q3',
  ),
  JobRound(
    subject: 'a footing below the frost line',
    job:
        'A building footing cast below the frost line and backfilled. It '
        'needs 5,000 psi and it will never freeze down there.',
    needs: 5000,
    freezes: false,
    mixes: [
      Mix(wc: 0.60),
      Mix(wc: 0.40),
      Mix(wc: 0.40, air: 6),
    ],
    answer: 1,
    why:
        'The low ratio, no air. Buried concrete below the frost line does not '
        'go through freezing cycles, so the air would only cost strength. '
        'Note what decides it: not whether the CITY is cold, but whether this '
        'piece of concrete freezes. The garage deck up top and the footing '
        'underneath it get different mixes.',
    source: 'mat-cmd-q3',
  ),
];

class _WhatThisJobNeedsGameState extends State<WhatThisJobNeedsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-this-job-needs',
    chapterId: 'materials',
    total: siteRounds.length,
    sourceProblemIdOf: (round) => siteRounds[round].source,
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

  JobRound get _round => siteRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What This Job Needs',
        closing:
            'Two questions, answered separately. How strong, which sets the '
            'ratio, and does this piece of concrete freeze, which decides the '
            'air. Air costs about a fifth of the strength, so a job that '
            'needs both pushes the ratio down further. And when the only '
            'complaint is that it will not pour, the answer is a water '
            'reducer, never water.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: exposureBrief,
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
            'WHICH MIX SUITS THE JOB',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.job,
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
              height: 240,
              width: double.infinity,
              child: CustomPaint(
                painter: MixPainter(
                  marks: r.mixes,
                  target: r.needs,
                  picked: _picked,
                  answer: answered ? r.answer : null,
                  locked: answered,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'the chart answers the strength half. the exposure is yours',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < r.mixes.length; i++) ...[
            _Choice(
              label: '${i + 1}.  ${r.mixes[i].plain}',
              selected: _picked == i,
              locked: answered,
              isTruth: r.answer == i,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 6),
            BoardFeedback(
              correct: _session.correct!,
              title:
                  _session.correct! ? 'THAT IS THE MIX' : 'THAT ONE FAILS A TEST',
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
            style: AppTheme.mono(size: 13.5, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
