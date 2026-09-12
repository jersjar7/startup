import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'figure_ink.dart';
import 'lesson_brief.dart';

/// When It Runs Away — the second item for `vibrations-natural-frequency`.
///
/// The lesson's own application is a list of things that go wrong when a
/// forcing frequency lands on a natural one: a footbridge under walkers, a
/// machine on a mounting, a building in an earthquake. Its middle problem is
/// that question with the arithmetic attached.
///
/// The arithmetic is a square root and a division by two pi. What is left,
/// and what this item is, is comparing two frequencies that arrive in
/// different units and saying whether they are too close for comfort.
class WhenItRunsAwayGame extends StatefulWidget {
  const WhenItRunsAwayGame({super.key});

  @override
  State<WhenItRunsAwayGame> createState() => _WhenItRunsAwayGameState();
}

/// How the two frequencies sit against each other.
enum Danger { resonant, wellClear, tooLow }

extension DangerWords on Danger {
  String get plain => switch (this) {
        Danger.resonant => 'Trouble: they are on top of each other',
        Danger.wellClear => 'Safe: the forcing is well ABOVE it',
        Danger.tooLow => 'Safe: the forcing is well BELOW it',
      };
}

@immutable
class TuneRound {
  const TuneRound({
    required this.subject,
    required this.setting,
    required this.naturalHz,
    required this.forcingHz,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;

  /// Both in cycles a second, whatever units the words used.
  final double naturalHz;
  final double forcingHz;

  final String why;
  final String source;

  /// Within about a fifth of each other counts as on top of each other.
  Danger get answer {
    final ratio = forcingHz / naturalHz;
    if (ratio > 0.8 && ratio < 1.25) return Danger.resonant;
    return ratio > 1 ? Danger.wellClear : Danger.tooLow;
  }
}

const tuneRounds = <TuneRound>[
  TuneRound(
    subject: 'a footbridge under walkers',
    setting:
        'A pedestrian bridge has a natural frequency of about two cycles a '
        'second. People walk across it at about two paces a second.',
    naturalHz: 2,
    forcingHz: 2,
    why:
        'Trouble. Walking pace lands right on the bridge\'s own frequency, so '
        'every footfall arrives in time with the last swing and adds to it. '
        'This is why some famous footbridges had to be closed and fitted with '
        'dampers, and why pedestrian bridges are now deliberately designed '
        'away from the one to three cycle band.',
    source: 'dyn-vib-q2',
  ),
  TuneRound(
    subject: 'the lesson\'s machine mounting',
    setting:
        'The mounting gives a natural frequency of about two and a half cycles '
        'a second. The machine runs at 150 rpm.',
    naturalHz: 2.49,
    forcingHz: 2.5,
    why:
        'Trouble, and the units are the whole point of the round: a hundred '
        'and fifty turns a minute is two and a half turns a SECOND, which is '
        'the natural frequency almost exactly. Two numbers can only be '
        'compared once they are in the same units, and rpm, hertz and radians '
        'a second are three ways of saying the same kind of thing.',
    source: 'dyn-vib-q2',
  ),
  TuneRound(
    subject: 'the same mounting, a faster machine',
    setting:
        'The same mounting at about two and a half cycles a second, with a '
        'machine running at 1,500 rpm instead.',
    naturalHz: 2.49,
    forcingHz: 25,
    why:
        'Safe, and safe in the good direction: twenty five cycles a second is '
        'ten times the mounting\'s own frequency, so the machine is running '
        'far above it. That is how machine mountings are designed. It does '
        'mean the machine passes through resonance on its way up to speed, '
        'which is why a big machine is run up quickly rather than dwelt on '
        'the way through.',
    source: 'dyn-vib-q2',
  ),
  TuneRound(
    subject: 'a tall building in an earthquake',
    setting:
        'A tall building sways with a natural frequency near zero point two '
        'cycles a second. The ground is shaking at about five cycles a second.',
    naturalHz: 0.2,
    forcingHz: 5,
    why:
        'Safe here, because the shaking is far quicker than the building can '
        'answer. A tall building is slow and soft, and hard high frequency '
        'ground motion goes underneath it. The frightening case is the other '
        'way round: soft ground that shakes slowly, right where a tall '
        'building lives, which is what did the damage in Mexico City in '
        'nineteen eighty five.',
    source: 'dyn-vib-q2',
  ),
  TuneRound(
    subject: 'a stiff little building on soft ground',
    setting:
        'A four story building has a natural frequency near two cycles a '
        'second. The ground beneath it shakes at about a quarter of a cycle a '
        'second.',
    naturalHz: 2,
    forcingHz: 0.25,
    why:
        'Safe, this time because the shaking is far SLOWER than the building. '
        'The ground moves and the building simply rides along with it, barely '
        'flexing. Notice that both of the safe answers in this item are about '
        'being far away in one direction or the other, and it is only the '
        'middle that is dangerous.',
    source: 'dyn-vib-q2',
  ),
  TuneRound(
    subject: 'a shaft at its critical speed',
    setting:
        'The torsional system in this lesson comes out at about five cycles a '
        'second. The shaft is being driven at 31.4 radians a second.',
    naturalHz: 5.03,
    forcingHz: 5,
    why:
        'Trouble, and the units again: thirty one point four radians a second '
        'is five cycles a second, since a cycle is two pi radians. This is '
        'what a critical speed is, and it is the number a rotating machine is '
        'designed to run either side of and never at.',
    source: 'dyn-vib-q3',
  ),
];

class _WhenItRunsAwayGameState extends State<WhenItRunsAwayGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'when-it-runs-away',
    chapterId: 'dynamics',
    total: tuneRounds.length,
    sourceProblemIdOf: (round) => tuneRounds[round].source,
  )..addListener(_onSession);

