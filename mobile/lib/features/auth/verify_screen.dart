import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/kit.dart';
import 'auth_controller.dart';

/// Check your email: a cream sheet over the faded welcome cards, with the
/// link's destination in bold (`mobile/design/reference-screens/02c`).
class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen>
    with WidgetsBindingObserver {
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the user comes back from tapping the email link, re-check.
    if (state == AppLifecycleState.resumed) _recheck();
  }

  Future<void> _recheck() async {
    final auth = context.read<AuthController>();
    await auth.refreshMe();
    if (mounted && auth.emailVerified) context.go('/home');
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    final auth = context.read<AuthController>();
    String message;
    try {
      await auth.api.post('/auth/resend-verification');
      message = 'Sent. Check your inbox.';
    } on ApiException catch (e) {
      message = e.message;
    }
    if (!mounted) return;
    setState(() => _resending = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _wrongEmail() async {
    await context.read<AuthController>().signOut();
    if (!mounted) return;
    context.go('/welcome');
    context.push('/create');
  }

  @override
  Widget build(BuildContext context) {
    final email =
        context.select<AuthController, String?>((a) => a.email) ?? 'your email';
    return Scaffold(
      backgroundColor: AppColors.fog,
      body: Stack(
        children: [
          const FadedCards(),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
              child: Row(
                children: [
                  const SizedBox(width: 48, height: 48),
                  const SizedBox(width: 14),
                  Expanded(child: StepBar(count: 3, at: 3)),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Sheet(
              title: 'Check your email.',
              body: Text.rich(
                TextSpan(
                  style: AppTheme.body(size: 16, color: AppColors.ink2),
                  children: [
                    const TextSpan(text: 'We sent a link to '),
                    TextSpan(
                      text: email,
                      style: const TextStyle(
                        color: AppColors.charcoal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ". Tap it and you're in."),
                  ],
                ),
              ),
              children: [
                SheetButton(
                  label: 'Open email app',
                  onTap: () => launchUrl(
                    Uri.parse('message://'),
                    mode: LaunchMode.externalApplication,
                  ).catchError((_) => false),
                ),
                const SizedBox(height: 10),
                SheetButton(
                  label: 'Resend link',
                  filled: false,
                  loading: _resending,
                  loadingLabel: 'Sending…',
                  onTap: _resend,
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextAction(
                    label: 'Wrong email? Go back',
                    onTap: _wrongEmail,
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/home'),
                    child: Text(
                      'Continue to the app',
                      style: AppTheme.body(
                        size: 14,
                        weight: FontWeight.w600,
                        color: AppColors.forest,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The cream bottom sheet: grabber, a display title, one body line, then
/// whatever buttons the screen needs.
class Sheet extends StatelessWidget {
  const Sheet({
    super.key,
    required this.title,
    required this.body,
    required this.children,
  });

  final String title;
  final Widget body;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.charcoal.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(title, style: AppTheme.display(size: 38, height: 1)),
              const SizedBox(height: 8),
              body,
              const SizedBox(height: 22),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// The welcome screen's two colored cards, faded and behind a sheet.
class FadedCards extends StatelessWidget {
  const FadedCards({super.key});

  @override
  Widget build(BuildContext context) {
    Widget card(Color color, double w, double h, double angle) =>
        Transform.rotate(
          angle: angle,
          child: Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        );
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 96,
            left: 22,
            child: card(AppColors.spring, 232, 284, -0.12),
          ),
          Positioned(
            top: 160,
            right: -26,
            child: card(AppColors.peach, 206, 246, 0.16),
          ),
        ],
      ),
    );
  }
}
