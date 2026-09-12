import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'rigid_figures.dart';

/// What the Bar Is For — the second item for `rigid-pavement`.
///
/// A dowel carries the wheel load from one slab to the next and lets the
/// two move. A tie bar holds a joint shut and is meant not to move at all.
/// Confusing them is the mistake the lesson names.
class WhatTheBarIsForGame extends StatefulWidget {
  const WhatTheBarIsForGame({super.key});

  @override
  State<WhatTheBarIsForGame> createState() => _WhatTheBarIsForGameState();
}

@immutable
class JointRound {
  const JointRound({
    required this.subject,
    required this.asked,
    required this.joint,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Joint joint;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const _doweled = Joint(
  name: 'a transverse joint, across the lane',
  steel: Steel.dowel,
  whatItDoes: 'the dowel hands the wheel load to the next slab',
);

const _tied = Joint(
  name: 'a longitudinal joint, between two lanes',
  steel: Steel.tie,
  whatItDoes: 'the tie bar holds the two lanes together',
);

const _plain = Joint(
  name: 'a contraction joint, sawn in soon after paving',
  steel: Steel.nothing,
  whatItDoes: 'the slab cracks here, where it was told to',
);

const jointRounds = <JointRound>[
  JointRound(
    subject: 'what a dowel does',
    asked:
        'Dowel bars run across a transverse joint. What are they there for?',
    joint: _doweled,
    options: [
      'To hold the two slabs tightly together',
      'To carry the wheel load from one slab to the next while letting them '
          'move',
      'To reinforce the concrete against bending',
      'To stop water entering the joint',
    ],
    answer: 1,
    why:
        'Load transfer, with movement allowed. Without a dowel the leading '
        'edge of the next slab takes the wheel with nothing under it, which '
        'is how slabs crack at their corners. The bar is smooth and greased '
        'precisely so the slabs can still expand and contract.',
    source: 'trans-rp-q2',
  ),
  JointRound(
    subject: 'what a tie bar does',
    asked:
        'A tie bar runs across the joint between two lanes. What is its job?',
    joint: _tied,
    options: [
      'To carry wheel loads across',
      'To let the lanes slide past each other',
      'To hold the joint closed so the lanes do not drift apart',
      'To mark the lane line',
    ],
    answer: 2,
    why:
        'To hold it shut. A tie bar is deformed steel bonded into both sides, '
        'which is the opposite of a dowel: it is meant NOT to move. Calling '
        'a tie bar a dowel, or the other way round, is the mistake the lesson '
        'calls out.',
    source: 'trans-rp-q2',
  ),
  JointRound(
    subject: 'why a slab is cut at all',
    asked:
        'Contraction joints are sawn into a new slab within hours of paving. '
        'Why?',
    joint: _plain,
    options: [
      'To save concrete',
      'Because the slab will crack anyway, and this decides where',
      'To let water drain through',
      'To mark the stations',
    ],
    answer: 1,
    why:
        'Because concrete shrinks as it cures and contracts as it cools, and '
        'it will crack. A sawn joint gives the crack somewhere tidy to '
        'happen, in a straight line under the saw cut, where it can be '
        'sealed and where the two faces still interlock.',
    source: 'trans-rp-q2',
  ),
  JointRound(
    subject: 'the joint that leaves room',
    asked:
        'An expansion joint is a wider gap with filler in it. What is it for?',
    joint: _doweled,
    options: [
      'To give the slab room to grow when it warms',
      'To transfer load',
      'To hold the lanes together',
      'To let the subgrade breathe',
    ],
    answer: 0,
    why:
        'Room to grow. Concrete expands in the heat, and with nowhere to go '
        'it can buckle upward at a joint. Expansion joints are used sparingly '
        'in modern paving, at structures mostly, because the gap itself is a '
        'maintenance problem.',
    source: 'trans-rp-q2',
  ),
  JointRound(
    subject: 'no bar at all',
    asked:
        'Some contraction joints carry no steel. How does the load get '
        'across those?',
    joint: _plain,
    options: [
      'It does not: each slab carries its own',
      'Through the rough faces of the crack below the saw cut, which '
          'interlock',
      'Through the sealant',
      'Through the subbase only',
    ],
    answer: 1,
    why:
        'By aggregate interlock: the crack below the saw cut is rough, and '
        'the two faces bear on each other. It works while the joint stays '
        'tight and fails as it opens, which is why doweled joints are '
        'specified where the traffic is heavy.',
    source: 'trans-rp-q2',
  ),
  JointRound(
    subject: 'which bar goes where',
    asked:
        'One bar is smooth and greased, the other deformed and bonded. Which '
        'goes across a lane line?',
    joint: _tied,
    options: [
      'The smooth greased one, the dowel',
      'The deformed bonded one, the tie bar',
      'Either: they are interchangeable',
      'Neither: lane lines carry no steel',
    ],
    answer: 1,
    why:
        'The deformed one, bonded into both lanes, because a lane line is not '
        'meant to open. The smooth greased dowel belongs in the transverse '
        'joints, where movement is exactly what has to be allowed. Smooth '
        'means let go, deformed means hold on.',
    source: 'trans-rp-q2',
  ),
];

class _WhatTheBarIsForGameState extends State<WhatTheBarIsForGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-the-bar-is-for',
    chapterId: 'transportation',
    total: jointRounds.length,
    sourceProblemIdOf: (round) => jointRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  JointRound get _round => jointRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What the Bar Is For',
        closing:
            'Smooth and greased means let go: a dowel carries the wheel load '
            'across a transverse joint while the slabs move. Deformed and '
            'bonded means hold on: a tie bar keeps a lane line shut. '
            'Contraction joints decide where the slab cracks, and where '
            'there is no steel the rough crack faces interlock instead.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: jointBrief,
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
            'JOINTS AND THE STEEL IN THEM',
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
            height: 206,
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
                  painter: JointPainter(
                    joint: r.joint,
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