  Danger? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  TuneRound get _round => tuneRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'When It Runs Away',
        closing:
            'Resonance is not a property of a structure, it is what happens '
            'when something pushes it at its own frequency. Far above is safe '
            'and far below is safe; it is the middle that tears things apart. '
            'And two frequencies can only be compared once they are in the '
            'same units: turns a minute, cycles a second and radians a second '
            'are three ways of saying the same kind of thing.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: resonanceBrief,
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
            'IS THIS HEADED FOR RESONANCE',
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
          SizedBox(
            height: 130,
            child: CustomPaint(
              painter: _TunePainter(
                naturalHz: r.naturalHz,
                forcingHz: answered ? r.forcingHz : null,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answered
                ? 'the mark is where the forcing lands'
                : 'the peak is the natural frequency',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$1\ \mathrm{Hz} = 60\ \mathrm{rpm} = 2\pi\ \mathrm{rad/s}$',
              style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 14),
          for (final d in Danger.values) ...[
            _Choice(
              label: d.plain,
              selected: _picked == d,
              locked: answered,
              isTruth: d == r.answer,
              onTap: answered ? null : () => setState(() => _picked = d),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 8),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE CASE' : 'LOOK AT THE TWO',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

/// The response curve against forcing frequency, with the natural frequency
/// at the peak and, once the answer is out, a mark where the forcing lands.
class _TunePainter extends CustomPainter {
  const _TunePainter({required this.naturalHz, this.forcingHz});

  final double naturalHz;
  final double? forcingHz;

  @override
  void paint(Canvas canvas, Size size) {
    const padL = 22.0;
    const padB = 18.0;
    final floor = size.height - padB;
    final room = size.height - padB - 12;
    final wide = size.width - padL - 10;

    // The axis runs from nothing to three times the natural frequency, so a
    // forcing well above still lands on the page.
    final span = naturalHz * 3.2;
    double x(double hz) => padL + math.min(hz, span) / span * wide;

    canvas
      ..drawLine(Offset(padL, floor), Offset(size.width - 8, floor),
          Paint()..color = AppColors.ink3..strokeWidth = 1)
      ..drawLine(Offset(padL, 8), Offset(padL, floor),
          Paint()..color = AppColors.ink3..strokeWidth = 1);

    // A lightly damped response: big near the natural frequency, small away.
    final path = Path();
    var started = false;
    for (var i = 0; i <= 120; i++) {
      final hz = span * i / 120;
      final r = hz / naturalHz;
      final amp = 1 / math.sqrt(math.pow(1 - r * r, 2) + math.pow(0.28 * r, 2));
      final p = Offset(x(hz), floor - math.min(amp, 3.8) / 3.8 * room);
      started ? path.lineTo(p.dx, p.dy) : path.moveTo(p.dx, p.dy);
      started = true;
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.info
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    canvas.drawLine(
      Offset(x(naturalHz), floor),
      Offset(x(naturalHz), 10),
      Paint()
        ..color = AppColors.ink3
        ..strokeWidth = 0.8,
    );
    _write(canvas, size, 'natural', Offset(x(naturalHz) - 18, floor + 4),
        AppColors.ink3);
    _write(canvas, size, 'how far it swings', const Offset(2, 2), AppColors.ink3);

    if (forcingHz != null) {
      final at = x(forcingHz!);
      canvas
        ..drawLine(
          Offset(at, floor),
          Offset(at, 14),
          Paint()
            ..color = AppColors.ember
            ..strokeWidth = 2,
        )
        ..drawCircle(Offset(at, 14), 4, Paint()..color = AppColors.ember);
      _write(canvas, size, 'forcing', Offset(at - 14, floor + 4), AppColors.ember);
    }
  }

  /// A forcing frequency at the top of the range puts its label hard against
  /// the right edge, so every label here is kept inside the panel.
  void _write(Canvas canvas, Size size, String text, Offset at, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 9.5, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    paintInside(canvas, size, tp, at);
  }

  @override
  bool shouldRepaint(_TunePainter old) =>
      old.naturalHz != naturalHz || old.forcingHz != forcingHz;
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
