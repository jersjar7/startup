import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'weir_figures.dart';

/// Which Weir Notices More — the second item for `pipe-systems-weirs`.
///
/// An exponent is not a piece of notation, it is a sensitivity. Three halves
/// means doubling the head multiplies the flow by about 2.8. Five halves
/// means doubling it multiplies the flow by 5.7. That difference is the
/// whole reason a V-notch is what gets installed where the flow is small and
/// has to be measured well, and it is worth having in your hands rather than
/// in a formula.
class WhichWeirNoticesMoreGame extends StatefulWidget {
  const WhichWeirNoticesMoreGame({super.key});

  @override
  State<WhichWeirNoticesMoreGame> createState() =>
      _WhichWeirNoticesMoreGameState();
}

/// Which of the two weirs changes by the larger factor.
enum Notices { top, bottom, same }

extension NoticesWords on Notices {
  String get plain => switch (this) {
        Notices.top => 'Weir A, the top one',
        Notices.bottom => 'Weir B, the bottom one',
        Notices.same => 'Neither: the same factor',
      };
}

@immutable
class NoticeRound {
  const NoticeRound({
    required this.subject,
    required this.change,
    required this.top,
    required this.bottom,
    required this.thenTop,
    required this.thenBottom,
    required this.why,
    required this.source,
  });

  final String subject;

  /// What happens to the head, in plain words.
  final String change;
  final Weir top;
  final Weir bottom;

  /// The head each weir ends up with.
  final double thenTop;
  final double thenBottom;
  final String why;
  final String source;

  double get factorTop => top.flowAt(thenTop) / top.flow;

  double get factorBottom => bottom.flowAt(thenBottom) / bottom.flow;

  /// Which moved further, measured as a factor rather than as a difference
  /// so that two weirs of different sizes can be compared at all.
  Notices get answer {
    final a = (math.log(factorTop)).abs();
    final b = (math.log(factorBottom)).abs();
    if ((a - b).abs() < 0.01) return Notices.same;
    return a > b ? Notices.top : Notices.bottom;
  }
}

