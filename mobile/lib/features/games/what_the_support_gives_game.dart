import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'beam_figures.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// What the Support Gives — the first item for
/// `equilibrium-free-body-diagrams`.
///
/// The lesson says the free body diagram is the single most important skill in
/// statics, and the whole of it is knowing what each support hands you: a
/// roller one force, a pin two, a fixed end two and a moment. Get that wrong
/// and every equation after it is wrong.
///
/// Learned as a sentence it is three counts to memorize. Drawn, it is
/// something you can see, so the support is drawn and the answers are pictures
/// of the arrows rather than descriptions of them. Two rounds put the roller on
/// something that is not flat ground, where the one force it gives is square to
/// THAT surface and not vertical, which is where this is lost on an exam.
class WhatTheSupportGivesGame extends StatefulWidget {
  const WhatTheSupportGivesGame({super.key});

  @override
  State<WhatTheSupportGivesGame> createState() =>
      _WhatTheSupportGivesGameState();
}

/// One picture of a reaction set, as it appears on a button.
@immutable
class Reaction {
  const Reaction({
    this.square = false,
    this.along = false,
    this.moment = false,
    this.slope = 0,
  });

  /// A force square to the surface, a force along it, a moment.
  final bool square;
  final bool along;
  final bool moment;

  /// Tips the square-on force over, for a support on a slope or a wall.
  final double slope;

  int get count => (square ? 1 : 0) + (along ? 1 : 0) + (moment ? 1 : 0);
}

