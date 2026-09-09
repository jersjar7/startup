import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/games/lesson_node.dart';

/// Draws the four node states twice: as they ship today, and as I proposed
/// changing them. A claim about which reads better is not settleable by
/// argument, so this exists to settle it by looking.
Future<void> _fonts() async {
  final flutter =
      Platform.environment['FLUTTER_ROOT'] ?? '/opt/homebrew/share/flutter';
  final icons = File(
    '$flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (icons.existsSync()) {
    await (FontLoader('MaterialIcons')
          ..addFont(Future.value(icons.readAsBytesSync().buffer.asByteData())))
        .load();
  }
  final dir = Directory('assets/fonts');
  if (!dir.existsSync()) return;
  for (final family in const {
    'DM Sans': 'DMSans',
    'Inter': 'Inter',
    'JetBrains Mono': 'JetBrainsMono',
  }.entries) {
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains(family.value));
    if (files.isEmpty) continue;
    final loader = FontLoader(family.key);
    for (final f in files) {
      loader.addFont(Future.value(f.readAsBytesSync().buffer.asByteData()));
    }
    await loader.load();
  }
}

/// Proposal A: untouched goes quiet, in progress becomes the one loud thing.
NodeSkin proposalA(NodeState state) => switch (state) {
  NodeState.cleared => const NodeSkin(
    AppColors.forest,
    Color(0xFF23624B),
    Colors.white,
    Icons.check_rounded,
    ring: Color(0x66FFFFFF),
  ),
  NodeState.inProgress => const NodeSkin(
    AppColors.emberBg,
    Color(0xFFE9CDBF),
    AppColors.ember,
    Icons.play_arrow_rounded,
    ring: AppColors.ember,
  ),
  NodeState.notStarted => const NodeSkin(
    AppColors.white,
    Color(0xFFE7DCCB),
    AppColors.ink3,
    Icons.play_arrow_rounded,
  ),
  NodeState.notBuilt => const NodeSkin(
    Color(0xFFF2EADC),
    Color(0xFFE3D8C6),
    Color(0xFFC4BAA8),
    Icons.horizontal_rule_rounded,
  ),
};

/// Proposal B: four states on a scale of WEIGHT rather than of hue. Untouched
/// is outlined and confident, not greyed, because nothing locks and a greyed
/// node lies about that. The one lesson underway is the only filled ember on
/// the map. Finished is filled green. Not built is flat.
NodeSkin proposalB(NodeState state) => switch (state) {
  NodeState.cleared => const NodeSkin(
    AppColors.forest,
    Color(0xFF23624B),
    Colors.white,
    Icons.check_rounded,
  ),
  NodeState.inProgress => const NodeSkin(
    AppColors.ember,
    Color(0xFFC85A31),
    Colors.white,
    Icons.play_arrow_rounded,
    ring: Colors.white,
  ),
  NodeState.notStarted => const NodeSkin(
    AppColors.white,
    Color(0xFFCDBFA8),
    AppColors.charcoal,
    Icons.play_arrow_rounded,
  ),
  NodeState.notBuilt => const NodeSkin(
    Color(0xFFF4EEE3),
    Color(0xFFEDE5D7),
    Color(0xFFCFC5B4),
    Icons.horizontal_rule_rounded,
  ),
};

/// Proposal C: one hue, three saturations. The owner's suggestion. Untouched
/// keeps the brand's warmth at low saturation so it still reads as inviting
/// rather than switched off; the lesson underway is the only fully saturated
/// ember on the map; finished moves to forest.
NodeSkin proposalC(NodeState state) => switch (state) {
  NodeState.cleared => const NodeSkin(
    AppColors.forest,
    Color(0xFF23624B),
    Colors.white,
    Icons.check_rounded,
  ),
  NodeState.inProgress => const NodeSkin(
    AppColors.ember,
    Color(0xFFC85A31),
    Colors.white,
    Icons.play_arrow_rounded,
    ring: Colors.white,
  ),
  NodeState.notStarted => const NodeSkin(
    Color(0xFFF7CDB8),
    Color(0xFFE8B79E),
    Color(0xFFA8461F),
    Icons.play_arrow_rounded,
  ),
  NodeState.notBuilt => const NodeSkin(
    Color(0xFFF4EEE3),
    Color(0xFFEDE5D7),
    Color(0xFFCFC5B4),
    Icons.horizontal_rule_rounded,
  ),
};

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await _fonts();
  });

  testWidgets('the four states, both ways', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const states = [
      (NodeState.notStarted, 0.0, 'Untouched'),
      (NodeState.inProgress, 0.0, 'Started,\nnothing cleared'),
      (NodeState.inProgress, 0.34, 'One of three'),
      (NodeState.cleared, 1.0, 'Finished'),
      (NodeState.notBuilt, 0.0, 'Not built'),
    ];

    Widget row(String title, NodeSkin? Function(NodeState) skin) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
          child: Text(title, style: AppTheme.overline(color: AppColors.ink2)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (state, fraction, label) in states)
              SizedBox(
                width: 70,
                child: Column(
                  children: [
                    LessonNodeWidget(
                      state: state,
                      fractionFrom: fraction,
                      fractionTo: fraction,
                      size: 58,
                      skin: skin(state),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: AppTheme.mono(size: 9, color: AppColors.ink3),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppColors.cream,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                row('AS IT SHIPS TODAY', (_) => null),
                const SizedBox(height: 6),
                const Divider(color: AppColors.line),
                row('PROPOSAL A: UNTOUCHED GOES QUIET', proposalA),
                const SizedBox(height: 6),
                const Divider(color: AppColors.line),
                row('PROPOSAL B: A SCALE OF WEIGHT', proposalB),
                const SizedBox(height: 6),
                const Divider(color: AppColors.line),
                row('PROPOSAL C: ONE HUE, THREE SATURATIONS', proposalC),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 60)),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/00-map/node-states.png'),
    );
  });
}
