import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'steel_figures.dart';

/// Which Axis Wins Now — the first item for `steel-columns`.
///
/// That a bare column folds about its weak axis is taught in mechanics of
/// materials and is not repeated here. What belongs to steel design is what
/// happens once the two axes are held differently, which is the usual case
/// in a real frame: a brace shortens the length for ONE axis only, and
/// halving the weak axis length is often enough to hand the column over to
/// the strong one.
class WhichAxisWinsNowGame extends StatefulWidget {
  const WhichAxisWinsNowGame({super.key});

  @override
  State<WhichAxisWinsNowGame> createState() => _WhichAxisWinsNowGameState();
}

@immutable
class AxisRound {
  const AxisRound({
    required this.subject,
    required this.asked,
    required this.post,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Post post;
  final String why;
  final String source;

  /// The column decides, from its own lengths and radii.
  Axis2 get answer => post.decides;

  static String label(Axis2 which) => switch (which) {
        Axis2.strong => 'The deep way, about the strong axis',
        Axis2.weak => 'The shallow way, about the weak axis',
        Axis2.either => 'Neither: the two come out the same',
      };
}

const bothAxisRounds = <AxisRound>[
  AxisRound(
    subject: 'held at the ends only',
    asked:
        'A 24 foot column of a shape whose two radii are 6.0 and 2.5 inches, '
        'with nothing holding it in between either way. Which way does it go?',
    post: Post(height: 24, rx: 6.0, ry: 2.5),
    why:
        'The shallow way. With the same free length either way, the axis with '
        'the smaller radius has the larger slenderness and loses. This is the '
        'ordinary case and the reason a bare column always folds the shallow '
        'way, which is worth having in mind only so that the next rounds can '
        'overturn it.',
    source: 'str-sc-q1',
  ),
  AxisRound(
    subject: 'one brace at midheight',
    asked:
        'The same column and the same shape, but a wall now holds it at '
        'midheight against moving the shallow way. Which way does it go now?',
    post: Post(height: 24, rx: 6.0, ry: 2.5, weakBraces: 2),
    why:
        'Still the shallow way, but only just: 12 feet over 2.5 inches comes '
        'to 58 against the deep way\'s 24 feet over 6.0, which is 48. '
        'Halving the free length divides that slenderness by two, so the deep '
        'way takes over only when its radius is less than TWICE the shallow '
        'one. Here it is 2.4 times, so the shallow way survives the brace. '
        'One brace is not automatically enough.',
    source: 'str-sc-q3',
  ),
  AxisRound(
    subject: 'a shape with a wider flange',
    asked:
        'The same 24 foot height, braced at midheight the shallow way again, '
        'but a stockier shape whose radii are 4.0 and 2.5 inches. Now which?',
    post: Post(height: 24, rx: 4.0, ry: 2.5, weakBraces: 2),
    why:
        'The deep way this time. The only thing that changed is the shape: '
        'its strong radius is 1.6 times the weak one, inside the factor of '
        'two that halving the length is worth, so the same brace that was not '
        'enough on the last shape is enough on this one. Stocky shapes are '
        'the ones chosen as columns, and they flip like this.',
    source: 'str-sc-q3',
  ),
  AxisRound(
    subject: 'a very slender shape',
    asked:
        'Now a shape whose radii are 6.0 and 1.4 inches, still 24 feet, still '
        'braced once at midheight the shallow way. Which way?',
    post: Post(height: 24, rx: 6.0, ry: 1.4, weakBraces: 2),
    why:
        'The shallow way after all. Here the strong radius is more than four '
        'times the weak one, so halving the shallow length is nowhere near '
        'enough to make up the difference. The rule is not that bracing '
        'always flips the column: it is that you work out the slenderness '
        'about each axis with the length that actually applies to it, and the '
        'larger of the two wins.',
    source: 'str-sc-q3',
  ),
  AxisRound(
    subject: 'braced at the third points',
    asked:
        'Back to the 6.0 and 2.5 shape, 24 feet, but now held the shallow way '
        'at both third points. Which way does it go?',
    post: Post(height: 24, rx: 6.0, ry: 2.5, weakBraces: 3),
    why:
        'The deep way at last. Cutting the shallow length into three divides '
        'that slenderness by three, which beats the 2.4 between the radii '
        'where halving it did not. Note what this means: once the deep way '
        'has taken over, a fourth brace the shallow way buys nothing at all, '
        'because the axis deciding the column is the one you are not '
        'touching.',
    source: 'str-sc-q3',
  ),
  AxisRound(
    subject: 'a square tube',
    asked:
        'A square hollow section, whose two radii are both 3.0 inches, held '
        'at its ends only over 20 feet. Which way does it go?',
    post: Post(height: 20, rx: 3.0, ry: 3.0),
    why:
        'Neither: the two come out the same, which is exactly why square '
        'tubes are used for columns that are unbraced in both directions. '
        'There is no weak axis to find. Brace such a column one way and the '
        'other immediately becomes the weak one, which turns the usual '
        'question on its head.',
    source: 'str-sc-q1',
  ),
];

class _WhichAxisWinsNowGameState extends State<WhichAxisWinsNowGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-axis-wins-now',
    chapterId: 'structural',
    total: bothAxisRounds.length,
    sourceProblemIdOf: (round) => bothAxisRounds[round].source,
  )..addListener(_onSession);

  Axis2? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  AxisRound get _round => bothAxisRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Axis Wins Now',
        closing:
            'A brace shortens the free length for the axis it is fitted to '
            'and for no other, so the two directions have to be looked at '
            'separately: each with its own radius and its own length, and the '
            'larger slenderness decides the column. Halving the shallow '
            'length divides its slenderness by two, so the deep way takes '
            'over only when its radius is less than twice the shallow one: '
            'true of the stocky shapes chosen as columns, and not of the deep '
            'ones chosen as beams.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: axisBrief,
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
            'WHICH WAY DOES IT GO',
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
            height: 224,
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
                  painter: AxisPainter(post: r.post, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\text{the larger } KL/r \text{ decides it}$',
              style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Axis2.values) ...[
            _Choice(
              label: AxisRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Axis2.values.last) const SizedBox(height: 8),
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
