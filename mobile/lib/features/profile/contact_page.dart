import 'package:flutter/material.dart';

import '../../core/build_info.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../shared/widgets/kit.dart';

/// "Contact us" (the tester's point 12a), one level in from the account
/// sheet's three dots, in the same sheet: a headline, one oversized field
/// and a send pill (the feedback sheet's shape, reference 18). It goes to
/// POST /api/feedback/contact, which emails the owner with Reply-To set to
/// the account's address.
class ContactPage extends StatefulWidget {
  const ContactPage({super.key, required this.auth, required this.onBack});

  final AuthController auth;
  final VoidCallback onBack;

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _text = TextEditingController();
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
      setState(() => _error = 'Write a message first.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await widget.auth.api.post('/feedback/contact', {
        'message': text,
        'source': 'app',
        'build': appBuild,
      });
      if (!mounted) return;
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
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: Grabber()),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: TextAction(
                  label: 'Account',
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    widget.onBack();
                  },
                ),
              ),
              const SizedBox(height: 12),
              if (_sent) ...[
                Text(
                  'Sent. Thank you.',
                  style: AppTheme.display(size: 34, height: 1),
                ),
                const SizedBox(height: 8),
                Text(
                  'A person reads every message and writes back to the '
                  'email on your account.',
                  style: AppTheme.body(size: 16, color: AppColors.mutedOnLight),
                ),
                const SizedBox(height: 26),
                PillButton(label: 'Back to the account', onTap: widget.onBack),
              ] else ...[
                Text(
                  'Contact us',
                  style: AppTheme.display(size: 34, height: 1),
                ),
                const SizedBox(height: 8),
                Text(
                  'A question, a round that looks wrong, something you wish '
                  'the app did.',
                  style: AppTheme.body(size: 15, color: AppColors.mutedOnLight),
                ),
                const SizedBox(height: 22),
                XLField(
                  controller: _text,
                  label: 'Your message',
                  hint: 'Your message',
                  // Never the address itself: shown here it read as ours,
                  // not the student's (owner, 2026-10-17).
                  caption:
                      'A person reads every one and writes back to the email '
                      'on your account.',
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
