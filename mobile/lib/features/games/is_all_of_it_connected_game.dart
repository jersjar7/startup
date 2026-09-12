import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'tension_figures.dart';

/// Is All of It Connected — the third item for `steel-tension`.
///
/// Shear lag is the one idea in this lesson that is not bookkeeping. Load
/// entering a member through part of its section has to work its way across
/// into the rest, and it needs length to do that, so at the connection
/// itself the far-off parts are not pulling their weight. The factor U is
/// how much of the net area is really working, and whether it is one or less
/// can be read off a picture.
class IsAllOfItConnectedGame extends StatefulWidget {
  const IsAllOfItConnectedGame({super.key});

  @override
  State<IsAllOfItConnectedGame> createState() =>
      _IsAllOfItConnectedGameState();
}

@immutable
class LagRound {
  const LagRound({
    required this.subject,
    required this.asked,
    required this.grip,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Grip grip;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const lagRounds = <LagRound>[
  LagRound(
    subject: 'a flat bar',
    asked:
        'A flat bar bolted right across its width. What is the shear lag '
        'factor?',
    grip: Grip.allOfIt,
    options: [
      'One: every part of the section is connected',
      'Less than one, because bolts are never perfect',
      'Less than one, because of the holes',
      'It cannot be worked out without the connection length',
    ],
    answer: 0,
    why:
        'One. Every bit of the section is gripped by the bolts, so the whole '
        'net area is pulling from the first cross-section onward and there is '
        'nothing to lag. This is the case the exam uses most often, and it is '
        'why flat bar problems quietly say that U is one.',
    source: 'str-st-q3',
  ),
  LagRound(
    subject: 'an angle on one leg',
    asked:
        'An angle bolted through one leg only, with the other leg sticking '
        'out unattached. Now what?',
    grip: Grip.oneLeg,
    options: [
      'Less than one: the unconnected leg is not fully working at the '
          'connection',
      'One: the two legs are the same piece of steel',
      'One, provided the bolts are tight',
      'Zero for the unconnected leg, which is simply left out',
    ],
    answer: 0,
    why:
        'Less than one. The load arrives in the connected leg and has to '
        'travel across the corner into the other one, which takes length. At '
        'the critical section the outstanding leg is carrying less than its '
        'share, so the code counts less than the whole net area. It is not '
        'left out altogether either: the reduction is partial.',
    source: 'str-st-q3',
  ),
  LagRound(
    subject: 'what the reduction means',
    asked: 'What is physically going on when the factor is less than one?',
    grip: Grip.oneLeg,
    options: [
      'The load needs length to spread into the parts the bolts do not hold',
      'The unconnected part is thinner and therefore weaker',
      'The bolts bend and lose some of their grip',
      'The steel yields early beside the holes',
    ],
    answer: 0,
    why:
        'It needs length. Force entering through one leg spreads across the '
        'section gradually, and the critical section sits right where the '
        'spreading has hardly begun. That is the whole of shear lag, and it '
        'explains the fix: a LONGER connection gives the load more room to '
        'spread, and the factor rises toward one.',
    source: 'str-st-q3',
  ),
  LagRound(
    subject: 'a W shape by its flanges',
    asked:
        'A wide flange member spliced through its two flanges, with nothing '
        'attached to the web. What about this one?',
    grip: Grip.flangesOnly,
    options: [
      'Less than one: the web is the part left to catch up',
      'One: the flanges are most of the area anyway',
      'One, because the section is symmetric',
      'Zero, because the web is doing nothing',
    ],
    answer: 0,
    why:
        'Less than one, for the same reason as the angle: the web has to pick '
        'up its share across the depth of the section and there is not enough '
        'length at the splice for it to do so. The flanges being most of the '
        'area is exactly why the reduction here is mild rather than severe, '
        'but it is still a reduction.',
    source: 'str-st-q3',
  ),
  LagRound(
    subject: 'making it better',
    asked:
        'The angle connected through one leg is failing its rupture check by '
        'a little. What helps the shear lag factor most?',
    grip: Grip.oneLeg,
    options: [
      'Making the connection longer, so the load has room to spread',
      'Using higher grade steel',
      'Using larger bolts, which grip harder',
      'Nothing: the factor is a property of the shape',
    ],
    answer: 0,
    why:
        'Lengthen the connection. The factor is one less the distance from '
        'the face of the connection out to the centroid of the piece, divided '
        'by the LENGTH of the connection, so stretching that length raises '
        'the factor toward one. Bigger bolts do the opposite of helping: '
        'their holes take more area away.',
    source: 'str-st-q3',
  ),
  LagRound(
    subject: 'where the factor belongs',
    asked:
        'Does the shear lag factor come into the yielding check as well?',
    grip: Grip.allOfIt,
    options: [
      'No: it belongs to the rupture check and its effective net area',
      'Yes: it applies to both, being a property of the connection',
      'Yes, but only when it is less than 0.8',
      'No, and it does not belong to the rupture check either',
    ],
    answer: 0,
    why:
        'Rupture only. Yielding happens along the length of the member, far '
        'from the connection, where the load has long since spread itself '
        'evenly across the section, so there is no lag left to allow for. '
        'Every reduction in this lesson lives at the connection: the holes '
        'and the lag both, and both in the same one check.',
    source: 'str-st-q1',
  ),
];

class _IsAllOfItConnectedGameState extends State<IsAllOfItConnectedGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'is-all-of-it-connected',
    chapterId: 'structural',
    total: lagRounds.length,
    sourceProblemIdOf: (round) => lagRounds[round].source,
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

  LagRound get _round => lagRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Is All of It Connected',
        closing:
            'Load entering through part of a section needs length to spread '
            'into the rest, so at the connection the unattached parts are not '
            'yet pulling their share. Connected right across and the factor '
            'is one; through one leg or through the flanges alone and it is '
            'less. A longer connection raises it, bigger bolts do not, and '
            'the whole idea belongs to the rupture check and nowhere else.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: shearLagBrief,
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
            'HOW MUCH IS REALLY WORKING',
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
            height: 186,
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
                  painter: GripPainter(grip: r.grip, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$A_e = U A_n, \quad U = 1 - \bar{x}/L$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
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
