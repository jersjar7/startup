import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'compaction_figures.dart';
import 'lesson_brief.dart';

/// Wetter Is Not Denser — the first item for `compaction-stabilization`.
///
/// The Proctor curve is a hump, not a slope. Water helps up to a point and
/// then starts taking the place the soil grains wanted, and the peak of that
/// hump is the number every field test is compared against.
class WetterIsNotDenserGame extends StatefulWidget {
  const WetterIsNotDenserGame({super.key});

  @override
  State<WetterIsNotDenserGame> createState() => _WetterIsNotDenserGameState();
}

@immutable
class ProctorRound {
  const ProctorRound({
    required this.subject,
    required this.asked,
    required this.test,
    required this.showField,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Proctor test;

  /// Some rounds are about the laboratory curve alone, with no field test on
  /// it yet.
  final bool showField;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own fill: 118 pcf measured against a modified Proctor
/// maximum of 124, which is 95.2 per cent.
const _theFill = Proctor(
  maxDryUnitWeight: 124,
  optimum: 12,
  fieldDryUnitWeight: 118,
  fieldMoisture: 10.5,
);

/// The same fill rolled too wet: past the optimum, and short of the line.
const _tooWet = Proctor(
  maxDryUnitWeight: 124,
  optimum: 12,
  fieldDryUnitWeight: 114,
  fieldMoisture: 16,
);

const proctorRounds = <ProctorRound>[
  ProctorRound(
    subject: 'what the peak of the curve is',
    asked:
        'A laboratory compacts the same soil at several moisture contents and '
        'plots this. What does the top of the hump mean?',
    test: _theFill,
    showField: false,
    options: [
      'The wettest the soil can be made',
      'The densest this soil gets under this compaction effort, and the '
          'water content that gets it there',
      'The density the field must exactly match',
      'The point where the soil stops taking water',
    ],
    answer: 1,
    why:
        'The densest this soil will go for this amount of rolling, and the '
        'one moisture content that gets it there. Both halves matter: change '
        'the compaction effort and the whole curve moves. The field is not '
        'asked to match the peak, it is asked to reach a stated fraction of '
        'it.',
    source: 'geo-cmp-q1',
  ),
  ProctorRound(
    subject: 'a fill that will not come up',
    asked:
        'A fill is going in well dry of the optimum and the roller cannot get '
        'it to density. What is the fix?',
    test: _theFill,
    showField: true,
    options: [
      'Wet it up toward the optimum and roll it again',
      'Keep rolling: it will get there eventually',
      'Dry it out further',
      'Accept it: dry soil is strong soil',
    ],
    answer: 0,
    why:
        'Water it. Dry of the optimum the grains grind against each other and '
        'will not slide into place, and a little water lubricates them. This '
        'is the one direction where adding water makes a soil DENSER, and it '
        'only works while you are still left of the peak.',
    source: 'geo-cmp-q1',
  ),
  ProctorRound(
    subject: 'and one that is too wet',
    asked:
        'This one came in well past the optimum and is also short. What is '
        'happening?',
    test: _tooWet,
    showField: true,
    options: [
      'The soil has become too strong to compress',
      'Water is taking up room the grains would have filled',
      'The roller is too heavy',
      'Nothing is wrong: wet soil weighs more',
    ],
    answer: 1,
    why:
        'Water is in the way. Past the optimum the voids are close to full, '
        'and the water cannot be squeezed out fast enough by a roller, so it '
        'holds the grains apart. More passes will not help and a heavier '
        'roller may make it worse. The fix is to dry it back, which on a wet '
        'site is slow and expensive.',
    source: 'geo-cmp-q1',
  ),
  ProctorRound(
    subject: 'what the field is measured against',
    asked:
        'Relative compaction is the field dry unit weight divided by what?',
    test: _theFill,
    showField: true,
    options: [
      'The wet unit weight of the same sample',
      'The unit weight of water',
      'The laboratory maximum from the Proctor test on that soil',
      'The unit weight of the solid grains',
    ],
    answer: 2,
    why:
        'The laboratory maximum for that soil, from its own Proctor test. '
        'Relative compaction is always against a number that came out of the '
        'laboratory, never against some absolute density, which is why two '
        'different soils at 95 per cent can have quite different densities.',
    source: 'geo-cmp-q1',
  ),
  ProctorRound(
    subject: 'a ratio the wrong way up',
    asked:
        'A technician divides the laboratory maximum by the field value and '
        'reports 105 per cent. What went wrong?',
    test: _theFill,
    showField: true,
    options: [
      'Nothing: the field beat the laboratory',
      'The ratio is upside down: field goes on top',
      'They used the wet unit weight',
      'They forgot to multiply by a hundred',
    ],
    answer: 1,
    why:
        'Upside down. The field value is the smaller of the two here, so the '
        'answer has to be under a hundred, and a number just over it is the '
        'signature of the swap. Reporting it would pass a fill that is '
        'actually short, which is the reason this particular slip matters.',
    source: 'geo-cmp-q1',
  ),
  ProctorRound(
    subject: 'which Proctor it was',
    asked:
        'The same field density is compared against a STANDARD Proctor '
        'maximum instead of a modified one. What happens to the percentage?',
    test: _theFill,
    showField: true,
    options: [
      'It goes up, because the standard maximum is the lower number',
      'It goes down',
      'Nothing: the soil has not changed',
      'It cannot be compared at all',
    ],
    answer: 0,
    why:
        'It goes up, because the standard test uses less compaction effort '
        'and so produces a lower maximum to be measured against. The same '
        'fill can be 95 per cent of modified and comfortably over 100 per '
        'cent of standard, so a specification has to say which test it '
        'means.',
    source: 'geo-cmp-q1',
  ),
];

class _WetterIsNotDenserGameState extends State<WetterIsNotDenserGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'wetter-is-not-denser',
    chapterId: 'geotechnical',
    total: proctorRounds.length,
    sourceProblemIdOf: (round) => proctorRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  ProctorRound get _round => proctorRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Wetter Is Not Denser',
        closing:
            'The Proctor curve is a hump. Dry of its peak, water helps the '
            'grains slide together. Wet of it, water holds them apart and no '
            'amount of rolling will fix that. The peak is the laboratory '
            'maximum for one soil at one compaction effort, and relative '
            'compaction is the field value over THAT, the right way up.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: proctorBrief,
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
            'THE PROCTOR CURVE',
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
                  painter: ProctorPainter(
                    test: r.test,
                    showField: r.showField,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < r.options.length; i++) ...[
            _Choice(
              label: r.options[i],
              selected: _picked == i,
              locked: answered,
              isTruth: r.answer == i,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            if (i != r.options.length - 1) const SizedBox(height: 8),
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
