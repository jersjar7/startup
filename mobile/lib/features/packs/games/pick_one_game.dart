import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../games/board.dart';
import '../../games/liability_row.dart';
import '../../shared/widgets/engineering_grid.dart';
import '../../shared/widgets/math_text.dart';
import '../drawing/drawing_painter.dart';
import '../pack_model.dart';

part 'screen_nodes.dart';

/// Game type "pick-one": a question over a drawing, four answers, pick one.
///
/// Built from Per Million What, screen for screen, so that game plays the
/// same from a pack as it did built in. Each round's drawing comes in two
/// states, before the answer ("ask") and after it ("done").
///
/// A round may instead carry its whole screen as a list of blocks
/// (`screen`), for games laid out differently from that one; see
/// [_ScreenBlocks].
class PackPickOneGame extends StatefulWidget {
  const PackPickOneGame({super.key, required this.game});

  final PackGame game;

  @override
  State<PackPickOneGame> createState() => _PackPickOneGameState();
}

class _PackPickOneGameState extends State<PackPickOneGame> {
  PackGame get _game => widget.game;

  late final BoardSession _session = BoardSession(
    gameId: _game.id,
    gameName: _game.title,
    pack: _game.pack,
    chapterId: _game.chapterId,
    total: _game.rounds.length,
    sourceProblemIdOf: (round) => _game.rounds[round]['source']! as String,
  )..addListener(_onSession);

  void _onSession() => setState(() {});

  /// What is picked, in the order it was picked: one answer, or for game
  /// type "pick-several" any number of them. A round whose answers fill
  /// slots (`"order": "slots"`) keeps an empty slot as null.
  final _picks = <int?>[];

  Set<int> get _picked => _picks.whereType<int>().toSet();

  bool get _several => _game.type == 'pick-several';

  /// The right answers: one, or for "pick-several" every one that must be
  /// picked (in order, when the round says order matters).
  List<int> get _answer => switch (_round['answer']) {
    final int i => [i],
    final List all => all.cast<int>(),
    final other => throw FormatException('Not an answer: $other'),
  };

  void _pick(int i) => setState(() {
    final r = _round;
    if (!_several) {
      _picks
        ..clear()
        ..add(i);
      return;
    }
    final most = r['most'] as int?;
    if (r['order'] == 'slots') {
      // Tapping a picked answer empties its slot; anything else fills the
      // first empty slot, if there is one.
      final at = _picks.indexOf(i);
      if (at >= 0) {
        _picks[at] = null;
      } else {
        while (_picks.length < most!) {
          _picks.add(null);
        }
        final hole = _picks.indexOf(null);
        if (hole >= 0) _picks[hole] = i;
      }
      return;
    }
    // Answers in a group ("yes" and "no" to one question) are one choice:
    // picking one replaces the other, and picking it again keeps it.
    for (final group in (r['groups'] as List?) ?? const []) {
      final members = (group as List).cast<int>();
      if (!members.contains(i)) continue;
      _picks.removeWhere((p) => p != i && members.contains(p));
      if (!_picks.contains(i)) _picks.add(i);
      return;
    }
    // An answer that stands alone ("nobody clears it") clears the rest,
    // and picking any other clears it.
    final alone = ((r['alone'] as List?) ?? const []).cast<int>();
    if (alone.contains(i)) {
      final had = _picks.contains(i);
      _picks.clear();
      if (!had) _picks.add(i);
    } else if (_picks.contains(i)) {
      _picks.remove(i);
    } else if (most == null || _picks.length < most) {
      _picks
        ..removeWhere(alone.contains)
        ..add(i);
    }
  });

  /// Whether the picks can be locked in: anything picked, or exactly as
  /// many as the round needs.
  bool get _ready {
    final count = _picked.length;
    final need = _round['need'] as int?;
    return need == null ? count > 0 : count == need;
  }

