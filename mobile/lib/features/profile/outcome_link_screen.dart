import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../shared/widgets/kit.dart';
import 'account_extras.dart' show StripChip;
import 'exam_date_screen.dart';
import 'pass_card_screen.dart';

/// Where the results email's buttons land when the phone opens the app
/// instead of the website (ADR 0023): "I passed", "Not this time", "I did not
/// sit it", and the attempt buttons after them.
///
/// The same requests the website's page makes, asking for JSON, so the answer
/// is recorded once by the same server code whichever opens the link. Like the
/// website it needs no sign in: the email's token is the account. A pass goes
/// on to the card, here, on the phone.
class OutcomeLinkScreen extends StatefulWidget {
  const OutcomeLinkScreen({
    super.key,
    required this.token,
    this.answer,
    this.attempt,
  });

  final String token;

  /// passed, failed or missed, from an answer link.
  final String? answer;

  /// 1, 2 or 3, from an attempt link.
  final int? attempt;

  @override
  State<OutcomeLinkScreen> createState() => _OutcomeLinkScreenState();
}

class _OutcomeLinkScreenState extends State<OutcomeLinkScreen> {
  bool _loading = true;
  bool _ok = false;
  String _heading = '';
  String _msg = '';
  bool _card = false;
  bool _offerAttempt = false;
  int? _attemptSaved;

  @override
  void initState() {
    super.initState();
    widget.attempt != null ? _sendAttempt(widget.attempt!) : _record();
  }

  String get _token => Uri.encodeComponent(widget.token);

  Future<void> _record() async {
    final api = context.read<AuthController>().api;
    try {
      final r =
          await api.get(
                '/email/exam-result/$_token?a=${widget.answer}&format=json',
              )
              as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _loading = false;
        _ok = r['ok'] == true;
        _heading = (r['heading'] as String?) ?? 'Thank you';
        _msg = (r['msg'] as String?) ?? '';
        _card = r['card'] == true;
        _offerAttempt = r['offerAttempt'] == true;
      });
      // A signed-in account on this phone should see the answer at once.
      final auth = context.read<AuthController>();
      if (auth.status == AuthStatus.authenticated) auth.refreshMe();
    } on ApiException catch (e) {
      _fail(
        e.isNetwork
            ? 'Could not reach the server. Try the link again in a moment.'
            : 'That link has expired. You can tell us from inside the app any '
                  'time.',
      );
    } catch (_) {
      _fail('Something went wrong. Try the link again in a moment.');
    }
  }

  Future<void> _sendAttempt(int n) async {
    final api = context.read<AuthController>().api;
    try {
      await api.get('/email/exam-attempt/$_token?n=$n&format=json');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _ok = true;
        _attemptSaved = n;
        _offerAttempt = false;
        if (widget.attempt != null) {
          _heading = 'Noted';
          _msg = 'That is everything. Thank you.';
        }
      });
    } catch (_) {
      if (widget.attempt != null) {
        _fail('That link has expired.');
      } else if (mounted) {
        // The attempt is the optional second tap; never a dead end.
        setState(() => _offerAttempt = false);
      }
    }
  }

  void _fail(String why) {
    if (!mounted) return;
    setState(() {
      _loading = false;
      _ok = false;
      _heading = 'Link not found';
      _msg = why;
    });
  }

  void _home() => context.go('/home');

  @override
  Widget build(BuildContext context) {
    final signedIn = context.select<AuthController, bool>(
      (a) => a.status == AuthStatus.authenticated,
    );
    final passed = widget.answer == 'passed' && _card;
    return Scaffold(
      backgroundColor: passed ? AppColors.spring : AppColors.fog,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  RoundIconButton(
                    icon: Icons.close_rounded,
                    label: 'Close',
                    onTap: _home,
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Text(
                _loading ? 'One moment.' : _heading,
                style: AppTheme.display(),
              ),
              if (!_loading && _msg.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(_msg, style: AppTheme.body(size: 16)),
              ],
              if (_offerAttempt) ...[
                const SizedBox(height: 28),
                Text(
                  'One last thing: which attempt was it?',
                  style: AppTheme.body(size: 16, weight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (n, label) in const [
                      (1, 'First'),
                      (2, 'Second'),
                      (3, 'Third or more'),
                    ])
                      StripChip(
                        label: label,
                        on: _attemptSaved == n,
                        onTap: () => _sendAttempt(n),
                      ),
                  ],
                ),
              ],
              const Spacer(),
              if (!_loading && passed)
                PillButton(
                  label: 'Get my card',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PassCardScreen(token: widget.token),
                    ),
                  ),
                )
              else if (!_loading &&
                  _ok &&
                  signedIn &&
                  widget.answer != null &&
                  widget.answer != 'passed')
                // Both are about to sit again; the date is the first step.
                PillButton(
                  label: 'Set my next exam date',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ExamDateScreen(),
                    ),
                  ),
                )
              else if (!_loading)
                PillButton(label: 'Open the app', onTap: _home),
            ],
          ),
        ),
      ),
    );
  }
}
