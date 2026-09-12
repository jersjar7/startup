import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'truss_section_figures.dart';
import 'beam_figures.dart' show Prop;
import 'truss_figures.dart';

/// Where Do You Take Moments — the first item for `truss-analysis-methods`.
///
/// Choosing the cut is one skill and the statics chapter already drills it.
/// What comes after it is a second skill and the one that makes the method
/// of sections worth using: the point you sum moments about decides how many
/// unknowns survive the equation. Put it where the other two cut members
/// cross and they both vanish, leaving the member you wanted on its own. Put
/// it anywhere else and you have three unknowns in one equation and nothing
/// has been gained over the method of joints.
class WhereDoYouTakeMomentsGame extends StatefulWidget {
  const WhereDoYouTakeMomentsGame({super.key});

  @override
  State<WhereDoYouTakeMomentsGame> createState() =>
      _WhereDoYouTakeMomentsGameState();
}

/// Which of the marked points to sum moments about.
enum Pivot { first, second, neither }

@immutable
class PivotRound {
  const PivotRound({
    required this.subject,
    required this.asked,
    required this.truss,
    required this.cut,
    required this.target,
    required this.anchors,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Truss truss;
  final Cut cut;

  /// The member whose force the round wants.
  final int target;
  final List<Anchor> anchors;
  final Pivot answer;
  final String why;
  final String source;

  String label(Pivot which) => switch (which) {
        Pivot.first => 'Point ${anchors.first.name}',
        Pivot.second => 'Point ${anchors.last.name}',
        Pivot.neither =>
          'Neither: the other two are parallel, so sum vertical forces',
      };
}

/// The lesson's own truss: parallel chords, four meter panels, three meters
/// deep. Member order is bottom chords, top chords, end diagonals,
/// verticals, then the two inner diagonals.
const _truss = Truss(
  joints: [
    Joint('A', Offset(0, 0)),
    Joint('B', Offset(4, 0)),
    Joint('C', Offset(8, 0)),
    Joint('D', Offset(12, 0)),
    Joint('E', Offset(16, 0)),
    Joint('F', Offset(4, 3)),
    Joint('G', Offset(8, 3)),
    Joint('H', Offset(12, 3)),
  ],
  supports: {0: Prop.pin, 4: Prop.roller},
  members: [
    (0, 1),
    (1, 2),
    (2, 3),
    (3, 4),
    (5, 6),
    (6, 7),
    (0, 5),
    (4, 7),
    (1, 5),
    (2, 6),
    (3, 7),
    (5, 2),
    (7, 2),
  ],
);

const pivotRounds = <PivotRound>[
  PivotRound(
    subject: 'the lesson\'s own bottom chord',
    asked:
        'The cut severs the bottom chord BC, the top chord FG and the '
        'diagonal FC. The force wanted is in the BOTTOM chord.',
    truss: _truss,
    cut: Cut('section', Offset(6, -1.2), Offset(6, 4.2)),
    target: 1,
    anchors: [Anchor('P', Offset(4, 3)), Anchor('Q', Offset(8, 0))],
    answer: Pivot.first,
    why:
        'Point P, where the top chord and the diagonal meet. Both of those '
        'pass through it, so neither has a lever arm about it and both drop '
        'straight out of the moment equation, leaving the bottom chord force '
        'times the three meter depth against the moment of everything to the '
        'left. One equation, one unknown. That is the whole of the method of '
        'sections.',
    source: 'str-tam-q2',
  ),
  PivotRound(
    subject: 'the top chord instead',
    asked:
        'The same cut through the same three members, but now the force '
        'wanted is in the TOP chord.',
    truss: _truss,
    cut: Cut('section', Offset(6, -1.2), Offset(6, 4.2)),
    target: 4,
    anchors: [Anchor('P', Offset(4, 3)), Anchor('Q', Offset(8, 0))],
    answer: Pivot.second,
    why:
        'Point Q, down at the bottom of the panel, where the bottom chord '
        'and the diagonal meet. The point moves with the member you are '
        'after: you always put it where the two you do NOT want cross. Same '
        'cut, same three members, different question, different pivot.',
    source: 'str-tam-q2',
  ),
  PivotRound(
    subject: 'the diagonal',
    asked:
        'The same cut again, and now the force wanted is in the DIAGONAL '
        'between the chords.',
    truss: _truss,
    cut: Cut('section', Offset(6, -1.2), Offset(6, 4.2)),
    target: 11,
    anchors: [Anchor('P', Offset(4, 3)), Anchor('Q', Offset(8, 0))],
    answer: Pivot.neither,
    why:
        'Neither point will do it. The two members you want rid of are the '
        'top and bottom chords, and in a parallel chord truss they never '
        'meet: their intersection is off at infinity. So no moment equation '
        'kills both. Use the vertical force equation instead: the chords are '
        'horizontal and carry no vertical component, so the diagonal alone '
        'has to balance the shear across the cut.',
    source: 'str-tam-q2',
  ),
  PivotRound(
    subject: 'a cut in the first panel',
    asked:
        'A cut near the left support severs the bottom chord AB and the end '
        'diagonal AF, and nothing else. The force wanted is in the BOTTOM '
        'chord.',
    truss: _truss,
    cut: Cut('section', Offset(2, -1.2), Offset(2, 4.2)),
    target: 0,
    anchors: [Anchor('P', Offset(4, 3)), Anchor('Q', Offset(8, 0))],
    answer: Pivot.first,
    why:
        'Point P, at the top of the panel where the end diagonal lands. Only '
        'two members are cut here, so there is only one to get rid of, and '
        'taking moments where it ends does it. A cut through two members is '
        'easier than one through three, and it is worth looking for one near '
        'the end of a truss before reaching for anything cleverer.',
    source: 'str-tam-q2',
  ),
  PivotRound(
    subject: 'the far panel',
    asked:
        'A cut through the third panel severs the bottom chord CD, the top '
        'chord GH and the diagonal HC. The force wanted is in the TOP chord.',
    truss: _truss,
    cut: Cut('section', Offset(10, -1.2), Offset(10, 4.2)),
    target: 5,
    anchors: [Anchor('P', Offset(12, 3)), Anchor('Q', Offset(8, 0))],
    answer: Pivot.second,
    why:
        'Point Q, back at joint C, where the bottom chord and the diagonal '
        'both arrive. Note that the pivot sits outside the piece of truss you '
        'kept: it is a point in space, not a joint you are analyzing, and '
        'putting it wherever the unwanted members cross is the only rule.',
    source: 'str-tam-q2',
  ),
  PivotRound(
    subject: 'the diagonal in the far panel',
    asked:
        'The same cut through the third panel, and the force wanted is in '
        'the DIAGONAL.',
    truss: _truss,
    cut: Cut('section', Offset(10, -1.2), Offset(10, 4.2)),
    target: 12,
    anchors: [Anchor('P', Offset(12, 3)), Anchor('Q', Offset(8, 0))],
    answer: Pivot.neither,
    why:
        'Neither, for the same reason as before: the two chords are parallel '
        'and never cross. Any time the member you want is a diagonal in a '
        'parallel chord truss, stop looking for a pivot and sum the vertical '
        'forces. It is the shorter route anyway, and it is why the diagonals '
        'of such a truss are said to carry the shear.',
    source: 'str-tam-q2',
  ),
];

class _WhereDoYouTakeMomentsGameState
    extends State<WhereDoYouTakeMomentsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'where-do-you-take-moments',
    chapterId: 'structural',
    total: pivotRounds.length,
    sourceProblemIdOf: (round) => pivotRounds[round].source,
  )..addListener(_onSession);

  Pivot? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  PivotRound get _round => pivotRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Where Do You Take Moments',
        closing:
            'Put the pivot where the two members you do NOT want cross, and '
            'both of them fall out of the equation because neither has a '
            'lever arm about it. The point moves with the member you are '
            'after, and it can sit outside the piece of truss you kept. When '
            'the unwanted pair is the two chords of a parallel chord truss '
            'they never cross at all, and the vertical force equation is the '
            'way in instead.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: momentCenterBrief,
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
            'WHICH POINT KILLS THE OTHER TWO',
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
            height: 238,
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
                    truss: r.truss,
                    cut: r.cut,
                    target: r.target,
                    anchors: r.anchors,
                    picked: _picked == Pivot.first
                        ? 0
                        : (_picked == Pivot.second ? 1 : null),
                    answer: !answered
                        ? null
                        : (r.answer == Pivot.first
                            ? 0
                            : (r.answer == Pivot.second ? 1 : null)),
                    locked: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\sum M_{point} = 0$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Pivot.values) ...[
            _Choice(
              label: r.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Pivot.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE PIVOT' : 'NOT THAT ONE',
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
