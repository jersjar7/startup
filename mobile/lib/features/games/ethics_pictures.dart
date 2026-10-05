// The pictures on the Ethics & Professional Practice concept sheets.
//
// A sheet is read picture first (owner's call, 2026-09-30): the drawing the
// student just played with, with one thing happening in it, then the idea in
// short steps, then the rule. Built from the same painters the games draw
// with; see mechanics_pictures.dart for the pattern and the shared
// ConceptPicture and ConceptPair tiles.
//
// Most of this chapter's games are answered in words, so most of these are
// small situation diagrams: who is above whom, which way the money runs,
// where a claim has to land. They draw the SITUATION the rule is about, so
// the rule has something to point at.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';
import 'contract_figures.dart';
import 'lifecycle_figures.dart';
import 'mechanics_pictures.dart' show ConceptPair, ConceptPicture;
import 'which_delivery_game.dart' show Delivery, boxesFor;

/// Every picture on this chapter's sheets, by the contact sheet's card name.
const ethicsPictures = <String, Widget Function()>{
  'public-first': publicFirstPicture,
  'escalation': escalationPicture,
  'proportion': proportionPicture,
  'competence': competencePicture,
  'consent': consentPicture,
  'claims': claimsPicture,
  'standing': standingPicture,
  'exemption': exemptionPicture,
  'holding-out': holdingOutPicture,
  'ladder': ladderPicture,
  'discipline': disciplinePicture,
  'sections': sectionsPicture,
  'formation': formationPicture,
  'risk': riskPicture,
  'delivery': deliveryPicture,
  'standard-of-care': standardOfCarePicture,
  'negligence': negligencePicture,
  'clocks': clocksPicture,
  'property': propertyPicture,
  'portfolio': portfolioPicture,
  'life-cycle': lifeCyclePicture,
};

// ---------------------------------------------------------------------------
// Obligations to the public

Widget publicFirstPicture() => const ConceptPicture(
  painter: _PodiumPainter(),
  caption:
      'who comes first when they pull different ways. The public is on top, always',
  height: 190,
);

Widget escalationPicture() => const ConceptPicture(
  painter: _LadderPainter(),
  caption:
      'one rung at a time: the person, then the firm, then the board. Skipping one is the mistake',
  height: 200,
);

Widget proportionPicture() => const ConceptPicture(
  painter: _DialPainter(),
  caption: 'the rule asks for one exact amount. Both sides of it are wrong',
  height: 195,
);

// ---------------------------------------------------------------------------
// Obligations to employers, clients and other licensees

Widget competencePicture() => const ConceptPicture(
  painter: _TwoGatesPainter(),
  caption:
      'a seal needs both gates open at once: your field, and your own direct control',
  height: 180,
);

Widget consentPicture() => const ConceptPicture(
  painter: _PayersPainter(),
  caption:
      'two people paying you about the same thing. Each one has to say yes, in writing',
  height: 190,
);

Widget claimsPicture() => const ConceptPicture(
  painter: _ShareOfWorkPainter(),
  caption:
      'the whole job, and the part that was actually yours. Claim the part',
  height: 170,
);

// ---------------------------------------------------------------------------
// Definitions and the practice of engineering

Widget standingPicture() => const ConceptPicture(
  painter: _BadgesPainter(),
  caption: 'two badges. Only the second one comes with a seal',
  height: 190,
);

Widget exemptionPicture() => const ConceptPicture(
  painter: _ChargePainter(),
  caption:
      'an unlicensed employee may do the work while a PE directs it and makes the final calls',
  height: 200,
);

Widget holdingOutPicture() => const ConceptPicture(
  painter: _TwoOffensesPainter(),
  caption:
      'two separate ways to break the law: doing the work, or wearing the title',
  height: 190,
);

// ---------------------------------------------------------------------------
// Licensure and discipline

Widget ladderPicture() => const ConceptPicture(
  painter: _YearsPainter(),
  caption: 'the years of experience the PE exam waits for, by degree',
  height: 190,
);

Widget disciplinePicture() => const ConceptPicture(
  painter: _GroundsPainter(),
  caption:
      'a felony always counts. A misdemeanor counts only if it involves dishonesty or the practice',
  height: 200,
);

Widget sectionsPicture() => const ConceptPicture(
  painter: _ForkPainter(),
  caption:
      'the first question is whether they hold a license. The two roads have different penalties',
  height: 200,
);

// ---------------------------------------------------------------------------
// Contracts

Widget formationPicture() => const ConceptPicture(
  painter: _FiveChecksPainter(),
  caption: 'five things make a deal. A notary is not one of them',
  height: 170,
);

Widget riskPicture() => const ConceptPicture(
  painter: CostBarPainter(
    priced: 100,
    actual: 118,
    pricedLabel: 'the fixed price',
    revealed: true,
  ),
  caption:
      'the job cost more than it was priced at. Somebody has to absorb the piece past the line',
  height: 170,
);

