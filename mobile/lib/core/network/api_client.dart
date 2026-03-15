import 'package:dio/dio.dart';
import '../navigation/navigation_service.dart';
import 'api_errors.dart';
import 'api_base_url.dart';
import '../storage/secure_store.dart';

class ApiClient {
  static String _resolveBaseUrl() => getApiBaseUrl();

  /// WebSocket base URL (e.g. ws://192.168.1.5:8080) derived from API base.
  /// Used for chat and other WS endpoints.
  static String get wsBaseUrl {
    final api = _resolveBaseUrl();
    final uri = Uri.parse(api);
    return 'ws://${uri.host}:${uri.port}';
  }

  static final dio = Dio(
    BaseOptions(
      baseUrl: _resolveBaseUrl(),
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStore.read('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (err, handler) {
          final apiError = ApiException.fromDio(err);
          if (apiError.statusCode == 409 &&
              apiError.code == 'PROFILE_REQUIRED') {
            NavigationService.goToProfileSetup();
          }
          handler.next(apiError.toDioException());
        },
      ),
    );
}
