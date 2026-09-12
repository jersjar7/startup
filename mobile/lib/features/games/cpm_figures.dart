import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';

/// One activity in a network: what it is called, how long it takes, and
/// what has to finish before it can start.
@immutable
class Task {
  const Task({
    required this.name,
    required this.days,
    this.after = const [],
  });

  final String name;
  final double days;
  final List<String> after;
}

/// A whole network, with both passes worked out. Everything a round can
/// claim about it is computed here, so no round can claim a number the
/// network does not give.
@immutable
class Network {
  const Network({required this.tasks});

  final List<Task> tasks;

  Task named(String name) => tasks.firstWhere((t) => t.name == name);

  List<Task> successorsOf(String name) =>
      tasks.where((t) => t.after.contains(name)).toList();

  /// The forward pass: an activity starts when the LAST of the things it
  /// waits on has finished.
  Map<String, double> get earlyStart {
    final es = <String, double>{};
    double startOf(Task t) {
      if (es.containsKey(t.name)) return es[t.name]!;
      var start = 0.0;
      for (final p in t.after) {
        final pre = named(p);
        start = math.max(start, startOf(pre) + pre.days);
      }
      es[t.name] = start;
      return start;
    }

    for (final t in tasks) {
      startOf(t);
    }
    return es;
  }

  Map<String, double> get earlyFinish => {
        for (final t in tasks) t.name: earlyStart[t.name]! + t.days,
      };

  double get duration =>
      earlyFinish.values.fold(0, (a, b) => math.max(a, b));

  /// The backward pass: an activity must finish before the EARLIEST of the
  /// things waiting on it has to start.
  Map<String, double> get lateFinish {
    final lf = <String, double>{};
    double finishOf(Task t) {
      if (lf.containsKey(t.name)) return lf[t.name]!;
      final next = successorsOf(t.name);
      var finish = duration;
      for (final s in next) {
        finish = math.min(finish, finishOf(s) - s.days);
      }
      lf[t.name] = finish;
      return finish;
    }

    for (final t in tasks) {
      finishOf(t);
    }
    return lf;
  }

  Map<String, double> get lateStart => {
        for (final t in tasks) t.name: lateFinish[t.name]! - t.days,
      };

  /// How far an activity can slip without pushing the end of the project.
  double totalFloatOf(String name) =>
      lateStart[name]! - earlyStart[name]!;

  /// And how far it can slip without pushing anything else at all.
  double freeFloatOf(String name) {
    final next = successorsOf(name);
    if (next.isEmpty) return duration - earlyFinish[name]!;
    final earliest = next
        .map((s) => earlyStart[s.name]!)
        .reduce((a, b) => math.min(a, b));
    return earliest - earlyFinish[name]!;
  }

  bool isCritical(String name) => totalFloatOf(name).abs() < 0.0001;

  List<String> get criticalPath =>
      tasks.where((t) => isCritical(t.name)).map((t) => t.name).toList();
}

/// The network drawn as boxes and arrows, laid out by how far along each
/// activity sits. The numbers the passes produce are the questions, so they
/// arrive with the answer.
class NetworkPainter extends CustomPainter {
  const NetworkPainter({
    required this.network,
    this.highlight,
    this.showEarly = true,
    this.showLate = true,
    this.markCritical = true,
    this.answered = false,
  });

  final Network network;

  /// An activity the round is about.
  final String? highlight;

  /// Which numbers this item is teaching.
  final bool showEarly;
  final bool showLate;

  /// Whether to pick out the critical chain once the answer is in.
  final bool markCritical;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final es = network.earlyStart;
    final ef = network.earlyFinish;
    final ls = network.lateStart;
    final lf = network.lateFinish;

    // Columns by early start, rows by how many share a column.
    final columns = <double, List<Task>>{};
    for (final t in network.tasks) {
      columns.putIfAbsent(es[t.name]!, () => []).add(t);
    }
    final keys = columns.keys.toList()..sort();

    final left = 18.0;
    final wide = (size.width - 36) / math.max(keys.length, 1);
    const boxW = 58.0;
    const boxH = 34.0;

