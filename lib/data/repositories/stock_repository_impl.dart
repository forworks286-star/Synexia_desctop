import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/config/app_config.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/repositories.dart';
import '../services/api_client.dart';

class StockRepositoryImpl implements StockRepository {
  final _dio = ApiClient.instance.dio;

  @override
  Future<Either<String, List<Product>>> getProducts() async {
    try {
      final response = await _dio.get(AppConfig.stockProducts);
      final products = (response.data['results'] as List)
          .map((e) => _parseProduct(e as Map<String, dynamic>))
          .toList();
      return Right(products);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, Product>> getProductByQr(String qrCode) async {
    try {
      final response = await _dio.post(AppConfig.stockScanQr, data: {'qr_code': qrCode});
      return Right(_parseProduct(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const Left('scan_not_found');
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, Movement>> registerMovement({
    required int productId,
    required MovementType type,
    required int quantity,
  }) async {
    try {
      final response = await _dio.post(AppConfig.stockMovements, data: {
        'product_id': productId,
        'type': type == MovementType.entry ? 'entree' : 'sortie',
        'quantity': quantity,
      });
      return Right(_parseMovement(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, List<Movement>>> getMovements({int? limit}) async {
    try {
      final response = await _dio.get(
        AppConfig.stockMovements,
        queryParameters: limit != null ? {'limit': limit} : null,
      );
      final movements = (response.data['results'] as List)
          .map((e) => _parseMovement(e as Map<String, dynamic>))
          .toList();
      return Right(movements);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, DashboardStats>> getDashboardStats() async {
    try {
      final response = await _dio.get(AppConfig.dashboardStats);
      final data = response.data as Map<String, dynamic>;
      return Right(DashboardStats(
        totalProducts: data['total_products'] as int,
        todayEntries: data['today_entries'] as int,
        todayExits: data['today_exits'] as int,
        activeAlerts: data['active_alerts'] as int,
        pendingInvoices: data['pending_invoices'] as int,
        availability: (data['availability'] as num).toDouble(),
      ));
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  Product _parseProduct(Map<String, dynamic> data) => Product(
    id: data['id'] as int,
    name: data['name'] as String,
    qrReference: data['qr_reference'] as String,
    stockQuantity: data['stock_quantity'] as int,
    alertThreshold: data['alert_threshold'] as int,
    supplierName: data['supplier_name'] as String?,
    supplierId: data['supplier_id'] as int?,
  );

  Movement _parseMovement(Map<String, dynamic> data) => Movement(
    id: data['id'] as int,
    productId: data['product_id'] as int,
    productName: data['product_name'] as String,
    type: data['type'] == 'entree' ? MovementType.entry : MovementType.exit,
    quantity: data['quantity'] as int,
    date: DateTime.parse(data['date'] as String),
    userName: data['user_name'] as String?,
  );

  String _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) return 'error_network';
    if (e.response?.statusCode == 401) return 'error_auth';
    return 'error_server';
  }
}