Widget deliveryPicture() => ConceptPair(
  left: DeliveryPainter(
    boxes: boxesFor(Delivery.designBidBuild),
    color: AppColors.charcoal,
  ),
  right: DeliveryPainter(
    boxes: boxesFor(Delivery.designBuild),
    color: AppColors.charcoal,
  ),
  leftCaption: 'design-bid-build: two lines out of the owner',
  rightCaption: 'design-build: one line, the designer underneath it',
  height: 190,
);

// ---------------------------------------------------------------------------
// Liability

Widget standardOfCarePicture() => const ConceptPicture(
  painter: _BandPainter(),
  caption:
      'the measure is the band a competent peer would land in. Not the top, and not below it',
  height: 190,
);

Widget negligencePicture() => const ConceptPicture(
  painter: _ChainPainter(),
  caption:
      'a claim is a chain of four links. One missing link and nothing pulls through',
  height: 160,
);

Widget clocksPicture() => const ConceptPicture(
  painter: TwoClocksPainter(
    from: 2006,
    to: 2030,
    completion: 2015,
    discovery: 2018,
    filed: 2020,
    reposeYears: 10,
    limitationYears: 3,
  ),
  caption: 'two windows on one line. The claim has to land inside both',
  height: 190,
);

// ---------------------------------------------------------------------------
// Intellectual property and sustainability

Widget propertyPicture() => const ConceptPicture(
  painter: _SortPainter(),
  caption:
      'one question splits the first two. the other two guard something else '
      'again',
  height: 230,
);

Widget portfolioPicture() => const ConceptPicture(
  painter: _FourBoxesPainter(
    titles: ['the invention', 'the name', 'the manual', 'the process'],
    notes: ['patent', 'trademark', 'copyright', 'trade secret'],
    hub: 'one product',
  ),
  caption: 'one product carries four assets, and each takes its own protection',
  height: 210,
);

Widget lifeCyclePicture() => const ConceptPicture(
  painter: StagesPainter(
    options: [
      Option('A', [40, 10, 55, 12]),
      Option('B', [58, 8, 20, 8]),
    ],
    revealed: true,
  ),
  caption:
      'two options, each split into what it costs at every stage of its life',
  height: 190,
);

// ---------------------------------------------------------------------------
// Shared drawing helpers

TextPainter _text(
  String s, {
  double size = 11,
  Color color = AppColors.charcoal,
  FontWeight? weight,
  double? maxWidth,
  TextAlign align = TextAlign.left,
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: s,
      style: AppTheme.mono(
        size: size,
        color: color,
      ).copyWith(fontWeight: weight),
    ),
    textDirection: TextDirection.ltr,
    textAlign: align,
    maxLines: 3,
  )..layout(maxWidth: maxWidth ?? double.infinity);
  return tp;
}

Paint _stroke(Color color, [double width = 2]) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

void _arrow(Canvas canvas, Offset from, Offset to, Paint paint) {
  canvas.drawLine(from, to, paint);
  final d = to - from;
  final len = d.distance;
  if (len < 1) return;
  final u = d / len;
  final n = Offset(-u.dy, u.dx);
  final head = Path()
    ..moveTo(to.dx, to.dy)
    ..lineTo(to.dx - u.dx * 8 + n.dx * 4.5, to.dy - u.dy * 8 + n.dy * 4.5)
    ..lineTo(to.dx - u.dx * 8 - n.dx * 4.5, to.dy - u.dy * 8 - n.dy * 4.5)
    ..close();
  canvas.drawPath(head, Paint()..color = paint.color);
}

/// A rounded box with a label centered in it, in the chapter's tokens:
/// charcoal or cream fills, never an outline as the main shape.
void _box(
  Canvas canvas,
  Rect rect,
  String label, {
  Color fill = AppColors.charcoal,
  Color ink = AppColors.cream,
  double size = 11,
  String? note,
  double radius = 10,
}) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(rect, Radius.circular(radius)),
    Paint()..color = fill,
  );
  final tp = _text(
    label,
    size: size,
    color: ink,
    weight: FontWeight.w600,
    maxWidth: rect.width - 10,
    align: TextAlign.center,
  );
  final noteTp = note == null
      ? null
      : _text(
          note,
          size: 9.5,
          color: ink,
          maxWidth: rect.width - 10,
          align: TextAlign.center,
        );
  final total = tp.height + (noteTp == null ? 0 : noteTp.height + 3);
  var y = rect.center.dy - total / 2;
  inkLabel(canvas, tp, Offset(rect.center.dx - tp.width / 2, y));
  y += tp.height + 3;
  if (noteTp != null) {
    inkLabel(canvas, noteTp, Offset(rect.center.dx - noteTp.width / 2, y));
  }
}

void _check(Canvas canvas, Offset at, {bool ok = true, double r = 8}) {
  canvas.drawCircle(
    at,
    r,
    Paint()..color = ok ? AppColors.spring : AppColors.error,
  );
  final p = _stroke(AppColors.charcoal, 2.2);
  if (ok) {
    canvas.drawLine(
      at + Offset(-r * 0.45, 0),
      at + Offset(-r * 0.1, r * 0.4),
      p,
    );
    canvas.drawLine(
      at + Offset(-r * 0.1, r * 0.4),
      at + Offset(r * 0.5, -r * 0.4),
      p,
    );
  } else {
    canvas.drawLine(
      at + Offset(-r * 0.4, -r * 0.4),
      at + Offset(r * 0.4, r * 0.4),
      p,
    );
    canvas.drawLine(
      at + Offset(-r * 0.4, r * 0.4),
      at + Offset(r * 0.4, -r * 0.4),
      p,
    );
  }
}

