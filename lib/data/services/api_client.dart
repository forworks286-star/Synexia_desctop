import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/config/app_config.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // القفل: يمنع عدة تجديدات متوازية من التصادم مع بعض
  Completer<bool>? _refreshCompleter;

  ApiClient._() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(milliseconds: AppConfig.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // تجديد استباقي: إذا access باقيلو أقل من 5 دقائق، نجدد قبل ما نبعث الطلب
        await _refreshIfExpiringSoon();
        final token = await _storage.read(key: AppConfig.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final detail = error.response?.data?['detail'];
          if (detail == 'error_session_compromised') {
            // كشف سرقة: خروج فوري بلا محاولة تجديد
            await _storage.deleteAll();
            Get.offAllNamed('/login');
            Get.snackbar('Session terminée',
                'Votre session a été fermée pour raison de sécurité. Reconnectez-vous.');
            return handler.next(error);
          }
          final refreshed = await _refreshToken();
          if (refreshed) {
            final token = await _storage.read(key: AppConfig.tokenKey);
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            try {
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (_) {}
          } else {
            await _storage.deleteAll();
            Get.offAllNamed('/login');
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
  Future<bool> _refreshToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    final completer = Completer<bool>();
    _refreshCompleter = completer;
    try {
      final refresh = await _storage.read(key: AppConfig.refreshTokenKey);
      if (refresh == null) {
        completer.complete(false);
        return false;
      }
      final response = await _dio.post(
        AppConfig.authRefresh,
        data: {'refresh_token': refresh},
      );
      await _storage.write(key: AppConfig.tokenKey, value: response.data['access'] as String);
      await _storage.write(key: AppConfig.refreshTokenKey, value: response.data['refresh'] as String);
      completer.complete(true);
      return true;
    } catch (_) {
      completer.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }
}