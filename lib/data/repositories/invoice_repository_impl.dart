import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/config/app_config.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/repositories.dart';
import '../services/api_client.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final _dio = ApiClient.instance.dio;

  @override
  Future<Either<String, List<Invoice>>> getInvoices() async {
    try {
      final response = await _dio.get(AppConfig.facturesAll);
      final invoices = (response.data['results'] as List)
          .map((e) => _parseInvoice(e as Map<String, dynamic>))
          .toList();
      return Right(invoices);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, Invoice>> getInvoice(int id) async {
    try {
      final response = await _dio.get('${AppConfig.facturesAll}/$id');
      return Right(_parseInvoice(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, Invoice>> submitOcrResult(Map<String, dynamic> ocrData) async {
    try {
      final response = await _dio.post(AppConfig.ocrReceive, data: ocrData);
      return Right(_parseInvoice(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, void>> validateInvoice(int id) async {
    try {
      final url = AppConfig.facturesValidate.replaceAll('{id}', '$id');
      await _dio.put(url);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, void>> rejectInvoice(int id) async {
    try {
      await _dio.put('${AppConfig.facturesAll}/$id/rejeter');
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  Invoice _parseInvoice(Map<String, dynamic> data) => Invoice(
    id: data['id'] as int,
    supplierName: data['supplier_name'] as String,
    date: DateTime.parse(data['date'] as String),
    amountHt: (data['amount_ht'] as num).toDouble(),
    amountTtc: (data['amount_ttc'] as num).toDouble(),
    stampDetected:      (data['stamp_detected'] as bool?) ?? true,
    signatureDetected:  (data['signature_detected'] as bool?) ?? true,
    status:             _parseStatus(data['status'] as String? ?? 'pending'),
    photoUrl:           data['photo_url'] as String?,
    typeFacture:        (data['type_facture'] as String?) ?? 'achat',
  );

  InvoiceStatus _parseStatus(String status) {
    switch (status) {
      case 'validated': return InvoiceStatus.validated;
      case 'rejected': return InvoiceStatus.rejected;
      default: return InvoiceStatus.pending;
    }
  }

  String _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) return 'error_network';
    if (e.response?.statusCode == 401) return 'error_auth';
    return 'error_server';
  }
}
