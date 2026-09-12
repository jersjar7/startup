import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Factored or Service — the first item for `load-combinations`.
///
/// The lesson's own warning is that the first thing to read in a load
/// combination question is which METHOD it is asking for, because the two
/// halves of the check go together: factored loads belong with a design
/// strength, service loads belong with an allowable one. Take one half from
/// each method and the answer is either unsafe or absurd, and no arithmetic
/// afterward can tell you which.
class FactoredOrServiceGame extends StatefulWidget {
  const FactoredOrServiceGame({super.key});

  @override
  State<FactoredOrServiceGame> createState() => _FactoredOrServiceGameState();
}

@immutable
class DesignRound {
  const DesignRound({
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

const designRounds = <DesignRound>[
  DesignRound(
    subject: 'the lesson\'s own beam',
    asked:
        'A beam carries 20 kips of dead load and 40 kips of floor live load. '
        'The stem says to use LRFD. What is the check?',
    options: [
      '1.2 times the dead plus 1.6 times the live, against the design strength',
      'The dead plus the live as they stand, against the design strength',
      '1.2 times the dead plus 1.6 times the live, against the strength '
          'divided by a safety factor',
      'The dead plus the live as they stand, against the strength divided by '
          'a safety factor',
    ],
    answer: 0,
    why:
        'Factored loads against the design strength. The two halves of a '
        'check always come from the same method, because each method decides '
        'how much margin to build in and where to put it. Take the factored '
        'load and then divide the strength as well and the member is paying '
        'for its safety twice; take the service load against the design '
        'strength and it is barely paying at all.',
    source: 'str-lc-q1',
  ),
  DesignRound(
    subject: 'the same beam, the other method',
    asked:
        'The same 20 kips of dead and 40 kips of live, but now the stem says '
        'allowable stress design. What is the check?',
    options: [
      'The dead plus the live as they stand, against the strength divided by '
          'a safety factor',
      '1.2 times the dead plus 1.6 times the live, against the strength '
          'divided by a safety factor',
      'The dead plus the live as they stand, against the full nominal '
          'strength',
      '1.2 times the dead plus 1.6 times the live, against the design strength',
    ],
    answer: 0,
    why:
        'Service loads, which is to say the loads as the building actually '
        'sees them, against a capacity that has been divided down. ASD keeps '
        'its whole margin on the strength side, which is why its loads look '
        'so much smaller than an LRFD answer for the same beam. The two '
        'numbers are not comparable and are not meant to be.',
    source: 'str-lc-q1',
  ),
  DesignRound(
    subject: 'why the factors differ',
    asked:
        'In LRFD the dead load is multiplied by 1.2 and the floor live load '
        'by 1.6. Why is the dead load the one that gets the smaller factor?',
    options: [
      'Because the dead load is known far better than the live load is',
      'Because the dead load is usually the smaller of the two',
      'Because the live load can be taken off the structure and the dead '
          'cannot',
      'Because the two factors have to add up to a set total',
    ],
    answer: 0,
    why:
        'Because it is known better. The dead load is the weight of things '
        'that are already drawn, so it can be counted with some confidence; '
        'the live load is a guess about how people will use the place, and a '
        'guess needs more room. The factor is buying uncertainty, not weight, '
        'which is why the size of the load has nothing to do with it.',
    source: 'str-lc-q1',
  ),
  DesignRound(
    subject: 'a factor in the wrong place',
    asked:
        'Working an allowable stress check, somebody multiplies the floor '
        'live load by 1.6. Is that right?',
    options: [
      'No: the load factors belong to LRFD, and ASD keeps its margin on the '
          'capacity side',
      'Yes: the load factors apply to both methods',
      'Yes, whenever snow or wind is in the combination as well',
      'No: under ASD every load is multiplied by 0.75 instead',
    ],
    answer: 0,
    why:
        'No. ASD combinations use the loads unfactored, and the safety comes '
        'from dividing the strength by omega. Factoring the load as well and '
        'then dividing the strength counts the same margin twice and produces '
        'a member nobody would build. The 0.75 that shows up in ASD is not a '
        'safety factor either: it appears only where three loads are combined '
        'at once, and it is there because they are unlikely to peak together.',
    source: 'str-lc-q2',
  ),
  DesignRound(
    subject: 'the combination on its own',
    asked:
        'LRFD combination 1 is 1.4 times the dead load and nothing else. When '
        'is that the combination to worry about?',
    options: [
      'When the live load is small next to the dead load',
      'When the live load is large next to the dead load',
      'Whenever there is no wind in the problem',
      'Never: combination 2 always gives the bigger number',
    ],
    answer: 0,
    why:
        'When the live load is small. Combination 2 gives the dead load a '
        'smaller factor, 1.2 instead of 1.4, and makes up the difference with '
        '1.6 times the live load. If there is hardly any live load to apply '
        'that 1.6 to, the extra 0.2 on a big dead load wins. A heavy slab '
        'carrying almost nothing is the case to watch, and it is the reason '
        'combination 1 is in the list at all.',
    source: 'str-lc-q2',
  ),
  DesignRound(
    subject: 'are both allowed',
    asked: 'Do the two methods both give a design the code will accept?',
    options: [
      'Yes: they are two routes to the same margin and either may be used',
      'No: allowable stress design is no longer permitted',
      'Yes, but allowable stress design always gives the bigger member',
      'Only LRFD counts for steel, and allowable stress design for timber',
    ],
    answer: 0,
    why:
        'Both are in ASCE 7 and both are allowed. Which one a question wants '
        'is a matter of reading the stem, not of judgment, and the two do not '
        'generally give the same member: which comes out heavier depends on '
        'how much of the load is live. The only real mistake is mixing them.',
    source: 'str-lc-q1',
  ),
];

class _FactoredOrServiceGameState extends State<FactoredOrServiceGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'factored-or-service',
    chapterId: 'structural',
    total: designRounds.length,
    sourceProblemIdOf: (round) => designRounds[round].source,
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

  DesignRound get _round => designRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Factored or Service',
        closing:
            'Read the stem first. LRFD factors the loads up, dead by 1.2 '
            'because it is well known and live by 1.6 because it is not, and '
            'compares them with a design strength. Allowable stress design '
            'takes the loads exactly as they come and divides the strength '
            'instead. Both are allowed, both are safe, and the only way to go '
            'wrong is to take one half from each.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: lrfdBrief,
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
            'WHICH CHECK IS IT',
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
          // The two checks are the answer to half these rounds, so they are
          // only shown once the round is over.
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
                    'THE TWO CHECKS',
                    style: AppTheme.overline(color: AppColors.ink3),
                  ),
                  const SizedBox(height: 8),
                  MathText(
                    r'$\text{LRFD: } 1.2D + 1.6L \; \le \; \phi R_n$',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  MathText(
                    r'$\text{ASD: } D + L \; \le \; R_n / \Omega$',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.charcoal,
                    ),
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
              title: _session.correct! ? 'THAT IS THE CHECK' : 'NOT THAT ONE',
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
