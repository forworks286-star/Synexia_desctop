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
  Future<Either<String, void>> registerMovement({
    required int produitId,
    required int lotId,
    required MovementType type,
    required int quantite,
  }) async {
    try {
      await _dio.post(AppConfig.stockMovements, data: {
        'produit_id': produitId,
        'lot_id': lotId,
        'type': type == MovementType.entry ? 'entree' : (type == MovementType.returnType ? 'retour' : 'sortie'),
        'quantite': quantite,
      });
      return const Right(null);
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
        totalProducts:    data['total_products'] as int? ?? 0,
        todayEntries:     data['today_entries'] as int? ?? 0,
        todayExits:       data['today_exits'] as int? ?? 0,
        activeAlerts:     data['active_alerts'] as int? ?? 0,
        pendingInvoices:  data['pending_invoices'] as int? ?? 0,
        availability:     (data['availability'] as num?)?.toDouble() ?? 0,
        valeurStockTotal: (data['valeur_stock_total'] as num?)?.toDouble() ?? 0,
      ));
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, List<ChartPoint>>> getMovementsChart({int days = 7}) async {
    try {
      final response = await _dio.get(AppConfig.dashboardMovementsChart, queryParameters: {'days': days});
      final points = (response.data['results'] as List)
          .map((e) => ChartPoint(
                date:    e['date'] as String,
                entrees: e['entrees'] as int? ?? 0,
                sorties: e['sorties'] as int? ?? 0,
              ))
          .toList();
      return Right(points);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, List<CommandeAuto>>> getCommandesAuto() async {
    try {
      final response = await _dio.get(AppConfig.stockCommandesAuto);
      final list = (response.data['results'] as List)
          .map((e) => CommandeAuto(
                id:                 e['id'] as int,
                sku:                e['sku'] as String,
                designation:        e['designation'] as String,
                quantiteSuggeree:   e['quantite_suggeree'] as int,
                fournisseurNom:     e['fournisseur_nom'] as String? ?? '—',
                dernierPrixAchat:   (e['dernier_prix_achat'] as num?)?.toDouble() ?? 0,
                timestamp:          DateTime.tryParse(e['timestamp']?.toString() ?? '') ?? DateTime.now(),
              ))
          .toList();
      return Right(list);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, void>> validerCommande(int id) async {
    try {
      await _dio.put('${AppConfig.stockCommandesAuto}/$id/valider');
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, void>> rejeterCommande(int id) async {
    try {
      await _dio.put('${AppConfig.stockCommandesAuto}/$id/rejeter');
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, List<IoTZone>>> getIoTDashboard() async {
    try {
      final response = await _dio.get(AppConfig.dashboardIot);
      final zones = (response.data['zones'] as List)
          .map((e) => IoTZone(
                deviceId:    e['device_id'] as String? ?? '',
                module:      e['module'] as String? ?? '',
                zoneId:      e['zone_id'] as String? ?? '',
                hasAlarm:    e['has_alarm'] as bool? ?? false,
                timestamp:   DateTime.tryParse(e['timestamp']?.toString() ?? '') ?? DateTime.now(),
                inputs:      Map<String, dynamic>.from(e['inputs'] as Map? ?? {}),
                outputs:     Map<String, dynamic>.from(e['outputs'] as Map? ?? {}),
                states:      Map<String, dynamic>.from(e['states'] as Map? ?? {}),
                lighting:    Map<String, dynamic>.from(e['lighting'] as Map? ?? {}),
                hvac:        Map<String, dynamic>.from(e['hvac'] as Map? ?? {}),
                energy:      Map<String, dynamic>.from(e['energy'] as Map? ?? {}),
                alarms:      Map<String, dynamic>.from(e['alarms'] as Map? ?? {}),
                diagnostic:  Map<String, dynamic>.from(e['diagnostic'] as Map? ?? {}),
                maintenance: Map<String, dynamic>.from(e['maintenance'] as Map? ?? {}),
              ))
          .toList();
      return Right(zones);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, List<FaceEvent>>> getFaceEvents() async {
    try {
      final response = await _dio.get(AppConfig.integrationsFaceEvents);
      final events = (response.data['results'] as List)
          .map((e) => FaceEvent(
                id:         e['id'] as int,
                personneId: e['personne_id'] as String?,
                nom:        e['nom'] as String?,
                reconnu:    e['reconnu'] as bool? ?? false,
                confiance:  e['confiance'] as String?,
                zone:       e['zone'] as String?,
                autorise:   e['autorise'] as bool? ?? false,
                timestamp:  DateTime.tryParse(e['timestamp']?.toString() ?? '') ?? DateTime.now(),
              ))
          .toList();
      return Right(events);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }


  @override
  Future<Either<String, void>> ajoutManuelComplet(Map<String, dynamic> data) async {
    try {
      await _dio.post(AppConfig.produitAjoutManuelComplet, data: data);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  Product _parseProduct(Map<String, dynamic> data) {
    final lotsRaw = data['lots'] as List? ?? [];
    return Product(
      id:                   data['id'] as int,
      sku:                  (data['sku'] as String?) ?? '',
      name:                 (data['name'] as String?) ?? '',
      categorie:            data['categorie'] as String?,
      qrReference:          (data['qr_reference'] as String?) ?? '',
      codeBarre:            data['code_barre'] as String?,
      uniteMesure:          (data['unite_mesure'] as String?) ?? 'piece',
      numeroSerie:          data['numero_serie'] as String?,
      photoUrl:             data['photo_url'] as String?,
      paysOrigine:          data['pays_origine'] as String?,
      statutProduit:        (data['statut_produit'] as String?) ?? 'actif',
      stockPhysique:        data['stock_physique'] as int? ?? 0,
      stockDisponible:      data['stock_disponible'] as int? ?? 0,
      stockReserve:         data['stock_reserve'] as int? ?? 0,
      alertThreshold:       data['alert_threshold'] as int? ?? 0,
      stockSecurite:        data['stock_securite'] as int? ?? 0,
      quantiteMinCommande:  data['quantite_min_commande'] as int? ?? 1,
      quantiteMaxStock:     data['quantite_max_stock'] as int?,
      prixAchat:            (data['prix_achat'] as num?)?.toDouble() ?? 0,
      prixMoyenPondere:     (data['prix_moyen_pondere'] as num?)?.toDouble() ?? 0,
      prixVente:            (data['prix_vente'] as num?)?.toDouble() ?? 0,
      tauxTva:              (data['taux_tva'] as num?)?.toDouble() ?? 19,
      devise:               (data['devise'] as String?) ?? 'DZD',
      valeurStock:          (data['valeur_stock'] as num?)?.toDouble() ?? 0,
      supplierName:         data['supplier_name'] as String?,
      supplierId:           data['supplier_id'] as int?,
      supplierSecondaireName: data['supplier_secondaire_name'] as String?,
      delaiLivraisonJours:  data['delai_livraison_jours'] as int?,
      champsExtra:          (data['champs_extra'] as Map<String, dynamic>?) ?? {},
      lots:                 lotsRaw.map((l) => Lot(
        id:                  l['id'] as int,
        numeroLot:           l['numero_lot'] as String?,
        quantitePhysique:    l['quantite_physique'] as int? ?? 0,
        quantiteDisponible:  l['quantite_disponible'] as int? ?? 0,
        statut:              l['statut'] as String? ?? 'disponible',
        emplacement:         l['emplacement'] as String?,
        dateExpiration:      l['date_expiration'] != null
                               ? DateTime.tryParse(l['date_expiration'].toString())
                               : null,
      )).toList(),
    );
  }

  Movement _parseMovement(Map<String, dynamic> data) => Movement(
    id:                   data['id'] as int,
    productId:            data['product_id'] as int,
    productName:          (data['product_name'] as String?) ?? '',
    type:                 data['type'] == 'entry' ? MovementType.entry
                          : (data['type'] == 'return' ? MovementType.returnType : MovementType.exit),
    quantity:             data['quantity'] as int,
    numeroCommandeAchat:  data['numero_commande_achat'] as String?,
    numeroBl:             data['numero_bl'] as String?,
    date:                 DateTime.tryParse(data['date']?.toString() ?? '') ?? DateTime.now(),
    userName:             data['user_name'] as String?,
  );

  String _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) return 'error_network';
    if (e.response?.statusCode == 401) return 'error_auth';
    if (e.response?.statusCode == 403) return 'error_forbidden';
    return 'error_server';
  }
}