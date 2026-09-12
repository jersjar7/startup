import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'virtual_work_figures.dart';

/// Does This One Count — the second item for `deflection-virtual-work`.
///
/// The sum has one term per member and the arithmetic in it belongs on paper.
/// What can be settled by looking is which terms are there at all and which
/// way each one pushes: either factor zero and the member drops out however
/// large the other is, like signs and it moves the joint the way the unit
/// load points, unlike signs and it pulls the joint back. The sign convention
/// is the whole trap, and two compressions making a positive term is the part
/// that catches people.
class DoesThisOneCountGame extends StatefulWidget {
  const DoesThisOneCountGame({super.key});

  @override
  State<DoesThisOneCountGame> createState() => _DoesThisOneCountGameState();
}

/// What one term does to the running total.
enum Adds { along, opposite, nothing }

@immutable
class TermRound {
  const TermRound({
    required this.subject,
    required this.asked,
    required this.term,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Contribution term;
  final Adds answer;
  final String why;
  final String source;

  static String label(Adds which) => switch (which) {
        Adds.along => 'The way the unit load points',
        Adds.opposite => 'The other way',
        Adds.nothing => 'Nothing at all',
      };
}

const termRounds = <TermRound>[
  TermRound(
    subject: 'the lesson\'s own member',
    asked:
        'The real load puts 50 kN of tension in this member, and the unit '
        'load on its own puts 0.5 of tension in it.',
    term: Contribution(member: 1, real: 50, virt: 0.5),
    answer: Adds.along,
    why:
        'Both forces are tension, so the product n times N is positive and '
        'the term adds to the deflection in the direction the unit load '
        'points. This is the ordinary case: a member that stretches under the '
        'real load, and that the unit load also stretches, lets the joint '
        'move the way the unit load is pulling it.',
    source: 'str-dvw-q1',
  ),
  TermRound(
    subject: 'a member the unit load misses',
    asked:
        'This member is working hard, carrying 80 kN of tension from the real '
        'load. The unit load is hanging one joint over, and it leaves this '
        'member at nothing: look at the joint at its foot and the two chords '
        'there run straight through with nothing else pulling.',
    term: Contribution(member: 7, real: 80, virt: 0, hangAt: 1),
    answer: Adds.nothing,
    why:
        'Nothing at all. With n equal to zero the whole term is zero no '
        'matter how big N is, and the member drops straight out of the sum. '
        'That is worth knowing before you start: run the unit-load analysis '
        'first, cross off every member it leaves at zero, and the list of '
        'terms to work out is often half the truss.',
    source: 'str-dvw-q1',
  ),
  TermRound(
    subject: 'one of each',
    asked:
        'The real load sits on the far side of this panel and puts the '
        'diagonal into compression, 40 kN of it. The unit load sits on this '
        'side and stretches it instead, 0.6 of tension.',
    term: Contribution(member: 8, real: -40, virt: 0.6),
    answer: Adds.opposite,
    why:
        'One tension and one compression give a negative product, so this '
        'term pulls the running total back the other way. It does not mean a '
        'mistake has been made: a diagonal genuinely reverses as the load '
        'crosses its panel, which is why the real loading and the unit '
        'loading can disagree about it. A real truss has members doing both, '
        'and the total is what survives after they have argued it out.',
    source: 'str-dvw-q1',
  ),
  TermRound(
    subject: 'a member with nothing in it',
    asked:
        'The unit load hangs right on this member and puts a full 1.0 of '
        'tension in it. Under the real load, which sits elsewhere, it is a '
        'zero-force member.',
    term: Contribution(member: 7, real: 0, virt: 1),
    answer: Adds.nothing,
    why:
        'Nothing at all. Either factor being zero kills the term, and this is '
        'the other way round from the last one: the member does nothing in '
        'the real structure, so it cannot contribute to how far the real '
        'structure moves, whatever the virtual analysis makes of it.',
    source: 'str-dvw-q1',
  ),
  TermRound(
    subject: 'two compressions',
    asked:
        'The real load puts 60 kN of compression in this member, and the unit '
        'load on its own puts 0.5 of compression in it too.',
    term: Contribution(member: 3, real: -60, virt: -0.5),
    answer: Adds.along,
    why:
        'Two negatives multiply to a positive, so this term pushes the joint '
        'the way the unit load points, exactly like two tensions would. This '
        'is the round that catches people: it is the AGREEMENT of the two '
        'signs that matters, not whether they are positive. Carry the signs '
        'through the multiplication and the bookkeeping takes care of itself.',
    source: 'str-dvw-q1',
  ),
  TermRound(
    subject: 'the finished total',
    asked:
        'Every member has been worked out and added up, and the total for the '
        'joint has come out negative.',
    term: Contribution(
        member: 0, real: 0, virt: 0, wholeSum: true, sumNegative: true),
    answer: Adds.opposite,
    why:
        'The other way. A negative total is not an error: it means the joint '
        'moved opposite to the direction you pointed the unit load, so if you '
        'hung it downward, the joint went up by that amount. The unit load '
        'sets the positive direction and the sign of the answer reports '
        'against it. Report the size with the direction named in words and '
        'there is nothing left to get wrong.',
    source: 'str-dvw-q1',
  ),
];

class _DoesThisOneCountGameState extends State<DoesThisOneCountGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'does-this-one-count',
    chapterId: 'structural',
    total: termRounds.length,
    sourceProblemIdOf: (round) => termRounds[round].source,
  )..addListener(_onSession);

  Adds? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  TermRound get _round => termRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Does This One Count',
        closing:
            'Either factor zero and the member is not in the sum at all, '
            'which is worth spotting early because it saves most of the work. '
            'Otherwise the two signs decide the direction: agreeing signs, '
            'including two compressions, push the joint the way the unit load '
            'points, and disagreeing signs pull it back. A negative total '
            'means the joint moved the other way, not that something went '
            'wrong.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: termSignBrief,
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
            'WHICH WAY DOES THIS TERM PUSH',
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
            height: 200,
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
                  painter:
                      ContributionPainter(term: r.term, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\delta = \sum \frac{n N L}{A E}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Adds.values) ...[
            _Choice(
              label: TermRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Adds.values.last) const SizedBox(height: 8),
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