// ---------------------------------------------------------------------------
// The painters

/// Who outranks whom: a podium with the public on the top step.
class _PodiumPainter extends CustomPainter {
  const _PodiumPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final base = size.height * 0.84;
    final steps = [
      ('the public', 1.0, AppColors.spring, AppColors.charcoal),
      ('the client', 0.62, AppColors.charcoal, AppColors.cream),
      ('the employer', 0.44, AppColors.charcoal, AppColors.cream),
      ('the schedule', 0.28, AppColors.ink2, AppColors.cream),
    ];
    final w = (size.width - 16 * 2 - 8 * 3) / 4;
    final tall = size.height * 0.62;
    for (final (i, (label, h, fill, ink)) in steps.indexed) {
      final left = 16 + i * (w + 8);
      final rect = Rect.fromLTRB(left, base - tall * h, left + w, base);
      _box(canvas, rect, label, fill: fill, ink: ink, radius: 8);
    }
    final t = _text(
      'first',
      size: 10,
      color: AppColors.forest,
      weight: FontWeight.w600,
    );
    inkLabel(
      canvas,
      t,
      Offset(16 + w / 2 - t.width / 2, base - tall - t.height - 4),
    );
    final u = _text('everything else', size: 10, color: AppColors.ink2);
    inkLabel(canvas, u, Offset(size.width - 16 - u.width, base + 6));
  }

  @override
  bool shouldRepaint(_PodiumPainter old) => false;
}

/// Three rungs and an arrow that climbs them one at a time; a dashed jump
/// straight to the top, crossed out.
class _LadderPainter extends CustomPainter {
  const _LadderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rungs = ['the person', 'the firm', 'the board'];
    final w = size.width * 0.34;
    final h = 30.0;
    final left = size.width * 0.12;
    final gap = (size.height - 24 - 3 * h) / 2;
    final rects = <Rect>[];
    for (final (i, label) in rungs.indexed) {
      final top = size.height - 12 - h - i * (h + gap);
      final rect = Rect.fromLTWH(left + i * 14, top, w, h);
      rects.add(rect);
      _box(
        canvas,
        rect,
        label,
        fill: i == 2 ? AppColors.spring : AppColors.charcoal,
        ink: i == 2 ? AppColors.charcoal : AppColors.cream,
        radius: 8,
      );
    }
    final up = _stroke(AppColors.forest, 2.5);
    for (var i = 0; i < 2; i++) {
      final from = Offset(rects[i].right + 12, rects[i].center.dy);
      final to = Offset(rects[i + 1].right + 12, rects[i + 1].center.dy + 2);
      _arrow(canvas, from, to, up);
    }
    final t = _text(
      'one rung, then the next',
      size: 10,
      color: AppColors.forest,
    );
    inkLabel(canvas, t, Offset(rects[0].left, rects[0].top - t.height - 6));
    // the jump straight to the top, crossed out
    final jumpX = size.width * 0.86;
    final jump = _stroke(AppColors.error, 1.5);
    var y = rects[0].center.dy;
    while (y > rects[2].center.dy + 8) {
      canvas.drawLine(Offset(jumpX, y), Offset(jumpX, y - 5), jump);
      y -= 10;
    }
    _check(
      canvas,
      Offset(jumpX, (rects[0].center.dy + rects[2].center.dy) / 2),
      ok: false,
    );
    final s = _text('skip', size: 9.5, color: AppColors.error);
    inkLabel(canvas, s, Offset(jumpX - s.width / 2, rects[0].center.dy + 8));
  }

  @override
  bool shouldRepaint(_LadderPainter old) => false;
}

/// A dial from too little to too much with the right amount marked.
class _DialPainter extends CustomPainter {
  const _DialPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * 0.42;
    final left = size.width * 0.1;
    final right = size.width * 0.9;
    canvas.drawLine(
      Offset(left, y),
      Offset(right, y),
      _stroke(AppColors.ink2, 4),
    );
    final mid = (left + right) / 2;
    canvas.drawCircle(Offset(mid, y), 13, Paint()..color = AppColors.spring);
    canvas.drawCircle(Offset(mid, y), 13, _stroke(AppColors.charcoal, 2));
    for (final x in [left + 22, right - 22]) {
      canvas.drawCircle(Offset(x, y), 7, Paint()..color = AppColors.error);
    }
    // What each end of the dial is, above the line.
    final e = _text('say nothing', size: 9.5, color: AppColors.ink2);
    inkLabel(canvas, e, Offset(left + 22 - e.width / 2, y - 26));
    final f = _text('resign', size: 9.5, color: AppColors.ink2);
    inkLabel(canvas, f, Offset(right - 22 - f.width / 2, y - 26));
    final c = _text(
      'the rule',
      size: 11,
      color: AppColors.charcoal,
      weight: FontWeight.w600,
    );
    inkLabel(canvas, c, Offset(mid - c.width / 2, y - 42));