  bool get _right {
    final answer = _answer;
    if (_round['order'] == 'slots' || _round['order'] == 'list') {
      return _picks.length == answer.length &&
          [
            for (var k = 0; k < answer.length; k++) _picks[k] == answer[k],
          ].every((same) => same);
    }
    final picked = _picked;
    return picked.length == answer.length && picked.containsAll(answer);
  }

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  Map<String, Object?> get _round => _game.rounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: _game.title,
        closing: _game.closing,
      );
    }

    final answered = _session.answered;
    final r = _round;
    final options = (r['options']! as List).cast<String>();
    final truth = _answer.toSet();

    return BoardShell(
      session: _session,
      brief: _game.brief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(_picks.clear);
              _session.next();
            }
          : (!_ready
                ? null
                : () => _session.submit(ok: _right, context: context)),
      child: r['screen'] != null
          ? _ScreenBlocks(
              blocks: (r['screen']! as List).cast<Map<String, Object?>>(),
              answered: answered,
              picks: _picks,
              truth: truth,
              onPick: answered ? null : _pick,
              choice: (i) => r['notes'] is List
                  ? LiabilityRow(
                      title: options[i],
                      note: (r['notes']! as List)[i]! as String,
                      selected: _picked.contains(i),
                      locked: answered,
                      isTruth: truth.contains(i),
                      onTap: answered ? null : () => _pick(i),
                    )
                  : _Choice(
                      label: options[i],
                      tex: (r['tex'] as List?)?[i] as String?,
                      pad: (r['choicePad'] as num?)?.toDouble() ?? 13,
                      selected: _picked.contains(i),
                      locked: answered,
                      isTruth: truth.contains(i),
                      onTap: answered ? null : () => _pick(i),
                    ),
              options: options.length,
              feedback: answered
                  ? BoardFeedback(
                      correct: _session.correct!,
                      title: _session.correct!
                          ? (r['right'] as String? ?? _game.text('right'))
                          : _game.text('wrong'),
                      body: r['why']! as String,
                    )
                  : null,
            )
          : _classic(r, answered, options, truth.single),
    );
  }

  Widget _classic(
    Map<String, Object?> r,
    bool answered,
    List<String> options,
    int answer,
  ) {
    final figure = r['figure']! as Map<String, Object?>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _game.text('overline'),
          style: AppTheme.overline(color: AppColors.ember),
        ),
        const SizedBox(height: 6),
        Text(
          r['subject']! as String,
          style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
        ),
        const SizedBox(height: 10),
        Text(
          r['asked']! as String,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: AppColors.charcoal,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: (_game.json['figureHeight']! as num).toDouble(),
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
                painter: DrawingPainter(ops(figure[answered ? 'done' : 'ask'])),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < options.length; i++) ...[
          _Choice(
            label: options[i],
            selected: _picked.contains(i),
            locked: answered,
            isTruth: answer == i,
            onTap: answered ? null : () => _pick(i),
          ),
          if (i != options.length - 1) const SizedBox(height: 8),
        ],
        if (answered) ...[
          const SizedBox(height: 14),
          BoardFeedback(
            correct: _session.correct!,
            title: _session.correct!
                ? (r['right'] as String? ?? _game.text('right'))
                : _game.text('wrong'),
            body: r['why']! as String,
          ),
        ],
      ],
    );
  }
}

/// A round's screen as data: each block is one widget of the column, in
/// order. Any block may carry `"when": "ask"` or `"when": "done"` to show
/// only before or only after the answer, `"when": "none"` to show only
/// while nothing is picked, or `"when": "picked"` to show only while an
/// answer is picked and not locked in, or `"when": "chosen"` while one is
/// picked, locked in or not (with `of`, on "picked", "chosen" or "done",
/// only while one of those answers is the one picked).
///
/// Blocks: `gap` (height), `overline` (with `color`), `mono` (with `size`
/// and `color`), `text` (with `bold`, `size` and `line`), `code` (with
/// `size`), `math` (centred, with `size`), `figure` (a recorded drawing
/// with `h`, framed as `panel`, `grid`, `clip` with a `radius`, or `none`),
/// `box` (a box holding blocks, with `pad`, and `fill`, `radius` and
/// `border` when it is not the white bordered one), `row` (cells side by
/// side, see [_cell]), `rule` (a hairline with `rule` pixels above and
/// below),
/// `choices` (the answers, or a list of which ones, with `space` between
/// them and `last`, whether the last one gets the gap too; a round with
/// `notes` shows each answer as a title with its note beneath, the app's
/// titled row), `tiles` (answers that tint when picked, each a row of
/// cells, see [_cell]; in a `row` or a column, with `pad`, `radius`, `h`,
/// `center`, `space` and `last`), `panels` (answers that are drawings: one per
/// answer, each drawn as it looks `idle`, `picked`, `right` and `wrong`, or
/// just `idle` and `on` when only its border changes; in a `row` or a
/// column, with `h`, `pad`, `space` and `last`), `pickedLabel` (the picked
/// answer's words, shown only while it is picked and not yet locked in)
/// and `feedback`; and `tap`, a drawing answered by tapping near one of
/// its marks (`targets`, one recorded circle per mark, the nearest within
/// `within` pixels wins; `hits`, the answer each mark stands for), drawn
/// as it looks for each mark picked and each state (`"<mark or ->|<0 or
/// 1 for answered>"`).
class _ScreenBlocks extends StatelessWidget {
  const _ScreenBlocks({
    required this.blocks,
    required this.answered,
    required this.picks,
    required this.truth,
    required this.onPick,
    required this.choice,
    required this.options,
    required this.feedback,
  });

