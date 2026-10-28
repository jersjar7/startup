part of 'pick_one_game.dart';

/// A round's screen written as a small widget tree, for layouts the plain
/// blocks do not cover (docs/mobile/content-packs.md, "Screen nodes").
///
/// Every node is a map with its kind in `k`:
///
/// - `box`: a container. `pad` [left, top, right, bottom], `w` (or
///   `"max"` for the full width), `h`,
///   `fill`, `border` (a color, or false), `stroke`, `radius`, `align`
///   (`center`, `left`, `right`), `clip`, `edge` (`top` for a border on
///   the top side only), and a `child` or `c` (children, laid out as a
///   column with `cross`).
/// - `row`, `col`: children `c` in a line, with `main` and `cross`
///   alignment.
/// - `gap`: empty space, `w` wide or `h` high.
/// - `flex`: its `child` takes `f` shares of the room left in a row, or
///   with `loose` up to that much.
/// - `center`: its `child` centred, with `wf`, a width factor.
/// - `t`: words, `v`, in a `font` (`body`, `mono`, `code`, `overline`,
///   `heading`) with `size`, `color`, `bold`, `line`, `align`, `one` (one
///   line, cut short), `bar` (a line over it, for a macron) and `weight`
///   (100 to 900, over the face's own, as Something Is Wrong Here sets a
///   report's values in bold mono).
/// - `rule`: a divider `h` high in `color`.
/// - `tex`: a formula set as a block (`v`, `size`).
/// - `math`: a formula set in a line of text (`v`, `size`, `color`), as the
///   games write one inside a box or beside words.
/// - `draw`: a recorded drawing, `d`, filling its parent.
/// - `clip`: its `child` clipped to a `radius`.
/// - `grid`: the engineering grid behind its `child`, with lines every
///   `minor` (18) and heavier ones every `major` (90).
/// - `answer`: answer `i`, tapped anywhere on its `child`, with `radius`
///   and `fill`. Inside it, a value may follow the answer's state.
/// - `tapdraw`: a drawing answered by tapping on it (see [_tapDraw]): by
///   area, by the nearest mark, or by the nearest line (Which Arrow Is
///   That's three arrows, where every tap picks one); drawn as one drawing
///   per pick, a layer per mark, or one per order of picks.
/// - `icon`: one of the few icons the games draw, by name in `v` (only
///   `check` so far), with `size` and `color`.
///
/// Any value may follow the round: `{"ask": a, "done": b}` (before and
/// after the answer); `{"idle", "picked", "right", "wrong"}` (the state of
/// the answer it sits in, or of answer `of`; `slot0`, `slot1`... for a
/// pick in that slot); `{"slot": k, "of": [one per answer], "empty": v}`
/// (what is picked in slot k); `{"pick": [one per answer], "none": v}`
/// (what is picked, in a round of one); `{"place": [one per slot],
/// "none": v}` (which place the answer it sits in, or answer `of`, was
/// picked in). A node's `child`, or any of its `c`, may be such a value,
/// and may come out as nothing. Colors are token names, with
/// `/alpha` for a see-through one, or `clear`.
extension on _ScreenBlocks {
  Widget _node(Map<String, Object?> n, [int? answer]) {
    Object? v(String key) => _value(n[key], answer);
    double? d(String key) => (v(key) as num?)?.toDouble();
    // A child may itself follow the round, and be nothing for now.
    Widget? child() => _nodeOf(n['child'], answer);
    List<Widget> kids() => [
      for (final c in (n['c'] as List?) ?? const [])
        if (c is! Map<String, Object?> || _shown(c)) ?_nodeOf(c, answer),
    ];

    switch (n['k']) {
      case 'box':
        final pad = (v('pad') as List?)?.cast<num>();
        final border = v('border');
        final kidsList = n['c'] == null ? null : kids();
        return Container(
          width: v('w') == 'max' ? double.infinity : d('w'),
          height: d('h'),
          alignment: _align(v('align')),
          padding: pad == null
              ? null
              : EdgeInsets.fromLTRB(
                  pad[0].toDouble(),
                  pad[1].toDouble(),
                  pad[2].toDouble(),
                  pad[3].toDouble(),
                ),
          clipBehavior: n['clip'] == true ? Clip.antiAlias : Clip.none,
          decoration: BoxDecoration(
            color: _color(v('fill')),
            borderRadius: n['radius'] == null
                ? null
                : BorderRadius.circular(d('radius')!),
            border: border == null || border == false
                ? null
                : n['edge'] == 'top'
                ? Border(
                    top: BorderSide(
                      color: _color(border)!,
                      width: d('stroke') ?? 1,
                    ),
                  )
                : Border.all(color: _color(border)!, width: d('stroke') ?? 1),
          ),
          child: kidsList == null
              ? child()
              : Column(
                  crossAxisAlignment: _cross(v('cross')),
                  children: kidsList,
                ),
        );
      case 'row':
        return Row(
          mainAxisAlignment: _main(v('main')),
          crossAxisAlignment: _cross(v('cross') ?? 'center'),
          children: kids(),
        );
      case 'col':
        return Column(
          mainAxisAlignment: _main(v('main')),
          crossAxisAlignment: _cross(v('cross') ?? 'center'),
          children: kids(),
        );
      case 'gap':
        return SizedBox(width: d('w'), height: d('h'));
      case 'flex':
        return n['loose'] == true
            ? Flexible(flex: (n['f'] as int?) ?? 1, child: child()!)
            : Expanded(flex: (n['f'] as int?) ?? 1, child: child()!);
      case 'center':
        return Center(widthFactor: d('wf'), child: child());
      case 't':
        final bar = n['bar'] == true;
        final color = _color(v('color') ?? 'charcoal')!;
        final size = d('size');
        var style = switch (v('font') ?? 'body') {
          'mono' => AppTheme.mono(size: size ?? 14, color: color),
          'code' => AppTheme.code(size: size ?? 14, color: color),
          'overline' => AppTheme.overline(color: color),
          'heading' => AppTheme.heading(size: size ?? 27, color: color),
          _ => TextStyle(
            fontSize: size,
            height: d('line'),
            fontWeight: n['bold'] == true ? FontWeight.w600 : null,
            color: color,
          ),
        };
        if (n['weight'] case final int weight) {
          style = style.copyWith(
            fontWeight: FontWeight.values[weight ~/ 100 - 1],
          );
        }
        if (bar) {
          style = style.copyWith(
            decoration: TextDecoration.overline,
            decorationColor: color,
            decorationThickness: 1.4,
          );
        }
        return Text(
          v('v')! as String,
          textAlign: switch (v('align')) {
            'center' => TextAlign.center,
            'right' => TextAlign.right,
            _ => null,
          },
          maxLines: n['one'] == true ? 1 : null,
          overflow: n['one'] == true ? TextOverflow.ellipsis : null,
          style: style,
        );
      case 'tex':
        return MathBlock(v('v')! as String, fontSize: d('size')!);
      case 'math':
        return MathText(
          v('v')! as String,
          style: TextStyle(
            fontSize: d('size'),
            color: _color(v('color') ?? 'charcoal'),
          ),
        );
      case 'draw':
        return CustomPaint(
          painter: DrawingPainter(ops(v('d'))),
          child: const SizedBox.expand(),
        );
      case 'clip':
        return ClipRRect(
          borderRadius: BorderRadius.circular(d('radius')!),
          child: child(),
        );
      case 'grid':
        return EngineeringGrid(
          minor: d('minor') ?? 18,
          major: d('major') ?? 90,
          child: child()!,
        );
      case 'answer':
        final i = n['i']! as int;
        final radius = BorderRadius.circular(d('radius') ?? 12);
        return Material(
          // Kept as the same answer when something appears above it once
          // answered, as the built-in games' keyed buttons are.
          key: ValueKey('answer-$i'),
          color: _color(_value(n['fill'], i)) ?? Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: onPick == null ? null : () => onPick!(i),
            child: _node(n['child']! as Map<String, Object?>, i),
          ),
        );
      case 'rule':
        return Divider(height: d('h') ?? 1, color: _color(v('color')));
      case 'tapdraw':
        return _tapDraw(n);
      case 'icon':
        return Icon(
          switch (v('v')) {
            'check' => Icons.check_rounded,
            final other => throw FormatException('Unknown icon $other'),
          },
          size: d('size'),
          color: _color(v('color')),
        );
    }
    throw FormatException('Unknown screen node $n');
  }

  /// A node, or a value that follows the round and comes out as a node or
  /// as nothing.
  Widget? _nodeOf(Object? raw, int? answer) => switch (_value(raw, answer)) {
    final Map<String, Object?> node => _node(node, answer),
    null => null,
    final other => throw FormatException('Not a screen node: $other'),
  };

  /// A value as it stands now: see [_node] for the forms, which nest.
  Object? _value(Object? raw, int? answer) {
    final now = _valueOnce(raw, answer);
    return identical(now, raw) ? now : _value(now, answer);
  }

  Object? _valueOnce(Object? raw, int? answer) {
    if (raw is! Map) return raw;
    if (raw.containsKey('ask')) return answered ? raw['done'] : raw['ask'];
    if (raw['slot'] case final int k) {
      final at = k < picks.length ? picks[k] : null;
      return at == null ? raw['empty'] : (raw['of']! as List)[at];
    }
    if (raw['place'] case final List each) {
      final at = picks.indexOf((raw['of'] as int?) ?? answer);
      return at < 0 ? raw['none'] : each[at];
    }
    if (raw['pick'] case final List each) {
      return picked.isEmpty ? raw['none'] : each[picked.single];
    }
    if (raw.containsKey('idle')) {
      final i = (raw['of'] as int?) ?? answer!;
      final slot = picks.indexOf(i);
      final state = answered && truth.contains(i)
          ? 'right'
          : answered && slot >= 0
          ? 'wrong'
          : slot >= 0
          ? (raw.containsKey('slot$slot') ? 'slot$slot' : 'picked')
          : 'idle';
      return raw[state];
    }
    return raw;
  }

  Color? _color(Object? name) {
    if (name == null) return null;
    if (name == 'clear') return Colors.transparent;
    final [token, ...alpha] = (name as String).split('/');
    final color = _allColors[token];
    if (color == null) throw FormatException('No color $token');
    return alpha.isEmpty
        ? color
        : color.withValues(alpha: double.parse(alpha.single));
  }

  static const _allColors = <String, Color>{
    'charcoal': AppColors.charcoal,
    'white': AppColors.white,
    // White in both themes, for the light on a calculator's screen.
    'pure': Colors.white,
    'cream': AppColors.cream,
    'creamDark': AppColors.creamDark,
    'screen': AppColors.screen,
    'onScreen': AppColors.onScreen,
    'line': AppColors.line,
    'ink2': AppColors.ink2,
    'ink3': AppColors.ink3,
    'ember': AppColors.ember,
    'emberBg': AppColors.emberBg,
    'forest': AppColors.forest,
    'forestBg': AppColors.forestBg,
    'sunbeam': AppColors.sunbeam,
    'sunbeamBg': AppColors.sunbeamBg,
    'error': AppColors.error,
    'errorBg': AppColors.errorBg,
    'info': AppColors.info,
    'infoBg': AppColors.infoBg,
  };

  static AlignmentGeometry? _align(Object? a) => switch (a) {
    'center' => Alignment.center,
    'left' => Alignment.centerLeft,
    'right' => Alignment.centerRight,
    null => null,
    _ => throw FormatException('No alignment $a'),
  };

  static MainAxisAlignment _main(Object? a) => switch (a) {
    'center' => MainAxisAlignment.center,
    'end' => MainAxisAlignment.end,
    'between' => MainAxisAlignment.spaceBetween,
    'evenly' => MainAxisAlignment.spaceEvenly,
    _ => MainAxisAlignment.start,
  };

  static CrossAxisAlignment _cross(Object? a) => switch (a) {
    'start' => CrossAxisAlignment.start,
    'end' => CrossAxisAlignment.end,
    'stretch' => CrossAxisAlignment.stretch,
    _ => CrossAxisAlignment.center,
  };

  /// A drawing `h` high answered by tapping on it. Targets are recorded
  /// circles, rectangles or lines, one per mark, and `hits` says which
  /// answer each mark stands for: a tap inside a rectangle picks it (the
  /// last of overlapping ones), otherwise the nearest circle within its
  /// radius, by distance or, with `axis: "x"`, across only, or the nearest
  /// line however far (the first of lines as near).
  ///
  /// The drawing is `d`, keyed `"<pick or ->|<0 or 1 for answered>"` for a
  /// round of one pick, or `layers`, drawn in order: each either the same
  /// always (`d`) or for one mark (`mark`, keyed `"<0 or 1 for picked>|<0
  /// or 1 for answered>"`), so a drawing of several picks needs no
  /// drawing per combination. With `"by": "order"` the drawing follows
  /// every pick in the order made, keyed `"<marks picked, comma separated,
  /// or ->|<0 or 1 for answered>"`, for a ranking whose drawing numbers
  /// each pick (Rank Them by Stiffness).
  Widget _tapDraw(Map<String, Object?> n) {
    final hits = (n['hits']! as List).cast<int>();
    final h = (n['h']! as num).toDouble();
    final done = answered ? 1 : 0;
    String one() {
      if (n['by'] == 'order') {
        final marks = [
          for (final p in picks.whereType<int>()) hits.indexOf(p),
        ];
        return '${marks.isEmpty ? '-' : marks.join(',')}|$done';
      }
      final mark = picked.length == 1 ? hits.indexOf(picked.single) : -1;
      return '${mark < 0 ? '-' : mark}|$done';
    }

    return LayoutBuilder(
      builder: (context, box) {
        final size = Size(box.maxWidth, h);
        final layers = n['layers'] as List?;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: onPick == null
              ? null
              : (details) {
                  final hit = _hitOf(n, size, details.localPosition);
                  if (hit != null) onPick!(hits[hit]);
                },
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: CustomPaint(
              painter: layers == null
                  ? DrawingPainter(ops((n['d']! as Map)[one()]))
                  : _LayersPainter([
                      for (final l in layers.cast<Map<String, Object?>>())
                        switch (l['mark']) {
                          final int m =>
                            (l['d']!
                                as Map)['${picked.contains(hits[m]) ? 1 : 0}|$done'],
                          _ => l['d'],
                        },
                    ]),
              child: const SizedBox.expand(),
            ),
          ),
        );
      },
    );
  }

  static int? _hitOf(Map<String, Object?> n, Size size, Offset tap) {
    final acrossOnly = n['axis'] == 'x';
    int? best;
    var bestGap = double.infinity;
    double? reach;
    for (final (i, step) in drawingSteps(
      ops(n['targets']),
      size.width,
    ).indexed) {
      final op = step! as List<Object?>;
      double at(int k) => drawingNumber(op[k], size.width);
      if (op[0] == 'rect') {
        if (Rect.fromLTRB(at(1), at(2), at(3), at(4)).contains(tap)) best = i;
        continue;
      }
      if (op[0] == 'line') {
        // The nearest line, however far: every tap picks one.
        final gap = _toSegment(tap, Offset(at(1), at(2)), Offset(at(3), at(4)));
        if (gap < bestGap) {
          bestGap = gap;
          best = i;
          reach = double.infinity;
        }
        continue;
      }
      final centre = Offset(at(1), at(2));
      final gap = acrossOnly
          ? (centre.dx - tap.dx).abs()
          : (centre - tap).distance;
      if (gap < bestGap) {
        bestGap = gap;
        best = i;
        reach = at(3);
      }
    }
    if (reach != null && bestGap > reach) return null;
    return best;
  }

  /// How far [p] is from the segment from [a] to [b].
  static double _toSegment(Offset p, Offset a, Offset b) {
    final run = b - a;
    final len2 = run.dx * run.dx + run.dy * run.dy;
    if (len2 < 0.001) return (p - a).distance;
    final t = (((p - a).dx * run.dx + (p - a).dy * run.dy) / len2).clamp(
      0.0,
      1.0,
    );
    return (p - (a + run * t)).distance;
  }
}

/// Recorded drawings painted one over the other, in order.
class _LayersPainter extends CustomPainter {
  _LayersPainter(this.layers);

  final List<Object?> layers;

  @override
  void paint(Canvas canvas, Size size) {
    for (final l in layers) {
      DrawingPainter(ops(l)).paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(_LayersPainter old) => true;
}
