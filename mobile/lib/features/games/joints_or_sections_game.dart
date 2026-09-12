import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'truss_section_figures.dart';
import 'truss_figures.dart';

/// Joints or Sections — the third item for `truss-analysis-methods`.
///
/// Both methods will get any member force in a determinate truss. Which one
/// is faster depends entirely on what is being asked for and where it sits,
/// and on an exam the difference is several minutes. One member deep in the
/// truss wants a cut. Several members around one connection want joint
/// equilibrium. And whichever is used, the support reactions come first,
/// because both methods need to know what is pushing back.
class JointsOrSectionsGame extends StatefulWidget {
  const JointsOrSectionsGame({super.key});

  @override
  State<JointsOrSectionsGame> createState() => _JointsOrSectionsGameState();
}

/// What to reach for.
enum Route3 { joints, sections, reactions }

extension Route3Words on Route3 {
  String get plain => switch (this) {
        Route3.joints => 'The method of joints',
        Route3.sections => 'The method of sections: one cut',
        Route3.reactions =>
          'Neither yet: the support reactions have to come first',
      };
}

@immutable
class RouteRound {
  const RouteRound({
    required this.subject,
    required this.asked,
    required this.target,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;

  /// The member the question is about, lit on the drawing.
  final int target;
  final Route3 answer;
  final String why;
  final String source;
}

/// The lesson's own parallel chord truss.
const _truss = Truss(
  joints: [
    Joint('A', Offset(0, 0)),
    Joint('B', Offset(4, 0)),
    Joint('C', Offset(8, 0)),
    Joint('D', Offset(12, 0)),
    Joint('E', Offset(4, 3)),
    Joint('F', Offset(8, 3)),
  ],
  members: [
    (0, 1),
    (1, 2),
    (2, 3),
    (4, 5),
    (0, 4),
    (1, 4),
    (1, 5),
    (2, 5),
    (3, 5),
  ],
);

const routeRounds = <RouteRound>[
  RouteRound(
    subject: 'one chord in the middle',
    asked:
        'The question asks for the force in the middle bottom chord and '
        'nothing else. The reactions are already known.',
    target: 1,
    answer: Route3.sections,
    why:
        'Sections. One cut through the panel and one moment equation gets it, '
        'against four or five joints worked in turn to reach the same member. '
        'This is exactly what the method is for, and the lesson\'s tip says '
        'so: one member, deep in the truss, means cut.',
    source: 'str-tam-q2',
  ),
  RouteRound(
    subject: 'everything at the end',
    asked:
        'The question asks for the forces in BOTH members meeting at the '
        'left support. The reactions are known.',
    target: 4,
    answer: Route3.joints,
    why:
        'Joints. Two unknowns at that joint and two equations, so it falls '
        'out immediately, and a cut would be no help at all because you want '
        'both members rather than one. Near a support the method of joints is '
        'usually the shortest thing there is.',
    source: 'str-tam-q1',
  ),
  RouteRound(
    subject: 'nothing known yet',
    asked:
        'The question asks for a chord force in the middle of the truss, and '
        'the supports have not been dealt with at all.',
    target: 1,
    answer: Route3.reactions,
    why:
        'Neither yet. Both methods need to know what the supports are '
        'pushing with: a cut leaves you holding a piece of truss whose only '
        'other external force is the reaction, and a joint at the support is '
        'the reaction. Reactions first, every time, and they come from the '
        'whole truss as one free body.',
    source: 'str-tam-q2',
  ),
  RouteRound(
    subject: 'a diagonal in the middle',
    asked:
        'The force in the middle diagonal is wanted, with the reactions '
        'already in hand.',
    target: 6,
    answer: Route3.sections,
    why:
        'Sections again. A cut across the panel and the vertical force '
        'equation gives the diagonal directly, because the chords are '
        'horizontal and cannot help carry the shear. Marching joint to joint '
        'from the support would reach it eventually and take four times as '
        'long.',
    source: 'str-tam-q2',
  ),
  RouteRound(
    subject: 'a whole connection',
    asked:
        'A connection design needs every member force arriving at the top '
        'joint on the left. The reactions are known.',
    target: 5,
    answer: Route3.joints,
    why:
        'Joints. When what you want is everything at ONE connection, that '
        'joint is the free body to draw: the question and the method line up '
        'exactly. Sections is the wrong shape of tool here, because a cut '
        'gives you three member forces chosen by where the cut fell rather '
        'than by which joint you care about.',
    source: 'str-tam-q1',
  ),
  RouteRound(
    subject: 'a fresh truss and one member',
    asked:
        'A truss you have not touched, and the question wants the top chord '
        'force in the far panel only.',
    target: 3,
    answer: Route3.reactions,
    why:
        'Neither yet, again, and it is worth the repetition because it is '
        'the step people skip. Even the fastest possible cut needs the '
        'reaction on the piece you keep. Work the whole truss as one free '
        'body first, get the reactions, and then make the cut.',
    source: 'str-tam-q2',
  ),
];

class _JointsOrSectionsGameState extends State<JointsOrSectionsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'joints-or-sections',
    chapterId: 'structural',
    total: routeRounds.length,
    sourceProblemIdOf: (round) => routeRounds[round].source,
  )..addListener(_onSession);

  Route3? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  RouteRound get _round => routeRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Joints or Sections',
        closing:
            'One member deep in the truss wants a cut. Several members at '
            'one connection want joint equilibrium. Near a support the joints '
            'are quickest because the reaction is already there. And whatever '
            'the question, the support reactions come first, from the whole '
            'truss taken as one free body: neither method can start without '
            'them.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: trussRouteBrief,
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
            'WHAT WOULD YOU REACH FOR',
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
                  painter: SectionPointsPainter(
                    truss: _truss,
                    target: r.target,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (final option in Route3.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Route3.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE SHORT WAY' : 'THE LONGER WAY',
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
