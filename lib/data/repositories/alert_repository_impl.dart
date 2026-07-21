import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/config/app_config.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/repositories.dart';
import '../services/api_client.dart';

import 'package:get/get.dart';
import '../../../presentation/controllers/controllers.dart';


class AlertRepositoryImpl implements AlertRepository {
  final _dio = ApiClient.instance.dio;
  WebSocketChannel? _channel;
  final _streamController = StreamController<Alert>.broadcast();
  bool _disposed = false;

  @override
  Future<Either<String, List<Alert>>> getAlerts() async {
    try {
      final response = await _dio.get(AppConfig.alertesHistory);
      final alerts = (response.data['results'] as List)
          .map((e) => _parseAlert(e as Map<String, dynamic>))
          .toList();
      return Right(alerts);
    } on DioException catch (_) {
      return const Right([]);
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
    } catch (_) {
      return const Left('error_server');
    }
  }

  @override
  Future<Either<String, void>> markAllRead() async {
    try {
      await _dio.put('${AppConfig.alertesHistory}/read-all');
      return const Right(null);
    } catch (_) {
      return const Left('error_server');
    }
  }

  void _connectWebSocket() {
  if (_disposed) return;
  try {
    _channel = WebSocketChannel.connect(Uri.parse(AppConfig.alertesRealtime));
    _channel!.stream.listen(
      (data) {
        try {
          final json = jsonDecode(data as String) as Map<String, dynamic>;
          final type = json['type'] as String?;

         
          if (type == null || type == 'new_alert' ||
              json.containsKey('niveau')) {
            _streamController.add(_parseAlert(json));
          }

          
          if (type == 'automation_update') {
            if (Get.isRegistered<StockController>()) {
              Get.find<StockController>().handleWsAutomation(json);
            }
          }

          
          if (type == 'stock_update') {
            if (Get.isRegistered<StockController>()) {
              Get.find<StockController>().loadProducts();
            }
          }


          if (type == 'facture_update') {
            if (Get.isRegistered<InvoiceController>()) {
              Get.find<InvoiceController>().loadInvoices();
            }
          }

          
          if (type == 'new_facture') {
            if (Get.isRegistered<StockController>()) {
              Get.find<StockController>().loadFactures();
            }
          }

          if (type == 'facture_draft_update') {
            if (Get.isRegistered<InvoiceController>()) {
              Get.find<InvoiceController>().loadInvoices();
            }
          }

          if (type == 'demande_update') {
            if (Get.isRegistered<InvoiceController>()) {
              Get.find<InvoiceController>().loadDemandes();
            }
          }

          if (type == 'appairage_update') {
            if (Get.isRegistered<AlertController>()) {
              Get.find<AlertController>().pushAppairage(json);
            }
          }

        } catch (_) {}
      },
      onError: (_) => _scheduleReconnect(),
      onDone: () => _scheduleReconnect(),
      cancelOnError: true,
    );
  } catch (_) {
    _scheduleReconnect();
  }
}

  void _scheduleReconnect() {
    if (_disposed) return;
    Future.delayed(const Duration(seconds: 8), _connectWebSocket);
  }

  Alert _parseAlert(Map<String, dynamic> data) {
    return Alert(
      id:           data['id'] as int,
      level:        _parseLevel(data['level'] as String? ?? 'info'),
      title:        (data['title'] as String?) ?? '',
      message:      (data['message'] as String?) ?? '',
      createdAt:    DateTime.tryParse(data['created_at']?.toString() ?? '') ?? DateTime.now(),
      isRead:       (data['is_read'] as bool?) ?? false,
      sourceModule: data['source_module'] as String?,
      type:         (data['alert_type'] as String?) ?? (data['type'] as String?),
    );
  }
  AlertLevel _parseLevel(String level) {
    switch (level) {
      case 'danger': return AlertLevel.danger;
      case 'warning': return AlertLevel.warning;
      case 'success': return AlertLevel.success;
      default: return AlertLevel.info;
    }
  }

  void dispose() {
    _disposed = true;
    _channel?.sink.close();
    _streamController.close();
  }
}