const noticeRounds = <NoticeRound>[
  NoticeRound(
    subject: 'a flat crest against a V',
    change: 'The head on both goes from 1 foot to 2 feet.',
    top: Weir(notch: Notch.fullWidth, head: 1, crest: 4, channel: 4),
    bottom: Weir(notch: Notch.vee, head: 1, channel: 5),
    thenTop: 2,
    thenBottom: 2,
    why:
        'The V-notch, and by a long way. Doubling the head multiplies a '
        'rectangular weir by 2 to the three halves, about 2.8, and a V-notch '
        'by 2 to the five halves, about 5.7. Twice the depth of water over a '
        'V sends nearly six times the flow. That steepness is exactly why a V '
        'is chosen where the flow is small: a small change in flow shows up '
        'as a change in level you can actually read.',
    source: 'wr-psw-q2',
  ),
  NoticeRound(
    subject: 'two V-notches, starting from different heads',
    change:
        'Both heads double: the top one from 0.5 feet, the bottom from 1.5.',
    top: Weir(notch: Notch.vee, head: 0.5, channel: 5),
    bottom: Weir(notch: Notch.vee, head: 1.5, channel: 5),
    thenTop: 1,
    thenBottom: 3,
    why:
        'Neither: both go up by the same 5.7 times. A power law only cares '
        'about the RATIO the head changed by, not where it started, so '
        'doubling is doubling whether the notch was barely wet or nearly '
        'full. This is worth seeing once, because it is what lets you answer '
        'a question like this without knowing any of the actual numbers.',
    source: 'wr-psw-q2',
  ),
  NoticeRound(
    subject: 'suppressed against contracted',
    change: 'The head on both goes from 0.5 feet to 1.5 feet.',
    top: Weir(notch: Notch.fullWidth, head: 0.5, crest: 3, channel: 3),
    bottom: Weir(notch: Notch.contracted, head: 0.5, crest: 3, channel: 7),
    thenTop: 1.5,
    thenBottom: 1.5,
    why:
        'The suppressed one, though only just. Both are three halves weirs, '
        'so most of the change is identical, but the contracted one loses '
        'crest length as the head rises: the correction takes 0.2 times H off '
        'it, and H got bigger. A weir that eats its own length grows a little '
        'more slowly, which is a detail worth knowing exists rather than one '
        'worth computing in your head.',
    source: 'wr-psw-q1',
  ),
  NoticeRound(
    subject: 'the flow falls away',
    change: 'A dry spell halves the head on both, from 2 feet to 1.',
    top: Weir(notch: Notch.fullWidth, head: 2, crest: 4, channel: 4),
    bottom: Weir(notch: Notch.vee, head: 2, channel: 6),
    thenTop: 1,
    thenBottom: 1,
    why:
        'The V-notch again. Steepness cuts both ways: halving the head takes '
        'a rectangular weir down to about a third of its flow and a V-notch '
        'to about a sixth. It is the same exponent doing the same work in the '
        'other direction, and it is why a V-notch reads low flows so well and '
        'runs out of range so quickly when the flow comes up.',
    source: 'wr-psw-q2',
  ),
  NoticeRound(
    subject: 'a small rise',
    change: 'The head on both creeps up by a fifth, from 1.0 to 1.2 feet.',
    top: Weir(notch: Notch.vee, head: 1, channel: 5),
    bottom: Weir(notch: Notch.fullWidth, head: 1, crest: 4, channel: 4),
    thenTop: 1.2,
    thenBottom: 1.2,
    why:
        'The V-notch, on top this time. A fifth more head is 1.2 to the five '
        'halves, about 1.58, against 1.2 to the three halves, about 1.31. '
        'Even on a small change the steeper weir moves half again as far, '
        'and the answer does not depend on which weir is drawn where.',
    source: 'wr-psw-q2',
  ),
  NoticeRound(
    subject: 'two flat crests of different lengths',
    change: 'The head on both goes from 0.8 feet to 1.6.',
    top: Weir(notch: Notch.fullWidth, head: 0.8, crest: 2, channel: 2),
    bottom: Weir(notch: Notch.fullWidth, head: 0.8, crest: 8, channel: 8),
    thenTop: 1.6,
    thenBottom: 1.6,
    why:
        'Neither. The crest length multiplies the flow but it does not '
        'change how the flow RESPONDS: L sits outside the power, so both of '
        'these go up by the same 2.8 times. The long weir passes four times '
        'as much water throughout, and it always did.',
    source: 'wr-psw-q1',
  ),
];

class _WhichWeirNoticesMoreGameState extends State<WhichWeirNoticesMoreGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-weir-notices-more',
    chapterId: 'water-resources',
    total: noticeRounds.length,
    sourceProblemIdOf: (round) => noticeRounds[round].source,
  )..addListener(_onSession);

  Notices? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  NoticeRound get _round => noticeRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Weir Notices More',
        closing:
            'The exponent is a sensitivity. Doubling the head multiplies a '
            'rectangular weir by about 2.8 and a V-notch by about 5.7, and '
            'halving it cuts them by the same factors the other way. Only '
            'the ratio the head changed by matters, never where it started, '
            'and the crest length sits outside the power so it never changes '
            'the response at all.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: exponentBrief,
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
            'WHICH FLOW MOVES BY THE BIGGER FACTOR',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            '${r.change} The dashed green line is where the water ends up.',
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          _Plate(weir: r.top, then: r.thenTop, name: 'A', locked: answered,
              won: answered && r.answer == Notices.top ||
                  answered && r.answer == Notices.same),
          const SizedBox(height: 8),
          _Plate(weir: r.bottom, then: r.thenBottom, name: 'B',
              locked: answered,
              won: answered && r.answer == Notices.bottom ||
                  answered && r.answer == Notices.same),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$Q \propto H^{3/2}$  or  $H^{5/2}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Notices.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Notices.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE STEEPER ONE' : 'THE OTHER ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Plate extends StatelessWidget {
  const _Plate({
    required this.weir,
    required this.then,
    required this.name,
    required this.locked,
    required this.won,
  });

  final Weir weir;
  final double then;
  final String name;
  final bool locked;
  final bool won;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 176,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: locked && won ? AppColors.forest : AppColors.line,
          width: locked && won ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: EngineeringGrid(
          minor: 18,
          major: 90,
          child: CustomPaint(
            painter: WeirPainter(weir: weir, thenHead: then, tag: name),
            child: const SizedBox.expand(),
          ),
        ),
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
