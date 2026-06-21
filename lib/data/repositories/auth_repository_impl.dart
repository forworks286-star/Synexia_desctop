import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/app_config.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/repositories.dart';
import '../services/api_client.dart';

class AuthRepositoryImpl implements AuthRepository {
  final _dio = ApiClient.instance.dio;
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  Future<Either<String, User>> login(String username, String password) async {
    try {
      final response = await _dio.post(AppConfig.authLogin, data: {
        'username': username,
        'password': password,
      });
      await _storage.write(key: AppConfig.tokenKey, value: response.data['access'] as String);
      await _storage.write(key: AppConfig.refreshTokenKey, value: response.data['refresh'] as String);
      final user = _parseUser(response.data['user'] as Map<String, dynamic>);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.userKey, jsonEncode(response.data['user']));
      return Right(user);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return const Left('error_auth');
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.connectionError) {
        return const Left('error_network');
      }
      return const Left('error_server');
    }
  }

  @override
  Future<Either<String, User>> loginBiometric() async {
    return const Left('error_auth');
  }

  @override
  Future<Either<String, void>> logout() async {
    try { await _dio.post(AppConfig.authLogout); } catch (_) {}
    await _storage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.userKey);
    return const Right(null);
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(AppConfig.userKey);
      if (raw == null) return null;
      return _parseUser(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) { return null; }
  }

  @override
  Future<bool> refreshToken() async {
    try {
      final refresh = await _storage.read(key: AppConfig.refreshTokenKey);
      if (refresh == null) return false;
      final response = await _dio.post(AppConfig.authRefresh, data: {'refresh': refresh});
      await _storage.write(key: AppConfig.tokenKey, value: response.data['access'] as String);
      return true;
    } catch (_) { return false; }
  }

  User _parseUser(Map<String, dynamic> data) => User(
    id: data['id'] as int,
    fullName: (data['full_name'] as String?) ?? '',
    username: (data['username'] as String?) ?? '',
    role: _parseRole(data['role'] as String?),
    permissions: (data['permissions'] as List?)?.map((e) => e.toString()).toList() ?? [],
    biometricEnabled: false,
    lastLogin: data['last_login'] != null ? DateTime.tryParse(data['last_login'].toString()) : null,
  );

  UserRole _parseRole(String? role) {
    switch (role) {
      case 'admin': return UserRole.admin;
      case 'manager': return UserRole.manager;
      case 'agent_kiosk': return UserRole.agentKiosk;
      default: return UserRole.stockiste;
    }
  }
}