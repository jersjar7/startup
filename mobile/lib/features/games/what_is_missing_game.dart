import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// What Is Missing — the first item for `particle-kinematics`.
///
/// Four equations cover straight line motion at constant acceleration, and the
/// lesson's own tip is a decision tree: no time in the problem, use the one
/// without time in it. That is the whole skill and it is not arithmetic. Each
/// equation is missing exactly one of the five quantities, so the question
/// that picks the equation is which quantity the problem never mentions.
class WhatIsMissingGame extends StatefulWidget {
  const WhatIsMissingGame({super.key});

  @override
  State<WhatIsMissingGame> createState() => _WhatIsMissingGameState();
}

/// The five things a straight line problem can talk about.
enum Known { startSpeed, endSpeed, distance, time, acceleration }

extension KnownWords on Known {
  String get plain => switch (this) {
        Known.startSpeed => 'the speed it started at',
        Known.endSpeed => 'the speed it ended at',
        Known.distance => 'how far it went',
        Known.time => 'how long it took',
        Known.acceleration => 'the acceleration',
      };

  String get tex => switch (this) {
        Known.startSpeed => 'v_0',
        Known.endSpeed => 'v',
        Known.distance => 's',
        Known.time => 't',
        Known.acceleration => 'a',
      };
}

@immutable
class AbsentRound {
  const AbsentRound({
    required this.subject,
    required this.setting,
    required this.given,
    required this.wanted,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;

  /// What the problem hands you.
  final List<Known> given;

  /// What it asks for.
  final Known wanted;

  final String why;
  final String source;

  /// The one quantity that is neither given nor wanted, which is the one the
  /// equation you need must be missing. Worked out rather than declared.
  Known get answer {
    final used = {...given, wanted};
    final spare = Known.values.where((k) => !used.contains(k)).toList();
    return spare.single;
  }

  /// The equation that leaves that quantity out.
  String get equation => switch (answer) {
        Known.distance => 'v = v_0 + at',
        Known.time => 'v^2 = v_0^2 + 2a(s - s_0)',
        Known.endSpeed => 's = s_0 + v_0 t + \\tfrac{1}{2}at^2',
        Known.startSpeed => 's = s_0 + vt - \\tfrac{1}{2}at^2',
        Known.acceleration => 's = s_0 + \\tfrac{1}{2}(v_0 + v)t',
      };
}

const absentRounds = <AbsentRound>[
  AbsentRound(
    subject: 'a car braking to a stop',
    setting:
        'A car doing twenty five meters a second brakes at five meters a '
        'second squared until it stops. How far does it travel?',
    given: [Known.startSpeed, Known.endSpeed, Known.acceleration],
    wanted: Known.distance,
    why:
        'Time. Nobody mentioned it and nobody asked for it, so the equation '
        'you want is the one with no t in it: v squared equals v naught '
        'squared plus two a s. This is the lesson\'s own first problem and its '
        'own tip. You could find the time first and then the distance, and you '
        'would get the same answer after twice the work.',
    source: 'dyn-pk-q1',
  ),
  AbsentRound(
    subject: 'a train pulling away',
    setting:
        'A train starts from rest and accelerates at a steady one and a half '
        'meters a second squared for forty seconds. How far has it gone?',
    given: [Known.startSpeed, Known.acceleration, Known.time],
    wanted: Known.distance,
    why:
        'The speed it ends at. It is never mentioned and it is not what was '
        'asked, so reach for s equals v naught t plus a half a t squared. '
        'Working out the final speed first is not wrong, it is just a step you '
        'were never asked to take.',
    source: 'dyn-pk-q1',
  ),
  AbsentRound(
    subject: 'a lift slowing down',
    setting:
        'A lift moving at three meters a second slows to a stop over four '
        'seconds. What was its deceleration?',
    given: [Known.startSpeed, Known.endSpeed, Known.time],
    wanted: Known.acceleration,
    why:
        'How far it went. The distance is neither given nor asked for, so use '
        'v equals v naught plus a t, which is the only one of the four with no '
        's in it. Note the sign: slowing down means a comes out negative, and '
        'the lesson names dropping that sign as its first trap.',
    source: 'dyn-pk-q1',
  ),
  AbsentRound(
    subject: 'a runway',
    setting:
        'A plane needs to reach seventy meters a second and has eighteen '
        'hundred meters of runway. Starting from rest, what acceleration does '
        'it need?',
    given: [Known.startSpeed, Known.endSpeed, Known.distance],
    wanted: Known.acceleration,
    why:
        'Time again, so it is the same equation as the braking car read the '
        'other way round. Two very different sounding problems, one shape: '
        'speeds at both ends, a distance, and nobody counting seconds.',
    source: 'dyn-pk-q1',
  ),
  AbsentRound(
    subject: 'a stone dropped down a well',
    setting:
        'A stone is dropped from rest and hits the water after two point one '
        'seconds. How deep is the well? Gravity is the acceleration.',
    given: [Known.startSpeed, Known.acceleration, Known.time],
    wanted: Known.distance,
    why:
        'The speed it hits at. Same shape as the train pulling away, and the '
        'only difference is that the acceleration is gravity and the motion is '
        'downward. The four equations do not care which way up the problem is '
        'drawn, only which quantity is absent.',
    source: 'dyn-pk-q2',
  ),
  AbsentRound(
    subject: 'a cyclist over a measured mile',
    setting:
        'A cyclist crosses a five hundred meter stretch in twenty five '
        'seconds, entering at twelve meters a second and leaving faster. How '
        'fast were they going at the end?',
    given: [Known.startSpeed, Known.distance, Known.time],
    wanted: Known.endSpeed,
    why:
        'The acceleration, which nobody has mentioned. The equation with no a '
        'in it is the average speed one: the distance is the average of the '
        'two speeds times the time. It is the least remembered of the four and '
        'the easiest to reconstruct, since it is only saying that at a steady '
        'acceleration the average speed is halfway between the two.',
    source: 'dyn-pk-q1',
  ),
];

class _WhatIsMissingGameState extends State<WhatIsMissingGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-is-missing',
    chapterId: 'dynamics',
    total: absentRounds.length,
    sourceProblemIdOf: (round) => absentRounds[round].source,
  )..addListener(_onSession);

  Known? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  AbsentRound get _round => absentRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Is Missing',
        closing:
            'Five quantities, four equations, and each equation leaves exactly '
            'one of them out. Find the one the problem never mentions and it '
            'has chosen your equation for you. The one that comes up most is '
            'time: no seconds anywhere means v squared equals v naught squared '
            'plus two a s.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: missingBrief,
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
            'TAP WHAT THE PROBLEM NEVER MENTIONS',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.setting,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 14),
          for (final k in Known.values) ...[
            _Choice(
              tex: k.tex,
              label: k.plain,
              selected: _picked == k,
              locked: answered,
              isTruth: k == r.answer,
              onTap: answered ? null : () => setState(() => _picked = k),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SO THE EQUATION IS',
                    style: AppTheme.overline(color: AppColors.forest),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: MathText(
                      '\$${r.equation}\$',
                      style: const TextStyle(
                        fontSize: 17,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ABSENT ONE' : 'LOOK AGAIN',
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
    required this.tex,
    required this.label,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String tex;
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: MathText(
                  '\$$tex\$',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
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
