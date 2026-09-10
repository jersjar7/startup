import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'section_figures.dart';

/// Which Second Moment — the fourth item for `area-moments-of-inertia`.
///
/// This lesson defines four things and the other three items cover two of
/// them. The polar moment is the one that belongs here rather than anywhere
/// else, because this is the only page in the whole app where I and J sit side
/// by side, and the chapter's own trap list names using one where the other
/// belongs.
///
/// The radius of gyration is deliberately NOT here. Column Buckling has a
/// whole topic on the slenderness ratio and teaches it where it does actual
/// work, and teaching it twice would mean teaching it badly the first time.
///
/// The answer follows from the direction of the load and nothing else, which
/// is the second thing worth taking away: a section bends about the axis
/// SQUARE to the push, never about whichever of its axes is the stronger.
class WhichSecondMomentGame extends StatefulWidget {
  const WhichSecondMomentGame({super.key});

  @override
  State<WhichSecondMomentGame> createState() => _WhichSecondMomentGameState();
}

@immutable
class JobRound {
  const JobRound({
    required this.subject,
    required this.setting,
    required this.profile,
    required this.job,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Profile profile;
  final Job job;
  final String why;
  final String source;

  /// Worked out from the direction of the load, never declared beside the
  /// round.
  Needs get answer => job.needs;
}

/// A joist: deep and narrow.
const _joist = Profile([Piece(Slab.box, Offset.zero, Size(50, 200))]);

/// A stud: the same shape, thought about the other way.
const _stud = Profile([Piece(Slab.box, Offset.zero, Size(40, 140))]);

/// A round shaft.
const _shaft = Profile([Piece(Slab.disc, Offset.zero, Size(120, 120))]);

/// A hollow post.
const _post = Profile([
  Piece(Slab.disc, Offset.zero, Size(140, 140)),
  Piece(Slab.disc, Offset(15, 15), Size(110, 110), hole: true),
]);

/// An I-section stood up the usual way.
const _iBeam = Profile([
  Piece(Slab.box, Offset(0, 0), Size(120, 18)),
  Piece(Slab.box, Offset(51, 18), Size(18, 104)),
  Piece(Slab.box, Offset(0, 122), Size(120, 18)),
]);

/// The same I-section laid on its side.
const _iBeamOnSide = Profile([
  Piece(Slab.box, Offset(0, 0), Size(18, 120)),
  Piece(Slab.box, Offset(18, 51), Size(104, 18)),
  Piece(Slab.box, Offset(122, 0), Size(18, 120)),
]);

const jobRounds = <JobRound>[
  JobRound(
    subject: 'a floor joist under a load',
    setting:
        'A timber joist carrying the floor above it. The load comes straight '
        'down onto it.',
    profile: _joist,
    job: Job(load: Offset(0, -1)),
    why:
        'I about the horizontal axis. A downward load bends the joist in a '
        'vertical plane, and it bends about the axis square to that push, '
        'which is the horizontal one. That is also the axis this deep narrow '
        'shape is strongest about, which is the entire reason a joist is '
        'stood on edge.',
    source: 'stat-ami-q1',
  ),
  JobRound(
    subject: 'a wall stud in a gale',
    setting:
        'A stud in an outside wall. The wind presses on the wall face, so the '
        'load comes at it sideways.',
    profile: _stud,
    job: Job(load: Offset(1, 0)),
    why:
        'I about the VERTICAL axis. Same kind of member, load turned ninety '
        'degrees, so the bending turns with it and the section resists about '
        'its other axis, the weaker one. Which axis matters is set by the '
        'load, never by which way round the member happens to be drawn.',
    source: 'stat-ami-q1',
  ),
  JobRound(
    subject: 'a shaft carrying a torque',
    setting:
        'A round drive shaft. Nothing pushes it sideways at all; it is being '
        'twisted about its own length.',
    profile: _shaft,
    job: Job(load: Offset.zero, twists: true),
    why:
        'The polar moment J. Twisting is not bending, and it needs J, which '
        'is I about x plus I about y, both taken about the same point. Using I '
        'where J belongs is on the chapter trap list, and for a round shaft it '
        'costs you exactly a factor of two, because J is twice I there.',
    source: 'stat-ami-q1',
  ),
  JobRound(
    subject: 'wind on a road sign',
    setting:
        'A hollow post with a large sign bolted to one side of it. The wind '
        'pushes the sign, and because the sign is off to one side the post '
        'gets wrung about its own length.',
    profile: _post,
    job: Job(load: Offset.zero, twists: true),
    why:
        'J again. The wind is a horizontal push, but it arrives off to one '
        'side of the post, so what reaches the post is a twist. What decides '
        'this is not what the load looks like but what it does to the member, '
        'and a sign on a single post twists it every time.',
    source: 'stat-ami-q1',
  ),
  JobRound(
    subject: 'a beam laid on its side',
    setting:
        'An I-beam turned over so its flanges stand up rather than lying flat. '
        'The load is still straight down.',
    profile: _iBeamOnSide,
    job: Job(load: Offset(0, -1)),
    why:
        'Still I about the horizontal axis. This is the round worth the '
        'trouble: the load did not move, so the axis did not move, even though '
        'the section is now far weaker about it. The axis you need and the '
        'axis you would prefer are two separate questions, and only the first '
        'one is being asked.',
    source: 'stat-ami-q1',
  ),
  JobRound(
    subject: 'a beam shoved mostly sideways',
    setting:
        'An I-beam standing the usual way up, with a load coming in at a '
        'shallow angle: mostly sideways, a little downward.',
    profile: _iBeam,
    job: Job(load: Offset(1, -0.36)),
    why:
        'I about the vertical axis. Split the load into its two directions and '
        'the sideways part is the larger, so that is the bending that governs. '
        'A real member takes both at once and you would check each, but the '
        'one that will hurt this beam is the one about its weak axis.',
    source: 'stat-ami-q1',
  ),
];

class _WhichSecondMomentGameState extends State<WhichSecondMomentGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-second-moment',
    chapterId: 'statics',
    total: jobRounds.length,
    sourceProblemIdOf: (round) => jobRounds[round].source,
  )..addListener(_onSession);

