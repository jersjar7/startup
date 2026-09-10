import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'section_figures.dart';

/// Move It Right — the second item for `area-moments-of-inertia`.
///
/// The parallel axis theorem is the formula this lesson is really about, and
/// its warning is the thing people get wrong: it only runs between a
/// centroidal axis and some other axis. It will not take you straight from one
/// non-centroidal axis to another, however convenient that would be. You have
/// to come back through the centroid first.
///
/// So no arithmetic. Two axes are drawn on a section, the centroidal one is
/// marked as a drawing office marks one, and the answer is whether the
/// transfer term goes on, comes off, or will not get you there at all.
class MoveItRightGame extends StatefulWidget {
  const MoveItRightGame({super.key});

  @override
  State<MoveItRightGame> createState() => _MoveItRightGameState();
}

@immutable
class AxisRound {
  const AxisRound({
    required this.subject,
    required this.setting,
    required this.profile,
    required this.from,
    required this.to,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Profile profile;
  final Datum from;
  final Datum to;
  final String why;
  final String source;

  bool _isCentroidal(Datum d) =>
      (d.y - profile.centroid.dy).abs() < 0.01;

  /// Worked out from where the two axes sit against the centroid, never
  /// declared beside the round.
  Transfer get answer {
    final leaving = _isCentroidal(from);
    final arriving = _isCentroidal(to);
    if (leaving && !arriving) return Transfer.add;
    if (arriving && !leaving) return Transfer.subtract;
    return Transfer.cannot;
  }
}

/// A plain rectangle, centroid at fifty.
const _bar = Profile([Piece(Slab.box, Offset.zero, Size(50, 100))]);

/// A round bar, centroid at forty.
const _round = Profile([Piece(Slab.disc, Offset.zero, Size(80, 80))]);

/// The lesson's T, centroid at seventy.
const _tee = Profile([
  Piece(Slab.box, Offset(50, 0), Size(20, 80)),
  Piece(Slab.box, Offset(0, 80), Size(120, 20)),
]);

const axisRounds = <AxisRound>[
  AxisRound(
    subject: 'down to the base of a rectangle',
    setting:
        'You have the moment of inertia about the rectangle\'s own centroidal '
        'axis and you want it about the bottom edge.',
    profile: _bar,
    from: Datum(50, 'from'),
    to: Datum(0, 'to'),
    why:
        'Add the transfer term. You are leaving the centroidal axis, and the '
        'centroidal axis is the one place a section has the LEAST moment of '
        'inertia there is. Every other parallel axis is bigger, so moving away '
        'from it can only add. That is the whole sign rule.',
    source: 'stat-ami-q2',
  ),
  AxisRound(
    subject: 'back up from the base',
    setting:
        'This time you were given it about the bottom edge and you want the '
        'centroidal value, which is what a beam actually bends about.',
    profile: _bar,
    from: Datum(0, 'from'),
    to: Datum(50, 'to'),
    why:
        'Take the transfer term off. Same two axes as the round before and the '
        'same term, running the other way. Arriving at the centroid always '
        'subtracts, because you are heading for the smallest value the section '
        'has.',
    source: 'stat-ami-q2',
  ),
  AxisRound(
    subject: 'from the base straight to the top',
    setting:
        'You have it about the bottom edge and you want it about the top edge. '
        'Both are edges of the same rectangle.',
    profile: _bar,
    from: Datum(0, 'from'),
    to: Datum(100, 'to'),
    why:
        'Neither. The theorem runs between the centroidal axis and something '
        'else, and these are two something elses. Go down to the centroid '
        'first, subtracting, then out to the top edge, adding. Two steps, and '
        'the shortcut people reach for here is simply not a theorem.',
    source: 'stat-ami-q2',
  ),
  AxisRound(
    subject: 'a round bar down to a bolt line',
    setting:
        'A solid round bar. You know its centroidal value from the table and '
        'you need it about a line well below the bar.',
    profile: _round,
    from: Datum(40, 'from'),
    to: Datum(-30, 'to'),
    why:
        'Add it. It makes no difference that the new axis misses the shape '
        'altogether: d is just the perpendicular distance between the two '
        'parallel axes, and the further away it is the more the transfer term '
        'dominates. At this distance the bar\'s own value hardly matters.',
    source: 'stat-ami-q2',
  ),
  AxisRound(
    subject: 'onto the centroid of a T',
    setting:
        'A T section. You have the value about the underside of the flange and '
        'you want it about the composite centroidal axis.',
    profile: _tee,
    from: Datum(80, 'from'),
    to: Datum(70, 'to'),
    why:
        'Take it off. Arriving at the centroid subtracts, and it does not '
        'matter that the two axes are only ten apart or that the section is '
        'made of pieces. What matters is which end of the move is the '
        'centroidal one.',
    source: 'stat-ami-q3',
  ),
  AxisRound(
    subject: 'between two lines that miss the centroid',
    setting:
        'The same T. You have it about the underside of the flange and you '
        'want it about the bottom of the web.',
    profile: _tee,
    from: Datum(80, 'from'),
    to: Datum(0, 'to'),
    why:
        'Neither, again, and this is the round worth remembering. Both axes '
        'are perfectly reasonable lines on the drawing and neither is the '
        'centroidal one, so there is no single transfer that connects them. '
        'Come back to the centroid, then go out again.',
    source: 'stat-ami-q3',
  ),
];

class _MoveItRightGameState extends State<MoveItRightGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'move-it-right',
    chapterId: 'statics',
    total: axisRounds.length,
    sourceProblemIdOf: (round) => axisRounds[round].source,
  )..addListener(_onSession);

