/// A friendly, user-facing API error. [message] is safe to show directly in a
/// banner ("Incorrect email or password.", "Couldn't reach the server…").
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.isNetwork = false});

  final String message;
  final int? statusCode;
  final bool isNetwork;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
