import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Practice, or the Title — the third item for
/// `definitions-practice-of-engineering`.
///
/// The lesson's hard problem is a phone app that sizes steel members for
/// decks, and its point is that the Model Law does not care what the work is
/// delivered on. Paper, a spreadsheet, a book of tables or an app: if the
/// output is engineering judgment that reaches the public, it is practice.
///
/// The lesson also prints a separate warning, and it is the third answer here.
/// You do not have to do any engineering at all to break the law. Calling
/// yourself a Professional Engineer when you are not is a violation on its
/// own, and the two failures are easy to confuse because they usually travel
/// together.
class PracticeOrTitleGame extends StatefulWidget {
  const PracticeOrTitleGame({super.key});

  @override
  State<PracticeOrTitleGame> createState() => _PracticeOrTitleGameState();
}

enum Verdict { practice, title, neither }

@immutable
class VerdictCase {
  const VerdictCase({
    required this.subject,
    required this.scene,
    required this.answer,
    required this.rule,
    required this.why,
    required this.source,
  });

  final String subject;
  final String scene;
  final Verdict answer;
  final String rule;
  final String why;
  final String source;
}

const verdictCases = <VerdictCase>[
  VerdictCase(
    subject: 'a deck design app for homeowners',
    scene:
        'A developer with no licence writes a phone app that calculates beam '
        'deflections and recommends steel member sizes for residential decks, '
        'and sells it to homeowners as a DIY structural design tool. No '
        'licensed engineer is involved in how it works.',
    answer: Verdict.practice,
    rule: 'Model Law 110.20 A.3',
    why:
        'The output is a member size somebody will stand on. Delivering it '
        'through an app rather than a drawing changes the medium and not the '
        'service, and handing the tap to the homeowner does not move the '
        'judgment out of the software.',
    source: 'eth-dpe-q3',
  ),
  VerdictCase(
    subject: 'a headline on a professional profile',
    scene:
        'An unlicensed graduate works as a drafter and does no design work at '
        'all. Their public professional profile gives their title as '
        'Professional Engineer.',
    answer: Verdict.title,
    rule: 'Model Law 110.20 A.3(b)',
    why:
        'No engineering was practised and the law was still broken. Holding '
        'yourself out as a Professional Engineer is its own offence, whatever '
        'you actually spend the day doing.',
    source: 'eth-dpe-q3',
  ),
  VerdictCase(
    subject: 'a book of span tables',
    scene:
        'A publisher sells builders a book of standard joist and rafter span '
        'tables. The tables were prepared and sealed by a licensed engineer, '
        'and the book says so on the cover.',
    answer: Verdict.neither,
    rule: 'Model Law 110.20 A.3',
    why:
        'The engineering was done by somebody licensed, who took '
        'responsibility for it in the ordinary way. The publisher is selling '
        'a book and is not claiming to be an engineer while doing it.',
    source: 'eth-dpe-q3',
  ),
  VerdictCase(
    subject: 'a landscaping firm and some tall walls',
    scene:
        'A landscaping company designs and builds segmental retaining walls up '
        'to eight feet tall, above the height its state exempts. Nobody at the '
        'company is licensed and no engineer is engaged.',
    answer: Verdict.practice,
    rule: 'Model Law 110.20 A.3',
    why:
        'Above the exempt height it is a structure, and designing structures '
        'is the practice of engineering whoever is holding the shovel. Nobody '
        'here has claimed a title, and the work alone is enough.',
    source: 'eth-dpe-q3',
  ),
  VerdictCase(
    subject: 'a spreadsheet that converts units',
    scene:
        'A small software firm sells a spreadsheet that converts between units '
        'and rearranges standard formulas. It performs no design, recommends '
        'nothing, and is sold under the name Unit Tools.',
    answer: Verdict.neither,
    rule: 'Model Law 110.20 A.3',
    why:
        'A calculator is a calculator. Nothing here reaches a design decision '
        'and nothing here claims a title, and being useful to engineers does '
        'not make a product the practice of engineering.',
    source: 'eth-dpe-q3',
  ),
  VerdictCase(
    subject: 'a licence that stops at the state line',
    scene:
        'An engineer is licensed in one state and not in the neighbouring one. '
        'Their firm\'s website advertises them by name, with PE after it, as '
        'available for work in both.',
    answer: Verdict.title,
    rule: 'Model Law 110.20 A.3(b) and A.10',
    why:
        'The licence is real and it stops at the state line. Being advertised '
        'as a Professional Engineer available in a state that has not licensed '
        'you is the representation offence, before a single piece of work has '
        'been taken on there.',
    source: 'eth-dpe-q3',
  ),
];

class _PracticeOrTitleGameState extends State<PracticeOrTitleGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'practice-or-title',
    chapterId: 'ethics',
    total: verdictCases.length,
    sourceProblemIdOf: (round) => verdictCases[round].source,
  )..addListener(_onSession);

  Verdict? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  VerdictCase get _round => verdictCases[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Practice, or the Title',
        closing:
            'Two separate offences that usually arrive together. Doing the '
            'work without a licence is one, and claiming the title without a '
            'licence is the other, and either is enough on its own. The medium '
            'the work is delivered on has never been part of the test.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: holdingOutBrief,
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
            'WHAT IS BEING BROKEN, IF ANYTHING',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.scene,
            style: const TextStyle(
              fontSize: 15,
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
          for (final v in Verdict.values) ...[
            if (v != Verdict.values.first) const SizedBox(height: 8),
            _VerdictRow(
              key: ValueKey('verdict-${v.name}'),
              title: switch (v) {
                Verdict.practice => 'Practising without a licence',
                Verdict.title => 'The title, not the work',
                Verdict.neither => 'Neither',
              },
              note: switch (v) {
                Verdict.practice =>
                  'engineering judgment reaching the public',
                Verdict.title =>
                  'held out as a PE, whatever the work was',
                Verdict.neither => 'no engineering, and no claim to be one',
              },
              selected: _picked == v,
              locked: answered,
              isTruth: v == r.answer,
              onTap: answered ? null : () => setState(() => _picked = v),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            Text('THE RULE', style: AppTheme.overline(color: AppColors.ink3)),
            const SizedBox(height: 4),
            Text(r.rule, style: AppTheme.code(size: 13)),
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

class _VerdictRow extends StatelessWidget {
  const _VerdictRow({
    super.key,
    required this.title,
    required this.note,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String title;
  final String note;
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                note,
                style: AppTheme.mono(size: 10.5, color: AppColors.ink3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
