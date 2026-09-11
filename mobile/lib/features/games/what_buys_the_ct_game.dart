import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'chlorine_figures.dart';

/// What Buys the CT — the second item for `drinking-water-treatment`.
///
/// Disinfection credit is a product of two things, so there are two ways to
/// buy it: more chlorine left in the water, or more time in contact with it.
/// The subtlety is which time counts. It is not the volume over the flow,
/// which assumes every drop takes the same path, but the time the FASTEST
/// tenth gets, and in an open tank that is a small fraction of the
/// theoretical figure. Baffles are what close the gap.
class WhatBuysTheCtGame extends StatefulWidget {
  const WhatBuysTheCtGame({super.key});

  @override
  State<WhatBuysTheCtGame> createState() => _WhatBuysTheCtGameState();
}

/// Where the credit goes.
enum Credit { up, down, same }

extension CreditWords on Credit {
  String get plain => switch (this) {
        Credit.up => 'More credit: the CT goes up',
        Credit.down => 'Less credit: the CT comes down',
        Credit.same => 'No change to the credit',
      };
}

@immutable
class CreditRound {
  const CreditRound({
    required this.subject,
    required this.change,
    required this.before,
    required this.after,
    required this.why,
    required this.source,
  });

  final String subject;
  final String change;
  final Contact before;
  final Contact after;
  final String why;
  final String source;

  /// Worked out of the two basins, never declared.
  Credit get answer {
    if ((after.ct - before.ct).abs() / before.ct < 0.01) return Credit.same;
    return after.ct > before.ct ? Credit.up : Credit.down;
  }
}

const creditRounds = <CreditRound>[
  CreditRound(
    subject: 'holding a higher residual',
    change:
        'The operator raises the free residual from 1.0 to 1.5 mg/L. The '
        'basin and the flow are unchanged.',
    before: Contact(residual: 1.0, theoretical: 100, baffled: 0.6),
    after: Contact(residual: 1.5, theoretical: 100, baffled: 0.6),
    why:
        'Up, by half. CT is a plain product, so the two ways of buying '
        'credit trade off exactly: half again the residual is half again the '
        'credit, and it would take half again the contact time to do the same '
        'thing. At 1.5 mg/L this basin earns 90, which is the figure the '
        'lesson\'s own problem is built around.',
    source: 'wr-dwt-q3',
  ),
  CreditRound(
    subject: 'adding baffles',
    change:
        'Baffle walls are built into the open contact tank, taking the '
        'baffling factor from 0.3 to 0.7. The volume, the flow and the '
        'residual are all unchanged.',
    before: Contact(residual: 1.2, theoretical: 90, baffled: 0.3),
    after: Contact(residual: 1.2, theoretical: 90, baffled: 0.7),
    why:
        'Up, and by more than twice, for a few walls of concrete. Nothing '
        'about the volume or the flow changed: what changed is how much of '
        'the tank the fastest water is made to visit. An unbaffled tank lets '
        'a tenth of the water shoot from the inlet to the outlet, and that '
        'water sets the credit for all of it.',
    source: 'wr-dwt-q3',
  ),
  CreditRound(
    subject: 'a busy afternoon',
    change:
        'Demand rises and the flow through the same basin doubles, halving '
        'the volume over flow from 100 minutes to 50. The residual holds.',
    before: Contact(residual: 1.5, theoretical: 100, baffled: 0.6),
    after: Contact(residual: 1.5, theoretical: 50, baffled: 0.6),
    why:
        'Down, by half. The contact time is volume over flow at heart, so '
        'twice the flow is half the time and half the credit. This is why CT '
        'compliance is checked at PEAK flow rather than average: the worst '
        'hour of the day is the one that has to pass.',
    source: 'wr-dwt-q3',
  ),
  CreditRound(
    subject: 'a bigger tank',
    change:
        'A second contact tank doubles the volume at the same flow, taking '
        'the theoretical time from 60 minutes to 120. Same residual, same '
        'baffling.',
    before: Contact(residual: 0.8, theoretical: 60, baffled: 0.5),
    after: Contact(residual: 0.8, theoretical: 120, baffled: 0.5),
    why:
        'Up, doubled. Volume is the other half of the contact time, so this '
        'buys exactly what halving the flow would have. It is also the '
        'expensive way to do it: concrete in the ground against a few more '
        'milligrams a liter of chlorine, or against baffles in the tank you '
        'already have.',
    source: 'wr-dwt-q3',
  ),
  CreditRound(
    subject: 'more chlorine, dirtier water',
    change:
        'The dose is raised by 0.5 mg/L, but the raw water has gone off and '
        'the demand has risen by the same 0.5. The residual is unchanged.',
    before: Contact(residual: 1.0, theoretical: 80, baffled: 0.5),
    after: Contact(residual: 1.0, theoretical: 80, baffled: 0.5),
    why:
        'No change. CT runs on the RESIDUAL, not the dose, and the residual '
        'is exactly where it was: the extra chlorine went into meeting the '
        'extra demand. Feeding more is only disinfection credit if some of it '
        'survives, which is the distinction the dose equation is about.',
    source: 'wr-dwt-q3',
  ),
  CreditRound(
    subject: 'claiming the theoretical time',
    change:
        'An operator reports the credit using the volume over the flow, 90 '
        'minutes, rather than the 27 minutes the tracer study gave for the '
        'fastest tenth. What does the honest figure do to the claim?',
    before: Contact(residual: 1.2, theoretical: 90, baffled: 1.0),
    after: Contact(residual: 1.2, theoretical: 90, baffled: 0.3),
    why:
        'Down, to less than a third. The theoretical time assumes every drop '
        'takes the same path through the tank, and no real basin does: some '
        'water short circuits and some sits in corners. CT is written on the '
        'tenth percentile because the pathogens in the quickest water are the '
        'ones that matter, and reporting volume over flow overstates the '
        'protection by whatever the baffling factor is.',
    source: 'wr-dwt-q3',
  ),
];

class _WhatBuysTheCtGameState extends State<WhatBuysTheCtGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-buys-the-ct',
    chapterId: 'water-resources',
    total: creditRounds.length,
    sourceProblemIdOf: (round) => creditRounds[round].source,
  )..addListener(_onSession);

  Credit? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  CreditRound get _round => creditRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Buys the CT',
        closing:
            'Credit is the residual times the contact time, so more of '
            'either buys the same thing and they trade off exactly. The '
            'residual is what counts, not the dose: chlorine consumed by the '
            'demand buys nothing. And the time is the tenth percentile rather '
            'than volume over flow, because the fastest water sets the '
            'protection for all of it. Baffles are the cheap way to close '
            'that gap.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: contactBrief,
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
            'WHAT HAPPENS TO THE DISINFECTION CREDIT',
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
          Container(
            height: 224,
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
                  painter: ContactPainter(
                    contact: answered ? r.after : r.before,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$CT = C \times t_{10}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Credit.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Credit.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHAT IT DOES' : 'THE OTHER WAY',
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
