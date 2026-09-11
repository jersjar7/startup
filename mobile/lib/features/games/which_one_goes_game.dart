import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'corrosion_figures.dart';
import 'lesson_brief.dart';

/// Which One Goes — the first item for `corrosion-material-selection`.
///
/// Both corrosion problems in this lesson are the same question about
/// different metals: put two of them together in the wet and the more active
/// one is eaten. There is nothing to calculate and everything to recognize,
/// which is what a phone is for. Two rounds take one of the four things a
/// corrosion cell needs away instead, because knowing that the cell needs an
/// electrolyte AND a path is how the fix gets designed.
class WhichOneGoesGame extends StatefulWidget {
  const WhichOneGoesGame({super.key});

  @override
  State<WhichOneGoesGame> createState() => _WhichOneGoesGameState();
}

/// Which of the two, or neither.
enum Eaten { left, right, neither }

@immutable
class CoupleRound {
  const CoupleRound({
    required this.subject,
    required this.setting,
    required this.couple,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Couple couple;
  final String why;
  final String source;

  /// Worked out from the pair, never declared.
  Eaten get answer {
    final anode = couple.anode;
    if (anode == null) return Eaten.neither;
    return anode == couple.left ? Eaten.left : Eaten.right;
  }

  String labelFor(Eaten which) => switch (which) {
        Eaten.left => 'The ${couple.left.plain}',
        Eaten.right => 'The ${couple.right.plain}',
        Eaten.neither => 'Neither: no cell forms here',
      };
}

const coupleRounds = <CoupleRound>[
  CoupleRound(
    subject: 'the lesson\'s bracket',
    setting:
        'An aluminum bracket bolted to a copper grounding plate, out in the '
        'rain.',
    couple: Couple(left: Metal.aluminum, right: Metal.copper),
    why:
        'The aluminum. It is the more active of the two, so it becomes the '
        'anode and dissolves while the copper sits there protected. Copper is '
        'the most noble metal in that problem, which is exactly why bolting '
        'anything light-alloy to it out of doors is a detail worth arguing '
        'about.',
    source: 'mat-cms-q1',
  ),
  CoupleRound(
    subject: 'a scratch in the galvanizing',
    setting:
        'Galvanized steel, scratched through to the steel underneath, and '
        'wet.',
    couple: Couple(left: Metal.zinc, right: Metal.steel),
    why:
        'The zinc, and that is the whole point of galvanizing. Zinc is more '
        'active than steel, so the zinc around the scratch corrodes and the '
        'bare steel in the middle of it is protected. Paint cannot do this: a '
        'scratch in paint is where the rust starts, and a scratch in '
        'galvanizing is not.',
    source: 'mat-cms-q2',
  ),
  CoupleRound(
    subject: 'a copper pipe on a steel hanger',
    setting: 'A copper pipe sitting in a steel hanger in a damp plant room.',
    couple: Couple(left: Metal.copper, right: Metal.steel),
    why:
        'The steel, because now it is the more active of the pair. Steel was '
        'the protected one in the first round and it is the victim here: '
        'nothing about a metal decides this on its own. It is always the '
        'metal and the one it is touching, together.',
    source: 'mat-cms-q1',
  ),
  CoupleRound(
    subject: 'the same two metals, indoors and dry',
    setting:
        'An aluminum bracket bolted to a copper plate inside a heated, dry '
        'building. No condensation, ever.',
    couple: Couple(
        left: Metal.aluminum, right: Metal.copper, wet: false),
    why:
        'Neither. A corrosion cell needs four things, and the electrolyte is '
        'one of them: no water, no cell. This is why the same detail can be '
        'fine indoors and a liability on a roof, and why so much of corrosion '
        'design is really drainage.',
    source: 'mat-cms-q1',
  ),
  CoupleRound(
    subject: 'flashing on a steel beam',
    setting:
        'Aluminum flashing over a steel beam on a wet roof, with an '
        'insulating gasket between them.',
    couple: Couple(
        left: Metal.aluminum, right: Metal.steel, connected: false),
    why:
        'Neither, as long as the gasket holds. The fourth thing a cell needs '
        'is an electrical path between the two metals, and that is the one '
        'you can take away with a washer or a gasket when you cannot change '
        'the metals or keep the water out. It is the standard fix for exactly '
        'this pair.',
    source: 'mat-cms-q1',
  ),
  CoupleRound(
    subject: 'a block bolted to a hull on purpose',
    setting:
        'A zinc block is bolted to the steel hull of a boat and left in '
        'seawater.',
    couple: Couple(left: Metal.zinc, right: Metal.steel),
    why:
        'The zinc, and it is there to be eaten. This is the same physics as '
        'the galvanized scratch, sold by the block: a sacrificial anode is '
        'the most active metal you can bolt on, fitted so that it corrodes '
        'instead of the thing you care about, and replaced when it is gone.',
    source: 'mat-cms-q2',
  ),
];

class _WhichOneGoesGameState extends State<WhichOneGoesGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-one-goes',
    chapterId: 'materials',
    total: coupleRounds.length,
    sourceProblemIdOf: (round) => coupleRounds[round].source,
  )..addListener(_onSession);

  Eaten? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  CoupleRound get _round => coupleRounds[_session.round];

  int? _index(Eaten? which) => switch (which) {
        Eaten.left => 0,
        Eaten.right => 1,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which One Goes',
        closing:
            'The more active metal of a pair corrodes and the nobler one is '
            'protected, so no metal is safe or unsafe on its own: steel is '
            'protected next to aluminum and eaten next to copper. A cell '
            'needs two different metals, water, and a path between them. Take '
            'any one of those away, with a gasket or with drainage, and '
            'nothing happens.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: galvanicBrief,
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
            'WHICH ONE CORRODES',
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
          LayoutBuilder(
            builder: (context, box) {
              final size = Size(box.maxWidth, 200);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: answered
                    ? null
                    : (details) {
                        final hit =
                            CouplePainter.at(size, details.localPosition);
                        if (hit == null) return;
                        setState(() =>
                            _picked = hit == 0 ? Eaten.left : Eaten.right);
                      },
                child: EngineeringGrid(
                  minor: 18,
                  major: 90,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: CustomPaint(
                      painter: CouplePainter(
                        couple: r.couple,
                        picked: _index(_picked),
                        answer: answered ? _index(r.answer) : null,
                        locked: answered,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          for (final option in Eaten.values) ...[
            _Choice(
              label: r.labelFor(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 6),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'NOT THAT ONE',
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
