import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'rigid_figures.dart';

/// Beam or Blanket — the first item for `rigid-pavement`.
///
/// A concrete slab bends across a wheel load and hands it to a wide patch
/// of ground. An asphalt section passes the load down through its courses
/// to a narrow one. Everything else about the two kinds of pavement follows
/// from that difference.
class BeamOrBlanketGame extends StatefulWidget {
  const BeamOrBlanketGame({super.key});

  @override
  State<BeamOrBlanketGame> createState() => _BeamOrBlanketGameState();
}

@immutable
class LoadPathRound {
  const LoadPathRound({
    required this.subject,
    required this.asked,
    required this.load,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Loaded load;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const _rigid = Loaded(kind: Surfacing.rigid);
const _flexible = Loaded(kind: Surfacing.flexible);
const _rigidOnSoft = Loaded(kind: Surfacing.rigid, subgradeStiffness: 100);

const loadPathRounds = <LoadPathRound>[
  LoadPathRound(
    subject: 'how a slab carries a wheel',
    asked:
        'A wheel presses on a concrete slab. How does the load reach the '
        'ground?',
    load: _rigid,
    options: [
      'Straight down through the slab, in a narrow column',
      'The slab bends like a beam and spreads the load over a wide patch of '
          'subgrade',
      'The slab compresses under the wheel',
      'Through the joints only',
    ],
    answer: 1,
    why:
        'It bends. The slab is stiff enough to act as a beam across the '
        'load, so the pressure that reaches the subgrade is spread over an '
        'area many times the tire patch, and is correspondingly small.',
    source: 'trans-rp-q1',
  ),
  LoadPathRound(
    subject: 'and how an asphalt section does',
    asked: 'The same wheel on a flexible pavement. What happens instead?',
    load: _flexible,
    options: [
      'It bends the same way',
      'Each course passes the load down to the next, spreading it only a '
          'little on the way',
      'The load disappears into the base',
      'The load is carried by the surface alone',
    ],
    answer: 1,
    why:
        'It is handed down, course by course, spreading a little at each. '
        'That is why a flexible section needs several courses and why each '
        'of them has to be strong in its own right: nothing bridges, '
        'everything passes it on.',
    source: 'trans-rp-q1',
  ),
  LoadPathRound(
    subject: 'a soft spot underneath',
    asked:
        'There is a soft patch in the subgrade, a few feet across. Which '
        'pavement minds less?',
    load: _rigidOnSoft,
    options: [
      'The rigid slab, which bridges it',
      'The flexible section',
      'Both equally',
      'Neither: a soft spot is fatal to both',
    ],
    answer: 0,
    why:
        'The slab, which bridges the soft patch the way a beam bridges a '
        'gap. A flexible section has nothing to bridge with, so it settles '
        'into the soft spot and the surface follows. This is the practical '
        'reason rigid pavement is chosen over weak or variable ground.',
    source: 'trans-rp-q1',
  ),
  LoadPathRound(
    subject: 'what each one is designed on',
    asked:
        'A flexible pavement is designed on its structural number. What is a '
        'rigid one designed on?',
    load: _rigid,
    options: [
      'Its structural number as well',
      'The thickness of its base',
      'The bending strength of the concrete, which is what resists the slab '
          'flexing',
      'The number of joints',
    ],
    answer: 2,
    why:
        'The concrete\'s bending strength, its modulus of rupture, because '
        'bending is how the slab carries the load. The two design methods '
        'are not versions of each other: they follow the two different ways '
        'the load actually travels.',
    source: 'trans-rp-q1',
  ),
  LoadPathRound(
    subject: 'what it costs',
    asked:
        'Rigid pavement tolerates a weak subgrade better. Why is it not used '
        'everywhere?',
    load: _rigid,
    options: [
      'It costs more to build in the first place',
      'It cannot carry trucks',
      'It wears out faster',
      'It cannot be used on curves',
    ],
    answer: 0,
    why:
        'Price, at the start. Concrete costs more up front than asphalt, and '
        'the choice usually comes down to the whole life: heavy traffic, a '
        'long service life and a poor subgrade favor the slab, and lighter '
        'traffic on decent ground favors asphalt.',
    source: 'trans-rp-q1',
  ),
  LoadPathRound(
    subject: 'the two pictures',
    asked:
        'Which pair of words best separates the two kinds of pavement?',
    load: _flexible,
    options: [
      'Thick and thin',
      'Cheap and expensive',
      'A beam that bridges, and a blanket that passes the load down',
      'Old and modern',
    ],
    answer: 2,
    why:
        'Beam against blanket. Hold that picture and the rest follows: why '
        'the slab needs joints and the asphalt does not, why one is designed '
        'on bending strength and the other on layer coefficients, and why '
        'the subgrade matters so much less under concrete.',
    source: 'trans-rp-q1',
  ),
];

class _BeamOrBlanketGameState extends State<BeamOrBlanketGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'beam-or-blanket',
    chapterId: 'transportation',
    total: loadPathRounds.length,
    sourceProblemIdOf: (round) => loadPathRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  LoadPathRound get _round => loadPathRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Beam or Blanket',
        closing:
            'A concrete slab bends across the load and hands it to a wide '
            'patch of ground, so it bridges soft spots and minds the '
            'subgrade far less. An asphalt section passes the load down '
            'course by course, so every course has to be strong. One is '
            'designed on bending strength, the other on a structural '
            'number.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: rigidVsFlexibleBrief,
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
            'HOW THE LOAD GETS DOWN',
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
                  painter: SlabPainter(
                    load: r.load,
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
