part of 'pick_one_game.dart';

/// A round's screen written as a small widget tree, for layouts the plain
/// blocks do not cover (docs/mobile/content-packs.md, "Screen nodes").
///
/// Every node is a map with its kind in `k`:
///
/// - `box`: a container. `pad` [left, top, right, bottom], `w` (or
///   `"max"` for the full width), `h`, at least `minw` wide and `minh`
///   high and at most `maxw` wide, `fill`, `border` (a color, or false), `stroke`, `radius`, `align`
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
///   line, cut short), `max` (at most that many lines, the rest cut off
///   with no ellipsis), `bar` (a line over it, for a macron) and `weight`
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
///   and `fill`, and a `key` when the built-in game keys its own. Inside
///   it, a value may follow the answer's state.
/// - `tapdraw`: a drawing answered by tapping on it (see [_tapDraw]): by
///   area, by the nearest mark, or by the nearest line (Which Arrow Is
///   That's three arrows, where every tap picks one); drawn as one drawing
///   per pick, a layer per mark, or one per order of picks.
/// - `icon`: one of the few icons the games draw, by name in `v` (`check`,
///   `close`, `northEast`, `southEast`, `add`, `remove`), with `size` and
///   `color`.
/// - `fade`: its `child` at opacity `o`.
/// - `wrap`: children `c` in runs, `spacing` apart and `run` between
///   runs, with `align` and `cross` (`center`).
/// - `step`: a button that moves the pick by `by` (Stretch It to Fit).
/// - `slot`: slot `s` (or row of a fill), tapped to empty it once filled.
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
/// `/alpha` for a see-through one, or `clear`. Also `{"on", "off", "of":
/// i}` (whether answer i, or the answer it sits in, is picked), `{"picks":
/// {"0,2": v}, "else": v, "sorted": true}` (what is picked, in order or
/// sorted), `{"step": [one per step]}` (a run of moves), `{"open", "won",
/// "lost"}` (how the round ended) and `{"fill": k, "next", "full",
/// "empty", "right", "wrong"}` (how row k of a fill stands).
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
        final limits =
            n['minw'] != null || n['maxw'] != null || n['minh'] != null;
        return Container(
          width: v('w') == 'max' ? double.infinity : d('w'),
          height: d('h'),
          constraints: limits
              ? BoxConstraints(
                  minWidth: d('minw') ?? 0,
                  maxWidth: d('maxw') ?? double.infinity,
                  minHeight: d('minh') ?? 0,
                )
              : null,
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
            shape: n['shape'] == 'circle'
                ? BoxShape.circle
                : BoxShape.rectangle,
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
                : n['edge'] == 'topLeft'
                ? Border(
                    top: BorderSide(
                      color: _color(border)!,
                      width: d('stroke') ?? 1,
                    ),
                    left: BorderSide(
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
          mainAxisSize: n['size'] == 'min'
              ? MainAxisSize.min
              : MainAxisSize.max,
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
        // The face's own weight (`fw`), as a game asks the style for it,
        // which picks a different face from setting the weight after.
        final face = n['fw'] == null
            ? null
            : FontWeight.values[(n['fw']! as int) ~/ 100 - 1];
        var style = switch (v('font') ?? 'body') {
          'mono' => AppTheme.mono(
            size: size ?? 14,
            color: color,
            weight: face ?? FontWeight.w500,
          ),
          'code' => AppTheme.code(
            size: size ?? 14,
            color: color,
            weight: face ?? FontWeight.w500,
          ),
          'overline' => AppTheme.overline(color: color),
          'heading' => AppTheme.heading(
            size: size ?? 27,
            color: color,
            weight: face ?? FontWeight.w700,
            height: d('line') ?? 1.1,
          ),
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
          maxLines: n['one'] == true ? 1 : n['max'] as int?,
          overflow: n['one'] == true ? TextOverflow.ellipsis : null,
          style: style,
        );
      case 'tex':
        return MathBlock(
          v('v')! as String,
          fontSize: d('size')!,
          align: _align(v('align')) as Alignment?,
          fit: n['fit'] != false,
        );
      case 'step':
        // A button that moves the pick up or down by `by`, as Stretch It to
        // Fit's multiplier is worked with a thumb.
        final radius = BorderRadius.circular(d('radius') ?? 12);
        return Material(
          color: _color(v('fill')) ?? Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: onStep == null ? null : () => onStep!(n['by']! as int),
            child: child(),
          ),
        );
      case 'math':
        return MathText(
          v('v')! as String,
          style: TextStyle(
            fontSize: d('size'),
            height: d('line'),
            color: _color(v('color') ?? 'charcoal'),
          ),
        );
      case 'wrap':
        return Wrap(
          alignment: n['align'] == 'center'
              ? WrapAlignment.center
              : WrapAlignment.start,
          crossAxisAlignment: n['cross'] == 'center'
              ? WrapCrossAlignment.center
              : WrapCrossAlignment.start,
          spacing: d('spacing') ?? 0,
          runSpacing: d('run') ?? 0,
          children: kids(),
        );
      case 'fade':
        return Opacity(opacity: d('o')!, child: child());
      case 'slot':
        // A filled slot, tapped to take its pick back (Fill the Trace's
        // rows).
        final k = n['s']! as int;
        final filled = k < picks.length && picks[k] != null;
        return GestureDetector(
          key: ValueKey('slot-$k'),
          onTap: onClear == null || !filled ? null : () => onClear!(k),
          child: child(),
        );
      case 'draw':
        // One drawing, or `layers` drawn one over the other (each may
        // follow the round, and come out as nothing).
        if (n['layers'] case final List layers) {
          return CustomPaint(
            painter: _LayersPainter([
              for (final l in layers)
                if (_value(l, answer) case final Object drawn) (drawn, null),
            ]),
            child: const SizedBox.expand(),
          );
        }
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
        final off = onPick == null || _value(n['off'], i) == true;
        if (n['plain'] == true) {
          // Tapped with no ink, as games built on a bare tap handler are.
          return GestureDetector(
            key: ValueKey('answer-$i'),
            onTap: off ? null : () => onPick!(i),
            child: _node(n['child']! as Map<String, Object?>, i),
          );
        }
        final radius = BorderRadius.circular(d('radius') ?? 12);
        return Material(
          // Kept as the same answer when something appears above it once
          // answered, as the built-in games' keyed buttons are. A `key`
          // names it as the built-in game names its own (`cell-B2`).
          key: ValueKey(n['key'] as String? ?? 'answer-$i'),
          color: _color(_value(n['fill'], i)) ?? Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: off ? null : () => onPick!(i),
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
            'close' => Icons.close_rounded,
            'northEast' => Icons.north_east_rounded,
            'southEast' => Icons.south_east_rounded,
            'add' => Icons.add_rounded,
            'remove' => Icons.remove_rounded,
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
    if (raw.containsKey('won')) {
      return !answered ? raw['open'] : (correct! ? raw['won'] : raw['lost']);
    }
    if (raw['picks'] case final Map each) {
      final now = raw['sorted'] == true
          ? (picked.toList()..sort())
          : picks.whereType<int>().toList();
      final key = now.join(',');
      return each.containsKey(key) ? each[key] : raw['else'];
    }
    if (raw.containsKey('on')) {
      final i = (raw['of'] as int?) ?? answer!;
      return picked.contains(i) ? raw['on'] : raw['off'];
    }
    if (raw['step'] case final List each) return each[at];
    if (raw['fill'] case final int k) {
      final at = k < picks.length ? picks[k] : null;
      if (answered) {
        return at == this.answer[k] ? raw['right'] : raw['wrong'];
      }
      var next = 0;
      while (next < picks.length && picks[next] != null) {
        next++;
      }
      return k == next
          ? raw['next']
          : at != null
          ? raw['full']
          : raw['empty'];
    }
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

  /// A drawing `h` high (or `"h": "w"`, as tall as it is wide) answered by
  /// tapping on it, and with `drag` by dragging across it too. Targets are
  /// recorded circles, rectangles, paths, lines or arcs, one per mark, and
  /// `hits` says which answer each mark stands for: a tap inside a
  /// rectangle or a path picks it (the last of overlapping ones),
  /// otherwise the nearest circle within
  /// its radius, by distance or, with `axis: "x"`, across only, or with
  /// `axis: "y"`, up and down only (Which Fiber Is Worst's layers run the
  /// width of the section), the nearest line (the first of lines as near)
  /// however far, or with `"reach": "stroke"` within its paint's stroke
  /// width (What the Water Touches's pieces of a channel's boundary, Tap
  /// the Side), or the nearest arc
  /// within its paint's stroke width of it (Which Curve Is Sharper's two
  /// curves). With `first`, the first circle within its radius wins rather
  /// than the nearest, as games that check their points in order do.
  ///
  /// The drawing is `d`, keyed `"<pick or ->|<0 or 1 for answered>"` for a
  /// round of one pick, or `layers`, drawn in order: each either the same
  /// always (`d`) or for one mark (`mark`, keyed `"<0 or 1 for picked>|<0
  /// or 1 for answered>"`), so a drawing of several picks needs no
  /// drawing per combination, or one drawing moved onto whichever mark is
  /// picked (`moved`, its origin put on the mark's centre), so a dot on any
  /// of many points is recorded once. A layer's `d` may follow the round
  /// as any value does, and may come out as nothing. With `"reach":
  /// "stroke"`, a line takes only taps within its paint's stroke width of
  /// it. With `"by": "order"` the drawing follows
  /// every pick in the order made, keyed `"<marks picked, comma separated,
  /// or ->|<0 or 1 for answered>"`, for a ranking whose drawing numbers
  /// each pick (Rank Them by Stiffness).
  Widget _tapDraw(Map<String, Object?> n) {
    final hits = (n['hits']! as List).cast<int>();
    final done = answered ? 1 : 0;
    String one() {
      if (n['by'] == 'order') {
        final marks = [for (final p in picks.whereType<int>()) hits.indexOf(p)];
        return '${marks.isEmpty ? '-' : marks.join(',')}|$done';
      }
      final mark = picked.length == 1 ? hits.indexOf(picked.single) : -1;
      return '${mark < 0 ? '-' : mark}|$done';
    }

    return LayoutBuilder(
      builder: (context, box) {
        // As tall as it is wide (`"h": "w"`), or a set height.
        final size = Size(
          box.maxWidth,
          n['h'] == 'w' ? box.maxWidth : (n['h']! as num).toDouble(),
        );
        final layers = n['layers'] as List?;
        void at(Offset local) {
          final hit = _hitOf(n, size, local);
          if (hit != null) onPick!(hits[hit]);
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: onPick == null
              ? null
              : (details) => at(details.localPosition),
          // Dragged across as well as tapped (`drag`), as Slide to the Flat
          // Spot's marker is.
          onHorizontalDragUpdate: onPick == null || n['drag'] != true
              ? null
              : (details) => at(details.localPosition),
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: CustomPaint(
              painter: layers == null
                  ? DrawingPainter(ops((n['d']! as Map)[one()]))
                  : _LayersPainter([
                      for (final l in layers.cast<Map<String, Object?>>())
                        if (l['pin'] case final Map pin)
                          ?_pin(n, pin, l['at'], size, hits)
                        // One drawing for whichever mark is picked, moved
                        // onto it (`moved`): Place the Center's dot, on any
                        // of 169 points.
                        else if (l['moved'] == true)
                          ?(picked.length != 1 || !hits.contains(picked.single)
                              ? null
                              : (
                                  _value(l['d'], null),
                                  _markAt(n, size, hits.indexOf(picked.single)),
                                ))
                        else
                          switch (l['mark']) {
                            final int m => (
                              (l['d']!
                                  as Map)['${picked.contains(hits[m]) ? 1 : 0}|$done'],
                              null,
                            ),
                            // The same for every pick, or following the
                            // round (before and after the answer).
                            _ => (_value(l['d'], null), null),
                          },
                    ]),
              child: const SizedBox.expand(),
            ),
          ),
        );
      },
    );
  }

  /// Where mark [mark] sits: the middle of its tap area, or its circle's
  /// centre.
  static Offset _markAt(Map<String, Object?> n, Size size, int mark) {
    final op =
        drawingSteps(ops(n['targets']), size.width)[mark]! as List<Object?>;
    double at(int k) => drawingNumber(op[k], size.width);
    return op[0] == 'rect'
        ? Rect.fromLTRB(at(1), at(2), at(3), at(4)).center
        : Offset(at(1), at(2));
  }

  /// A pin layer: one drawing, recorded around the origin, drawn at the
  /// middle of a mark (Land the Resultant's ring on the point tapped, out
  /// of 169). `at: "pick"` draws it on the picked mark, as `ask` before the
  /// answer and `right` or `wrong` after it; `at: "truth"` on the right
  /// answer's mark once answered, as `done`. A state with no drawing draws
  /// nothing.
  (Object?, Offset?)? _pin(
    Map<String, Object?> n,
    Map pin,
    Object? at,
    Size size,
    List<int> hits,
  ) {
    final int answer;
    final String state;
    if (at == 'truth') {
      if (!answered) return null;
      answer = truth.single;
      state = 'done';
    } else {
      if (picked.length != 1) return null;
      answer = picked.single;
      state = !answered
          ? 'ask'
          : truth.contains(answer)
          ? 'right'
          : 'wrong';
    }
    final drawing = pin[state];
    final mark = hits.indexOf(answer);
    if (drawing == null || mark < 0) return null;
    final op =
        drawingSteps(ops(n['targets']), size.width)[mark]! as List<Object?>;
    return (
      drawing,
      Offset(
        drawingNumber(op[1], size.width),
        drawingNumber(op[2], size.width),
      ),
    );
  }

  static int? _hitOf(Map<String, Object?> n, Size size, Offset tap) {
    final acrossOnly = n['axis'] == 'x';
    final upOnly = n['axis'] == 'y';
    // Measured as the larger of across and up, so the mark taken is the
    // lattice point a tap rounds to, as Land the Resultant's grid does.
    final square = n['axis'] == 'box';
    final first = n['first'] == true;
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
      if (op[0] == 'path') {
        // An area of any shape (Quadrant Signs' quarters of a disc, clear
        // of the axes): a tap inside it picks it, the last one winning.
        final area = buildPath(
          op[1]! as int,
          op[2]! as List<Object?>,
          size.width,
        );
        if (area.contains(tap)) best = i;
        continue;
      }
      if (op[0] == 'arc') {
        // How far the tap is from the arc: from its circle while the tap
        // lies within the arc's sweep, otherwise from the end on the tap's
        // side of the arc's middle.
        final rect = Rect.fromLTRB(at(1), at(2), at(3), at(4));
        final start = at(5), sweep = at(6);
        final mid = start + sweep / 2;
        final d = tap - rect.center;
        var turn = math.atan2(d.dy, d.dx) - mid;
        while (turn > math.pi) {
          turn -= 2 * math.pi;
        }
        while (turn <= -math.pi) {
          turn += 2 * math.pi;
        }
        final r = rect.width / 2;
        final double gap;
        if (turn.abs() <= sweep.abs() / 2) {
          gap = (d.distance - r).abs();
        } else {
          final end = mid + (turn < 0 ? -1 : 1) * sweep.abs() / 2;
          gap = (tap - (rect.center + Offset(math.cos(end), math.sin(end)) * r))
              .distance;
        }
        if (gap < bestGap) {
          bestGap = gap;
          best = i;
          reach = drawingNumber((op[8]! as Map)['w'], size.width);
        }
        continue;
      }
      if (op[0] == 'line') {
        // The nearest line: however far, or with `"reach": "stroke"`
        // within its paint's stroke width (Tap the Side takes a side
        // within 60).
        final gap = _toSegment(tap, Offset(at(1), at(2)), Offset(at(3), at(4)));
        if (gap < bestGap) {
          bestGap = gap;
          best = i;
          reach = n['reach'] == 'stroke'
              ? drawingNumber((op[5]! as Map)['w'], size.width)
              : double.infinity;
        }
        continue;
      }
      final centre = Offset(at(1), at(2));
      final gap = acrossOnly
          ? (centre.dx - tap.dx).abs()
          : upOnly
          ? (centre.dy - tap.dy).abs()
          : square
          ? math.max((centre.dx - tap.dx).abs(), (centre.dy - tap.dy).abs())
          : (centre - tap).distance;
      if (first) {
        if (best == null && gap < at(3)) {
          bestGap = gap;
          best = i;
          reach = at(3);
        }
        continue;
      }
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

/// Recorded drawings painted one over the other, in order, each where it
/// is pinned or moved (a mark's middle) or where it was recorded.
class _LayersPainter extends CustomPainter {
  _LayersPainter(this.layers);

  final List<(Object?, Offset?)> layers;

  @override
  void paint(Canvas canvas, Size size) {
    for (final (l, at) in layers) {
      if (l == null) continue;
      if (at == null) {
        DrawingPainter(ops(l)).paint(canvas, size);
        continue;
      }
      canvas
        ..save()
        ..translate(at.dx, at.dy);
      DrawingPainter(ops(l)).paint(canvas, size);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_LayersPainter old) => true;
}
