import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'runoff_figures.dart';

/// Which One Sheds More — the first item for `rainfall-runoff`.
///
/// The Rational Method is three numbers multiplied together, and with the
/// same storm falling on both catchments the intensity cancels out. What is
/// left is C times A: how much ground there is and how much of the rain that
/// ground refuses to absorb. Neither one wins on its own, which is the point
/// of the item. A small parking lot and a large wood can come to the same
/// peak.
class WhichOneShedsMoreGame extends StatefulWidget {
  const WhichOneShedsMoreGame({super.key});

  @override
  State<WhichOneShedsMoreGame> createState() => _WhichOneShedsMoreGameState();
}

/// Which catchment sends more water to the inlet.
enum Sheds { top, bottom, same }

extension ShedsWords on Sheds {
  String get plain => switch (this) {
        Sheds.top => 'Catchment A, the top one',
        Sheds.bottom => 'Catchment B, the bottom one',
        Sheds.same => 'Neither: the same peak',
      };
}

@immutable
class ShedRound {
  const ShedRound({
    required this.subject,
    required this.top,
    required this.bottom,
    required this.rain,
    required this.why,
    required this.source,
  });

  final String subject;
  final Catchment top;
  final Catchment bottom;

  /// The same storm falls on both, so the intensity cancels and only C
  /// times A is left to separate them.
  final double rain;
  final String why;
  final String source;

  /// The larger of the two acreages, so the pair is drawn to one scale.
  double get biggest =>
      top.acres > bottom.acres ? top.acres : bottom.acres;

  Sheds get answer {
    final a = top.peakAt(rain);
    final b = bottom.peakAt(rain);
    if ((a - b).abs() / b < 0.01) return Sheds.same;
    return a > b ? Sheds.top : Sheds.bottom;
  }
}

const shedRounds = <ShedRound>[
  ShedRound(
    subject: 'paving against woodland',
    top: Catchment([Patch(cover: 'commercial paving', acres: 50, coefficient: 0.85)]),
    bottom: Catchment([Patch(cover: 'woodland', acres: 50, coefficient: 0.20)]),
    rain: 4,
    why:
        'The paving, by more than four times. Same acreage and same storm, '
        'so the only thing separating them is what the ground does with the '
        'rain: asphalt sheds nearly all of it and a wood soaks up four fifths. '
        'This is the lesson\'s own commercial site at C = 0.85, and it is why '
        'the storm drain under a car park is so much larger than the ditch '
        'beside a forest road.',
    source: 'wr-rr-q1',
  ),
  ShedRound(
    subject: 'a small hard site against a big soft one',
    top: Catchment([Patch(cover: 'rooftops and yard', acres: 30, coefficient: 0.90)]),
    bottom: Catchment([Patch(cover: 'parkland', acres: 60, coefficient: 0.45)]),
    rain: 3.5,
    why:
        'Neither: both come to 27 acre-inches an hour. Thirty acres at 0.90 '
        'and sixty at 0.45 are the same product, and the Rational Method '
        'cannot tell them apart. Area and cover trade off exactly, which is '
        'worth seeing once: doubling the ground and halving the coefficient '
        'leaves the peak alone.',
    source: 'wr-rr-q3',
  ),
  ShedRound(
    subject: 'a large lawn against a small yard',
    top: Catchment([Patch(cover: 'lawns on clay', acres: 50, coefficient: 0.30)]),
    bottom: Catchment([Patch(cover: 'concrete yard', acres: 20, coefficient: 0.95)]),
    rain: 2.5,
    why:
        'The yard, despite being two and a half times smaller. Nineteen '
        'against fifteen: the coefficient is the stronger lever here because '
        'it spans a factor of three while the areas only span two and a half. '
        'Nothing about a big area makes it the bigger contributor on its own.',
    source: 'wr-rr-q1',
  ),
  ShedRound(
    subject: 'a mixed catchment against one cover',
    top: Catchment([
      Patch(cover: 'paving', acres: 30, coefficient: 0.90),
      Patch(cover: 'grass', acres: 20, coefficient: 0.40),
    ]),
    bottom: Catchment([Patch(cover: 'mixed suburban', acres: 50, coefficient: 0.70)]),
    rain: 3.5,
    why:
        'Neither, and this is what an area weighted coefficient means. The '
        'mixed catchment comes to 27 plus 8, which is 35, and 50 acres at '
        '0.70 comes to the same 35: 0.70 IS the weighted average of 0.90 and '
        '0.40 over those areas. Replacing a patchwork with one equivalent '
        'coefficient is legitimate as long as the weighting is by area.',
    source: 'wr-rr-q3',
  ),
  ShedRound(
    subject: 'the same ground, two covers',
    top: Catchment([Patch(cover: 'gravel', acres: 40, coefficient: 0.35)]),
    bottom: Catchment([Patch(cover: 'asphalt', acres: 40, coefficient: 0.75)]),
    rain: 5,
    why:
        'The asphalt, at more than twice the peak. Paving a gravel yard is '
        'one of the commonest ways a site outgrows its drainage: nothing '
        'about the area changed and the pipe that was adequate no longer is. '
        'It is also why detention is required on redevelopment, to give back '
        'what the new surface stopped absorbing.',
    source: 'wr-rr-q1',
  ),
  ShedRound(
    subject: 'a big field against a small lot',
    top: Catchment([Patch(cover: 'pasture', acres: 100, coefficient: 0.25)]),
    bottom: Catchment([Patch(cover: 'paved lot', acres: 15, coefficient: 0.95)]),
    rain: 2,
    why:
        'The pasture, 25 against 14. Enough acres of even a soft cover will '
        'beat a small hard one, which is the other half of the trade and the '
        'reason both numbers have to be looked at. Note that the pasture is '
        'over the 200 acre limit for nothing here, but a catchment much '
        'larger than this one would need the SCS method instead: the Rational '
        'Method is for small sites.',
    source: 'wr-rr-q1',
  ),
];