    // The verdict on each end, below the line.
    final a = _text('too little', size: 10, color: AppColors.error);
    inkLabel(canvas, a, Offset(left + 22 - a.width / 2, y + 16));
    final b = _text('too much', size: 10, color: AppColors.error);
    inkLabel(canvas, b, Offset(right - 22 - b.width / 2, y + 16));

    // What the rule actually asks for, on its own line clear of both.
    final d = _text(
      'disclose it, and step out of that one decision',
      size: 9.5,
      color: AppColors.forest,
      maxWidth: size.width * 0.9,
      align: TextAlign.center,
    );
    inkLabel(canvas, d, Offset(mid - d.width / 2, size.height - 26));
  }

  @override
  bool shouldRepaint(_DialPainter old) => false;
}

/// The question that sorts a patent from a trade secret, drawn as the fork
/// it is, with the two protections that answer a different question again
/// underneath.
///
/// The sheet is titled for that one question, so four boxes in a grid left
/// the title's promise unkept.
class _SortPainter extends CustomPainter {
  const _SortPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.width / 2;
    final q = _text(
      'do you tell the world, or keep it quiet?',
      size: 10.5,
      color: AppColors.charcoal,
      weight: FontWeight.w600,
    );
    inkLabel(canvas, q, Offset(mid - q.width / 2, 8));

    // The fork.
    const forkTop = 28.0;
    const boxTop = 56.0;
    final boxW = size.width * 0.42;
    final leftC = mid - boxW / 2 - 8;
    final rightC = mid + boxW / 2 + 8;
    final line = _stroke(AppColors.ink3, 1.4);
    canvas.drawLine(Offset(mid, forkTop), Offset(mid, forkTop + 10), line);
    canvas.drawLine(
      Offset(leftC, forkTop + 10),
      Offset(rightC, forkTop + 10),
      line,
    );
    _arrow(
      canvas,
      Offset(leftC, forkTop + 10),
      Offset(leftC, boxTop - 2),
      line,
    );
    _arrow(
      canvas,
      Offset(rightC, forkTop + 10),
      Offset(rightC, boxTop - 2),
      line,
    );
    final yes = _text('tell it', size: 9, color: AppColors.ink2);
    inkLabel(canvas, yes, Offset(leftC - yes.width - 7, forkTop + 1));
    final no = _text('keep it quiet', size: 9, color: AppColors.ink2);
    inkLabel(canvas, no, Offset(rightC + 7, forkTop + 1));

    _box(
      canvas,
      Rect.fromCenter(
        center: Offset(leftC, boxTop + 24),
        width: boxW,
        height: 48,
      ),
      'patent',
      note: 'published, 20 years',
    );
    final secret = Rect.fromCenter(
      center: Offset(rightC, boxTop + 24),
      width: boxW,
      height: 48,
    );
    _box(
      canvas,
      secret,
      'trade secret',
      fill: AppColors.cream,
      ink: AppColors.charcoal,
      note: 'kept quiet, no clock',
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(secret, const Radius.circular(10)),
      _stroke(AppColors.charcoal, 1.5),
    );

    // The other two answer a different question.
    final divider = size.height - 74;
    canvas.drawLine(
      Offset(size.width * 0.06, divider),
      Offset(size.width * 0.94, divider),
      _stroke(AppColors.line, 1),
    );
    final other = _text(
      'these two guard what it is CALLED and what is WRITTEN',
      size: 9,
      color: AppColors.ink2,
    );
    inkLabel(canvas, other, Offset(mid - other.width / 2, divider + 5));

    _box(
      canvas,
      Rect.fromCenter(
        center: Offset(leftC, size.height - 26),
        width: boxW,
        height: 40,
      ),
      'trademark',
      note: 'the name',
    );
    final words = Rect.fromCenter(
      center: Offset(rightC, size.height - 26),
      width: boxW,
      height: 40,
    );
    _box(
      canvas,
      words,
      'copyright',
      fill: AppColors.cream,
      ink: AppColors.charcoal,
      note: 'the words',
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(words, const Radius.circular(10)),
      _stroke(AppColors.charcoal, 1.5),
    );
  }

  @override
  bool shouldRepaint(_SortPainter old) => false;
}

