import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'column_figures.dart';
import 'lesson_brief.dart';

/// Buckle or Squash — the third item for `column-buckling`.
///
/// Euler's formula is not always allowed. It describes a column bending away
/// sideways while the material is still elastic, and a stocky column never
/// gets the chance: it reaches its yield stress and squashes first. The lesson
/// says so in a line, and its hardest problem asks the question directly by
/// making you check the answer against the yield stress.
///
/// One curve settles it. Euler's hyperbola falls away as the column gets
/// slenderer, the yield stress caps the short end, and where they cross is the
/// slenderness that divides the two. So the column is put on that curve and
/// the answer is which side of the crossing it landed.
class BuckleOrSquashGame extends StatefulWidget {
  const BuckleOrSquashGame({super.key});

  @override
  State<BuckleOrSquashGame> createState() => _BuckleOrSquashGameState();
}

@immutable
class SlenderRound {
  const SlenderRound({
    required this.subject,
    required this.setting,
    required this.post,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Post post;
  final String why;
  final String source;

  Governs get answer => post.governs;
}

const slenderRounds = <SlenderRound>[
  SlenderRound(
    subject: 'the lesson\'s own slender column',
    setting:
        'Six meters between pinned ends, a minimum radius of gyration of '
        'forty millimeters, ordinary steel that yields at two hundred and '
        'fifty.',
    post: Post(
      length: 6000,
      top: End.pinned,
      bottom: End.pinned,
      radius: 40,
    ),
    why:
        'It buckles, and Euler is allowed. The slenderness is a hundred and '
        'fifty, well to the right of the crossing, and the stress it goes at '
        'is eighty eight against a yield of two hundred and fifty. The steel '
        'never gets anywhere near its strength: the column simply bows out of '
        'the way first.',
    source: 'mm-cb-q3',
  ),
  SlenderRound(
    subject: 'a stub of the same column',
    setting:
        'The same section and the same steel, but only one and a half meters '
        'long.',
    post: Post(
      length: 1500,
      top: End.pinned,
      bottom: End.pinned,
      radius: 40,
    ),
    why:
        'It squashes. A slenderness of thirty seven puts it well to the left '
        'of the crossing, where Euler\'s hyperbola is up in the clouds: the '
        'formula would say it buckles at well over a thousand megapascals, and '
        'the steel gives up at two hundred and fifty long before that. Euler '
        'does not apply, and quoting it here would be nonsense.',
    source: 'mm-cb-q3',
  ),
  SlenderRound(
    subject: 'right on the line',
    setting:
        'The same section again, three and a half meters long. Look at where '
        'the mark lands.',
    post: Post(
      length: 3556,
      top: End.pinned,
      bottom: End.pinned,
      radius: 40,
    ),
    why:
        'Neither, cleanly: this column is sitting on the crossing, where the '
        'buckling stress and the yield stress are the same number. Around '
        'here a real column does worse than either curve promises, because '
        'small crookednesses and leftover stresses in the steel matter most '
        'exactly here. It is why design codes use a curve through this region '
        'rather than the two straight ideas.',
    source: 'mm-cb-q3',
  ),
  SlenderRound(
    subject: 'a stronger steel, same column',
    setting:
        'The six meter column again, this time in a high strength steel that '
        'yields at four hundred and fifty rather than two hundred and fifty.',
    post: Post(
      length: 6000,
      top: End.pinned,
      bottom: End.pinned,
      radius: 40,
      yieldStress: 450,
    ),
    why:
        'It still buckles, at exactly the same eighty eight megapascals it did '
        'before. Look at Euler\'s formula and see what is not in it: the yield '
        'stress. Paying for stronger steel has bought this column NOTHING, '
        'because it never reaches its strength either way. What the stronger '
        'steel did do is move the crossing to the left, so it helps stockier '
        'columns and not this one.',
    source: 'mm-cb-q3',
  ),
  SlenderRound(
    subject: 'a stocky column in that stronger steel',
    setting:
        'A two meter column of the same section, in the four hundred and fifty '
        'steel.',
    post: Post(
      length: 2000,
      top: End.pinned,
      bottom: End.pinned,
      radius: 40,
      yieldStress: 450,
    ),
    why:
        'It squashes, and here the stronger steel earns its money: a stocky '
        'column fails at its yield stress, so a higher yield is a higher '
        'capacity, pound for pound. Slender columns care about E and about '
        'length, stocky ones care about strength. Knowing which you have in '
        'front of you is the whole point of the crossing.',
    source: 'mm-cb-q3',
  ),
  SlenderRound(
    subject: 'a flagpole in ordinary steel',
    setting:
        'Three meters of the same section, fixed at the base with nothing at '
        'the top. Remember what that does to the effective length.',
    post: Post(
      length: 3000,
      top: End.free,
      bottom: End.fixed,
      radius: 40,
    ),
    why:
        'It buckles. Three meters looks stocky until the ends are read: with '
        'nothing holding the top the effective length is six meters, the '
        'slenderness is a hundred and fifty again, and it lands in exactly the '
        'same place as the first round. The slenderness that counts is the '
        'EFFECTIVE one, which is why the two items in this lesson belong '
        'together.',
    source: 'mm-cb-q3',
  ),
];

class _BuckleOrSquashGameState extends State<BuckleOrSquashGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'buckle-or-squash',
    chapterId: 'mechanics-materials',
    total: slenderRounds.length,
    sourceProblemIdOf: (round) => slenderRounds[round].source,
  )..addListener(_onSession);

  Governs? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SlenderRound get _round => slenderRounds[_session.round];

  String _label(Governs g) => switch (g) {
        Governs.buckling => 'It buckles: Euler gives the load',
        Governs.yielding => 'It squashes: Euler does not apply',
        Governs.together => 'Neither: it is sitting on the crossing',
      };

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Buckle or Squash',
        closing:
            'Euler describes a column bowing sideways while the material is '
            'still elastic. A stocky column squashes before it gets the '
            'chance, so the formula is only allowed when the stress it gives '
            'comes out below yield. And Euler has no yield stress in it at '
            'all: a stronger steel does nothing whatever for a slender column.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: slenderBrief,
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
            'WHICH FAILURE COMES FIRST',
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
              height: 190,
              child: CustomPaint(
                painter: ColumnCurvePainter(post: r.post),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'the dot is this column. the dashed cap is its yield stress',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 14),
          for (final g in Governs.values) ...[
            _Choice(
              label: _label(g),
              selected: _picked == g,
              locked: answered,
              isTruth: g == r.answer,
              onTap: answered ? null : () => setState(() => _picked = g),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 8),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHAT GIVES' : 'THE OTHER ONE',
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
