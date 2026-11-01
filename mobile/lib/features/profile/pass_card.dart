import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// The pass card, drawn on the phone.
///
/// The mirror of `src/data/passCard.js` and `src/components/passCard/
/// drawPassCard.js`. There are two renderers because there are two surfaces and
/// no shared drawing runtime, and they have to produce the same image, so every
/// number here matches that file exactly. A change on one side is a change on
/// both. See docs/EXAM-OUTCOME-AND-PASS-CARD.md section 4.3.
///
/// Nothing on the card is per person except the name and the month. Bars that
/// looked like a personal record but were the same for everybody would make
/// every card posted to LinkedIn claim a study record its owner never had.

/// NAMES ONLY. There are deliberately no question counts here.
///
/// The counts in the web's src/data/chapters.js are the NCEES FE Civil
/// specification effective January 2014, superseded in July 2020, so printing
/// them on something a student publishes under their own name would put a
/// retired figure in public. The names are stable and are what the app teaches.
///
/// Last checked: 2026-10-06.
const passCardChapters = <String>[
  'Mathematics',
  'Probability & Statistics',
  'Ethics & Professional Practice',
  'Engineering Economics',
  'Statics',
  'Dynamics',
  'Mechanics of Materials',
  'Materials',
  'Fluid Mechanics',
  'Surveying',
  'Water Resources & Env.',
  'Structural Engineering',
  'Geotechnical Engineering',
  'Transportation Engineering',
  'Construction Engineering',
];

/// Both our sources and the NCEES document agree on the total, so it is safe to
/// print even though the per-chapter split is not.
const passCardTotalQuestions = 110;

/// The design size, in design units. Everything scales from it, so one painter
/// draws the preview and the export with no second set of numbers.
///
/// 1200 x 627 is the link-preview ratio LinkedIn, X and Facebook all crop to.
const passCardWidth = 1200.0;
const passCardHeight = 627.0;
const passCardExportScale = 2.0;
const _pad = 52.0;

const _paper = Color(
  0xFFFDFCF8,
); // the pass card is an image, light in both modes
const _gridFine = Color(0x0E2C2C2C); // rgba(44,44,44,0.055)
const _gridBold = Color(0x1A2C2C2C); // rgba(44,44,44,0.10)
const _mute = Color(0xFFA8A196);
const _soft = Color(0xFF6B6358); // CARD_INK.soft

/// A warm ember light in the top right corner, so the card is not flat
/// (owner, 2026-10-31). An ellipse centred at (cx, cy) with radii (rx, ry), all
/// as fractions of the card, fading from the ink to clear. CARD.glow.
const _glowCx = 0.92;
const _glowCy = 0.10;
const _glowRx = 0.50;
const _glowRy = 0.60;
const _glowInk = Color(0x2EE8683A); // rgba(232,104,58,0.18)
const _glowClear = Color(0x00E8683A);

/// The right column: the fifteen chapters as a stack of books (owner,
/// 2026-10-31), chapter 15 on top with the raccoon peeking over it, chapter 1
/// at the bottom. Replaced a plain list. CARD.stack.
abstract final class PassCardStack {
  static const x = 640.0;
  static const top = 94.0;
  static const width = 510.0;
  static const bookHeight = 30.0;
  static const overlap = 0.04;
  static const radius = 6.0;
  static const padLeft = 16.0;
  static const numberGap = 26.0;
  static const bandsFromRight = [22.0, 14.0];
  static const bandWidth = 3.0;
  static const bandInset = 0.24;
  static const captionX = 640.0;
  static const captionY = 579.0;
  static const peekWidth = 118.0;
  static const peekAlong = 0.70;
  static const peekSeat = 0.835;

  /// The vertical distance from one book's top to the next one's.
  static const step = bookHeight * (1 - overlap);
}

/// The title block, read the way a drawing sheet is read. It runs under the
/// left column only; the stack takes the right. CARD.titleBlock.
const passCardTitleFromBottom = 78.0;
const passCardTitleRuleEnd = 580.0;
const _titleRuleWidth = 2.5;
const _titleCellPitch = 180.0;
const _titleLabelY = 18.0;
const _titleValueY = 41.0;

/// A book cover. [band] is the two binding lines near the spine's end.
class PassCardCover {
  const PassCardCover(this.fill, this.text, this.band);
  final Color fill;
  final Color text;
  final Color band;
}

