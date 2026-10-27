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
  required bool answered,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.sheet,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
    ),
    builder: (_) => FeedbackSheet(
      gameId: gameId,
      gameName: gameName,
      chapterId: chapterId,
      round: round,
      answered: answered,
    ),
  );
}

/// The same sheet behind the flag on a concept sheet: the concept as the
/// eyebrow, chips for the parts that sheet has, and the lesson and chapter
/// sent along. [gameId] is set when the sheet was opened from a round.
Future<void> showConceptFeedbackSheet(
  BuildContext context, {
  required String concept,
  required String chapterId,
  required List<(String, String)> parts,
  String? lessonId,
  String? lessonName,
  String? gameId,
  String back = 'Back to the concept',
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.sheet,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
    ),
    builder: (_) => FeedbackSheet.concept(
      concept: concept,
      chapterId: chapterId,
      parts: parts,
      lessonId: lessonId,
      lessonName: lessonName,
      gameId: gameId,
      back: back,
    ),
  );
}

class FeedbackSheet extends StatefulWidget {
  const FeedbackSheet({
    super.key,
    required String this.gameId,
    required String this.gameName,
    required this.chapterId,
    required int this.round,
    required this.answered,
    this.sent = false,
  }) : concept = null,
       parts = const [],
       lessonId = null,
       lessonName = null,
       back = 'Back to the round';

  /// About a concept sheet rather than a round. [parts] are the chips:
  /// only the parts this sheet actually has.
  const FeedbackSheet.concept({
    super.key,
    required String this.concept,
    required this.chapterId,
    required this.parts,
    this.lessonId,
    this.lessonName,
    this.gameId,
    this.back = 'Back to the concept',
    this.sent = false,
  }) : gameName = null,
       round = null,
       answered = false;

  final String? gameId;
  final String? gameName;
  final String chapterId;

  /// 1-based, as the student sees it. Null for a concept.
  final int? round;

  /// The concept's headline, when the report is about a concept sheet.
  final String? concept;
  final List<(String, String)> parts;
  final String? lessonId;
  final String? lessonName;

  /// What the thank-you's pill says.
  final String back;

  /// Whether the round has been answered: the answer and its explanation
  /// only exist after that, so they are only offered after that.
  final bool answered;

  /// Opens on the thank-you. Only a photograph needs this.
  final bool sent;

  /// The parts of a concept sheet, each offered only when the sheet has it.
  static const words = ('words', 'The explanation');
  static const picture = ('picture', 'The picture');
  static const formula = ('formula', 'A formula');

  /// The parts of a round a student can find unclear, in the order they
  /// meet them. The label is what the owner reads in the report.
  static const before = [
    ('question', 'The question'),
    ('drawing', 'The drawing'),
    ('howto', 'How to play'),
    ('concept', 'The concept'),
  ];
  static const after = [
    ('question', 'The question'),
    ('drawing', 'The drawing'),
    ('answer', 'The answer'),
    ('explanation', 'The explanation'),
    ('concept', 'The concept'),
    ('howto', 'How to play'),
  ];

  @override
  State<FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<FeedbackSheet> {
  final _text = TextEditingController();
  bool get _isConcept => widget.concept != null;

  List<(String, String)> get _kinds => _isConcept
      ? widget.parts
      : widget.answered
      ? FeedbackSheet.after
      : FeedbackSheet.before;

  late String _kind = _isConcept
      ? widget.parts.first.$1
      : widget.answered
      ? 'explanation'
      : 'question';
  bool _sending = false;
  late bool _sent = widget.sent;
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
      final label = _kinds.firstWhere((k) => k.$1 == _kind).$2;
      await context.read<AuthController>().api.post('/feedback/game', {
        'gameId': ?widget.gameId,
        'gameName': ?widget.gameName,
        'chapterId': widget.chapterId,
        'round': ?widget.round,
        // A concept report is always about the concept; the chip says
        // which part of it.
        'kind': _isConcept ? 'concept' : _kind,
        'kindLabel': label,
        'concept': ?widget.concept,
        'lessonId': ?widget.lessonId,
        'lessonName': ?widget.lessonName,
        'text': text,
        'build': appBuild,
      });
      if (!mounted) return;
      // The thank-you stays until the student puts it away (owner's call:
      // a timed one vanished before it could be read).
      setState(() => _sent = true);
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
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                const SizedBox(height: 26),
                PillButton(
                  label: widget.back,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ] else ...[
                Text(
                  _isConcept
                      ? 'THE CONCEPT · ${widget.concept!.toUpperCase()}'
                      : '${widget.gameName!.toUpperCase()} · ROUND ${widget.round}',
                  style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
                ),
                const SizedBox(height: 8),
                Text(
                  'Something unclear?',
                  style: AppTheme.display(size: 34, height: 1),
                ),
                const SizedBox(height: 22),
                // One part only needs no choosing.
                if (_kinds.length > 1) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (id, label) in _kinds)
                        _KindChip(
                          label: label,
                          on: _kind == id,
                          onTap: () => setState(() => _kind = id),
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                ],
                XLField(
                  controller: _text,
                  label: 'What tripped you up?',
                  hint: 'What tripped you up?',
                  caption: _isConcept
                      ? 'We read every one. The concept you were on comes '
                            'along, so you can keep it short.'
                      : 'We read every one. The round you were on comes '
                            'along, so you can keep it short.',
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
