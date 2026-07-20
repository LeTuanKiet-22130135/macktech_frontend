import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'session_service.dart';

/// Centralized Dio client singleton.
/// Provides connection pooling, automatic JWT injection, and error handling.
class DioClient {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080';

  static Dio? _instance;

  /// Returns the singleton Dio instance.
  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        contentType: 'application/json',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    // Auth interceptor: automatically attaches JWT to non-public requests
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip auth header for public auth endpoints
          final path = options.path;
          if (!path.startsWith('/api/auth/')) {
            final token = await SessionService.getToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized by attempting to refresh the token
          if (error.response?.statusCode == 401 && !error.requestOptions.path.startsWith('/api/auth/')) {
            final refreshToken = await SessionService.getRefreshToken();
            if (refreshToken != null) {
              try {
                final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
                final refreshResponse = await refreshDio.post(
                  '/api/auth/refresh',
                  data: {'refreshToken': refreshToken},
                );

                final data = refreshResponse.data as Map<String, dynamic>;
                final user = await SessionService.getUser();
                
                // Keep existing user data but update tokens
                user['token'] = data['token'];
                user['refreshToken'] = data['refreshToken'];
                await SessionService.save(user);

                // Retry original request
                final opts = error.requestOptions;
                opts.headers['Authorization'] = 'Bearer ${data['token']}';
                
                final cloneReq = await refreshDio.request(
                  opts.path,
                  options: Options(
                    method: opts.method,
                    headers: opts.headers,
                  ),
                  data: opts.data,
                  queryParameters: opts.queryParameters,
                );
                return handler.resolve(cloneReq);
              } catch (e) {
                // Refresh failed, clear session to force re-login
                await SessionService.clear();
              }
            } else {
              await SessionService.clear();
            }
          }

          // Centralized error handling: parse backend error messages
          if (error.response != null) {
            final data = error.response?.data;
            if (data is Map<String, dynamic> && data.containsKey('message')) {
              final message = data['message'] as String;
              handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  response: error.response,
                  type: error.type,
                  error: message,
                  message: message,
                ),
              );
              return;
            }
          }
          handler.next(error);
        },
      ),
    );

    // Parse JSON in a background isolate to prevent UI freezes
    dio.transformer = BackgroundTransformer();

    return dio;
  }
}