/// BOOK_COVERS: charcoal, cream, sand, and ember for the top book only.
const _charcoalCover = PassCardCover(
  Color(0xFF2C2C2C),
  Color(0xFFFFF9F0),
  Color(0x4DFFF9F0), // rgba(255,249,240,0.30)
);
const _creamCover = PassCardCover(
  Color(0xFFFFFDF8),
  Color(0xFF2C2C2C),
  Color(0x382C2C2C), // rgba(44,44,44,0.22)
);
const _sandCover = PassCardCover(
  Color(0xFFEADFCB),
  Color(0xFF2C2C2C),
  Color(0x382C2C2C), // rgba(44,44,44,0.22)
);
const _emberCover = PassCardCover(
  Color(0xFFE8683A),
  Color(0xFFFFFFFF),
  Color(0x73FFFFFF), // rgba(255,255,255,0.45)
);

/// One book: its share of the stack's width ([w], percent), a nudge right
/// ([dx]), a tilt in degrees and a cover.
class PassCardBook {
  const PassCardBook(this.w, this.dx, this.tilt, this.cover);
  final double w;
  final double dx;
  final double tilt;
  final PassCardCover cover;
}

/// BOOKS: one per chapter, in chapter order (index 0 is chapter 1, drawn at
/// the bottom). Hand-placed so the stack looks stacked by a person.
const passCardBooks = <PassCardBook>[
  PassCardBook(86, 22, -1.1, _charcoalCover),
  PassCardBook(92, 6, 0.8, _creamCover),
  PassCardBook(88, 14, -0.5, _sandCover),
  PassCardBook(95, 0, 0.4, _charcoalCover),
  PassCardBook(84, 28, -0.9, _creamCover),
  PassCardBook(90, 10, 0.6, _sandCover),
  PassCardBook(93, 4, -0.3, _charcoalCover),
  PassCardBook(87, 18, 0.7, _creamCover),
  PassCardBook(96, 0, -0.4, _sandCover),
  PassCardBook(85, 24, 0.9, _charcoalCover),
  PassCardBook(91, 8, -0.6, _creamCover),
  PassCardBook(89, 16, 0.3, _sandCover),
  PassCardBook(94, 2, -0.7, _charcoalCover),
  PassCardBook(88, 12, 0.5, _creamCover),
  PassCardBook(97, 0, -0.2, _emberCover),
];

/// What the card says. The only two things that vary.
class PassCardData {
  const PassCardData({required this.name, required this.when});

  /// Null when the account has no name. Account creation has never collected
  /// one, so this is the ordinary case and the caller has to ask before
  /// drawing. Never falls back to the email address: this is the one thing
  /// they will publish under their own identity.
  final String? name;
  final String when;

  bool get hasName => name != null && name!.isNotEmpty;

  /// "EIT" is appended here, never typed, so nobody has to know the
  /// abbreviation to get it right.
  static PassCardData from({
    String? firstName,
    String? lastName,
    DateTime? answeredAt,
    DateTime? now,
  }) {
    final full = [firstName, lastName]
        .where((s) => s != null && s.trim().isNotEmpty)
        .map((s) => s!.trim())
        .join(' ');
    final when = answeredAt ?? now ?? DateTime.now();
    return PassCardData(
      name: full.isEmpty ? null : '$full, EIT',
      when: '${_months[when.month - 1]} ${when.year}',
    );
  }
}

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

class PassCardPainter extends CustomPainter {
  const PassCardPainter(this.data, {this.peek});

  final PassCardData data;

  /// The raccoon, seated on the top book. Without it the stack is drawn
  /// alone, as the web does when the image fails to load.
  final ui.Image? peek;

  @override
  void paint(Canvas canvas, Size size) {
    // The card is an image people post, so it is always the light design, even
    // when the phone is in dark mode (owner, 2026-11-01). Every themed token it
    // uses resolves while painting, so pin the palette to day for the length
    // of this paint and put it back after.
    final wasDark = AppPalette.dark;
    AppPalette.dark = false;
    try {
      _paintCard(canvas, size);
    } finally {
      AppPalette.dark = wasDark;
    }
  }

