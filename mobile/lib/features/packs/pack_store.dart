import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/network/api_client.dart';
import 'game_types.dart';
import 'pack_model.dart';

/// Whether the app plays games from content packs (ADR 0030). Off for every
/// student until phase 4; a developer build turns it on with
/// `--dart-define=PACKS=true`.
const packsOn = bool.fromEnvironment('PACKS');

/// One published version of an exam's pack, as the app holds it.
class LoadedPack {
  LoadedPack._(this.json, this.sha256);

  /// Reads a pack from its published text. Throws [FormatException] if it
  /// is not a pack this app can read.
  factory LoadedPack.parse(String text) {
    final json = jsonDecode(text);
    if (json is! Map<String, Object?> ||
        json['format'] != packFormat ||
        json['exam'] is! String ||
        json['version'] is! int ||
        json['lessons'] is! Map ||
        json['games'] is! Map) {
      throw const FormatException('Not a pack this app reads');
    }
    return LoadedPack._(
      json,
      crypto.sha256.convert(utf8.encode(text)).toString(),
    );
  }

  final Map<String, Object?> json;
  final String sha256;

  String get exam => json['exam']! as String;
  int get version => json['version']! as int;

  /// `fe-civil@1`: how a report names the pack it came from.
  String get label => '$exam@$version';

  Map<String, Object?> get _lessons => json['lessons']! as Map<String, Object?>;

  late final Map<String, PackGame> games = {
    for (final MapEntry(:key, :value)
        in (json['games']! as Map<String, Object?>).entries)
      key: PackGame(value! as Map<String, Object?>, pack: label),
  };

  /// The lesson (`chapter/lesson`) each game sits in.
  late final Map<String, String> lessonOf = {
    for (final MapEntry(:key, :value) in _lessons.entries)
      for (final g in (value! as Map)['games'] as List) g as String: key,
  };

  /// The oldest app that can play [lesson].
  String minAppOf(String lesson) =>
      (_lessons[lesson]! as Map)['minApp'] as String;
}

/// Holds the FE Civil pack: the copy inside the app, or a newer one
/// downloaded since. Never waits on the network to start (rule 3), never
/// changes a round in progress (rule 4): a game holds the [PackGame] it was
/// opened with, so a newer pack only reaches the next lesson opened.
class PackStore extends ChangeNotifier {
  PackStore({this.exam = 'fe-civil', Future<Directory> Function()? folder})
    : _folder = folder ?? getApplicationSupportDirectory;

  static final instance = PackStore();

  final String exam;
  final Future<Directory> Function() _folder;

  LoadedPack? _pack;
  LoadedPack? get pack => _pack;

  /// This app's version, `major.minor.patch`.
  String appVersion = firstPackApp;

  Future<Directory> _dir() async =>
      Directory('${(await _folder()).path}/packs/$exam');

  /// The copy inside the app, then a downloaded one if it is newer and
  /// still matches the hash it was saved with.
  Future<void> load({AssetBundle? bundle}) async {
    final bundled = LoadedPack.parse(
      await (bundle ?? rootBundle).loadString('assets/packs/$exam.json'),
    );
    var best = bundled;
    try {
      final saved = await _readSaved();
      if (saved != null && saved.version > best.version) best = saved;
    } catch (_) {
      // A damaged download is ignored; the copy inside the app still works.
    }
    _set(best);
  }

  Future<LoadedPack?> _readSaved() async {
    final dir = await _dir();
    final pointer = File('${dir.path}/current.json');
    if (!pointer.existsSync()) return null;
    final p = jsonDecode(await pointer.readAsString()) as Map<String, Object?>;
    final file = File('${dir.path}/${p['file']}');
    if (!file.existsSync()) return null;
    final pack = LoadedPack.parse(await file.readAsString());
    return pack.sha256 == p['sha256'] ? pack : null;
  }

  /// Asks the server for a newer version and keeps it if it checks out.
  /// Quiet: true when a newer pack was saved, false otherwise, and any
  /// failure (offline, a bad file) leaves the current pack in place.
  Future<bool> refresh(ApiClient api) async {
    try {
      final m = await api.get('/packs/$exam') as Map<String, Object?>;
      // A newer layout than this app reads: keep what we have. Lessons
      // that need a newer app are told so one by one, through minApp.
      if (m['format'] != packFormat) return false;
      final version = m['version'] as int;
      if (_pack != null && version <= _pack!.version) return false;
      final file = m['file'] as String;
      if (!RegExp(r'^[a-z0-9-]+-v\d+-[a-f0-9]{12}\.json$').hasMatch(file)) {
        return false;
      }
      final text = await api.getText('/packs/$exam/$file');
      final pack = LoadedPack.parse(text);
      if (pack.sha256 != m['sha256'] ||
          pack.exam != exam ||
          pack.version != version) {
        return false;
      }
      final dir = await _dir();
      await dir.create(recursive: true);
      // Written whole, then pointed at: a cut-off download is never read.
      await File('${dir.path}/$file').writeAsString(text, flush: true);
      final tmp = File('${dir.path}/current.json.tmp');
      await tmp.writeAsString(
        jsonEncode({'file': file, 'sha256': pack.sha256, 'version': version}),
        flush: true,
      );
      await tmp.rename('${dir.path}/current.json');
      await _prune(dir, keep: file);
      _set(pack);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Older downloads go once a newer one is in place.
  Future<void> _prune(Directory dir, {required String keep}) async {
    await for (final f in dir.list()) {
      final name = f.uri.pathSegments.last;
      if (f is File && name.endsWith('.json') && name != keep) {
        if (name != 'current.json') await f.delete();
      }
    }
  }

  void _set(LoadedPack pack) {
    _pack = pack;
    notifyListeners();
  }

  /// The pack's game [id], or null when the pack does not have it.
  PackGame? game(String id) => _pack?.games[id];

  /// Whether this app can play the lesson [gameId] sits in.
  bool canPlay(String gameId) {
    final pack = _pack;
    final lesson = pack?.lessonOf[gameId];
    if (pack == null || lesson == null) return false;
    return compareVersions(pack.minAppOf(lesson), appVersion) <= 0;
  }
}
