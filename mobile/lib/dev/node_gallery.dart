import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../features/games/lesson_node.dart';
import '../features/games/lesson_node_rive.dart';

/// Every lesson node state on one screen, drawn by Rive, with the two motions
/// that matter on a button: fill the wedge, and finish a lesson.
///
/// Not part of the app. Run it on a device or simulator to look at the
/// artwork, which no widget test can do:
///
///   flutter run -t lib/dev/node_gallery.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LessonNodeArt.warmUp();
  runApp(const _Gallery());
}

class _Gallery extends StatefulWidget {
  const _Gallery();

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  // The demo node walks 0 -> 1/3 -> 2/3 -> cleared, a step every two
  // seconds or on a tap, then starts over, so the fill and the pop can be
  // watched as many times as wanted (and captured from a script).
  int _step = 0;
  double _shown = 0;
  late final Timer _clock = Timer.periodic(
    const Duration(seconds: 2),
    (_) => _advance(),
  );

  static const _fractions = [0.0, 1 / 3, 2 / 3, 1.0];

  void _advance() => setState(() => _step = (_step + 1) % 4);

  @override
  void initState() {
    super.initState();
    _clock;
  }

  @override
  void dispose() {
    _clock.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = _fractions[_step];
    final state = _step == 3 ? NodeState.cleared : NodeState.inProgress;
    final ready = LessonNodeArt.file.value != null;

    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ready ? 'Rive artwork loaded' : 'Rive artwork NOT loaded',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    color: ready ? AppColors.forest : AppColors.error,
                  ),
                ),
                const SizedBox(height: 24),
                const Text('The four states'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final s in NodeState.values)
                      LessonNodeWidget(
                        state: s,
                        fractionFrom: s == NodeState.inProgress ? 0.4 : 1,
                        fractionTo: s == NodeState.inProgress ? 0.4 : 1,
                        size: 72,
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                Text('Fills, then finishes (step ${_step + 1} of 4)'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    LessonNodeWidget(
                      key: const ValueKey('demo'),
                      state: state,
                      fractionFrom: _shown,
                      fractionTo: target,
                      size: 82,
                      onTap: _advance,
                      onSettled: (v) => _shown = v,
                    ),
                    const SizedBox(width: 24),
                    Text(
                      '${state.name}  ${target.toStringAsFixed(2)}',
                      style: const TextStyle(fontFamily: 'JetBrains Mono'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
