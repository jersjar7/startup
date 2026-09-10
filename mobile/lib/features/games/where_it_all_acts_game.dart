import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'beam_figures.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Where It All Acts — the second item for `equilibrium-free-body-diagrams`.
///
/// The lesson's cantilever problem is lost on one number: a load spread along
/// the beam is replaced by a single force at the CENTROID of the shape it
/// makes, and the named trap is using the whole length instead. Twelve
/// kilonewtons at two meters, not at four.
///
/// So nothing is added up here. The load is drawn, some places on the beam are
/// marked, and the answer is where the one force that could replace it would
/// have to act. Uniform lands in the middle, a triangle a third of the way
/// from its heavy end, and the middle of the beam is a marked answer on every
/// round precisely because it is right so much less often than it looks.
class WhereItAllActsGame extends StatefulWidget {
  const WhereItAllActsGame({super.key});

  @override
  State<WhereItAllActsGame> createState() => _WhereItAllActsGameState();
}

@immutable
class ActsRound {
  const ActsRound({
    required this.subject,
    required this.setting,
    required this.span,
    required this.load,
    required this.stations,
    required this.supports,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final double span;
  final Spread load;

  /// The places on the beam that can be tapped.
  final List<Station> stations;
  final List<Support> supports;
  final String why;
  final String source;

  /// Worked out from the shape of the load rather than declared beside it.
  int get answer {
    var best = 0;
    for (var i = 1; i < stations.length; i++) {
      if ((stations[i].at - load.actsAt).abs() <
          (stations[best].at - load.actsAt).abs()) {
        best = i;
      }
    }
    return best;
  }
}

const actsRounds = <ActsRound>[
  ActsRound(
    subject: 'a cantilever under its own load',
    setting:
        'Four meters of beam built into a wall, carrying three kilonewtons per '
        'meter along every bit of it.',
    span: 4,
    load: Spread(0, 4, 3, 3, label: '3 kN/m'),
    stations: [Station(1, '1'), Station(2, '2'), Station(3, '3'), Station(4, '4')],
    supports: [Support(Offset(0, 0), Prop.fixed)],
    why:
        'Two meters, the middle of the load. Twelve kilonewtons act there, so '
        'the moment at the wall is twelve times two. Putting the resultant at '
        'the tip doubles that moment, and it is the wrong answer the lesson '
        'names, because the far end is where the load STOPS rather than where '
        'it adds up to.',
    source: 'stat-efb-q2',
  ),
  ActsRound(
    subject: 'a load that builds toward the far end',
    setting:
        'Six meters, carrying nothing at the left and building steadily to its '
        'heaviest at the right.',
    span: 6,
    load: Spread(0, 6, 0, 4, label: 'up to 4 kN/m'),
    stations: [Station(2, '2'), Station(3, '3'), Station(4, '4'), Station(5, '5')],
    supports: [Support(Offset(0, 0), Prop.pin), Support(Offset(6, 0), Prop.roller)],
    why:
        'Four meters, a third of the way in from the heavy end. Most of a '
        'triangle is at its thick end, so its resultant sits there too. Three '
        'meters is the middle of the beam and would be right only if the load '
        'were the same all the way along.',
    source: 'stat-efb-q2',
  ),
  ActsRound(
    subject: 'the same load, turned around',
    setting:
        'Six meters again, but now it is heaviest against the wall and fades to '
        'nothing at the tip.',
    span: 6,
    load: Spread(0, 6, 4, 0, label: 'from 4 kN/m'),
    stations: [Station(2, '2'), Station(3, '3'), Station(4, '4'), Station(5, '5')],
    supports: [Support(Offset(0, 0), Prop.fixed)],
    why:
        'Two meters. Same triangle, turned around, and the answer moves with '
        'it: still a third of the way in from the heavy end, which is now the '
        'wall. Nothing about this can be settled by remembering a fraction '
        'without looking at which end is loaded.',
    source: 'stat-efb-q2',
  ),
  ActsRound(
    subject: 'a load over part of the span',
    setting:
        'An eight meter beam with a uniform load over the middle four meters '
        'only, from two to six.',
    span: 8,
    load: Spread(2, 6, 2.5, 2.5, label: '2.5 kN/m'),
    stations: [Station(2, '2'), Station(3, '3'), Station(4, '4'), Station(6, '6')],
    supports: [Support(Offset(0, 0), Prop.pin), Support(Offset(8, 0), Prop.roller)],
    why:
        'Four meters, the middle of the LOAD. The middle of the beam is at four '
        'as well here, which makes this the one round where the lazy answer is '
        'also the right one. It is the middle of the loaded part that matters, '
        'and the two happen to coincide.',
    source: 'stat-efb-q2',
  ),
  ActsRound(
    subject: 'a load heavier at one end than the other',
    setting:
        'Nine meters, carrying one kilonewton per meter at the left and two at '
        'the right, straight between.',
    span: 9,
    load: Spread(0, 9, 1, 5, label: '1 to 5 kN/m'),
    stations: [
      Station(4.5, '4.5'),
      Station(5.5, '5.5'),
      Station(7, '7'),
      Station(8, '8'),
    ],
    supports: [Support(Offset(0, 0), Prop.pin), Support(Offset(9, 0), Prop.roller)],
    why:
        'Five and a half meters. Neither a rectangle nor a triangle, so neither '
        'the middle nor a third: the resultant sits between the two, pulled '
        'toward the heavy end in proportion. Four and a half is the middle of '
        'the beam, and this load is not symmetric.',
    source: 'stat-efb-q2',
  ),
  ActsRound(
    subject: 'the same shape, leaning the other way',
    setting:
        'Nine meters again, five kilonewtons per meter at the left falling to '
        'one at the right.',
    span: 9,
    load: Spread(0, 9, 5, 1, label: '5 down to 1 kN/m'),
    stations: [
      Station(3.5, '3.5'),
      Station(4.5, '4.5'),
      Station(6, '6'),
      Station(8, '8'),
    ],
    supports: [Support(Offset(0, 0), Prop.pin), Support(Offset(9, 0), Prop.roller)],
    why:
        'Three and a half meters, the mirror of the round before: the same '
        'distance in from the heavy end, which has swapped sides. Every one of '
        'these is the same question, which is where the area of the shape sits.',
    source: 'stat-efb-q2',
  ),
];

class _WhereItAllActsGameState extends State<WhereItAllActsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'where-it-all-acts',
    chapterId: 'statics',
    total: actsRounds.length,
    sourceProblemIdOf: (round) => actsRounds[round].source,
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

  ActsRound get _round => actsRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Where It All Acts',
        closing:
            'A spread load is replaced by one force at the centroid of its own '
            'shape. Uniform puts it in the middle of the LOADED part, a '
            'triangle a third of the way in from the heavy end, and anything '
            'in between lands in between. The middle of the beam is a guess, '
            'not a rule.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: resultantBrief,
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
            'TAP WHERE IT ALL ACTS',
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
          const SizedBox(height: 6),
          Text(
            'one force, standing in for the whole load',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          _Beam(
            round: r,
            picked: _picked,
            locked: answered,
            onTap: answered ? null : (i) => setState(() => _picked = i),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'RIGHT THERE' : 'SOMEWHERE ELSE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Beam extends StatelessWidget {
  const _Beam({
    required this.round,
    required this.picked,
    required this.locked,
    required this.onTap,
  });

  final ActsRound round;
  final int? picked;
  final bool locked;
  final void Function(int)? onTap;

  static const _height = 210.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: _height,
        width: double.infinity,
        child: EngineeringGrid(
          minor: 18,
          major: 90,
          child: LayoutBuilder(
            builder: (context, box) {
              final size = Size(box.maxWidth, _height);
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: BeamPainter(
                        span: round.span,
                        supports: round.supports,
                        spreads: [round.load],
                        stations: round.stations,
                        selected: picked,
                        locked: locked,
                        truth: round.answer,
                        markResultant: locked,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  for (var i = 0; i < round.stations.length; i++)
                    _target(i, size),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _target(int i, Size size) {
    final at = BeamPainter.stationAt(size, round.span, round.stations[i].at);
    const box = 46.0;
    return Positioned(
      key: ValueKey('station-$i'),
      left: at.dx - box / 2,
      top: at.dy - box / 2 + 8,
      width: box,
      height: box,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap == null ? null : () => onTap!(i),
        child: const SizedBox.expand(),
      ),
    );
  }
}
