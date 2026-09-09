import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'contract_figures.dart';
import 'lesson_brief.dart';

/// Which Delivery — the third item for `engineering-contracts`.
///
/// A delivery method is a shape, not a name. What separates design-bid-build
/// from design-build is the number of lines running out of the owner's box,
/// and the exam question is always a description of that shape wearing an
/// acronym.
///
/// So the three shapes are drawn side by side and the description picks one.
/// The names are on the cards, which is deliberate: nobody needs to be tested
/// on whether they can recall an acronym, and everybody needs to be able to
/// see who is holding whose contract.
class WhichDeliveryGame extends StatefulWidget {
  const WhichDeliveryGame({super.key});

  @override
  State<WhichDeliveryGame> createState() => _WhichDeliveryGameState();
}

enum Delivery { designBidBuild, designBuild, cmAtRisk }

/// What hangs off the owner in each shape. The flag is whether the owner holds
/// that contract directly.
List<(String, bool)> boxesFor(Delivery d) => switch (d) {
  // Short enough to fit the box. A truncated label reads as an abbreviation
  // nobody chose, which is worse than a shorter word.
  Delivery.designBidBuild => [
    ('Designer', true),
    ('Builder', true),
  ],
  Delivery.designBuild => [
    ('DB firm', true),
    ('Subs', false),
  ],
  Delivery.cmAtRisk => [
    ('Designer', true),
    ('CM', true),
  ],
};

@immutable
class DeliveryRound {
  const DeliveryRound({
    required this.subject,
    required this.description,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String description;
  final Delivery answer;
  final String why;
  final String source;
}

const deliveryRounds = <DeliveryRound>[
  DeliveryRound(
    subject: 'one throat to choke',
    description:
        'The owner wants a single entity contractually responsible for both '
        'the design and the construction, under one agreement.',
    answer: Delivery.designBuild,
    why:
        'One line out of the owner\'s box. Everybody else, including the '
        'designer, is a subcontractor to the entity that holds it, which is '
        'what the owner is buying and what they give up in exchange.',
    source: 'eth-con-q3',
  ),
  DeliveryRound(
    subject: 'the traditional route',
    description:
        'The owner engages an engineer to complete the design, then puts the '
        'finished documents out to bid and engages the low bidder to build it.',
    answer: Delivery.designBidBuild,
    why:
        'Two separate agreements and no line between the two parties. It is '
        'the shape most public work still uses, and it is why the designer and '
        'the contractor answer to the owner and not to each other.',
    source: 'eth-con-q3',
  ),
  DeliveryRound(
    subject: 'advice early, a number later',
    description:
        'A builder joins during design to advise on constructability and cost, '
        'then delivers the construction under a guaranteed maximum price.',
    answer: Delivery.cmAtRisk,
    why:
        'Two agreements again, and the second one changes character partway '
        'through. The manager is an adviser first and carries the risk above '
        'the guaranteed maximum afterwards.',
    source: 'eth-con-q3',
  ),
  DeliveryRound(
    subject: 'a design the owner never held',
    description:
        'The owner has one contract. The firm that signed it hired the '
        'architect and the structural engineer itself, and the owner has no '
        'agreement with either of them.',
    answer: Delivery.designBuild,
    why:
        'Look at who the owner can send a letter to. Having no contract with '
        'the designer is the defining feature of this shape, and it is also '
        'the thing owners most often fail to think through.',
    source: 'eth-con-q3',
  ),
  DeliveryRound(
    subject: 'a bid opening',
    description:
        'Construction pricing is fixed by competitive bid against a complete '
        'set of documents, and the designer stays on to administer the '
        'contract for the owner.',
    answer: Delivery.designBidBuild,
    why:
        'Bidding against a finished set is the middle word of the name. It '
        'also explains the method\'s weakness: nobody who will build it has '
        'looked at it until the design is already done.',
    source: 'eth-con-q3',
  ),
  DeliveryRound(
    subject: 'a ceiling, agreed partway',
    description:
        'The owner holds two contracts. The second party spent the design '
        'period advising, and has now committed to a ceiling price for the '
        'work.',
    answer: Delivery.cmAtRisk,
    why:
        'Two contracts rules out the single-entity shape, and the ceiling '
        'price rules out the traditional one, where the number comes from a '
        'bid rather than from a negotiation.',
    source: 'eth-con-q3',
  ),
];

class _WhichDeliveryGameState extends State<WhichDeliveryGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-delivery',
    chapterId: 'ethics',
    total: deliveryRounds.length,
    sourceProblemIdOf: (round) => deliveryRounds[round].source,
  )..addListener(_onSession);

  Delivery? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  DeliveryRound get _round => deliveryRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Delivery',
        closing:
            'Count the lines out of the owner. Two, with the design finished '
            'before anybody bids, is the traditional route. One is '
            'design-build, and the owner has no agreement with the designer at '
            'all. Two, with the builder advising early and then guaranteeing a '
            'maximum, is a manager at risk.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: deliveryBrief,
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
            'WHICH SHAPE IS THIS',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.description,
            style: const TextStyle(
              fontSize: 15.5,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 14),
          for (final d in Delivery.values) ...[
            if (d != Delivery.values.first) const SizedBox(height: 8),
            _DeliveryCard(
              key: ValueKey('delivery-${d.name}'),
              delivery: d,
              label: switch (d) {
                Delivery.designBidBuild => 'Design, bid, build',
                Delivery.designBuild => 'Design-build',
                Delivery.cmAtRisk => 'Manager at risk',
              },
              selected: _picked == d,
              locked: answered,
              isTruth: d == r.answer,
              onTap: answered ? null : () => setState(() => _picked = d),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT SHAPE' : 'A DIFFERENT SHAPE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({
    super.key,
    required this.delivery,
    required this.label,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Delivery delivery;
  final String label;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 132,
                height: 84,
                child: CustomPaint(
                  painter: DeliveryPainter(
                    boxes: boxesFor(delivery),
                    color: border == AppColors.line
                        ? AppColors.charcoal
                        : border,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.3,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