    final at = <String, Offset>{};
    for (var c = 0; c < keys.length; c++) {
      final here = columns[keys[c]]!;
      for (var r = 0; r < here.length; r++) {
        final x = left + c * wide + (wide - boxW) / 2;
        final y = 44.0 + r * (boxH + 14) +
            (here.length == 1 ? (boxH + 14) / 2 : 0);
        at[here[r].name] = Offset(x, y);
      }
    }

    // Arrows first, so the boxes sit on top of them.
    for (final t in network.tasks) {
      for (final p in t.after) {
        final from = at[p]!;
        final to = at[t.name]!;
        final critical = answered &&
            markCritical &&
            network.isCritical(p) &&
            network.isCritical(t.name);
        canvas.drawLine(
            Offset(from.dx + boxW, from.dy + boxH / 2),
            Offset(to.dx, to.dy + boxH / 2),
            Paint()
              ..color = critical ? AppColors.ember : AppColors.ink3
              ..strokeWidth = critical ? 2.4 : 1.2);
      }
    }

    for (final t in network.tasks) {
      final p = at[t.name]!;
      final box = Rect.fromLTWH(p.dx, p.dy, boxW, boxH);
      final picked = highlight == t.name;
      final critical = answered && markCritical && network.isCritical(t.name);
      canvas
        ..drawRect(
            box,
            Paint()
              ..color = (picked
                      ? AppColors.ember
                      : critical
                          ? AppColors.ember
                          : AppColors.ink2)
                  .withValues(alpha: picked ? 0.28 : critical ? 0.16 : 0.16))
        ..drawRect(
            box,
            Paint()
              ..color = picked
                  ? AppColors.ember
                  : critical
                      ? AppColors.ember
                      : AppColors.line
              ..style = PaintingStyle.stroke
              ..strokeWidth = picked ? 2 : 1.2);

      final title = TextPainter(
        text: TextSpan(
          text: '${t.name}  ${t.days.toStringAsFixed(0)}d',
          style: AppTheme.mono(size: 10, color: AppColors.charcoal),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      title.paint(canvas, Offset(box.left + 5, box.top + 4));

      if (answered) {
        if (showEarly) {
          final early = TextPainter(
            text: TextSpan(
              text: '${es[t.name]!.toStringAsFixed(0)} to '
                  '${ef[t.name]!.toStringAsFixed(0)}',
              style: AppTheme.mono(size: 9, color: AppColors.info),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          early.paint(canvas, Offset(box.left + 5, box.top + 18));
        }
        if (showLate) {
          final late = TextPainter(
            text: TextSpan(
              text: '${ls[t.name]!.toStringAsFixed(0)} to '
                  '${lf[t.name]!.toStringAsFixed(0)}',
              style: AppTheme.mono(size: 9, color: AppColors.forest),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          late.paint(
              canvas, Offset(box.left + 5, box.top + (showEarly ? 25 : 18)));
        }
      }
    }

    writeOn(canvas, size, 'each box is an activity and its days',
        const Offset(8, 8), AppColors.ink3, fontSize: 9.5);

    if (!answered) {
      writeOn(canvas, size, 'the dates come out after the answer',
          Offset(8, size.height - 16), AppColors.ink3, fontSize: 9.5);
      return;
    }

    final legend = StringBuffer();
    if (showEarly) legend.write('early start to finish in blue');
    if (showEarly && showLate) legend.write(', ');
    if (showLate) legend.write('late start to finish in green');
    writeOn(canvas, size, legend.toString(), Offset(8, size.height - 30),
        AppColors.ink3, fontSize: 9.5);
    writeOn(
        canvas,
        size,
        '${network.duration.toStringAsFixed(0)} days in all'
            '${markCritical ? ', and the critical chain is marked' : ''}',
        Offset(8, size.height - 16),
        AppColors.charcoal,
        fontSize: 9.5);
  }

  @override
  bool shouldRepaint(NetworkPainter old) =>
      old.network != network ||
      old.highlight != highlight ||
      old.showEarly != showEarly ||
      old.showLate != showLate ||
      old.markCritical != markCritical ||
      old.answered != answered;
}