  Needs? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  JobRound get _round => jobRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Second Moment',
        closing:
            'Bending needs I, and it is I about the axis SQUARE to the load, '
            'whichever way round the member is drawn. Twisting needs J, which '
            'is the two I values added about the same point. Reaching for one '
            'where the other belongs is on the trap list for this whole '
            'chapter, and it is decided before any number is looked up.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: polarBrief,
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
            'WHICH ONE DOES THIS JOB NEED',
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
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 250,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: JobPainter(
                    profile: r.profile,
                    job: r.job,
                    showAxis: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Needs.values) ...[
            _NeedsButton(
              key: ValueKey('needs-${option.name}'),
              option: option,
              selected: _picked == option,
              locked: answered,
              isTruth: option == r.answer,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Needs.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'A DIFFERENT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _NeedsButton extends StatelessWidget {
  const _NeedsButton({
    super.key,
    required this.option,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Needs option;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  static const _titles = {
    Needs.iAboutX: 'I about the horizontal axis',
    Needs.iAboutY: 'I about the vertical axis',
    Needs.polarJ: 'The polar moment J',
  };

  static const _notes = {
    Needs.iAboutX: 'bending from a load pushing up or down',
    Needs.iAboutY: 'bending from a load pushing sideways',
    Needs.polarJ: 'twisting about the member, and J is the two I added',
  };

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color fill;
    final Color ink;
    if (locked && isTruth) {
      border = AppColors.forest;
      fill = AppColors.forestBg;
      ink = AppColors.forest;
    } else if (locked && selected) {
      border = AppColors.error;
      fill = AppColors.errorBg;
      ink = AppColors.error;
    } else if (selected) {
      border = AppColors.ember;
      fill = AppColors.emberBg;
      ink = AppColors.ember;
    } else {
      border = AppColors.line;
      fill = AppColors.white;
      ink = AppColors.charcoal;
    }

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 38,
                height: 34,
                child: CustomPaint(painter: _NeedsGlyph(option, ink)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _titles[option]!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _notes[option]!,
                      style: AppTheme.mono(size: 10.5, color: AppColors.ink3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A little section with the axis this answer means marked on it.
class _NeedsGlyph extends CustomPainter {
  const _NeedsGlyph(this.option, this.colour);

  final Needs option;
  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final box = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.52,
      height: size.height * 0.66,
    );
    canvas.drawRect(box, Paint()..color = AppColors.sunbeamBg);
    canvas.drawRect(
      box,
      Paint()
        ..color = AppColors.ink2
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    final ink = Paint()
      ..color = colour
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final c = box.center;
    switch (option) {
      case Needs.iAboutX:
        canvas.drawLine(Offset(2, c.dy), Offset(size.width - 2, c.dy), ink);
      case Needs.iAboutY:
        canvas.drawLine(Offset(c.dx, 2), Offset(c.dx, size.height - 2), ink);
      case Needs.polarJ:
        canvas.drawCircle(
          c,
          6,
          Paint()
            ..color = colour
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        canvas.drawCircle(c, 2.2, Paint()..color = colour);
    }
  }

  @override
  bool shouldRepaint(_NeedsGlyph old) =>
      old.option != option || old.colour != colour;
}
