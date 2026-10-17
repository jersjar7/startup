import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';

/// The student's choice from the account sheet (owner, 2026-10-17:
/// "automatic plus a choice"). Automatic follows the phone.
enum AppearanceChoice { automatic, light, dark }

/// The appearance choice, kept on the phone, and what it resolves to.
///
/// [ThemeModeHost] listens to [choice] and to the phone's own setting, and
/// when the answer changes it flips [AppPalette.dark] and asks the whole app
/// to build and paint again. Nothing closes or loses its place: a sheet open
/// on the choice stays open while the app turns dark around it.
abstract final class Appearance {
  static const _key = 'appearance';

  static final choice = ValueNotifier<AppearanceChoice>(
    AppearanceChoice.automatic,
  );

  static Future<void> load() async {
    try {
      final saved = (await SharedPreferences.getInstance()).getString(_key);
      choice.value = AppearanceChoice.values.firstWhere(
        (c) => c.name == saved,
        orElse: () => AppearanceChoice.automatic,
      );
    } catch (_) {}
  }

  static Future<void> set(AppearanceChoice c) async {
    choice.value = c;
    try {
      await (await SharedPreferences.getInstance()).setString(_key, c.name);
    } catch (_) {}
  }

  /// Dark for this choice when the phone is in [platform].
  static bool resolve(AppearanceChoice c, Brightness platform) => switch (c) {
    AppearanceChoice.light => false,
    AppearanceChoice.dark => true,
    AppearanceChoice.automatic => platform == Brightness.dark,
  };
}

/// Sits at the top of the app and keeps [AppPalette.dark] right.
class ThemeModeHost extends StatefulWidget {
  const ThemeModeHost({super.key, required this.child});

  final Widget child;

  @override
  State<ThemeModeHost> createState() => _ThemeModeHostState();
}

class _ThemeModeHostState extends State<ThemeModeHost>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Appearance.choice.addListener(_update);
    _apply(_resolve(), repaint: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Appearance.choice.removeListener(_update);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() => _update();

  bool _resolve() => Appearance.resolve(
    Appearance.choice.value,
    WidgetsBinding.instance.platformDispatcher.platformBrightness,
  );

  void _update() {
    final dark = _resolve();
    if (dark != AppPalette.dark) _apply(dark, repaint: true);
  }

  void _apply(bool dark, {required bool repaint}) {
    AppPalette.dark = dark;
    // The clock, battery and signal over the app: light on a dark ground.
    SystemChrome.setSystemUIOverlayStyle(
      dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
    if (!repaint) return;
    setState(() {});
    // A box decoration keeps the paint it made the first time, colour and
    // all, and the same const decoration compares equal in both modes, so
    // nothing else tells it to remake it (measured: a rounded tile stayed
    // its day colour while a plain coloured box turned). Setting it to
    // something else and back makes it start again.
    void reset(Element e) {
      if (e is RenderObjectElement) {
        final box = e.renderObject;
        if (box is RenderDecoratedBox) {
          final d = box.decoration;
          box.decoration = const BoxDecoration();
          box.decoration = d;
        } else if (box is RenderParagraph) {
          // Text (and every Icon, which is text) keeps the laid-out
          // paragraph its colours were baked into, and an identical span
          // never asks for a new one.
          final t = box.text;
          box.text = const TextSpan();
          box.text = t;
        } else if (box is RenderEditable) {
          final t = box.text;
          box.text = const TextSpan();
          box.text = t;
        }
      }
      e.visitChildren(reset);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(reset);
    // Every colour is read when it is used, so everything already built has
    // to build, lay out and paint again. Reassembly does exactly that, in a
    // release build too, without disposing a single State, so the screen
    // and anything open over it stay where they are.
    unawaited(WidgetsBinding.instance.reassembleApplication());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
