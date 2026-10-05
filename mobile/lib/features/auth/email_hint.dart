import 'dart:math';

import 'package:flutter/foundation.dart';

/// The placeholder in every email field in the app.
///
/// It used to be `you@school.edu` everywhere. The website's student discount
/// is tied to a verified .edu address, so a single school domain in the
/// placeholder reads as a requirement rather than an example, and the app is
/// free for everyone (owner, 2026-10-05). These span personal mail, Apple,
/// work and school, so whichever one a student sees, the field is plainly
/// asking for an address and not a particular kind of address.
///
/// Picked once when a screen is first built, never while someone is looking
/// at it: a placeholder that changes under the cursor is a glitch, not a hint.
/// Moving between sign-up, log in and forgot password shows a different one,
/// which is where the breadth is actually read.
const emailHints = <String>[
  'you@gmail.com',
  'you@icloud.com',
  'you@outlook.com',
  'you@school.edu',
];

/// Pins the placeholder, so a photographed screen does not change between
/// runs. Tests only.
@visibleForTesting
String? debugEmailHint;

/// One placeholder. Pass [random] to make the choice repeatable.
String emailHint([Random? random]) =>
    debugEmailHint ??
    emailHints[(random ?? Random()).nextInt(emailHints.length)];
