import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The windows every tablet test draws in (TABLET.md, self-check 1): an
/// 11-inch iPad both ways round, and half of it in split screen beside the
/// Handbook, which must be the phone.
const landscape = Size(1180, 820);
const portrait = Size(820, 1180);
const splitHalf = Size(585, 820);
const phone = Size(390, 844);

void setWindow(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Fonts load from the asset bundle asynchronously; give them a beat.
Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 60)),
  );
  await tester.pumpAndSettle();
}
