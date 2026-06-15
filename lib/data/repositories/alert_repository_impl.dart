import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/config/app_config.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/repositories.dart';
import '../services/api_client.dart';

class AlertRepositoryImpl implements AlertRepository {
  final _dio = ApiClient.instance.dio;
  WebSocketChannel? _channel;
  final _streamController = StreamController<Alert>.broadcast();

  @override
  Future<Either<String, List<Alert>>> getAlerts() async {
    try {
      final response = await _dio.get(AppConfig.alertesHistory);
      final alerts = (response.data['results'] as List)
          .map((e) => _parseAlert(e as Map<String, dynamic>))
          .toList();
      return Right(alerts);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) return const Left('error_network');
      return const Left('error_server');
    }
  }

  @override
  Stream<Alert> alertStream() {
    _connectWebSocket();
    return _streamController.stream;
  }

  @override
  Future<Either<String, void>> markAsRead(int alertId) async {
    try {
      await _dio.put('${AppConfig.alertesHistory}/$alertId/read');
      return const Right(null);
    } on DioException catch (_) {
      return const Left('error_server');
    }
  }

  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(AppConfig.alertesRealtime));
      _channel!.stream.listen(
        (data) {
          final json = jsonDecode(data as String) as Map<String, dynamic>;
          _streamController.add(_parseAlert(json));
        },
        onError: (_) => Future.delayed(const Duration(seconds: 5), _connectWebSocket),
        onDone: () => Future.delayed(const Duration(seconds: 5), _connectWebSocket),
      );
    } catch (_) {
      Future.delayed(const Duration(seconds: 5), _connectWebSocket);
    }
  }

  Alert _parseAlert(Map<String, dynamic> data) => Alert(
    id: data['id'] as int,
    level: _parseLevel(data['level'] as String),
    title: data['title'] as String,
    message: data['message'] as String,
    createdAt: DateTime.parse(data['created_at'] as String),
    isRead: (data['is_read'] as bool?) ?? false,
  );

  AlertLevel _parseLevel(String level) {
    switch (level) {
      case 'danger': return AlertLevel.danger;
      case 'warning': return AlertLevel.warning;
      case 'success': return AlertLevel.success;
      default: return AlertLevel.info;
    }
  }

  void dispose() {
    _channel?.sink.close();
    _streamController.close();
  }
}
