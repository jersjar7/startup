import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'hydrograph_figures.dart';

/// Filling or Emptying — the third item for `hydrograph-watershed`.
///
/// Storage routing is one subtraction and a sign, and the sign is the part
/// that gets reversed. Inflow minus outflow is the rate the storage is
/// changing: positive means the pond is filling. Everything a detention
/// pond does for a catchment follows from holding water back while that
/// difference is positive, and the moment the two flows are equal is the
/// moment the pond is at its fullest.
class FillingOrEmptyingGame extends StatefulWidget {
  const FillingOrEmptyingGame({super.key});

  @override
  State<FillingOrEmptyingGame> createState() =>
      _FillingOrEmptyingGameState();
}

/// What the storage is doing.
enum Store { filling, emptying, holding }

extension StoreWords on Store {
  String get plain => switch (this) {
        Store.filling => 'Filling: the storage is going up',
        Store.emptying => 'Emptying: the storage is coming down',
        Store.holding => 'Neither: the storage is steady',
      };
}

@immutable
class PondRound {
  const PondRound({
    required this.subject,
    required this.setting,
    required this.pond,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Pond pond;
  final String why;
  final String source;

  /// Inflow minus outflow, and the sign of it. Never declared.
  Store get answer {
    if (pond.change.abs() < 0.01) return Store.holding;
    return pond.change > 0 ? Store.filling : Store.emptying;
  }
}

const pondRounds = <PondRound>[
  PondRound(
    subject: 'the lesson\'s own reservoir',
    setting: '800 cubic feet a second arriving, 500 leaving.',
    pond: Pond(inflow: 800, outflow: 500),
    why:
        'Filling, at 300 cubic feet a second. Inflow minus outflow is the '
        'rate the storage is changing, and it is positive, so water is piling '
        'up. Doing the subtraction the other way round gives the same 300 '
        'with the wrong sign attached, which is the trap the lesson names, '
        'and it is worth a sanity check every time: more coming in than '
        'going out has to mean more water in the pond.',
    source: 'wr-hw-q3',
  ),
  PondRound(
    subject: 'after the storm has gone through',
    setting: '200 cubic feet a second arriving, 450 still being let out.',
    pond: Pond(inflow: 200, outflow: 450),
    why:
        'Emptying, at 250. The outlet does not know the storm is over: it '
        'passes whatever the head above it dictates, so while the pond is '
        'still high it keeps releasing more than is arriving. That is the '
        'recovery half of the cycle, and a pond that cannot finish it before '
        'the next storm has no room left to be useful.',
    source: 'wr-hw-q3',
  ),
  PondRound(
    subject: 'the fullest moment',
    setting:
        '600 cubic feet a second arriving and 600 leaving, which happens '
        'once on the way down.',
    pond: Pond(inflow: 600, outflow: 600),
    why:
        'Neither: the storage is momentarily steady, and this is the instant '
        'the pond is at its fullest. It is worth knowing where it falls: on '
        'the FALLING limb of the inflow hydrograph, where the outflow curve '
        'crosses it. Everything before that moment was filling and everything '
        'after is emptying, so the peak outflow and the peak water level both '
        'happen right there.',
    source: 'wr-hw-q3',
  ),
  PondRound(
    subject: 'the storm arriving',
    setting: '1,200 cubic feet a second arriving, 300 leaving.',
    pond: Pond(inflow: 1200, outflow: 300),
    why:
        'Filling hard, at 900 a second. This is the whole purpose of the '
        'pond: the outlet is deliberately small, so on the rising limb almost '
        'everything that arrives is held back, and the catchment downstream '
        'never sees the 1,200. What it sees instead is the 300, and later a '
        'long gentle release.',
    source: 'wr-hw-q3',
  ),
  PondRound(
    subject: 'a long dry spell',
    setting: 'Nothing arriving, and 40 cubic feet a second still trickling '
        'out of the low level outlet.',
    pond: Pond(inflow: 0, outflow: 40),
    why:
        'Emptying. With no inflow at all the change is simply minus the '
        'outflow, and the pond draws down until the outlet has no head left '
        'over it. A detention basin is meant to end up empty; a retention '
        'pond is built to keep a permanent pool, and the difference is '
        'whether the outlet sits at the bottom.',
    source: 'wr-hw-q3',
  ),
  PondRound(
    subject: 'a steady state',
    setting: '350 cubic feet a second arriving and 350 leaving, hour after '
        'hour.',
    pond: Pond(inflow: 350, outflow: 350),
    why:
        'Neither. When the two match for any length of time the level simply '
        'sits where it is, which is what a reservoir passing a steady river '
        'does. Note that this is not a special case of the equation but the '
        'ordinary one: storage only changes when the two flows disagree.',
    source: 'wr-hw-q3',
  ),
];

class _FillingOrEmptyingGameState extends State<FillingOrEmptyingGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'filling-or-emptying',
    chapterId: 'water-resources',
    total: pondRounds.length,
    sourceProblemIdOf: (round) => pondRounds[round].source,
  )..addListener(_onSession);

  Store? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  PondRound get _round => pondRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Filling or Emptying',
        closing:
            'Inflow minus outflow is the rate the storage changes, and the '
            'sign is the whole answer: more in than out means the pond is '
            'filling. It fills through the rising limb, is at its fullest at '
            'the single moment the two flows are equal, and empties after '
            'that. Subtracting the other way round gives the right number '
            'with the wrong story attached.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: routingBrief,
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
            'WHAT IS THE STORAGE DOING',
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
          const SizedBox(height: 12),
          Container(
            height: 226,
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
                  painter: PondPainter(pond: r.pond, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$I - O = \dfrac{\Delta S}{\Delta t}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Store.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Store.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHAT IT IS DOING' : 'THE OTHER WAY',
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
