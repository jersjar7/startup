import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import '../../core/theme/app_colors.dart';
import 'lesson_node.dart';

/// The Rive artwork behind every lesson node, loaded once for the whole app.
///
/// Nothing waits on it. Until the file arrives, and forever if it never does,
/// a node draws itself with the painter in `lesson_node.dart`. That painter is
/// also what every widget test and golden sees, because a test never calls
/// [warmUp]. So the app logic (which state, how full, when to pop) is
/// exercised without a native runtime, and Rive only ever changes pixels.
///
/// The artboard lives in `mobile/rive/lesson_node/scene.rml` and is built
/// with the Rive CLI into [asset]. Its contract with this file is the
/// `LessonNode` view model, spelled out in `docs/mobile/lesson-node-rive.md`.
abstract final class LessonNodeArt {
  static const asset = 'assets/rive/lesson_node.riv';
  static const artboard = 'LessonNode';
  static const stateMachine = 'Node';

  /// The view model's public surface, by name. `lesson_node_rive_test.dart`
  /// reads the markup and fails when the two lists drift.
  static const inputs = [
    'state',
    'progress',
    'pressed',
    'celebrate',
    'face',
    'plinth',
    'rim',
    'wedge',
    'ink',
    'halo',
  ];

  /// The artboard's own geometry, in artboard units. The face is 100 across
  /// with a 10 plinth under it and 12 of air on every side, so the finished
  /// pop and its halo have room to leave the face without being clipped.
  static const faceSize = 100.0;
  static const artWidth = 124.0;
  static const artHeight = 134.0;
  static const pad = 12.0;

  /// The loaded file, or null while loading and after a failure.
  static final file = ValueNotifier<rive.File?>(null);
  static Future<void>? _loading;

  /// Loads the file once. Safe to call from anywhere, any number of times.
  static Future<void> warmUp() => _loading ??= _load();

  static Future<void> _load() async {
    try {
      // The Flutter renderer, not the Rive one: a chapter map shows a couple
      // dozen of these at once, and each Rive-rendered widget would own its
      // own texture. Flat vector shapes are cheap on Flutter's own canvas.
      file.value = await rive.File.asset(
        asset,
        riveFactory: rive.Factory.flutter,
      );
    } catch (e) {
      debugPrint('lesson node art unavailable, the painter stays: $e');
    }
  }
}

/// One lesson node drawn by Rive.
///
/// Every decision arrives from outside: [showing] is the state to wear right
/// now (the map holds a just-finished lesson on its unfinished face until the
/// wedge has closed), [fraction] is how full the wedge is this frame, and
/// [pressed] is whether a finger is on it. This widget only translates those
/// into the view model and lets the artboard move.
///
/// The one thing it decides itself is the finished moment: the pop fires when
/// [showing] turns from in-progress to cleared while the widget is on screen,
/// which is exactly when the wedge has just closed, and never on first build.
class RiveLessonNode extends StatefulWidget {
  const RiveLessonNode({
    super.key,
    required this.file,
    required this.showing,
    required this.skin,
    required this.fraction,
    required this.pressed,
    required this.size,
  });

  final rive.File file;
  final NodeState showing;
  final NodeSkin skin;
  final double fraction;
  final bool pressed;
  final double size;

  @override
  State<RiveLessonNode> createState() => _RiveLessonNodeState();
}

