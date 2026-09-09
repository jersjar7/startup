import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// What Is Missing Yet — the first item for
/// `licensure-path-disciplinary-action`.
///
/// The lesson's easy problem is a candidate two years into a four-year
/// requirement, and its traps are the other two tracks: a master's cuts it to
/// three years and a doctorate to two, and a student who half-remembers the
/// list will read one of those onto a bachelor's record.
///
/// So the record is on screen as it would reach a board, five lines of fact,
/// and the question is the first requirement it does not meet. One record
/// meets all five, because a board that always finds something wrong is not
/// teaching anybody the ladder.
class WhatIsMissingYetGame extends StatefulWidget {
  const WhatIsMissingYetGame({super.key});

  @override
  State<WhatIsMissingYetGame> createState() => _WhatIsMissingYetGameState();
}

/// The five general requirements, in the order a board walks them.
const requirements = <String>[
  'The degree',
  'The FE exam',
  'The experience',
  'The PE exam',
  'The references',
];

/// The answer when the record clears all five. It sits one past the last
/// requirement, which is five; a const cannot read a list's length.
const readyIndex = 5;

@immutable
class RecordRound {
  const RecordRound({
    required this.subject,
    required this.degree,
    required this.fe,
    required this.experience,
    required this.pe,
    required this.references,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;

  /// The five lines of the record, exactly as stated.
  final String degree;
  final String fe;
  final String experience;
  final String pe;
  final String references;

  /// Index into [requirements], or [readyIndex] when nothing is missing.
  final int answer;
  final String why;
  final String source;
}

const recordRounds = <RecordRound>[
  RecordRound(
    subject: 'two years in, and applying',
    degree: 'BS from an EAC/ABET accredited program',
    fe: 'Passed',
    experience: '2 years, under a licensed PE',
    pe: 'Passed',
    references: '5 submitted',
    answer: 2,
    why:
        'A bachelor\'s asks for four years of progressive experience after the '
        'qualifying degree. Two years is the DOCTORAL track, and reading it '
        'onto a bachelor\'s record is the mistake this problem exists for.',
    source: 'eth-lpd-q1',
  ),
  RecordRound(
    subject: 'plenty of years, one exam short',
    degree: 'BS from an EAC/ABET accredited program',
    fe: 'Passed',
    experience: '5 years, progressive',
    pe: 'Not attempted',
    references: '5 submitted',
    answer: 3,
    why:
        'Experience does not accumulate into an exam. The years are there and '
        'the second paper still has to be sat, and there is nothing about a '
        'long record that shortens that.',
    source: 'eth-lpd-q1',
  ),
  RecordRound(
    subject: 'a record that clears',
    degree: 'MS in civil engineering, EAC/ABET accredited',
    fe: 'Passed',
    experience: '3 years, progressive',
    pe: 'Passed',
    references: '5 submitted',
    answer: readyIndex,
    why:
        'A master\'s reduces the experience requirement to three years, and '
        'three years is what this record has. Everything else is in place, and '
        'the honest answer is that there is nothing to add.',
    source: 'eth-lpd-q1',
  ),
  RecordRound(
    subject: 'years of work and no first exam',
    degree: 'BS from an EAC/ABET accredited program',
    fe: 'Not attempted',
    experience: '6 years, progressive',
    pe: 'Not attempted',
    references: '5 submitted',
    answer: 1,
    why:
        'The order is fixed and six years does not move it. The first exam '
        'comes before the certificate, the certificate comes before the '
        'second exam, and time served in the office changes none of that.',
    source: 'eth-lpd-q1',
  ),
  RecordRound(
    subject: 'a doctorate, and one year',
    degree: 'PhD, on an EAC/ABET accredited BS, used for the education',
    fe: 'Passed',
    experience: '1 year, progressive',
    pe: 'Passed',
    references: '5 submitted',
    answer: 2,
    why:
        'A doctorate with the FE behind it brings the requirement down to two '
        'years, and it does not bring it down to none. The degree that '
        'satisfied the education requirement cannot also be counted as the '
        'experience.',
    source: 'eth-lpd-q1',
  ),
  RecordRound(
    subject: 'everything but the paperwork',
    degree: 'BS from an EAC/ABET accredited program',
    fe: 'Passed',
    experience: '4 years, progressive',
    pe: 'Passed',
    references: '3 submitted',
    answer: 4,
    why:
        'Five references, acceptable to the board, is one of the five general '
        'requirements and not a formality attached to the others. A record '
        'that clears every exam and stops at three is not a complete '
        'application.',
    source: 'eth-lpd-q1',
  ),
];

class _WhatIsMissingYetGameState extends State<WhatIsMissingYetGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-is-missing-yet',
    chapterId: 'ethics',
    total: recordRounds.length,
    sourceProblemIdOf: (round) => recordRounds[round].source,
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

  RecordRound get _round => recordRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Is Missing Yet',
        closing:
            'Four years after a bachelor\'s, three after a master\'s, two '
            'after a doctorate with the FE behind it. The degree that bought '
            'the education requirement cannot be spent again on the '
            'experience, and five references are a requirement rather than a '
            'courtesy.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final lines = [
      ('DEGREE', r.degree),
      ('FE EXAM', r.fe),
      ('EXPERIENCE', r.experience),
      ('PE EXAM', r.pe),
      ('REFERENCES', r.references),
    ];

    return BoardShell(
      session: _session,
      brief: ladderBrief,
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
            'THE FIRST THING THIS RECORD LACKS',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              children: [
                for (final (i, line) in lines.indexed) ...[
                  if (i > 0)
                    const Divider(height: 1, color: AppColors.line),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 84,
                          child: Text(
                            line.$1,
                            style: AppTheme.overline(color: AppColors.ink3),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            line.$2,
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.35,
                              color: AppColors.charcoal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < requirements.length; i++) ...[
            if (i > 0) const SizedBox(height: 7),
            _MissingRow(
              key: ValueKey('missing-$i'),
              label: requirements[i],
              selected: _picked == i,
              locked: answered,
              isTruth: i == r.answer,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
          ],
          const SizedBox(height: 7),
          _MissingRow(
            key: const ValueKey('missing-ready'),
            label: 'Nothing. This record is complete.',
            selected: _picked == readyIndex,
            locked: answered,
            isTruth: r.answer == readyIndex,
            onTap: answered
                ? null
                : () => setState(() => _picked = readyIndex),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE GAP' : 'LOOK AGAIN',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _MissingRow extends StatelessWidget {
  const _MissingRow({
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 14.5, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
