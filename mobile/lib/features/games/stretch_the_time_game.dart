import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'collision_figures.dart';
import 'lesson_brief.dart';

/// Stretch the Time — the third item for `impulse-and-momentum`.
///
/// The lesson's hardest problem is a car hitting a barrier, and the sentence
/// worth carrying out of it is the one about crumple zones: the change in
/// momentum is fixed by how fast the car was going, so the only thing a
/// designer can change is how LONG the stopping takes, and the force follows
/// from that. Same area under the curve, different shape.
class StretchTheTimeGame extends StatefulWidget {
  const StretchTheTimeGame({super.key});

  @override
  State<StretchTheTimeGame> createState() => _StretchTheTimeGameState();
}

@immutable
class PulseRound {
  const PulseRound({
    required this.subject,
    required this.setting,
    required this.asked,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final String asked;

  /// The pulses on offer, in the order they are drawn.
  final List<Pulse> options;

  final int answer;
  final String why;
  final String source;

  double get tallest =>
      options.map((p) => p.force).reduce((a, b) => a > b ? a : b) * 1.15;

  double get longest =>
      options.map((p) => p.seconds).reduce((a, b) => a > b ? a : b) * 1.1;
}

const pulseRounds = <PulseRound>[
  PulseRound(
    subject: 'a car into a barrier',
    setting:
        'The same car at the same speed stops against three different '
        'barriers. All three take away the same momentum, so all three areas '
        'are the same.',
    asked: 'Tap the one that goes easiest on the people inside.',
    options: [
      Pulse(force: 200, seconds: 0.15, label: 'rigid'),
      Pulse(force: 100, seconds: 0.30, label: 'crumple'),
      Pulse(force: 300, seconds: 0.10, label: 'solid'),
    ],
    answer: 1,
    why:
        'The long flat one. The area under each of these is the same, because '
        'the car arrives with the same momentum and leaves with none, so the '
        'only way to lower the FORCE is to stretch the time. Twice as long is '
        'half as hard, which is the whole idea behind a crumple zone, an '
        'airbag and a run off area.',
    source: 'dyn-im-q3',
  ),
  PulseRound(
    subject: 'the same crash, the other way round',
    setting: 'The same three barriers.',
    asked: 'Tap the one that puts the biggest force on the car.',
    options: [
      Pulse(force: 100, seconds: 0.30, label: 'crumple'),
      Pulse(force: 300, seconds: 0.10, label: 'solid'),
      Pulse(force: 200, seconds: 0.15, label: 'rigid'),
    ],
    answer: 1,
    why:
        'The tall narrow one. It stops the car in a tenth of a second and pays '
        'for it with three times the force of the gentle barrier. Note that '
        'nothing about the car changed between these two rounds, and neither '
        'did its change in momentum: only the time.',
    source: 'dyn-im-q3',
  ),
  PulseRound(
    subject: 'catching a ball',
    setting:
        'Two ways of catching the same ball at the same speed. One pair of '
        'hands is held stiff and the other draws back with the ball.',
    asked: 'Tap the one that is the hands drawing back.',
    options: [
      Pulse(force: 60, seconds: 0.25, label: 'drawn back'),
      Pulse(force: 300, seconds: 0.05, label: 'held stiff'),
    ],
    answer: 0,
    why:
        'The long low one. Drawing your hands back with the ball is stretching '
        'the time on purpose, and it is the same physics as a crumple zone '
        'happening at the scale of a person. The ball loses the same momentum '
        'either way: what you are choosing is how hard it has to hurt.',
    source: 'dyn-im-q3',
  ),
  PulseRound(
    subject: 'a pile driver',
    setting:
        'A hammer drops on a pile. Here the engineer WANTS the biggest force '
        'possible, to drive the pile down.',
    asked: 'Tap the impact a pile driver is trying to produce.',
    options: [
      Pulse(force: 80, seconds: 0.4, label: 'soft cap'),
      Pulse(force: 160, seconds: 0.2, label: 'medium'),
      Pulse(force: 640, seconds: 0.05, label: 'steel on steel'),
    ],
    answer: 2,
    why:
        'The tall narrow one, and this is the round that turns the idea over. '
        'Everything else in this item is about softening a blow, but a pile '
        'driver is trying to deliver one: the same momentum in the shortest '
        'possible time is the biggest possible force. Same physics, opposite '
        'goal.',
    source: 'dyn-im-q3',
  ),
  PulseRound(
    subject: 'two impacts that are not the same',
    setting:
        'These two do NOT have the same area. One of them takes away twice as '
        'much momentum as the other.',
    asked: 'Tap the one that changes the momentum more.',
    options: [
      Pulse(force: 150, seconds: 0.2, label: 'A'),
      Pulse(force: 150, seconds: 0.4, label: 'B'),
    ],
    answer: 1,
    why:
        'The second, and by exactly two, because it pushes just as hard for '
        'twice as long. This is what the impulse actually IS: the force '
        'multiplied by the time, which is the area under the line, and it is '
        'the whole of the change in momentum. The other rounds held that area '
        'fixed; this one does not.',
    source: 'dyn-im-q3',
  ),
  PulseRound(
    subject: 'same job, gentler',
    setting:
        'Three impacts on the same truck. Two of them do not take away the '
        'same momentum as the first at all.',
    asked:
        'Tap the one that brings the truck to the same stop as the first, but '
        'more gently.',
    options: [
      Pulse(force: 300, seconds: 0.2, label: 'the first'),
      Pulse(force: 150, seconds: 0.4, label: 'B'),
      Pulse(force: 150, seconds: 0.2, label: 'C'),
    ],
    answer: 1,
    why:
        'The second. Same area as the first, so the same impulse and the same '
        'stop, at half the force because it lasts twice as long. The third is '
        'gentle too and it only takes away half the momentum, which means the '
        'truck is still moving at the end of it. Gentler is only useful if the '
        'area still matches.',
    source: 'dyn-im-q3',
  ),
];

class _StretchTheTimeGameState extends State<StretchTheTimeGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'stretch-the-time',
    chapterId: 'dynamics',
    total: pulseRounds.length,
    sourceProblemIdOf: (round) => pulseRounds[round].source,
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

  PulseRound get _round => pulseRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Stretch the Time',
        closing:
            'The impulse is the force times the time, and it is the whole of '
            'the change in momentum. A crash decides the momentum change; the '
            'design decides how long it takes, and the force follows. Stretch '
            'the time to soften a blow, shorten it to deliver one.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: impulseBrief,
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
            'TAP A FORCE AGAINST TIME',
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
          const SizedBox(height: 8),
          Text(
            r.asked,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < r.options.length; i++) ...[
            _Panel(
              pulse: r.options[i],
              tallest: r.tallest,
              longest: r.longest,
              selected: _picked == i,
              locked: answered,
              isTruth: i == r.answer,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            const SizedBox(height: 8),
          ],
          Center(
            child: MathText(
              r'$F\,\Delta t = m\,\Delta v$',
              style: const TextStyle(fontSize: 17, color: AppColors.charcoal),
            ),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'THE OTHER SHAPE',
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
    required this.pulse,
    required this.tallest,
    required this.longest,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Pulse pulse;
  final double tallest;
  final double longest;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color tone;
    if (locked && isTruth) {
      border = AppColors.forest;
      tone = AppColors.forest;
    } else if (locked && selected) {
      border = AppColors.error;
      tone = AppColors.error;
    } else if (selected) {
      border = AppColors.ember;
      tone = AppColors.ember;
    } else {
      border = AppColors.line;
      tone = AppColors.info;
    }

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 104,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: EngineeringGrid(
              minor: 16,
              major: 80,
              child: CustomPaint(
                painter: PulsePainter(
                  pulse: pulse,
                  tallest: tallest,
                  longest: longest,
                  tone: tone,
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
