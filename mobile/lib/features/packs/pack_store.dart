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

String _sha(String text) => crypto.sha256.convert(utf8.encode(text)).toString();

final _indexName = RegExp(r'^[a-z0-9-]+-v\d+-[a-f0-9]{12}\.json$');
final _chapterName = RegExp(r'^[a-z0-9-]+\.[a-z0-9-]+\.[a-f0-9]{12}\.json$');

/// One published version of an exam's pack, as the app holds it: the index
/// that lists every lesson and names each chapter's file (ADR 0033). A
/// chapter's games are read the first time one of them is opened, from
/// wherever [_read] finds the file, and kept.
class LoadedPack {
  LoadedPack._(this.json, this.sha256, this._read);

  /// Reads a version from its published index. [read] gives a chapter
  /// file's text by name. Throws [FormatException] if it is not a pack this
  /// app can read.
  factory LoadedPack.parse(
    String text, {
    required Future<String> Function(String file) read,
  }) {
    final json = jsonDecode(text);
    if (json is! Map<String, Object?> ||
        json['format'] != packFormat ||
        json['exam'] is! String ||
        json['version'] is! int ||
        json['lessons'] is! Map ||
        json['chapters'] is! Map) {
      throw const FormatException('Not a pack this app reads');
    }
    for (final c in (json['chapters']! as Map).values) {
      if (c is! Map ||
          c['sha256'] is! String ||
          !_chapterName.hasMatch('${c['file']}')) {
        throw const FormatException('Not a pack this app reads');
      }
    }
    return LoadedPack._(json, _sha(text), read);
  }

  final Map<String, Object?> json;
  final String sha256;
  final Future<String> Function(String file) _read;

  String get exam => json['exam']! as String;
  int get version => json['version']! as int;

  /// `fe-civil@1`: how a report names the pack it came from.
  String get label => '$exam@$version';

  Map<String, Object?> get _lessons => json['lessons']! as Map<String, Object?>;

  /// Every chapter's file, by chapter: `{file, sha256, bytes}`.
  Map<String, Map<String, Object?>> get chapters => {
    for (final MapEntry(:key, :value)
        in (json['chapters']! as Map<String, Object?>).entries)
      key: (value! as Map).cast<String, Object?>(),
  };

  /// The lesson (`chapter/lesson`) each game sits in.
  late final Map<String, String> lessonOf = {
    for (final MapEntry(:key, :value) in _lessons.entries)
      for (final g in (value! as Map)['games'] as List) g as String: key,
  };

  /// Every game in the pack, read or not.
  Iterable<String> get gameIds => lessonOf.keys;

  /// The oldest app that can play [lesson].
  String minAppOf(String lesson) =>
      (_lessons[lesson]! as Map)['minApp'] as String;

  String? chapterOf(String gameId) => lessonOf[gameId]?.split('/').first;

  final _reading = <String, Future<Map<String, PackGame>>>{};
  final _ready = <String, Map<String, PackGame>>{};

  /// Game [id] if its chapter has been read, without waiting.
  PackGame? gameIfRead(String id) => _ready[chapterOf(id)]?[id];

  /// Game [id], reading its chapter first if need be. Throws if the
  /// chapter's file is missing or does not match its hash.
  Future<PackGame?> game(String id) async {
    final chapter = chapterOf(id);
    if (chapter == null) return null;
    return (await _chapter(chapter))[id];
  }

  Future<Map<String, PackGame>> _chapter(String chapter) =>
      _reading[chapter] ??= _readChapter(chapter).then(
        (games) => _ready[chapter] = games,
        onError: (Object e) {
          // Not kept, so the next open tries again.
          _reading.remove(chapter);
          throw e;
        },
      );

  Future<Map<String, PackGame>> _readChapter(String chapter) async {
    final entry = chapters[chapter]!;
    final text = await _read(entry['file']! as String);
    if (_sha(text) != entry['sha256']) {
      throw const FormatException('A chapter file does not match its hash');
    }
    final json = jsonDecode(text) as Map<String, Object?>;
    if (json['format'] != packFormat ||
        json['exam'] != exam ||
        json['chapter'] != chapter) {
      throw const FormatException('Not this pack\'s chapter');
    }
    return {
      for (final MapEntry(:key, :value)
          in (json['games']! as Map<String, Object?>).entries)
        key: PackGame(value! as Map<String, Object?>, pack: label),
    };
  }
}

/// Holds the FE Civil pack: the copy inside the app, or a newer one
/// downloaded since. Every chapter is always on the phone (ADR 0033), so
/// nothing waits on the network: not starting (rule 3), not opening a
/// chapter. Never changes a round in progress (rule 4): a game holds the
/// [PackGame] it was opened with, so a newer pack only reaches the next
/// lesson opened.
class PackStore extends ChangeNotifier {
  PackStore({this.exam = 'fe-civil', Future<Directory> Function()? folder})
    : _folder = folder ?? getApplicationSupportDirectory;

