import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../shared/widgets/kit.dart';
import 'pass_card.dart';

/// The pass card in the app (ADR 0023): the name it should carry, then the
/// card, then save or share.
///
/// Reached three ways, all ending here: answering "I passed" on the app's own
/// outcome question, the results email's link opening the app ([token] set),
/// and "Your pass card" on Profile for good afterwards. Signed in, it reads
/// the card from the account; from a link, from the link's token, exactly as
/// the website's /pass-card page does, so it works signed out or signed in as
/// somebody else, and nothing else of a signed-in account is shown or changed.
///
/// The name question is always shown, filled in with the card's own name, or
/// else the account's: what someone is called and what they publish under
/// are not always the same. What is confirmed is saved as the card's name and
/// never renames the account.
class PassCardScreen extends StatefulWidget {
  const PassCardScreen({super.key, this.token});

  /// The results email's token, when the card was opened from its link.
  final String? token;

  @override
  State<PassCardScreen> createState() => _PassCardScreenState();
}

enum _Step { loading, naming, ready, gone, failed }

class _PassCardScreenState extends State<PassCardScreen> {
  final _name = TextEditingController();
  _Step _step = _Step.loading;
  Map<String, dynamic>? _card;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final auth = context.read<AuthController>();
    try {
      final Map<String, dynamic>? card;
      if (widget.token != null) {
        card =
            await auth.api.get(
                  '/email/pass-card/${Uri.encodeComponent(widget.token!)}',
                )
                as Map<String, dynamic>?;
      } else {
        await auth.refreshMe();
        card = (auth.user?['passCard'] as Map?)?.cast<String, dynamic>();
      }
      if (!mounted) return;
      if (card == null) return setState(() => _step = _Step.gone);
      _name.text = (card['suggestedName'] as String?) ?? '';
      setState(() {
        _card = card;
        _step = _Step.naming;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _step = e.statusCode == 404 ? _Step.gone : _Step.failed);
    } catch (_) {
      if (mounted) setState(() => _step = _Step.failed);
    }
  }

  Future<void> _confirm() async {
    final name = _name.text.trim();
    if (name.isEmpty || _busy) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    final auth = context.read<AuthController>();
    try {
      final saved =
          await auth.api.post(
                widget.token != null
                    ? '/email/pass-card/${Uri.encodeComponent(widget.token!)}/name'
                    : '/auth/card-name',
                {'name': name},
              )
              as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _card = saved;
        _step = _Step.ready;
        _busy = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.isNetwork ? 'No signal. Try again in a moment.' : e.message;
      });
    }
  }

  /// The card's data: what is typed while asking, what was saved after.
  PassCardData get _data {
    final printed = _step == _Step.ready
        ? (_card?['cardName'] as String?) ?? _name.text.trim()
        : _name.text.trim();
    return PassCardData.from(
      firstName: printed,
      answeredAt: DateTime.tryParse(_card?['answeredAt'] as String? ?? ''),
    );
  }

  Future<void> _share() async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    setState(() => _busy = true);
    try {
      final image = await renderPassCard(_data);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      // The share sheet rather than a photo library plugin: it has Save
      // Image in it, and it needs no permission until they choose to save.
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(bytes!.buffer.asUint8List(), mimeType: 'image/png'),
          ],
          fileNameOverrides: ['fe-civil-pass-card.png'],
          sharePositionOrigin: origin,
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'The image could not be made. Try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _close() => context.canPop() ? context.pop() : context.go('/home');

  @override
  Widget build(BuildContext context) {
    final ready = _step == _Step.ready;
    return Scaffold(
      backgroundColor: ready ? AppColors.springField : AppColors.fog,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  RoundIconButton(
                    icon: Icons.close_rounded,
                    label: 'Close',
                    onTap: _close,
                  ),
                ],
              ),
              const SizedBox(height: 26),
              ...switch (_step) {
                _Step.loading => [
                  Text('One moment.', style: AppTheme.display()),
                ],
                _Step.gone => [
                  Text('No card here.', style: AppTheme.display()),
                  const SizedBox(height: 14),
                  Text(
                    'This link does not have a card behind it. If you passed '
                    'and told us so, your card is on your profile.',
                    style: AppTheme.body(size: 16),
                  ),
                ],
                _Step.failed => [
                  Text('That did not load.', style: AppTheme.display()),
                  const SizedBox(height: 14),
                  Text(
                    'Check your signal and try again.',
                    style: AppTheme.body(size: 16),
                  ),
                  const SizedBox(height: 24),
                  PillButton(label: 'Try again', onTap: _load),
                ],
                _Step.naming => _naming(),
                _Step.ready => _ready(),
              },
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(
                  _error!,
                  style: AppTheme.body(size: 14, color: AppColors.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _naming() => [
    Text('Congratulations.', style: AppTheme.display()),
    const SizedBox(height: 12),
    Text(
      'What name should your card carry? Write it the way you would want it '
      'on a certificate. This is what people will read when you post it.',
      style: AppTheme.body(size: 16, color: AppColors.mutedOnLight),
    ),
    const SizedBox(height: 22),
    XLField(
      key: const ValueKey('card-name'),
      controller: _name,
      label: 'Your full name',
      hint: 'Your full name',
      textCapitalization: TextCapitalization.words,
      autofillHints: const [AutofillHints.name],
      caption: 'We add the EIT. You do not have to type it.',
      onSubmitted: (_) => _confirm(),
    ),
    const SizedBox(height: 22),
    Opacity(opacity: 0.55, child: PassCardView(data: _data)),
    const SizedBox(height: 22),
    PillButton(
      label: _busy ? 'Saving' : 'Make my card',
      onTap: _name.text.trim().isEmpty || _busy ? null : _confirm,
    ),
  ];

  List<Widget> _ready() => [
    Text('It is yours.', style: AppTheme.display()),
    const SizedBox(height: 12),
    Text(
      'Post it, print it, or keep it. It stays on your profile, so you can '
      'come back for it any time.',
      style: AppTheme.body(size: 16),
    ),
    const SizedBox(height: 22),
    PassCardView(data: _data),
    const SizedBox(height: 22),
    PillButton(label: 'Save or share', onTap: _busy ? null : _share),
    const SizedBox(height: 10),
    Center(
      child: TextAction(
        label: 'Change the name',
        onTap: () => setState(() => _step = _Step.naming),
      ),
    ),
  ];
}
