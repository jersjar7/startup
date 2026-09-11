import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'corrosion_figures.dart';
import 'lesson_brief.dart';

/// Check Every Box — the second item for `corrosion-material-selection`.
///
/// The hardest problem in this lesson is a table and three requirements, and
/// its two named traps are both the same mistake: picking the metal that wins
/// one column without reading the others. Nothing about that is arithmetic.
/// It is the discipline of taking the criteria one at a time and crossing
/// candidates off, which is a skill the exam tests over and over and a phone
/// can drill in seconds.
class CheckEveryBoxGame extends StatefulWidget {
  const CheckEveryBoxGame({super.key});

  @override
  State<CheckEveryBoxGame> createState() => _CheckEveryBoxGameState();
}

@immutable
class PickRound {
  const PickRound({
    required this.subject,
    required this.job,
    required this.needs,
    required this.answer,
    required this.why,
    required this.source,
    this.minConducts,
    this.maxConducts,
    this.maxDensity,
    this.minDensity,
    this.needsResistance = false,
  });

  final String subject;

  /// What the part is, and the requirements in the words a specification
  /// would use.
  final String job;
  final List<String> needs;

  /// The metal that passes every one, or null when none of them does.
  final Metal? answer;
  final String why;
  final String source;

  /// The requirements, as numbers, so a test can check the answer rather than
  /// take it on trust.
  final double? minConducts;
  final double? maxConducts;
  final double? maxDensity;
  final double? minDensity;
  final bool needsResistance;

  bool suits(Listing m) {
    if (minConducts != null && m.conducts < minConducts!) return false;
    if (maxConducts != null && m.conducts > maxConducts!) return false;
    if (maxDensity != null && m.density > maxDensity!) return false;
    if (minDensity != null && m.density < minDensity!) return false;
    if (needsResistance && !m.resists) return false;
    return true;
  }
}

/// The four metals the lesson's own problem puts in front of you, with the
/// numbers it quotes from the handbook table.
const table = <Listing>[
  Listing(
      metal: Metal.copper, conducts: 403, density: 8933, resists: true),
  Listing(
      metal: Metal.aluminum, conducts: 236, density: 2698, resists: true),
  Listing(metal: Metal.steel, conducts: 83.5, density: 7873, resists: false),
  Listing(
      metal: Metal.titanium, conducts: 22, density: 4508, resists: true),
];