class _RiveLessonNodeState extends State<RiveLessonNode>
    with SingleTickerProviderStateMixin {
  late final rive.RiveWidgetController _controller;
  late final rive.ViewModelInstance _vmi;
  late final rive.ViewModelInstanceEnum _state;
  late final rive.ViewModelInstanceNumber _progress;
  late final rive.ViewModelInstanceBoolean _pressed;
  late final rive.ViewModelInstanceTrigger _celebrate;
  late final Map<String, rive.ViewModelInstanceColor> _colors;

  /// The brand colors live in Dart, so the cross-fade between two states'
  /// colors does too, on the same 220ms the artboard uses for its geometry.
  late final AnimationController _tint = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  late _Palette _from;
  late _Palette _to;

  @override
  void initState() {
    super.initState();
    _controller = rive.RiveWidgetController(
      widget.file,
      artboardSelector: rive.ArtboardSelector.byName(LessonNodeArt.artboard),
      stateMachineSelector: rive.StateMachineSelector.byName(
        LessonNodeArt.stateMachine,
      ),
    );
    _vmi = _controller.dataBind(rive.DataBind.auto());
    _state = _vmi.enumerator('state')!;
    _progress = _vmi.number('progress')!;
    _pressed = _vmi.boolean('pressed')!;
    _celebrate = _vmi.trigger('celebrate')!;
    _colors = {for (final name in _Palette.names) name: _vmi.color(name)!};

    _from = _to = _Palette.of(widget.skin, previous: null);
    _push(_to);
    _state.value = widget.showing.name;
    _progress.value = widget.fraction;
    _pressed.value = widget.pressed;

    _tint.addListener(() {
      _push(_Palette.lerp(_from, _to, Curves.easeOut.transform(_tint.value)));
    });
  }

  @override
  void didUpdateWidget(RiveLessonNode old) {
    super.didUpdateWidget(old);
    if (old.showing != widget.showing) {
      _state.value = widget.showing.name;
      if (old.showing == NodeState.inProgress &&
          widget.showing == NodeState.cleared) {
        _celebrate.trigger();
      }
    }
    if (old.fraction != widget.fraction) _progress.value = widget.fraction;
    if (old.pressed != widget.pressed) _pressed.value = widget.pressed;

    final next = _Palette.of(widget.skin, previous: _to);
    if (next != _to) {
      _from = _Palette.lerp(_from, _to, Curves.easeOut.transform(_tint.value));
      _to = next;
      _tint.forward(from: 0);
    }
  }

  void _push(_Palette p) {
    for (final name in _Palette.names) {
      _colors[name]!.value = p[name];
    }
  }

  @override
  void dispose() {
    _tint.dispose();
    for (final c in _colors.values) {
      c.dispose();
    }
    _state.dispose();
    _progress.dispose();
    _pressed.dispose();
    _celebrate.dispose();
    _vmi.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The node's slot is the same box the painter uses: the face, plus the
    // plinth showing below it. The artboard is bigger than that by its
    // padding on every side, so it hangs over the slot rather than shrinking
    // to fit it, and the face lands exactly where the painter's face was.
    final size = widget.size;
    final k = size / LessonNodeArt.faceSize;
    return SizedBox(
      width: size,
      height: size + LessonNodeWidget.bodyShow,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -LessonNodeArt.pad * k,
            top: -LessonNodeArt.pad * k,
            width: LessonNodeArt.artWidth * k,
            height: LessonNodeArt.artHeight * k,
            child: rive.RiveWidget(
              controller: _controller,
              fit: rive.Fit.contain,
              // Taps belong to the GestureDetector around the node.
              hitTestBehavior: rive.RiveHitTestBehavior.none,
            ),
          ),
        ],
      ),
    );
  }
}

/// The six colors the artboard takes, named as the view model names them.
@immutable
class _Palette {
  const _Palette(this._c);

  final Map<String, Color> _c;

  static const names = ['face', 'plinth', 'rim', 'wedge', 'ink', 'halo'];

  /// A skin leaves the rim and wedge unset on states that do not show them.
  /// The artboard fades those out by opacity, so their color should stay
  /// what it was, not drift toward some stand-in while the fade runs.
  static _Palette of(NodeSkin skin, {required _Palette? previous}) => _Palette({
    'face': skin.face,
    'plinth': skin.plinth,
    'rim': skin.rim ?? previous?['rim'] ?? skin.ink,
    'wedge': skin.wedge ?? previous?['wedge'] ?? AppColors.ember,
    'ink': skin.ink,
    // The halo marks a finished lesson, and finished is forest.
    'halo': AppColors.forest,
  });

  static _Palette lerp(_Palette a, _Palette b, double t) =>
      _Palette({for (final n in names) n: Color.lerp(a[n], b[n], t)!});

  Color operator [](String name) => _c[name]!;

  @override
  bool operator ==(Object other) =>
      other is _Palette && names.every((n) => other[n] == this[n]);

  @override
  int get hashCode => Object.hashAll(names.map((n) => this[n]));
}
