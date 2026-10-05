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
import 'figure_ink.dart';
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
  painter: _RoutesPainter(),
  caption:
      'the same network, pulled apart into its three routes. the longest one '
      'is the finish date',
  height: 215,
);

// ---------------------------------------------------------------------------
// Earned value

/// Week ten of a job: 500k was planned by now, 420k of work is done, and
/// 480k has gone out of the door.
const _weekTen = Progress(planned: 500000, earned: 420000, actual: 480000);

/// The same date on a job that is behind but spending carefully: less got
/// done than the plan asked for, and still less money went out than the work
/// was worth. The two gaps point opposite ways, which is why they are
/// reported as two numbers and not one.
const _shortHanded = Progress(planned: 500000, earned: 420000, actual: 380000);

Widget earnedValuePicture() => const Column(
  children: [
    ConceptPicture(
      painter: ValuePainter(progress: _weekTen, answered: true),
      caption:
          'behind and over budget: less got done than planned, and it cost '
          'more than it was worth',
      height: 195,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: ValuePainter(progress: _shortHanded, answered: true),
      caption:
          'behind and UNDER budget: the same work done, on less money. one '
          'gap each way, which is why there are two numbers',
      height: 195,
    ),
  ],
);

Widget forecastPicture() => const ConceptPicture(
  painter: _StretchPainter(),
  caption:
      'dividing by a rate under one makes the bar LONGER. that is the step '
      'people turn upside down',
  height: 252,
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
    // At the right end of the line: the worker standing at five feet has his
    // own label just above it, and at the left the two sat on each other.
    inkLabel(
      canvas,
      rule,
      Offset(size.width - rule.width - 16, trigger - rule.height - 3),
    );

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
      inkLabel(canvas, t, Offset(centerX - t.width / 2, deck - 38));
    }

    worker(size.width * 0.27, 5, '5 ft up', AppColors.forest);
    worker(size.width * 0.72, 8, '8 ft up', AppColors.error);

    final under = _text('nothing required', color: AppColors.forest);
    inkLabel(
      canvas,
      under,
      Offset(size.width * 0.27 - under.width / 2, ground + 8),
    );
    final over = _text('rails, net or harness', color: AppColors.error);
    inkLabel(
      canvas,
      over,
      Offset(size.width * 0.72 - over.width / 2, ground + 8),
    );
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

// ---------------------------------------------------------------------------
// The painters written for a sheet, where the game's own drawing could not
// carry the idea (second pass, 2026-09-30).

