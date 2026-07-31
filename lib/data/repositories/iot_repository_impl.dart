import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../../data/services/api_client.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/repositories.dart';

class IoTRepositoryImpl implements IoTRepository {
  final Dio _dio = ApiClient.instance.dio;

  String _mapError(DioException e) {
    final detail = e.response?.data is Map ? e.response?.data['detail'] : null;
    return detail?.toString() ?? e.message ?? 'Erreur inconnue';
  }

  IoTZoneState parseZone(Map<String, dynamic> d) => IoTZoneState(
    zoneId: d['zone_id'] as String,
    nom: d['nom'] as String,
    profil: d['profil'] as String,
    valeurs: Map<String, dynamic>.from(d['valeurs'] as Map? ?? {}),
    niveau: d['niveau'] as String? ?? 'normal',
    libelle: d['libelle'] as String? ?? '',
    resoluAuto: d['resolu_auto'] as bool?,
    derniereMaj: d['derniere_maj'] != null ? DateTime.tryParse(d['derniere_maj'] as String) : null,
  );

  @override
  Future<Either<String, List<IoTZoneState>>> getZones() async {
    try {
      final response = await _dio.get(AppConfig.iotZones);
      final list = (response.data['results'] as List).map((e) => parseZone(e as Map<String, dynamic>)).toList();
      return Right(list);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<String, IoTZoneState>> getZoneDetail(String zoneId) async {
    try {
      final url = AppConfig.iotZoneDetail.replaceAll('{id}', zoneId);
      final response = await _dio.get(url);
      return Right(parseZone(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }
}