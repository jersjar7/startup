import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'area_figures.dart';

/// Does the Listing Close — the third item for `area-computations`.
///
/// The coordinate method is exact, which makes it dangerous: it returns a
/// tidy number for any list of coordinates you hand it, including lists that
/// are not the parcel. Two things go wrong and neither shows up in the
/// arithmetic. The corners can be listed out of order, which draws a bowtie
/// and quietly hands back the difference of two areas instead of their sum.
/// Or a corner can be left out, which gives the area of a smaller figure
/// that closes perfectly well. Both are obvious the moment the listing is
/// plotted, and invisible if it is not, which is the whole reason to plot it.
class DoesTheListingCloseGame extends StatefulWidget {
  const DoesTheListingCloseGame({super.key});

  @override
  State<DoesTheListingCloseGame> createState() =>
      _DoesTheListingCloseGameState();
}

/// What a listing of corners turns out to be.
enum Listed { boundary, crosses, missing }

extension ListedWords on Listed {
  String get plain => switch (this) {
        Listed.boundary => 'Yes: it walks the boundary',
        Listed.crosses => 'No: the listing crosses itself',
        Listed.missing => 'No: it leaves a corner out',
      };
}

@immutable
class ListingRound {
  const ListingRound({
    required this.subject,
    required this.parcel,
    required this.order,
    required this.why,
    required this.source,
  });

  final String subject;
  final Parcel parcel;

  /// The order the field book lists the corners in.
  final List<int> order;
  final String why;
  final String source;

  String get listing =>
      [for (final i in order) parcel.corners[i].name].join(' to ');

  /// Worked out by walking the listing, never declared.
  Listed get answer {
    if (order.length < parcel.corners.length) return Listed.missing;
    if (!parcel.walksTheBoundary(order)) return Listed.crosses;
    return Listed.boundary;
  }
}

const listingRounds = <ListingRound>[
  ListingRound(
    subject: 'the lesson\'s own quadrilateral',
    parcel: Parcel(corners: [
      Corner2('A', 0, 0),
      Corner2('B', 10, 0),
      Corner2('C', 8, 6),
      Corner2('D', 2, 5),
    ]),
    order: [0, 1, 2, 3],
    why:
        'Yes. A to B to C to D walks right round the outside and comes home, '
        'which is what the formula assumes and never checks. Four corners, '
        'four cross products, and the last one pairs D back to A. This is '
        'the listing the lesson uses to get 44.',
    source: 'surv-ac-q2',
  ),
  ListingRound(
    subject: 'two corners swapped in the field book',
    parcel: Parcel(corners: [
      Corner2('A', 0, 0),
      Corner2('B', 10, 0),
      Corner2('C', 8, 6),
      Corner2('D', 2, 5),
    ]),
    order: [0, 1, 3, 2],
    why:
        'No: it crosses itself. The same four corners in the wrong order '
        'draws a bowtie, and the shoelace formula does not complain. It '
        'returns a number, and the number is the difference between the two '
        'loops rather than the area of anything on the ground. Nothing in '
        'the arithmetic will tell you. Plotting the listing will, in about '
        'two seconds.',
    source: 'surv-ac-q2',
  ),
  ListingRound(
    subject: 'a corner that never got written down',
    parcel: Parcel(corners: [
      Corner2('A', 0, 0),
      Corner2('B', 10, 0),
      Corner2('C', 8, 6),
      Corner2('D', 2, 5),
    ]),
    order: [0, 1, 2],
    why:
        'No: D is missing. Three corners of a four sided lot still make a '
        'perfectly good triangle, so the formula runs, closes, and hands '
        'back an area that is simply too small. A listing that is short one '
        'corner is the easiest of all of these to miss, because the figure '
        'it draws looks entirely reasonable.',
    source: 'surv-ac-q2',
  ),
  ListingRound(
    subject: 'the same lot, walked the other way',
    parcel: Parcel(corners: [
      Corner2('A', 0, 0),
      Corner2('B', 10, 0),
      Corner2('C', 8, 6),
      Corner2('D', 2, 5),
    ]),
    order: [0, 3, 2, 1],
    why:
        'Yes. Walking the boundary backwards is still walking the boundary. '
        'The shoelace sum comes out negative instead of positive, and the '
        'absolute value in the formula exists precisely so that it does not '
        'matter. Clockwise or counterclockwise, same parcel, same area.',
    source: 'surv-ac-q2',
  ),
  ListingRound(
    subject: 'five corners, one pair out of order',
    parcel: Parcel(corners: [
      Corner2('A', 0, 0),
      Corner2('B', 9, 1),
      Corner2('C', 11, 7),
      Corner2('D', 4, 9),
      Corner2('E', -1, 5),
    ]),
    order: [0, 1, 3, 2, 4],
    why:
        'No: it crosses itself. With five corners there are a great many '
        'wrong orders and only one right one in each direction, so the more '
        'corners a parcel has the more worthwhile the plot becomes. The '
        'crossing here is between the C to D side and the one that should '
        'not meet it.',
    source: 'surv-ac-q2',
  ),
  ListingRound(
    subject: 'the five sided parcel, listed properly',
    parcel: Parcel(corners: [
      Corner2('A', 0, 0),
      Corner2('B', 9, 1),
      Corner2('C', 11, 7),
      Corner2('D', 4, 9),
      Corner2('E', -1, 5),
    ]),
    order: [0, 1, 2, 3, 4],
    why:
        'Yes. Five corners, five cross products, E paired back to A at the '
        'end. The coordinate method does not care how irregular a parcel is '
        'or how many sides it has: it cares that the listing goes round the '
        'boundary once and closes.',
    source: 'surv-ac-q2',
  ),
];

class _DoesTheListingCloseGameState extends State<DoesTheListingCloseGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'does-the-listing-close',
    chapterId: 'surveying',
    total: listingRounds.length,
    sourceProblemIdOf: (round) => listingRounds[round].source,
  )..addListener(_onSession);

  Listed? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ListingRound get _round => listingRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Does the Listing Close',
        closing:
            'The formula runs on any list of coordinates and returns a tidy '
            'number, whether or not that list is the parcel. Corners out of '
            'order draw a bowtie and give back the difference of two loops. '
            'A corner left out draws a smaller figure that closes perfectly '
            'well. Neither shows up in the arithmetic, and both show up in a '
            'two second plot.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: shoelaceBrief,
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
            'IS THIS LISTING THE PARCEL',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            'The field book lists the corners ${r.listing}, and back.',
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 230,
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
                  painter: ParcelPainter(
                    parcel: r.parcel,
                    order: r.order,
                    showCoordinates: false,
                    fill: answered && r.answer == Listed.boundary,
                    tone: answered && r.answer != Listed.boundary
                        ? AppColors.error
                        : AppColors.charcoal,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (final option in Listed.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 6),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS IT' : 'LOOK AGAIN',
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
