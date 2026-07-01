/// Base URL for the FE for Raccoons backend (the same API the website uses).
///
/// Points at **production** — the always-on server at fe4raccoons.com that also
/// serves the website. `flutter run` works against it with no local server.
///
/// For local backend development, run the service (`cd service && node
/// index.js`) and swap [apiBaseUrl] to [_local]; the iOS simulator reaches the
/// host's localhost and Info.plist allows local-network HTTP. See TESTING.md.
const String _prod = 'https://fe4raccoons.com/api';
// ignore: unused_element
const String _local = 'http://localhost:4000/api';

const String apiBaseUrl = _prod;
