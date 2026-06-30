import 'package:flutter/foundation.dart';

/// Base URL for the FE for Raccoons backend (the same API the website uses).
///
/// - **Release** builds talk to production.
/// - **Debug** builds (`flutter run`) talk to a backend on your Mac's
///   localhost, so you can test against the new /content + sessions endpoints
///   before they're deployed. The iOS simulator reaches the host's localhost
///   directly (Info.plist allows local-network HTTP). See mobile/TESTING.md.
const String _prod = 'https://fe4raccoons.com/api';
const String _local = 'http://localhost:4000/api';

const String apiBaseUrl = kReleaseMode ? _prod : _local;