const boxRounds = <PickRound>[
  PickRound(
    subject: 'the lesson\'s heat exchanger',
    job: 'A heat exchanger working in a marine environment.',
    needs: [
      'conducts heat above 200 W/mK',
      'lighter than 5,000 kg/m3',
      'stands up to seawater',
    ],
    minConducts: 200,
    maxDensity: 5000,
    needsResistance: true,
    answer: Metal.aluminum,
    why:
        'Aluminum, and only because all three columns were read. Copper '
        'conducts nearly twice as well and is three times too heavy. Titanium '
        'survives anything and barely conducts at all. Steel fails on both '
        'counts and rusts. Aluminum is the compromise that clears every bar '
        'rather than winning any of them.',
    source: 'mat-cms-q3',
  ),
  PickRound(
    subject: 'a bus bar in a dry switch room',
    job: 'A bar to carry heat and current away inside dry switchgear, where '
        'weight and corrosion are nobody\'s problem.',
    needs: ['conducts heat above 300 W/mK'],
    minConducts: 300,
    answer: Metal.copper,
    why:
        'Copper, which is what wins when only one column matters. Notice how '
        'the answer changed with the requirements and not with the table: the '
        'same four metals, the same numbers, a different job. Copper is the '
        'right answer here and the trap in the first round.',
    source: 'mat-cms-q3',
  ),
  PickRound(
    subject: 'a thermal break that lives in the sea',
    job: 'A fitting permanently immersed in seawater whose job is to carry '
        'load without carrying heat across the joint.',
    needs: [
      'conducts heat below 50 W/mK',
      'stands up to seawater',
    ],
    maxConducts: 50,
    needsResistance: true,
    answer: Metal.titanium,
    why:
        'Titanium, which is the one metal here that is both a poor conductor '
        'and completely at home in seawater. Steel conducts about as little '
        'and rusts. Notice that a LOW conductivity was the requirement this '
        'time: the table does not know what is good, only what each metal is, '
        'and the job decides which end of a column you want.',
    source: 'mat-cms-q3',
  ),
  PickRound(
    subject: 'something light that conducts',
    job: 'A part for an aircraft ground unit: it has to be light and conduct '
        'heat reasonably well.',
    needs: ['lighter than 5,000 kg/m3', 'conducts heat above 100 W/mK'],
    minConducts: 100,
    maxDensity: 5000,
    answer: Metal.aluminum,
    why:
        'Aluminum again, and this time it is the only one under the weight '
        'bar that conducts at all: titanium is light enough and conducts at '
        '22. Being light is not enough on its own, which is the same lesson '
        'as copper conducting well and being too heavy.',
    source: 'mat-cms-q3',
  ),
  PickRound(
    subject: 'an impossible specification',
    job: 'A part that must conduct better than any of these except copper, '
        'and still come in under five thousand.',
    needs: ['conducts heat above 300 W/mK', 'lighter than 5,000 kg/m3'],
    minConducts: 300,
    maxDensity: 5000,
    answer: null,
    why:
        'None of them. The only metal on the list that conducts that well '
        'weighs nearly nine thousand, and everything light enough conducts '
        'far less. Finding that no candidate passes is a real answer, and it '
        'is the point at which you go back and ask which requirement is '
        'really a requirement.',
    source: 'mat-cms-q3',
  ),
  PickRound(
    subject: 'a condenser tube in a power station',
    job: 'A tube carrying heat into seawater, bolted down where weight is '
        'welcome rather than a problem.',
    needs: [
      'conducts heat above 50 W/mK',
      'stands up to seawater',
      'heavier than 5,000 kg/m3',
    ],
    minConducts: 50,
    minDensity: 5000,
    needsResistance: true,
    answer: Metal.copper,
    why:
        'Copper. Every column rules one metal out here: steel conducts well '
        'enough and rusts, aluminum survives and is too light for this one, '
        'titanium is heavy enough and hardly conducts. Three requirements, '
        'three eliminations, one survivor. Work down them in whatever order '
        'is quickest to check.',
    source: 'mat-cms-q3',
  ),
];

class _CheckEveryBoxGameState extends State<CheckEveryBoxGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'check-every-box',
    chapterId: 'materials',
    total: boxRounds.length,
    sourceProblemIdOf: (round) => boxRounds[round].source,
  )..addListener(_onSession);

  Metal? _picked;
  bool _pickedNone = false;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  PickRound get _round => boxRounds[_session.round];

  bool get _ready => _picked != null || _pickedNone;

  bool get _correct {
    final r = _round;
    if (r.answer == null) return _pickedNone;
    return !_pickedNone && _picked == r.answer;
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Check Every Box',
        closing:
            'Take the requirements one at a time and cross candidates off. '
            'The metal that wins a column is rarely the one that passes them '
            'all: copper conducts best and is far too heavy, titanium '
            'survives anything and hardly conducts. And notice when a '
            'requirement rules nothing out, or when nothing passes at all. '
            'Both mean the specification needs another look.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: pickingBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() {
                _picked = null;
                _pickedNone = false;
              });
              _session.next();
            }
          : (!_ready
                ? null
                : () => _session.submit(ok: _correct, context: context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHICH ONE PASSES EVERY TEST',
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('IT MUST', style: AppTheme.overline(color: AppColors.ink3)),
                const SizedBox(height: 6),
                for (final need in r.needs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      '- $need',
                      style:
                          AppTheme.mono(size: 12.5, color: AppColors.charcoal),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final listing in table) ...[
            _Choice(
              label: listing.line,
              selected: _picked == listing.metal && !_pickedNone,
              locked: answered,
              isTruth: r.answer == listing.metal,
              onTap: answered
                  ? null
                  : () => setState(() {
                        _picked = listing.metal;
                        _pickedNone = false;
                      }),
            ),
            const SizedBox(height: 8),
          ],
          _Choice(
            label: 'None of them passes',
            selected: _pickedNone,
            locked: answered,
            isTruth: r.answer == null,
            onTap: answered
                ? null
                : () => setState(() {
                      _pickedNone = true;
                      _picked = null;
                    }),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'READ THE REST',
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            style: AppTheme.mono(size: 12.5, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
