import 'package:flutter/foundation.dart';

import '../../core/network/api_client.dart';

/// The five leagues, weakest to strongest (ADR 0037; metal names approved by
/// the owner 2026-11-01). The server's ids are these; a server from before
/// the rename sends the construction names, which map by position.
enum LeagueMetal {
  copper('Copper', 'C'),
  bronze('Bronze', 'B'),
  silver('Silver', 'S'),
  gold('Gold', 'G'),
  platinum('Platinum', 'P');

  const LeagueMetal(this.label, this.letter);

  final String label;

  /// The letter struck on the coin.
  final String letter;

  static const _legacy = ['timber', 'masonry', 'concrete', 'steel', 'titanium'];

  static LeagueMetal fromId(Object? id) {
    final s = '$id'.toLowerCase();
    for (final m in values) {
      if (m.name == s) return m;
    }
    final i = _legacy.indexOf(s);
    return i >= 0 ? values[i] : copper;
  }

  LeagueMetal? get up => index < values.length - 1 ? values[index + 1] : null;
  LeagueMetal? get down => index > 0 ? values[index - 1] : null;
}

/// How a place moved since yesterday, as the board shows it.
enum LeagueMove { up, down, isNew }

@immutable
class LeagueRow {
  const LeagueRow({
    required this.place,
    required this.name,
    required this.xp,
    required this.isMe,
    this.move,
    this.days,
  });

  final int place;
  final String name;
  final int xp;
  final bool isMe;

  /// Null when the server does not say (an older server, or no change).
  final LeagueMove? move;

  /// Days studied this week, when the server says.
  final int? days;

  static LeagueRow fromJson(Map json) => LeagueRow(
    place: _int(json['place']) ?? 0,
    name: '${json['name'] ?? 'A student'}',
    xp: _int(json['xp']) ?? 0,
    isMe: json['isMe'] == true,
    move: switch (json['move']) {
      'up' => LeagueMove.up,
      'down' => LeagueMove.down,
      'new' => LeagueMove.isNew,
      _ => null,
    },
    days: _int(json['days']),
  );

  /// "SD" for "Sweet D.", "S" for "sal***", "AS" for "A student".
  String get initials {
    final words = name
        .replaceAll(RegExp(r'[^A-Za-z ]'), ' ')
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    final a = words.first[0];
    final b = words.length > 1 ? words[1][0] : '';
    return (a + b).toUpperCase();
  }
}

/// Last week's result, until it has been shown once.
@immutable
class LeagueResult {
  const LeagueResult({
    required this.from,
    required this.to,
    required this.place,
    required this.size,
    required this.moved,
  });

  final LeagueMetal from;
  final LeagueMetal to;
  final int place;
  final int size;

  /// 'up', 'down' or 'stay'.
  final String moved;

  static LeagueResult? fromJson(Object? json) {
    if (json is! Map) return null;
    final from = LeagueMetal.fromId(json['tier']);
    final to = LeagueMetal.fromId(json['newTier'] ?? json['tier']);
    final moved = to.index > from.index
        ? 'up'
        : to.index < from.index
        ? 'down'
        : 'stay';
    return LeagueResult(
      from: from,
      to: to,
      place: _int(json['place']) ?? 0,
      size: _int(json['size']) ?? 0,
      moved: moved,
    );
  }
}

/// What GET /api/league says, read leniently: a field the server does not
/// send is a field the screen does without.
@immutable
class LeagueView {
  const LeagueView({
    required this.metal,
    required this.joined,
    required this.rows,
    required this.promote,
    required this.demote,
    this.hidden = false,
    this.lastResult,
  });

  final LeagueMetal metal;
  final bool joined;
  final List<LeagueRow> rows;
  final int promote;
  final int demote;
  final bool hidden;
  final LeagueResult? lastResult;

  static LeagueView fromJson(Map json) {
    final zones = json['zones'] is Map ? json['zones'] as Map : const {};
    final rows = [
      for (final r in (json['rows'] is List ? json['rows'] as List : const []))
        if (r is Map) LeagueRow.fromJson(r),
    ]..sort((a, b) => a.place.compareTo(b.place));
    return LeagueView(
      metal: LeagueMetal.fromId(json['tier']),
      joined: json['joined'] == true && rows.isNotEmpty,
      rows: rows,
      promote: _int(zones['promote']) ?? 0,
      demote: _int(zones['demote']) ?? 0,
      hidden: json['hidden'] == true,
      lastResult: LeagueResult.fromJson(json['lastResult']),
    );
  }

  LeagueRow? get me {
    for (final r in rows) {
      if (r.isMe) return r;
    }
    return null;
  }

  /// The rows that move up, stay, and move down, in place order.
  List<LeagueRow> get upZone => rows.take(promote).toList();
  List<LeagueRow> get downZone =>
      demote == 0 ? const [] : rows.skip(rows.length - demote).toList();
  List<LeagueRow> get stayZone => rows
      .skip(promote)
      .take((rows.length - promote - demote).clamp(0, rows.length))
      .toList();

  /// "21 XP to pass Kasie N.", or the lead, or nothing when not on the board.
  String get passLine {
    final i = rows.indexWhere((r) => r.isMe);
    if (i < 0) return '';
    if (i == 0) return 'You lead this week.';
    final above = rows[i - 1];
    final gap = above.xp - rows[i].xp + 1;
    final name = above.name.endsWith('.') ? above.name : '${above.name}.';
    return '$gap XP to pass $name';
  }

  LeagueView withHidden(bool value) => LeagueView(
    metal: metal,
    joined: joined,
    rows: rows,
    promote: promote,
    demote: demote,
    hidden: value,
    lastResult: lastResult,
  );

  LeagueView withoutResult() => LeagueView(
    metal: metal,
    joined: joined,
    rows: rows,
    promote: promote,
    demote: demote,
    hidden: hidden,
  );
}

/// "1st", "2nd", "3rd", "4th", "11th", "22nd".
String ordinal(int n) {
  final teen = n % 100;
  if (teen >= 11 && teen <= 13) return '${n}th';
  return switch (n % 10) {
    1 => '${n}st',
    2 => '${n}nd',
    3 => '${n}rd',
    _ => '${n}th',
  };
}

int? _int(Object? v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}');

/// The student's league, read once per Profile open and kept for the
/// screens that follow (the league page, the account sheet's switch).
///
/// Never throws to a caller: a server without leagues, or no network, leaves
/// [view] null and the Profile without its league line.
class LeagueStore {
  LeagueStore._();

  static final view = ValueNotifier<LeagueView?>(null);

  static Future<LeagueView?> refresh(ApiClient api) async {
    try {
      final data = await api.get('/league');
      if (data is! Map) return view.value;
      return view.value = LeagueView.fromJson(data);
    } catch (e) {
      debugPrint('league unavailable: $e');
      return view.value;
    }
  }

  /// The result has been shown: drop it here and tell the server.
  static Future<void> markSeen(ApiClient api) async {
    final v = view.value;
    if (v != null) view.value = v.withoutResult();
    try {
      await api.post('/league/seen');
    } catch (e) {
      debugPrint('league seen not saved: $e');
    }
  }

  /// "Hide me from leagues". Throws so the switch can put itself back.
  static Future<void> setHidden(ApiClient api, bool hidden) async {
    await api.post('/league/hidden', {'hidden': hidden});
    final v = view.value;
    if (v != null) view.value = v.withHidden(hidden);
  }

  @visibleForTesting
  static void reset() => view.value = null;
}
