import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../../data/services/api_client.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/repositories.dart';

class BonCommandeRepositoryImpl implements BonCommandeRepository {
  final Dio _dio = ApiClient.instance.dio;

  String _mapError(DioException e) {
    final detail = e.response?.data is Map ? e.response?.data['detail'] : null;
    return detail?.toString() ?? e.message ?? 'Erreur inconnue';
  }

  BonCommande _parse(Map<String, dynamic> d) => BonCommande(
    id: d['id'] as int,
    numeroBc: d['numero_bc'] as String,
    typeStock: d['type_stock'] as String,
    fournisseurNom: d['fournisseur_nom'] as String?,
    statut: d['statut'] as String,
    dateCreation: DateTime.parse(d['date_creation'] as String),
    lignes: (d['lignes'] as List<dynamic>? ?? []).map((l) => LigneBonCommande(
      id: l['id'] as int, produitId: l['produit_id'] as int?,
      designation: l['designation'] as String,
      quantite: (l['quantite'] as num).toDouble(),
      prixUnitaireEstime: (l['prix_unitaire_estime'] as num?)?.toDouble() ?? 0.0,
    )).toList(),
  );

  @override
  Future<Either<String, List<BonCommande>>> getBonsCommande({String? typeStock, String statut = 'ouvert'}) async {
    try {
      final response = await _dio.get(AppConfig.bonsCommande, queryParameters: {
        if (typeStock != null) 'type_stock': typeStock,
        'statut': statut,
      });
      final list = (response.data['results'] as List).map((e) => _parse(e as Map<String, dynamic>)).toList();
      return Right(list);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, BonCommande>> getBonCommandeDetail(int id) async {
    try {
      final url = AppConfig.bonCommandeDetail.replaceAll('{id}', '$id');
      final response = await _dio.get(url);
      return Right(_parse(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, BonCommande>> creerBonCommande({
      required String typeStock, String? fournisseurNom, required List<Map<String, dynamic>> lignes}) async {
    try {
      final response = await _dio.post(AppConfig.bonsCommande, data: {
        'type_stock': typeStock, 'fournisseur_nom': fournisseurNom, 'lignes': lignes,
      });
      return Right(_parse(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }
}