  final List<Map<String, Object?>> blocks;
  final bool answered;

  /// What is picked, in order (null for an empty slot).
  final List<int?> picks;
  Set<int> get picked => picks.whereType<int>().toSet();
  final Set<int> truth;
  final void Function(int)? onPick;
  final Widget Function(int) choice;
  final int options;
  final Widget? feedback;

  static const _colors = {
    'ember': AppColors.ember,
    'forest': AppColors.forest,
    'info': AppColors.info,
    'ink2': AppColors.ink2,
    'ink3': AppColors.ink3,
    'charcoal': AppColors.charcoal,
    'white': AppColors.white,
    'creamDark': AppColors.creamDark,
    'emberBg': AppColors.emberBg,
  };

  bool _shown(Map<String, Object?> b) {
    final of = (b['of'] as List?)?.any(picked.contains) ?? true;
    return switch (b['when']) {
      'ask' => !answered,
      'done' => answered && of,
      'none' => picked.isEmpty && !answered,
      'picked' => picked.isNotEmpty && !answered && of,
      'chosen' => picked.isNotEmpty && of,
      _ => true,
    };
  }

  double _num(Object? v) => switch (v) {
    {'ask': final num ask, 'done': final num done} =>
      (answered ? done : ask).toDouble(),
    final num n => n.toDouble(),
    _ => throw FormatException('Not a size: $v'),
  };

  List<Widget> _all(List<Map<String, Object?>> blocks) => [
    for (final b in blocks)
      if (_shown(b)) ..._block(b),
  ];

