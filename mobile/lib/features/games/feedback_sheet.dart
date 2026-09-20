import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/build_info.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../shared/widgets/kit.dart';

/// "Something unclear?" (reference 18): the sheet behind the flag on a game
/// round. Three chips for what it is about, one oversized field, a send
/// pill; on send it thanks the student and closes. The game, the round and
/// the app build travel with the words, so the owner never has to ask.
Future<void> showFeedbackSheet(
  BuildContext context, {
  required String gameId,
  required String gameName,
  required String chapterId,
  required int round,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.cream,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
    ),
    builder: (_) => FeedbackSheet(
      gameId: gameId,
      gameName: gameName,
      chapterId: chapterId,
      round: round,
    ),
  );
}

class FeedbackSheet extends StatefulWidget {
  const FeedbackSheet({
    super.key,
    required this.gameId,
    required this.gameName,
    required this.chapterId,
    required this.round,
  });

  final String gameId;
  final String gameName;
  final String chapterId;

  /// 1-based, as the student sees it.
  final int round;

  @override
  State<FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<FeedbackSheet> {
  static const kinds = [
    ('explanation', 'The explanation'),
    ('game', 'The game'),
    ('answer', 'The answer'),
  ];

  final _text = TextEditingController();
  String _kind = 'explanation';
  bool _sending = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final text = _text.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Write a line first.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await context.read<AuthController>().api.post('/feedback/game', {
        'gameId': widget.gameId,
        'gameName': widget.gameName,
        'chapterId': widget.chapterId,
        'round': widget.round,
        'kind': _kind,
        'text': text,
        'build': appBuild,
      });
      if (!mounted) return;
      setState(() => _sent = true);
      await Future<void>.delayed(const Duration(milliseconds: 1400));
      if (mounted) Navigator.of(context).maybePop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = 'Could not reach the server. Try again in a moment.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: keyboard),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 34),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Grabber(),
              const SizedBox(height: 22),
              if (_sent) ...[
                Text(
                  'Thanks. That helps.',
                  style: AppTheme.display(size: 38, height: 1),
                ),
                const SizedBox(height: 8),
                Text(
                  'We read every one, and it makes the next round better.',
                  style: AppTheme.body(size: 16, color: AppColors.mutedOnLight),
                ),
                const SizedBox(height: 22),
              ] else ...[
                Text(
                  '${widget.gameName.toUpperCase()} · ROUND ${widget.round}',
                  style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
                ),
                const SizedBox(height: 8),
                Text(
                  'Something unclear?',
                  style: AppTheme.display(size: 38, height: 1),
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (id, label) in kinds)
                      _KindChip(
                        label: label,
                        on: _kind == id,
                        onTap: () => setState(() => _kind = id),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                XLField(
                  controller: _text,
                  label: 'What tripped you up?',
                  hint: 'What tripped you up?',
                  caption:
                      'We read every one. Your round and game come along, so '
                      'you can keep it short.',
                  error: _error,
                  keyboardType: TextInputType.multiline,
                  onSubmitted: (_) => _send(),
                ),
                const SizedBox(height: 22),
                PillButton(
                  label: _sending ? 'Sending' : 'Send it',
                  onTap: _sending ? () {} : _send,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _KindChip extends StatelessWidget {
  const _KindChip({required this.label, required this.on, required this.onTap});

  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: on ? AppColors.charcoal : AppColors.creamDark,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Center(
          widthFactor: 1,
          child: Text(
            label,
            style: AppTheme.display(
              size: 15,
              weight: FontWeight.w700,
              height: 1,
              tracking: -0.02,
              color: on ? AppColors.cream : AppColors.charcoal,
            ),
          ),
        ),
      ),
    );
  }
}