/// Two gates in a row that both have to be open before the seal.
class _TwoGatesPainter extends CustomPainter {
  const _TwoGatesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * 0.45;
    final w = size.width * 0.27;
    final h = 46.0;
    final g1 = Rect.fromCenter(
      center: Offset(size.width * 0.2, y),
      width: w,
      height: h,
    );
    final g2 = Rect.fromCenter(
      center: Offset(size.width * 0.5, y),
      width: w,
      height: h,
    );
    _box(canvas, g1, 'your field', note: 'education or experience', radius: 8);
    _box(canvas, g2, 'your charge', note: 'you directed it', radius: 8);
    _check(canvas, Offset(g1.right - 6, g1.top + 2));
    _check(canvas, Offset(g2.right - 6, g2.top + 2));
    final line = _stroke(AppColors.forest, 2.5);
    _arrow(canvas, Offset(g1.right + 4, y), Offset(g2.left - 4, y), line);
    _arrow(canvas, Offset(g2.right + 4, y), Offset(size.width * 0.72, y), line);
    final seal = Offset(size.width * 0.84, y);
    canvas.drawCircle(seal, 26, Paint()..color = AppColors.spring);
    canvas.drawCircle(seal, 20, _stroke(AppColors.charcoal, 2));
    final s = _text(
      'SEAL',
      size: 10,
      color: AppColors.charcoal,
      weight: FontWeight.w700,
    );
    inkLabel(canvas, s, seal - Offset(s.width / 2, s.height / 2));
    final t = _text('both, or no seal', size: 10, color: AppColors.ink2);
    inkLabel(
      canvas,
      t,
      Offset(size.width * 0.35 - t.width / 2, y + h / 2 + 12),
    );
  }

  @override
  bool shouldRepaint(_TwoGatesPainter old) => false;
}

/// Two payers, one engineer, and a written yes from each.
class _PayersPainter extends CustomPainter {
  const _PayersPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final you = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.72),
      width: 96,
      height: 40,
    );
    final a = Rect.fromCenter(
      center: Offset(size.width * 0.24, size.height * 0.24),
      width: 100,
      height: 40,
    );
    final b = Rect.fromCenter(
      center: Offset(size.width * 0.76, size.height * 0.24),
      width: 100,
      height: 40,
    );
    _box(canvas, a, 'payer A', note: 'the same job');
    _box(canvas, b, 'payer B', note: 'the same job');
    _box(canvas, you, 'you', fill: AppColors.spring, ink: AppColors.charcoal);
    final line = _stroke(AppColors.charcoal, 2);
    _arrow(
      canvas,
      Offset(a.center.dx, a.bottom + 2),
      Offset(you.left + 10, you.top - 2),
      line,
    );
    _arrow(
      canvas,
      Offset(b.center.dx, b.bottom + 2),
      Offset(you.right - 10, you.top - 2),
      line,
    );
    for (final x in [size.width * 0.33, size.width * 0.67]) {
      final tag = Rect.fromCenter(
        center: Offset(x, size.height * 0.5),
        width: 74,
        height: 20,
      );
      _box(
        canvas,
        tag,
        'yes, in writing',
        fill: AppColors.cream,
        ink: AppColors.forest,
        size: 8.5,
        radius: 10,
      );
    }
  }

  @override
  bool shouldRepaint(_PayersPainter old) => false;
}

/// The whole job as one long bar, and the piece of it that was yours.
class _ShareOfWorkPainter extends CustomPainter {
  const _ShareOfWorkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.08;
    final right = size.width * 0.92;
    final y = size.height * 0.5;
    final bar = Rect.fromLTRB(left, y - 16, right, y + 16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bar, const Radius.circular(8)),
      Paint()..color = AppColors.charcoal,
    );
    final mine = Rect.fromLTRB(
      left + (right - left) * 0.55,
      y - 16,
      left + (right - left) * 0.78,
      y + 16,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mine, const Radius.circular(8)),
      Paint()..color = AppColors.spring,
    );
    final w = _text(
      'the whole bridge',
      size: 10.5,
      color: AppColors.cream,
      weight: FontWeight.w600,
    );
    inkLabel(canvas, w, Offset(left + 12, y - w.height / 2));
    final m = _text(
      'your part',
      size: 10,
      color: AppColors.charcoal,
      weight: FontWeight.w600,
    );
    inkLabel(canvas, m, Offset(mine.center.dx - m.width / 2, y - m.height / 2));
    final say = _text(
      'say this',
      size: 10,
      color: AppColors.forest,
      weight: FontWeight.w600,
    );
    inkLabel(canvas, say, Offset(mine.center.dx - say.width / 2, y + 22));
    final not = _text(
      'not "I designed the bridge"',
      size: 10,
      color: AppColors.error,
    );
    inkLabel(canvas, not, Offset(left + 12, y - 22 - not.height));
  }

  @override
  bool shouldRepaint(_ShareOfWorkPainter old) => false;
}

