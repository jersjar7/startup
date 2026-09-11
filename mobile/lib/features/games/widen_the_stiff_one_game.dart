import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'composite_figures.dart';
import 'lesson_brief.dart';

/// Widen the Stiff One — the first item for `transformed-sections-plastic`.
///
/// Two materials bonded together bend as one thing, and the way through is to
/// rewrite the section as though it were all made of the softer one: the
/// stiffer material gets WIDER by the modular ratio, because it takes that
/// much more of the soft stuff to do the same job. Which way round that goes
/// is the whole of the method and the lesson's first named trap.
///
/// Nothing is computed. Three transformed sections are drawn and the answer is
/// which one belongs to the beam above it.
class WidenTheStiffOneGame extends StatefulWidget {
  const WidenTheStiffOneGame({super.key});

  @override
  State<WidenTheStiffOneGame> createState() => _WidenTheStiffOneGameState();
}

/// What was done to a candidate drawing.
enum Done {
  /// The stiffer material widened by n, which is the method.
  widenStiff,

  /// The softer one widened instead, which is the ratio upside down.
  widenSoft,

  /// The stiffer one made narrower by n, which is dividing where you should
  /// multiply.
  narrowStiff,

  /// The stiffer material made DEEPER rather than wider, which moves material
  /// away from the axis and is a different beam entirely.
  deepenStiff,
}

