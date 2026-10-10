import 'dart:ui' as ui;

import 'package:flutter/material.dart';
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

const _paper = Color(0xFFFDFCF8);
const _gridFine = Color(0x0E2C2C2C); // rgba(44,44,44,0.055)
const _gridBold = Color(0x1A2C2C2C); // rgba(44,44,44,0.10)
const _mute = Color(0xFFA8A196);

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
  const PassCardPainter(this.data);

  final PassCardData data;

  @override
  void paint(Canvas canvas, Size size) {
    // Scale the design to whatever the canvas is, exactly as the web renderer
    // does, so the preview and the saved image are the same drawing.
    canvas.save();
    canvas.scale(size.width / passCardWidth);

    _engineeringPaper(canvas);
    _claim(canvas);
    _index(canvas);
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

  void _index(Canvas canvas) {
    const cx = 700.0;
    // Was 72, which left only 16px of baseline between the heading and the
    // first chapter so the two read as one block (owner, 2026-10-06).
    const top = 104.0;
    const rowHeight = 25.6;
    const numberGap = 36.0;

    _text(
      canvas,
      'ALL FIFTEEN CHAPTERS. $passCardTotalQuestions QUESTIONS.',
      const Offset(cx, _pad + 16),
      AppTheme.mono(
        size: 13,
        weight: FontWeight.w600,
        color: AppColors.ink2,
      ).copyWith(letterSpacing: 2.2),
    );

    final rule = Paint()
      ..color = _gridBold
      ..strokeWidth = 1;

    for (var i = 0; i < passCardChapters.length; i++) {
      final y = top + i * rowHeight;
      _text(
        canvas,
        '${i + 1}'.padLeft(2, '0'),
        Offset(cx, y),
        AppTheme.mono(
          size: 13,
          weight: FontWeight.w600,
          color: AppColors.ember,
        ),
      );
      _text(
        canvas,
        passCardChapters[i],
        Offset(cx + numberGap, y),
        AppTheme.body(
          size: 17,
          color: AppColors.charcoal,
        ).copyWith(fontWeight: FontWeight.w500),
      );
      canvas.drawLine(
        Offset(cx, y + 8.5),
        const Offset(passCardWidth - _pad, 0).translate(0, y + 8.5),
        rule,
      );
    }
  }

  void _titleBlock(Canvas canvas) {
    const ty = passCardHeight - 78;
    canvas.drawLine(
      const Offset(_pad, ty),
      const Offset(passCardWidth - _pad, ty),
      Paint()
        ..color = AppColors.charcoal
        ..strokeWidth = 2.5,
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
        Offset(x, ty + 18),
        AppTheme.mono(
          size: 11,
          weight: FontWeight.w500,
          color: _mute,
        ).copyWith(letterSpacing: 1.8),
      );
      _text(
        canvas,
        cell.$2,
        Offset(x, ty + 41),
        AppTheme.display(
          size: 17,
          weight: FontWeight.w600,
        ).copyWith(color: AppColors.charcoal),
      );
      x += 232;
    }

    _text(
      canvas,
      'FE4RACCOONS',
      const Offset(passCardWidth - _pad, ty + 41),
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

  @override
  bool shouldRepaint(PassCardPainter old) =>
      old.data.name != data.name || old.data.when != data.when;
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

/// The card as a PNG, at export size.
///
/// Drawn straight onto a picture recorder rather than captured from the widget
/// tree: a RepaintBoundary capture would be at the phone's pixel ratio and at
/// whatever size the preview happened to be on screen, which is smaller than
/// the 2400px the social networks want.
Future<ui.Image> renderPassCard(PassCardData data) async {
  await passCardFontsReady();
  const scale = passCardExportScale;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  PassCardPainter(
    data,
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

  @override
  void initState() {
    super.initState();
    passCardFontsReady().then((_) {
      if (mounted) setState(() => _fontsReady = true);
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
        painter: PassCardPainter(widget.data),
      ),
    );
  }
}
