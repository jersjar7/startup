import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'pack_model.dart';
import 'pack_store.dart';
import 'update_needed_screen.dart';

/// Opens a pack game whose chapter has not been read yet (ADR 0033). The
/// chapter is already on the phone, so this waits only on reading it; the
/// game's plain background shows meanwhile.
class PackGameLoader extends StatefulWidget {
  const PackGameLoader({
    super.key,
    required this.id,
    required this.store,
    required this.fallback,
  });

  final String id;
  final PackStore store;

  /// What to show if the chapter cannot be read: the built-in game.
  final Widget Function() fallback;

  @override
  State<PackGameLoader> createState() => _PackGameLoaderState();
}

class _PackGameLoaderState extends State<PackGameLoader> {
  late final Future<PackGame?> _game = widget.store.open(widget.id);

  @override
  Widget build(BuildContext context) => FutureBuilder<PackGame?>(
    future: _game,
    builder: (context, snap) {
      if (snap.connectionState != ConnectionState.done) {
        return const Scaffold(backgroundColor: AppColors.fog);
      }
      final game = snap.data;
      if (game == null) return widget.fallback();
      return game.screen() ?? const UpdateNeededScreen();
    },
  );
}