/// An intern's badge and an engineer's badge, and the seal only the second has.
class _BadgesPainter extends CustomPainter {
  const _BadgesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * 0.46;
    final w = size.width * 0.36;
    final ei = Rect.fromCenter(
      center: Offset(size.width * 0.26, y),
      width: w,
      height: 70,
    );
    final pe = Rect.fromCenter(
      center: Offset(size.width * 0.7, y),
      width: w,
      height: 70,
    );
    _box(
      canvas,
      ei,
      'Engineer Intern',
      note: 'passed the FE\ncertified',
      fill: AppColors.cream,
      ink: AppColors.charcoal,
      radius: 12,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(ei, const Radius.circular(12)),
      _stroke(AppColors.charcoal, 2),
    );
    _box(
      canvas,
      pe,
      'Professional Engineer',
      note: 'passed both, the years\nlicensed',
      radius: 12,
    );
    // Above the badge, not on its top corner: the badge's own name fills it
    // corner to corner once those two words wrap, and the seal was landing
    // on the end of it.
    final seal = Offset(
      math.min(pe.right - 8, size.width - 17),
      math.max(16, pe.top - 16),
    );
    canvas.drawCircle(seal, 15, Paint()..color = AppColors.spring);
    canvas.drawCircle(seal, 10, _stroke(AppColors.charcoal, 1.8));
    final s = _text(
      'seal',
      size: 8,
      color: AppColors.charcoal,
      weight: FontWeight.w700,
    );
    inkLabel(canvas, s, seal - Offset(s.width / 2, s.height / 2));
    final line = _stroke(AppColors.ink2, 2);
    _arrow(canvas, Offset(ei.right + 4, y), Offset(pe.left - 4, y), line);
    final t = _text(
      'the PE exam, plus the years',
      size: 9.5,
      color: AppColors.ink2,
    );
    inkLabel(canvas, t, Offset((ei.right + pe.left) / 2 - t.width / 2, y + 44));
    final n = _text('no seal', size: 9.5, color: AppColors.error);
    inkLabel(
      canvas,
      n,
      Offset(ei.center.dx - n.width / 2, ei.top - n.height - 6),
    );
  }

  @override
  bool shouldRepaint(_BadgesPainter old) => false;
}

/// A licensed engineer over an unlicensed employee: the work flows up, the
/// direction and the final decisions flow down.
class _ChargePainter extends CustomPainter {
  const _ChargePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final pe = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.22),
      width: 150,
      height: 40,
    );
    final sub = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.76),
      width: 150,
      height: 40,
    );
    _box(canvas, pe, 'a licensed PE', note: 'in responsible charge');
    _box(
      canvas,
      sub,
      'the employee',
      note: 'calculations, drawings, checks',
      fill: AppColors.cream,
      ink: AppColors.charcoal,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(sub, const Radius.circular(10)),
      _stroke(AppColors.charcoal, 2),
    );
    final down = _stroke(AppColors.forest, 2.5);
    _arrow(
      canvas,
      Offset(size.width * 0.36, pe.bottom + 4),
      Offset(size.width * 0.36, sub.top - 4),
      down,
    );
    final up = _stroke(AppColors.ink2, 2);
    _arrow(
      canvas,
      Offset(size.width * 0.64, sub.top - 4),
      Offset(size.width * 0.64, pe.bottom + 4),
      up,
    );
    final a = _text(
      'direct control\nfinal decisions',
      size: 9.5,
      color: AppColors.forest,
    );
    inkLabel(
      canvas,
      a,
      Offset(
        size.width * 0.36 - a.width - 8,
        size.height * 0.49 - a.height / 2,
      ),
    );
    final b = _text('the work', size: 9.5, color: AppColors.ink2);
    inkLabel(
      canvas,
      b,
      Offset(size.width * 0.64 + 8, size.height * 0.49 - b.height / 2),
    );
  }

  @override
  bool shouldRepaint(_ChargePainter old) => false;
}

/// Two separate offenses: doing the work, and wearing the title.
class _TwoOffensesPainter extends CustomPainter {
  const _TwoOffensesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * 0.44;
    final w = size.width * 0.4;
    final work = Rect.fromCenter(
      center: Offset(size.width * 0.26, y),
      width: w,
      height: 78,
    );
    final title = Rect.fromCenter(
      center: Offset(size.width * 0.74, y),
      width: w,
      height: 78,
    );
    _box(
      canvas,
      work,
      'doing the work',
      note:
          'drawings, a spreadsheet,\nan app: judgment that\nreaches the public',
      radius: 12,
    );
    _box(
      canvas,
      title,
      'wearing the title',
      note: 'a card, a sign, a website\nthat says P.E.',
      radius: 12,
    );
    _check(canvas, Offset(work.left + 4, work.top + 4), ok: false);
    _check(canvas, Offset(title.left + 4, title.top + 4), ok: false);
    final t = _text(
      'either one is a violation on its own',
      size: 10,
      color: AppColors.error,
    );
    inkLabel(canvas, t, Offset(size.width / 2 - t.width / 2, work.bottom + 10));
  }

  @override
  bool shouldRepaint(_TwoOffensesPainter old) => false;
}

