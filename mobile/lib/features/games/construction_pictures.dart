// The pictures on the Construction Engineering concept sheets.
//
// A sheet is read picture first (owner's call, 2026-09-30): the drawing the
// student just played with, with one thing happening in it, then the idea in
// short steps, then the rule. Built from the same painters the games draw
// with; see mechanics_pictures.dart for the pattern and the shared
// ConceptPicture and ConceptPair tiles.
//
// Every painter in this chapter writes its own captions along the bottom
// edge of the panel, so the drawings are stacked at full width rather than
// paired side by side: at half width those captions clip.

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'cpm_figures.dart';
import 'delivery_figures.dart';
import 'earned_value_figures.dart';
import 'mechanics_pictures.dart' show ConceptPicture;
import 'safety_figures.dart' show Trench, TrenchPainter;

// ---------------------------------------------------------------------------
// The networks, matching the ones the games hand out.

/// A branch and a merge: the shape the forward pass is taught on.
const _fourTask = Network(
  tasks: [
    Task(name: 'A', days: 4),
    Task(name: 'B', days: 6, after: ['A']),
    Task(name: 'C', days: 3, after: ['A']),
    Task(name: 'D', days: 2, after: ['B', 'C']),
  ],
);

/// The same network with the short branch lengthened until it governs, so
/// the longest route moves from B to C without the drawing changing shape.
const _flipped = Network(
  tasks: [
    Task(name: 'A', days: 4),
    Task(name: 'B', days: 6, after: ['A']),
    Task(name: 'C', days: 9, after: ['A']),
    Task(name: 'D', days: 2, after: ['B', 'C']),
  ],
);

/// The five activity network the passes, float and critical path items all
/// use. C carries five days of total float; A, B and D carry none.
const _fiveTask = Network(
  tasks: [
    Task(name: 'A', days: 3),
    Task(name: 'B', days: 4, after: ['A']),
    Task(name: 'C', days: 2, after: ['A']),
    Task(name: 'D', days: 6, after: ['B']),
    Task(name: 'E', days: 3, after: ['B', 'C']),
  ],
);

/// Three routes from one start: fifteen days through B and D, twelve through
/// C and D, ten through C and E.
const _threePaths = Network(
  tasks: [
    Task(name: 'A', days: 4),
    Task(name: 'B', days: 6, after: ['A']),
    Task(name: 'C', days: 3, after: ['A']),
    Task(name: 'D', days: 5, after: ['B', 'C']),
    Task(name: 'E', days: 3, after: ['C']),
  ],
);

// ---------------------------------------------------------------------------
// Scheduling

Widget forwardPassPicture() => const ConceptPicture(
  painter: NetworkPainter(
    network: _fourTask,
    showLate: false,
    markCritical: false,
    answered: true,
  ),
  caption:
      'four jobs and what waits on what. D waits on B and C, so it starts '
      'the day the later of the two finishes',
  height: 230,
);

Widget projectDurationPicture() => const Column(
  children: [
    ConceptPicture(
      painter: NetworkPainter(
        network: _fourTask,
        showLate: false,
        answered: true,
      ),
      caption: 'the long way round is A, B, D: twelve days',
      height: 215,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: NetworkPainter(
        network: _flipped,
        showLate: false,
        answered: true,
      ),
      caption:
          'the same drawing with C stretched to nine days. now C is the long '
          'way round, and the job takes fifteen',
      height: 215,
    ),
  ],
);

Widget passesPicture() => const Column(
  children: [
    ConceptPicture(
      painter: NetworkPainter(
        network: _fiveTask,
        showLate: false,
        markCritical: false,
        answered: true,
      ),
      caption: 'going forward: the earliest each job can happen, in blue',
      height: 215,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: NetworkPainter(
        network: _fiveTask,
        showEarly: false,
        markCritical: false,
        answered: true,
      ),
      caption:
          'coming back: the latest it can happen without the job finishing '
          'late, in green',
      height: 215,
    ),
  ],
);

// Early and late numbers are drawn in separate panels rather than together:
// the painter stacks both inside a 34pt box, where they overlap.
Widget floatPicture() => const Column(
  children: [
    ConceptPicture(
      painter: NetworkPainter(
        network: _fiveTask,
        highlight: 'C',
        showLate: false,
        markCritical: false,
        answered: true,
      ),
      caption: 'C at its earliest: day 3 to day 5',
      height: 200,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: NetworkPainter(
        network: _fiveTask,
        highlight: 'C',
        showEarly: false,
        markCritical: false,
        answered: true,
      ),
      caption:
          'C at its latest: day 8 to day 10, and the job still finishes on '
          'time. those five days are its room to slip',
      height: 200,
    ),
  ],
);

Widget criticalPathPicture() => const ConceptPicture(
  painter: NetworkPainter(
    network: _threePaths,
    showLate: false,
    answered: true,
  ),
  caption:
      'three ways through. the marked one is the longest, and it is the one '
      'with no room anywhere along it',
  height: 235,
);

// ---------------------------------------------------------------------------
// Earned value

/// Week ten of a job: 500k was planned by now, 420k of work is done, and
/// 480k has gone out of the door.
const _weekTen = Progress(planned: 500000, earned: 420000, actual: 480000);

/// The same job with a budget, running at eighty cents on the dollar.
const _overspending = Progress(
  planned: 700000,
  earned: 600000,
  actual: 750000,
  budget: 2000000,
);