  Transfer? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  AxisRound get _round => axisRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Move It Right',
        closing:
            'The centroidal axis is where a section has its smallest moment of '
            'inertia, so leaving it adds the transfer term and arriving at it '
            'takes the term off. Between two axes that both miss the centroid '
            'there is no single step at all: go back through the centroid, '
            'every time.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: transferBrief,
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
            'WHAT DOES THE TRANSFER TERM DO',
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
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 250,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: ProfilePainter(
                    profile: r.profile,
                    axes: [r.from, r.to],
                    markCentroid: true,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'the chain line is the centroidal axis',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          for (final option in Transfer.values) ...[
            _MoveButton(
              key: ValueKey('move-${option.name}'),
              option: option,
              selected: _picked == option,
              locked: answered,
              isTruth: option == r.answer,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Transfer.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE MOVE' : 'NOT THAT MOVE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _MoveButton extends StatelessWidget {
  const _MoveButton({
    super.key,
    required this.option,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Transfer option;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  static const _titles = {
    Transfer.add: 'Add the transfer term',
    Transfer.subtract: 'Take the transfer term off',
    Transfer.cannot: 'It will not go straight there',
  };

  static const _notes = {
    Transfer.add: 'leaving the centroidal axis',
    Transfer.subtract: 'arriving at the centroidal axis',
    Transfer.cannot: 'neither axis is the centroidal one',
  };

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color fill;
    final Color ink;
    if (locked && isTruth) {
      border = AppColors.forest;
      fill = AppColors.forestBg;
      ink = AppColors.forest;
    } else if (locked && selected) {
      border = AppColors.error;
      fill = AppColors.errorBg;
      ink = AppColors.error;
    } else if (selected) {
      border = AppColors.ember;
      fill = AppColors.emberBg;
      ink = AppColors.ember;
    } else {
      border = AppColors.line;
      fill = AppColors.white;
      ink = AppColors.charcoal;
    }

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                height: 36,
                child: CustomPaint(painter: _MoveGlyph(option, ink)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _titles[option]!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _notes[option]!,
                      style: AppTheme.mono(size: 10.5, color: AppColors.ink3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Two axes and an arrow between them, barred when the move is not allowed.
class _MoveGlyph extends CustomPainter {
  const _MoveGlyph(this.option, this.colour);

  final Transfer option;
  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final top = 7.0;
    final bottom = size.height - 7;
    final x = size.width / 2;
    final rule = Paint()
      ..color = AppColors.ink3
      ..strokeWidth = 1.4;
    for (final y in [top, bottom]) {
      for (var a = 2.0; a < size.width - 2; a += 7) {
        canvas.drawLine(Offset(a, y), Offset(a + 4, y), rule);
      }
    }

    final ink = Paint()
      ..color = colour
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final up = option == Transfer.subtract;
    final tip = Offset(x, up ? top + 3 : bottom - 3);
    final tail = Offset(x, up ? bottom - 3 : top + 3);
    canvas.drawLine(tail, tip, ink);
    final back = up ? 1.0 : -1.0;
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx - 4.4, tip.dy + back * 7)
        ..lineTo(tip.dx + 4.4, tip.dy + back * 7)
        ..close(),
      Paint()..color = colour,
    );

    if (option == Transfer.cannot) {
      canvas.drawLine(Offset(x - 9, size.height / 2 + 7),
          Offset(x + 9, size.height / 2 - 7), ink);
    }
  }

  @override
  bool shouldRepaint(_MoveGlyph old) =>
      old.option != option || old.colour != colour;
}