@immutable
class PropRound {
  const PropRound({
    required this.subject,
    required this.setting,
    required this.kind,
    required this.slope,
    required this.at,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Prop kind;

  /// The surface angle, for a roller that is not on flat ground.
  final double slope;

  /// Where along the four unit stub of beam it holds. A wall belongs at an
  /// END: drawn halfway along, it read as a beam passing through a wall.
  final double at;

  final List<Reaction> options;
  final int answer;
  final String why;
  final String source;
}

const propRounds = <PropRound>[
  PropRound(
    subject: 'a roller under a beam',
    setting:
        'The right-hand end of a simply supported beam sits on a roller, on '
        'level ground.',
    kind: Prop.roller,
    slope: 0,
    at: 4.0,
    options: [
      Reaction(square: true),
      Reaction(square: true, along: true),
      Reaction(square: true, along: true, moment: true),
    ],
    answer: 0,
    why:
        'One force, and it points straight up. A roller cannot hold the beam '
        'sideways because it would simply roll, and it cannot hold it against '
        'turning either. One unknown, which is why a roller is the cheapest '
        'support there is to have in an equation.',
    source: 'stat-efb-q1',
  ),
  PropRound(
    subject: 'a pin at the other end',
    setting:
        'The left-hand end of the same beam is pinned. It can turn about the '
        'pin but it cannot go anywhere.',
    kind: Prop.pin,
    slope: 0,
    at: 0.0,
    options: [
      Reaction(square: true, along: true, moment: true),
      Reaction(square: true),
      Reaction(square: true, along: true),
    ],
    answer: 2,
    why:
        'Two forces and no moment. The pin stops the end moving in any '
        'direction, so it can push both up and sideways, but the beam is still '
        'free to rotate about it, so there is nothing to resist a turn. Two '
        'unknowns.',
    source: 'stat-efb-q1',
  ),
  PropRound(
    subject: 'a beam cast into a wall',
    setting:
        'A cantilever is built into the wall at one end. The end cannot move '
        'and it cannot rotate either.',
    kind: Prop.fixed,
    slope: 0,
    at: 0.0,
    options: [
      Reaction(square: true, along: true),
      Reaction(square: true, along: true, moment: true),
      Reaction(square: true),
    ],
    answer: 1,
    why:
        'Two forces AND a moment. Whatever a support prevents, it supplies: '
        'this one prevents rotation, so it has to be able to push back against '
        'a turn. Three unknowns, which is a whole set of equations spent on one '
        'end, and the reason a cantilever needs nothing else holding it.',
    source: 'stat-efb-q2',
  ),
  PropRound(
    subject: 'a roller on a slope',
    setting:
        'A bridge bearing sits on a surface cut at 30 degrees. It is still a '
        'roller: it can run along that surface freely.',
    kind: Prop.slopedRoller,
    slope: 30,
    at: 3.0,
    options: [
      Reaction(square: true),
      Reaction(square: true, along: true),
      Reaction(square: true, slope: 30),
    ],
    answer: 2,
    why:
        'One force, square to the SURFACE, which is thirty degrees off '
        'vertical. A roller always pushes perpendicular to whatever it runs on, '
        'and reaching for a vertical arrow because rollers are usually on flat '
        'ground gives that force a horizontal part that is not there.',
    source: 'stat-efb-q1',
  ),
  PropRound(
    subject: 'an end bearing on a wall',
    setting:
        'The right-hand end of the beam bears against a smooth vertical face. '
        'Nothing stops it sliding up or down that face.',
    kind: Prop.slopedRoller,
    slope: 90,
    at: 4.0,
    options: [
      Reaction(square: true, slope: 90),
      Reaction(square: true),
      Reaction(square: true, along: true),
    ],
    answer: 0,
    why:
        'One force, horizontal, because the wall is what it is square to. This '
        'is the last round turned all the way over, and it is the reason the '
        'smooth wall in a ladder problem contributes one unknown and not two.',
    source: 'stat-efb-q1',
  ),
  PropRound(
    subject: 'a beam hung on a cable',
    setting:
        'One end of the beam hangs from a vertical cable fixed to the ceiling.',
    kind: Prop.cable,
    slope: 0,
    at: 4.0,
    options: [
      Reaction(square: true, along: true),
      Reaction(square: true),
      Reaction(square: true, along: true, moment: true),
    ],
    answer: 1,
    why:
        'One force, along the cable, and it can only pull. A cable and a roller '
        'are not the same thing and they cost the same: one unknown each. What '
        'a support is called matters less than how many ways it can stop the '
        'end moving.',
    source: 'stat-efb-q2',
  ),
];

class _WhatTheSupportGivesGameState extends State<WhatTheSupportGivesGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-the-support-gives',
    chapterId: 'statics',
    total: propRounds.length,
    sourceProblemIdOf: (round) => propRounds[round].source,
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

  PropRound get _round => propRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What the Support Gives',
        closing:
            'Whatever a support prevents, it supplies. A roller stops one '
            'direction and gives one force, square to whatever it runs on. A '
            'pin stops two and gives two. A fixed end stops rotation as well, '
            'so it gives a moment on top. Count them before you write anything '
            'down.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: supportsBrief,
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
            'WHAT DOES IT HAND YOU',
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
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: BeamPainter(
                    span: 4,
                    supports: [
                      Support(Offset(r.at, 0), r.kind, slope: r.slope),
                    ],
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < r.options.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _ReactionButton(
                    key: ValueKey('reaction-$i'),
                    reaction: r.options[i],
                    selected: _picked == i,
                    locked: answered,
                    isTruth: i == r.answer,
                    onTap: answered
                        ? null
                        : () => setState(() => _picked = i),
                  ),
                ),
              ],
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE SET' : 'A DIFFERENT SET',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({
    super.key,
    required this.reaction,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Reaction reaction;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

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
          height: 92,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: CustomPaint(
                  painter: ReactionGlyphPainter(
                    vertical: reaction.square,
                    horizontal: reaction.along,
                    moment: reaction.moment,
                    slope: reaction.slope,
                    colour: ink,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text(
                  reaction.count == 1 ? 'one unknown' : '${reaction.count} unknowns',
                  style: AppTheme.mono(size: 10, color: AppColors.ink3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
