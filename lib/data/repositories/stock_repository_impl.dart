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
        'type': type == MovementType.entry ? 'entree' : (type == MovementType.returnType ? 'retour' : 'sortie'),
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
        totalProducts: data['total_products'] as int? ?? 0,
        todayEntries: data['today_entries'] as int? ?? 0,
        todayExits: data['today_exits'] as int? ?? 0,
        activeAlerts: data['active_alerts'] as int? ?? 0,
        pendingInvoices: data['pending_invoices'] as int? ?? 0,
        availability: (data['availability'] as num?)?.toDouble() ?? 0,
      ));
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  Product _parseProduct(Map<String, dynamic> data) => Product(
    id: data['id'] as int,
    sku: (data['sku'] as String?) ?? '',
    name: (data['name'] as String?) ?? '',
    categorie: data['categorie'] as String?,
    qrReference: (data['qr_reference'] as String?) ?? '',
    codeBarre: data['code_barre'] as String?,
    uniteMesure: (data['unite_mesure'] as String?) ?? 'piece',
    numeroSerie: data['numero_serie'] as String?,
    photoUrl: data['photo_url'] as String?,
    paysOrigine: data['pays_origine'] as String?,
    statutProduit: (data['statut_produit'] as String?) ?? 'actif',
    stockPhysique: data['stock_physique'] as int? ?? 0,
    stockDisponible: data['stock_disponible'] as int? ?? 0,
    stockReserve: data['stock_reserve'] as int? ?? 0,
    alertThreshold: data['alert_threshold'] as int? ?? 0,
    stockSecurite: data['stock_securite'] as int? ?? 0,
    quantiteMinCommande: data['quantite_min_commande'] as int? ?? 1,
    quantiteMaxStock: data['quantite_max_stock'] as int?,
    prixAchat: (data['prix_achat'] as num?)?.toDouble() ?? 0,
    prixMoyenPondere: (data['prix_moyen_pondere'] as num?)?.toDouble() ?? 0,
    prixVente: (data['prix_vente'] as num?)?.toDouble() ?? 0,
    tauxTva: (data['taux_tva'] as num?)?.toDouble() ?? 19,
    devise: (data['devise'] as String?) ?? 'DZD',
    valeurStock: (data['valeur_stock'] as num?)?.toDouble() ?? 0,
    supplierName: data['supplier_name'] as String?,
    supplierId: data['supplier_id'] as int?,
    supplierSecondaireName: data['supplier_secondaire_name'] as String?,
    delaiLivraisonJours: data['delai_livraison_jours'] as int?,
  );

  Movement _parseMovement(Map<String, dynamic> data) => Movement(
    id: data['id'] as int,
    productId: data['product_id'] as int,
    productName: (data['product_name'] as String?) ?? '',
    type: data['type'] == 'entry' ? MovementType.entry : (data['type'] == 'return' ? MovementType.returnType : MovementType.exit),
    quantity: data['quantity'] as int,
    numeroCommandeAchat: data['numero_commande_achat'] as String?,
    numeroBl: data['numero_bl'] as String?,
    date: DateTime.tryParse(data['date']?.toString() ?? '') ?? DateTime.now(),
    userName: data['user_name'] as String?,
  );

  String _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.connectionError) {
      return 'error_network';
    }
    if (e.response?.statusCode == 401) return 'error_auth';
    return 'error_server';
  }
}