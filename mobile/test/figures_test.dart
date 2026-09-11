import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

/// The checks on drawn figures that eyes keep failing.
///
/// A figure audit in September 2026 turned up a curve that had never been
/// drawn once since it was written, and a Greek letter coming out as an empty
/// box. Neither was findable by looking at the app: the missing curve read as
/// a design choice and the empty box read as a glyph. Both were findable in
/// about a minute by looking at the source, which is what this file does.
///
/// What it cannot check is framing and collisions. Those still need somebody
/// to open the figures one at a time and look at them, which is written down
/// in `docs/mobile/figures.md` along with the rules these tests enforce.

/// A font file, and the question worth asking of it.
class _Font {
  _Font(this.path) : _bytes = File(path).readAsBytesSync();

  final String path;
  final Uint8List _bytes;

  String get name => path.split('/').last;

  late final ByteData _data = ByteData.view(
    _bytes.buffer,
    _bytes.offsetInBytes,
    _bytes.lengthInBytes,
  );

  int? _cmapAt;

  /// The offset of the best cmap subtable, found once.
  int get _cmap {
    if (_cmapAt != null) return _cmapAt!;
    final numTables = _data.getUint16(4);
    var cmapStart = -1;
    for (var i = 0; i < numTables; i++) {
      final rec = 12 + i * 16;
      final tag = String.fromCharCodes(_bytes.sublist(rec, rec + 4));
      if (tag == 'cmap') {
        cmapStart = _data.getUint32(rec + 8);
        break;
      }
    }
    if (cmapStart < 0) throw StateError('$name has no cmap table');

    // Prefer a full-range subtable, then the usual Windows BMP one.
    final count = _data.getUint16(cmapStart + 2);
    var best = -1;
    var bestScore = -1;
    for (var i = 0; i < count; i++) {
      final rec = cmapStart + 4 + i * 8;
      final platform = _data.getUint16(rec);
      final encoding = _data.getUint16(rec + 2);
      final offset = cmapStart + _data.getUint32(rec + 4);
      final format = _data.getUint16(offset);
      final score = switch ((platform, encoding, format)) {
        (3, 10, 12) => 4,
        (3, 1, 4) => 3,
        (0, _, 12) => 2,
        (0, _, 4) => 1,
        _ => 0,
      };
      if (score > bestScore) {
        bestScore = score;
        best = offset;
      }
    }
    if (best < 0) throw StateError('$name has no usable cmap subtable');
    return _cmapAt = best;
  }

  /// Whether the font can actually draw this character.
  bool has(int codePoint) {
    final at = _cmap;
    final format = _data.getUint16(at);
    if (format == 12) {
      final groups = _data.getUint32(at + 12);
      for (var g = 0; g < groups; g++) {
        final rec = at + 16 + g * 12;
        final start = _data.getUint32(rec);
        final end = _data.getUint32(rec + 4);
        if (codePoint >= start && codePoint <= end) {
          return _data.getUint32(rec + 8) != 0 || codePoint == start;
        }
      }
      return false;
    }
    if (format == 4) {
      if (codePoint > 0xFFFF) return false;
      final segX2 = _data.getUint16(at + 6);
      final segs = segX2 ~/ 2;
      final endAt = at + 14;
      final startAt = endAt + segX2 + 2;
      final deltaAt = startAt + segX2;
      final rangeAt = deltaAt + segX2;
      for (var s = 0; s < segs; s++) {
        final end = _data.getUint16(endAt + s * 2);
        if (codePoint > end) continue;
        final start = _data.getUint16(startAt + s * 2);
        if (codePoint < start) return false;
        final rangeOffset = _data.getUint16(rangeAt + s * 2);
        if (rangeOffset == 0) {
          final delta = _data.getInt16(deltaAt + s * 2);
          return (codePoint + delta) & 0xFFFF != 0;
        }
        final glyphAt =
            rangeAt + s * 2 + rangeOffset + (codePoint - start) * 2;
        if (glyphAt + 1 >= _bytes.lengthInBytes) return false;
        return _data.getUint16(glyphAt) != 0;
      }
      return false;
    }
    throw StateError('$name uses cmap format $format, which is not read here');
  }
}

/// One string literal found in the source, and where it came from.
class _Literal {
  const _Literal(this.file, this.line, this.text);

  final String file;
  final int line;
  final String text;

  String get where => '$file:$line';
}

