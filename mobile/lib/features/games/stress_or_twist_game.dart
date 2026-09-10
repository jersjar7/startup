import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'torsion_figures.dart';

/// Stress or Twist — the second item for `torsion`.
///
/// Two formulas, and the difference between them is worth more than either.
/// The stress carries T, c and J. The angle of twist carries T, L, G and J.
/// So the length is in one and not the other, and the shear modulus is in one
/// and not the other, which means a longer shaft twists further and is not one
/// bit more stressed.
///
/// So no arithmetic. Something about the shaft is changed and the answer is
/// which of the two moves. There is no answer for the stress moving on its
/// own, and the reason is worth carrying: c and J are locked together on a
/// round shaft, so anything that changes the stress changes the twist as well.
class StressOrTwistGame extends StatefulWidget {
  const StressOrTwistGame({super.key});

  @override
  State<StressOrTwistGame> createState() => _StressOrTwistGameState();
}

/// What a change moves.
enum Moves { twistOnly, both, neither }

@immutable
class ChangeShaftRound {
  const ChangeShaftRound({
    required this.subject,
    required this.change,
    required this.before,
    required this.after,
    required this.why,
    required this.source,
  });

  final String subject;
  final String change;
  final Shaft before;
  final Shaft after;
  final String why;
  final String source;

  bool get _stressMoved =>
      (after.shearStress - before.shearStress).abs() >
          before.shearStress * 0.01;
  bool get _twistMoved =>
      (after.twist - before.twist).abs() > before.twist * 0.01;

  /// Worked out by putting both shafts through both formulas, never declared.
  Moves get answer {
    if (_stressMoved && _twistMoved) return Moves.both;
    if (_twistMoved) return Moves.twistOnly;
    return Moves.neither;
  }
}

const shaftRounds = <ChangeShaftRound>[
  ChangeShaftRound(
    subject: 'the same shaft, twice as long',
    change:
        'A drive shaft is replaced by one exactly the same in section and '
        'material, but twice the length. The same torque goes through it.',
    before: Shaft(outerD: 50, length: 1000),
    after: Shaft(outerD: 50, length: 2000),
    why:
        'Only the twist, and it doubles. The length is in the twist formula '
        'and it is nowhere in the stress formula at all, so every millimeter '
        'of this shaft is stressed exactly as it was. A long shaft is not a '
        'weaker shaft. It is a floppier one.',
    source: 'mm-tor-q2',
  ),
  ChangeShaftRound(
    subject: 'twice the torque',
    change: 'The same shaft, driven twice as hard.',
    before: Shaft(outerD: 50, torque: 400000),
    after: Shaft(outerD: 50, torque: 800000),
    why:
        'Both, and both double. Torque is on the top of each formula, so it '
        'scales the two together. This is the one everybody expects, and it is '
        'worth having in front of you before the rounds where only one of them '
        'moves.',
    source: 'mm-tor-q1',
  ),
  ChangeShaftRound(
    subject: 'a softer material',
    change:
        'The steel shaft is swapped for an aluminum one of identical '
        'dimensions. Aluminum has about a third of the shear modulus.',
    before: Shaft(outerD: 50, g: 80000),
    after: Shaft(outerD: 50, g: 27000),
    why:
        'Only the twist, and it nearly trebles. The shear modulus sits with '
        'the length in the twist formula and never appears in the stress one. '
        'The aluminum shaft carries exactly the same shear stress as the steel '
        'did, and winds up almost three times as far doing it.',
    source: 'mm-tor-q2',
  ),
  ChangeShaftRound(
    subject: 'bored out down the middle',
    change:
        'The same shaft, the same outside diameter, with a forty millimeter '
        'hole bored down its length.',
    before: Shaft(outerD: 80),
    after: Shaft(outerD: 80, innerD: 40),
    why:
        'Both, and both go up. Taking material out lowers J, which is '
        'underneath in each formula, so the stress rises and the twist rises '
        'together. Note how little: a hole half the diameter takes only a '
        'sixteenth of J, because the metal it removed was the metal doing the '
        'least work.',
    source: 'mm-tor-q3',
  ),
  ChangeShaftRound(
    subject: 'a stiffer alloy that is no stiffer in shear',
    change:
        'The shaft is swapped for an alloy with a considerably higher Young\'s '
        'modulus and the same shear modulus.',
    before: Shaft(outerD: 50, e: 200000),
    after: Shaft(outerD: 50, e: 320000),
    why:
        'Neither. Torsion runs on G and never on E. The two are related '
        'through Poisson\'s ratio, so they usually rise together and it is easy '
        'to assume one stands in for the other, but the formula is quite '
        'specific: it is the shear modulus or nothing.',
    source: 'mm-tor-q2',
  ),
  ChangeShaftRound(
    subject: 'the torque put on the other way',
    change:
        'Nothing about the shaft changes. The machine is reversed, so the '
        'torque now acts in the opposite direction.',
    before: Shaft(outerD: 50, torque: 500000),
    after: Shaft(outerD: 50, torque: -500000),
    why:
        'Neither, in size. It twists the other way and it is stressed the '
        'other way, and both are the same magnitude as before, which is what '
        'the formulas hand you. Torsion has no equivalent of a beam having a '
        'weaker face: a round shaft does not care which way it is wrung.',
    source: 'mm-tor-q1',
  ),
];