/// Three bars of years, one per degree, all ending at the same exam.
class _YearsPainter extends CustomPainter {
  const _YearsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rows = [("bachelor's", 4), ("master's", 3), ('doctorate + FE', 2)];
    final left = size.width * 0.3;
    final unit = (size.width * 0.5) / 4;
    final rowH = (size.height - 30) / 3;
    for (final (i, (label, years)) in rows.indexed) {
      final y = 10 + i * rowH + rowH / 2;
      final l = _text(label, size: 10, color: AppColors.charcoal);
      inkLabel(canvas, l, Offset(left - l.width - 10, y - l.height / 2));
      final bar = Rect.fromLTWH(left, y - 11, unit * years, 22);
      canvas.drawRRect(
        RRect.fromRectAndRadius(bar, const Radius.circular(7)),
        Paint()..color = AppColors.charcoal,
      );
      final n = _text(
        '$years years',
        size: 10,
        color: AppColors.cream,
        weight: FontWeight.w600,
      );
      inkLabel(canvas, n, Offset(bar.left + 8, y - n.height / 2));
    }
    final x = left + unit * 4 + 10;
    final pe = Rect.fromLTWH(x, 8, size.width - x - 8, size.height - 16);
    _box(
      canvas,
      pe,
      'PE\nexam',
      fill: AppColors.spring,
      ink: AppColors.charcoal,
      size: 10,
      radius: 10,
    );
  }

  @override
  bool shouldRepaint(_YearsPainter old) => false;
}

/// Felony against misdemeanor: what counts and what does not.
class _GroundsPainter extends CustomPainter {
  const _GroundsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final colW = size.width * 0.44;
    final f = Rect.fromLTWH(size.width * 0.04, 8, colW, 30);
    final m = Rect.fromLTWH(size.width * 0.52, 8, colW, 30);
    _box(canvas, f, 'a felony', radius: 8);
    _box(canvas, m, 'a misdemeanor', radius: 8);
    final rows = [
      ('anything at all', true, false),
      ('a lie, or fraud', true, true),
      ('done in the practice', true, true),
      ('a speeding ticket', true, false),
    ];
    final rowH = (size.height - 50) / rows.length;
    for (final (i, (label, fel, mis)) in rows.indexed) {
      final y = 48 + i * rowH + rowH / 2;
      final t = _text(label, size: 9.5, color: AppColors.charcoal);
      inkLabel(canvas, t, Offset(f.left + 24, y - t.height / 2));
      _check(canvas, Offset(f.left + 10, y), ok: fel, r: 7);
      final t2 = _text(label, size: 9.5, color: AppColors.charcoal);
      inkLabel(canvas, t2, Offset(m.left + 24, y - t2.height / 2));
      _check(canvas, Offset(m.left + 10, y), ok: mis, r: 7);
    }
  }

  @override
  bool shouldRepaint(_GroundsPainter old) => false;
}

/// One question, two roads, two different lists of penalties.
class _ForkPainter extends CustomPainter {
  const _ForkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final q = Rect.fromCenter(
      center: Offset(size.width / 2, 26),
      width: 150,
      height: 32,
    );
    _box(
      canvas,
      q,
      'do they hold a license?',
      fill: AppColors.spring,
      ink: AppColors.charcoal,
      size: 10,
    );
    final yes = Rect.fromLTWH(
      size.width * 0.05,
      size.height * 0.42,
      size.width * 0.42,
      size.height * 0.5,
    );
    final no = Rect.fromLTWH(
      size.width * 0.53,
      size.height * 0.42,
      size.width * 0.42,
      size.height * 0.5,
    );
    _box(
      canvas,
      yes,
      'yes: a licensee',
      note: 'suspend, revoke,\nfine, reprimand',
      radius: 12,
    );
    _box(
      canvas,
      no,
      'no: unlicensed',
      note: 'fined, and each day\ncounts again',
      fill: AppColors.cream,
      ink: AppColors.charcoal,
      radius: 12,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(no, const Radius.circular(12)),
      _stroke(AppColors.charcoal, 2),
    );
    final line = _stroke(AppColors.ink2, 2);
    _arrow(
      canvas,
      Offset(q.center.dx - 20, q.bottom + 2),
      Offset(yes.center.dx, yes.top - 3),
      line,
    );
    _arrow(
      canvas,
      Offset(q.center.dx + 20, q.bottom + 2),
      Offset(no.center.dx, no.top - 3),
      line,
    );
    final t = _text('expired or revoked = no', size: 9, color: AppColors.ink2);
    inkLabel(canvas, t, Offset(no.center.dx - t.width / 2, no.bottom + 3));
  }

  @override
  bool shouldRepaint(_ForkPainter old) => false;
}

/// Five ticks in a row that add up to a contract, and one thing that is not
/// on the list.
class _FiveChecksPainter extends CustomPainter {
  const _FiveChecksPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final items = [
      'offer',
      'acceptance',
      'consideration',
      'capacity',
      'lawful',
    ];
    final y = size.height * 0.36;
    final step = (size.width - 24) / items.length;
    for (final (i, label) in items.indexed) {
      final x = 12 + step * i + step / 2;
      _check(canvas, Offset(x, y), r: 10);
      final t = _text(
        label,
        size: 8.5,
        color: AppColors.charcoal,
        maxWidth: step + 10,
        align: TextAlign.center,
      );
      inkLabel(canvas, t, Offset(x - t.width / 2, y + 16));
    }
    final bar = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.8),
      width: 130,
      height: 28,
    );
    _box(
      canvas,
      bar,
      'a contract',
      fill: AppColors.spring,
      ink: AppColors.charcoal,
      radius: 14,
    );
    final nx = size.width * 0.5;
    final ny = size.height * 0.8;
    final n = _text('a notary', size: 9.5, color: AppColors.error);
    inkLabel(canvas, n, Offset(nx + 84, ny - n.height / 2));
    _check(canvas, Offset(nx + 74, ny), ok: false, r: 7);
  }

  @override
  bool shouldRepaint(_FiveChecksPainter old) => false;
}

