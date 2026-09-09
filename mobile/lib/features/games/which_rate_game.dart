import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'liability_row.dart';

/// Which Rate — the second item for `equivalence-interest-factors`.
///
/// A quoted rate is three numbers wearing one label. Twelve percent
/// compounded monthly means one percent a month, twelve percent on the paper,
/// and twelve point six eight percent actually earned over a year, and both of
/// the lesson's named traps are handing over one of the other two.
///
/// All three numbers are on screen every round, worked out already. The only
/// question is which one the sentence asked for, and which one belongs beside
/// the n you are about to use.
class WhichRateGame extends StatefulWidget {
  const WhichRateGame({super.key});

  @override
  State<WhichRateGame> createState() => _WhichRateGameState();
}

enum Rate { periodic, nominal, effective }

@immutable
class RateRound {
  const RateRound({
    required this.subject,
    required this.quoted,
    required this.ask,
    required this.periodic,
    required this.nominal,
    required this.effective,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;

  /// How the rate was quoted, in the words a lender would use.
  final String quoted;
  final String ask;

  /// The three numbers, already worked out.
  final String periodic;
  final String nominal;
  final String effective;

  final Rate answer;
  final String why;
  final String source;

  String valueOf(Rate r) => switch (r) {
    Rate.periodic => periodic,
    Rate.nominal => nominal,
    Rate.effective => effective,
  };
}

const rateRounds = <RateRound>[
  RateRound(
    subject: 'equipment finance',
    quoted: '12% nominal, compounded monthly',
    ask:
        'You are about to work in months, with n = 60. Which rate goes beside '
        'that n?',
    periodic: '1.00% per month',
    nominal: '12.00% per year',
    effective: '12.68% per year',
    answer: Rate.periodic,
    why:
        'The rate and the period have to match. Sixty monthly payments take '
        'the monthly rate, and putting an annual rate beside a monthly n is '
        'the error that makes an answer twelve times too big or too small.',
    source: 'econ-eif-q2',
  ),
  RateRound(
    subject: 'the same finance, differently asked',
    quoted: '12% nominal, compounded monthly',
    ask: 'What is the effective annual interest rate?',
    periodic: '1.00% per month',
    nominal: '12.00% per year',
    effective: '12.68% per year',
    answer: Rate.effective,
    why:
        'Compounding twelve times a year earns more than twelve percent, and '
        'the difference is the whole reason the word effective exists. Handing '
        'back the quoted twelve is the trap this problem was written for.',
    source: 'econ-eif-q2',
  ),
  RateRound(
    subject: 'what the paperwork says',
    quoted: '9% nominal, compounded quarterly',
    ask: 'What rate is printed on the loan agreement?',
    periodic: '2.25% per quarter',
    nominal: '9.00% per year',
    effective: '9.31% per year',
    answer: Rate.nominal,
    why:
        'The quoted rate is the one on the document and it is the least useful '
        'of the three. It is a label rather than a rate anybody earns or pays, '
        'and it exists to be divided by the number of periods.',
    source: 'econ-eif-q2',
  ),
  RateRound(
    subject: 'a bond paying twice a year',
    quoted: '6% nominal, compounded semiannually',
    ask: 'What does a year of this bond actually cost?',
    periodic: '3.00% per half-year',
    nominal: '6.00% per year',
    effective: '6.09% per year',
    answer: Rate.effective,
    why:
        'Two compoundings in the year, so a year costs slightly more than the '
        'six on the certificate. It is also the only one of the three you '
        'could hold up against an offer that compounds monthly.',
    source: 'econ-eif-q2',
  ),
  RateRound(
    subject: 'a rate that compounds every day',
    quoted: '8% nominal, compounded daily',
    ask:
        'You are about to work in days, with n = 365. Which rate goes beside '
        'that n?',
    periodic: '0.0219% per day',
    nominal: '8.00% per year',
    effective: '8.33% per year',
    answer: Rate.periodic,
    why:
        'Eight percent split across three hundred and sixty five days is a '
        'very small number, and it is the right one to sit beside an n counted '
        'in days. Dividing is all it takes, and it is the step people do '
        'correctly and then discard.',
    source: 'econ-eif-q2',
  ),
  RateRound(
    subject: 'a rate quoted plainly',
    quoted: '7% nominal, compounded annually',
    ask: 'What is the effective annual interest rate?',
    periodic: '7.00% per year',
    nominal: '7.00% per year',
    effective: '7.00% per year',
    answer: Rate.effective,
    why:
        'All three are the same number, and that is worth meeting once. '
        'Compounded annually there is only one period in the year, so nothing '
        'compounds on anything and the three collapse into each other.',
    source: 'econ-eif-q2',
  ),
];

class _WhichRateGameState extends State<WhichRateGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-rate',
    chapterId: 'economics',
    total: rateRounds.length,
    sourceProblemIdOf: (round) => rateRounds[round].source,
  )..addListener(_onSession);

  Rate? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  RateRound get _round => rateRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Rate',
        closing:
            'Three numbers, one label. The periodic rate goes beside a '
            'matching n, the effective rate is what a year actually costs and '
            'is the only one worth comparing across offers, and the quoted '
            'rate is the one on the paperwork and answers almost nothing.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: ratesBrief,
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
            'THREE NUMBERS, ONE LABEL',
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
            child: Text(r.quoted, style: AppTheme.code(size: 14)),
          ),
          const SizedBox(height: 10),
          Text(
            r.ask,
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
          const SizedBox(height: 16),
          for (final rate in Rate.values) ...[
            if (rate != Rate.values.first) const SizedBox(height: 8),
            LiabilityRow(
              key: ValueKey('rate-${rate.name}'),
              title: r.valueOf(rate),
              note: switch (rate) {
                Rate.periodic => 'the periodic rate, one compounding period',
                Rate.nominal => 'the nominal rate, as quoted',
                Rate.effective => 'the effective rate, what a year costs',
              },
              selected: _picked == rate,
              locked: answered,
              isTruth: rate == r.answer,
              onTap: answered ? null : () => setState(() => _picked = rate),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'A DIFFERENT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