/// Every string literal in a Dart file, with comments thrown away first.
///
/// Doc comments are full of the punctuation these tests forbid, and they are
/// not drawn on anything.
List<_Literal> _literalsIn(File file) {
  final src = file.readAsStringSync();
  final out = <_Literal>[];
  final name = file.path;
  var line = 1;
  var i = 0;

  while (i < src.length) {
    final c = src[i];
    if (c == '\n') {
      line++;
      i++;
      continue;
    }
    // Comments.
    if (c == '/' && i + 1 < src.length) {
      if (src[i + 1] == '/') {
        while (i < src.length && src[i] != '\n') {
          i++;
        }
        continue;
      }
      if (src[i + 1] == '*') {
        i += 2;
        while (i + 1 < src.length && !(src[i] == '*' && src[i + 1] == '/')) {
          if (src[i] == '\n') line++;
          i++;
        }
        i += 2;
        continue;
      }
    }
    // Strings, raw or not, single or triple quoted.
    if (c == "'" || c == '"' || (c == 'r' && i + 1 < src.length &&
        (src[i + 1] == "'" || src[i + 1] == '"'))) {
      final raw = c == 'r';
      if (raw) i++;
      final quote = src[i];
      final triple = src.startsWith(quote * 3, i);
      final close = triple ? quote * 3 : quote;
      i += close.length;
      final startLine = line;
      final buffer = StringBuffer();
      while (i < src.length && !src.startsWith(close, i)) {
        if (src[i] == '\n') line++;
        if (!raw && src[i] == r'\' && i + 1 < src.length) {
          buffer.write(src[i + 1]);
          i += 2;
          continue;
        }
        buffer.write(src[i]);
        i++;
      }
      i += close.length;
      out.add(_Literal(name, startLine, buffer.toString()));
      continue;
    }
    i++;
  }
  return out;
}

List<File> _dartFiles(String root) => Directory(root)
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList()
  ..sort((a, b) => a.path.compareTo(b.path));