/// The band a competent peer lands in, with a good result inside it, a
/// perfect one above, and negligence below.
class _BandPainter extends CustomPainter {
  const _BandPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.4;
    final right = size.width * 0.95;
    final top = size.height * 0.34;
    final bottom = size.height * 0.62;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(left, top, right, bottom),
        const Radius.circular(8),
      ),
      Paint()..color = AppColors.spring.withValues(alpha: 0.55),
    );
    final band = _text(
      'what a competent peer would do',
      size: 9.5,
      color: AppColors.charcoal,
      weight: FontWeight.w600,
    );
    inkLabel(
      canvas,
      band,
      Offset(left + 8, (top + bottom) / 2 - band.height / 2),
    );
    void mark(double y, String label, Color color) {
      canvas.drawCircle(Offset(left - 14, y), 6, Paint()..color = color);
      final t = _text(label, size: 9.5, color: color, align: TextAlign.right);
      inkLabel(canvas, t, Offset(left - 26 - t.width, y - t.height / 2));
    }

    mark(size.height * 0.14, 'perfect: not owed', AppColors.ink2);
    mark((top + bottom) / 2, 'yours: fine', AppColors.forest);
    mark(size.height * 0.84, 'below: negligence', AppColors.error);
    canvas.drawLine(
      Offset(left - 14, size.height * 0.1),
      Offset(left - 14, size.height * 0.9),
      _stroke(AppColors.ink2, 1),
    );
  }

  @override
  bool shouldRepaint(_BandPainter old) => false;
}

/// Four links, with the third one missing.
class _ChainPainter extends CustomPainter {
  const _ChainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final links = ['duty', 'breach', 'causation', 'damages'];
    final y = size.height * 0.42;
    final w = (size.width - 24 - 3 * 8) / 4;
    for (final (i, label) in links.indexed) {
      final rect = Rect.fromLTWH(12 + i * (w + 8), y - 16, w, 32);
      final missing = i == 2;
      if (missing) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(16)),
          _stroke(AppColors.error, 2)..strokeCap = StrokeCap.butt,
        );
        final t = _text(label, size: 10, color: AppColors.error);
        inkLabel(canvas, t, rect.center - Offset(t.width / 2, t.height / 2));
      } else {
        _box(canvas, rect, label, radius: 16, size: 10);
      }
    }
    final t = _text(
      'one link gone, and the claim does not pull through',
      size: 9.5,
      color: AppColors.error,
      maxWidth: size.width - 24,
      align: TextAlign.center,
    );
    inkLabel(canvas, t, Offset(size.width / 2 - t.width / 2, y + 26));
    final u = _text('intent is not a link', size: 9.5, color: AppColors.ink2);
    inkLabel(canvas, u, Offset(size.width / 2 - u.width / 2, y - 40));
  }

  @override
  bool shouldRepaint(_ChainPainter old) => false;
}

/// Four boxes, each with a title and a note, optionally hung off one hub.
class _FourBoxesPainter extends CustomPainter {
  const _FourBoxesPainter({
    required this.titles,
    required this.notes,
    this.hub,
  });

  final List<String> titles;
  final List<String> notes;
  final String? hub;

  @override
  void paint(Canvas canvas, Size size) {
    final hasHub = hub != null;
    final top = hasHub ? size.height * 0.36 : 10.0;
    final w = (size.width - 24 - 8) / 2;
    final h = (size.height - top - 10 - 8) / 2;
    final rects = <Rect>[];
    for (var i = 0; i < 4; i++) {
      final rect = Rect.fromLTWH(
        12 + (i % 2) * (w + 8),
        top + (i ~/ 2) * (h + 8),
        w,
        h,
      );
      rects.add(rect);
      _box(
        canvas,
        rect,
        titles[i],
        note: notes[i],
        fill: i.isEven ? AppColors.charcoal : AppColors.cream,
        ink: i.isEven ? AppColors.cream : AppColors.charcoal,
        radius: 12,
      );
      if (i.isOdd) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(12)),
          _stroke(AppColors.charcoal, 1.5),
        );
      }
    }
    if (hasHub) {
      final hubRect = Rect.fromCenter(
        center: Offset(size.width / 2, 22),
        width: 120,
        height: 30,
      );
      _box(
        canvas,
        hubRect,
        hub!,
        fill: AppColors.spring,
        ink: AppColors.charcoal,
        radius: 15,
      );
      final line = _stroke(AppColors.ink2, 1.5);
      for (final r in rects.take(2)) {
        canvas.drawLine(
          Offset(
            hubRect.center.dx + (r.center.dx < size.width / 2 ? -20 : 20),
            hubRect.bottom,
          ),
          Offset(r.center.dx, r.top),
          line,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_FourBoxesPainter old) =>
      old.titles != titles || old.notes != notes || old.hub != hub;
}
