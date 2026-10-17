import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/kit.dart';
import 'daily_calendar.dart';
import 'daily_models.dart';
import 'daily_widgets.dart';

/// Like Wordle, a shared Daily shows how you did without giving any answer
/// away: the score, the time, and the rounds as bars.
///
/// Shared as a picture, because the text version Wordle made famous is built
/// from emoji squares and this brand uses none. The text copy is plain words
/// and the link.
String dailyShareText(String date, DailyMine mine) =>
    'FE for Raccoons Daily, ${dailyDayLabel(date)}\n'
    '${mine.score} of ${mine.total} on the first try, ${clockOf(mine.ms)}\n'
    'fe4raccoons.com';

/// The card that is shared.
class DailyShareCard extends StatelessWidget {
  const DailyShareCard({super.key, required this.date, required this.mine});

  /// 'YYYY-MM-DD'.
  final String date;
  final DailyMine mine;

  String get _day => dailyDayLabel(date);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(36),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('FE FOR RACCOONS', style: AppTheme.eyebrow()),
              const Spacer(),
              Text(
                _day.toUpperCase(),
                style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'The Daily',
            style: AppTheme.display(size: 30, height: 1.1, tracking: -0.04),
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              text: '${mine.score}',
              style: AppTheme.display(size: 72, height: 0.82, tracking: -0.06),
              children: [
                TextSpan(
                  text: ' of ${mine.total}',
                  style: AppTheme.display(
                    size: 22,
                    weight: FontWeight.w700,
                    tracking: -0.02,
                  ),
                ),
                TextSpan(
                  text: '   ${clockOf(mine.ms)}',
                  style: AppTheme.display(
                    size: 18,
                    weight: FontWeight.w700,
                    color: AppColors.mutedOnLight,
                    tracking: -0.02,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          DailyBars(
            rows: mine.rounds,
            missed: AppColors.peach,
            height: 18,
            gap: 7,
          ),
          const SizedBox(height: 18),
          Text(
            'fe4raccoons.com',
            style: AppTheme.mono(size: 12, color: AppColors.mutedOnLight),
          ),
        ],
      ),
    );
  }
}

/// The share sheet: the card as it will be sent, then the two ways to send it.
Future<void> showDailyShare(
  BuildContext context, {
  required String date,
  required DailyMine mine,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.sheetFog,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
    ),
    builder: (_) => _ShareSheet(date: date, mine: mine),
  );
}

class _ShareSheet extends StatefulWidget {
  const _ShareSheet({required this.date, required this.mine});

  final String date;
  final DailyMine mine;

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  final _card = GlobalKey();
  bool _copied = false;
  bool _busy = false;

  Future<void> _sharePicture() async {
    setState(() => _busy = true);
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    try {
      final boundary =
          _card.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(bytes!.buffer.asUint8List(), mimeType: 'image/png'),
          ],
          fileNameOverrides: ['fe4raccoons-daily-${widget.date}.png'],
          text: dailyShareText(widget.date, widget.mine),
          sharePositionOrigin: origin,
        ),
      );
    } catch (_) {
      // No share sheet (a test, an odd platform): copying still works.
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copy() async {
    await Clipboard.setData(
      ClipboardData(text: dailyShareText(widget.date, widget.mine)),
    );
    if (mounted) setState(() => _copied = true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Grabber(),
            const SizedBox(height: 26),
            Transform.rotate(
              angle: -0.035,
              child: RepaintBoundary(
                key: _card,
                child: DailyShareCard(date: widget.date, mine: widget.mine),
              ),
            ),
            const SizedBox(height: 30),
            SheetButton(
              label: 'Share the picture',
              loading: _busy,
              onTap: _sharePicture,
            ),
            const SizedBox(height: 10),
            SheetButton(
              label: _copied ? 'Copied' : 'Copy as text',
              filled: false,
              onTap: _copy,
            ),
          ],
        ),
      ),
    );
  }
}
