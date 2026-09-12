import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// What the Table Gives You — the second item for `steel-columns`.
///
/// The two critical stress formulas are in the handbook and the exam does
/// not want them worked out: the column table hands over a design stress for
/// any slenderness, already multiplied by its resistance factor. What is
/// left to know is what that number is, what to do with it, and what the
/// answer means, which is where the lesson's own wrong choices live.
class WhatTheTableGivesYouGame extends StatefulWidget {
  const WhatTheTableGivesYouGame({super.key});

  @override
  State<WhatTheTableGivesYouGame> createState() =>
      _WhatTheTableGivesYouGameState();
}

@immutable
class TableRound {
  const TableRound({
    required this.subject,
    required this.asked,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const columnTableRounds = <TableRound>[
  TableRound(
    subject: 'the lesson\'s own column',
    asked:
        'The table gives a design stress of 34.6 ksi at the column\'s '
        'slenderness, and the section has a gross area of 15 square inches. '
        'What is the design compressive strength?',
    options: [
      'The two multiplied together',
      'The two multiplied together, then multiplied by 0.90',
      'The yield stress times the area',
      'The two multiplied together, then divided by 1.67',
    ],
    answer: 0,
    why:
        'Just multiply. The tabulated stress already has the resistance '
        'factor inside it, which is why the table calls it a DESIGN stress, '
        'and applying 0.90 a second time takes another tenth off a column '
        'that has already paid. Multiplying by the gross area turns a stress '
        'into a force, and that is the whole calculation.',
    source: 'str-sc-q2',
  ),
  TableRound(
    subject: 'the tempting wrong one',
    asked:
        'Somebody answers with the yield stress times the gross area. What '
        'have they worked out?',
    options: [
      'The load a column of zero length could take, with no buckling at all',
      'The design strength, by a different route',
      'The load at which the column first goes out of straight',
      'The strength about the strong axis only',
    ],
    answer: 0,
    why:
        'The squash load: what the section could take if it were too short to '
        'buckle. Every column of any length takes less, and the longer it is '
        'the less it takes. This choice is in the lesson because it is what '
        'you get by forgetting that a column is a buckling problem rather '
        'than a stress problem.',
    source: 'str-sc-q2',
  ),
  TableRound(
    subject: 'which formula applies',
    asked:
        'Away from the table, two formulas for the critical stress sit either '
        'side of a threshold. What decides which one a column uses?',
    options: [
      'Its slenderness, against a threshold that depends on the steel',
      'Whether it is braced in both directions',
      'Whether the ends are pinned or fixed',
      'The size of the axial load on it',
    ],
    answer: 0,
    why:
        'Its slenderness, compared with a threshold set by the modulus over '
        'the yield stress. Below it the column squashes partly before it '
        'goes, which is the inelastic branch; above it the thing buckles '
        'while still elastic. The table has already picked the right branch '
        'for every slenderness, which is the point of using it.',
    source: 'str-sc-q2',
  ),
  TableRound(
    subject: 'two columns of the same shape',
    asked:
        'Two columns of identical section, one with a slenderness of 40 and '
        'one with 120. Which has the greater design stress?',
    options: [
      'The one at 40',
      'The one at 120',
      'They are the same: the section is the same',
      'It depends on the yield stress',
    ],
    answer: 0,
    why:
        'The stocky one. Design stress falls away as slenderness rises, '
        'steeply once buckling has taken over, so the same steel is worth far '
        'less per square inch in a long column than in a short one. That is '
        'the entire content of the column table, read as a graph.',
    source: 'str-sc-q1',
  ),
  TableRound(
    subject: 'stronger steel',
    asked:
        'A very slender column is redesigned in a higher grade of steel, same '
        'shape and same length. What happens to its capacity?',
    options: [
      'Almost nothing: elastic buckling depends on stiffness, not on strength',
      'It rises in proportion to the yield stress',
      'It falls, because higher grade steel is more brittle',
      'It doubles, because the threshold moves',
    ],
    answer: 0,
    why:
        'Almost nothing. Once a column is slender enough to buckle while '
        'elastic, the stress it goes at depends on the modulus and the '
        'slenderness, and every grade of steel has the same modulus. Paying '
        'for stronger steel in a slender column buys nothing, which is one of '
        'the more useful things this lesson has to say. A stockier shape, or '
        'another brace, is what helps.',
    source: 'str-sc-q2',
  ),
  TableRound(
    subject: 'reading the slenderness',
    asked:
        'A column is 15 feet long with an effective length factor of 1.0, and '
        'the radius of gyration is given in inches. What has to happen before '
        'dividing?',
    options: [
      'The length has to be turned into inches',
      'The radius has to be turned into feet',
      'Nothing: the ratio has no units',
      'The length has to be multiplied by the area',
    ],
    answer: 0,
    why:
        'Put them in the same units, which in practice means turning the '
        'length into inches. The slenderness ratio has no units of its own, '
        'and that is exactly why a mismatch survives unnoticed: dividing 15 '
        'by a radius in inches gives a tidy little number that looks like a '
        'slenderness and is out by a factor of twelve.',
    source: 'str-sc-q1',
  ),
];

class _WhatTheTableGivesYouGameState extends State<WhatTheTableGivesYouGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-the-table-gives-you',
    chapterId: 'structural',
    total: columnTableRounds.length,
    sourceProblemIdOf: (round) => columnTableRounds[round].source,
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

  TableRound get _round => columnTableRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What the Table Gives You',
        closing:
            'The column table hands over a stress that already has its '
            'resistance factor in it, so the whole calculation is that stress '
            'times the gross area. The yield stress times the area is the '
            'answer for a column of no length at all. Design stress falls '
            'away as slenderness rises, and once a column is slender enough '
            'to buckle elastically, stronger steel buys nothing: only a '
            'stockier shape or another brace does.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: tableBrief3,
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
            'WHAT DO YOU DO WITH IT',
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
          const SizedBox(height: 14),
          if (answered)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THE WHOLE CALCULATION',
                    style: AppTheme.overline(color: AppColors.ink3),
                  ),
                  const SizedBox(height: 8),
                  MathText(
                    r'$\phi_c P_n = (\phi_c F_{cr}) \times A_g$',
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.charcoal),
                  ),
                  const SizedBox(height: 6),
                  MathText(
                    r'$\text{slenderness} = KL/r, \; \text{both in inches}$',
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.charcoal),
                  ),
                ],
              ),
            ),
          if (answered) const SizedBox(height: 14),
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
