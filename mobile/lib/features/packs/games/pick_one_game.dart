import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../games/board.dart';
import '../../shared/widgets/engineering_grid.dart';
import '../../shared/widgets/math_text.dart';
import '../drawing/drawing_painter.dart';
import '../pack_model.dart';

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

  int? _picked;

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
    final answer = r['answer']! as int;

    return BoardShell(
      session: _session,
      brief: _game.brief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _picked = null);
              _session.next();
            }
          : (_picked == null
                ? null
                : () =>
                      _session.submit(ok: _picked == answer, context: context)),
      child: r['screen'] != null
          ? _ScreenBlocks(
              blocks: (r['screen']! as List).cast<Map<String, Object?>>(),
              answered: answered,
              picked: _picked,
              truth: answer,
              onPick: answered ? null : (i) => setState(() => _picked = i),
              choice: (i) => _Choice(
                label: options[i],
                tex: (r['tex'] as List?)?[i] as String?,
                pad: (r['choicePad'] as num?)?.toDouble() ?? 13,
                selected: _picked == i,
                locked: answered,
                isTruth: answer == i,
                onTap: answered ? null : () => setState(() => _picked = i),
              ),
              options: options.length,
              feedback: answered
                  ? BoardFeedback(
                      correct: _session.correct!,
                      title: _session.correct!
                          ? _game.text('right')
                          : _game.text('wrong'),
                      body: r['why']! as String,
                    )
                  : null,
            )
          : _classic(r, answered, options, answer),
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
            selected: _picked == i,
            locked: answered,
            isTruth: answer == i,
            onTap: answered ? null : () => setState(() => _picked = i),
          ),
          if (i != options.length - 1) const SizedBox(height: 8),
        ],
        if (answered) ...[
          const SizedBox(height: 14),
          BoardFeedback(
            correct: _session.correct!,
            title: _session.correct!
                ? _game.text('right')
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
/// only before or only after the answer, or `"when": "picked"` to show only
/// while an answer is picked and not locked in (with `of`, only while one
/// of those answers is).
///
/// Blocks: `gap` (height), `overline` (with `color`), `mono` (with `size`
/// and `color`), `text` (with `bold`), `math` (centred, with `size`),
/// `figure` (a recorded drawing with `h`, framed as `panel`, `grid` or
/// `none`), `box` (white bordered box holding blocks, with `pad`),
/// `choices` (the answers, or a list of which ones, with `space` between them and `last`, whether the
/// last one gets the gap too), `panels` (answers that are drawings: one per
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
    required this.picked,
    required this.truth,
    required this.onPick,
    required this.choice,
    required this.options,
    required this.feedback,
  });

  final List<Map<String, Object?>> blocks;
  final bool answered;
  final int? picked;
  final int truth;
  final void Function(int)? onPick;
  final Widget Function(int) choice;
  final int options;
  final Widget? feedback;

  static const _colors = {
    'ember': AppColors.ember,
    'forest': AppColors.forest,
    'info': AppColors.info,
    'ink3': AppColors.ink3,
    'charcoal': AppColors.charcoal,
  };

  bool _shown(Map<String, Object?> b) => switch (b['when']) {
    'ask' => !answered,
    'done' => answered,
    'picked' =>
      picked != null &&
          !answered &&
          ((b['of'] as List?)?.contains(picked) ?? true),
    _ => true,
  };

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
            fontSize: 15,
            height: 1.5,
            fontWeight: b['bold'] == true ? FontWeight.w600 : null,
            color: AppColors.charcoal,
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
          _ => SizedBox(height: h, child: paint),
        },
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
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.line),
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
    if (b['panels'] case final List panels) {
      final space = _num(b['space'] ?? 8);
      Widget panel(int i) => _FigureChoice(
        drawings: (panels[i]! as Map).cast<String, Object?>(),
        height: _num(b['h']),
        pad: _num(b['pad'] ?? 0),
        selected: picked == i,
        locked: answered,
        isTruth: truth == i,
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
          labels[picked!]! as String,
          style: AppTheme.mono(
            size: _num(b['size']),
            color: _colors[b['color']]!,
          ),
        ),
      ];
    }
    if (b['tap'] case final Map<String, Object?> drawings) {
      final hits = (b['hits']! as List).cast<int>();
      final mark = hits.indexOf(picked ?? -1);
      final state = '${mark < 0 ? '-' : mark}|${answered ? 1 : 0}';
      final h = _num(b['h']);
      return [
        LayoutBuilder(
          builder: (context, box) {
            final size = Size(box.maxWidth, h);
            return GestureDetector(
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
          },
        ),
      ];
    }
    if (b['feedback'] == true) return [?feedback];
    throw FormatException('Unknown screen block $b');
  }

  /// The mark nearest a tap, if one is within reach: the first of equals
  /// wins, as in the games this was built from.
  static int? _nearest(Map<String, Object?> b, Size size, Offset tap) {
    int? best;
    var gap = (b['within']! as num).toDouble();
    for (final (i, step) in drawingSteps(
      ops(b['targets']),
      size.width,
    ).indexed) {
      final op = step! as List<Object?>;
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