  static final instance = PackStore();

  final String exam;
  final Future<Directory> Function() _folder;
  AssetBundle _bundle = rootBundle;

  /// The chapter files inside the app.
  Set<String> _bundled = {};

  LoadedPack? _pack;
  LoadedPack? get pack => _pack;

  /// This app's version, `major.minor.patch`.
  String appVersion = firstPackApp;

  Future<Directory> _dir() async =>
      Directory('${(await _folder()).path}/packs/$exam');

  String get _assets => 'assets/packs/$exam';

  /// A chapter file: downloaded, or else the copy inside the app.
  Future<String> _readFile(String file) async {
    final saved = File('${(await _dir()).path}/$file');
    if (saved.existsSync()) return saved.readAsString();
    return _bundle.loadString('$_assets/$file', cache: false);
  }

  /// The index inside the app, then a downloaded one if it is newer and
  /// still matches the hash it was saved with. Reads no chapter.
  Future<void> load({AssetBundle? bundle}) async {
    _bundle = bundle ?? rootBundle;
    final bundled = LoadedPack.parse(
      await _bundle.loadString('$_assets/index.json'),
      read: _readFile,
    );
    _bundled = {for (final c in bundled.chapters.values) c['file']! as String};
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
    final pack = LoadedPack.parse(await file.readAsString(), read: _readFile);
    return pack.sha256 == p['sha256'] ? pack : null;
  }

  /// Asks the server for a newer version and keeps it if it checks out: its
  /// index, and every chapter file the phone does not already hold, each
  /// checked against its hash. Quiet: true when a newer pack was saved,
  /// false otherwise, and any failure (offline, a bad file) leaves the
  /// current pack in place.
  Future<bool> refresh(ApiClient api) async {
    try {
      final m = await api.get('/packs/$exam') as Map<String, Object?>;
      // A different layout than this app reads: keep what we have. Lessons
      // that need a newer app are told so one by one, through minApp.
      if (m['format'] != packFormat) return false;
      final version = m['version'] as int;
      if (_pack != null && version <= _pack!.version) return false;
      final file = m['file'] as String;
      if (!_indexName.hasMatch(file)) return false;
      final text = await api.getText('/packs/$exam/$file');
      final pack = LoadedPack.parse(text, read: _readFile);
      if (pack.sha256 != m['sha256'] ||
          pack.exam != exam ||
          pack.version != version) {
        return false;
      }

      final dir = await _dir();
      await dir.create(recursive: true);
      // Only the chapters that changed come down. Each is written whole
      // and checked before anything points at it.
      for (final c in pack.chapters.values) {
        final name = c['file']! as String;
        if (_bundled.contains(name) || File('${dir.path}/$name').existsSync()) {
          continue;
        }
        final chapter = await api.getText('/packs/$exam/$name');
        if (_sha(chapter) != c['sha256']) return false;
        final tmp = File('${dir.path}/$name.tmp');
        await tmp.writeAsString(chapter, flush: true);
        await tmp.rename('${dir.path}/$name');
      }
      // Written whole, then pointed at once every chapter is in place: a
      // cut-off download is never read, and never half of two versions.
      await File('${dir.path}/$file').writeAsString(text, flush: true);
      final tmp = File('${dir.path}/current.json.tmp');
      await tmp.writeAsString(
        jsonEncode({'file': file, 'sha256': pack.sha256, 'version': version}),
        flush: true,
      );
      await tmp.rename('${dir.path}/current.json');
      await _prune(
        dir,
        keep: {
          file,
          for (final c in pack.chapters.values) c['file']! as String,
        },
      );
      _set(pack);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Files the current version does not use go once it is in place.
  Future<void> _prune(Directory dir, {required Set<String> keep}) async {
    await for (final f in dir.list()) {
      final name = f.uri.pathSegments.last;
      if (f is File && name != 'current.json' && !keep.contains(name)) {
        await f.delete();
      }
    }
  }

  void _set(LoadedPack pack) {
    _pack = pack;
    notifyListeners();
  }

  /// Whether the pack holds game [id].
  bool has(String id) => _pack?.lessonOf.containsKey(id) ?? false;

  /// Game [id] if its chapter has been read already, else null.
  PackGame? game(String id) => _pack?.gameIfRead(id);

  /// Game [id], reading its chapter from the phone first if need be. Null
  /// when the pack does not hold it or its chapter cannot be read.
  Future<PackGame?> open(String id) async {
    try {
      return await _pack?.game(id);
    } catch (_) {
      return null;
    }
  }

  /// Whether this app can play the lesson [gameId] sits in.
  bool canPlay(String gameId) {
    final pack = _pack;
    final lesson = pack?.lessonOf[gameId];
    if (pack == null || lesson == null) return false;
    return compareVersions(pack.minAppOf(lesson), appVersion) <= 0;
  }
}
