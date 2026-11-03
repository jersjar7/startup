import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../../core/theme/tablet.dart';
import '../shared/widgets/kit.dart';
import '../shared/widgets/split_page.dart';
import 'league_coin.dart';
import 'league_model.dart';

/// The student's league this week (ADR 0037), opened from the league line
/// on Profile. The approved mock is scratchpad mock/app/league.html: the
/// coin and the league's name as the headline, the student's place as the
/// hero, then the fifteen in three groups named for where they are heading.
///
/// Closest reference: 17-days-studied (back button and eyebrow, a hero
/// number with its unit, then the detail on cream), with the rows drawn as
/// 12-lesson-sheet draws its rows.
class LeagueScreen extends StatefulWidget {
  const LeagueScreen({super.key, this.initial, this.live = true, this.scroll});

  /// What Profile already read, so the page opens full.
  final LeagueView? initial;

  /// False shows [initial] as it is, without asking the server (the gallery
  /// and the tests).
  final bool live;

  /// For the gallery's recording, which scrolls the board by itself.
  final ScrollController? scroll;

  @override
  State<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends State<LeagueScreen> {
  LeagueView? _view;

  @override
  void initState() {
    super.initState();
    _view = widget.initial ?? LeagueStore.view.value;
    if (!widget.live) return;
    // Fresh numbers every open: the board moves all week.
    LeagueStore.refresh(context.read<AuthController>().api).then((v) {
      if (mounted && v != null) setState(() => _view = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final v = _view;
    if (v != null &&
        v.joined &&
        v.me != null &&
        AppTablet.of(context) == SizeClass.expanded) {
      return Scaffold(backgroundColor: AppColors.fog, body: _split(v));
    }
    return Scaffold(
      backgroundColor: AppColors.fog,
      body: MediumColumn(
        child: SafeArea(
          bottom: false,
          child: v == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  controller: widget.scroll,
                  padding: EdgeInsets.fromLTRB(
                    24,
                    8,
                    24,
                    34 + MediaQuery.paddingOf(context).bottom,
                  ),
                  children: [
                    Row(
                      children: [
                        RoundIconButton(
                          icon: Icons.chevron_left_rounded,
                          label: 'Back',
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                        const Spacer(),
                        Text(
                          'ENDS SATURDAY',
                          style: AppTheme.eyebrow(color: AppColors.charcoal),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        LeagueCoin(metal: v.metal, size: 40),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            '${v.metal.label} league',
                            style: AppTheme.display(size: 40),
                          ),
                        ),
                      ],
                    ),
                    if (v.joined && v.me != null)
                      ..._board(v)
                    else
                      ..._notJoined(v),
                  ],
                ),
        ),
      ),
    );
  }

  /// T11: the coin, the place and the lines on the left; the three zones on
  /// the right, all fifteen in view or nearly.
  Widget _split(LeagueView v) {
    final me = v.me!;
    return SplitPage(
      rightScroll: widget.scroll,
      left: [
        Row(
          children: [
            RoundIconButton(
              icon: Icons.chevron_left_rounded,
              label: 'Back',
              onTap: () => Navigator.of(context).maybePop(),
            ),
            const Spacer(),
            Text(
              'ENDS SATURDAY',
              style: AppTheme.eyebrow(color: AppColors.charcoal),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            LeagueCoin(metal: v.metal, size: 46),
            const SizedBox(width: 14),
            Flexible(
              child: Text(
                '${v.metal.label} league',
                style: AppTheme.display(size: 44),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text.rich(
          TextSpan(
            text: ordinal(me.place),
            style: AppTablet.heroXL(),
            children: [
              const TextSpan(text: ' '),
              TextSpan(
                text: 'of ${v.rows.length}',
                style: AppTheme.display(
                  size: 30,
                  weight: FontWeight.w700,
                  height: 0.82,
                  tracking: -0.03,
                ),
              ),
            ],
          ),
          semanticsLabel: '${ordinal(me.place)} of ${v.rows.length}',
        ),
        const SizedBox(height: 32),
        Text(
          [
            if (v.passLine.isNotEmpty) v.passLine,
            'Points from the app and the website both count.',
            'The week ends Saturday at midnight, Eastern.',
          ].join(' '),
          style: AppTablet.bodyTablet(),
        ),
        const SizedBox(height: 22),
        Text(
          'Everyone here studied this week. A new league starts every Sunday.',
          style: AppTablet.bodyTablet(color: AppColors.mutedOnLight),
        ),
      ],
      right: _zones(v, firstPad: 0),
    );
  }

  List<Widget> _notJoined(LeagueView v) => [
    const SizedBox(height: 22),
    Text(
      'Earn XP this week to join your ${v.metal.label} league.',
      style: AppTheme.display(size: 28, height: 1.1, tracking: -0.04),
    ),
    const SizedBox(height: 12),
    Text(
      'Any round on the app or problem on the website puts you in a group '
      'of up to 15 who also studied this week. A new league starts every '
      'Sunday.',
      style: AppTheme.body(size: 15, color: AppColors.mutedOnLight),
    ),
  ];

  List<Widget> _zones(LeagueView v, {double firstPad = 26}) {
    final up = v.metal.up;
    final down = v.metal.down;
    var first = true;
    double pad() {
      final p = first ? firstPad : 26.0;
      first = false;
      return p;
    }

    return [
      if (v.upZone.isNotEmpty && up != null) ...[
        _ZoneLabel(
          top: pad(),
          text: 'Moving up to ${up.label}',
          color: AppColors.forest,
          icon: Icons.arrow_upward_rounded,
        ),
        _Group(rows: v.upZone),
      ],
      if (v.stayZone.isNotEmpty) ...[
        _ZoneLabel(
          top: pad(),
          text: 'Staying in ${v.metal.label}',
          color: AppColors.mutedOnLight,
        ),
        _Group(rows: v.stayZone),
      ],
      if (v.downZone.isNotEmpty && down != null) ...[
        _ZoneLabel(
          top: pad(),
          text: 'Moving down to ${down.label}',
          color: AppColors.ember,
          icon: Icons.arrow_downward_rounded,
        ),
        _Group(rows: v.downZone),
      ],
    ];
  }

  List<Widget> _board(LeagueView v) {
    final me = v.me!;
    return [
      const SizedBox(height: 14),
      Text.rich(
        TextSpan(
          text: ordinal(me.place),
          style: AppTheme.display(size: 120, height: 0.82, tracking: -0.07),
          children: [
            const TextSpan(text: ' '),
            TextSpan(
              text: 'of ${v.rows.length}',
              style: AppTheme.display(
                size: 28,
                weight: FontWeight.w700,
                height: 0.82,
                tracking: -0.03,
              ),
            ),
          ],
        ),
        semanticsLabel: '${ordinal(me.place)} of ${v.rows.length}',
      ),
      const SizedBox(height: 18),
      Text(
        [
          if (v.passLine.isNotEmpty) v.passLine,
          'Points from the app and the website both count.',
          'The week ends Saturday at midnight, Eastern.',
        ].join(' '),
        style: AppTheme.body(size: 15),
      ),
      ..._zones(v),
      const SizedBox(height: 22),
      Text(
        'Everyone here studied this week. A new league starts every Sunday.',
        style: AppTheme.body(size: 15),
      ),
    ];
  }
}

class _ZoneLabel extends StatelessWidget {
  const _ZoneLabel({
    required this.text,
    required this.color,
    this.icon,
    this.top = 26,
  });

  final double top;

  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, top, 0, 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
          ],
          Text(text.toUpperCase(), style: AppTheme.eyebrow(color: color)),
        ],
      ),
    );
  }
}

/// One zone's rows on a cream tile; the student's own row is the dark one.
class _Group extends StatelessWidget {
  const _Group({required this.rows});

  final List<LeagueRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(children: [for (final r in rows) LeagueRowTile(row: r)]),
    );
  }
}

class LeagueRowTile extends StatelessWidget {
  const LeagueRowTile({super.key, required this.row});