class _WhichOneShedsMoreGameState extends State<WhichOneShedsMoreGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-one-sheds-more',
    chapterId: 'water-resources',
    total: shedRounds.length,
    sourceProblemIdOf: (round) => shedRounds[round].source,
  )..addListener(_onSession);

  Sheds? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ShedRound get _round => shedRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which One Sheds More',
        closing:
            'With the same storm on both, the Rational Method comes down to '
            'the coefficient times the area. Neither is the stronger lever on '
            'its own: a small hard site can beat a large soft one and a large '
            'soft one can beat a small hard one, and two quite different '
            'catchments can come to exactly the same peak.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: rationalBrief,
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
            'WHICH SENDS MORE TO THE INLET',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            'The same storm falls on both, ${r.rain} inches an hour. Both '
            'plans are to one scale and shaded by how much of the rain each '
            'cover sheds, so the dark ink IS the peak.',
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          _Plan(catchment: r.top, rain: r.rain, name: 'A',
              biggest: r.biggest,
              won: answered &&
                  (r.answer == Sheds.top || r.answer == Sheds.same),
              locked: answered),
          const SizedBox(height: 8),
          _Plan(catchment: r.bottom, rain: r.rain, name: 'B',
              biggest: r.biggest,
              won: answered &&
                  (r.answer == Sheds.bottom || r.answer == Sheds.same),
              locked: answered),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$Q = C I A$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Sheds.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Sheds.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE BIGGER PEAK' : 'THE OTHER ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Plan extends StatelessWidget {
  const _Plan({
    required this.catchment,
    required this.rain,
    required this.name,
    required this.won,
    required this.locked,
    required this.biggest,
  });

  final Catchment catchment;
  final double rain;
  final String name;

  /// The larger of the two catchments, so both are drawn to one scale.
  final double biggest;
  final bool won;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: won ? AppColors.forest : AppColors.line,
          width: won ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: EngineeringGrid(
          minor: 18,
          major: 90,
          child: CustomPaint(
            painter: CatchmentPainter(
              catchment: catchment,
              intensity: rain,
              scaleTo: biggest,
              showWeighted: locked && catchment.patches.length > 1,
              tag: 'CATCHMENT $name',
            ),
            child: const SizedBox.expand(),
          ),
        ),
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
