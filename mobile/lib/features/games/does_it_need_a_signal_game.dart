import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'sign_figures.dart';

/// Does It Need a Signal — the second item for `traffic-control-devices`.
///
/// A signal is not automatically an improvement. The manual requires a
/// warrant because an unwarranted signal buys delay and rear-end crashes
/// without buying safety, and because meeting a warrant shows a signal is
/// justified rather than required.
class DoesItNeedASignalGame extends StatefulWidget {
  const DoesItNeedASignalGame({super.key});

  @override
  State<DoesItNeedASignalGame> createState() =>
      _DoesItNeedASignalGameState();
}

@immutable
class WarrantRound {
  const WarrantRound({
    required this.subject,
    required this.asked,
    required this.crossing,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Junction crossing;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const _quiet = Junction(
  description: 'a quiet crossroads, a few dozen vehicles an hour',
  warrantMet: null,
  note: 'a signal here would add delay and rear-end crashes',
);

const _busy = Junction(
  description: 'heavy on the main road and the side road, all day',
  warrantMet: 'eight hours of heavy volume',
);

const _school = Junction(
  description: 'children crossing four lanes to school, twice a day',
  warrantMet: 'a school crossing',
);

const _crashes = Junction(
  description: 'five right-angle crashes in a year, and stop signs already',
  warrantMet: 'a crash history a signal would fix',
);

const warrantRounds = <WarrantRound>[
  WarrantRound(
    subject: 'why ask at all',
    asked:
        'Why does the manual require a warrant analysis before a signal goes '
        'in?',
    crossing: _busy,
    options: [
      'To slow the work down',
      'Because a signal is not automatically an improvement: an unwarranted '
          'one adds delay and rear-end crashes',
      'Because signals are expensive to buy',
      'Because the state has to approve every signal',
    ],
    answer: 1,
    why:
        'Because it can make things worse. A signal stops traffic that did '
        'not have to stop before, which costs delay and produces rear-end '
        'crashes, and drivers who wait at an empty red learn to ignore it. '
        'The warrant is there to prove the trade is worth making.',
    source: 'trans-tcd-q2',
  ),
  WarrantRound(
    subject: 'what meeting a warrant means',
    asked:
        'This crossroads meets the eight hour volume warrant. Must a signal '
        'be installed?',
    crossing: _busy,
    options: [
      'Yes, immediately: a met warrant is a requirement',
      'No: meeting a warrant shows a signal is justified, and engineering '
          'judgment still decides',
      'No: warrants are advisory and rarely used',
      'Only if two warrants are met',
    ],
    answer: 1,
    why:
        'It is justified, not required. The warrant is a threshold that has '
        'to be passed before a signal may be considered at all, and the '
        'decision after that still rests on judgment: sight distance, the '
        'other approaches, what a roundabout would do instead.',
    source: 'trans-tcd-q2',
  ),
  WarrantRound(
    subject: 'a quiet crossroads',
    asked:
        'A resident asks for a signal here, where a few dozen vehicles an '
        'hour cross. What is the likely answer?',
    crossing: _quiet,
    options: [
      'Install it: a signal is always safer',
      'No warrant is met, and a signal would probably make this intersection '
          'worse',
      'Install it, but only at peak times',
      'Replace it with a stop sign on all four approaches',
    ],
    answer: 1,
    why:
        'No warrant, and a signal here would be a poor trade: long waits at '
        'a red with nothing coming, drivers who start to disregard it, and '
        'rear-end crashes on a road that had almost none. This is the '
        'commonest request an agency receives and usually the right one to '
        'refuse.',
    source: 'trans-tcd-q2',
  ),
  WarrantRound(
    subject: 'children crossing',
    asked:
        'Here the volumes are moderate, but children cross four lanes twice a '
        'day. Is there a warrant for that?',
    crossing: _school,
    options: [
      'No: only vehicle volumes count',
      'Yes: a school crossing is a warrant of its own',
      'Only if the crossing is on a state highway',
      'Only during the school year',
    ],
    answer: 1,
    why:
        'Yes. The warrants are not all about vehicle counts: there is one for '
        'a school crossing, one for people waiting to cross on foot, and one '
        'for a crash history. A crossing can qualify on any of them without '
        'ever meeting the volume tests.',
    source: 'trans-tcd-q2',
  ),
  WarrantRound(
    subject: 'a crash history',
    asked:
        'This intersection already has stop signs and has had five '
        'right-angle crashes in a year. What does that suggest?',
    crossing: _crashes,
    options: [
      'Nothing: crashes are not part of the warrants',
      'The crash experience warrant may be met, since a signal separates the '
          'conflicting movements in time',
      'The stop signs should be removed',
      'The speed limit should be raised',
    ],
    answer: 1,
    why:
        'That the crash warrant may be met. Right-angle crashes are the kind '
        'a signal actually prevents, because it separates the conflicting '
        'movements in time. It is the pattern of crashes, not only the count, '
        'that decides whether a signal is the right treatment.',
    source: 'trans-tcd-q2',
  ),
  WarrantRound(
    subject: 'what a signal trades',
    asked:
        'A signal is installed where a warrant is met. Which crashes tend to '
        'go up?',
    crossing: _crashes,
    options: [
      'Rear-end crashes, because traffic now has to stop',
      'Right-angle crashes',
      'None: every kind falls',
      'Only crashes involving pedestrians',
    ],
    answer: 0,
    why:
        'Rear-end. The signal trades the crash type it is good at preventing, '
        'the right-angle collision that injures people, for one it causes, '
        'the rear-end shunt that usually does not. That is a trade worth '
        'making where the angle crashes are happening and a bad one where '
        'they are not.',
    source: 'trans-tcd-q2',
  ),
];

class _DoesItNeedASignalGameState extends State<DoesItNeedASignalGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'does-it-need-a-signal',
    chapterId: 'transportation',
    total: warrantRounds.length,
    sourceProblemIdOf: (round) => warrantRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  WarrantRound get _round => warrantRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Does It Need a Signal',
        closing:
            'A signal stops traffic that did not have to stop, so it buys '
            'delay and rear-end crashes and must earn its place. Meeting a '
            'warrant shows it is justified, not that it is required. The '
            'warrants cover volumes, people on foot, school crossings and '
            'crash history, and an intersection can qualify on any of them.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: warrantBrief,
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
            'BEFORE A SIGNAL GOES IN',
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
            height: 196,
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
                  painter: WarrantPainter(
                    crossing: r.crossing,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
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