  final LeagueRow row;

  @override
  Widget build(BuildContext context) {
    final me = row.isMe;
    final text = me ? AppColors.onScreen : AppColors.charcoal;
    final muted = me ? AppColors.mutedOnDark : AppColors.mutedOnLight;
    final days = row.days;
    final line = [
      '${_thousands(row.xp)} XP',
      if (days != null) '$days ${days == 1 ? 'day' : 'days'} this week',
    ].join(' · ');
    return Semantics(
      container: true,
      label:
          '${ordinal(row.place)}, ${me ? 'you' : row.name}, $line'
          '${_moveWords(row.move)}',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
          decoration: me
              ? BoxDecoration(
                  color: AppColors.screen,
                  borderRadius: BorderRadius.circular(28),
                )
              : null,
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Column(
                  children: [
                    Text(
                      '${row.place}',
                      style: AppTheme.display(
                        size: 20,
                        weight: FontWeight.w700,
                        height: 1.1,
                        tracking: -0.02,
                        color: text,
                      ),
                    ),
                    _Move(move: row.move, onDark: me),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: me ? AppColors.spring : AppColors.creamDark,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  row.initials,
                  style: AppTheme.display(
                    size: 15,
                    weight: FontWeight.w700,
                    tracking: -0.02,
                    color: me ? AppColors.onAccent : AppColors.charcoal,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      me ? 'You' : row.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.display(
                        size: 19,
                        weight: FontWeight.w700,
                        height: 1.15,
                        tracking: -0.02,
                        color: text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      line,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.body(size: 14, color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _moveWords(LeagueMove? m) => switch (m) {
    LeagueMove.up => ', up since yesterday',
    LeagueMove.down => ', down since yesterday',
    LeagueMove.isNew => ', new this week',
    null => '',
  };
}

/// The caret under a place: up, down, or NEW. Nothing when unchanged.
class _Move extends StatelessWidget {
  const _Move({required this.move, required this.onDark});

  final LeagueMove? move;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return switch (move) {
      LeagueMove.up => Icon(
        Icons.keyboard_arrow_up_rounded,
        size: 18,
        color: onDark ? AppColors.spring : AppColors.forest,
      ),
      LeagueMove.down => Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 18,
        color: AppColors.ember,
      ),
      LeagueMove.isNew => Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(
          'NEW',
          style: AppTheme.eyebrow(
            size: 9,
            color: onDark ? AppColors.mutedOnDark : AppColors.charcoal,
          ),
        ),
      ),
      null => const SizedBox(height: 18),
    };
  }
}

String _thousands(int n) {
  final s = n.toString();
  final out = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
    out.write(s[i]);
  }
  return out.toString();
}
