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

/// Which term they finish in. A May and a December graduate are a full exam
/// cycle apart, so the year alone blurs two different cohorts, but twelve
/// months is too much friction on a field people already skip. Four terms is
/// two taps and it is how universities actually talk (owner, 2026-10-06).
const graduationTerms = ['Winter', 'Spring', 'Summer', 'Fall'];

/// Both halves of one answer, laid out the way the exam date screen already
/// does it: a strip, a big readout, a second strip.
///
/// The first version was two wrapping sets of chips, which put Fall alone on
/// its own row and left "Already have" sitting among the years as though it
/// were one (owner's catch, 2026-10-06). The real fault was treating a term
/// and a year as two unrelated tag sets when they are one answer with two
/// coordinates. This reads as a sentence instead: Spring 2027.
///
/// Matching "When's the big day?" is deliberate. The app now asks two
/// date-shaped questions and they should not look like different products.
class GraduationPicker extends StatelessWidget {
  const GraduationPicker({
    super.key,
    required this.year,
    required this.term,
    required this.onYear,
    required this.onTerm,
    this.onClear,
  });

  final int? year;
  final String? term;
  final ValueChanged<int?> onYear;
  final ValueChanged<String?> onTerm;

  /// "I have already graduated", which is a different kind of answer from a
  /// year and so is a text action rather than another chip, exactly as
  /// "Clear the date" is on the exam date screen.
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final years = graduationYears();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GRADUATING',
          style: AppTheme.eyebrow(size: 11, color: AppColors.ink2),
        ),
        const SizedBox(height: 12),
        // Four terms fit one row exactly, so nothing can ever wrap.
        Row(
          children: [
            for (final t in graduationTerms)
              Expanded(
                child: StripChip(
                  label: t,
                  on: term == t,
                  onTap: () => onTerm(term == t ? null : t),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          term == null && year == null
              ? 'Not set'
              : '${term ?? 'Term'} ${year?.toString() ?? ''}'.trim(),
          style: AppTheme.display(size: 38, height: 1.0, tracking: -0.05),
        ),
        const SizedBox(height: 14),
        // Years scroll rather than spill onto a second line.
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              for (final y in years) ...[
                StripChip(
                  label: '$y',
                  on: year == y,
                  onTap: () => onYear(year == y ? null : y),
                ),
                const SizedBox(width: 4),
              ],
            ],
          ),
        ),
        if (onClear != null) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onClear,
            child: Text(
              'I have already graduated',
              style: AppTheme.body(
                size: 14,
                weight: FontWeight.w600,
                color: AppColors.ink2,
              ).copyWith(decoration: TextDecoration.underline),
            ),
          ),
        ],
      ],
    );
  }
}

/// The exam date screen's month chip, shared rather than copied so the two
/// date-shaped questions cannot drift apart.
class StripChip extends StatelessWidget {
  const StripChip({
    super.key,
    required this.label,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: on ? AppColors.charcoal : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          widthFactor: 1,
          child: Opacity(
            opacity: on ? 1 : 0.7,
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              style: AppTheme.eyebrow(
                size: 12,
                color: on ? AppColors.spring : AppColors.charcoal,
              ),
            ),
          ),
        ),
      ),
    );
  }
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
              child: Text(
                label,
                style: AppTheme.body(size: 15.5, weight: FontWeight.w500),
              ),
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
            content: Text(
              'Reminders are off for this app in your phone settings.',
            ),
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
      // Swaps the content of the sheet it is already in. Opening a second sheet
      // on top left the first one visible behind at its own taller height, and
      // the two rounded tops stacked read as a mistake (owner, 2026-10-07).
      onTap: () {
        final host = AccountSheetHost.of(context);
        if (host != null) {
          host.showSchool();
        } else {
          showSchoolEditor(context, auth);
        }
      },
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
  const SchoolEditor({super.key, required this.auth, this.onDone});

  final AuthController auth;

  /// Called instead of popping, when this is shown inside another sheet rather
  /// than as its own. See [AccountSheetHost].
  final VoidCallback? onDone;

  @override
  State<SchoolEditor> createState() => _SchoolEditorState();
}

