import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'weir_figures.dart';

/// Which Formula Fits This Weir — the first item for `pipe-systems-weirs`.
///
/// Three weir formulas sit next to each other on the handbook page and the
/// only thing that picks between them is the shape of the hole in the plate.
/// A full width crest takes the plain three halves formula. A crest that
/// stops short of the walls loses a tenth of the head off each end. A V
/// takes five halves, because a V gets wider as the water rises and a
/// rectangle does not. Both of the lesson's weir problems name the wrong
/// exponent as their trap.
class WhichFormulaFitsThisWeirGame extends StatefulWidget {
  const WhichFormulaFitsThisWeirGame({super.key});

  @override
  State<WhichFormulaFitsThisWeirGame> createState() =>
      _WhichFormulaFitsThisWeirGameState();
}

/// Which of the three weir formulas the drawing calls for.
enum Rule3 { plain, trimmed, fiveHalves }

extension Rule3Words on Rule3 {
  String get latex => switch (this) {
        Rule3.plain => r'$Q = C\,L\,H^{3/2}$',
        Rule3.trimmed => r'$Q = C\,(L - 0.2H)\,H^{3/2}$',
        Rule3.fiveHalves => r'$Q = C\,H^{5/2}$',
      };
}

@immutable
class WeirRound {
  const WeirRound({
    required this.subject,
    required this.weir,
    required this.why,
    required this.source,
  });

  final String subject;
  final Weir weir;
  final String why;
  final String source;

  /// Read off the shape of the opening, which is the only thing that
  /// decides it.
  Rule3 get answer => switch (weir.notch) {
        Notch.fullWidth => Rule3.plain,
        Notch.contracted => Rule3.trimmed,
        Notch.vee => Rule3.fiveHalves,
      };
}

const weirRounds = <WeirRound>[
  WeirRound(
    subject: 'the lesson\'s own weir',
    weir: Weir(notch: Notch.fullWidth, head: 1.5, crest: 5, channel: 5),
    why:
        'The plain three halves formula. The crest runs the full width of '
        'the channel, so the water has no ends to curl around and nothing is '
        'taken off the length. That is what suppressed means: the end '
        'contractions are suppressed by the walls. Five feet of crest at a '
        'foot and a half of head passes 30.6 cubic feet a second.',
    source: 'wr-psw-q1',
  ),
  WeirRound(
    subject: 'a notch cut in a plate',
    weir: Weir(notch: Notch.vee, head: 2, channel: 6),
    why:
        'Five halves, and there is no L in it at all. A V has no crest to '
        'measure: the opening is a point at the bottom and it widens as the '
        'water rises, so the head is doing two jobs at once and the exponent '
        'picks up an extra half. This is the lesson\'s own second problem, '
        'and using the rectangular three halves here is the trap it names.',
    source: 'wr-psw-q2',
  ),
  WeirRound(
    subject: 'a crest that stops short of the walls',
    weir: Weir(notch: Notch.contracted, head: 1, crest: 4, channel: 8),
    why:
        'The trimmed formula. The opening does not reach the walls, so the '
        'water curls in around each end and the nappe is narrower than the '
        'crest it poured over. The correction takes a TENTH of the head off '
        'each end, two tenths in total, which at a foot of head is about two '
        'and a half percent of a four foot crest. Small, but the exam expects '
        'you to notice which weir you are looking at.',
    source: 'wr-psw-q1',
  ),
  WeirRound(
    subject: 'a small notch on a stream gauge',
    weir: Weir(notch: Notch.vee, head: 0.8, channel: 5),
    why:
        'Five halves again. V-notches are what get installed where the flow '
        'is small and needs measuring accurately, because at low heads a V '
        'gives a much bigger change in level for a given change in flow than '
        'a wide rectangular crest does. The narrow opening is the feature, '
        'not a limitation.',
    source: 'wr-psw-q2',
  ),
  WeirRound(
    subject: 'a wide low crest at a treatment plant',
    weir: Weir(notch: Notch.fullWidth, head: 0.6, crest: 6, channel: 6),
    why:
        'The plain formula. Wall to wall again, so no correction. The head '
        'here is small and the crest long, which is the usual arrangement at '
        'a plant: the weir has to pass the whole works flow without backing '
        'the water up, and a long crest does that at a few inches of head.',
    source: 'wr-psw-q1',
  ),
  WeirRound(
    subject: 'a short crest in a wide channel',
    weir: Weir(notch: Notch.contracted, head: 1.4, crest: 3, channel: 9),
    why:
        'Trimmed, and here it matters. The head is 1.4 feet against a crest '
        'of only 3, so the correction takes 0.28 off it, nearly a tenth of '
        'the whole length. The shorter the crest and the higher the head, the '
        'more the end contractions take, which is why the correction exists '
        'at all rather than being rounded away.',
    source: 'wr-psw-q1',
  ),
];

class _WhichFormulaFitsThisWeirGameState
    extends State<WhichFormulaFitsThisWeirGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-formula-fits-this-weir',
    chapterId: 'water-resources',
    total: weirRounds.length,
    sourceProblemIdOf: (round) => weirRounds[round].source,
  )..addListener(_onSession);

  Rule3? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  WeirRound get _round => weirRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Formula Fits This Weir',
        closing:
            'The shape of the opening picks the formula. A crest running '
            'wall to wall takes C L H to the three halves. A crest that stops '
            'short loses a tenth of the head off each end first. A V has no '
            'crest length at all and takes C H to the five halves, because '
            'the opening widens as the water rises. The coefficients differ '
            'too, and they differ again between feet and meters.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: weirBrief,
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
            'WHICH FORMULA MEASURES THIS ONE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          const Text(
            'You are looking at the weir plate from upstream, with the water '
            'standing behind it.',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 232,
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
                  painter: WeirPainter(weir: r.weir, showFlow: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Rule3.values) ...[
            _Choice(
              latex: option.latex,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Rule3.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'A DIFFERENT SHAPE',
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
    required this.latex,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String latex;
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: MathText(
            latex,
            style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
