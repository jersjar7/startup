import 'package:dio/dio.dart';

import 'api_config.dart';
import 'api_exception.dart';

/// Thin wrapper over Dio that talks to the FE for Raccoons backend.
///
/// - Sends `x-client: mobile` on every request (so the backend returns the
///   bearer token on login/register and treats us as the app).
/// - Attaches `Authorization: Bearer <token>` once we have one.
/// - Maps Dio failures to a friendly [ApiException] (using the server's `msg`
///   where present), and fires [onUnauthorized] when a call 401s so the app can
///   route back to sign in ("Your session expired").
class ApiClient {
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'x-client': 'mobile'},
      // We handle non-2xx ourselves so we can read the server's message.
      validateStatus: (s) => s != null && s < 500,
    ));
  }

  late final Dio _dio;
  String? _token;

  /// Called when any request comes back 401 with a token attached (expired or
  /// revoked session). The app uses this to sign out and show the banner.
  void Function()? onUnauthorized;

  void setToken(String? token) => _token = token;

  Options get _opts => Options(
        headers: _token != null ? {'Authorization': 'Bearer $_token'} : null,
      );

  Future<dynamic> get(String path) => _send(() => _dio.get(path, options: _opts));

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) =>
      _send(() => _dio.post(path, data: body, options: _opts));

  Future<dynamic> delete(String path, [Map<String, dynamic>? body]) =>
      _send(() => _dio.delete(path, data: body, options: _opts));

  Future<dynamic> _send(Future<Response> Function() run) async {
    Response res;
    try {
      res = await run();
    } on DioException catch (_) {
      // No response = connectivity/timeout.
      throw ApiException(
        "Couldn't reach the server. Check your connection and try again.",
        isNetwork: true,
      );
    }

    final status = res.statusCode ?? 0;
    if (status >= 200 && status < 300) return res.data;

    // Server sent an error with a message we can show.
    final msg = (res.data is Map && res.data['msg'] is String)
        ? res.data['msg'] as String
        : 'Something went wrong. Please try again.';

    if (status == 401 && _token != null) {
      // A request we made *with* a token was rejected → the session is gone.
      onUnauthorized?.call();
    }
    throw ApiException(msg, statusCode: status);
  }
}
