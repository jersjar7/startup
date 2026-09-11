import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'composite_figures.dart';
import 'lesson_brief.dart';

/// Same Strain, Different Stress — the second item for
/// `transformed-sections-plastic`.
///
/// The lesson's third problem is one sentence long and it is the sentence the
/// whole method rests on: the stiffer material carries n times the stress of
/// the transformed one at the same fiber. Underneath it is a physical fact
/// that is easier to hold on to than the formula. Two materials glued
/// together cannot stretch by different amounts at the line where they meet,
/// so the STRAIN is the same on both sides of it and the STRESS jumps.
///
/// No arithmetic: the question is which of the two quantities is equal across
/// the join and which is not.
class SameStrainGame extends StatefulWidget {
  const SameStrainGame({super.key});

  @override
  State<SameStrainGame> createState() => _SameStrainGameState();
}

/// What a round asks about the two sides of the join.
enum Across { stiffer, softer, same }

@immutable
class JoinRound {
  const JoinRound({
    required this.subject,
    required this.asked,
    required this.beam,
    required this.join,
    required this.why,
    required this.source,
    required this.about,
  });

  final String subject;

  /// The question, in full.
  final String asked;

  final Composite beam;

  /// The height where the two materials meet.
  final double join;

  /// Whether the round is about stress or about strain.
  final Feels about;

  final String why;
  final String source;

  /// Read off the beam: strain is the same on both sides, stress is bigger in
  /// the stiffer material by the modular ratio.
  Across get answer {
    if (about == Feels.strain) return Across.same;
    final inStiff = beam.stressAt(join, 20e6, beam.stiffer).abs();
    final inSoft = beam.stressAt(join, 20e6, beam.softer).abs();
    if ((inStiff - inSoft).abs() < inSoft * 0.01) return Across.same;
    return inStiff > inSoft ? Across.stiffer : Across.softer;
  }
}

enum Feels { stress, strain }

const _plated = Composite([
  Slice(Offset(0, 0), Size(150, 12), Made.steel),
  Slice(Offset(25, 12), Size(100, 200), Made.timber),
]);

const _capped = Composite([
  Slice(Offset(0, 0), Size(120, 160), Made.concrete),
  Slice(Offset(15, 160), Size(90, 14), Made.steel),
]);

const _alu = Composite([
  Slice(Offset(0, 0), Size(140, 180), Made.timber),
  Slice(Offset(0, 180), Size(140, 10), Made.aluminum),
]);

final joinRounds = <JoinRound>[
  JoinRound(
    subject: 'steel plate bolted under a timber joist',
    asked:
        'Right at the line where the two meet, which material is carrying '
        'more STRESS?',
    beam: _plated,
    join: 12,
    about: Feels.stress,
    why:
        'The steel, by the modular ratio: about seventeen times more at the '
        'same height. It is stiffer, so for the same amount of stretch it '
        'pushes back much harder. That is all the n in the formula is saying, '
        'and it is why the transformed section gives you the SOFT material\'s '
        'stress and you multiply to get the stiff one\'s.',
    source: 'mom-tsp-q3',
  ),
  JoinRound(
    subject: 'the same join, the other quantity',
    asked:
        'At that same line, which material is under more STRAIN?',
    beam: _plated,
    join: 12,
    about: Feels.strain,
    why:
        'Neither: they are equal. The two are bonded, so a fiber of steel and '
        'the fiber of timber glued to it have to stretch by exactly the same '
        'amount. If they did not, the glue line would have to tear. Equal '
        'strain and unequal stiffness is precisely what makes the stress '
        'unequal, and it is the reason the whole method works.',
    source: 'mom-tsp-q3',
  ),
  JoinRound(
    subject: 'a steel plate on top of a concrete beam',
    asked:
        'At the line where they meet, which carries more STRESS?',
    beam: _capped,
    join: 160,
    about: Feels.stress,
    why:
        'The steel again, this time by about eight. Being on the top face '
        'rather than the bottom changes which one is squashed and which is '
        'stretched, and changes nothing about the ratio between them. The '
        'stiffer material always takes the bigger share wherever it sits.',
    source: 'mom-tsp-q3',
  ),
  JoinRound(
    subject: 'the concrete and steel beam, strain this time',
    asked: 'And which of them is under more STRAIN at that line?',
    beam: _capped,
    join: 160,
    about: Feels.strain,
    why:
        'Equal, and it is worth saying why this is not a trick: strain is how '
        'much something stretches, and two things stuck together stretch '
        'together. Stress is how hard the material pushes back while doing it, '
        'and a stiffer material pushes back harder for the same stretch.',
    source: 'mom-tsp-q3',
  ),
  JoinRound(
    subject: 'an aluminum cap on a timber beam',
    asked: 'Which carries more STRESS at the join?',
    beam: _alu,
    join: 180,
    about: Feels.stress,
    why:
        'The aluminum, by about six. A smaller modular ratio than the steel '
        'cases, and the same answer: it is always the stiffer one. Note what '
        'that means for design, which is that the stiff material attracts load '
        'whether you wanted it to or not.',
    source: 'mom-tsp-q3',
  ),
  JoinRound(
    subject: 'the aluminum and timber beam, strain',
    asked: 'Which is under more STRAIN there?',
    beam: _alu,
    join: 180,
    about: Feels.strain,
    why:
        'Equal, for the third time, and that is the point of asking it three '
        'times. If you remember only one thing from this lesson, make it this: '
        'strain is shared across a bonded join and stress is not. Everything '
        'else, the modular ratio, the widening, the factor of n on the stress, '
        'follows from it.',
    source: 'mom-tsp-q3',
  ),
];

class _SameStrainGameState extends State<SameStrainGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'same-strain',
    chapterId: 'mechanics-materials',
    total: joinRounds.length,
    sourceProblemIdOf: (round) => joinRounds[round].source,
  )..addListener(_onSession);

  Across? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  JoinRound get _round => joinRounds[_session.round];

  String _label(Across a) => switch (a) {
        Across.stiffer => 'The ${_round.beam.stiffer.plain}',
        Across.softer => 'The ${_round.beam.softer.plain}',
        Across.same => 'Neither: they are equal',
      };

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Same Strain, Different Stress',
        closing:
            'Bonded materials stretch together, so the strain matches across '
            'the join and the stress does not. The stiffer one carries n times '
            'the stress at the same height. The transformed section hands you '
            'the soft material\'s stress; multiply by n for the stiff one.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: joinBrief,
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
            'AT THE LINE WHERE THEY MEET',
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
          EngineeringGrid(
            minor: 16,
            major: 80,
            child: SizedBox(
              height: 150,
              child: CustomPaint(
                painter: MadePainter(
                  slices: r.beam.slices,
                  join: r.join,
                  label: 'the join is marked',
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _Key(made: r.beam.stiffer),
              const SizedBox(width: 14),
              _Key(made: r.beam.softer),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\sigma_1 = \dfrac{nMy}{I_T}, \quad \sigma_2 = \dfrac{My}{I_T}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 14),
          for (final a in Across.values) ...[
            _Choice(
              label: _label(a),
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
              title: _session.correct! ? 'THAT IS IT' : 'THE OTHER WAY',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.made});

  final Made made;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: made.tone.withValues(alpha: 0.35),
              border: Border.all(color: AppColors.charcoal, width: 1.2),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Text(made.plain,
              style: AppTheme.mono(size: 11, color: AppColors.ink3)),
        ],
      );
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
