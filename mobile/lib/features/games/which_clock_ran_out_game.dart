import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'contract_figures.dart';
import 'lesson_brief.dart';
import 'liability_row.dart';

/// Which Clock Ran Out — the third item for `professional-liability`.
///
/// Two rules that sound alike and start from different events. Limitations
/// runs from when the harm was found; repose runs from substantial completion
/// and nothing that happens afterwards extends it. Read as two paragraphs they
/// blur together. Drawn as two windows on one line they stop being confusable,
/// and the case the lesson warns about becomes obvious: harm that appears
/// after the repose window has shut has nowhere to go.
class WhichClockRanOutGame extends StatefulWidget {
  const WhichClockRanOutGame({super.key});

  @override
  State<WhichClockRanOutGame> createState() => _WhichClockRanOutGameState();
}

enum Clock { inTime, limitations, repose }

@immutable
class ClockRound {
  const ClockRound({
    required this.subject,
    required this.completion,
    required this.discovery,
    required this.filed,
    required this.why,
    required this.source,
  });

  final String subject;
  final int completion;
  final int discovery;
  final int filed;
  final String why;
  final String source;

  /// The two periods are the same on every round, so that the years on the
  /// picture are the only thing that changes.
  static const reposeYears = 10;
  static const limitationYears = 3;

  /// Worked out from the dates rather than declared, so the answer and the
  /// picture cannot disagree.
  Clock get answer {
    if (filed > completion + reposeYears) return Clock.repose;
    if (filed > discovery + limitationYears) return Clock.limitations;
    return Clock.inTime;
  }
}

const clockRounds = <ClockRound>[
  ClockRound(
    subject: 'a claim brought promptly',
    completion: 2015,
    discovery: 2018,
    filed: 2020,
    why:
        'Inside both windows. Two years after it was found and five after the '
        'job finished, which is the ordinary case and the one worth seeing '
        'first.',
    source: 'eth-liab-q3',
  ),
  ClockRound(
    subject: 'harm that arrived far too late',
    completion: 2010,
    discovery: 2022,
    filed: 2023,
    why:
        'The limitations clock is fine, because it started when the harm was '
        'found. The repose window shut in 2020 and nothing reopens it, so the '
        'claim was barred before the harm existed.',
    source: 'eth-liab-q3',
  ),
  ClockRound(
    subject: 'a claim that sat on the desk',
    completion: 2015,
    discovery: 2016,
    filed: 2021,
    why:
        'Well inside the repose window and five years after the harm was '
        'found. Knowing about it and doing nothing is what the limitations '
        'clock is there to end.',
    source: 'eth-liab-q3',
  ),
  ClockRound(
    subject: 'a latent defect found late',
    completion: 2012,
    discovery: 2020,
    filed: 2021,
    why:
        'The limitations clock started in 2020 rather than when the damage '
        'began, which is the point of measuring from discovery. And 2021 is '
        'still inside the repose window, by a year.',
    source: 'eth-liab-q3',
  ),
  ClockRound(
    subject: 'an older building',
    completion: 2008,
    discovery: 2019,
    filed: 2020,
    why:
        'Filed the year after it was found, and it makes no difference. Twelve '
        'years had passed since completion, and the repose window is measured '
        'from that and from nothing else.',
    source: 'eth-liab-q3',
  ),
  ClockRound(
    subject: 'five years of thinking about it',
    completion: 2016,
    discovery: 2017,
    filed: 2022,
    why:
        'Six years after completion, so repose is not the problem. It was '
        'found in 2017 and brought in 2022, and three years is three years.',
    source: 'eth-liab-q3',
  ),
];

class _WhichClockRanOutGameState extends State<WhichClockRanOutGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-clock-ran-out',
    chapterId: 'ethics',
    total: clockRounds.length,
    sourceProblemIdOf: (round) => clockRounds[round].source,
  )..addListener(_onSession);

  Clock? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ClockRound get _round => clockRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Clock Ran Out',
        closing:
            'Limitations runs from when the harm was found. Repose runs from '
            'substantial completion and nothing extends it, which is why it '
            'can bar a claim before the harm has appeared at all. A claim has '
            'to land inside both windows.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: clocksBrief,
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
            'DID THE CLAIM LAND IN TIME',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 4),
          Text(
            'repose ${ClockRound.reposeYears} years from completion, '
            'limitations ${ClockRound.limitationYears} from discovery',
            style: AppTheme.mono(size: 10.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 190,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: TwoClocksPainter(
                    from: 2006,
                    to: 2030,
                    completion: r.completion,
                    discovery: r.discovery,
                    filed: r.filed,
                    reposeYears: ClockRound.reposeYears,
                    limitationYears: ClockRound.limitationYears,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (final c in Clock.values) ...[
            if (c != Clock.values.first) const SizedBox(height: 8),
            LiabilityRow(
              key: ValueKey('clock-${c.name}'),
              title: switch (c) {
                Clock.inTime => 'In time',
                Clock.limitations => 'Barred, the limitations clock',
                Clock.repose => 'Barred, the repose clock',
              },
              note: switch (c) {
                Clock.inTime => 'inside both windows',
                Clock.limitations => 'too long after it was found',
                Clock.repose => 'too long after the job finished',
              },
              selected: _picked == c,
              locked: answered,
              isTruth: c == r.answer,
              onTap: answered ? null : () => setState(() => _picked = c),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS RIGHT' : 'THE OTHER CLOCK',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
