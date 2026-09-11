import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'column_figures.dart';
import 'lesson_brief.dart';
import 'section_figures.dart';
import 'stress_figures.dart';

/// Which Way Does It Fold — the second item for `column-buckling`.
///
/// Euler's formula says I and the lesson says MINIMUM I, because a column
/// folds about whichever axis it is weakest around and nothing makes it wait
/// for the strong one. Using the larger value is one of the named traps in the
/// first problem and it does not fail safely: it tells you the column is
/// stronger than it is.
///
/// Reading which axis is weaker is looking, not computing: it is about how
/// wide the material is spread each way.
class WhichWayDoesItFoldGame extends StatefulWidget {
  const WhichWayDoesItFoldGame({super.key});

  @override
  State<WhichWayDoesItFoldGame> createState() =>
      _WhichWayDoesItFoldGameState();
}

/// Which axis the column bends about.
enum About { horizontal, vertical, either }

extension AboutWords on About {
  String get plain => switch (this) {
        About.horizontal => 'About the x axis, the horizontal one',
        About.vertical => 'About the y axis, the upright one',
        About.either => 'Neither: it is the same both ways',
      };
}

@immutable
class FoldRound {
  const FoldRound({
    required this.subject,
    required this.setting,
    required this.section,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Profile section;
  final String why;
  final String source;

  /// A column folds about the axis with the SMALLER second moment of area.
  /// Read off the section, never declared.
  About get answer {
    final x = section.ownIx;
    final y = section.ownIy;
    if ((x - y).abs() < 0.02 * (x > y ? x : y)) return About.either;
    return x < y ? About.horizontal : About.vertical;
  }
}

final foldRounds = <FoldRound>[
  FoldRound(
    subject: 'a steel I-beam used as a column',
    setting:
        'A wide flange section, deep one way and much narrower the other.',
    section: iSection(
      depth: 300,
      flangeWidth: 150,
      flangeThickness: 20,
      webThickness: 10,
    ),
    why:
        'About the upright axis, which means the column swings sideways. All '
        'that depth is helping it resist bending the other way and doing '
        'almost nothing here: the material is gathered close to the upright '
        'axis. This is the lesson\'s own warning in one picture, that a wide '
        'flange column is weakest about its minor axis, and it is why they get '
        'braced sideways rather than front to back.',
    source: 'mm-cb-q1',
  ),
  FoldRound(
    subject: 'a timber post on edge',
    setting: 'A hundred wide and three hundred deep.',
    section: boxSection(100, 300),
    why:
        'About the upright axis again. Stand a plank on edge and it is very '
        'stiff the way you are looking at it and floppy the other way, and a '
        'column has no say in which way it goes: it picks the easier one. The '
        'numbers are a factor of nine apart here, since the width counts once '
        'and the depth three times over.',
    source: 'mm-cb-q1',
  ),
  FoldRound(
    subject: 'the same post laid the other way',
    setting: 'Three hundred wide and a hundred deep.',
    section: boxSection(300, 100),
    why:
        'About the horizontal axis this time. Nothing about the timber '
        'changed, only which way up it is, and the weak axis went with it. '
        'Worth noticing that the critical load is exactly the same as the last '
        'round: a column is as strong as its weakest axis whichever way you '
        'turn it.',
    source: 'mm-cb-q1',
  ),
  FoldRound(
    subject: 'a square hollow post',
    setting: 'Two hundred square, with a hundred and forty square hole.',
    section: Profile([
      Piece(Slab.box, Offset.zero, Size(200, 200)),
      Piece(Slab.box, Offset(30, 30), Size(140, 140), hole: true),
    ]),
    why:
        'Neither. The section is the same both ways, so there is no weak axis '
        'to find and the column is equally happy to fold either way. That is '
        'exactly what makes hollow square and round sections good columns: '
        'nothing is wasted propping up a strong axis that will never be '
        'tested.',
    source: 'mm-cb-q1',
  ),
  FoldRound(
    subject: 'a tee section',
    setting:
        'A flange two hundred across on top of a web going down three '
        'hundred.',
    section: teeSection(
      depth: 300,
      flangeWidth: 200,
      flangeThickness: 40,
      webThickness: 30,
    ),
    why:
        'About the upright axis. The flange is wide and the web is thin, so '
        'there is far more spread about the horizontal axis than about the '
        'upright one. Note that the neutral axis of a tee sits high rather '
        'than halfway, which matters for bending stress and does not change '
        'this answer at all: buckling asks only which second moment is '
        'smaller.',
    source: 'mm-cb-q1',
  ),
  FoldRound(
    subject: 'a round tube',
    setting: 'A hundred and sixty across with a ten millimeter wall.',
    section: Profile([
      Piece(Slab.disc, Offset.zero, Size(160, 160)),
      Piece(Slab.disc, Offset(10, 10), Size(140, 140), hole: true),
    ]),
    why:
        'Neither, and a circle is the extreme case of it: every axis through '
        'the middle is the same, so a round tube has no weak direction at all. '
        'A scaffold pole is round for this reason. When every axis is equal, '
        'the minimum I is simply I, and the only thing left to get right is '
        'the effective length.',
    source: 'mm-cb-q1',
  ),
];

class _WhichWayDoesItFoldGameState extends State<WhichWayDoesItFoldGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-way-does-it-fold',
    chapterId: 'mechanics-materials',
    total: foldRounds.length,
    sourceProblemIdOf: (round) => foldRounds[round].source,
  )..addListener(_onSession);

  About? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  FoldRound get _round => foldRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Way Does It Fold',
        closing:
            'A column folds about the axis it is weakest around, which is the '
            'one with the SMALLER second moment of area. Using the bigger one '
            'tells you the column is stronger than it is. A section that is '
            'the same both ways, a square tube or a round one, has no weak '
            'axis to find, and that is what makes it a good column.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: weakAxisBrief,
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
            'WHICH AXIS DOES IT BEND ABOUT',
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
          EngineeringGrid(
            minor: 18,
            major: 90,
            child: SizedBox(
              height: 200,
              child: CustomPaint(
                painter: AxisPainter(
                  profile: r.section,
                  highlight: _picked == About.horizontal
                      ? true
                      : _picked == About.vertical
                          ? false
                          : null,
                  locked: answered,
                  truth: answered
                      ? (r.answer == About.horizontal
                          ? true
                          : r.answer == About.vertical
                              ? false
                              : null)
                      : null,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (final a in About.values) ...[
            _Choice(
              label: a.plain,
              selected: _picked == a,
              locked: answered,
              isTruth: a == r.answer,
              onTap: answered ? null : () => setState(() => _picked = a),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 8),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE WEAK ONE' : 'THE OTHER WAY',
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
