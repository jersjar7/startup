import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

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
}
