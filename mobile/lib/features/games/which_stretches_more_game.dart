import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'axial_figures.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Which Stretches More — the first item for
/// `axial-stress-strain-deformation`.
///
/// One formula holds this lesson together and it has four things in it: how
/// hard you pull, how long the bar is, how fat it is, and what it is made of.
/// Two of those make it stretch more and two make it stretch less, and knowing
/// which is which is worth more on an exam than being able to divide.
///
/// So two bars are drawn to ONE scale, differing in one thing or in two, and
/// the answer is which stretches more. Two rounds change two things at once so
/// that they cancel, and the answer is that there is nothing between them.
class WhichStretchesMoreGame extends StatefulWidget {
  const WhichStretchesMoreGame({super.key});

  @override
  State<WhichStretchesMoreGame> createState() =>
      _WhichStretchesMoreGameState();
}

@immutable
class StretchRound {
  const StretchRound({
    required this.subject,
    required this.setting,
    required this.bars,
    required this.labels,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final List<Bar> bars;
  final List<String> labels;
  final String why;
  final String source;

  /// Minus one means there is nothing between them. Worked out from the bars,
  /// never declared beside the round.
  int get answer {
    final a = bars[0].stretch;
    final b = bars[1].stretch;
    if ((a - b).abs() < a * 0.02) return -1;
    return a > b ? 0 : 1;
  }
}

const moveMoreRounds = <StretchRound>[
  StretchRound(
    subject: 'the same bar, pulled harder',
    setting:
        'Two identical steel bars. The lower one is being pulled with twice '
        'the force.',
    bars: [
      Bar(length: 2000, area: 400, load: 20000, stuff: Stuff.steel),
      Bar(length: 2000, area: 400, load: 40000, stuff: Stuff.steel),
    ],
    labels: ['2 m, 400 sq mm, steel, 20 kN', '2 m, 400 sq mm, steel, 40 kN'],
    why:
        'The lower one, and by exactly double. The load sits on the top of the '
        'fraction, so twice the pull is twice the stretch, and nothing else '
        'about the bar changed. This is the one everybody gets, and it is '
        'worth being sure of before the rounds where two things move at once.',
    source: 'mm-asd-q2',
  ),
  StretchRound(
    subject: 'the same bar, twice as long',
    setting:
        'The same steel and the same pull, but the lower bar is twice the '
        'length.',
    bars: [
      Bar(length: 1500, area: 400, load: 25000, stuff: Stuff.steel),
      Bar(length: 3000, area: 400, load: 25000, stuff: Stuff.steel),
    ],
    labels: ['1.5 m, 400 sq mm, steel, 25 kN', '3 m, 400 sq mm, steel, 25 kN'],
    why:
        'The longer one, and again by double. Length is on the top as well. '
        'Every millimeter of the bar stretches by the same fraction of itself, '
        'so twice as many millimeters is twice as much movement. The STRESS in '
        'the two is identical, which is worth noticing: length does not appear '
        'in P over A at all.',
    source: 'mm-asd-q2',
  ),
  StretchRound(
    subject: 'the same bar, made fatter',
    setting:
        'Same length, same pull, same steel. The lower bar has four times the '
        'cross-section, so it is drawn twice as thick.',
    bars: [
      Bar(length: 2500, area: 300, load: 30000, stuff: Stuff.steel),
      Bar(length: 2500, area: 1200, load: 30000, stuff: Stuff.steel),
    ],
    labels: ['2.5 m, 300 sq mm, steel, 30 kN', '2.5 m, 1200 sq mm, steel, 30 kN'],
    why:
        'The thin one, four times as much. Area is underneath, so making a bar '
        'fatter makes it stretch less in proportion. Note how it is drawn: '
        'four times the area is twice the thickness, because the area goes as '
        'the square of the size.',
    source: 'mm-asd-q1',
  ),
  StretchRound(
    subject: 'steel against aluminum',
    setting:
        'Two bars of exactly the same size under exactly the same pull. The '
        'upper is steel and the lower is aluminum.',
    bars: [
      Bar(length: 2000, area: 500, load: 35000, stuff: Stuff.steel),
      Bar(length: 2000, area: 500, load: 35000, stuff: Stuff.aluminum),
    ],
    labels: ['2 m, 500 sq mm, steel, 35 kN', '2 m, 500 sq mm, aluminum, 35 kN'],
    why:
        'The aluminum, by getting on for three to one. The modulus is '
        'underneath with the area, and aluminum is about seventy gigapascals '
        'against steel at two hundred. Same shape, same load, same stress in '
        'both of them, and one moves three times as far.',
    source: 'mm-asd-q2',
  ),
  StretchRound(
    subject: 'longer and pulled harder',
    setting:
        'The lower bar is twice as long AND carries twice the load. Everything '
        'else about the two is the same.',
    bars: [
      Bar(length: 1200, area: 400, load: 15000, stuff: Stuff.steel),
      Bar(length: 2400, area: 400, load: 30000, stuff: Stuff.steel),
    ],
    labels: ['1.2 m, 400 sq mm, steel, 15 kN', '2.4 m, 400 sq mm, steel, 30 kN'],
    why:
        'The lower one, four times over. Both changes are on the top of the '
        'fraction, so they multiply rather than cancel. Two things moving at '
        'once do not automatically settle each other, and which side of the '
        'fraction they sit on is the whole of it.',
    source: 'mm-asd-q2',
  ),
  StretchRound(
    subject: 'longer and fatter together',
    setting:
        'The lower bar is twice as long and has twice the cross-section. The '
        'pull and the material are unchanged.',
    bars: [
      Bar(length: 1500, area: 300, load: 24000, stuff: Stuff.steel),
      Bar(length: 3000, area: 600, load: 24000, stuff: Stuff.steel),
    ],
    labels: ['1.5 m, 300 sq mm, steel, 24 kN', '3 m, 600 sq mm, steel, 24 kN'],
    why:
        'Nothing between them. Length doubled on the top and area doubled '
        'underneath, so they cancel exactly and both bars move the same '
        'distance. They are not carrying the same stress though: the fat one '
        'is at half the stress of the thin one, and only the movement matches.',
    source: 'mm-asd-q2',
  ),
];

class _WhichStretchesMoreGameState extends State<WhichStretchesMoreGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-stretches-more',
    chapterId: 'mechanics-materials',
    total: moveMoreRounds.length,
    sourceProblemIdOf: (round) => moveMoreRounds[round].source,
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

  StretchRound get _round => moveMoreRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Stretches More',
        closing:
            'Load and length are on the top, area and modulus underneath. Put '
            'more of the first two in and it moves further; more of the last '
            'two and it moves less. Read the formula that way once and you '
            'never have to remember which is which again.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: deformationBrief,
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
            'WHICH ONE MOVES FURTHER',
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
          _Pair(
            round: r,
            picked: _picked,
            locked: answered,
            onTap: answered ? null : (i) => setState(() => _picked = i),
          ),
          const SizedBox(height: 8),
          _SameRow(
            selected: _picked == -1,
            locked: answered,
            isTruth: r.answer == -1,
            onTap: answered ? null : () => setState(() => _picked = -1),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'THE OTHER WAY',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Pair extends StatelessWidget {
  const _Pair({
    required this.round,
    required this.picked,
    required this.locked,
    required this.onTap,
  });

  final StretchRound round;
  final int? picked;
  final bool locked;
  final void Function(int)? onTap;

  static const _height = 230.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: _height,
        width: double.infinity,
        child: EngineeringGrid(
          minor: 18,
          major: 90,
          child: LayoutBuilder(
            builder: (context, box) {
              final size = Size(box.maxWidth, _height);
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: BarPairPainter(
                        bars: round.bars,
                        labels: round.labels,
                        picked: picked,
                        truth: round.answer,
                        locked: locked,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  for (var i = 0; i < round.bars.length; i++)
                    _target(i, size),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _target(int i, Size size) {
    final row = BarPairPainter.rowFor(round.bars, size, i);
    return Positioned(
      key: ValueKey('bar-$i'),
      left: 0,
      top: row.top,
      width: size.width,
      height: row.height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap == null ? null : () => onTap!(i),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SameRow extends StatelessWidget {
  const _SameRow({
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color fill;
    if (locked && isTruth) {
      border = AppColors.forest;
      fill = AppColors.forestBg;
    } else if (locked && selected) {
      border = AppColors.error;
      fill = AppColors.errorBg;
    } else if (selected) {
      border = AppColors.ember;
      fill = AppColors.emberBg;
    } else {
      border = AppColors.line;
      fill = AppColors.white;
    }

    return Material(
      key: const ValueKey('same-stretch'),
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 54,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: const Text(
            'Nothing between them',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
        ),
      ),
    );
  }
}
