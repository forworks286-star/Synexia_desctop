import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/config/app_config.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/repositories.dart';
import '../services/api_client.dart';

class ManufacturingRepositoryImpl implements ManufacturingRepository {
  final _dio = ApiClient.instance.dio;

  @override
  Future<Either<String, List<BomModel>>> getBoms() async {
    try {
      final response = await _dio.get(AppConfig.bomAll);
      final list = (response.data['results'] as List)
          .map((e) => _parseBom(e as Map<String, dynamic>)).toList();
      return Right(list);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, BomModel>> getBomDuProduit(int produitFiniId) async {
    try {
      final url = AppConfig.bomDuProduit.replaceAll('{id}', '$produitFiniId');
      final response = await _dio.get(url);
      return Right(_parseBom(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, BomModel>> creerBom({
      required int produitFiniId, String? nom, required List<Map<String, dynamic>> lignes}) async {
    try {
      final response = await _dio.post(AppConfig.bomAll, data: {
        'produit_fini_id': produitFiniId, 'nom': nom, 'lignes': lignes,
      });
      return Right(_parseBom(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> creerOrdreFabrication({
      required int bomId, required double quantiteProduite, String? emplacement,
      String? dateFabrication, String? dateExpiration, String? numeroLot}) async {
    try {
      final response = await _dio.post(AppConfig.ordresFabrication, data: {
        'bom_id': bomId, 'quantite_produite': quantiteProduite,
        'emplacement_produit_fini': emplacement,
        'date_fabrication': dateFabrication, 'date_expiration': dateExpiration,
        'numero_lot_produit_fini': numeroLot,
      });
      return Right(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> getMaxRealisable(int bomId) async {
    try {
      final url = AppConfig.bomMaxRealisable.replaceAll('{id}', '$bomId');
      final response = await _dio.get(url);
      return Right(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, List<OrdreFabrication>>> getOrdresFabrication() async {
    try {
      final response = await _dio.get(AppConfig.ordresFabrication);
      final list = (response.data['results'] as List).map((e) {
        final d = e as Map<String, dynamic>;
        return OrdreFabrication(
          id: d['id'] as int, numeroOf: d['numero_of'] as String, bomId: d['bom_id'] as int,
          produitFiniNom: d['produit_fini_nom'] as String?,
          quantiteProduite: (d['quantite_produite'] as num).toDouble(),
          numeroLot: d['numero_lot'] as String?,
          coutRevientTotal: (d['cout_revient_total'] as num?)?.toDouble(),
          coutRevientUnitaire: (d['cout_revient_unitaire'] as num?)?.toDouble(),
          dateCreation: DateTime.tryParse(d['date_creation']?.toString() ?? '') ?? DateTime.now(),
        );
      }).toList();
      return Right(list);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  BomModel _parseBom(Map<String, dynamic> data) => BomModel(
    id: data['id'] as int, produitFiniId: data['produit_fini_id'] as int,
    produitFiniNom: data['produit_fini_nom'] as String?, nom: data['nom'] as String?,
    actif: (data['actif'] as bool?) ?? true,
    lignes: (data['lignes'] as List? ?? []).map((e) {
      final d = e as Map<String, dynamic>;
      return LigneBom(
        id: d['id'] as int, composantProduitId: d['composant_produit_id'] as int,
        composantNom: d['composant_nom'] as String? ?? '—',
        composantUnite: d['composant_unite'] as String?,
        quantiteNecessaire: (d['quantite_necessaire'] as num).toDouble(),
        tauxPerte: (d['taux_perte'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList(),
  );

  String _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) return 'error_network';
    if (e.response?.statusCode == 401) return 'error_auth';
    final detail = e.response?.data?['detail'];
    if (detail is String) return detail;
    return 'error_server';
  }
}