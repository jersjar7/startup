import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'lifecycle_figures.dart';

/// Over the Whole Life — the third item for
/// `intellectual-property-sustainability`.
///
/// The lesson's medium problem hands you an option that costs more to build
/// and recommends it anyway, and the answer is a phrase: life-cycle analysis.
/// A phrase is a poor thing to test. The idea underneath it is a longer bar,
/// so both options are drawn out across their whole lives and the question is
/// which one an assessment favors.
///
/// One round has the cheaper option win on both counts, because a set where
/// the expensive one is always right teaches somebody to pick the expensive
/// one rather than to add up the bar.
class OverTheWholeLifeGame extends StatefulWidget {
  const OverTheWholeLifeGame({super.key});

  @override
  State<OverTheWholeLifeGame> createState() => _OverTheWholeLifeGameState();
}

@immutable
class LifeRound {
  const LifeRound({
    required this.subject,
    required this.setting,
    required this.options,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;

  /// Exactly two, each split into the four stages.
  final List<Option> options;
  final String why;
  final String source;

  /// Worked out from the bars rather than declared, so the picture and the
  /// answer cannot come apart.
  int get answer =>
      options[0].total <= options[1].total ? 0 : 1;

  /// Which one is cheapest to build, which is what a first glance sees.
  int get cheapestToBuild =>
      options[0].stages.first <= options[1].stages.first ? 0 : 1;
}

const lifeRounds = <LifeRound>[
  LifeRound(
    subject: 'a bridge replacement, two ways',
    setting:
        'Option B costs more to build, uses recycled steel, and needs far less '
        'maintenance over its life.',
    options: [
      Option('A', [40, 10, 55, 12]),
      Option('B', [58, 8, 20, 8]),
    ],
    why:
        'A costs less on the day it opens and more over its life, and the '
        'difference is nearly all maintenance. This is what a life-cycle '
        'assessment is for, and it is why the recommendation looked wrong to '
        'anybody reading only the first segment.',
    source: 'eth-ips-q2',
  ),
  LifeRound(
    subject: 'a pavement section',
    setting:
        'The thicker section costs more to lay and needs resurfacing half as '
        'often over a forty year horizon.',
    options: [
      Option('Thin', [30, 6, 70, 10]),
      Option('Thick', [46, 6, 34, 10]),
    ],
    why:
        'The same shape as the bridge and a familiar argument on every '
        'pavement job. Doing it once properly beats doing it cheaply four '
        'times, and the bar is where that stops being a slogan.',
    source: 'eth-ips-q2',
  ),
  LifeRound(
    subject: 'a pump station, two control schemes',
    setting:
        'The simpler scheme costs less to install, less to run, and about the '
        'same to maintain, and the plant is being decommissioned in twelve '
        'years either way.',
    options: [
      Option('Simple', [22, 30, 18, 6]),
      Option('Complex', [38, 26, 20, 9]),
    ],
    why:
        'Sometimes the cheap one really is the cheap one. A life-cycle '
        'assessment is a method rather than a verdict, and a set where the '
        'expensive option always wins is training somebody to guess.',
    source: 'eth-ips-q2',
  ),
  LifeRound(
    subject: 'a building envelope',
    setting:
        'The better envelope costs noticeably more to build and cuts the '
        'energy the building uses for the whole of its life.',
    options: [
      Option('Standard', [35, 62, 20, 8]),
      Option('Improved', [52, 30, 20, 8]),
    ],
    why:
        'The saving is in the operating segment rather than the maintenance '
        'one, and it is the largest segment on the bar. An envelope is bought '
        'once and paid for every month for sixty years.',
    source: 'eth-ips-q2',
  ),
  LifeRound(
    subject: 'a culvert material',
    setting:
        'One material is cheaper on every count except that it has to be '
        'removed and landfilled at the end, where the other is recovered and '
        'sold.',
    options: [
      Option('Landfilled', [26, 5, 22, 30]),
      Option('Recovered', [30, 5, 24, 4]),
    ],
    why:
        'The last segment decides it, and it is the one nobody prices because '
        'it happens after everybody involved has retired. Taking a thing away '
        'is part of its life whether it was budgeted for or not.',
    source: 'eth-ips-q2',
  ),
  LifeRound(
    subject: 'a treatment upgrade',
    setting:
        'The membrane process costs more to build and much less to run. The '
        'conventional process is cheap to build and needs constant chemicals '
        'and attention.',
    options: [
      Option('Conventional', [40, 70, 40, 10]),
      Option('Membrane', [70, 34, 30, 12]),
    ],
    why:
        'Two segments go the engineer\'s way and the first goes against, and '
        'the total is what an assessment compares. Adding the whole bar rather '
        'than arguing about the first block is the method in one sentence.',
    source: 'eth-ips-q2',
  ),
];

class _OverTheWholeLifeGameState extends State<OverTheWholeLifeGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'over-the-whole-life',
    chapterId: 'ethics',
    total: lifeRounds.length,
    sourceProblemIdOf: (round) => lifeRounds[round].source,
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

  LifeRound get _round => lifeRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Over the Whole Life',
        closing:
            'A life-cycle assessment adds the whole bar: building it, running '
            'it, keeping it and taking it away. The cheapest thing to build is '
            'regularly not the cheapest thing to own, and sometimes it is, '
            'which is why the method is worth more than the slogan.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: lifeCycleBrief,
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
            'WHICH ONE OVER THE WHOLE LIFE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.setting,
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
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 130,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: StagesPainter(
                    options: r.options,
                    revealed: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < r.options.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _OptionButton(
                    key: ValueKey('option-$i'),
                    label: r.options[i].name,
                    selected: _picked == i,
                    locked: answered,
                    isTruth: i == r.answer,
                    onTap: answered
                        ? null
                        : () => setState(() => _picked = i),
                  ),
                ),
              ],
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'OVER THE WHOLE LIFE' : 'ADD IT AGAIN',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
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
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
