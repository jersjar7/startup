import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'contract_figures.dart';
import 'lesson_brief.dart';

/// Who Pays the Overrun — the second item for `engineering-contracts`.
///
/// Contract types are usually learned as a list of names, and the exam does
/// not ask for names. It asks who carries the risk, which is one question
/// about one picture: the job cost more than the number in the contract, and
/// somebody absorbs the difference.
///
/// So the difference is drawn, and the answer is a party. Two rounds are the
/// ones people lose: a unit-price contract where the quantity really did go up
/// and the owner pays for what was placed, and a lump sum where the owner
/// changed the scope, which buys back the risk they had handed away.
class WhoPaysTheOverrunGame extends StatefulWidget {
  const WhoPaysTheOverrunGame({super.key});

  @override
  State<WhoPaysTheOverrunGame> createState() => _WhoPaysTheOverrunGameState();
}

enum Payer { owner, contractor }

@immutable
class OverrunRound {
  const OverrunRound({
    required this.contract,
    required this.what,
    required this.priced,
    required this.actual,
    required this.pricedLabel,
    required this.answer,
    required this.why,
    required this.source,
  });

  /// The contract type, named as the exam names it.
  final String contract;

  /// What happened to make the job cost more.
  final String what;
  final double priced;
  final double actual;
  final String pricedLabel;
  final Payer answer;
  final String why;
  final String source;
}

const overrunRounds = <OverrunRound>[
  OverrunRound(
    contract: 'Lump sum, fixed price',
    what:
        'The excavation took longer than the contractor allowed for. Nothing '
        'about the scope changed.',
    priced: 100,
    actual: 118,
    pricedLabel: 'the fixed price',
    answer: Payer.contractor,
    why:
        'The price was the whole point of the contract and the owner has cost '
        'certainty because somebody else took the risk. The eighteen comes out '
        'of the contractor\'s margin.',
    source: 'eth-con-q2',
  ),
  OverrunRound(
    contract: 'Cost plus a fee',
    what:
        'Steel prices rose partway through and the contractor\'s invoices rose '
        'with them.',
    priced: 100,
    actual: 124,
    pricedLabel: 'the estimate',
    answer: Payer.owner,
    why:
        'Cost plus reimburses what the work actually cost, so the estimate was '
        'never a promise. The owner carries the overrun, which is the price of '
        'starting before the scope was pinned down.',
    source: 'eth-con-q2',
  ),
  OverrunRound(
    contract: 'Unit price, per cubic yard',
    what:
        'The bid quantity was ten thousand yards. Twelve thousand were '
        'actually placed, at the rate in the contract.',
    priced: 100,
    actual: 120,
    pricedLabel: 'the bid quantity',
    answer: Payer.owner,
    why:
        'Nothing overran. A unit-price contract prices a rate rather than a '
        'total, and the owner pays for every yard that goes in the ground, '
        'which is exactly why it is used when the quantity is not known yet.',
    source: 'eth-con-q2',
  ),
  OverrunRound(
    contract: 'Lump sum, with an owner-directed change',
    what:
        'The owner added a second stair core after the price was agreed. The '
        'extra cost is entirely that change.',
    priced: 100,
    actual: 115,
    pricedLabel: 'the original price',
    answer: Payer.owner,
    why:
        'A fixed price is fixed against the scope it was given. Changing the '
        'scope hands the risk back, and this is settled by change order rather '
        'than out of anybody\'s margin.',
    source: 'eth-con-q2',
  ),
  OverrunRound(
    contract: 'Time and materials',
    what:
        'The investigation took three weeks rather than the two everybody '
        'expected. The hours are all documented.',
    priced: 100,
    actual: 145,
    pricedLabel: 'the expectation',
    answer: Payer.owner,
    why:
        'Hours plus materials is a way of paying for work whose shape nobody '
        'knows yet, and an expectation is not a cap. It is why the method '
        'belongs on small or ill-defined scopes and nowhere else.',
    source: 'eth-con-q2',
  ),
  OverrunRound(
    contract: 'Construction manager at risk, guaranteed maximum',
    what:
        'The trades came in above the guaranteed maximum. The scope is '
        'unchanged from what the guarantee was given against.',
    priced: 100,
    actual: 109,
    pricedLabel: 'the guaranteed maximum',
    answer: Payer.contractor,
    why:
        'The word guaranteed is doing the work. Below the maximum the owner '
        'pays actual cost and above it the manager does, which is what puts '
        'the "at risk" in the name.',
    source: 'eth-con-q3',
  ),
];

class _WhoPaysTheOverrunGameState extends State<WhoPaysTheOverrunGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'who-pays-the-overrun',
    chapterId: 'ethics',
    total: overrunRounds.length,
    sourceProblemIdOf: (round) => overrunRounds[round].source,
  )..addListener(_onSession);

  Payer? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  OverrunRound get _round => overrunRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Who Pays the Overrun',
        closing:
            'Lump sum puts the risk on the contractor, cost plus and time and '
            'materials put it on the owner, and a guaranteed maximum draws a '
            'line and swaps them at it. Unit price is not an overrun at all, '
            'and changing the scope hands the risk back whatever was signed.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: riskBrief,
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
            'WHO ABSORBS THE DIFFERENCE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.creamDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              r.contract,
              style: AppTheme.code(size: 14),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            r.what,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: CostBarPainter(
                    priced: r.priced,
                    actual: r.actual,
                    pricedLabel: r.pricedLabel,
                    revealed: answered && !_session.correct!,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final (i, payer) in Payer.values.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _PayerButton(
                    key: ValueKey('payer-${payer.name}'),
                    label: payer == Payer.owner ? 'The owner' : 'The contractor',
                    selected: _picked == payer,
                    locked: answered,
                    isTruth: payer == r.answer,
                    onTap: answered
                        ? null
                        : () => setState(() => _picked = payer),
                  ),
                ),
              ],
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THEY DO' : 'THE OTHER SIDE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _PayerButton extends StatelessWidget {
  const _PayerButton({
    super.key,
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
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
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
