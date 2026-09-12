import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'alignment_figures.dart';
import 'lesson_brief.dart';

/// Sharper or Flatter — the item that turns a degree of curve into a
/// radius, and a radius into the distance out to the corner.
///
/// The surveying chapter asks which of six lengths is which, and which of
/// two curves is sharper. This lesson's own problems ask for the two
/// conversions a designer actually does, with the half-angle trap the
/// handbook page warns about.
class SharperOrFlatterGame extends StatefulWidget {
  const SharperOrFlatterGame({super.key});

  @override
  State<SharperOrFlatterGame> createState() => _SharperOrFlatterGameState();
}

@immutable
class CurveQuoteRound {
  const CurveQuoteRound({
    required this.subject,
    required this.asked,
    required this.bend,
    this.piece,
    this.note,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Bend2 bend;

  /// The piece of the curve this round is about, when it has one.
  final Bit? piece;

  /// A line written on the drawing.
  final String? note;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own curve: six degrees of curve, which is a radius of just
/// under 955 feet.
const _sixDegrees = Bend2(radius: 954.93, turn: 40);

/// A gentler one, two degrees.
const _twoDegrees = Bend2(radius: 2864.79, turn: 40);

/// And the tangent problem's curve: 1,200 ft radius through 30 degrees.
const _twelveHundred = Bend2(radius: 1200, turn: 30);

const curveQuoteRounds = <CurveQuoteRound>[
  CurveQuoteRound(
    subject: 'from the degree to the radius',
    asked:
        'The plans give a degree of curve of six. What radius is that?',
    bend: _sixDegrees,
    piece: Bit.radius,
    note: 'D = 6',
    options: [
      '5,730 ft, which is the constant itself',
      'About 955 ft: the constant divided by six',
      'About 34,400 ft: the constant times six',
      'About 478 ft',
    ],
    answer: 1,
    why:
        'About 955 feet. The constant, 5,729.58, is the radius whose hundred '
        'foot arc turns through exactly one degree, so dividing it by the '
        'degree of curve gives the radius. Multiplying instead gives 34,400, '
        'which the lesson prints, and which is a curve you would notice on '
        'the ground.',
    source: 'trans-hc-q1',
  ),
  CurveQuoteRound(
    subject: 'which way the two run',
    asked:
        'This curve has a degree of two rather than six. Is it sharper or '
        'gentler?',
    bend: _twoDegrees,
    piece: Bit.radius,
    note: 'D = 2',
    options: [
      'Sharper: a smaller degree is a tighter curve',
      'Gentler: a smaller degree means a bigger radius',
      'The same: the degree does not set the sharpness',
      'It depends on the turn angle',
    ],
    answer: 1,
    why:
        'Gentler, and its radius is three times the other one at about 2,865 '
        'feet. The two numbers run opposite ways because their product is '
        'fixed, so a big degree is a sharp curve and a big radius is a flat '
        'one. Fixing that direction once saves reading the answer backwards '
        'later.',
    source: 'trans-hc-q1',
  ),
  CurveQuoteRound(
    subject: 'a sanity check on the answer',
    asked:
        'A calculation gives a radius of 34,400 ft for a six degree curve. '
        'Why is that wrong on its face?',
    bend: _sixDegrees,
    piece: Bit.radius,
    note: 'D = 6',
    options: [
      'Because it is not a round number',
      'Because six and a half miles of radius is not a highway curve, it is '
          'almost a straight line',
      'Because the degree of curve cannot be six',
      'It is not wrong',
    ],
    answer: 1,
    why:
        'Because it is six and a half miles of radius. A six degree curve is '
        'a normal rural highway curve of a few hundred feet, and a curve of '
        'thirty four thousand feet would be indistinguishable from a '
        'straight. Knowing what a real curve measures catches this kind of '
        'slip without redoing the sum.',
    source: 'trans-hc-q1',
  ),
  CurveQuoteRound(
    subject: 'out to the corner',
    asked:
        'This curve has a radius of 1,200 ft and turns through 30 degrees. '
        'How far is it from the start of the curve out to the corner?',
    bend: _twelveHundred,
    piece: Bit.tangent,
    note: 'R = 1,200, I = 30',
    options: [
      'About 693 ft',
      'About 322 ft: the radius times the tangent of HALF the turn',
      'About 628 ft',
      'About 161 ft',
    ],
    answer: 1,
    why:
        'About 322 feet. The tangent distance uses half the turn angle, '
        'because the curve is symmetrical about the corner and each side '
        'subtends half of it. Using the whole thirty degrees gives 693, '
        'which the lesson prints and which the handbook page warns about in '
        'as many words.',
    source: 'trans-hc-q2',
  ),
  CurveQuoteRound(
    subject: 'why the angle is halved',
    asked:
        'The formula uses the tangent of half the turn. Where does the half '
        'come from?',
    bend: _twelveHundred,
    piece: Bit.tangent,
    note: 'I = 30, so I/2 = 15',
    options: [
      'It is a factor of safety',
      'The curve is symmetrical about the corner, so each tangent sees half '
          'the total turn',
      'It converts degrees to radians',
      'It allows for superelevation',
    ],
    answer: 1,
    why:
        'Symmetry. The corner sits on the bisector of the turn, so the right '
        'triangle you actually solve has half the angle in it. Read that '
        'once and the half stops being something to memorize and starts '
        'being something you could re-derive on the spot.',
    source: 'trans-hc-q2',
  ),
  CurveQuoteRound(
    subject: 'the piece the road actually follows',
    asked:
        'On the same curve, what is the 628 ft on the list of choices?',
    bend: _twelveHundred,
    piece: Bit.arc,
    note: 'R = 1,200, I = 30',
    options: [
      'Nothing: it is a made up number',
      'The length of the curve itself, the arc the road follows',
      'The long chord',
      'Twice the tangent distance',
    ],
    answer: 1,
    why:
        'The curve length, which is the arc from the start of the curve to '
        'its end. It is the distance the road covers and the one the '
        'stationing runs along, and it is a plausible looking wrong answer to '
        'a tangent question precisely because it belongs to the same curve.',
    source: 'trans-hc-q2',
  ),
];

class _SharperOrFlatterGameState extends State<SharperOrFlatterGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'sharper-or-flatter',
    chapterId: 'transportation',
    total: curveQuoteRounds.length,
    sourceProblemIdOf: (round) => curveQuoteRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  CurveQuoteRound get _round => curveQuoteRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Sharper or Flatter',
        closing:
            'The constant over the degree of curve is the radius, so a big '
            'degree is a sharp curve and a big radius is a flat one. The '
            'distance out to the corner is the radius times the tangent of '
            'HALF the turn, because the curve is symmetrical about that '
            'corner. Use the whole angle and the answer roughly doubles.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: curveConversionBrief,
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
            'RADIUS, DEGREE, TANGENT',
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
                  painter: AlignPainter(
                    bend: r.bend,
                    answer: r.piece,
                    locked: answered,
                    label: r.note,
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