void _say(
  Canvas canvas,
  String text,
  Offset at, {
  Color color = AppColors.ink2,
  double size = 10,
  bool center = false,
  bool right = false,
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: AppTheme.mono(size: size, color: color),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  var x = at.dx;
  if (center) x -= tp.width / 2;
  if (right) x -= tp.width;
  inkLabel(canvas, tp, Offset(x, at.dy));
}

/// The network's three routes pulled apart and laid one under another, each
/// as long as the days it takes.
///
/// The game draws the network as a network, which is right for playing it:
/// you have to trace the routes yourself. A sheet that is ABOUT the longest
/// route should not make you trace anything, so this lays the three routes
/// out and lets their lengths answer the question.
class _RoutesPainter extends CustomPainter {
  const _RoutesPainter();

  // A 4, B 6, C 3, D 5, E 3. B and C follow A; D follows B and C; E follows C.
  static const _routes = <(List<(String, int)>, int)>[
    ([('A', 4), ('B', 6), ('D', 5)], 15),
    ([('A', 4), ('C', 3), ('D', 5)], 12),
    ([('A', 4), ('C', 3), ('E', 3)], 10),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const left = 14.0;
    final right = size.width - 68;
    const perDay = 0.0;
    final scale = (right - left) / 15 + perDay;
    const top = 34.0;
    final gap = (size.height - top - 34) / _routes.length;

    _say(
      canvas,
      'every way from the start to the finish',
      Offset(left, 12),
      size: 9.5,
      color: AppColors.charcoal,
    );

    for (var r = 0; r < _routes.length; r++) {
      final (chain, total) = _routes[r];
      final longest = r == 0;
      final y = top + r * gap;
      var x = left;
      for (final (name, days) in chain) {
        final w = days * scale;
        final box = Rect.fromLTWH(x, y, w - 2, 20);
        canvas.drawRRect(
          RRect.fromRectAndRadius(box, const Radius.circular(3)),
          Paint()
            ..color = longest
                ? AppColors.ember
                : AppColors.ink3.withValues(alpha: 0.35),
        );
        _say(
          canvas,
          '$name $days',
          Offset(box.center.dx, y + 4),
          center: true,
          size: 9.5,
          color: longest ? AppColors.cream : AppColors.ink2,
        );
        x += w;
      }
      _say(
        canvas,
        '$total days',
        Offset(x + 6, y + 4),
        size: 10,
        color: longest ? AppColors.ember : AppColors.ink2,
      );
      if (longest) {
        _say(
          canvas,
          'the longest: no room to slip anywhere on it',
          Offset(left, y + 24),
          size: 9,
          color: AppColors.ember,
        );
      }
    }

    _say(
      canvas,
      'the job takes 15 days, whatever the other routes do',
      Offset(left, size.height - 16),
      size: 9,
    );
  }

  @override
  bool shouldRepaint(_RoutesPainter old) => false;
}

/// Work still to do, and the same work after it is divided by a rate under
/// one: the second bar is LONGER, which is the step the sheet is about.
class _StretchPainter extends CustomPainter {
  const _StretchPainter();

  // Budget 2.00M, earned 0.60M, spent 0.75M, so the rate is 0.80.
  // Still to do 1.40M; at 0.80 that costs 1.75M; plus 0.75M spent = 2.50M.
  @override
  void paint(Canvas canvas, Size size) {
    const left = 14.0;
    final right = size.width - 60;
    final scale = (right - left) / 2.5;
    const barH = 17.0;

    void bar(double y, double millions, Color tone, String label, String note) {
      final r = Rect.fromLTWH(left, y, millions * scale, barH);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(3)),
        Paint()..color = tone,
      );
      _say(
        canvas,
        '${millions.toStringAsFixed(2)}M',
        Offset(r.right + 6, y + 2),
        size: 10,
        color: tone == AppColors.ink3 ? AppColors.ink2 : tone,
      );
      _say(canvas, label, Offset(left, y - 13), size: 9, color: AppColors.ink2);
      if (note.isNotEmpty) {
        _say(
          canvas,
          note,
          Offset(left, y + barH + 3),
          size: 9,
          color: AppColors.ember,
        );
      }
    }

    bar(
      33,
      1.40,
      AppColors.ink3.withValues(alpha: 0.5),
      'the work still to do, priced at budget',
      '',
    );

    // The division, drawn as the thing that lengthens the bar.
    const arrowY = 58.0;
    canvas.drawLine(
      Offset(left + 20, arrowY),
      Offset(left + 20, arrowY + 14),
      Paint()
        ..color = AppColors.ember
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      Path()
        ..moveTo(left + 20, arrowY + 17)
        ..lineTo(left + 16.5, arrowY + 11)
        ..lineTo(left + 23.5, arrowY + 11)
        ..close(),
      Paint()..color = AppColors.ember,
    );
    _say(
      canvas,
      'divide by the rate, 0.80',
      Offset(left + 30, arrowY + 1),
      size: 9,
      color: AppColors.ember,
    );

    bar(
      97,
      1.75,
      AppColors.ember,
      'so the rest will really cost',
      'under one, so the bar got LONGER',
    );

    bar(
      152,
      0.75,
      AppColors.ink3.withValues(alpha: 0.5),
      'and this much is already gone',
      '',
    );

    bar(207, 2.50, AppColors.charcoal, 'the whole job, forecast', '');

    // The original budget, as the line the forecast runs past.
    final budgetX = left + 2.0 * scale;
    canvas.drawLine(
      Offset(budgetX, 201),
      Offset(budgetX, 207 + barH + 4),
      Paint()
        ..color = AppColors.error
        ..strokeWidth = 1.4,
    );
    _say(
      canvas,
      'budget 2.00M',
      Offset(budgetX + 4, 207 + barH + 6),
      size: 9,
      color: AppColors.error,
      right: true,
    );
  }

  @override
  bool shouldRepaint(_StretchPainter old) => false;
}
