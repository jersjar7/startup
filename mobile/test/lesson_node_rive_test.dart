import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/theme/road.dart';
import 'package:mobile/features/games/lesson_node.dart';
import 'package:mobile/features/games/lesson_node_rive.dart';

/// The artboard and the app agree on a contract by name, and nothing checks
/// it at build time: a renamed view model property compiles on both sides and
/// the node silently stops responding. So the test reads the markup.
void main() {
  final rml = File('rive/lesson_node/scene.rml').readAsStringSync();

  test('the view model names match what the app sets', () {
    final declared = RegExp(
      r'<ViewModelProperty\w+ [^>]*name="(\w+)"',
    ).allMatches(rml).map((m) => m.group(1)).toList();
    expect(declared, LessonNodeArt.inputs);
  });

  test('every node state is an enum value the artboard knows', () {
    final values = RegExp(
      r'<DataEnumValue key="(\w+)"',
    ).allMatches(rml).map((m) => m.group(1)).toSet();
    for (final s in NodeState.values) {
      expect(values, contains(s.name), reason: '${s.name} is not in the enum');
    }
  });

  test('the artboard and state machine are named as the app asks for them', () {
    expect(rml, contains('name="${LessonNodeArt.artboard}"'));
    expect(rml, contains('<StateMachine name="${LessonNodeArt.stateMachine}"'));
    expect(
      rml,
      contains(
        'width="${LessonNodeArt.artWidth.toInt()}" '
        'height="${LessonNodeArt.artHeight.toInt()}"',
      ),
    );
  });

  test('the built file is bundled', () {
    expect(
      File(LessonNodeArt.asset).existsSync(),
      isTrue,
      reason: 'run: rive rive/lesson_node --once',
    );
  });

  /// The keyframes of one animation's property, in frame order.
  List<double> keys(String animation, int propertyKey, {String? object}) {
    final start = RegExp(
      '<LinearAnimation[^>]*name="$animation"',
    ).firstMatch(rml)!.start;
    final body = rml.substring(start, rml.indexOf('</LinearAnimation>', start));
    final blocks = RegExp(
      r'<KeyedObject objectId="([^"]+)">\s*<KeyedProperty propertyKey="(\d+)">(.*?)</KeyedProperty>',
      dotAll: true,
    ).allMatches(body);
    final block = blocks.firstWhere(
      (m) =>
          m.group(2) == '$propertyKey' &&
          (object == null || m.group(1) == object),
    );
    return RegExp(r'<KeyFrameDouble value="([-\d.]+)" frame="(\d+)"')
        .allMatches(block.group(3)!)
        .map((m) => double.parse(m.group(1)!))
        .toList();
  }

  test('the rise and the bounce are the curves the painter uses', () {
    // Rive samples them frame by frame (60 fps over 300 ms), so the artboard
    // and the painter fallback move identically.
    final rise = keys('Rise', 16);
    final bounce = keys('Bounce', 16);
    expect(rise.length, AppRoad.riseMs ~/ (1000 / 60) + 1);
    for (var i = 0; i < rise.length; i++) {
      final t = i / (rise.length - 1);
      expect(rise[i], closeTo(AppRoad.riseScale(t), 1e-3), reason: 'rise $t');
      expect(bounce[i], closeTo(AppRoad.arriveBounce(t), 1e-3));
    }
    // The lift, 4 points at the phone's face, in artboard units.
    final y = keys('Rise', 14);
    final unit = LessonNodeArt.faceSize / RoadSize.phone.platform;
    for (var i = 0; i < y.length; i++) {
      final t = i / (y.length - 1);
      expect(y.first - y[i], closeTo(AppRoad.riseLift(t) * unit, 1e-3));
    }
    expect(keys('Ahead', 16).single, AppRoad.aheadScale);
  });
}
