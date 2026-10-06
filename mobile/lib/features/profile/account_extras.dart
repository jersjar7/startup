import 'package:flutter/material.dart';

import '../../core/notifications/notifications.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../shared/widgets/kit.dart';

/// The two rows the account sheet grew, and the editors behind them.
///
/// Kept out of profile_tab.dart because both need their own state and that
/// file is already the longest screen in the app.

/// The years a student can pick from. Four ahead covers an incoming freshman.
/// "Already graduated" is a real answer: repeat takers are a third of the FE
/// Civil population and have no year to give.
List<int> graduationYears([DateTime? now]) {
  final y = (now ?? DateTime.now()).year;
  return [for (var i = 0; i <= 4; i++) y + i];
}

/// A row that reads like the stat rows above it: a label, the current value,
/// and a chevron. Used for both school and reminders.
class SheetRow extends StatelessWidget {
  const SheetRow({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
    this.trailing,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: AppTheme.body(size: 15.5, weight: FontWeight.w500)),
            ),
            const SizedBox(width: 12),
            if (trailing != null)
              trailing!
            else ...[
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.body(size: 15, color: AppColors.ink2),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, size: 20, color: AppColors.ink3),
            ],
          ],
        ),
      ),
    );
  }
}

/// Turns study reminders on, which is also where permission is asked for.
///
/// Deliberately not asked on first launch. Somebody who has just opened the
/// app has not been given a reason to say yes yet, and on iOS a refused
/// permission can only be undone in Settings, so the ask is worth spending
/// once, here, where they went looking for it.
class RemindersRow extends StatefulWidget {
  const RemindersRow({super.key, required this.notifications, this.examIso});

  final Notifications notifications;
  final String? examIso;

  @override
  State<RemindersRow> createState() => _RemindersRowState();
}

class _RemindersRowState extends State<RemindersRow> {
  bool? _on;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    widget.notifications.isEnabled().then((v) {
      if (mounted) setState(() => _on = v);
    });
  }

  Future<void> _toggle(bool want) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (!want) {
        await widget.notifications.setEnabled(false);
        if (mounted) setState(() => _on = false);
        return;
      }
      // Asking is the same call whether or not they have been asked before;
      // on a second ask iOS answers from its own record without a dialog.
      final granted = await widget.notifications.requestPermission();
      if (granted) {
        await widget.notifications.setEnabled(true);
        await widget.notifications.rearm(examDay: widget.examIso);
      }
      if (mounted) setState(() => _on = granted);
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminders are off for this app in your phone settings.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SheetRow(
      label: 'Study reminders',
      value: _on == true ? 'On' : 'Off',
      trailing: Switch.adaptive(
        value: _on ?? false,
        onChanged: _on == null || _busy ? null : _toggle,
        activeTrackColor: AppColors.spring,
      ),
    );
  }
}

/// Where they study, and when they finish, editable after the fact. Students
/// transfer and people mistype their own university, and a stale school
/// quietly corrupts a report they are counted in.
class SchoolRow extends StatelessWidget {
  const SchoolRow({super.key, required this.auth});

  final AuthController auth;

  @override
  Widget build(BuildContext context) {
    final school = auth.user?['school'] as Map<String, dynamic>?;
    final name = (school?['name'] ?? '') as String;
    final year = school?['graduationYear'] as int?;
    final shown = name.isEmpty
        ? 'Not set'
        : year == null
        ? name
        : '$name, $year';
    return SheetRow(
      label: 'School',
      value: shown,
      onTap: () => showSchoolEditor(context, auth),
    );
  }
}

Future<void> showSchoolEditor(BuildContext context, AuthController auth) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.cream,
    barrierColor: const Color(0xA62C2C2C),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
    ),
    builder: (_) => SchoolEditor(auth: auth),
  );
}

class SchoolEditor extends StatefulWidget {
  const SchoolEditor({super.key, required this.auth});

  final AuthController auth;

  @override
  State<SchoolEditor> createState() => _SchoolEditorState();
}

class _SchoolEditorState extends State<SchoolEditor> {
  late final TextEditingController _name;
  int? _year;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final school = widget.auth.user?['school'] as Map<String, dynamic>?;
    _name = TextEditingController(text: (school?['name'] ?? '') as String);
    _year = school?['graduationYear'] as int?;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Which school?');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.auth.setSchool(name, _year);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not save that. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
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
            Text('Where do you study?', style: AppTheme.display(size: 30, height: 1.05)),
            const SizedBox(height: 8),
            Text(
              'So we can show you how you compare with other students at '
              'your school.',
              style: AppTheme.body(size: 14.5, color: AppColors.ink2, height: 1.5),
            ),
            const SizedBox(height: 24),
            XLField(
              controller: _name,
              label: 'School',
              hint: 'Your university',
              textCapitalization: TextCapitalization.words,
              error: _error,
              autofocus: true,
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 22),
            Text('GRADUATING', style: AppTheme.eyebrow(size: 11, color: AppColors.ink2)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final y in graduationYears())
                  YearChip(
                    label: '$y',
                    on: _year == y,
                    onTap: () => setState(() => _year = _year == y ? null : y),
                  ),
                YearChip(
                  label: 'Already have',
                  on: false,
                  onTap: () => setState(() => _year = null),
                ),
              ],
            ),
            const SizedBox(height: 26),
            PillButton(label: _busy ? 'Saving' : 'Save', onTap: _busy ? null : _save),
          ],
        ),
      ),
    );
  }
}

/// Shared with the sign-up screen, so the two places that ask for a
/// graduation year cannot drift apart.
class YearChip extends StatelessWidget {
  const YearChip({
    super.key,required this.label,
    required this.on,
    required this.onTap,
  });

  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: on ? AppColors.charcoal : AppColors.cream,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: on ? AppColors.charcoal : AppColors.charcoal.withValues(alpha: 0.18),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.body(
            size: 14.5,
            weight: FontWeight.w600,
            color: on ? AppColors.cream : AppColors.charcoal,
          ),
        ),
      ),
    );
  }
}
