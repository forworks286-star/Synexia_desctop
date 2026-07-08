import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/config/app_config.dart';


enum _RefreshResult { success, sessionExpired, sessionCompromised }
class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  late final Dio _plainDio;   
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );


  Completer<_RefreshResult>? _refreshCompleter;
  ApiClient._() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(milliseconds: AppConfig.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
      headers: {'Content-Type': 'application/json'},
    ));

    _plainDio = Dio(BaseOptions(
      connectTimeout: const Duration(milliseconds: AppConfig.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
   
        await _refreshIfExpiringSoon();
        final token = await _storage.read(key: AppConfig.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final result = await _refreshToken();
          if (result == _RefreshResult.success) {
            final token = await _storage.read(key: AppConfig.tokenKey);
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            try {
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (_) {}
          } else {
            await _storage.deleteAll();
            Get.offAllNamed('/login');
            if (result == _RefreshResult.sessionCompromised) {
              Get.snackbar('Session terminée',
                  'Votre session a été fermée pour raison de sécurité. Reconnectez-vous.');
            } else {
              Get.snackbar('Session expirée',
                  'Votre session a expiré. Veuillez vous reconnecter.');
            }
          }
        }
        return handler.next(error);
      },
    ));
  }

  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  Dio get dio => _dio;

  /// يفحص وقت انتهاء access token المخزّن، ويجدد قبل الانتهاء بـ 5 دقائق
  Future<void> _refreshIfExpiringSoon() async {
    final token = await _storage.read(key: AppConfig.tokenKey);
    if (token == null) return;
    final exp = _getTokenExpiry(token);
    if (exp == null) return;
    final remaining = exp.difference(DateTime.now());
    if (remaining < const Duration(minutes: 5)) {
      await _refreshToken();
    }
  }

  DateTime? _getTokenExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      var payload = parts[1];
      payload += '=' * ((4 - payload.length % 4) % 4);
      final decoded = jsonDecode(utf8.decode(base64Url.decode(payload)));
      final exp = decoded['exp'] as int?;
      if (exp == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    } catch (_) {
      return null;
    }
  }

  /// نقطة الدخول الوحيدة للتجديد. لو تجديد شغال حاليًا، ننتظر نتيجته بدل ما نبدأ وحدة جديدة.
  Future<_RefreshResult> _refreshToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    final completer = Completer<_RefreshResult>();
    _refreshCompleter = completer;
    try {
      final refresh = await _storage.read(key: AppConfig.refreshTokenKey);
      if (refresh == null) {
        completer.complete(_RefreshResult.sessionExpired);
        return _RefreshResult.sessionExpired;
      }
      final response = await _plainDio.post(
        AppConfig.authRefresh,
        data: {'refresh_token': refresh},
      );
      await _storage.write(key: AppConfig.tokenKey, value: response.data['access'] as String);
      await _storage.write(key: AppConfig.refreshTokenKey, value: response.data['refresh'] as String);
      completer.complete(_RefreshResult.success);
      return _RefreshResult.success;
    } on DioException catch (e) {
      final detail = e.response?.data?['detail'];
      final result = detail == 'error_session_compromised'
          ? _RefreshResult.sessionCompromised
          : _RefreshResult.sessionExpired;
      completer.complete(result);
      return result;
    } catch (_) {
      completer.complete(_RefreshResult.sessionExpired);
      return _RefreshResult.sessionExpired;
    } finally {
      _refreshCompleter = null;
    }
  }
}