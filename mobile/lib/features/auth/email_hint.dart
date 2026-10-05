import 'package:flutter/foundation.dart';

/// The placeholder in every email field in the app.
///
/// It used to read `you@school.edu` everywhere. The website's student discount
/// is tied to a verified .edu address, so a lone school domain in the
/// placeholder reads as a requirement rather than an example, and the app is
/// free for everyone (owner, 2026-10-05).
///
/// So the domain rolls: `you@` stays put and the part after it changes every
/// [emailHintEvery], old rolling up and out while the next comes up into its
/// place. A student reads two or three of them before they start typing, which
/// is what actually says "any address" (owner picked the roll, 2026-10-05).
///
/// The rotation stops the moment there is anything in the field, and never
/// starts at all for someone who has asked their phone to reduce motion.
const emailHintPrefix = 'you@';

const emailHintDomains = <String>[
  'gmail.com',
  'icloud.com',
  'outlook.com',
  'yahoo.com',
  'school.edu',
];

const emailHintEvery = Duration(milliseconds: 1500);

/// Holds the placeholder on one domain and stops the clock, so a photographed
/// screen does not change between runs and `pumpAndSettle` has something to
/// settle on. Tests only.
@visibleForTesting
String? debugEmailHintStatic;

/// What an email field passes to the kit's XL field: the fixed head, and the
/// domains to roll through under it. A test that has pinned the placeholder
/// gets one still string and no clock.
({String head, List<String>? tail}) emailHintField() =>
    debugEmailHintStatic == null
    ? (head: emailHintPrefix, tail: emailHintDomains)
    : (head: '$emailHintPrefix$debugEmailHintStatic', tail: null);
