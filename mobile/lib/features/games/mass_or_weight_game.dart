import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Mass or Weight — the first item for `force-and-acceleration`.
///
/// The lesson's own warning is that a five hundred newton block and a fifty
/// kilogram block are different animals, and its middle problem is built on
/// exactly that: the number given is a weight, and using it as a mass is out
/// by nearly ten. Sorting that out is reading, not arithmetic, and it comes
/// before any formula.
class MassOrWeightGame extends StatefulWidget {
  const MassOrWeightGame({super.key});

  @override
  State<MassOrWeightGame> createState() => _MassOrWeightGameState();
}

/// What has to happen to the number before it can go into F equals m a.
enum Prep { useAsIs, divideByG, multiplyByG }

extension PrepWords on Prep {
  String get plain => switch (this) {
        Prep.useAsIs => 'Nothing: it is already what I need',
        Prep.divideByG => 'Divide it by g first',
        Prep.multiplyByG => 'Multiply it by g first',
      };
}

@immutable
class UnitRound {
  const UnitRound({
    required this.subject,
    required this.setting,
    required this.wanted,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;

  /// The sentence a problem would actually give you.
  final String setting;

  /// What the formula needs at this point: a mass or a force.
  final String wanted;

  final Prep answer;
  final String why;
  final String source;
}

const unitRounds = <UnitRound>[
  UnitRound(
    subject: 'a block given in newtons',
    setting: 'A 500 newton block slides down a frictionless slope.',
    wanted: 'the MASS, to put into F equals m a',
    answer: Prep.divideByG,
    why:
        'Divide by g. Newtons are a force, so five hundred newtons is what the '
        'earth pulls this block with, and its mass is five hundred over nine '
        'point eight one, about fifty one kilograms. Using the five hundred as '
        'a mass makes the block nearly ten times heavier than it is, and this '
        'is the lesson\'s own middle problem.',
    source: 'dyn-fa-q2',
  ),
  UnitRound(
    subject: 'a crate given in kilograms',
    setting: 'An 80 kilogram crate is pushed across a frictionless floor.',
    wanted: 'the MASS, to put into F equals m a',
    answer: Prep.useAsIs,
    why:
        'Nothing at all. Kilograms are already a mass, and this is the '
        'friendly case: the lesson\'s first problem hands you eighty '
        'kilograms and two hundred and forty newtons and the division is the '
        'whole of the work. The trap in that problem is the opposite one, '
        'turning the force into a weight it never was.',
    source: 'dyn-fa-q1',
  ),
  UnitRound(
    subject: 'the same crate, a different question',
    setting: 'The same 80 kilogram crate is resting on the floor.',
    wanted: 'its WEIGHT, the force the floor has to hold up',
    answer: Prep.multiplyByG,
    why:
        'Multiply by g: eighty times nine point eight one, about seven hundred '
        'and eighty five newtons. This is the same conversion as the first '
        'round running the other way, and which way it runs depends only on '
        'which of the two you were handed and which one you need.',
    source: 'dyn-fa-q1',
  ),
  UnitRound(
    subject: 'a lift in pounds',
    setting:
        'A 3,220 pound car is braking. The problem is in US units, where g is '
        '32.2 feet a second squared.',
    wanted: 'the MASS, to put into F equals m a',
    answer: Prep.divideByG,
    why:
        'Divide by g again, because a pound here is a force just as a newton '
        'is: three thousand two hundred and twenty over thirty two point two '
        'is a hundred slugs. The unit system does not change the question. '
        'What it changes is the number you divide by, thirty two point two '
        'rather than nine point eight one.',
    source: 'dyn-fa-q2',
  ),
  UnitRound(
    subject: 'a hanging load',
    setting: 'A crane holds a 2 tonne load still on its hook.',
    wanted: 'the FORCE in the cable',
    answer: Prep.multiplyByG,
    why:
        'Multiply by g. A tonne is a thousand kilograms, so this is two '
        'thousand kilograms of mass and the cable is holding about nineteen '
        'thousand six hundred newtons. Anything that names a mass and asks for '
        'a force runs this way round.',
    source: 'dyn-fa-q1',
  ),
  UnitRound(
    subject: 'a force given in newtons',
    setting:
        'A horizontal push of 240 newtons acts on that crate.',
    wanted: 'the FORCE, to put into F equals m a',
    answer: Prep.useAsIs,
    why:
        'Nothing. It is already a force, in the units the formula wants, and '
        'the mistake worth naming is doing something to it anyway: multiplying '
        'this two hundred and forty by g gives a number that answers no '
        'question at all. Convert only what needs converting.',
    source: 'dyn-fa-q1',
  ),
];

class _MassOrWeightGameState extends State<MassOrWeightGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'mass-or-weight',
    chapterId: 'dynamics',
    total: unitRounds.length,
    sourceProblemIdOf: (round) => unitRounds[round].source,
  )..addListener(_onSession);

  Prep? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  UnitRound get _round => unitRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Mass or Weight',
        closing:
            'Kilograms and slugs are mass. Newtons and pounds are force. F '
            'equals m a wants a force on one side and a mass on the other, so '
            'read which one you were given before you write anything down. '
            'Weight is m g, and on this exam g is nine point eight one or '
            'thirty two point two depending on the units.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: weightBrief,
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
            'WHAT HAS TO HAPPEN TO THE NUMBER',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THE PROBLEM SAYS',
                  style: AppTheme.overline(color: AppColors.info),
                ),
                const SizedBox(height: 8),
                Text(
                  r.setting,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'YOU WANT',
                  style: AppTheme.overline(color: AppColors.ember),
                ),
                const SizedBox(height: 8),
                Text(
                  r.wanted,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.charcoal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: MathText(
              r'$W = mg, \quad \sum F = ma$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 14),
          for (final p in Prep.values) ...[
            _Choice(
              label: p.plain,
              selected: _picked == p,
              locked: answered,
              isTruth: p == r.answer,
              onTap: answered ? null : () => setState(() => _picked = p),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 8),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE STEP' : 'THE OTHER WAY',
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
