import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'momentum_figures.dart';

/// Which Target Takes More — the first item for `momentum-equation`.
///
/// The lesson's own jet problem is a flat plate, and its named trap is the
/// choice that doubles the answer "perhaps thinking about a 180 degree
/// reversal". That trap is the concept: a jet does not push by arriving, it
/// pushes by being TURNED. Nothing turned is nothing delivered, a flat plate
/// takes all the momentum the jet had, and a cup that sends the water back
/// takes it twice over. Four faces side by side settle that without a single
/// number being worked out.
class WhichTargetTakesMoreGame extends StatefulWidget {
  const WhichTargetTakesMoreGame({super.key});

  @override
  State<WhichTargetTakesMoreGame> createState() =>
      _WhichTargetTakesMoreGameState();
}

@immutable
class HitRound {
  const HitRound({
    required this.subject,
    required this.setting,
    required this.faces,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;

  /// The four panels, in the order they are drawn.
  final List<Hit> faces;
  final String why;
  final String source;

  /// Worked out from the four, never declared beside them.
  int get answer {
    var best = 0;
    for (var i = 1; i < faces.length; i++) {
      if (faces[i].push > faces[best].push) best = i;
    }
    return best;
  }

  double get biggest => faces[answer].push;
}

const hitRounds = <HitRound>[
  HitRound(
    subject: 'one jet, four faces',
    setting:
        'The same jet of water in all four: same nozzle, same speed. Which '
        'face does it push hardest on?',
    faces: [
      Hit(face: Face.through),
      Hit(face: Face.vane),
      Hit(face: Face.plate),
      Hit(face: Face.cup),
    ],
    why:
        'The cup, and by twice what the flat plate takes. A jet pushes by '
        'being turned, not by arriving. The sleeve turns it through nothing '
        'and takes nothing. The plate takes away all the speed the water had '
        'along the jet. The cup takes that away and then sends the water back '
        'the other way, which is twice the change. That doubling is the '
        'lesson\'s own wrong answer of 4,500 N: right for a cup, and twice '
        'too big for the plate the problem actually describes.',
    source: 'fm-me-q1',
  ),
  HitRound(
    subject: 'past the right angle',
    setting:
        'Same jet again. Three of these turn the water, and one of them '
        'carries it back past square.',
    faces: [
      Hit(face: Face.through),
      Hit(face: Face.plate),
      Hit(face: Face.scoop),
      Hit(face: Face.vane),
    ],
    why:
        'The scoop, at about 1.7 times the plate. Turning past a right angle '
        'keeps adding, because the water ends up moving BACK along the jet '
        'and that counts on top of the speed it lost. The plate is not the '
        'strongest case, it is only the tidiest one: it is where the water '
        'leaves with nothing along the jet at all.',
    source: 'fm-me-q1',
  ),
  HitRound(
    subject: 'a fast jet that is not turned',
    setting:
        'The sleeve is fed by a jet three times as fast as the others. The '
        'cup is fed by one at half their speed.',
    faces: [
      Hit(face: Face.through, speed: 3),
      Hit(face: Face.vane),
      Hit(face: Face.plate),
      Hit(face: Face.cup, speed: 0.5),
    ],
    why:
        'The flat plate. A jet that is not turned delivers nothing however '
        'fast it goes, because nothing about its momentum has changed. And '
        'the cup doubles what ITS jet carries, which is a quarter as much at '
        'half the speed, so double a quarter is half the plate.',
    source: 'fm-me-q1',
  ),
  HitRound(
    subject: 'speed against shape',
    setting:
        'The flat plate is fed by a jet twice as fast as the others. The cup '
        'gets an ordinary one.',
    faces: [
      Hit(face: Face.vane),
      Hit(face: Face.cup),
      Hit(face: Face.plate, speed: 2),
      Hit(face: Face.through, speed: 2),
    ],
    why:
        'The fast plate, at four times the ordinary one. Speed appears twice '
        'over, once in how much water arrives each second and once in how '
        'much each kilogram carries, so doubling it is four times the push. '
        'No shape can do that: the most any face can do is turn the water '
        'right around, which is double.',
    source: 'fm-me-q1',
  ),
  HitRound(
    subject: 'the same plate, a bigger jet',
    setting:
        'Two flat plates. The second is fed by a nozzle of twice the bore at '
        'the same speed.',
    faces: [
      Hit(face: Face.vane),
      Hit(face: Face.plate),
      Hit(face: Face.plate, bore: 2),
      Hit(face: Face.scoop),
    ],
    why:
        'The wide plate, at four times the narrow one. Twice the bore is four '
        'times the area, and area is how much water arrives each second. It '
        'beats the scoop, which only turns the water further around. This is '
        'the A in the lesson\'s own working, and the wrong answer of 225 N '
        'is what happens when it goes in ten times too small.',
    source: 'fm-me-q1',
  ),
  HitRound(
    subject: 'a great deal of water, going nowhere new',
    setting:
        'The sleeve carries a jet of twice the bore at twice the speed. The '
        'other three get the ordinary jet.',
    faces: [
      Hit(face: Face.scoop),
      Hit(face: Face.through, speed: 2, bore: 2),
      Hit(face: Face.plate),
      Hit(face: Face.vane),
    ],
    why:
        'The scoop, and the fat fast sleeve is still nothing. Sixteen times '
        'the momentum goes through it and comes out the far side heading the '
        'same way at the same speed, so it has changed by nothing and the '
        'sleeve feels nothing. Force is the CHANGE. That is why a straight '
        'length of water main needs no block, however big the main is.',
    source: 'fm-me-q1',
  ),
];

class _WhichTargetTakesMoreGameState extends State<WhichTargetTakesMoreGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-target-takes-more',
    chapterId: 'fluid-mechanics',
    total: hitRounds.length,
    sourceProblemIdOf: (round) => hitRounds[round].source,
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

  HitRound get _round => hitRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Target Takes More',
        closing:
            'A jet pushes by being turned. Straight through is no push at '
            'all, a flat plate takes all the momentum the water had along '
            'the jet, and a face that sends it back takes twice that. Speed '
            'and bore both count twice over, so they outrun anything the '
            'shape can do.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: deflectionBrief,
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
            'WHICH ONE IS PUSHED HARDEST',
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
          for (var row = 0; row < 2; row++) ...[
            if (row > 0) const SizedBox(height: 8),
            Row(
              children: [
                for (var col = 0; col < 2; col++) ...[
                  if (col > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _Panel(
                      hit: r.faces[row * 2 + col],
                      biggest: r.biggest,
                      selected: _picked == row * 2 + col,
                      locked: answered,
                      isTruth: r.answer == row * 2 + col,
                      onTap: answered
                          ? null
                          : () => setState(() => _picked = row * 2 + col),
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'ANOTHER FACE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.hit,
    required this.biggest,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Hit hit;
  final double biggest;
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
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: EngineeringGrid(
              minor: 16,
              major: 80,
              child: CustomPaint(
                painter: HitPainter(
                  hit: hit,
                  biggest: biggest,
                  showPush: locked,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
