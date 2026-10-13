import 'package:flutter/material.dart';

/// The raccoon from the app icon, peeking over an edge: ears, the top of
/// the head, the mask and the nose, nothing below.
///
/// The artwork is traced from the icon itself (design/icon-master-1024.png),
/// not redrawn: a hand-drawn version shipped in build 1099 and the owner
/// could see its proportions were off. The trace keeps every shape exact and
/// only snaps the colors to cream and charcoal.
///
/// It is the only pose the mascot has. Put it AFTER the surface it peeks
/// over in a Stack, with its top at [-baseline] from that surface's top: the
/// head then ends on the edge and the nose rests over it, as it rests on the
/// 4 in the icon.
class RaccoonPeek extends StatelessWidget {
  const RaccoonPeek({super.key});

  static const _asset = 'assets/brand/raccoon_peek.png';

  static const width = 96.0;

  /// The traced crop is 479 by 222 at the icon's scale.
  static const height = width * 222 / 479;

  /// From the top of the artwork to the line the head stands on (185 of
  /// 222 in the icon). Everything below it is the nose.
  static const baseline = height * 185 / 222;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _asset,
      width: width,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'The FE for Raccoons raccoon',
    );
  }
}