class _SchoolEditorState extends State<SchoolEditor> {
  late final TextEditingController _name;
  int? _year;
  String? _term;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final school = widget.auth.user?['school'] as Map<String, dynamic>?;
    _name = TextEditingController(text: (school?['name'] ?? '') as String);
    _year = school?['graduationYear'] as int?;
    final t = school?['graduationTerm'] as String?;
    _term = t == null
        ? null
        : graduationTerms
              .firstWhere(
                (x) => x.toLowerCase() == t.toLowerCase(),
                orElse: () => '',
              )
              .isEmpty
        ? null
        : graduationTerms.firstWhere((x) => x.toLowerCase() == t.toLowerCase());
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
      await widget.auth.setSchool(name, _year, _term);
      if (!mounted) return;
      if (widget.onDone != null) {
        widget.onDone!();
      } else {
        Navigator.of(context).pop();
      }
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
      // Scrollable, because this is a form and the keyboard eats roughly half
      // a short phone. Without it the column simply overflows its box and the
      // save button is the part that goes.
      child: SingleChildScrollView(
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
              const SizedBox(height: 14),
              // The way back, when this is one level inside the account sheet
              // rather than a sheet of its own. The system back gesture works
              // too, but a gesture nobody can see is not a way out.
              if (widget.onDone != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      widget.onDone!();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      // Generous, because it is a small mark and it is the only
                      // way out somebody can see.
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back_rounded,
                            size: 18,
                            color: AppColors.ink2,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Account',
                            style: AppTheme.body(
                              size: 14.5,
                              color: AppColors.ink2,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              SizedBox(height: widget.onDone != null ? 12 : 22),
              Text(
                'Where do you study?',
                style: AppTheme.display(size: 30, height: 1.05),
              ),
              const SizedBox(height: 8),
              Text(
                'So we can show you how you compare with other students at '
                'your school.',
                style: AppTheme.body(
                  size: 14.5,
                  color: AppColors.ink2,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              XLField(
                controller: _name,
                label: 'School',
                hint: 'Your university',
                textCapitalization: TextCapitalization.words,
                error: _error,
                // Not autofocused. One tap on "School" used to open a sheet,
                // focus the field and throw up the keyboard all at once, which
                // is a lot of movement for one tap and hides half the sheet
                // before they have read it (owner, 2026-10-07).
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 22),
              GraduationPicker(
                year: _year,
                term: _term,
                onYear: (y) => setState(() => _year = y),
                onTerm: (t) => setState(() => _term = t),
                onClear: () => setState(() {
                  _year = null;
                  _term = null;
                }),
              ),
              const SizedBox(height: 26),
              PillButton(
                label: _busy ? 'Saving' : 'Save',
                onTap: _busy ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One bottom sheet whose contents change, rather than a stack of sheets.
///
/// Tapping "School" used to call showModalBottomSheet again, which left the
/// account sheet sitting behind the new one at its own taller height, with two
/// rounded tops visible and a dimming layer between them. The owner read that
/// as a mistake, and it is: nothing moved the user to a new place, they only
/// went one level deeper into the same panel.
///
/// So the sheet keeps one container and swaps what is inside it. The container
/// takes the height of whatever it is showing, so going from the account list
/// to the school form shrinks it instead of leaving a taller ghost behind.
class AccountSheetHost extends StatefulWidget {
  const AccountSheetHost({
    super.key,
    required this.account,
    required this.auth,
  });

  /// The sheet's resting content.
  final Widget account;
  final AuthController auth;

  static AccountSheetHostState? of(BuildContext context) =>
      context.findAncestorStateOfType<AccountSheetHostState>();

  @override
  State<AccountSheetHost> createState() => AccountSheetHostState();
}

class AccountSheetHostState extends State<AccountSheetHost> {
  bool _school = false;

  void showSchool() => setState(() => _school = true);
  void showAccount() => setState(() => _school = false);

  @override
  Widget build(BuildContext context) {
    // The back gesture closes the school form first and the sheet second, so
    // the two levels unwind in the order they were entered.
    return PopScope(
      canPop: !_school,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _school) showAccount();
      },
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          // Slides in from the right the way a push would, so going deeper
          // still reads as going deeper.
          transitionBuilder: (child, animation) => SlideTransition(
            position: Tween(
              begin: Offset(
                child.key == const ValueKey('school') ? 0.06 : -0.06,
                0,
              ),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: _school
              ? SchoolEditor(
                  key: const ValueKey('school'),
                  auth: widget.auth,
                  onDone: showAccount,
                )
              : KeyedSubtree(
                  key: const ValueKey('account'),
                  child: widget.account,
                ),
        ),
      ),
    );
  }
}