Widget earnedValuePicture() => const ConceptPicture(
  painter: ValuePainter(progress: _weekTen, answered: true),
  caption:
      'one date, three bars: what was planned, what got done, what was '
      'spent. both gaps are measured from the middle bar',
  height: 215,
);

Widget forecastPicture() => const ConceptPicture(
  painter: ForecastPainter(progress: _overspending, answered: true),
  caption:
      'the whole budget as one bar, with what has been spent and what that '
      'money bought. the forecast runs past the end of it',
  height: 215,
);

// ---------------------------------------------------------------------------
// Safety

Widget excavationPicture() => const Column(
  children: [
    ConceptPicture(
      painter: TrenchPainter(trench: Trench(depth: 4), answered: true),
      caption: 'four feet down: the rule has not started yet',
      height: 185,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: TrenchPainter(
        trench: Trench(depth: 7, protected: true),
        answered: true,
      ),
      caption: 'seven feet down, with the sides shored: the rule is met',
      height: 185,
    ),
  ],
);

// Both workers in one drawing. The game's own height painter draws one
// worker per panel and writes a sentence that runs under its view tag at
// sheet width, and the whole idea here is the pair either side of the line.
Widget fallProtectionPicture() => const ConceptPicture(
  painter: _TriggerPainter(),
  caption:
      'two workers and the six foot line. one is under it, one is over it, '
      'and only one of them needs anything',
  height: 215,
);

// ---------------------------------------------------------------------------
// Delivery

Widget deliveryFitPicture() => const Column(
  children: [
    ConceptPicture(
      painter: ScheduleShapePainter(
        method: Deliver.designBidBuild,
        answered: true,
      ),
      caption: 'drawing finishes, then bidding, then building. nothing shares',
      height: 165,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: ScheduleShapePainter(
        method: Deliver.designBuild,
        answered: true,
      ),
      caption: 'one firm does both, so building starts on a part drawn job',
      height: 165,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: ScheduleShapePainter(
        method: Deliver.managerAtRisk,
        answered: true,
      ),
      caption: 'the builder joins during drawing and names a ceiling price',
      height: 165,
    ),
  ],
);

// ---------------------------------------------------------------------------
// The one painter that exists only for a sheet

TextPainter _text(String s, {double size = 10, Color color = AppColors.ink2}) {
  return TextPainter(
    text: TextSpan(
      text: s,
      style: AppTheme.mono(size: size, color: color),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
}

/// Two workers on platforms either side of the six foot line.
class _TriggerPainter extends CustomPainter {
  const _TriggerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final ground = size.height - 34;
    final top = 42.0;
    const tallest = 10.0; // feet drawn to the top of the panel
    double yOf(double feet) => ground - feet / tallest * (ground - top);

    canvas.drawLine(
      Offset(14, ground),
      Offset(size.width - 14, ground),
      Paint()
        ..color = AppColors.charcoal
        ..strokeWidth = 2,
    );

    // The line the rule turns on, ruled the whole way across.
    final trigger = yOf(6);
    final dash = Paint()
      ..color = AppColors.error
      ..strokeWidth = 1.4;
    for (var x = 14.0; x < size.width - 14; x += 10) {
      canvas.drawLine(Offset(x, trigger), Offset(x + 5, trigger), dash);
    }
    final rule = _text('6 ft, where protection starts', color: AppColors.error);
    rule.paint(canvas, Offset(16, trigger - rule.height - 3));

    void worker(double centerX, double feet, String label, Color tone) {
      final deck = yOf(feet);
      canvas
        ..drawRect(
          Rect.fromLTRB(centerX - 52, deck, centerX + 52, deck + 6),
          Paint()..color = AppColors.charcoal.withValues(alpha: 0.75),
        )
        ..drawRect(
          Rect.fromLTWH(centerX - 5, deck - 20, 10, 20),
          Paint()..color = AppColors.charcoal,
        );
      // The post it stands on, so the height reads as a height.
      canvas.drawLine(
        Offset(centerX, deck + 6),
        Offset(centerX, ground),
        Paint()
          ..color = AppColors.ink3
          ..strokeWidth = 1.2,
      );
      final t = _text(label, size: 10.5, color: tone);
      t.paint(canvas, Offset(centerX - t.width / 2, deck - 38));
    }

    worker(size.width * 0.27, 5, '5 ft up', AppColors.forest);
    worker(size.width * 0.72, 8, '8 ft up', AppColors.error);

    final under = _text('nothing required', color: AppColors.forest);
    under.paint(
      canvas,
      Offset(size.width * 0.27 - under.width / 2, ground + 8),
    );
    final over = _text('rails, net or harness', color: AppColors.error);
    over.paint(canvas, Offset(size.width * 0.72 - over.width / 2, ground + 8));
  }

  @override
  bool shouldRepaint(_TriggerPainter old) => false;
}

/// Every picture on this chapter's sheets, by the contact sheet's card name.
const constructionPictures = <String, Widget Function()>{
  'forward': forwardPassPicture,
  'duration': projectDurationPicture,
  'passes': passesPicture,
  'float': floatPicture,
  'critical': criticalPathPicture,
  'variances': earnedValuePicture,
  'forecast': forecastPicture,
  'trench': excavationPicture,
  'height': fallProtectionPicture,
  'fit': deliveryFitPicture,
};
