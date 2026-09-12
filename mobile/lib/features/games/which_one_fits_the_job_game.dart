import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'delivery_figures.dart';
import 'lesson_brief.dart';

/// Which One Fits the Job — the only item for `delivery-methods`.
///
/// The ethics chapter draws these three as contract shapes, which is how
/// the law sees them. This item asks the question a construction manager
/// asks: given the job in front of you, which one fits, and what does the
/// schedule look like when it does.
class WhichOneFitsTheJobGame extends StatefulWidget {
  const WhichOneFitsTheJobGame({super.key});

  @override
  State<WhichOneFitsTheJobGame> createState() => _WhichOneFitsTheJobGameState();
}

@immutable
class FitRound {
  const FitRound({
    required this.subject,
    required this.asked,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  /// The method this round is about, which is also its answer.
  final Deliver answer;
  final String why;
  final String source;

  static String label(Deliver d) => switch (d) {
        Deliver.designBidBuild =>
          'Design, bid, build: finish the drawings, then price them',
        Deliver.designBuild =>
          'Design-build: one firm for both, and they can overlap',
        Deliver.managerAtRisk =>
          'Manager at risk: your designer, their ceiling price',
      };
}



const fitRounds = <FitRound>[
  FitRound(
    subject: 'a public agency with finished drawings',
    asked:
        'An agency must bid competitively by law and already has complete '
        'plans and specifications. Which method fits?',
    answer: Deliver.designBidBuild,
    why:
        'Design, bid, build. The drawings are done, so there is something '
        'complete to price, and every bidder prices the same thing, which is '
        'what competitive bidding needs. The other two bring a builder in '
        'before the design is finished, so there is nothing fixed to bid '
        'against.',
    source: 'const-dm-q1',
  ),
  FitRound(
    subject: 'an owner in a hurry',
    asked:
        'An owner wants to start building before the design is finished, and '
        'wants ONE firm answerable for both. Which method?',
    answer: Deliver.designBuild,
    why:
        'Design-build. One agreement covers design and construction, so the '
        'two can overlap and the job finishes sooner. The owner also gives '
        'up something for that: there is no second party to check the first, '
        'and the designer now works for the builder.',
    source: 'const-dm-q2',
  ),
  FitRound(
    subject: 'a builder at the design table',
    asked:
        'An owner wants a builder advising during design for '
        'constructability, keeps its own designer, and wants a guaranteed '
        'maximum price. Which method?',
    answer: Deliver.managerAtRisk,
    why:
        'Manager at risk, and all three clues point at it. Advice during '
        'design rules out design, bid, build. A separate designer rules out '
        'design-build. And the guaranteed maximum is this method\'s '
        'signature: the manager commits to a ceiling part way through the '
        'design and carries what goes over it.',
    source: 'const-dm-q3',
  ),
  FitRound(
    subject: 'why the traditional way cannot be rushed',
    asked:
        'Which method cannot be fast-tracked, because nothing can be priced '
        'until the drawings are finished?',
    answer: Deliver.designBidBuild,
    why:
        'Design, bid, build, by construction. Bidding needs a complete '
        'package, so the schedule is strictly one thing after another: '
        'design, then bid, then build. It buys price competition on a known '
        'scope and pays for it in time.',
    source: 'const-dm-q1',
  ),
  FitRound(
    subject: 'who carries the overrun',
    asked:
        'In which method does the builder agree a ceiling price part way '
        'through design and absorb what goes over it?',
    answer: Deliver.managerAtRisk,
    why:
        'The manager at risk, which is what the phrase at risk means: the '
        'manager is at risk for the amount above the guaranteed maximum. '
        'Below it the savings usually go back to the owner, which is why '
        'this method reads as a middle way between the other two.',
    source: 'const-dm-q3',
  ),
  FitRound(
    subject: 'the price of overlapping',
    asked:
        'A method lets construction start with the design a third finished. '
        'Which one, and what is the owner accepting?',
    answer: Deliver.designBuild,
    why:
        'Design-build, and the owner is accepting less certainty about what '
        'is being built. Early work is committed while later drawings are '
        'still in progress, so changes are cheaper for the builder to absorb '
        'and harder for the owner to police. Speed and single point '
        'responsibility are bought with scope certainty.',
    source: 'const-dm-q2',
  ),
];

class _WhichOneFitsTheJobGameState extends State<WhichOneFitsTheJobGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-one-fits-the-job',
    chapterId: 'construction',
    total: fitRounds.length,
    sourceProblemIdOf: (round) => fitRounds[round].source,
  );

  Deliver? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  FitRound get _round => fitRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which One Fits the Job',
        closing:
            'Complete drawings and a duty to bid: design, bid, build, '
            'one thing after another. Speed and one firm answerable for '
            'everything: design-build, with the design still in progress '
            'when the work starts. A builder advising through design, your '
            'own designer kept, and a ceiling price: manager at risk.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: deliveryFitBrief,
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
            'MATCHING THE JOB',
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
                  painter: ScheduleShapePainter(
                    method: r.answer,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Deliver.values) ...[
            _Choice(
              label: FitRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Deliver.values.last) const SizedBox(height: 8),
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