void main() {
  final lib = _dartFiles('lib');
  final literals = [for (final f in lib) ..._literalsIn(f)];

  group('every character the app draws exists in the font it is drawn in', () {
    final fonts = [
      _Font('assets/fonts/DMSans-SemiBold.ttf'),
      _Font('assets/fonts/Inter-Regular.ttf'),
      _Font('assets/fonts/JetBrainsMono-Medium.ttf'),
    ];

    /// Characters allowed even though some bundled face lacks them, because
    /// the ONE place they are used picks a face that has them.
    ///
    /// Keyed by the file as well as the character: the same letter somewhere
    /// else is a different decision, and has to be made again rather than
    /// inherited.
    const allowed = <String, List<(String, String)>>{
      'θ': [
        (
          'lib/features/games/trig_figures.dart',
          'drawn in mono, which has it; the heading face has no Greek at all',
        ),
        (
          'lib/features/games/lesson_brief.dart',
          'card body prose, which is set in Inter',
        ),
      ],
      'σ': [
        (
        'lib/features/games/which_readout_game.dart',
        'a calculator readout, drawn in mono',
        ),
      ],
      'Σ': [
        (
        'lib/features/games/which_readout_game.dart',
        'a calculator readout, drawn in mono',
        ),
      ],
      'μ': [
        (
        'lib/features/onboarding/onboarding_screen.dart',
        'body text, which is Inter',
        ),
      ],
      'ₛ': [
        (
        'lib/features/onboarding/onboarding_screen.dart',
        'body text, which is Inter; mono has no subscripts',
        ),
      ],
      'φ': [
        (
        'lib/features/onboarding/onboarding_screen.dart',
        'body text, which is Inter',
        ),
      ],
      '̄': [
        (
        'lib/features/games/which_readout_game.dart',
        'the macron is stripped and drawn as a real overline',
        ),
      ],
    };

    test('no drawn character is missing from a bundled face', () {
      final trouble = <String>[];
      for (final literal in literals) {
        for (final rune in literal.text.runes) {
          if (rune < 128) continue;
          final char = String.fromCharCode(rune);
          if (allowed[char]?.any((e) => e.$1 == literal.file) ?? false) {
            continue;
          }
          final missing =
              fonts.where((f) => !f.has(rune)).map((f) => f.name).toList();
          if (missing.isNotEmpty) {
            trouble.add(
              '${literal.where}: "$char" (U+${rune.toRadixString(16).toUpperCase().padLeft(4, '0')}) '
              'is missing from ${missing.join(', ')}',
            );
          }
        }
      }
      expect(trouble, isEmpty,
          reason: 'A character no bundled face can draw comes out as an empty '
              'box. Either draw it in a face that has it and record that here, '
              'or write it another way.\n${trouble.join('\n')}');
    });

    test('every allowlist entry is still earning its place', () {
      // Otherwise the list quietly becomes somewhere anything is fine.
      for (final entry in allowed.entries) {
        for (final (file, _) in entry.value) {
          expect(File(file).existsSync(), isTrue,
              reason: '$file is gone, so the entry for "${entry.key}" '
                  'should be');
          expect(File(file).readAsStringSync().contains(entry.key), isTrue,
              reason: '$file no longer uses "${entry.key}"');
        }
        if (entry.key == '̄') continue;
        final rune = entry.key.runes.first;
        expect(fonts.any((f) => !f.has(rune)), isTrue,
            reason: '"${entry.key}" is in every bundled face now, so it needs '
                'no entry at all');
      }
    });
  });

  group('what the app shows follows house style', () {
    test('no combining marks', () {
      // A combining mark is given a full advance by the mono face, so "x̄"
      // came out as an x with a stroke floating off its shoulder. Use a
      // decoration, or the math renderer.
      // The one file that takes a macron apart and draws it properly.
      const handled = {'lib/features/games/which_readout_game.dart'};
      final trouble = <String>[];
      for (final literal in literals) {
        if (handled.contains(literal.file)) continue;
        for (final rune in literal.text.runes) {
          if (rune >= 0x0300 && rune <= 0x036F) {
            trouble.add('${literal.where}: "${literal.text}"');
          }
        }
      }
      expect(trouble, isEmpty,
          reason: 'A combining mark does not sit over the letter it belongs '
              'to.\n${trouble.join('\n')}');
    });

    test('no em dashes in anything the app shows', () {
      final trouble = [
        for (final literal in literals)
          if (literal.text.contains('—')) '${literal.where}: ${literal.text}',
      ];
      expect(trouble, isEmpty,
          reason: 'House style, and the app already uses "?" for an empty '
              'slot.\n${trouble.join('\n')}');
    });

    test('American spelling only', () {
      // The content is written for an American exam. British spelling had got
      // in through 55 files before anybody read for it, so it is read for
      // here instead.
      const british = <String, String>{
        'colour': 'color',
        'centre': 'center',
        'metre': 'meter',
        'litre': 'liter',
        'fibre': 'fiber',
        'neighbour': 'neighbor',
        'labour': 'labor',
        'favour': 'favor',
        'honour': 'honor',
        'behaviour': 'behavior',
        'labelled': 'labeled',
        'labelling': 'labeling',
        'cancelled': 'canceled',
        'travelling': 'traveling',
        'modelling': 'modeling',
        'signalling': 'signaling',
        'offence': 'offense',
        'defence': 'defense',
        'pretence': 'pretense',
        'recognise': 'recognize',
        'organise': 'organize',
        'realise': 'realize',
        'analyse': 'analyze',
        'minimise': 'minimize',
        'maximise': 'maximize',
        'summarise': 'summarize',
        'emphasise': 'emphasize',
        'memorise': 'memorize',
        'practise': 'practice',
        'judgement': 'judgment',
        'enquiry': 'inquiry',
        'whilst': 'while',
        'amongst': 'among',
        'grey': 'gray',
        // "v naught" spelled the American way is fine and stays; this is the
        // British way of saying the digit zero.
        'nought': 'zero',
        'storey': 'story',
        'cheque': 'check',
        'ageing': 'aging',
        'mould': 'mold',
        'sceptic': 'skeptic',
        'aluminium': 'aluminum',
        'draught': 'draft',
      };
      final trouble = <String>[];
      for (final literal in literals) {
        final text = literal.text.toLowerCase();
        for (final entry in british.entries) {
          // "programme" would be here too, but it is the front of
          // "programmer", which is spelled the same on both sides of the water.
          if (text.contains(entry.key)) {
            trouble.add('${literal.where}: "${entry.key}" should be '
                '"${entry.value}"');
          }
        }
      }
      expect(trouble, isEmpty, reason: trouble.join('\n'));
    });
  });

  group('paths are built and painted the way they were meant to be', () {
    final sources = {for (final f in lib) f.path: f.readAsStringSync()};

    test('nothing decides where a path starts by asking for its bounds', () {
      // `Path.getBounds()` on a path holding nothing but moveTo reports empty,
      // so a loop that used it to choose between moveTo and lineTo took the
      // moveTo branch every time and drew no line at all. That is exactly how
      // one curve in this app went unnoticed for months.
      final trouble = <String>[];
      sources.forEach((path, src) {
        final lines = src.split('\n');
        for (var i = 0; i < lines.length; i++) {
          if (lines[i].contains('getBounds().isEmpty')) {
            trouble.add('$path:${i + 1}');
          }
        }
      });
      expect(trouble, isEmpty,
          reason: 'Track the first point with a flag instead.\n'
              '${trouble.join('\n')}');
    });

    test('an open path is never handed to a filling Paint', () {
      // A Paint with no style fills. Given an unclosed polyline that means a
      // zero-area shape and nothing on the screen, which is how the balance
      // line in the rate-of-return figure came to be invisible.
      final call = RegExp(
        r'drawPath\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*,\s*(Paint\(\)[^;]*?)\)\s*;',
        dotAll: true,
      );
      final trouble = <String>[];
      sources.forEach((path, src) {
        for (final m in call.allMatches(src)) {
          final paint = m.group(2)!;
          if (paint.contains('style') || paint.contains('PaintingStyle')) {
            continue;
          }
          final name = m.group(1)!;
          // How that path was built, from its declaration onward.
          final declared = RegExp('(?:final|var)\\s+$name\\s*=').firstMatch(src);
          if (declared == null) continue;
          final body = src.substring(declared.start, m.start);
          if (body.contains('lineTo') && !body.contains('close()')) {
            final line = src.substring(0, m.start).split('\n').length;
            trouble.add('$path:$line ($name)');
          }
        }
      });
      expect(trouble, isEmpty,
          reason: 'Either close the path or give the Paint a stroke '
              'style.\n${trouble.join('\n')}');
    });
  });
}
