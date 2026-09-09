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

/// Ember measures L* 59 against forest's L* 46, and carries more than twice
/// forest's chroma. That gap is why the two do not sit together, and it is
/// what these candidates close: each accent below was chosen to land on
/// forest's own lightness, so neither colour shouts over the other.
///
/// Clay is ember's own hue pulled down to forest's weight. Deep blue is the
/// brand's informational colour, likewise. Both are drawn against a plain
/// untouched node, because the accent then appears once on the whole map and
/// says "you are here" without competing with anything.

/// Ember at full strength, for reference: the structure without the recolour.
NodeSkin withEmber(NodeState state) => switch (state) {
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
  NodeState.notStarted => _plainUntouched,
  NodeState.notBuilt => _flatNotBuilt,
};

/// Clay: ember's hue at forest's weight. L* 44, chroma 107.
NodeSkin withClay(NodeState state) => switch (state) {
  NodeState.cleared => const NodeSkin(
    AppColors.forest,
    Color(0xFF23624B),
    Colors.white,
    Icons.check_rounded,
  ),
  NodeState.inProgress => const NodeSkin(
    Color(0xFFA15236),
    Color(0xFF86402A),
    Colors.white,
    Icons.play_arrow_rounded,
    ring: Colors.white,
  ),
  NodeState.notStarted => _plainUntouched,
  NodeState.notBuilt => _flatNotBuilt,
};

/// Deep blue: the brand's informational hue at forest's weight. L* 45.
NodeSkin withBlue(NodeState state) => switch (state) {
  NodeState.cleared => const NodeSkin(
    AppColors.forest,
    Color(0xFF23624B),
    Colors.white,
    Icons.check_rounded,
  ),
  NodeState.inProgress => const NodeSkin(
    Color(0xFF2F6E9E),
    Color(0xFF255880),
    Colors.white,
    Icons.play_arrow_rounded,
    ring: Colors.white,
  ),
  NodeState.notStarted => _plainUntouched,
  NodeState.notBuilt => _flatNotBuilt,
};

/// Clay again, but untouched keeps a tint of it rather than going white, so
/// the map stays warm instead of going pale.
NodeSkin clayRamp(NodeState state) => switch (state) {
  NodeState.cleared => const NodeSkin(
    AppColors.forest,
    Color(0xFF23624B),
    Colors.white,
    Icons.check_rounded,
  ),
  NodeState.inProgress => const NodeSkin(
    Color(0xFFA15236),
    Color(0xFF86402A),
    Colors.white,
    Icons.play_arrow_rounded,
    ring: Colors.white,
  ),
  NodeState.notStarted => const NodeSkin(
    Color(0xFFF0DAD0),
    Color(0xFFE0C4B6),
    Color(0xFF8A4630),
    Icons.play_arrow_rounded,
  ),
  NodeState.notBuilt => _flatNotBuilt,
};

const _plainUntouched = NodeSkin(
  AppColors.white,
  Color(0xFFCDBFA8),
  AppColors.charcoal,
  Icons.play_arrow_rounded,
);

const _flatNotBuilt = NodeSkin(
  Color(0xFFF4EEE3),
  Color(0xFFEDE5D7),
  Color(0xFFCFC5B4),
  Icons.horizontal_rule_rounded,
);

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
                const SizedBox(height: 4),
                const Divider(color: AppColors.line),
                row('EMBER, L* 59', withEmber),
                const SizedBox(height: 4),
                const Divider(color: AppColors.line),
                row('CLAY, L* 44', withClay),
                const SizedBox(height: 4),
                const Divider(color: AppColors.line),
                row('DEEP BLUE, L* 45', withBlue),
                const SizedBox(height: 4),
                const Divider(color: AppColors.line),
                row('CLAY, WARM UNTOUCHED', clayRamp),
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
