import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'seepage_figures.dart';

/// Counting the Net — the first item for `permeability-seepage`.
///
/// A flow net turns a seepage problem into two counts, and the marks go to
/// whoever gets the fraction the right way up. More lanes for the water to
/// run in means more water, so the channels go on top; more steps to come
/// down means less, so the drops go underneath. The lesson prints the
/// inverted version as a wrong answer, and it is off by a factor of nine.
class CountingTheNetGame extends StatefulWidget {
  const CountingTheNetGame({super.key});

  @override
  State<CountingTheNetGame> createState() => _CountingTheNetGameState();
}

@immutable
class NetRound {
  const NetRound({
    required this.subject,
    required this.asked,
    required this.net,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final FlowNet net;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const _lessonNet = FlowNet(channels: 4, drops: 12, head: 6, k: 2e-5);
const _wideNet = FlowNet(channels: 6, drops: 12, head: 6, k: 2e-5);
const _deepNet = FlowNet(channels: 4, drops: 18, head: 6, k: 2e-5);

const netRounds = <NetRound>[
  NetRound(
    subject: 'which way up the fraction goes',
    asked:
        'Four flow channels and twelve head drops. Which way round do they '
        'go in the seepage formula?',
    net: _lessonNet,
    options: [
      'Channels over drops: four twelfths of the head times the '
          'conductivity',
      'Drops over channels: three times the head times the conductivity',
      'Their product, twelve times four',
      'Their difference, eight',
    ],
    answer: 0,
    why:
        'Channels on top. More lanes for the water to run in means more water '
        'getting through, and more steps to come down in means the head is '
        'being spent more gradually, so less. Turning the fraction over here '
        'multiplies the answer by nine, and the lesson lists that as a '
        'choice.',
    source: 'geo-seep-q3',
  ),
  NetRound(
    subject: 'what a channel is',
    asked:
        'What does one flow channel mean on this drawing?',
    net: _lessonNet,
    options: [
      'A lane between two flow lines that carries its own share of the water',
      'A single line the water follows',
      'One of the steps the head comes down in',
      'The path of the fastest water',
    ],
    answer: 0,
    why:
        'A lane between two lines, not a line itself. That is why the count '
        'is one less than the number of flow lines drawn, which is the sort '
        'of off-by-one a tired reader makes at the end of a long problem. '
        'Each lane carries the same quantity as every other.',
    source: 'geo-seep-q3',
  ),
  NetRound(
    subject: 'what a drop is',
    asked:
        'And what is one equipotential drop?',
    net: _lessonNet,
    options: [
      'One equal step of head, the total head divided by the number of '
          'drops',
      'One meter of head',
      'The head lost in the first lane',
      'The head at the downstream side',
    ],
    answer: 0,
    why:
        'An equal step. With twelve drops across six meters of head, every '
        'step is half a meter, which is what makes a flow net useful for more '
        'than the total: the head at any point in the ground can be read by '
        'counting the drops to get there.',
    source: 'geo-seep-q3',
  ),
  NetRound(
    subject: 'a wider net',
    asked:
        'The same structure is redrawn with six channels instead of four, '
        'with the drops unchanged. What happens to the seepage?',
    net: _wideNet,
    options: [
      'It rises by half',
      'It falls by half',
      'Nothing: the net is only a drawing',
      'It rises by six twelfths',
    ],
    answer: 0,
    why:
        'It rises by half, since four lanes have become six. In practice a '
        'net drawn with more channels usually means the drops have gone up '
        'too, because the squares have to stay square; but where only the '
        'channels change, the water changes with them in proportion.',
    source: 'geo-seep-q3',
  ),
  NetRound(
    subject: 'more steps to come down',
    asked:
        'A deeper sheet pile makes the water take a longer way round: still '
        'four channels, but eighteen drops instead of twelve. What happens to '
        'the seepage?',
    net: _deepNet,
    options: [
      'It falls to two thirds of what it was',
      'It rises by half',
      'Nothing: the head has not changed',
      'It falls to four eighteenths of the head',
    ],
    answer: 0,
    why:
        'Two thirds. Driving the pile deeper makes the water travel further '
        'for the same total head, which is the same as saying the head comes '
        'down in more, smaller steps. That is exactly why sheet piles are '
        'driven deeper than they need to be for support alone.',
    source: 'geo-seep-q3',
  ),
  NetRound(
    subject: 'what the net does not depend on',
    asked:
        'The same structure is built in a sand ten times more permeable. What '
        'happens to the drawing itself, the lines and the counts?',
    net: _lessonNet,
    options: [
      'Nothing: the shape of the net is geometry, and only the quantity '
          'changes',
      'The channels multiply by ten',
      'The drops multiply by ten',
      'The net cannot be drawn for a different soil',
    ],
    answer: 0,
    why:
        'The drawing is unchanged. A flow net is decided by the shape of the '
        'ground and the structure, not by how permeable the soil is: the '
        'conductivity sits outside the counts and multiplies whatever they '
        'give. So one net serves for the same geometry in any uniform soil, '
        'which is most of why nets are worth drawing.',
    source: 'geo-seep-q1',
  ),
];

class _CountingTheNetGameState extends State<CountingTheNetGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'counting-the-net',
    chapterId: 'geotechnical',
    total: netRounds.length,
    sourceProblemIdOf: (round) => netRounds[round].source,
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

  NetRound get _round => netRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Counting the Net',
        closing:
            'Channels over drops, never the other way: more lanes means more '
            'water and more steps means less. A channel is the lane BETWEEN '
            'two flow lines, so the count is one less than the lines drawn. '
            'Every drop is an equal step of head. And the net itself is '
            'geometry: the same drawing serves for any uniform soil, with the '
            'conductivity waiting outside the fraction.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: flowNetBrief,
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
            'READING THE NET',
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
            height: 216,
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
                  painter: FlowNetPainter(net: r.net, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$q = k H \frac{N_f}{N_d}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
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