  List<Widget> _block(Map<String, Object?> b) {
    if (b['k'] != null) return [_node(b)];
    if (b['gap'] case final num h) return [SizedBox(height: h.toDouble())];
    if (b['overline'] case final String s) {
      return [Text(s, style: AppTheme.overline(color: _colors[b['color']]!))];
    }
    if (b['mono'] case final String s) {
      return [
        Text(
          s,
          style: AppTheme.mono(
            size: _num(b['size']),
            color: _colors[b['color']]!,
          ),
        ),
      ];
    }
    if (b['text'] case final String s) {
      return [
        Text(
          s,
          style: TextStyle(
            fontSize: _num(b['size'] ?? 15),
            height: _num(b['line'] ?? 1.5),
            fontWeight: b['bold'] == true ? FontWeight.w600 : null,
            color: AppColors.charcoal,
          ),
        ),
      ];
    }
    if (b['code'] case final String s) {
      return [
        Text(
          s,
          style: AppTheme.code(
            size: _num(b['size']),
            color: _colors[b['color'] ?? 'charcoal']!,
          ),
        ),
      ];
    }
    if (b['math'] case final String tex) {
      return [
        Center(
          child: MathText(
            tex,
            style: TextStyle(
              fontSize: _num(b['size']),
              color: AppColors.charcoal,
            ),
          ),
        ),
      ];
    }
    if (b['figure'] case final Map<String, Object?> figure) {
      final paint = CustomPaint(
        painter: DrawingPainter(ops(figure[answered ? 'done' : 'ask'])),
        child: const SizedBox.expand(),
      );
      final h = _num(b['h']);
      return [
        switch (b['frame']) {
          'panel' => Container(
            height: h,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: EngineeringGrid(minor: 18, major: 90, child: paint),
            ),
          ),
          'grid' => EngineeringGrid(
            minor: 18,
            major: 90,
            child: SizedBox(height: h, child: paint),
          ),
          'clip' => ClipRRect(
            borderRadius: BorderRadius.circular(_num(b['radius'])),
            child: SizedBox(
              height: h,
              width: double.infinity,
              child: EngineeringGrid(minor: 18, major: 90, child: paint),
            ),
          ),
          _ => SizedBox(height: h, child: paint),
        },
      ];
    }
    if (b['row'] case final List cells) {
      return [
        Row(
          children: [for (final c in cells) _cell(c as Map<String, Object?>)],
        ),
      ];
    }
    if (b['rule'] case final Object v?) {
      // Room above and below: one number for both, or [above, below].
      final (above, below) = switch (v) {
        [final num a, final num b] => (a, b),
        final num n => (n, n),
        _ => throw FormatException('Not a rule: $v'),
      };
      return [
        Padding(
          padding: EdgeInsets.only(
            top: above.toDouble(),
            bottom: below.toDouble(),
          ),
          child: const Divider(height: 1, color: AppColors.line),
        ),
      ];
    }
    if (b['box'] case final List inner) {
      final pad = (b['pad']! as List).cast<num>();
      return [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            pad[0].toDouble(),
            pad[1].toDouble(),
            pad[2].toDouble(),
            pad[3].toDouble(),
          ),
          decoration: BoxDecoration(
            color: _colors[b['fill'] ?? 'white'],
            borderRadius: BorderRadius.circular(_num(b['radius'] ?? 12)),
            border: b['border'] == false
                ? null
                : Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _all(inner.cast<Map<String, Object?>>()),
          ),
        ),
      ];
    }
    if (b['choices'] case final Object which?) {
      // Every answer, or only those listed when the rest are drawings.
      final shown = which is List
          ? which.cast<int>()
          : [for (var i = 0; i < options; i++) i];
      final gap = SizedBox(height: _num(b['space'] ?? 8));
      return [
        for (final (k, i) in shown.indexed) ...[
          choice(i),
          if (k != shown.length - 1 || b['last'] == true) gap,
        ],
      ];
    }
    if (b['tiles'] case final List tiles) {
      final space = _num(b['space'] ?? 8);
      // Answers 0, 1, 2... unless the block says which.
      final ids =
          ((b['answers'] as List?) ??
                  [for (var i = 0; i < tiles.length; i++) i])
              .cast<int>();
      Widget tile(int k) =>
          _tile(b, (tiles[k]! as List).cast<Map<String, Object?>>(), ids[k]);
      if (b['row'] == true) {
        return [
          Row(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) SizedBox(width: space),
                Expanded(child: tile(i)),
              ],
            ],
          ),
        ];
      }
      return [
        for (var i = 0; i < tiles.length; i++) ...[
          tile(i),
          if (i != tiles.length - 1 || b['last'] == true)
            SizedBox(height: space),
        ],
      ];
    }
    if (b['panels'] case final List panels) {
      final space = _num(b['space'] ?? 8);
      Widget panel(int i) => _FigureChoice(
        drawings: (panels[i]! as Map).cast<String, Object?>(),
        height: _num(b['h']),
        pad: _num(b['pad'] ?? 0),
        selected: picked.contains(i),
        locked: answered,
        isTruth: truth.contains(i),
        onTap: onPick == null ? null : () => onPick!(i),
      );
      if (b['row'] == true) {
        return [
          Row(
            children: [
              for (var i = 0; i < panels.length; i++) ...[
                if (i > 0) SizedBox(width: space),
                Expanded(child: panel(i)),
              ],
            ],
          ),
        ];
      }
      return [
        for (var i = 0; i < panels.length; i++) ...[
          panel(i),
          if (i != panels.length - 1 || b['last'] == true)
            SizedBox(height: space),
        ],
      ];
    }
    if (b['pickedLabel'] case final List labels) {
      return [
        Text(
          labels[picked.single]! as String,
          style: AppTheme.mono(
            size: _num(b['size']),
            color: _colors[b['color']]!,
          ),
        ),
      ];
    }
    if (b['tap'] case final Map<String, Object?> drawings) {
      final hits = (b['hits']! as List).cast<int>();
      final mark = picked.length == 1 ? hits.indexOf(picked.single) : -1;
      final state = '${mark < 0 ? '-' : mark}|${answered ? 1 : 0}';
      final h = _num(b['h']);
      return [
        LayoutBuilder(
          builder: (context, box) {
            final size = Size(box.maxWidth, h);
            final area = GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: onPick == null
                  ? null
                  : (details) {
                      final hit = _nearest(b, size, details.localPosition);
                      if (hit != null) onPick!(hits[hit]);
                    },
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: CustomPaint(
                    painter: DrawingPainter(ops(drawings[state])),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            );
            if (b['radius'] case final num r) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(r.toDouble()),
                child: area,
              );
            }
            return area;
          },
        ),
      ];
    }
    if (b['bars'] case final List bars) {
      return [
        _Bars(
          bars: [
            for (final bar in bars)
              ((bar as List)[0]! as String, (bar[1]! as num).toDouble()),
          ],
          span: _num(b['span']),
          line: _num(b['line']),
          label: b['label']! as String,
          picked: picked,
          truth: truth,
          locked: answered,
          onTap: onPick,
        ),
      ];
    }
    if (b['feedback'] == true) return [?feedback];
    throw FormatException('Unknown screen block $b');
  }

  /// An answer tile for answer [i], styled by [style] (`pad`, `radius`,
  /// `h`, `center`; `idle: "clear"` for one with no border or fill until
  /// picked, `stroke` for a border that keeps one width, `margin` for room
  /// around it).
  Widget _tile(
    Map<String, Object?> style,
    List<Map<String, Object?>> cells,
    int i,
  ) {
    final margin = (style['margin'] as List?)?.cast<num>();
    final tile = _Tile(
      cells: cells,
      cell: _cell,
      height: (style['h'] as num?)?.toDouble(),
      pad: (style['pad']! as List).cast<num>(),
      radius: _num(style['radius'] ?? 12),
      center: style['center'] == true,
      clear: style['idle'] == 'clear',
      stroke: (style['stroke'] as num?)?.toDouble(),
      selected: picked.contains(i),
      locked: answered,
      isTruth: truth.contains(i),
      onTap: onPick == null ? null : () => onPick!(i),
    );
    if (margin == null) return tile;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: margin[0].toDouble(),
        vertical: margin[1].toDouble(),
      ),
      child: tile,
    );
  }

  /// One piece of a row (a tile's, or a `row` block's): words, `code`,
  /// `mono`, an `overline`, a formula (`tex`), a horizontal `gap`, a
  /// `check` box, or an `answer` tile of its own `cells`. `w` sets its width,
  /// `h` its height (centred in it), `fill` gives it the width left over and
  /// `mid` a share of it, centred. Inside a tile, `ink` words take the
  /// tile's state color and a check box fills when the tile is marked.
  Widget _cell(Map<String, Object?> c, [TileState? tile]) {
    Widget w;
    final ink = c['ink'] == true ? tile!.ink : null;
    if (c['gap'] case final num g) {
      return SizedBox(width: g.toDouble());
    } else if (c['answer'] case final int i) {
      w = _tile(c, (c['cells']! as List).cast<Map<String, Object?>>(), i);
    } else if (c['check'] case final num size) {
      final on = tile!.marked;
      w = Container(
        width: size.toDouble(),
        height: size.toDouble(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_num(c['radius'])),
          color: on ? tile.mark : null,
          border: Border.all(color: on ? tile.mark : AppColors.line),
        ),
        child: on
            ? Icon(
                Icons.check_rounded,
                size: _num(c['icon']),
                color: AppColors.white,
              )
            : null,
      );
    } else if (c['text'] case final String s) {
      w = Text(
        s,
        maxLines: c['one'] == true ? 1 : null,
        overflow: c['one'] == true ? TextOverflow.ellipsis : null,
        style: TextStyle(
          fontSize: _num(c['size']),
          color: ink ?? _colors[c['color'] ?? 'charcoal'],
        ),
      );
    } else if (c['code'] case final String s) {
      w = Text(
        s,
        style: AppTheme.code(
          size: _num(c['size']),
          color: ink ?? _colors[c['color'] ?? 'charcoal']!,
        ),
      );
    } else if (c['mono'] case final String s) {
      w = Text(
        s,
        style: AppTheme.mono(
          size: _num(c['size']),
          color: _colors[c['color']]!,
        ),
      );
    } else if (c['overline'] case final String s) {
      w = Text(s, style: AppTheme.overline(color: _colors[c['color']]!));
    } else if (c['tex'] case final String tex) {
      w = MathBlock(tex, fontSize: _num(c['size']));
    } else {
      throw FormatException('Unknown cell $c');
    }
    if (c['h'] case final num height when c['answer'] == null) {
      w = SizedBox(
        height: height.toDouble(),
        child: Center(child: w),
      );
    }
    if (c['w'] case final num width) {
      w = SizedBox(width: width.toDouble(), child: w);
    }
    if (c['mid'] == true) {
      return Expanded(child: Center(widthFactor: 1, child: w));
    }
    return c['fill'] == true ? Expanded(child: w) : w;
  }

  /// The mark nearest a tap, if one is within reach: the first of equals
  /// wins, as in the games this was built from.
  ///
  /// Targets may instead be areas (recorded rectangles): a tap inside one
  /// picks it, the last of overlapping ones winning, as the topmost tap
  /// area does in the games built from a stack of them.
  static int? _nearest(Map<String, Object?> b, Size size, Offset tap) {
    int? best;
    var gap = ((b['within'] as num?) ?? 0).toDouble();
    for (final (i, step) in drawingSteps(
      ops(b['targets']),
      size.width,
    ).indexed) {
      final op = step! as List<Object?>;
      if (op[0] == 'rect') {
        final area = Rect.fromLTRB(
          drawingNumber(op[1], size.width),
          drawingNumber(op[2], size.width),
          drawingNumber(op[3], size.width),
          drawingNumber(op[4], size.width),
        );
        if (area.contains(tap)) best = i;
        continue;
      }
      if (op[0] != 'circle') throw UnsupportedError('Target shape ${op[0]}');
      final at = Offset(
        drawingNumber(op[1], size.width),
        drawingNumber(op[2], size.width),
      );
      final d = (at - tap).distance;
      if (d < gap) {
        gap = d;
        best = i;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: _all(blocks),
  );
}

/// An answer that is a drawing: a white panel on the grid whose border, and
/// often the drawing's own ink, shows whether it is picked, right or wrong.
class _FigureChoice extends StatelessWidget {
  const _FigureChoice({
    required this.drawings,
    required this.height,
    required this.pad,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Map<String, Object?> drawings;
  final double height;
  final double pad;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (String state, Color border) = locked && isTruth
        ? ('right', AppColors.forest)
        : locked && selected
        ? ('wrong', AppColors.error)
        : selected
        ? ('picked', AppColors.ember)
        : ('idle', AppColors.line);
    final drawing = drawings[state] ?? drawings['on'];

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: height,
          padding: EdgeInsets.all(pad),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(pad == 0 ? 11 : 8),
            child: EngineeringGrid(
              minor: 16,
              major: 80,
              child: CustomPaint(
                painter: DrawingPainter(ops(drawing)),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An answer that tints as well as borders: white, ember when picked, then
/// forest or red once locked in. Its content is a row of cells.
/// Answers as horizontal bars with a reference line drawn across all of
/// them (Over the Bar's projects against the MARR): each bar is answer 0,
/// 1, 2... in order, tapped anywhere along its row, and shows a check box,
/// its name and its value before the bar.
class _Bars extends StatelessWidget {
  const _Bars({
    required this.bars,
    required this.span,
    required this.line,
    required this.label,
    required this.picked,
    required this.truth,
    required this.locked,
    required this.onTap,
  });

  final List<(String, double)> bars;
  final double span;
  final double line;
  final String label;
  final Set<int> picked;
  final Set<int> truth;
  final bool locked;
  final void Function(int)? onTap;

  /// Everything left of the bars: the box, the name and the value.
  static const _gutter = 152.0;

  /// Room at the right-hand end, so a full bar does not touch the edge.
  static const _tail = 10.0;

  static const _rowHeight = 40.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        // One length for a full bar, for the bars and the line alike.
        final barFull = box.maxWidth - _gutter - _tail;
        final lineX = _gutter + line / span * barFull;
        return SizedBox(
          height: 18 + bars.length * _rowHeight,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 18,
                child: Column(
                  children: [
                    for (final (i, (name, value)) in bars.indexed)
                      _bar(i, name, value, barFull),
                  ],
                ),
              ),
              Positioned(
                left: lineX,
                top: 16,
                bottom: 0,
                child: Container(width: 1.8, color: AppColors.ember),
              ),
              Positioned(
                left: lineX - 40,
                top: 0,
                width: 80,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTheme.overline(color: AppColors.ember),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bar(int i, String name, double value, double barFull) {
    final selected = picked.contains(i);
    final isTruth = truth.contains(i);
    final color = locked && isTruth
        ? AppColors.forest
        : locked && selected
        ? AppColors.error
        : selected
        ? AppColors.ember
        : AppColors.ink2;
    final marked = selected || (locked && isTruth);

    return InkWell(
      onTap: onTap == null ? null : () => onTap!(i),
      child: SizedBox(
        height: _rowHeight,
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: marked ? color : null,
                  border: Border.all(color: marked ? color : AppColors.line),
                ),
                child: marked
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: AppColors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: _gutter - 28,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13.5, color: color),
                    ),
                  ),
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${value.toStringAsFixed(0)}%',
                      textAlign: TextAlign.right,
                      style: AppTheme.mono(size: 10.5, color: color),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            Container(
              height: 20,
              width: (value / span * barFull).clamp(1.5, 1e4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: marked ? 0.35 : 0.18),
                border: Border.all(color: color, width: marked ? 1.4 : 1),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(3),
                  right: Radius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// How a tile stands, for the cells inside it: the color its words take
/// (forest or red once locked in, otherwise charcoal), the color of its
/// mark, and whether it is marked (picked, or the right answer once locked
/// in).
typedef TileState = ({Color ink, Color mark, bool marked});

class _Tile extends StatelessWidget {
  const _Tile({
    required this.cells,
    required this.cell,
    required this.height,
    required this.pad,
    required this.radius,
    required this.center,
    required this.clear,
    required this.stroke,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final List<Map<String, Object?>> cells;
  final Widget Function(Map<String, Object?>, [TileState?]) cell;
  final double? height;
  final List<num> pad;
  final double radius;
  final bool center;
  final bool clear;
  final double? stroke;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (Color border, Color fill) = locked && isTruth
        ? (AppColors.forest, AppColors.forestBg)
        : locked && selected
        ? (AppColors.error, AppColors.errorBg)
        : selected
        ? (AppColors.ember, AppColors.emberBg)
        : clear
        ? (Colors.transparent, Colors.transparent)
        : (AppColors.line, AppColors.white);
    final TileState state = (
      ink: locked && isTruth
          ? AppColors.forest
          : locked && selected
          ? AppColors.error
          : AppColors.charcoal,
      mark: border,
      marked: selected || (locked && isTruth),
    );

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Container(
          width: center ? null : double.infinity,
          height: height,
          alignment: center ? Alignment.center : null,
          padding: EdgeInsets.fromLTRB(
            pad[0].toDouble(),
            pad[1].toDouble(),
            pad[2].toDouble(),
            pad[3].toDouble(),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: border,
              width: stroke ?? (border == AppColors.line ? 1 : 2),
            ),
          ),
          child: center && cells.length == 1
              ? cell(cells.single, state)
              : Row(children: [for (final c in cells) cell(c, state)]),
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    this.tex,
    this.pad = 13,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String label;

  /// A symbol set before the label, as What Is Missing shows its knowns.
  final String? tex;
  final double pad;
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
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: pad),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: tex == null
              ? Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.charcoal,
                  ),
                )
              : Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: MathText(
                        '\$$tex\$',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
