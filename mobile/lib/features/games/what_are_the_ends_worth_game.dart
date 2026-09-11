import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'column_figures.dart';
import 'lesson_brief.dart';

/// What Are the Ends Worth — the first item for `column-buckling`.
///
/// Two of the three problems in this lesson are the same formula with a
/// different number pulled off the same short table, and both of them name the
/// same trap: reading the end conditions wrongly. There are four cases and the
/// handbook gives them to you, so nothing here needs computing. What needs
/// doing is looking at the column and seeing how each end is held.
class WhatAreTheEndsWorthGame extends StatefulWidget {
  const WhatAreTheEndsWorthGame({super.key});

  @override
  State<WhatAreTheEndsWorthGame> createState() =>
      _WhatAreTheEndsWorthGameState();
}

@immutable
class EndsRound {
  const EndsRound({
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

  /// The four the handbook lists, in the order they are offered.
  static const values = [0.5, 0.7, 1.0, 2.0];

  int get answer => values.indexOf(post.k);
}

const endsRounds = <EndsRound>[
  EndsRound(
    subject: 'a temporary shore under a slab',
    setting:
        'A prop stood between a slab and the floor, resting on a plate at each '
        'end. Neither end is bolted down, so neither can stop the prop '
        'turning.',
    post: Post(length: 3000, top: End.pinned, bottom: End.pinned),
    why:
        'One. Pinned at both ends is the base case the whole table is measured '
        'against, and the effective length is the real length. Look at the '
        'buckled shape: one smooth bow from end to end, straight through '
        'nowhere in between.',
    source: 'mm-cb-q1',
  ),
  EndsRound(
    subject: 'a column welded top and bottom',
    setting:
        'A steel column welded into heavy beams at both ends, in a frame that '
        'cannot sway. Neither end can turn.',
    post: Post(length: 4000, top: End.fixed, bottom: End.fixed),
    why:
        'A half. Both ends held against turning, so the column bends into an S '
        'and passes straight through at the quarter points. The distance '
        'between those two points is HALF the column, and that is the length '
        'Euler\'s formula wants. Half the effective length is four times the '
        'load.',
    source: 'mm-cb-q2',
  ),
  EndsRound(
    subject: 'a flagpole',
    setting:
        'A pole set in concrete at its base with nothing at all at the top.',
    post: Post(length: 5000, top: End.free, bottom: End.fixed),
    why:
        'Two, and this is the worst of the four. With nothing at the top, the '
        'pole bends like half of a pinned column that is twice as long, so its '
        'effective length is TWICE what you can see. The lesson warns about it '
        'directly: a column like this carries a sixteenth of what the same '
        'column welded at both ends would.',
    source: 'mm-cb-q1',
  ),
  EndsRound(
    subject: 'one end cast in, the other on a pin',
    setting:
        'A column cast into a thick foundation at the bottom and connected at '
        'the top with a single bolt that lets it rotate.',
    post: Post(length: 5000, top: End.pinned, bottom: End.fixed),
    why:
        'Nought point seven. One end held against turning and one not, so the '
        'shape leaves the base straight and comes back to the pin at the top. '
        'The lesson\'s second problem is exactly this, and reaching for one, '
        'as though both ends were pinned, understates the column by half.',
    source: 'mm-cb-q2',
  ),
  EndsRound(
    subject: 'the same column turned upside down',
    setting:
        'A pinned connection at the bottom and a welded one at the top. The '
        'same two conditions as the last round, the other way up.',
    post: Post(length: 5000, top: End.fixed, bottom: End.pinned),
    why:
        'Nought point seven again. Which end is fixed makes no difference at '
        'all: the table cares that ONE end is held against turning and the '
        'other is not. The buckled shape is simply the last one turned over.',
    source: 'mm-cb-q2',
  ),
  EndsRound(
    subject: 'a sign post beside a road',
    setting:
        'A post bolted rigidly to a concrete base, carrying a sign at the top '
        'that nothing else touches.',
    post: Post(length: 3500, top: End.free, bottom: End.fixed),
    why:
        'Two. The same arrangement as the flagpole wearing a different hat, '
        'and the one people default away from: the lesson says students forget '
        'this case is on the list and reach for one. If nothing holds the top '
        'in place, the factor is two.',
    source: 'mm-cb-q1',
  ),
];

class _WhatAreTheEndsWorthGameState extends State<WhatAreTheEndsWorthGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-are-the-ends-worth',
    chapterId: 'mechanics-materials',
    total: endsRounds.length,
    sourceProblemIdOf: (round) => endsRounds[round].source,
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

  EndsRound get _round => endsRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Are the Ends Worth',
        closing:
            'Four cases and the handbook gives them to you. Both ends pinned '
            'is one. Both fixed is a half. One of each is nought point seven. '
            'Anything with a free end is two, and that is sixteen times weaker '
            'than the fixed pair. Read how each end is held, then look up the '
            'number.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: endsBrief,
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
            'TAP THE EFFECTIVE LENGTH FACTOR',
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
          Row(
            children: [
              Expanded(
                child: EngineeringGrid(
                  minor: 18,
                  major: 90,
                  child: SizedBox(
                    height: 210,
                    child: CustomPaint(
                      painter: PostPainter(post: r.post),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
              if (answered) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: EngineeringGrid(
                    minor: 18,
                    major: 90,
                    child: SizedBox(
                      height: 210,
                      child: CustomPaint(
                        painter: PostPainter(post: r.post, bent: true),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            answered
                ? 'how it stands, and the shape it folds into'
                : 'how each end is held',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < EndsRound.values.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _Choice(
                    label: EndsRound.values[i].toString(),
                    selected: _picked == i,
                    locked: answered,
                    isTruth: i == r.answer,
                    onTap: answered ? null : () => setState(() => _picked = i),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'K, the effective length factor',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE FACTOR' : 'A DIFFERENT CASE',
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
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
        ),
      ),
    );
  }
}