class _StressOrTwistGameState extends State<StressOrTwistGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'stress-or-twist',
    chapterId: 'mechanics-materials',
    total: shaftRounds.length,
    sourceProblemIdOf: (round) => shaftRounds[round].source,
  )..addListener(_onSession);

  Moves? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ChangeShaftRound get _round => shaftRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Stress or Twist',
        closing:
            'The stress carries T, c and J. The twist carries T, L, G and J. '
            'So length and shear modulus move the twist and leave the stress '
            'alone, and nothing moves the stress by itself, because c and J '
            'are locked together on a round shaft. Read which letters are in '
            'which formula once and the rest follows.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: twistBrief,
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
            'WHAT DOES THIS CHANGE MOVE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.change,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          const _Formulas(),
          const SizedBox(height: 12),
          for (final option in Moves.values) ...[
            _MovesButton(
              key: ValueKey('moves-${option.name}'),
              option: option,
              selected: _picked == option,
              locked: answered,
              isTruth: option == r.answer,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Moves.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHAT MOVES' : 'SOMETHING ELSE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

/// The two formulas, side by side, because which letters are in which is the
/// whole of the item and there is no reason to make anybody remember them.
class _Formulas extends StatelessWidget {
  const _Formulas();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 96,
        width: double.infinity,
        child: EngineeringGrid(
          minor: 18,
          major: 90,
          child: Row(
            children: [
              Expanded(child: _One(top: 'stress', tex: r'\tau = \dfrac{Tc}{J}')),
              Container(width: 1, color: AppColors.line),
              Expanded(
                  child: _One(top: 'twist', tex: r'\phi = \dfrac{TL}{GJ}')),
            ],
          ),
        ),
      ),
    );
  }
}

class _One extends StatelessWidget {
  const _One({required this.top, required this.tex});

  final String top;
  final String tex;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(top, style: AppTheme.mono(size: 10.5, color: AppColors.ink3)),
        const SizedBox(height: 6),
        MathText(
          '\$$tex\$',
          style: const TextStyle(fontSize: 17, color: AppColors.charcoal),
        ),
      ],
    );
  }
}

class _MovesButton extends StatelessWidget {
  const _MovesButton({
    super.key,
    required this.option,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Moves option;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  static const _titles = {
    Moves.twistOnly: 'The twist, and not the stress',
    Moves.both: 'Both of them',
    Moves.neither: 'Neither of them',
  };

  static const _notes = {
    Moves.twistOnly: 'what changed is in one formula and not the other',
    Moves.both: 'what changed is in both',
    Moves.neither: 'what changed is in neither',
  };

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
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 58,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _titles[option]!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _notes[option]!,
                style: AppTheme.mono(size: 10.5, color: AppColors.ink3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