  void _paintCard(Canvas canvas, Size size) {
    // Scale the design to whatever the canvas is, exactly as the web renderer
    // does, so the preview and the saved image are the same drawing.
    final scale = size.width / passCardWidth;
    canvas.save();
    canvas.scale(scale);

    _engineeringPaper(canvas);
    _glow(canvas);
    _claim(canvas);
    _bookStack(canvas, scale);
    _caption(canvas);
    _titleBlock(canvas);

    canvas.restore();
  }

  void _engineeringPaper(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, passCardWidth, passCardHeight),
      Paint()..color = _paper,
    );
    for (final grid in const [(24.0, _gridFine), (120.0, _gridBold)]) {
      final paint = Paint()
        ..color = grid.$2
        ..strokeWidth = 1;
      for (var x = 0.0; x <= passCardWidth; x += grid.$1) {
        canvas.drawLine(Offset(x, 0), Offset(x, passCardHeight), paint);
      }
      for (var y = 0.0; y <= passCardHeight; y += grid.$1) {
        canvas.drawLine(Offset(0, y), Offset(passCardWidth, y), paint);
      }
    }
  }

  void _claim(Canvas canvas) {
    _text(
      canvas,
      'FUNDAMENTALS OF ENGINEERING',
      Offset(_pad, _pad + 16),
      AppTheme.mono(
        size: 15,
        weight: FontWeight.w700,
        color: AppColors.ember,
      ).copyWith(letterSpacing: 2.6),
    );

    final headline = AppTheme.display(
      size: 84,
      weight: FontWeight.w800,
    ).copyWith(height: 1.0, letterSpacing: -3.4, color: AppColors.charcoal);
    _text(canvas, 'FE Civil', Offset(_pad - 4, _pad + 108), headline);
    _text(canvas, 'passed.', Offset(_pad - 4, _pad + 188), headline);

    // A card with no name is a bug upstream, not something to paper over here.
    // Drawing nothing is louder than drawing a placeholder, and far better than
    // drawing an email address.
    if (data.hasName) {
      _text(
        canvas,
        data.name!,
        Offset(_pad - 2, _pad + 252),
        AppTheme.display(
          size: 37,
          weight: FontWeight.w700,
        ).copyWith(color: AppColors.charcoal, letterSpacing: -1.2),
      );
    }

    _text(
      canvas,
      'Prepared with FE for Raccoons',
      Offset(_pad - 1, _pad + 283),
      AppTheme.body(size: 17, color: _mute),
    );
  }

  void _glow(Canvas canvas) {
    const w = passCardWidth;
    const h = passCardHeight;
    const r = _glowRx * w;
    canvas.save();
    canvas.translate(_glowCx * w, _glowCy * h);
    canvas.scale(1, _glowRy * h / r);
    canvas.drawRect(
      const Rect.fromLTRB(-r, -r, r, r),
      Paint()
        ..shader = ui.Gradient.radial(Offset.zero, r, const [
          _glowInk,
          _glowClear,
        ]),
    );
    canvas.restore();
  }

  /// The fifteen chapters as a stack of books, chapter 15 on top. Each book is
  /// drawn in its own tilted frame; lower books are drawn later so they sit
  /// over the edge of the one above, as a real stack would.
  ///
  /// [scale] is the design-to-pixel scale. Canvas 2D does not transform shadow
  /// offsets or blur, so on the web they are in output pixels at every size;
  /// dividing by the scale keeps this shadow the same as that one.
  void _bookStack(Canvas canvas, double scale) {
    const h = PassCardStack.bookHeight;
    final n = passCardChapters.length;
    for (var k = 0; k < n; k++) {
      final i = n - 1 - k; // chapter index, top book first
      final b = passCardBooks[i];
      final c = b.cover;
      final w = PassCardStack.width * b.w / 100;
      final x = PassCardStack.x + b.dx;
      final y = PassCardStack.top + k * PassCardStack.step;

      canvas.save();
      canvas.translate(x + w / 2, y + h / 2);
      canvas.rotate(b.tilt * math.pi / 180);
      canvas.translate(-w / 2, -h / 2);

      final cover = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        const Radius.circular(PassCardStack.radius),
      );

      // Cover, with a soft shadow under it (shadowBlur 10, offset 3).
      canvas.drawRRect(
        cover.shift(Offset(0, 3 / scale)),
        Paint()
          ..color =
              const Color(0x292C2C2C) // rgba(44,44,44,0.16)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 / scale),
      );
      canvas.drawRRect(cover, Paint()..color = c.fill);

      // Rounded spine: light along the top edge, dark along the bottom.
      canvas.drawRRect(
        cover,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset.zero,
            const Offset(0, h),
            const [
              Color(0x29FFFFFF),
              Color(0x00FFFFFF),
              Color(0x00000000),
              Color(0x29000000),
            ],
            const [0, 0.3, 0.7, 1],
          ),
      );

      final band = Paint()..color = c.band;
      for (final fromRight in PassCardStack.bandsFromRight) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              w - fromRight,
              h * PassCardStack.bandInset,
              PassCardStack.bandWidth,
              h * (1 - 2 * PassCardStack.bandInset),
            ),
            const Radius.circular(1.5),
          ),
          band,
        );
      }

      _textMiddle(
        canvas,
        '${i + 1}'.padLeft(2, '0'),
        const Offset(PassCardStack.padLeft, h / 2 + 1),
        AppTheme.mono(
          size: 10.5,
          weight: FontWeight.w700,
          color: c.text.withValues(alpha: 0.6),
        ),
      );
      _textMiddle(
        canvas,
        passCardChapters[i].toUpperCase(),
        const Offset(
          PassCardStack.padLeft + PassCardStack.numberGap,
          h / 2 + 1,
        ),
        AppTheme.display(
          size: 12.5,
          weight: FontWeight.w700,
        ).copyWith(color: c.text, letterSpacing: 1.25),
      );

      final img = peek;
      if (k == 0 && img != null && img.width > 0) {
        const pw = PassCardStack.peekWidth;
        final ph = pw * img.height / img.width;
        canvas.drawImageRect(
          img,
          Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
          Rect.fromLTWH(
            w * PassCardStack.peekAlong - pw / 2,
            -ph * PassCardStack.peekSeat,
            pw,
            ph,
          ),
          Paint()..filterQuality = FilterQuality.high,
        );
      }
      canvas.restore();
    }
  }

  void _caption(Canvas canvas) {
    _text(
      canvas,
      'ALL FIFTEEN CHAPTERS. $passCardTotalQuestions QUESTIONS.',
      const Offset(PassCardStack.captionX, PassCardStack.captionY),
      AppTheme.mono(
        size: 12,
        weight: FontWeight.w600,
        color: _soft,
      ).copyWith(letterSpacing: 2),
    );
  }

  void _titleBlock(Canvas canvas) {
    const ty = passCardHeight - passCardTitleFromBottom;
    canvas.drawLine(
      const Offset(_pad, ty),
      const Offset(passCardTitleRuleEnd, ty),
      Paint()
        ..color = AppColors.charcoal
        ..strokeWidth = _titleRuleWidth,
    );

    var x = _pad;
    for (final cell in [
      ('DISCIPLINE', 'Civil Engineering'),
      ('RESULT', 'Pass'),
      ('DATE', data.when),
    ]) {
      _text(
        canvas,
        cell.$1,
        Offset(x, ty + _titleLabelY),
        AppTheme.mono(
          size: 11,
          weight: FontWeight.w500,
          color: _mute,
        ).copyWith(letterSpacing: 1.8),
      );
      _text(
        canvas,
        cell.$2,
        Offset(x, ty + _titleValueY),
        AppTheme.display(
          size: 17,
          weight: FontWeight.w600,
        ).copyWith(color: AppColors.charcoal),
      );
      x += _titleCellPitch;
    }

    _text(
      canvas,
      'FE4RACCOONS',
      const Offset(passCardWidth - _pad, ty + _titleValueY),
      AppTheme.display(
        size: 23,
        weight: FontWeight.w700,
      ).copyWith(color: AppColors.charcoal),
      align: TextAlign.right,
    );
  }

  /// Draws [text] with its BASELINE at [at], which is what canvas fillText does
  /// on the web. Positioning by the top and guessing the ascent from the font
  /// size, as this used to, put every line a few pixels out and the two
  /// renderers quietly disagreed.
  void _text(
    Canvas canvas,
    String text,
    Offset at,
    TextStyle style, {
    TextAlign align = TextAlign.left,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout();
    final ascent = tp.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    final dx = align == TextAlign.right ? -tp.width : 0.0;
    tp.paint(canvas, Offset(at.dx + dx, at.dy - ascent));
  }

  /// Draws [text] with its vertical middle at [at], which is what canvas
  /// fillText does on the web with textBaseline 'middle': halfway between the
  /// font's ascent and descent. Any line height on [style] is dropped, so the
  /// box measured is the font's own.
  void _textMiddle(Canvas canvas, String text, Offset at, TextStyle style) {
    final natural = TextStyle(
      fontFamily: style.fontFamily,
      fontFamilyFallback: style.fontFamilyFallback,
      fontSize: style.fontSize,
      fontWeight: style.fontWeight,
      fontStyle: style.fontStyle,
      color: style.color,
      letterSpacing: style.letterSpacing,
    );
    final tp = TextPainter(
      text: TextSpan(text: text, style: natural),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(at.dx, at.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(PassCardPainter old) =>
      old.data.name != data.name ||
      old.data.when != data.when ||
      old.peek != peek;
}

/// Wait for the brand faces before drawing anything that is kept.
///
/// The fonts are bundled as assets and loaded by google_fonts on first use,
/// asynchronously. A widget that asks for one before it has landed rebuilds
/// when it arrives; a CustomPainter does not, and an image exported in that
/// window is saved with every DM Sans and JetBrains Mono glyph as an empty box.
/// The web renderer has the same hazard and waits on document.fonts.ready for
/// the same reason.
///
/// Never allowed to throw. A font that will not resolve should cost them a
/// slightly plainer card, not the card.
Future<void> passCardFontsReady() async {
  try {
    await GoogleFonts.pendingFonts([
      AppTheme.display(weight: FontWeight.w800),
      AppTheme.display(weight: FontWeight.w700),
      AppTheme.display(weight: FontWeight.w600),
      AppTheme.mono(weight: FontWeight.w700),
      AppTheme.mono(weight: FontWeight.w600),
      AppTheme.mono(weight: FontWeight.w500),
      AppTheme.body(),
      AppTheme.body(weight: FontWeight.w500),
    ]);
  } catch (_) {
    // Nothing useful to say and nothing to retry.
  }
}

/// The raccoon that peeks over the top book, decoded once. Resolves to null if
/// it cannot load, as the web's loadPeek does: the card is still theirs
/// without it.
Future<ui.Image?>? _peekLoad;
Future<ui.Image?> loadPassCardPeek() {
  return _peekLoad ??= () async {
    try {
      final bytes = await rootBundle.load('assets/brand/raccoon_peek.png');
      final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    }
  }();
}

/// The card as a PNG, at export size.
///
/// Drawn straight onto a picture recorder rather than captured from the widget
/// tree: a RepaintBoundary capture would be at the phone's pixel ratio and at
/// whatever size the preview happened to be on screen, which is smaller than
/// the 2400px the social networks want.
Future<ui.Image> renderPassCard(PassCardData data) async {
  await passCardFontsReady();
  final peek = await loadPassCardPeek();
  const scale = passCardExportScale;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  PassCardPainter(
    data,
    peek: peek,
  ).paint(canvas, const Size(passCardWidth * scale, passCardHeight * scale));
  return recorder.endRecording().toImage(
    (passCardWidth * scale).round(),
    (passCardHeight * scale).round(),
  );
}

/// The card on screen, which repaints once the faces land.
///
/// A plain CustomPaint would keep whatever it drew on its first frame, boxes
/// included, because nothing rebuilds a painter when a font finishes loading.
class PassCardView extends StatefulWidget {
  const PassCardView({super.key, required this.data});

  final PassCardData data;

  @override
  State<PassCardView> createState() => _PassCardViewState();
}

class _PassCardViewState extends State<PassCardView> {
  bool _fontsReady = false;
  ui.Image? _peek;

  @override
  void initState() {
    super.initState();
    passCardFontsReady().then((_) {
      if (mounted) setState(() => _fontsReady = true);
    });
    loadPassCardPeek().then((img) {
      if (mounted && img != null) setState(() => _peek = img);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: passCardWidth / passCardHeight,
      child: CustomPaint(
        // The key makes the repaint unmissable rather than relying on the
        // painter's own shouldRepaint, which compares data and not fonts.
        key: ValueKey(_fontsReady),
        painter: PassCardPainter(widget.data, peek: _peek),
      ),
    );
  }
}
