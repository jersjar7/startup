import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../shared/widgets/mastery_ring.dart';
import '../study/content_repository.dart';

/// Tab 3 — Profile: the mastery hero, the three stats, and account actions.
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late Future<int> _mastery; // overall concept mastery %

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthController>();
    auth.refreshMe(); // freshen XP / days / badges
    final repo = ContentRepository(auth.api);
    _mastery = repo.mastery().then((m) {
      if (m.isEmpty) return 0;
      final avg = m.values.fold<int>(0, (a, b) => a + b) / m.values.length;
      return avg.round();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user ?? const {};
    final first = (user['firstName'] ?? '') as String;
    final last = (user['lastName'] ?? '') as String;
    final name = (user['displayName'] ?? user['email'] ?? '') as String;
    final email = (user['email'] ?? '') as String;
    final initials = _initials(first, last, email);
    final xp = (user['totalXp'] ?? 0) as int;
    final days = (user['currentStreak'] ?? 0) as int;
    final badges = (user['badges'] as List?)?.length ?? 0;
    final examDays = _daysUntil(user['examDate'] as String?);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: AppColors.charcoal,
                child: Text(initials,
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700, fontSize: 20, color: AppColors.cream)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTheme.heading(size: 19)),
                    if (email.isNotEmpty)
                      Text(email, style: const TextStyle(fontSize: 12, color: AppColors.ink3)),
                  ],
                ),
              ),
            ],
          ),
          if (examDays != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(color: AppColors.emberBg, borderRadius: BorderRadius.circular(20)),
                child: Text('FE exam in $examDays days',
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700, fontSize: 11.5, color: const Color(0xFFB8431C))),
              ),
            ),
          ],
          // Mastery hero
          FutureBuilder<int>(
            future: _mastery,
            builder: (context, snap) {
              final pct = snap.data ?? 0;
              return Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [BoxShadow(color: Color(0x0F2C2C2C), blurRadius: 24, offset: Offset(0, 8))],
                ),
                child: Row(
                  children: [
                    MasteryRing(pct: pct, size: 92, stroke: 9),
                    const SizedBox(width: 18),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Concept mastery',
                              style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w700, fontSize: 17)),
                          SizedBox(height: 4),
                          Text(
                            'Of the concepts the FE tests. Not a probability of passing, but an indicator of how prepared you are.',
                            style: TextStyle(fontSize: 12, color: AppColors.ink3, height: 1.45),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _tile(Icons.bolt, AppColors.sunbeam, xp.toString(), 'Total XP'),
              const SizedBox(width: 10),
              _tile(Icons.local_fire_department, AppColors.ember, days.toString(), 'Days studied'),
              const SizedBox(width: 10),
              _tile(Icons.military_tech, AppColors.forest, badges.toString(), 'Badges'),
            ],
          ),
          const SizedBox(height: 22),
          Text('ACCOUNT', style: AppTheme.overline()),
          _row(Icons.open_in_new, 'Open the website',
              () => launchUrl(Uri.parse('https://fe4raccoons.com'), mode: LaunchMode.externalApplication)),
          const Divider(height: 1),
          _row(Icons.logout, 'Sign out', () => auth.signOut()),
          const Divider(height: 1),
          _row(Icons.delete_outline, 'Delete account', () => _confirmDelete(auth), danger: true),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, Color color, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color(0x0F2C2C2C), blurRadius: 16, offset: Offset(0, 6))],
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 5),
            Text(value, style: AppTheme.mono(size: 19, weight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.ink3)),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, VoidCallback onTap, {bool danger = false}) {
    final color = danger ? AppColors.error : AppColors.charcoal;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: danger ? AppColors.error : AppColors.ink2),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14, color: color))),
            if (!danger) const Icon(Icons.chevron_right, color: Color(0xFFCBBFAE)),
          ],
        ),
      ),
    );
  }

  String _initials(String first, String last, String email) {
    if (first.isNotEmpty) {
      return (first[0] + (last.isNotEmpty ? last[0] : '')).toUpperCase();
    }
    return email.isNotEmpty ? email[0].toUpperCase() : '?';
  }

  int? _daysUntil(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final d = DateTime.tryParse(iso);
    if (d == null) return null;
    final days = d.difference(DateTime.now()).inDays;
    return days >= 0 ? days : null;
  }

  Future<void> _confirmDelete(AuthController auth) async {
    final pw = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        bool loading = false;
        String? error;
        return StatefulBuilder(
          builder: (ctx, setLocal) => AlertDialog(
            backgroundColor: AppColors.cream,
            title: const Text('Delete account?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('This permanently deletes your account and all progress. Enter your password to confirm.',
                    style: TextStyle(fontSize: 13, color: AppColors.ink2, height: 1.4)),
                const SizedBox(height: 14),
                TextField(
                  controller: pw,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Password', border: OutlineInputBorder()),
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
                ],
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
              TextButton(
                onPressed: loading
                    ? null
                    : () async {
                        setLocal(() {
                          loading = true;
                          error = null;
                        });
                        try {
                          await auth.deleteAccount(pw.text);
                          if (ctx.mounted) Navigator.of(ctx).pop(); // gate routes out
                        } on ApiException catch (e) {
                          setLocal(() {
                            loading = false;
                            error = e.message;
                          });
                        }
                      },
                child: Text(loading ? 'Deleting…' : 'Delete', style: const TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
      },
    );
  }
}