@immutable
class TransformRound {
  const TransformRound({
    required this.subject,
    required this.setting,
    required this.beam,
    required this.options,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Composite beam;

  /// The three drawings on offer, in the order they appear.
  final List<Done> options;

  final String why;
  final String source;

  int get answer => options.indexOf(Done.widenStiff);

  /// How deep the wrong-way-round candidate draws the stiff material. The
  /// real transform would make it n times deeper, which on a steel plate in
  /// timber is seventeen times and swamps the row. The point of the drawing
  /// is the DIRECTION, so it is shown modestly and the feedback says why the
  /// direction is wrong at any size.
  static const _deepenBy = 2.5;

  /// What a candidate drawing actually is, worked out from the beam rather
  /// than written down beside it.
  List<Slice> drawingFor(Done done) {
    switch (done) {
      case Done.widenStiff:
      case Done.widenSoft:
      case Done.narrowStiff:
        return [
          for (final s in beam.slices)
            Slice(
              Offset(
                s.at.dx + s.size.width / 2 - _widthOf(s, done) / 2,
                s.at.dy,
              ),
              Size(_widthOf(s, done), s.size.height),
              s.made,
            ),
        ];
      case Done.deepenStiff:
        final grown = <Slice>[];
        var lift = 0.0;
        for (final s in beam.slices) {
          final deeper = s.made == beam.stiffer;
          final h = deeper ? s.size.height * _deepenBy : s.size.height;
          grown.add(Slice(
            Offset(s.at.dx, s.at.dy + lift),
            Size(s.size.width, h),
            s.made,
          ));
          if (deeper) lift += h - s.size.height;
        }
        return grown;
    }
  }

  double _widthOf(Slice s, Done done) => switch (done) {
        Done.widenStiff =>
          s.made == beam.stiffer ? s.size.width * beam.n : s.size.width,
        Done.widenSoft =>
          s.made == beam.softer ? s.size.width * beam.n : s.size.width,
        Done.narrowStiff =>
          s.made == beam.stiffer ? s.size.width / beam.n : s.size.width,
        Done.deepenStiff => s.size.width,
      };
}

/// A concrete beam with a steel plate bolted underneath, the classic
/// transformed section. Steel is eight times concrete, and the plate is
/// narrow, so the transformed drawing stays a shape rather than a smear.
const _plated = Composite([
  Slice(Offset(45, 0), Size(90, 12), Made.steel),
  Slice(Offset(0, 12), Size(180, 270), Made.concrete),
]);

/// The same pairing with the plate on the top face instead.
const _sandwich = Composite([
  Slice(Offset(0, 0), Size(170, 240), Made.concrete),
  Slice(Offset(50, 240), Size(70, 14), Made.steel),
]);

/// Aluminum on timber, where the ratio is smaller and the drawings sit closer
/// together.
const _clad = Composite([
  Slice(Offset(0, 0), Size(150, 240), Made.timber),
  Slice(Offset(40, 240), Size(70, 12), Made.aluminum),
]);

final transformRounds = <TransformRound>[
  TransformRound(
    subject: 'a concrete beam with a steel plate under it',
    setting:
        'Steel is about eight times stiffer than concrete. Which drawing is '
        'this beam written as though it were all concrete?',
    beam: _plated,
    options: [Done.widenStiff, Done.widenSoft, Done.narrowStiff],
    why:
        'The first, with the steel plate stretched out wide. It takes eight '
        'times as much concrete to be as stiff as that plate, so that is how '
        'much concrete it is replaced by. The second widens the concrete, '
        'which is the ratio upside down, and the third makes the steel '
        'narrower, which is dividing where the method multiplies. Both leave '
'you with a beam that is nothing like the real one.',
    source: 'mom-tsp-q1',
  ),
  TransformRound(
    subject: 'a concrete beam with a steel plate on top',
    setting:
        'The same two materials with the plate on the top face instead. Still '
        'being written as though it were all concrete.',
    beam: _sandwich,
    options: [Done.narrowStiff, Done.widenStiff, Done.widenSoft],
    why:
        'The second. Same rule and the plate is on the other face this time, '
        'which changes nothing about which material gets widened: it is always '
        'the STIFFER one, wherever it sits. Eight is the ratio the lesson\'s '
        'own first problem works out, twenty nine thousand over three '
        'thousand six hundred and twenty five.',
    source: 'mom-tsp-q1',
  ),
  TransformRound(
    subject: 'a timber beam with an aluminum cap',
    setting:
        'Aluminum is about six times stiffer than timber, so the ratio is '
        'smaller and the three drawings sit closer together.',
    beam: _clad,
    options: [Done.widenSoft, Done.widenStiff, Done.narrowStiff],
    why:
        'The second again. A smaller modular ratio makes the transformed '
        'section look more like the real one, and the method has not changed '
        'at all. The cap is narrow to start with, and widening it says '
        'something worth hearing: this thin strip does the work of six times '
        'its width in timber.',
    source: 'mom-tsp-q1',
  ),
  TransformRound(
    subject: 'the same plated beam, with a fourth drawing on offer',
    setting:
        'One of these keeps every width and makes the steel DEEPER instead.',
    beam: _plated,
    options: [Done.deepenStiff, Done.widenStiff, Done.widenSoft],
    why:
        'The second. Deepening the steel would move material further from the '
        'neutral axis, and how far material sits from the axis is the one '
        'thing a transformed section must not change: that distance is what '
        'bending is about. Widening leaves every fiber where it was and only '
        'says how much soft material would be needed there instead.',
    source: 'mom-tsp-q1',
  ),
  TransformRound(
    subject: 'the concrete beam again',
    setting:
        'Two of these three drawings would give you a section stiffer than '
        'the real beam and one would give you a softer one.',
    beam: _sandwich,
    options: [Done.widenSoft, Done.narrowStiff, Done.widenStiff],
    why:
        'The third. Read the drawings against the real beam: widening the '
        'concrete adds material that is not there, narrowing the steel throws '
        'away material that is. Only the third replaces the steel with the '
        'amount of concrete that would do the same work, which is what '
        'transforming means.',
    source: 'mom-tsp-q3',
  ),
  TransformRound(
    subject: 'the timber and aluminum beam once more',
    setting: 'Last one. The rule has not moved.',
    beam: _clad,
    options: [Done.narrowStiff, Done.widenSoft, Done.widenStiff],
    why:
        'The third. Once the section is transformed, everything from the '
        'bending lesson works on it unchanged: find the centroid, find I, use '
        'M y over I. The one thing left to remember is that the stress it '
        'gives you is the stress in the SOFT material, and the stiff material '
        'carries n times that at the same height.',
    source: 'mom-tsp-q3',
  ),
];

class _WidenTheStiffOneGameState extends State<WidenTheStiffOneGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'widen-the-stiff-one',
    chapterId: 'mechanics-materials',
    total: transformRounds.length,
    sourceProblemIdOf: (round) => transformRounds[round].source,
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

  TransformRound get _round => transformRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Widen the Stiff One',
        closing:
            'Write the section as though it were all the softer material: the '
            'stiffer one gets n times wider, where n is the stiffer modulus '
            'over the softer. Never deeper, never narrower, and never the '
            'other material. Then it is an ordinary bending problem again.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: transformBrief,
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
            'TAP THE TRANSFORMED SECTION',
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
          EngineeringGrid(
            minor: 16,
            major: 80,
            child: SizedBox(
              height: 132,
              child: CustomPaint(
                painter: MadePainter(slices: r.beam.slices, label: 'the beam'),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _Key(made: r.beam.stiffer),
              const SizedBox(width: 14),
              _Key(made: r.beam.softer),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < r.options.length; i++) ...[
            _Panel(
              slices: r.drawingFor(r.options[i]),
              selected: _picked == i,
              locked: answered,
              isTruth: i == r.answer,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            'each drawn to fit its own box: read which material got wider',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct!
                  ? 'THAT IS THE TRANSFORM'
                  : 'A DIFFERENT BEAM',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.made});

  final Made made;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: made.tone.withValues(alpha: 0.35),
              border: Border.all(color: AppColors.charcoal, width: 1.2),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Text(made.plain,
              style: AppTheme.mono(size: 11, color: AppColors.ink3)),
        ],
      );
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.slices,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final List<Slice> slices;
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
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 118,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: EngineeringGrid(
              minor: 14,
              major: 70,
              child: CustomPaint(
                painter: MadePainter(slices: slices),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
